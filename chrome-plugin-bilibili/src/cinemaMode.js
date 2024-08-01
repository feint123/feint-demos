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

  let lastCid;
  if (note) {
    note.click();
    clearInterval(inteval);
    const indicatorDiv = document.createElement("div");
    indicatorDiv.innerHTML = `

      <div class="svg-icon print" data-v-7a68f144="" style="width: 22px; height: 22px;">
      <svg xmlns:xlink="http://www.w3.org/1999/xlink" width="800px" height="800px" viewBox="0 0 32 32" xml:space="preserve">
      <style type="text/css">
	.duotone_twee{fill:#555D5E;}
	.duotone_een{fill:#0B1719;}
      </style>
      <g>
	<path class="duotone_een" d="M23.078,17.263C23.26,17.596,23.017,18,22.637,18H9.361c-0.351,0-0.589-0.356-0.469-0.686
		c0.503-1.381,1.493-2.479,2.91-2.741c0.212-0.039,0.371-0.206,0.402-0.419L12.94,9h6.219c0.286,2.005,0.122,0.854,0.749,5.246
		c0.025,0.178,0.151,0.322,0.317,0.388C21.48,15.134,22.449,16.109,23.078,17.263z M9.928,7.695L11.15,8h9.8l1.221-0.305
		c0.223-0.056,0.379-0.256,0.379-0.485V5.5c0-0.276-0.224-0.5-0.5-0.5h-12c-0.276,0-0.5,0.224-0.5,0.5v1.71
		C9.549,7.439,9.706,7.639,9.928,7.695z"></path>
	<path class="duotone_twee" d="M15,19v8c0,1.323,2,1.325,2,0v-8H15z"></path>
      </g>
      </svg>
      </div>
      `;
    indicatorDiv.classList.add("close-note");
    indicatorDiv.addEventListener("click", () => {
      let activeCid = null;
      const activeEle = document.querySelector(
        ".bpx-player-ctrl-eplist-menu-item.bpx-state-active",
      );
      if (activeEle) {
        activeCid = activeEle.getAttribute("data-cid");
      }
      let tagBlotList = document.querySelectorAll(".ql-tag-blot");
      const currentSecond = getPlayedSecond();
      let minDisSecond = 1000000;
      let targetTagElem = tagBlotList[0];
      tagBlotList.forEach((element) => {
        const secondStr = element.getAttribute("data-seconds");
        const tagCid = element.getAttribute("data-cid");
        if (secondStr) {
          // 适配分区视频
          if ((activeCid && activeCid == tagCid) || !activeCid) {
            const tagSeconde = Number.parseInt(secondStr);
            // 获取距离播放时间点最近的时间标记
            const currentDis = Math.abs(tagSeconde - currentSecond);
            if (currentDis < minDisSecond) {
              minDisSecond = currentDis;
              targetTagElem = element;
            }
          }
        }
      });

      const qlEditor = document.querySelector(".ql-editor");
      // 查看他人笔记时，使用“note-detail” 来进行滚动；
      const noteDetail = document.querySelector(".note-detail");

      if (targetTagElem) {
        // bpx-state-active
        const offsetTop = targetTagElem.offsetTop;

        if (noteDetail) {
          noteDetail.scrollTo({ top: offsetTop, behavior: "smooth" });
        } else {
          qlEditor.scrollTo({ top: offsetTop, behavior: "smooth" });
        }
      }
    });
    const noteHeader = document.querySelector(".note-header");
    noteHeader.appendChild(indicatorDiv);
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
