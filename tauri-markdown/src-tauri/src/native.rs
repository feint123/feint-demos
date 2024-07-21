use tauri::WebviewWindow;
use tauri::{AppHandle, LogicalSize};

#[cfg(target_os = "macos")]
pub fn native_windows(
    window: &tauri::WebviewWindow,
    vibrancy_radius: Option<f64>,
    need_toolbar: bool,
) {
    use cocoa::{
        appkit::{NSWindow, NSWindowToolbarStyle},
        base::id,
    };
    use objc::{class, msg_send, sel, sel_impl};
    // use window_shadows::set_shadow;
    use window_vibrancy::{apply_vibrancy, NSVisualEffectMaterial};

    // set_shadow(window, true).unwrap();

    apply_vibrancy(
        window,
        NSVisualEffectMaterial::Sidebar,
        None,
        vibrancy_radius,
    )
    .expect("Unsupported platform! 'apply_vibrancy' is only supported on macOS");

    if need_toolbar {
        // 添加toolbar让"红绿灯"看起来更自然
        let ns_window = window.ns_window().unwrap() as id;
        unsafe {
            ns_window.setToolbar_(msg_send![class!(NSToolbar), new]);
            ns_window.setToolbarStyle_(NSWindowToolbarStyle::NSWindowToolbarStyleUnified);
        }
    }
}

/**
*  {
       "fullscreen": false,
       "height": 600,
       "resizable": true,
       "title": "dTools",
       "width": 800,
       "titleBarStyle": "Overlay",
       "hiddenTitle": true,
       "transparent": true,
       "minHeight": 600,
       "minWidth": 800,
       "label": "main",
       "acceptFirstMouse": true,
       "url": "index.html",
       "tabbingIdentifier": "test"
     }
*/
pub fn create_main_window(app: &AppHandle) -> WebviewWindow {
    #[cfg(target_os = "macos")]
    let style = tauri::TitleBarStyle::Overlay;

    #[cfg(target_os = "windows")]
    let style = tauri::TitleBarStyle::Visible;

    let main_window = tauri::WebviewWindowBuilder::new(
        app,
        "main", /* the unique window label */
        tauri::WebviewUrl::App("/".parse().unwrap()),
    )
    .decorations(true)
    .resizable(true)
    .visible(true)
    .accept_first_mouse(true)
    .hidden_title(true)
    .title_bar_style(style)
    .build()
    .expect("failed to build window");
    main_window
        .set_size(LogicalSize::new(800, 600))
        .expect("failed to set size");
    main_window
        .set_min_size(Some(LogicalSize::new(800, 600)))
        .expect("failed to set min size");

    #[cfg(target_os = "macos")]
    native_windows(&main_window, None, true);

    return main_window;
}

/**
 * 创建设置窗口
 */
pub fn create_setting_window(app: &AppHandle) -> WebviewWindow {
    #[cfg(target_os = "macos")]
    let style = tauri::TitleBarStyle::Overlay;

    #[cfg(target_os = "windows")]
    let style = tauri::TitleBarStyle::Visible;

    let setting_window = tauri::WebviewWindowBuilder::new(
        app,
        "settings", /* the unique window label */
        tauri::WebviewUrl::App("/settings".parse().unwrap()),
    )
    .decorations(true)
    .visible(true)
    .accept_first_mouse(true)
    .hidden_title(true)
    .title_bar_style(style)
    .build()
    .expect("failed to build window");

    setting_window
        .set_size(LogicalSize::new(800, 600))
        .expect("failed to set size");
    setting_window
        .set_resizable(false)
        .expect("failed to set resizable");

    #[cfg(target_os = "macos")]
    native_windows(&setting_window, None, true);
    return setting_window;
}
