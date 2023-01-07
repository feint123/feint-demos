import Database from 'tauri-plugin-sql-api';


const dbName = "test.db";

/**
 * @typedef {Database} 
 */

var db = Database.load(`sqlite:${dbName}`);


export function closeDb() {
    db.then((database) => {
        database.close;
        database = null;
    })
}

export async function initTables(createSqls) {
    const database = await db;
    for (var index in createSqls) {
        database.execute(createSqls[index])
    }
}

export async function initSqls(tableName,insertSqls) {
    const database = await db;
    await database.execute(`DELETE FROM ${tableName} WHERE 1=1;`);
    for (var index in insertSqls) {
        database.execute(insertSqls[index])
    }
}

//-------------------CLIPBOARD----------------//
export function selectAllClips(handleFunc) {
    db.then((database) => {
        database.select('SELECT * FROM CLIPBOARD ORDER by ADD_TIME DESC;', [])
            .then((result) => {
                if (result.length > 0) {
                    handleFunc(result);
                }
            })
    })
}

export function deleteClipsById(id, handleFunc) {
    db.then((database) => {
        database.execute('DELETE FROM CLIPBOARD WHERE ID = $1', [id])
            .then((result) => {
                handleFunc(result);
            })
    })
}

export function selectFirstClips(handleFunc) {
    db.then((database) => {
        database.select('SELECT * FROM CLIPBOARD ORDER by ADD_TIME DESC limit 1;', [])
            .then((result) => {
                if (result.length > 0) {
                    handleFunc(result);
                }
            })
    })
}

export function selectClipsByMd5(md5, handleFunc) {
    db.then((database) => {
        database.select('SELECT * FROM CLIPBOARD WHERE CONTENT_MD5=$1;', [md5])
            .then((result) => {
                if (result.length > 0) {
                    handleFunc(result);
                }
            }).catch((e)=> {
                console.log(e);
            })
    })
}

export function selectClipsByKey(keyword, handleFunc) {
    db.then((database) => {
        database.select(`SELECT * FROM CLIPBOARD WHERE CONTENT LIKE "%${keyword}%" and CLIP_TYPE=1`, [])
            .then((result) => {
                if (result.length > 0) {
                    handleFunc(result);
                }
            })
    })
}

export function checkClipExsits(md5, handleFunc) {
    db.then((database) => {
        database.select("SELECT CONTENT FROM CLIPBOARD WHERE CONTENT_MD5=$1;", [md5])
            .then((result) => {
                if (result.length > 0 && result[0].CONTENT != null) {
                    handleFunc(true);
                } else {
                    handleFunc(false);
                }
            }).catch(e=> {
                console.error(e)
            })
    })
}

export function updateCLipAddTimeByMd5(md5, datetime, handleFunc) {
    db.then((database) => {
        // console.log("feint-debug updateCLipAddTimeByMd5: " + md5)
        database.execute("UPDATE CLIPBOARD SET ADD_TIME = $1 WHERE CONTENT_MD5=$2;",
            [datetime, md5]).then((result) => {
                // console.log("feint-debug updateCLipAddTimeByMd5: success")
                handleFunc(result);
            });
    }).catch(e=> {
        console.error(e);
    })
}

export function insertClip(clipboard, handleFunc) {
    db.then((database) => {
        database.execute('INSERT INTO CLIPBOARD(CONTENT, ADD_TIME, CONTENT_MD5, CLIP_TYPE) VALUES ($1,$2,$3, $4);',
            [clipboard.content, clipboard.addTime, clipboard.md5, clipboard.clipType]).finally((result) => {
                handleFunc(result);
            });
    }) 
}

//-------------------COLOR----------------//

export function selectAllColors(handleFunc) {
    db.then((database) => {
        database.select('SELECT * FROM COLOR;', [])
            .then((result) => {
                if (result.length > 0) {
                    handleFunc(result);
                }
            })
    })
}
