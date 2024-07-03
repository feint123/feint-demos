// Listen for message
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    sendResponse({message:"default nessage"})
});