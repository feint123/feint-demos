use std::{
    fs,
    path::PathBuf,
    sync::{atomic::AtomicBool, Arc, Mutex},
    time,
};

use crate::source::{ToolsSource, ToolsSourceItem};
use lazy_static::lazy_static;
use log::info;
use rusqlite::{Connection, Row};
use tauri::{AppHandle, Manager};

#[derive(Debug)]
pub struct DbManager {
    pub name: String,
    pub connection: Connection,
}
#[derive(Default)]
pub struct SqlState(pub AtomicBool);

unsafe impl Sync for DbManager {}

lazy_static! {
    pub static ref DB: Arc<Mutex<DbManager>> = Arc::new(Mutex::new(DbManager::default()));
}

impl Default for DbManager {
    fn default() -> Self {
        let connect = Connection::open_in_memory()
            .map_err(|err| err.to_string())
            .unwrap();

        Self {
            name: Default::default(),
            connection: connect,
        }
    }
}

pub fn init_db_conn(handle: &AppHandle) -> Result<(), String> {
    let mut db_manager = DB.lock().map_err(|err| err.to_string())?;
    let mut app_data_dir = handle
        .path()
        .app_data_dir()
        .map_err(|err| err.to_string())?;
    if !app_data_dir.exists() {
        fs::create_dir(&app_data_dir).map_err(|err| err.to_string())?;
    }
    let app_data_dir_string = app_data_dir.as_mut_os_string();
    app_data_dir_string.push("/db");
    let index_path_str = app_data_dir_string.to_str().unwrap();
    let mut index_path = PathBuf::from(index_path_str);
    if !index_path.exists() {
        info!("try create index file");
        fs::create_dir(&index_path).map_err(|err| err.to_string())?;
    }
    info!("create index dir success");
    let sql_data_file_string = index_path.as_mut_os_string();
    sql_data_file_string.push("/index.db");
    let sql_data_file_str = sql_data_file_string.to_str().unwrap();
    let sql_data_file_path = PathBuf::from(sql_data_file_str);
    if !sql_data_file_path.exists() {
        fs::File::create_new(sql_data_file_path.as_path()).map_err(|err| err.to_string())?;
    }
    info!("create index file success");
    db_manager.connection = Connection::open(&index_path)
        .map_err(|err| err.to_string())
        .unwrap();
    Ok(())
}

