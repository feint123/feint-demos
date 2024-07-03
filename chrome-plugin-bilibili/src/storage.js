/**
 * @param {string} key
 * @param {string} value
 * @returns {Promise<void>}
 */
export function setItem(key, value) {
    return new Promise((resolve, reject) => {
        chrome.storage.sync.set({ [key]: value }, () => {
            if (chrome.runtime.lastError) {
                reject(chrome.runtime.lastError);
            } else {
                resolve();
            }
        });
        // localStorage.setItem(key , JSON.stringify(value));
        // resolve()
    });
}

/**
 * @param {string} key
 * @returns {Promise<string>}
 */
export function getItem(key) {
    return new Promise((resolve, reject) => {
        chrome.storage.sync.get([key], (result) => {
            if (chrome.runtime.lastError) {
                reject(chrome.runtime.lastError);
            } else {
                resolve(result[key]);
            }
        });
        // resolve(JSON.parse(localStorage.getItem(key)))
    });
}