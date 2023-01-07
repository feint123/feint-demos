#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use std::{fs, path::Path, rc::Rc};

use mouse_position::mouse_position::Mouse;
use tauri::{
    AppHandle, CustomMenuItem, Manager, SystemTray, SystemTrayEvent, SystemTrayMenu,
    SystemTrayMenuItem,
};
use tauri_plugin_sql::TauriSql;
use window_vibrancy::{apply_vibrancy, NSVisualEffectMaterial};

#[derive(serde::Serialize, Default)]
struct ClipboardData {
    clip_type: i8,
    text_content: String,
    file_path: String,
    content_md5: String,
}

impl ClipboardData {
    fn new(clip_type: i8, text_content: String, file_path: String, content_md5: String) -> Self {
        Self {
            clip_type,
            text_content,
            file_path,
            content_md5,
        }
    }
}
/**
 * 读取剪切板
 */
#[tauri::command]
fn read_clipboard(
    app_handle: tauri::AppHandle,
    current_md5: String,
) -> Result<ClipboardData, String> {
    let mut clipboard = clippers::Clipboard::get();
    match clipboard.read() {
        // 普通文本
        Some(clippers::ClipperData::Text(text)) => {
            let text = Rc::new(text);
            return Ok(ClipboardData::new(
                1,
                text.clone().to_string(),
                "".to_string(),
                format!("{:x}", md5::compute(text.clone().to_string().as_bytes())),
            ));
        }
        // 图片
        Some(clippers::ClipperData::Image(image)) => {
            let row_data = image.as_raw().rgba();
            let file_md5 = md5::compute(row_data);
            if format!("{:x}", file_md5).to_string().eq(&current_md5) {
                return Ok(ClipboardData::default());
            }
            let mut cache_dir = app_handle.path_resolver().app_cache_dir().unwrap();
            if !cache_dir.exists() {
                fs::create_dir(cache_dir.clone()).unwrap();
            }
            cache_dir = cache_dir.join("imgs");
            if !cache_dir.exists() {
                fs::create_dir(cache_dir.clone()).unwrap();
            }
            let path_str = format!("{}/{:x}.png", cache_dir.to_str().unwrap(), file_md5);
            let img_temp_path = Path::new(path_str.as_str());
            if !img_temp_path.exists() {
                image.save(img_temp_path).unwrap();
            }
            return Ok(ClipboardData::new(
                2,
                "".to_string(),
                path_str,
                format!("{:x}", file_md5),
            ));
        }
        _ => {
            return Err("unsupported".to_string());
        }
    }
}
/**
 * 写入剪切板
 */
#[tauri::command]
fn write_clipboard(content: String, clip_type: i8) -> Result<(), String> {
    let mut clipboard = clippers::Clipboard::get();
    match clip_type {
        // 写入文字
        1 => {
            clipboard.write_text(content.clone()).unwrap();
        }
        // 写入图片
        2 => {
            use image::io::Reader as ImageReader;
            let image = ImageReader::open(Path::new(content.as_str()))
                .unwrap()
                .decode()
                .unwrap();
            clipboard
                .write_image(image.width(), image.height(), image.as_bytes())
                .unwrap();
        }
        _ => {}
    }

    Ok(())
}

#[derive(serde::Serialize, Default)]
struct MousePosition {
    x: i32,
    y: i32,
}

impl MousePosition {
    fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }
}
// 全局获取当前的鼠标坐标
#[tauri::command]
fn mouse_position() -> Result<MousePosition, String> {
    let position = Mouse::get_mouse_position();
    match position {
        Mouse::Position { x, y } => return Ok(MousePosition::new(x, y)),
        Mouse::Error => Err("Cannot find mouse position".to_string()),
    }
}

fn main() {
    // 定义系统托盘
    let open_main = CustomMenuItem::new("open_main".to_string(), "打开主界面");
    let mut quit = CustomMenuItem::new("quit".to_string(), "退出");
    let mut q_clipboard = CustomMenuItem::new("clipboard".to_string(), "快捷剪切板");
    // 设置菜单快捷键
    quit = quit.accelerator("Command+Q");
    q_clipboard = q_clipboard.accelerator("CommandOrControl+SHIFT+V");
    let tray_menu = SystemTrayMenu::new()
        .add_item(open_main)
        .add_item(q_clipboard)
        .add_native_item(SystemTrayMenuItem::Separator)
        .add_item(quit);

    let system_tray = SystemTray::new().with_menu(tray_menu);

    tauri::Builder::default()
        .setup(|app| {
            // 根据label获取窗口实例
            let window = app.get_window("main").unwrap();
            let qcb_window = app.get_window("qcb").unwrap();
            // 设置窗口模糊特效
            #[cfg(target_os = "macos")]
            apply_vibrancy(&window, NSVisualEffectMaterial::Sidebar, None, None)
                .expect("Unsupported platform! 'apply_vibrancy' is only supported on macOS");
            // 设置窗口模糊特效
            #[cfg(target_os = "macos")]
            apply_vibrancy(
                &qcb_window,
                NSVisualEffectMaterial::ContentBackground,
                None,
                None,
            )
            .expect("Unsupported platform! 'apply_vibrancy' is only supported on macOS");
            // 快捷剪切板窗口默认隐藏
            qcb_window.hide().unwrap();
            Ok(())
        })
        .plugin(TauriSql::default())
        .system_tray(system_tray)
        .on_system_tray_event(system_try_handler)
        .invoke_handler(tauri::generate_handler![
            read_clipboard,
            write_clipboard,
            mouse_position
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

/**
 * 处理系统托盘菜单项的点接事件
 */
fn system_try_handler(app: &AppHandle, event: SystemTrayEvent) {
    match event {
        SystemTrayEvent::MenuItemClick { id, .. } => {
            match id.as_str() {
                // 退出
                "quit" => {
                    // TODO: do something before exsits
                    std::process::exit(0);
                }
                // 快捷剪切板
                "clipboard" => {
                    let window = app.get_window("qcb").unwrap();
                    window.show().unwrap();
                    window.set_focus().unwrap();
                }
                "open_main" => {
                    let window = app.get_window("main").unwrap();
                    window.show().unwrap();
                    window.set_focus().unwrap();
                }
                _ => {}
            }
        }
        _ => {}
    }
}
