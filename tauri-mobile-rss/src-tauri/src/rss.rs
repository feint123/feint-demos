use std::error::Error;

use rss::Channel;
use serde::Serialize;
use serde_json::json;
use tauri::ipc::IpcResponse;
use tauri_plugin_http::reqwest;

pub async fn read_feed(url: &String) -> Result<Channel, Box<dyn Error>> {
    let content = reqwest::get(url.clone()).await?.bytes().await?;
    let channel = Channel::read_from(&content[..])?;
    Ok(channel)
}