impl DbManager {
    fn init(self: &Self, handler: &AppHandle) -> Result<(), String> {
        let state = handler.state::<SqlState>();
        if !state.0.load(std::sync::atomic::Ordering::Relaxed) {
            for sql in vec![
                "CREATE TABLE IF NOT EXISTS tools_source (
                id INTEGER PRIMARY KEY,
                source_id TEXT NOT NULL,
                name TEXT NOT NULL,
                description TEXT,
                version INTEGER NOT NULL,
                author TEXT,
                url TEXT UNIQUE,
                source_type INTEGER NOT NULL,
                last_sync TEXT
                );",
                "CREATE TABLE IF NOT EXISTS tools_source_item (
                id INTEGER PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT,
                cover_image_url TEXT,
                preview_image_url TEXT,
                target_url TEXT,
                content TEXT,
                author TEXT,
                tool_type TEXT,
                categorys TEXT,
                tools_source_id TEXT NOT NULL,
                source_name TEXT,
                UNIQUE(target_url, tools_source_id)
                );",
            ] {
                self.connection
                    .execute(&sql, ())
                    .map_err(|err| err.to_string())?;
            }
            state
                .0
                .fetch_and(true, std::sync::atomic::Ordering::Relaxed);
        }
        Ok(())
    }

    pub fn add_source(self: &Self, ts: &ToolsSource, handler: &AppHandle) -> Result<(), String> {
        self.init(&handler)?;
        self.connection.execute(
            "INSERT OR REPLACE INTO tools_source (source_id, name, description, version, author, url, source_type, last_sync) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)",
            (&ts.source_id, &ts.name, &ts.description, &ts.version, &ts.author, &ts.url, &ts.source_type,
                 &time::SystemTime::now().duration_since(time::UNIX_EPOCH).unwrap().as_millis().to_string()),
        ).map_err(|err| err.to_string())?;
        Ok(())
    }

    pub fn add_source_item(
        self: &Self,
        ts: &ToolsSource,
        item: &ToolsSourceItem,
        handle: &AppHandle,
    ) -> Result<(), String> {
        self.init(&handle)?;
        self.connection.execute(
            "INSERT OR REPLACE INTO tools_source_item (title, description, cover_image_url, preview_image_url, target_url, content, author, tool_type, categorys, tools_source_id, source_name) VALUES (?1, ?2,?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11)",
            (&item.title, &item.description, &item.cover_image_url, &item.preview_image_url.join("&"), 
            &item.target_url, &item.content, &item.author, &item.tool_type, &item.categorys.join(","), &ts.source_id, &ts.name),
        ).map_err(|err| err.to_string())?;
        Ok(())
    }

    pub fn delete_source(
        self: &Self,
        source_ids: &Vec<String>,
        handler: &AppHandle,
    ) -> Result<(), String> {
        self.init(&handler)?;
        let mut prepare = self
            .connection
            .prepare("DELETE FROM tools_source WHERE source_id IN (?1)")
            .map_err(|err| err.to_string())?;
        for ele in source_ids {
            prepare.execute((ele,)).map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    pub fn delete_item(self: &Self, source_id: &String, handler: &AppHandle) -> Result<(), String> {
        self.init(&handler)?;
        let mut prepare = self
            .connection
            .prepare("DELETE FROM tools_source_item WHERE tools_source_id = ?1")
            .map_err(|err| err.to_string())?;

        prepare
            .execute((source_id,))
            .map_err(|err| err.to_string())?;

        Ok(())
    }

    pub fn deal_source_row(row: &Row) -> rusqlite::Result<ToolsSourceItem> {
        Ok(ToolsSourceItem {
            id: row.get(0)?,
            title: row.get(1)?,
            description: row.get(2)?,
            cover_image_url: row.get(3)?,
            preview_image_url: (row.get::<_, String>(4)?)
                .split("&")
                .map(|s| s.to_string())
                .collect(),
            target_url: row.get(5)?,
            content: row.get(6)?,
            author: row.get(7)?,
            tool_type: row.get(8)?,
            categorys: (row.get::<_, String>(9)?)
                .split(",")
                .map(|s| s.to_string())
                .collect(),
            tools_source_id: row.get(10)?,
            source_name: row.get(11)?,
        })
    }

    pub fn get_source_item_by_id(
        self: &Self,
        item_id: i32,
        handler: &AppHandle,
    ) -> Result<Vec<ToolsSourceItem>, String> {
        self.init(&handler)?;
        let mut prepare = self
            .connection
            .prepare("SELECT * FROM tools_source_item WHERE id = ?1")
            .map_err(|err| err.to_string())?;

        let rows = prepare
            .query_map((item_id,), Self::deal_source_row)
            .map_err(|err| err.to_string())?;

        let mut sources = vec![];
        for source in rows {
            if source.is_ok() {
                let source = source.unwrap();
                sources.push(source);
            } else {
                let err = source.unwrap_err();
                info!("item error {err}")
            }
        }
        Ok(sources)
    }

    pub fn delete_source_item_by_id(
        self: &Self,
        item_id: i32,
        handler: &AppHandle,
    ) -> Result<(), String> {
        self.init(&handler)?;
        let mut prepare = self
            .connection
            .prepare("DELETE FROM tools_source_item WHERE id = ?1")
            .map_err(|err| err.to_string())?;

        prepare.execute((item_id,)).map_err(|err| err.to_string())?;

        Ok(())
    }

    pub fn get_source_item_by_url(
        self: &Self,
        target_url: String,
        source_id: String,
        handler: &AppHandle,
    ) -> Result<Vec<ToolsSourceItem>, String> {
        self.init(&handler)?;
        let mut prepare = self
            .connection
            .prepare(
                "SELECT * FROM tools_source_item WHERE target_url = ?1 AND tools_source_id = ?2",
            )
            .map_err(|err| err.to_string())?;
        info!("get_source_item_by_url {target_url} {source_id}");
        let rows = prepare
            .query_map((target_url, source_id), Self::deal_source_row)
            .map_err(|err| err.to_string())?;

        let mut sources = vec![];
        for source in rows {
            if source.is_ok() {
                let source = source.unwrap();
                sources.push(source);
            } else {
                let err = source.unwrap_err();
                info!("item error {err}")
            }
        }
        Ok(sources)
    }

    pub fn get_source_items_by_type(
        self: &Self,
        tool_type: String,
        handler: &AppHandle,
    ) -> Result<Vec<ToolsSourceItem>, String> {
        self.init(&handler)?;
        let mut prepare = self
            .connection
            .prepare("SELECT * FROM tools_source_item Where tool_type = ?")
            .map_err(|err| err.to_string())?;

        let rows = prepare
            .query_map((tool_type,), Self::deal_source_row)
            .map_err(|err| err.to_string())?;

        let mut sources = vec![];
        for source in rows {
            if source.is_ok() {
                let source = source.unwrap();
                sources.push(source);
            } else {
                let err = source.unwrap_err();
                info!("item error {err}")
            }
        }
        Ok(sources)
    }

    pub fn get_source_items(
        self: &Self,
        id: String,
        handler: &AppHandle,
    ) -> Result<Vec<ToolsSourceItem>, String> {
        info!("query id is {id}");
        self.init(&handler)?;
        let mut sql_template = "SELECT * FROM tools_source_item Where tools_source_id = ?";
        if id.len() == 0 {
            sql_template = "SELECT * FROM tools_source_item ORDER BY id DESC";
        }
        info!("sql template is {sql_template}");
        let mut prepare = self
            .connection
            .prepare(&sql_template)
            .map_err(|err| err.to_string())?;

        let rows;
        if id.len() == 0 {
            rows = prepare
                .query_map([], Self::deal_source_row)
                .map_err(|err| err.to_string())?;
        } else {
            rows = prepare
                .query_map((id,), Self::deal_source_row)
                .map_err(|err| err.to_string())?;
        }
        let mut sources = vec![];
        for source in rows {
            if source.is_ok() {
                let source = source.unwrap();
                sources.push(source);
            } else {
                let err = source.unwrap_err();
                info!("item error {err}")
            }
        }
        Ok(sources)
    }

    pub fn deal_tools_row(row: &Row) -> rusqlite::Result<ToolsSource> {
        Ok(ToolsSource {
            id: row.get(0)?,
            source_id: row.get(1)?,
            name: row.get(2)?,
            description: row.get(3)?,
            version: row.get(4)?,
            author: row.get(5)?,
            url: row.get(6)?,
            source_type: row.get(7)?,
            last_sync: row.get(8)?,
            items: vec![],
        })
    }

    pub fn get_all_source(self: &Self, handle: &AppHandle) -> Result<Vec<ToolsSource>, String> {
        self.init(&handle)?;
        let mut stmt = self
            .connection
            .prepare("SELECT * FROM tools_source")
            .map_err(|err| err.to_string())?;
        let rows = stmt
            .query_map([], Self::deal_tools_row)
            .map_err(|err| err.to_string())?;
        let mut sources = vec![];

        for source in rows {
            if source.is_ok() {
                let source = source.unwrap();
                sources.push(source);
            } else {
                let err = source.unwrap_err();
                info!("source error {err}")
            }
        }

        Ok(sources)
    }

    pub fn get_source_by_url(
        self: &Self,
        url: String,
        handle: &AppHandle,
    ) -> Result<Vec<ToolsSource>, String> {
        self.init(&handle)?;
        let mut stmt = self
            .connection
            .prepare("SELECT * FROM tools_source where url = ?")
            .map_err(|err| err.to_string())?;
        let rows = stmt
            .query_map((&url,), Self::deal_tools_row)
            .map_err(|err| err.to_string())?;
        let mut sources = vec![];

        for source in rows {
            if source.is_ok() {
                let source = source.unwrap();
                sources.push(source);
            } else {
                let err = source.unwrap_err();
                info!("source error {err}")
            }
        }

        Ok(sources)
    }
}
