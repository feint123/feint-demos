'use strict';
import { setItem, getItem } from "./storage";

/**
 * @module searchMode
 * @description 将阿B主页修改成类似搜索引擎首页的样式，让界面更加简洁
 */

const searchModeContext = {
  searchStyle: {}
}
function createUserStyle() {
  const style = document.createElement("style")
  style.innerHTML = `
    .bili-footer {
      display: none;
    }
    .bili-header__channel {
      display: none;
    }
    .header-channel {
      display: none;
    }
    .new-main {
      background-image: linear-gradient(to bottom, white, #ffffff00);
    }
    #i_cecream {
      background-color: #ffffff00;
    }
    main {
      display: none;
    }
  }`
  document.head.appendChild(style)
  searchModeContext.searchStyle = style
}
function centerSearchInput() {
  const headerBanner = document.querySelector(".bili-header");
  const headerChannel = document.querySelector(".header-channel")
  const newElement = document.createElement("div")
  newElement.classList.add("new-main")
  newElement.style.height = window.innerHeight - getDivHeight(headerBanner) + "px"

  headerChannel.insertAdjacentElement('afterend', newElement)
  const searchInput = document.querySelector(".center-search-container")
  // 使用绝对布局，让搜索框在中间
  searchInput.style.left = "50%"
  searchInput.style.transform = "translate(-50%, 0)"
  console.log()
  searchInput.style.top = (100 + getDivHeight(headerBanner)) + "px"
  searchInput.style.width = "50%"
  searchInput.style.height = "50%"
  searchInput.style.position = "absolute"
  searchInput.style.transition = "transform 0.5s ease"

  addEventListener("resize", () => {
    newElement.style.height = window.innerHeight - getDivHeight(headerBanner) + "px"
    searchInput.style.top = (100 + getDivHeight(headerBanner)) + "px"

  })
}

/**
 * 
 * @param {Node} node 
 * @returns {Number}
 */
function getDivHeight(node) {
  if (node && node instanceof Node) {
    return Number.parseInt(window.getComputedStyle(node).height.replace("px",""))
  } else {
    return 0
  }
}

/**
 * 
 * @param {boolean} enabled 
 */
function toggleSearchMode(enabled) {
  if (enabled) {
    createUserStyle()
    centerSearchInput()
  } else {
    if (searchModeContext.searchStyle instanceof Node) {
      document.head.removeChild(searchModeContext.searchStyle)
    }
    let newMain = document.querySelector(".new-main");
    if (newMain) {
      newMain.remove()
    }
    const searchInput = document.querySelector(".center-search-container")
    searchInput.style = ""
    // location.reload()
  }
}
// Listen for message
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'SEARCH_MODE') {
    if (request.payload && request.payload.searchMode) {
      toggleSearchMode(true)
    } else {
      toggleSearchMode(false)
    }
    sendResponse({});
    return true;
  }
});

getItem("switches").then(result => {
  if(result) {
    toggleSearchMode(result.searchMode)
  }
})