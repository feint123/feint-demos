use lazy_static::lazy_static;
use log::info;
use std::{
    fs,
    path::{Path, PathBuf},
    sync::{Arc, Mutex},
};
use tantivy::{
    collector::TopDocs,
    directory::MmapDirectory,
    doc, index,
    query::{self, BooleanQuery, Occur, QueryClone, QueryParser, TermQuery},
    schema::{
        self, FieldValue, IndexRecordOption, Schema, TextFieldIndexing, TextOptions, INDEXED,
        STORED, STRING,
    },
    Document, Index, IndexWriter, TantivyDocument, Term,
};
use tauri::{AppHandle, Manager};

use crate::source::ToolsSourceItem;

#[derive(Default)]
pub struct ToolsSearch {
    index_name: String,
    index: Option<Index>,
}

lazy_static! {
    pub static ref TOOLS_INDEX: Arc<Mutex<ToolsSearch>> =
        Arc::new(Mutex::new(ToolsSearch::default()));
}

pub fn init_index(handle: &AppHandle) -> Result<(), String> {
    let mut tools_index = TOOLS_INDEX.lock().map_err(|err| err.to_string())?;
    let index = tools_index.init_index(handle)?;
    tools_index.index = Some(index);
    Ok(())
}

impl ToolsSearch {
    fn exists(&self, index_path: &PathBuf) -> Result<bool, String> {
        let mmDir = MmapDirectory::open(index_path).map_err(|e| e.to_string())?;
        return Index::exists(&mmDir).map_err(|e| e.to_string());
    }

    fn get_schema() -> Schema {
        let mut schema_builder = Schema::builder();

        let text_filed_indexing = TextFieldIndexing::default()
            .set_tokenizer("jieba")
            .set_index_option(tantivy::schema::IndexRecordOption::WithFreqsAndPositions);

        let text_options = TextOptions::default()
            .set_indexing_options(text_filed_indexing)
            .set_stored();

        schema_builder.add_i64_field("tool_id", STORED | INDEXED);
        schema_builder.add_text_field("target_url", STORED | STRING);
        schema_builder.add_text_field("source_id", STORED | STRING);
        schema_builder.add_text_field("title", text_options.clone());
        schema_builder.add_text_field("description", text_options.clone());
        schema_builder.add_text_field("content", text_options.clone());

        return schema_builder.build();
    }

    pub fn init_index(&self, handle: &AppHandle) -> Result<Index, String> {
        let mut app_data_dir = handle
            .path()
            .app_data_dir()
            .map_err(|err| err.to_string())?;
        if !app_data_dir.exists() {
            fs::create_dir(app_data_dir.as_path()).map_err(|err| err.to_string())?
        }
        let app_data_dir_string = app_data_dir.as_mut_os_string();
        app_data_dir_string.push(format!("/index/{}", self.index_name.clone()));
        let index_path_str = app_data_dir_string.to_str().unwrap();
        let index_path = PathBuf::from(index_path_str);
        if !index_path.exists() {
            fs::create_dir_all(index_path.as_path()).map_err(|err| err.to_string())?
        }
        let tokenizer = tantivy_jieba::JiebaTokenizer {};
        if self.exists(&index_path).map_err(|e| e.to_string())? {
            let index = Index::open(MmapDirectory::open(&index_path).map_err(|e| e.to_string())?)
                .map_err(|e| e.to_string())?;
            index.tokenizers().register("jieba", tokenizer);
            return Ok(index);
        }

        let schema = Self::get_schema();

        let index = tantivy::Index::create_in_dir(&index_path.as_path(), schema.clone())
            .map_err(|e| e.to_string())?;

        index.tokenizers().register("jieba", tokenizer);

        Ok(index)
    }

