use core::fmt;
use std::{any::Any, ops::RangeInclusive, path::PathBuf};

use serde::{Deserialize, Serialize};
use serde_json::json;
use tauri::{http::HeaderMap, AppHandle, Manager, Url, Wry};
use tauri_plugin_http::reqwest::{self, get, Client};
use tauri_plugin_store::{with_store, StoreCollection};
use tokio::{fs::{File, OpenOptions}, io::AsyncWriteExt, sync::Mutex};
use uuid::Uuid;

use crate::{get_lock, PROCESS_MAP};
const CHUNK_SIZE: u64 = 1024 * 1024;
pub async fn download(
    url: Option<String>,
    file_path: Option<String>,
    work_id: &String,
    app: tauri::AppHandle,
) -> Result<(), DownloaderError> {
    if url.is_none() {
        download_file_in_chunks_by_id(&work_id, CHUNK_SIZE, &app).await?;
    } else {
        download_file_in_chunks(
            &work_id,
            &url.unwrap(),
            file_path.unwrap(),
            CHUNK_SIZE,
            &app,
        )
        .await?;
    }
    Ok(())
}


pub async fn stop_download(work_id: &String, handle: &AppHandle) {
    update_work_state(handle, work_id, WorkState::Stoped).await;
}

async fn download_segment(
    client: &Client,
    url: &String,
    range: RangeInclusive<u64>,
) -> Result<Vec<u8>, DownloaderError> {
    let mut headers = reqwest::header::HeaderMap::new();
    headers.insert(
        reqwest::header::RANGE,
        format!("bytes={}-{}", range.start(), range.end())
            .parse()
            .unwrap(),
    );

    let response = client
        .get(url)
        .headers(headers)
        .send()
        .await
        .expect("get resource failed");

    Ok(response.bytes().await.unwrap().to_vec())
    // sleep(Duration::from_secs(1));
    // Ok("hello world".as_bytes().to_vec())
}

fn get_work_info(work_id: &String, handle: &tauri::AppHandle) -> Option<WorkInfo> {
    let stores = handle.state::<StoreCollection<Wry>>();
    let path = PathBuf::from("store.bin");
    return with_store(handle.clone(), stores, path, |store| {
        let binding = json!([]);
        let works_json = store.get("works").unwrap_or(&binding);
        let mut works: Vec<WorkInfo> = serde_json::from_value(works_json.clone()).unwrap_or(vec![]);
        println!("works size: {}, work_id: {}", works.len(), work_id);
        for (_, ele) in works.iter_mut().enumerate() {
            if ele.work_id == *work_id {
                return Ok(Some(ele.clone()));
            }
        }
        Ok(None)
    })
    .unwrap();
}

fn get_state(work_id: &String, handle: &tauri::AppHandle) -> String {
    let stores = handle.state::<StoreCollection<Wry>>();
    let path = PathBuf::from("store.bin");
    return with_store(handle.clone(), stores, path, |store| {
        let binding = json!({"state": WorkState::Failed.to_string()});
        let state_json = store.get("state_".to_string() + work_id.clone().as_str())
        .unwrap_or(&binding);

        if let Some(state) = state_json.get("state") {
            return Ok(state.as_str().unwrap().to_string());
        } else {
            return Ok(WorkState::Failed.to_string())
        }
    })
    .unwrap();
}

fn get_chunk(work_id: &String, handle: &tauri::AppHandle) -> Option<u64> {
    let stores = handle.state::<StoreCollection<Wry>>();
    let path = PathBuf::from("store.bin");
    return with_store(handle.clone(), stores, path, |store| {
        let binding = json!({"chunk": WorkState::Failed.to_string()});
        let state_json = store.get("chunk_".to_string() + work_id.clone().as_str())
        .unwrap_or(&binding);

        if let Some(chunk) = state_json.get("chunk") {
            return Ok(chunk.as_u64());
        } else {
            return Ok(None)
        }
    })
    .unwrap();
}
 /**
 * 根据work_id下载文件
 */
