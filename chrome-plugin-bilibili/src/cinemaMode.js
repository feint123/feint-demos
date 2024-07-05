'use strict';
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
  let player = document.querySelector('#bilibili-player');
  player.classList.add('mode-webscreen');
  player.classList.add('cinema-flag')
  document.body.classList.add('webscreen-fix')
  let sendArea = document.querySelector('.bpx-player-sending-area');
  sendArea.innerHTML = ""
  document.querySelector("#biliMainHeader").style.display = 'none'
}

function revertWebScreeVideo() {
  let player = document.querySelector('.cinema-flag');
  if (player) {
    player.classList.remove('mode-webscreen');
  }
  document.body.classList.remove('webscreen-fix')
  document.querySelector("#biliMainHeader").style = ''
}

/**
 * 
 * @param {boolean} enabled 
 */
function toggleCinemaMode(enabled) {
  if (enabled) {
    webscreenVideo()
  } else {
    revertWebScreeVideo()
  }
}
// Listen for message
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'CINEMA_MODE') {
    if (request.payload && request.payload.cinemaMode) {
      toggleCinemaMode(true)
    } else {
      toggleCinemaMode(false)
    }
    sendResponse({});
    return true;
  } else if (request.type === 'AUTO_PLAY') {
    localStorage.setItem("recommend_auto_play", request.payload.autoPlay ? "open" : "close")
    sendResponse({});
    return true;
  }

});

getItem("switches").then(result => {
  localStorage.setItem("recommend_auto_play", result.autoPlay ? "open" : "close")

  setTimeout(() => {
    toggleCinemaMode(result.cinemaMode)
  }, 1000)
})