    pub fn update_index(&self, tool_items: &Vec<ToolsSourceItem>) -> Result<(), String> {
        if let Some(tools_index) = &self.index {
            let schema = Self::get_schema();
            let id = schema.get_field("tool_id").map_err(|err| err.to_string())?;
            let title = schema.get_field("title").map_err(|err| err.to_string())?;
            let description = schema
                .get_field("description")
                .map_err(|err| err.to_string())?;
            let content = schema.get_field("content").map_err(|err| err.to_string())?;
            let target_url = schema
                .get_field("target_url")
                .map_err(|err| err.to_string())?;
            let source_id = schema
                .get_field("source_id")
                .map_err(|err| err.to_string())?;
            let mut index_writer = tools_index
                .writer(50_000_000)
                .map_err(|err| err.to_string())?;
            // 更新索引分为 删除和添加 两步
            for ele in tool_items {
                let url_term = Term::from_field_text(target_url, &ele.target_url.as_str());
                let source_id_term =
                    Term::from_field_text(source_id, &ele.tools_source_id.as_str());
                let url_query = TermQuery::new(url_term.clone(), IndexRecordOption::Basic);
                let source_id_query =
                    TermQuery::new(source_id_term.clone(), IndexRecordOption::Basic);
                // let tools_exists = self.extract_doc_by_url(&url_term)?;
                // if tools_exists.is_some() {
                // }
                let union_query = BooleanQuery::new(vec![
                    (Occur::Must, url_query.box_clone()),
                    (Occur::Must, source_id_query.box_clone()),
                ]);
                let _ = index_writer
                    .delete_query(union_query.box_clone())
                    .map_err(|err| err.to_string())?;
                index_writer
                    .add_document(doc!(
                        id => ele.id as i64,
                        title => ele.title.as_str(),
                        description => ele.description.as_str(),
                        content => ele.content.as_str(),
                        target_url => ele.target_url.as_str(),
                        source_id => ele.tools_source_id.as_str()
                    ))
                    .map_err(|err| err.to_string())?;
            }

            index_writer.commit().map_err(|err| err.to_string())?;
        }
        Ok(())
    }

    pub fn delete_by_source_id(&self, tools_source_id: &String) -> Result<(), String> {
        if let Some(tools_index) = &self.index {
            let schema = Self::get_schema();
            let source_id = schema
                .get_field("source_id")
                .map_err(|err| err.to_string())?;
            let source_id_term = Term::from_field_text(source_id, &tools_source_id.as_str());
            let mut index_writer: IndexWriter = tools_index
                .writer(50_000_000)
                .map_err(|err| err.to_string())?;
            index_writer.delete_term(source_id_term);
            index_writer.commit().map_err(|err| err.to_string())?;
        }

        Ok(())
    }
    fn extract_doc_by_url(&self, target_url: &Term) -> Result<Option<TantivyDocument>, String> {
        if let Some(tools_index) = &self.index {
            let reader = tools_index.reader().map_err(|err| err.to_string())?;
            let searcher = reader.searcher();
            let term_query = TermQuery::new(target_url.clone(), IndexRecordOption::Basic);
            let top_docs = searcher
                .search(&term_query, &TopDocs::with_limit(1))
                .map_err(|err| err.to_string())?;
            if let Some((_score, doc_address)) = top_docs.first() {
                let doc = searcher.doc(*doc_address).map_err(|err| err.to_string())?;
                return Ok(Some(doc));
            } else {
                return Ok(None);
            }
        }

        Ok(None)
    }
    pub fn search(&self, keyword: String) -> Result<Vec<String>, String> {
        if let Some(tools_index) = &self.index {
            let mut result = vec![];
            let reader = tools_index.reader().map_err(|err| err.to_string())?;
            let searcher = reader.searcher();
            let schema = tools_index.schema();
            let title = schema.get_field("title").map_err(|err| err.to_string())?;
            let description = schema
                .get_field("description")
                .map_err(|err| err.to_string())?;
            let content = schema.get_field("content").map_err(|err| err.to_string())?;
            let query_parser =
                QueryParser::for_index(tools_index, vec![title, description, content]);
            let query = query_parser
                .parse_query(keyword.as_str())
                .map_err(|err| err.to_string())?;

            let top_docs = searcher
                .search(&query, &TopDocs::with_limit(10))
                .map_err(|err| err.to_string())?;
            for (_score, doc_address) in top_docs {
                let retrieved_doc: TantivyDocument =
                    searcher.doc(doc_address).map_err(|err| err.to_string())?;
                result.push(retrieved_doc.to_json(&schema))
            }
            return Ok(result);
        }

        Ok(vec![])
    }
}