async fn download_file_in_chunks_by_id(
    work_id: &String,
    chunk_size: u64,
    handle: &tauri::AppHandle,
) -> Result<(), DownloaderError> {
    
    let info = get_work_info(&work_id, &handle);
    let chunk = get_chunk(&work_id, &handle);
    if info.is_some() {
        let client = Client::new();
        let ele = info.unwrap();
        update_work_state(&handle, &work_id, WorkState::Processing).await;
        let index = chunk.unwrap_or(0);
        // 以追加方式打开文件
        let mut file = OpenOptions::new()
            .write(true)
            .create(true)
            .append(true)
            .open(ele.file_path)
            .await
            .expect("open file failed");
        for chunk_index in index..((ele.file_size + chunk_size - 1) / chunk_size) {
            
            if WorkState::Processing.to_string() != get_state(&work_id, handle) {
                return Ok(());
            }

            let start_byte = chunk_index * chunk_size;
            let end_byte = std::cmp::min(start_byte + chunk_size - 1, ele.file_size - 1);
            let range = start_byte..=end_byte;
            println!("downloading {} - {}", range.start(), range.end());
            let segment_data = download_segment(&client, &ele.url, range).await?;
            match file.write_all(&segment_data).await {
                Ok(_) => {
                    update_work_process(
                        &handle,
                        &work_id,
                        (start_byte as f64 * 100.0 / ele.file_size as f64).round(),
                        chunk_index + 1,
                    ).await;
                }
                Err(e) => {
                    println!("Error writing to file: {}", e);
                    return Err(DownloaderError::Io(e));
                }
            }
        }
        // 更新状态为已完成
        update_work_state(&handle, &work_id, WorkState::Finished).await;
    }

    Ok(())
}
/**
 * 根据url下载文件
 */
async fn download_file_in_chunks(
    work_id: &String,
    url: &String,
    file_path: String,
    chunk_size: u64,
    app: &tauri::AppHandle,
) -> Result<(), DownloaderError> {
    println!("download_file_in_chunks： {}", url);

    let client = Client::new();
    let result = client.head(url).send().await.expect("get head info failed");
    for ele in result.headers().iter() {
        println!("{}-{}", ele.0, ele.1.to_str().unwrap());
    }
    // 获取文件大小
    let total_size = result
        .headers()
        .get("content-length")
        .unwrap()
        .to_str()
        .unwrap_or("0")
        .parse()
        .unwrap_or(0);
    // let total_size = 1024 * 1024 * 25;
    let file_name: String = get_file_name(&result.headers(), &url);
    let mut fomated_url = url.clone();
    if url.split("~~").count() == 2 {
        fomated_url = url.split("~~").nth(0).unwrap_or("").to_string();
    }
    let complete_path = file_path + "/" + file_name.as_str();
    let mut file = File::create(&complete_path).await.unwrap();
    let work_info = save_work_info(
        &app,
        WorkInfo::new(fomated_url.clone(), complete_path, total_size, work_id.clone(), file_name),
    ).await;
    // 更新状态为处理中
    update_work_state(&app, &work_info.work_id, WorkState::Processing).await;
    for chunk_index in 0..((total_size + chunk_size - 1) / chunk_size) {
        if !WorkState::Processing.to_string().eq(&get_state(&work_info.work_id, app)) {
            return Ok(());
        }
        let start_byte = chunk_index * chunk_size;
        let end_byte = std::cmp::min(start_byte + chunk_size - 1, total_size - 1);
        let range = start_byte..=end_byte;
        println!("downloading {} - {}", range.start(), range.end());
        let segment_data = download_segment(&client, url, range).await?;
        match file.write_all(&segment_data).await {
            Ok(_) => {
                update_work_process(
                    &app,
                    &work_info.work_id,
                    (start_byte as f64 * 100.0 / total_size as f64).round(),
                    chunk_index + 1,
                ).await;
            }
            Err(e) => {
                println!("Error writing to file: {}", e);
                return Err(DownloaderError::Io(e));
            }
        }
    }
    // 更新状态为已完成
    update_work_state(&app, &work_info.work_id, WorkState::Finished).await;
    println!("download finished");
    Ok(())
}

