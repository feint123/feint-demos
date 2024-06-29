import { initTables } from "./db";

export function init() {
    console.log("init");
    const init_flag = localStorage.getItem("rss_app_init", "true");
    if (null != init_flag && "true" === init_flag) {
        return;
    } else {
        // 创建数据表
        initTables(createSqls);
        localStorage.setItem("rss_app_init", "true");
    }
}

const createSqls = [
    `CREATE TABLE If not exists rss_item(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        link TEXT UNIQUE,
        description TEXT,
        author TEXT,
        category TEXT,
        comments TEXT,
        enclosure TEXT,
        guid TEXT UNIQUE,
        pub_date TEXT,
        source TEXT,
        content TEXT,
        atom_ext TEXT,
        itunes_ext TEXT,
        rss_link TEXT);`
,
`Create TABLE If not exists rss_channel(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    link TEXT ,
    description TEXT,
    language TEXT,
    copyright TEXT,
    managing_editor TEXT,
    webmaster TEXT,
    pub_date TEXT,
    last_build_date TEXT,
    category TEXT,
    generator TEXT,
    docs TEXT);`
]