"use strict";

import "./popup.css";
import { setItem, getItem } from "./storage";

(function () {
  function loadCollectList() {
    let collectList = document.querySelector(".collect-list");
    getItem("localCollect").then((list) => {
      if (list && list instanceof Array && list.length > 0) {
        list.forEach((item) => {
          const div = document.createElement("div");
          div.classList.add(
            "flex",
            "flex-row",
            "bg-slate-50",
            "last:border-none",
            "border-b",
            "border-gray-200",
            "justify-start",
          );

          // div.onclick = () => {
          //   window.open(item.videoUrl)
          // }
          div.innerHTML = `
          <img
            src="${item.imageUrl}"
            alt="Card Image" class="w-16 h-16 object-cover">
          <div class="max-w-64 w-full py-1 px-4 flex flex-col text-left">
            <a href="${item.videoUrl}" target="_blank" class="text-gray-800 text-sm font-bold mb-2 truncate ...">${item.title}</a>
            <div class="text-gray-600 flex text-xs truncate ...">
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 24 24" width="24" height="24" fill="currentColor" class="bili-video-card__info--owner__up"><!--[--><path d="M6.15 8.24805C6.5642 8.24805 6.9 8.58383 6.9 8.99805L6.9 12.7741C6.9 13.5881 7.55988 14.248 8.3739 14.248C9.18791 14.248 9.8478 13.5881 9.8478 12.7741L9.8478 8.99805C9.8478 8.58383 10.1836 8.24805 10.5978 8.24805C11.012 8.24805 11.3478 8.58383 11.3478 8.99805L11.3478 12.7741C11.3478 14.41655 10.01635 15.748 8.3739 15.748C6.73146 15.748 5.4 14.41655 5.4 12.7741L5.4 8.99805C5.4 8.58383 5.73578 8.24805 6.15 8.24805z" fill="currentColor"></path><path d="M12.6522 8.99805C12.6522 8.58383 12.98795 8.24805 13.4022 8.24805L15.725 8.24805C17.31285 8.24805 18.6 9.53522 18.6 11.123C18.6 12.71085 17.31285 13.998 15.725 13.998L14.1522 13.998L14.1522 14.998C14.1522 15.4122 13.8164 15.748 13.4022 15.748C12.98795 15.748 12.6522 15.4122 12.6522 14.998L12.6522 8.99805zM14.1522 12.498L15.725 12.498C16.4844 12.498 17.1 11.8824 17.1 11.123C17.1 10.36365 16.4844 9.74804 15.725 9.74804L14.1522 9.74804L14.1522 12.498z" fill="currentColor"></path><path d="M12 4.99805C9.48178 4.99805 7.283 5.12616 5.73089 5.25202C4.65221 5.33949 3.81611 6.16352 3.72 7.23254C3.60607 8.4998 3.5 10.171 3.5 11.998C3.5 13.8251 3.60607 15.4963 3.72 16.76355C3.81611 17.83255 4.65221 18.6566 5.73089 18.7441C7.283 18.8699 9.48178 18.998 12 18.998C14.5185 18.998 16.7174 18.8699 18.2696 18.74405C19.3481 18.65655 20.184 17.8328 20.2801 16.76405C20.394 15.4973 20.5 13.82645 20.5 11.998C20.5 10.16965 20.394 8.49877 20.2801 7.23205C20.184 6.1633 19.3481 5.33952 18.2696 5.25205C16.7174 5.12618 14.5185 4.99805 12 4.99805zM5.60965 3.75693C7.19232 3.62859 9.43258 3.49805 12 3.49805C14.5677 3.49805 16.8081 3.62861 18.3908 3.75696C20.1881 3.90272 21.6118 5.29278 21.7741 7.09773C21.8909 8.3969 22 10.11405 22 11.998C22 13.88205 21.8909 15.5992 21.7741 16.8984C21.6118 18.7033 20.1881 20.09335 18.3908 20.23915C16.8081 20.3675 14.5677 20.498 12 20.498C9.43258 20.498 7.19232 20.3675 5.60965 20.2392C3.81206 20.0934 2.38831 18.70295 2.22603 16.8979C2.10918 15.5982 2 13.8808 2 11.998C2 10.1153 2.10918 8.39787 2.22603 7.09823C2.38831 5.29312 3.81206 3.90269 5.60965 3.75693z" fill="currentColor"></path><!--]--></svg>
             <div class="pl-2" style="line-height:1.5rem">${item.up}</div>
             </div>
            <!-- 这里可以添加更多内容 -->
          </div>

          `;
          const removeBtn = document.createElement("button");
          removeBtn.classList.add("text-red-500", "text-xl", "mr-4");
          removeBtn.innerHTML = "⊗";
          removeBtn.onclick = () => {
            console.log("click remove button");
            const index = list.indexOf(item);
            list.splice(index, 1);
            setItem("localCollect", list);
            div.remove();
          };
          div.appendChild(removeBtn);
          collectList.appendChild(div);
        });
      }
    });
  }

  document
    .getElementById("addRowButton")
    .addEventListener("click", function () {
      // 创建新的行元素
      document.getElementById("rowContainer").classList.remove("hidden");
      document.getElementById("cancelRowButton").disabled = false;
      document.getElementById("addRowButton").disabled = true;
    });

  document
    .getElementById("cancelRowButton")
    .addEventListener("click", function () {
      // 创建新的行元素
      document.getElementById("rowContainer").classList.add("hidden");
      document.getElementById("cancelRowButton").disabled = true;
      document.getElementById("addRowButton").disabled = false;
    });

  document
    .getElementById("saveFilterButton")
    .addEventListener("click", function () {
      // 创建新的行元素
      const type = document.querySelector("#filter-type").value;
      const keyword = document.querySelector("#filter-keyword").value;
      const id = new Date().getTime();
      const div = getFilterItemDiv(type, keyword, id);

      getItem("keywordFilter").then((result) => {
        if (!result || (!result) instanceof Array) {
          result = [];
        }
        result.push({
          id: id,
          type: type,
          keyword: keyword,
        });
        setItem("keywordFilter", result);
      });
      document.querySelector(".filter-list").appendChild(div);
      updateFilterMessage();
    });

  /**
   * 加载关键词列表
   */
  function loadFilterList() {
    getItem("keywordFilter").then((result) => {
      console.log(result);
      if (result && result instanceof Array && result.length > 0) {
        const filterList = document.querySelector(".filter-list");
        result.forEach((item) => {
          const div = getFilterItemDiv(item.type, item.keyword, item.id);
          filterList.appendChild(div);
        });
      }
    });
  }

  function updateFilterMessage() {
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
      const tab = tabs[0];
      chrome.tabs.sendMessage(
        tab.id,
        {
          type: "UPDATE_KEYWORD",
        },
        (response) => {
          console.log("hello world");
        },
      );
    });
  }
  /**
   *
   * @param {String} type
   * @param {String} keyword
   * @param {String} id
   * @returns {Node}
   */

  function getFilterItemDiv(type, keyword, id) {
    const div = document.createElement("div");
    div.classList.add("flex", "flex-row", "py-2");
    div.innerHTML = `
    <div class="w-1/4">
    ${getTypeName(type)}
    </div>
    <div class="w-1/2">
      ${keyword}
    </div>
    <div class="w-1/4">
      <button class="text-red-500">移除</button>
    </div>
    `;
    const button = div.querySelector("button");
    button.onclick = () => {
      div.remove();
      getItem("keywordFilter").then((result) => {
        if (result && result instanceof Array) {
          result = result.filter((item) => item.id !== id);
          setItem("keywordFilter", result);
        }
      });
      updateFilterMessage();
    };
    return div;
  }

  function getTypeName(type) {
    switch (type) {
      case "title":
        return "标题";
      case "up":
        return "up主";
      case "ad":
        return "广告";
      case "live":
        return "直播";
    }
  }
  /**
   * 存储开关
   */
  const switchStorage = {
    get: (cb) => {
      getItem("switches").then((result) => {
        cb(result);
      });
    },
    set: (value, cb) => {
      setItem("switches", value).then(() => {
        cb();
      });
    },
  };

  let defaultSwitchConfig = {
    searchMode: false,
    cinemaMode: false,
    keywordFilter: false,
    localCollect: true,
    autoPlay: false,
    noteMode: false,
  };
  /**
   * 恢复控制面板的数据
   */
  function restoreSwitches() {
    beforeRestorSwitches();
    switchStorage.get((switches) => {
      if (
        typeof switches === "undefined" ||
        switches == "" ||
        switches == null
      ) {
        // Set counter value as 0
        switchStorage.set(defaultSwitchConfig, () => {
          setupSwitch();
        });
      } else {
        setupSwitch(switches);
      }
    });
    loadCollectList();
    loadFilterList();
  }

  function beforeRestorSwitches() {
    // 设定默认值
    defaultSwitchConfig.autoPlay =
      localStorage.getItem("recommend_auto_play") === "open" ? true : false;
  }

  document.addEventListener("DOMContentLoaded", restoreSwitches);

  /**
   *
   * @param {*} initialState
   */
  function setupSwitch(initialState = defaultSwitchConfig) {
    setupSwitchElement({
      type: "SEARCH_MODE",
      elementId: "searchMode",
      switches: initialState,
    });
    setupSwitchElement({
      type: "CINEMA_MODE",
      elementId: "cinemaMode",
      switches: initialState,
    });
    setupSwitchElement({
      type: "LOCAL_COLLECT",
      elementId: "localCollect",
      switches: initialState,
    });
    setupSwitchElement({
      type: "KEYWORD_FILTER",
      elementId: "keywordFilter",
      switches: initialState,
    });
    setupSwitchElement({
      type: "AUTO_PLAY",
      elementId: "autoPlay",
      switches: initialState,
    });
    setupSwitchElement({
      type: "NOTE_MODE",
      elementId: "noteMode",
      switches: initialState,
    });
  }

  function setupSwitchElement({ type, elementId, switches }) {
    const switchElement = document.getElementById(elementId);
    if (switchElement) {
      switchElement.checked = switches[elementId];
      switchElement.addEventListener("change", () => {
        switchStorage.get((swithes) => {
          swithes[elementId] = switchElement.checked;
          updateSwitch({
            switchValue: swithes,
            type: type,
          });
        });
      });
    }
  }

  function updateSwitch({ switchValue, type }) {
    switchStorage.set(switchValue, () => {
      // 只对当前活动的页面生效
      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        const tab = tabs[0];
        chrome.tabs.sendMessage(
          tab.id,
          {
            type: type,
            payload: switchValue,
          },
          (response) => {
            console.log("Current count value passed to contentScript file");
          },
        );
      });
    });
  }
})();