fn get_file_name(headers: &HeaderMap, url: &String) -> String {
    let mut file_name: String = "temp_".to_string() + Uuid::new_v4().to_string().as_str();
    if url.split("~~").count() == 2 {
        return url.split("~~").nth(1).unwrap_or(&file_name.as_str()).to_string();
    }
    match Url::parse(url) {
        Ok(url) => {
            // 获取路径部分
            let path = url.path();
            if let Some(file_name_from_url) = path.rsplit('/').next() {
                if file_name_from_url.len() > 0 {
                    file_name = file_name_from_url.to_string()
                }
            } else {
                println!("无法从URL中提取文件名");
            }
        }
        Err(e) => println!("Parse url error {}", e.to_string()),
    }

    if let Some(content_disposition) = headers.get(reqwest::header::CONTENT_DISPOSITION) {
        // 解析Content-Disposition头部以获取filename
        if let Ok(cd) = content_disposition.to_str() {
            if let Some(filename) = cd.split('=').nth(1) {
                // 移除可能的引号并解码
                file_name = filename
                    .trim_matches(|c: char| c == '"' || c == '\'')
                    .to_string();
            }
        }
    }

    file_name
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct WorkInfo {
    url: String,
    file_path: String,
    file_size: u64,
    work_id: String,
    file_name: String,
    state: String,
    process: f64,
    chunk_index: u64,
}

#[derive(Debug, Serialize, Deserialize)]
enum WorkState {
    Init,
    Queeued,
    Finished,
    Failed,
    Stoped,
    Processing,
}

impl WorkState {
    fn to_string(&self) -> String {
        match self {
            WorkState::Init => "Init".to_string(),
            WorkState::Queeued => "Queeued".to_string(),
            WorkState::Finished => "Finished".to_string(),
            WorkState::Failed => "Failed".to_string(),
            WorkState::Processing => "Processing".to_string(),
            WorkState::Stoped => "Stopped".to_string(),
        }
    }
}

impl WorkInfo {
    fn new(
        url: String,
        file_path: String,
        file_size: u64,
        work_id: String,
        file_name: String,
    ) -> Self {
        Self {
            url,
            file_path,
            file_size,
            work_id,
            file_name,
            state: WorkState::Init.to_string(),
            process: 0.0,
            chunk_index: 0,
        }
    }
}
/**
 * 保存任务信息
 */
async fn save_work_info(handle: &AppHandle, info: WorkInfo) -> WorkInfo {
    let stores = handle.state::<StoreCollection<Wry>>();
    let path = PathBuf::from("store.bin");
    with_store(handle.clone(), stores, path, |store| {
        let binding = json!([]);
        let works_json = store.get("works").unwrap_or(&binding);
        let mut works: Vec<WorkInfo> = serde_json::from_value(works_json.clone()).unwrap_or(vec![]);
        works.push(info.clone());
        store
            .insert("works".to_string(), json!(works))
            .expect("Insert works failed");
        // 状态
        store
            .insert(
                "state_".to_string() + info.work_id.clone().as_str(),
                json!({"state":info.state.to_string()}),
            )
            .expect("Insert state failed");
        // 进度
        store
            .insert(
                "process_".to_string() + info.work_id.clone().as_str(),
                json!({"process":info.process}),
            )
            .expect("Insert process failed");
        // chunk
        store
        .insert(
            "chunk_".to_string() + info.work_id.clone().as_str(),
            json!({"chunk":info.chunk_index}),
        )
        .expect("Insert chunk failed");
        Ok(())
    })
    .expect("Save work info failed");
    return info;
}

/**
 * 更新状态
 */
async fn update_work_state(handle: &AppHandle, work_id: &String, state: WorkState) {
    let lock = get_lock(work_id, &PROCESS_MAP).await;
    let _guard = lock.lock().await;
    let stores = handle.state::<StoreCollection<Wry>>();
    let path = PathBuf::from("store.bin");
    with_store(handle.clone(), stores, path, |store| {
        store
            .insert(
                "state_".to_string() + work_id.clone().as_str(),
                json!({"state":state.to_string()}),
            )
            .expect("Insert state failed");
        Ok(())
    })
    .expect("Update work state failed");
}

// async fn process_lock(work_id: &String) {
//     let mut map = PROCESS_MAP.lock().await;
//     if !map.contains_key(work_id) {
//         map.insert(work_id.clone(), Mutex::new(work_id.clone()));
//     }
//     let _ = map.get(work_id).unwrap().lock().await;
// }
/**
 * 更新进度
 */
async fn update_work_process(handle: &AppHandle, work_id: &String, progress: f64, chunk_index: u64) {
    let lock = get_lock(work_id, &PROCESS_MAP).await;
    let _guard = lock.lock().await;
    let stores = handle.state::<StoreCollection<Wry>>();
    let path = PathBuf::from("store.bin");
    with_store(handle.clone(), stores, path, |store| {
        store
            .insert(
                "process_".to_string() + work_id.clone().as_str(),
                json!({"process":progress}),
            )
            .expect("Insert process failed");
        store
            .insert(
                "chunk_".to_string() + work_id.clone().as_str(),
                json!({"chunk":chunk_index}),
            )
            .expect("Insert chunk failed");
        Ok(())
    })
    .expect("Update work process failed");
}

#[derive(Debug)]
pub enum DownloaderError {
    Io(std::io::Error),
    Request(reqwest::Error),
    ParseUrl(String),
}

impl fmt::Display for DownloaderError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            DownloaderError::Io(e) => write!(f, "IO error: {}", e),
            DownloaderError::Request(e) => write!(f, "Request error: {}", e),
            DownloaderError::ParseUrl(e) => write!(f, "URL parse error: {}", e),
        }
    }
}

impl std::error::Error for DownloaderError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            DownloaderError::Io(e) => Some(e),
            DownloaderError::Request(e) => Some(e),
            DownloaderError::ParseUrl(e) => None,
        }
    }
}
