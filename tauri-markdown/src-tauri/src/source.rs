use std::{fs::File, io::Write};

use log::{info, kv::source};
use serde::{Deserialize, Serialize};
use serde_json::to_string;
use tauri::AppHandle;
use uuid::Uuid;

use crate::{
    db::DB,
    search::{self, TOOLS_INDEX},
};

/**
 * {
    "name":"xxx",
    "description":"描述",
    "version": 1,
    "author":"发布者",
    "items":[{
        "title":"标题",
        "description":"简要描述，建议不要超过20个字",
        "converImageUrl":"封面图片链接",
        "previewImageUrl":["","",""],
        "targetUrl":"",
        "content":"",
        "author":"xxx",
        "type":"app/web",
        "categorys":["",""]
    }]
}


 */
#[derive(Debug, Serialize, Deserialize)]
pub struct ToolsSource {
    #[serde(skip_deserializing)]
    pub id: i32,
    #[serde(skip_deserializing)]
    pub source_id: String,
    pub name: String,
    pub description: String,
    pub version: i32,
    pub author: String,
    pub url: String,
    #[serde(skip_deserializing)]
    pub source_type: i32,
    #[serde(skip_deserializing)]
    pub last_sync: String,
    pub items: Vec<ToolsSourceItem>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ToolsSourceExport {
    pub name: String,
    pub description: String,
    pub version: i32,
    pub author: String,
    pub url: String,
    pub items: Vec<ToolsSourceItem>,
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ToolsSourceItem {
    #[serde(skip_deserializing)]
    pub id: i32,
    pub title: String,
    pub description: String,
    pub cover_image_url: String,
    pub preview_image_url: Vec<String>,
    pub target_url: String,
    pub content: String,
    pub author: String,
    pub tool_type: String,
    pub categorys: Vec<String>,
    #[serde(skip_deserializing)]
    pub tools_source_id: String,
    #[serde(skip_deserializing)]
    pub source_name: String,
}

pub fn parse_source(source: &str) -> Result<ToolsSource, String> {
    let result =
        serde_json::from_str(source).map_err(|err| format!("parse json: {}", err.to_string()))?;
    Ok(result)
}
pub fn save_source(tools_source: &ToolsSource, handle: &AppHandle) -> Result<(), String> {
    let db = DB.lock().map_err(|err| err.to_string())?;
    // 添加源
    db.add_source(&tools_source, &handle)?;
    let source_item_len = tools_source.items.len();
    info!("save source: {source_item_len} ");
    // 添加工具列表
    for ele in &tools_source.items {
        db.add_source_item(&tools_source, &ele, handle)?;
    }
    let tools = db.get_source_items(tools_source.source_id.clone(), handle)?;
    let tools_index = TOOLS_INDEX.lock().map_err(|err| err.to_string())?;
    tools_index.update_index(&tools)?;
    Ok(())
}

pub fn delete_source(source_ids: Vec<String>, handle: &AppHandle) -> Result<(), String> {
    let db = DB.lock().map_err(|err| err.to_string())?;
    db.delete_source(&source_ids, &handle)?;
    let tools_index = TOOLS_INDEX.lock().map_err(|err| err.to_string())?;
    for source_id in source_ids {
        db.delete_item(&source_id, &handle)?;
        tools_index.delete_by_source_id(&source_id)?;
    }
    Ok(())
}

pub fn query_all(handle: &AppHandle) -> Result<Vec<ToolsSource>, String> {
    let db = DB.lock().map_err(|err| err.to_string())?;
    return db.get_all_source(&handle);
}

pub fn query_items(id: String, handle: &AppHandle) -> Result<Vec<ToolsSourceItem>, String> {
    let db = DB.lock().map_err(|err| err.to_string())?;
    return db.get_source_items(id, &handle);
}

pub fn query_items_by_id(item_id: i32, handle: &AppHandle) -> Result<Vec<ToolsSourceItem>, String> {
    let db = DB.lock().map_err(|err| err.to_string())?;
    return db.get_source_item_by_id(item_id, &handle);
}

pub fn query_items_by_type(
    tool_type: String,
    handle: &AppHandle,
) -> Result<Vec<ToolsSourceItem>, String> {
    let db = DB.lock().map_err(|err| err.to_string())?;
    return db.get_source_items_by_type(tool_type, &handle);
}

pub fn save_local_tool_item(item: &ToolsSourceItem, handle: &AppHandle) -> Result<i32, String> {
    // 查询source表，是否有本地的source, url = localhost
    let db = DB.lock().map_err(|err| err.to_string())?;
    let mut source = db.get_source_by_url("localhost".to_string(), handle)?;
    let source_id = Uuid::new_v4().to_string();
    if source.is_empty() {
        db.add_source(
            &ToolsSource {
                id: 0,
                source_id: source_id.clone(),
                name: "本地工具".to_string(),
                description: "本地工具".to_string(),
                version: 1,
                author: "你".to_string(),
                url: "localhost".to_string(),
                source_type: 1,
                last_sync: "".to_string(),
                items: vec![],
            },
            handle,
        )?;
        source = db.get_source_by_url("localhost".to_string(), handle)?;
    }
    // 如果没有，则插入一条数据
    db.add_source_item(&source[0], item, handle)?;

    // 插入tool—item 数据，结束
    let result_list = db.get_source_item_by_url(
        item.target_url.clone(),
        source[0].source_id.clone(),
        &handle,
    )?;
    let result_str = serde_json::to_string(&result_list);
    info!("search result: {:?}", result_str);
    if result_list.len() > 0 {
        let tools_index = TOOLS_INDEX.lock().map_err(|err| err.to_string())?;
        tools_index.update_index(&result_list)?;
        Ok(result_list[0].id)
    } else {
        Ok(0)
    }
}

pub fn search_tool_items(keywords: String, handle: &AppHandle) -> Result<Vec<String>, String> {
    let tools_index = TOOLS_INDEX.lock().map_err(|err| err.to_string())?;
    return tools_index.search(keywords);
}

pub fn export_source(
    tools_list: Vec<i32>,
    out_path: String,
    handle: &AppHandle,
) -> Result<(), String> {
    // 查询所有的tools数据
    let db = DB.lock().map_err(|err| err.to_string())?;
    let mut tools = vec![];
    for ele in tools_list {
        let tool = db.get_source_item_by_id(ele, handle)?;
        let first_tool = tool[0].clone();
        tools.push(first_tool);
    }
    // 构建source对象
    let source = ToolsSourceExport {
        name: "导出工具".to_string(),
        description: "导出工具".to_string(),
        version: 1,
        author: "你的昵称".to_string(),
        url: "".to_string(),
        items: tools,
    };

    // 转换成json字符串
    let export_json = serde_json::to_string(&source).map_err(|err| err.to_string())?;
    // 写入out_path 路径的文件。
    let mut file = File::create(format!("{}/{}", out_path, "tools-export.json"))
        .map_err(|err| err.to_string())?;
    file.write_all(export_json.as_bytes())
        .map_err(|err| err.to_string())?;
    Ok(())
}

pub(crate) fn delete_source_item_by_id(item_id: i32, handle: &AppHandle) -> Result<(), String> {
    let db = DB.lock().map_err(|err| err.to_string())?;
    db.delete_source_item_by_id(item_id, handle)?;
    Ok(())
}
