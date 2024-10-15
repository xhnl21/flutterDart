#include "flutter_window.h"
// #include "flutter/BadgeManager.h"
#include <optional>

#include "flutter/generated_plugin_registrant.h"
// #include <plugin_registrar_windows.h>

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



// void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

// class BadgePlugin : public flutter::Plugin {
//  public:
//   static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

//   BadgePlugin();

//   virtual ~BadgePlugin();

//  private:
//   void HandleMethodCall(
//       const std::string& method,
//       const flutter::MethodCall<flutter::EncodableValue>& call,
//       std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
// };

// void BadgePlugin::RegisterWithRegistrar(
//     flutter::PluginRegistrarWindows* registrar) {
//   auto plugin = std::make_unique<BadgePlugin>();
//   registrar->AddPlugin(std::move(plugin));
// }

// BadgePlugin::BadgePlugin() {}

// BadgePlugin::~BadgePlugin() {}

// void BadgePlugin::HandleMethodCall(
//     const std::string& method,
//     const flutter::MethodCall<flutter::EncodableValue>& call,
//     std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
//   if (method == "updateBadge") {
//     // Extrae el valor del badge
//     const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
//     if (args) {
//       auto count = std::get_if<int64_t>(&(*args)["count"]);
//       if (count) {
//         BadgeManager::UpdateBadge(*count); // Llama a la función UpdateBadge
//         result->Success();
//         return;
//       }
//     }
//     result->Error("INVALID_ARGUMENT", "Expected an integer count.");
//   } else {
//     result->NotImplemented();
//   }
// }