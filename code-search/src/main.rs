use clap::{arg, Command};
use colored::*;
use indicatif::{ProgressBar, ProgressStyle};
use lang::{
    CQuery, CppQuery, GoQuery, JavaQuery, JavascriptQuery, PythonQuery, RustQuery, SymbolQuery,
};
use prettytable::{
    format::{self},
    row, Table,
};
use std::ffi::OsStr;
use std::{
    fs::{self, read_dir, File},
    io::{BufRead, BufReader},
    path::{Path, PathBuf},
};

use tree_sitter::{Parser, Query, QueryCursor};

pub mod lang;

#[derive(Default)]
struct CommandArgs<'a> {
    path: &'a str,
    search_key: &'a str,
    language: &'a str,
    only_symbol: bool,
}
/**
* a code search engine, users can search code clips from different language source files.
* this program use tree-sitter to analyse code and index by tantivy.
*/
fn main() {
    // defined commands
    let matches = Command::new("code-search")
        .about("a command code search engine")
        .args(&[
            arg!(-p --path <Path> "搜索路径，文件或目录").default_value("."),
            arg!(-l --language <Language> "使用语言文件扩展名，如 rs、md等"),
            arg!(-s --symbol "只搜索符号，如类名、函数名称等"),
            arg!(-k --key <Key> "关键字").required(true),
        ])
        .get_matches();

    let mut args = CommandArgs::default();
    if let Some(path) = matches.get_one::<String>("path") {
        args.path = path;
    }

    if let Some(lang) = matches.get_one::<String>("language") {
        args.language = lang;
    }

    if let Some(key) = matches.get_one::<String>("key") {
        args.search_key = key;
    }

    if let Some(is_function) = matches.get_one::<bool>("symbol") {
        args.only_symbol = *is_function;
    } else {
        args.only_symbol = false;
    }
    // 扫描目录
    let path = Path::new(args.path);
    let mut pathes = vec![];
    recursion_dir(path, &mut pathes, args.language);
    let mut table = Table::new();
    let format = format::FormatBuilder::new().padding(1, 1).build();
    table.set_format(format);
    table.set_format(format);
    table.add_row(row!["文件路径".bold(), "行数".bold(), "代码".bold()]);
    let files = pathes.len();
    let pb = ProgressBar::new(files as u64);
    pb.set_style(
        ProgressStyle::with_template(
            "{spinner:.green} [{elapsed_precise}] [{wide_bar:.cyan/blue}] {pos}/{len} {msg}",
        )
        .unwrap()
        .progress_chars("#>-"),
    );

    let mut progress = 1;
    for path in pathes {
        // let path = doc.get_first(full_path_field).unwrap().as_str().unwrap();
        let path_str = path.to_str().unwrap();
        let mut result = vec![];
        let path_string = path_str.to_string();
        pb.set_position(progress);
        pb.set_message(path_string);
        if path.extension().is_some() {
            let path_extension = path.extension().unwrap().to_str().unwrap();
            // println!("search: {}", path_str.bright_black());
            if args.only_symbol {
                let code = fs::read_to_string(Path::new(path_str)).unwrap_or("".to_string());
                if code.contains(args.search_key) {
                    result = get_all_symbols(&code, get_symbol_query(path_extension));
                    result = result
                        .into_iter()
                        .filter(|item| item.1.contains(args.search_key))
                        .collect();
                }
            } else {
                result = find_text_in_file(path_str, args.search_key).expect(
                    format!("Error read file {path_str}")
                        .as_str()
                        .red()
                        .to_string()
                        .as_str(),
                );
            }
        }
        progress += 1;
        for (line_number, line) in result {
            let new_line = line.replace(
                args.search_key,
                args.search_key.blue().bold().to_string().as_str(),
            );

            table.add_row(row![
                path_str.green(),
                line_number.to_string().normal().bold(),
                new_line.trim()
            ]);
        }
    }
    println!("");
    // 输出结果
    table.printstd();
}
fn valid_language_file(extention: &str) -> bool {
    let valid_extensions = vec![
        "rs", "js", "ts", "java", "py", "go", "c", "cpp", "md", "txt", "html", "css",
    ];
    return valid_extensions.contains(&extention);
}
/*
* 递归目录
*/
fn recursion_dir(root_path: &Path, pathes: &mut Vec<PathBuf>, filter: &str) {
    if root_path.is_dir() {
        for entry in read_dir(root_path).expect("Error read Dir") {
            let dir_entry = entry.expect("Error");
            let path_buf = dir_entry.path();

            recursion_dir(path_buf.as_path(), pathes, filter);
        }
    } else if root_path.is_file() {
        if root_path.extension().is_some() {
            let extension = root_path
                .extension()
                .unwrap_or(OsStr::new(""))
                .to_str()
                .unwrap();
            if (filter.is_empty() || filter == extension) && valid_language_file(extension) {
                pathes.push(root_path.to_path_buf());
            }
        }
    }
}

fn get_symbol_query(extention: &str) -> Box<dyn SymbolQuery> {
    match extention {
        "rs" => Box::new(RustQuery),
        "java" => Box::new(JavaQuery),
        "py" => Box::new(PythonQuery),
        "c" => Box::new(CQuery),
        "cpp" => Box::new(CppQuery),
        "js" => Box::new(JavascriptQuery),
        "go" => Box::new(GoQuery),
        _ => Box::new(RustQuery),
    }
}
/**
* 获取源码中的所有符号
*
*
*/
fn get_all_symbols(code: &String, symbol_query: Box<dyn SymbolQuery>) -> Vec<(usize, String)> {
    let mut parser = Parser::new();
    parser
        .set_language(&symbol_query.get_lang())
        .expect("Error load Rust grammer");
    let tree = parser.parse(code.as_str(), None).unwrap();

    let mut query_cursor = QueryCursor::new();
    let mut filed_vec = vec![];
    for sq in symbol_query.get_queries() {
        let query = Query::new(&symbol_query.get_lang(), sq.as_str()).unwrap();
        let captures = query_cursor.captures(&query, tree.root_node(), code.as_bytes());
        for (m, capture_index) in captures {
            let capture = m.captures[capture_index];
            let node = capture.node;
            let text = node.utf8_text(code.as_bytes()).unwrap();
            filed_vec.push((node.start_position().row + 1, text.to_string()));
        }
    }
    return filed_vec;
}

fn find_text_in_file(filename: &str, text: &str) -> Result<Vec<(usize, String)>, std::io::Error> {
    let file = File::open(filename)?;
    let reader = BufReader::new(file);

    let mut found_lines = Vec::new();
    for (line_number, line) in reader.lines().enumerate() {
        let line = line.unwrap_or("".to_string());
        if line.contains(text) {
            found_lines.push((line_number + 1, line));
        }
    }

    Ok(found_lines)
}
