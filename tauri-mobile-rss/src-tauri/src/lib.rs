// Learn more about Tauri commands at https://tauri.app/v1/guides/features/command

use ::rss::Channel;

mod rss;

#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[tauri::command]
async fn request_rss(
    url: String,
    app: tauri::AppHandle,
    window: tauri::Window,
) -> Result<Channel, String> {
    let channel = rss::read_feed(&url).await;
    match channel {
        Ok(ch) => Ok(ch),
        Err(e) => Err(e.to_string()),
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_http::init())
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_sql::Builder::default().build())
        .invoke_handler(tauri::generate_handler![greet, request_rss])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
