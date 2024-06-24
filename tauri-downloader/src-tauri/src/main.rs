// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

pub mod download;
pub mod native;

use std::{borrow::Borrow, cell::RefCell, collections::HashMap, sync::Arc};

use download::{download, stop_download};
use lazy_static::lazy_static;
use native::create_main_window;
use tauri::App;
use tokio::sync::{Mutex, RwLock};


// Learn more about Tauri commands at https://tauri.app/v1/guides/features/command
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}
#[tauri::command]
async fn download_file(
    url: String,
    file_path: String,
    work_id: String,
    app: tauri::AppHandle,
) -> Result<(), String> {
    let lock = get_lock(&work_id, &GLOBAL_MAP).await;
    let _guard = lock.lock().await; // 阻塞直到获得锁
    println!("{} get read lock", work_id);
    download(Some(url), Some(file_path), &work_id, app)
        .await
        .map_err(|err| err.to_string())?;

    Ok(())
}

// pub async fn put_if_not_present(work_id: &String) {
//     let counter_map = Arc::clone(&GLOBAL_MAP);
//     let mut map = counter_map.write().await;
//     if !map.contains_key(work_id) {
//         map.insert(work_id.clone(), Mutex::new(work_id.clone()));
//     }
// }
lazy_static! {
    static ref GLOBAL_MAP: WorkIdLockMap = Arc::new(RwLock::new(HashMap::new()));
    static ref PROCESS_MAP: WorkIdLockMap = Arc::new(RwLock::new(HashMap::new()));
}

type WorkIdLockMap = Arc<RwLock<HashMap<String, Arc<Mutex<()>>>>>;

pub async fn get_lock(work_id: &String, lock_map: &WorkIdLockMap) -> Arc<Mutex<()>> {
    let lock_arc = {
        let map_read_lock = lock_map.read().await;
        map_read_lock.get(work_id).cloned()
    };
    // 如果没有找到对应的Mutex，需要锁定lock_map来插入
    let lock = if let Some(lock) = lock_arc {
        lock // 直接使用已有的锁
    } else {
        let mut map_write_lock = lock_map.write().await;
        let new_lock = Arc::new(Mutex::new(()));
        map_write_lock.insert(work_id.clone(), new_lock.clone());
        new_lock // 使用新插入的锁
    };

    lock
}

#[tauri::command]
async fn download_file_by_id(work_id: String, app: tauri::AppHandle) -> Result<(), String> {
    let lock = get_lock(&work_id, &GLOBAL_MAP).await;
    let _guard = lock.lock().await; // 阻塞直到获得锁

    println!("{} get read lock", work_id);
    download(None, None, &work_id, app)
        .await
        .map_err(|err| err.to_string())?;
    Ok(())
}
#[tauri::command]
async fn stop_download_by_id(work_id: String, app: tauri::AppHandle) -> Result<(), String> {
    stop_download(&work_id, &app).await;
    Ok(())
}
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_clipboard_manager::init())
        .plugin(tauri_plugin_store::Builder::new().build())
        .plugin(tauri_plugin_fs::init())
        .setup(window_design)
        .plugin(tauri_plugin_http::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![
            greet,
            download_file,
            download_file_by_id,
            stop_download_by_id
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

fn window_design(app: &mut App) -> Result<(), Box<dyn std::error::Error>> {
    let _window = create_main_window(&app.handle());
    Ok(())
}
