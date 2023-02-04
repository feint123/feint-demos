use tauri::SystemTray;

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
    use window_vibrancy::apply_blur;

    apply_blur(&window, Some((18, 18, 18, 125)))
        .expect("Unsupported platform! 'apply_blur' is only supported on Windows");

    set_shadow(window, true).unwrap();
}

#[cfg(target_os = "windows")]
pub fn create_tray() -> SystemTray {
    use tauri::{CustomMenuItem, SystemTrayMenu};

    let mut quit = CustomMenuItem::new("quit".to_string(), "退出");
    // 设置菜单快捷键
    quit = quit.accelerator("Command+Q");
    let tray_menu = SystemTrayMenu::new().add_item(quit);
    return SystemTray::new().with_menu(tray_menu);
}

#[cfg(target_os = "macos")]
pub fn create_tray() -> SystemTray {
    return SystemTray::new();
}
