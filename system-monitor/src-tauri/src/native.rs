use tauri::{AppHandle, LogicalSize, Window};


#[cfg(target_os = "macos")]
pub fn native_windows(window: &tauri::Window, vibrancy_radius: Option<f64>, need_toolbar: bool) {
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
    
}

#[cfg(target_os = "windows")]
pub fn native_windows(window: &tauri::Window, vibrancy_radius: Option<f64>, need_toolbar: bool) {

    use window_shadows::set_shadow;
    use window_vibrancy::{apply_blur};

    apply_blur(&window, Some((18, 18, 18, 125))).expect("Unsupported platform! 'apply_blur' is only supported on Windows");

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
    main_window.set_min_size(Some(LogicalSize::new(800, 600))).expect("failed to set min size");
    native_windows(&main_window, None, true);
    return main_window;
}

