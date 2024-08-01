"use strict";
import { setItem, getItem } from "./storage";

/**
 * @module cinemaMode
 * @description 沉浸式观看视频
 */

/**
 * id/class: comment 评论区
 * .left-container-under-player
 * right-container right-container-inner
 * .bpx-player-control-wrap
 *
 * #bilibili-player mode-webscreen
 * bpx-player-ctrl-web
 * bpx-player-sending-area
 */

function webscreenVideo() {
  let player = document.querySelector("#bilibili-player");
  player.classList.add("mode-webscreen");
  player.classList.add("cinema-flag");
  document.body.classList.add("webscreen-fix");
  let sendArea = document.querySelector(".bpx-player-sending-area");
  sendArea.innerHTML = "";
  document.querySelector("#biliMainHeader").style.display = "none";
}

function revertWebScreeVideo() {
  let player = document.querySelector(".cinema-flag");
  if (player) {
    player.classList.remove("mode-webscreen");
  }
  document.body.classList.remove("webscreen-fix");
  document.querySelector("#biliMainHeader").style = "";
}

/**
 *
 * @param {boolean} enabled
 */
function toggleCinemaMode(enabled) {
  if (enabled) {
    webscreenVideo();
  } else {
    revertWebScreeVideo();
  }
}
// Listen for message
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  console.log(request);
  if (request.type === "CINEMA_MODE") {
    if (request.payload && request.payload.cinemaMode) {
      toggleCinemaMode(true);
    } else {
      toggleCinemaMode(false);
    }
    sendResponse({});
    return true;
  } else if (request.type === "AUTO_PLAY") {
    localStorage.setItem(
      "recommend_auto_play",
      request.payload.autoPlay ? "open" : "close",
    );
    sendResponse({});
    return true;
  } else if (request.type === "NOTE_MODE") {
    if (request.payload.noteMode) {
      openNoteMode();
    }
    sendResponse({});
    return true;
  }
});
/**
 *
 */
function openNoteMode(inteval) {
  console.log("openNodeMode");
  // 自动打开笔记面板
  const note = document.querySelector(".video-note-inner");
  let qlEditor;
  let autoScroll = true;
  if (note) {
    note.click();
    clearInterval(inteval);
    // 获取笔记内容
    setInterval(() => {
      let tagBlotList = document.querySelectorAll(".ql-tag-blot");
      const currentSecond = getPlayedSecond();
      let minDisSecond = 1000000;
      let targetTagElem = tagBlotList[0];
      tagBlotList.forEach((element) => {
        const secondStr = element.getAttribute("data-seconds");
        if (secondStr) {
          const tagSeconde = Number.parseInt(secondStr);
          // 获取距离播放时间点最近的时间标记
          const currentDis = Math.abs(tagSeconde - currentSecond);
          if (currentDis < minDisSecond) {
            minDisSecond = currentDis;
            targetTagElem = element;
          }
        }
      });
      if (targetTagElem) {
        const offsetTop = targetTagElem.offsetTop;
        if (!qlEditor) {
          qlEditor = document.querySelector(".ql-editor");
          qlEditor.addEventListener("blur", (ev) => {
            autoScroll = true;
          });
          qlEditor.addEventListener("focus", (ev) => {
            autoScroll = false;
          });
        }
        if (autoScroll) {
          qlEditor.scrollTo({ top: offsetTop, behavior: "smooth" });
        }
      }
    }, 1000);
  }
}

function getPlayedSecond() {
  const currentTimeDiv = document.querySelector(
    ".bpx-player-ctrl-time-current",
  );
  if (currentTimeDiv) {
    const timeStr = currentTimeDiv.textContent;
    let second = 0;
    let rate = 1;
    timeStr
      .split(":")
      .reverse()
      .forEach((value) => {
        second = second + value * rate;
        rate = rate * 60;
      });
    return second;
  } else {
    return 0;
  }
}

getItem("switches").then((result) => {
  localStorage.setItem(
    "recommend_auto_play",
    result.autoPlay ? "open" : "close",
  );
  if (result.noteMode) {
    const inteval = setInterval(() => {
      openNoteMode(inteval);
    }, 1000);
  }
  setTimeout(() => {
    toggleCinemaMode(result.cinemaMode);
  }, 1000);
});
