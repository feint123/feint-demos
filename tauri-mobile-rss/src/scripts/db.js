import Database from '@tauri-apps/plugin-sql';
// 测试阶段暂定为test.db
const dbName = "mobileRss.db";
/**
 * @typedef {Database}
 */
var db = Database.load(`sqlite:${dbName}`);

export async function initTables(createSqls) {
    const database = await db;
    for (var index in createSqls) {
        database.execute(createSqls[index]);
    }
}

export function closeDb() {
    db.then((database) => {
        database.close(dbName);
    });
}
/**
 * CREATE TABLE If not exists rss_item(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        link TEXT,
        description TEXT,
        author TEXT,
        category TEXT,
        comments TEXT,
        enclosure TEXT,
        guid TEXT,
        pub_date TEXT,
        source TEXT,
        content TEXT,
        atom_ext TEXT,
        itunes_ext TEXT,
        rss_link TEXT,
 * @param {*} rssItem 
 * @returns 
 */
export function insertRSSItem(rssItem) {
    return new Promise((resolve, reject) => {
        db.then((database) => {
            database.execute(`INSERT OR REPLACE INTO rss_item (title, link, description, author, category, comments, enclosure, guid, pub_date, source, content, atom_ext, itunes_ext, rss_link) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) `, 
                [rssItem.title, rssItem.link, rssItem.description, rssItem.author, rssItem.category, rssItem.comments, rssItem.enclosure, rssItem.guid, rssItem.pub_date, rssItem.source, rssItem.content, rssItem.atom_ext, rssItem.itunes_ext, rssItem.rss_link])
            .then((result) => {
                resolve(result);
            }).catch((e) => {
                reject(e);
            })
        }).catch((e) => {
            reject(e);
        })
    });
}

export function selectAllRSSItem() {
    return new Promise((resolve, reject) => {
        db.then((database) => {
            database.select(`SELECT * FROM rss_item order by pub_date desc`)
            .then((result) => {
                resolve(result);
            }).catch((e) => {
                reject(e);
            })
        }).catch((e) => {
            reject(e);
        })
    });
}

export function selectRSSItemById(id) {
    return new Promise((resolve, reject) => {
        db.then((database) => {
            database.select(`SELECT * FROM rss_item where id = $1`, [Number.parseInt(id)])
            .then((result) => {
                resolve(result);
            }).catch((e) => {
                reject(e);
            })
        }).catch((e) => {
            reject(e);
        })
    });
}

export function deleteAllRSSItems() {
    return new Promise((resolve, reject) => {
        db.then((database) => {
            database.execute('DELETE FROM rss_item WHERE 1=1;').then((result) => {
                resolve(result);
            }).catch((e) => {
                reject(e);
            });
        }).catch((e) => {
            reject(e);
        })
    });
}