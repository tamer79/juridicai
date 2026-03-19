#include "flutter_window.h"

#include <gdiplus.h>
#include <objidl.h>
#include <optional>

#include "flutter/generated_plugin_registrant.h"

namespace {

int GetEncoderClsid(const WCHAR* format, CLSID* pClsid) {
  using Gdiplus::GetImageEncodersSize;
  using Gdiplus::GetImageEncoders;
  UINT num = 0;
  UINT size = 0;
  GetImageEncodersSize(&num, &size);
  if (size == 0) {
    return -1;
  }

  std::vector<BYTE> buffer(size);
  auto* image_codec_info =
      reinterpret_cast<Gdiplus::ImageCodecInfo*>(buffer.data());
  GetImageEncoders(num, size, image_codec_info);

  for (UINT i = 0; i < num; ++i) {
    if (wcscmp(image_codec_info[i].MimeType, format) == 0) {
      *pClsid = image_codec_info[i].Clsid;
      return i;
    }
  }
  return -1;
}

std::vector<uint8_t> CaptureScreenPng() {
  static bool gdiplus_initialized = false;
  static ULONG_PTR gdiplus_token = 0;
  if (!gdiplus_initialized) {
    Gdiplus::GdiplusStartupInput gdiplus_startup_input;
    if (Gdiplus::GdiplusStartup(&gdiplus_token, &gdiplus_startup_input,
                               nullptr) == Gdiplus::Ok) {
      gdiplus_initialized = true;
    }
  }

  const int screen_width = GetSystemMetrics(SM_CXSCREEN);
  const int screen_height = GetSystemMetrics(SM_CYSCREEN);
  HDC screen_dc = GetDC(nullptr);
  HDC memory_dc = CreateCompatibleDC(screen_dc);
  HBITMAP bitmap = CreateCompatibleBitmap(screen_dc, screen_width, screen_height);
  HGDIOBJ old_object = SelectObject(memory_dc, bitmap);
  BitBlt(memory_dc, 0, 0, screen_width, screen_height, screen_dc, 0, 0,
         SRCCOPY | CAPTUREBLT);
  SelectObject(memory_dc, old_object);

  std::vector<uint8_t> result;
  if (gdiplus_initialized) {
    CLSID png_clsid;
    if (GetEncoderClsid(L"image/png", &png_clsid) >= 0) {
      Gdiplus::Bitmap bmp(bitmap, nullptr);
      IStream* stream = nullptr;
      if (CreateStreamOnHGlobal(nullptr, TRUE, &stream) == S_OK) {
        if (bmp.Save(stream, &png_clsid, nullptr) == Gdiplus::Ok) {
          STATSTG stat = {};
          if (stream->Stat(&stat, STATFLAG_NONAME) == S_OK) {
            ULONG size = static_cast<ULONG>(stat.cbSize.QuadPart);
            result.resize(size);
            LARGE_INTEGER pos = {};
            stream->Seek(pos, STREAM_SEEK_SET, nullptr);
            ULONG read = 0;
            stream->Read(result.data(), size, &read);
            if (read != size) {
              result.clear();
            }
          }
        }
        stream->Release();
      }
    }
  }

  DeleteObject(bitmap);
  DeleteDC(memory_dc);
  ReleaseDC(nullptr, screen_dc);
  return result;
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  method_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "juridicai/screen_capture",
      &flutter::StandardMethodCodec::GetInstance());

  method_channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "captureScreen") {
          std::vector<uint8_t> bytes = CaptureScreenPng();
          if (bytes.empty()) {
            result->Error("capture_failed", "Failed to capture screen.");
          } else {
            result->Success(flutter::EncodableValue(bytes));
          }
        } else {
          result->NotImplemented();
        }
      });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
