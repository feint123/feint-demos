#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

pub mod monitor;
pub mod native;

use native::native_windows;
use tauri::{
    AppHandle, CustomMenuItem, Manager, SystemTray, SystemTrayEvent, SystemTrayMenu,
    SystemTrayMenuItem,
};

use crate::monitor::{battery_info, cpu_info, memory_info, process_info, system_info};

// Learn more about Tauri commands at https://tauri.app/v1/guides/features/command

fn main() {
    let mut quit = CustomMenuItem::new("quit".to_string(), "退出");

    // 设置菜单快捷键
    quit = quit.accelerator("Command+Q");
    // q_clipboard = q_clipboard.accelerator("CommandOrControl+SHIFT+V");
    // spotlight = spotlight.accelerator("Option+Space");
    let tray_menu = SystemTrayMenu::new()
        .add_native_item(SystemTrayMenuItem::Separator)
        .add_item(quit);

    let system_tray = SystemTray::new().with_menu(tray_menu);
    tauri::Builder::default()
        .setup(|app| {
            // 根据label获取窗口实例
            let window = app.get_window("main").unwrap();
            native_windows(&window, Some(10.), false);
            // window.open_devtools();
            Ok(())
        })
        .system_tray(system_tray)
        .on_system_tray_event(system_try_handler)
        .invoke_handler(tauri::generate_handler![
            system_info,
            battery_info,
            cpu_info,
            process_info,
            memory_info
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

/**
 * 处理系统托盘菜单项的点接事件
 */
fn system_try_handler(app: &AppHandle, event: SystemTrayEvent) {
    match event {
        SystemTrayEvent::LeftClick {
            position: pos,
            size: _,
            ..
        } => {
            let window = app.get_window("main").unwrap();
            window.set_position(pos).unwrap();
            #[cfg(target_os = "windows")]
            window.center().unwrap();
            window.show().unwrap();
            window.set_focus().unwrap();
        }
        SystemTrayEvent::RightClick {
            position: pos,
            size: _,
            ..
        } => {}

        SystemTrayEvent::MenuItemClick { id, .. } => {
            match id.as_str() {
                // 退出
                "quit" => {
                    // TODO: do something before exsits
                    std::process::exit(0);
                }
                _ => {

                }
            }
        }
        _ => {}
    }
}
