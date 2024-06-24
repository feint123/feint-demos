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
            ns_window.setToolbarStyle_(NSWindowToolbarStyle::NSWindowToolbarStyleUnifiedCompact);
        }
    }
}

#[cfg(target_os = "windows")]
pub fn native_windows(window: &tauri::Window, vibrancy_radius: Option<f64>, need_toolbar: bool) {
    use window_shadows::set_shadow;
    use window_vibrancy::apply_blur;

    apply_blur(&window, Some((18, 18, 18, 125)))
        .expect("Unsupported platform! 'apply_blur' is only supported on Windows");

    set_shadow(window, true).unwrap();
}

#[cfg(target_os = "windows")]
pub fn create_main_window(app: &AppHandle) -> Window {
    let main_window = tauri::WindowBuilder::new(
        app,
        "main", /* the unique window label */
        tauri::WindowUrl::App("index.html".parse().unwrap()),
    )
    .transparent(false)
    .decorations(false)
    .resizable(true)
    .visible(true)
    .build()
    .expect("failed to build window");
    main_window
        .set_size(LogicalSize::new(800, 600))
        .expect("failed to set size");
    main_window
        .set_min_size(Some(LogicalSize::new(800, 600)))
        .expect("failed to set min size");
    native_windows(&main_window, None, true);
    return main_window;
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
#[cfg(target_os = "macos")]
pub fn create_main_window(app: &AppHandle) -> WebviewWindow {

    let main_window = tauri::WebviewWindowBuilder::new(
        app,
        "main", /* the unique window label */
        tauri::WebviewUrl::App("index.html".parse().unwrap()),
    )
    .decorations(true)
    .resizable(true)
    .visible(true)
    .accept_first_mouse(true)
    .hidden_title(true)
    .title_bar_style(tauri::TitleBarStyle::Visible)
    .build()
    .expect("failed to build window");
    main_window
        .set_size(LogicalSize::new(800, 600))
        .expect("failed to set size");
    main_window
        .set_min_size(Some(LogicalSize::new(800, 600)))
        .expect("failed to set min size");
    native_windows(&main_window, None, true);
    return main_window;
}
