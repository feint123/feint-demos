import { getItem, setItem } from "./storage";

const style = document.createElement('style');
style.innerHTML = `
.local-collect-btn {
position: absolute;
right: 1px;
  margin-left: 1em;
  color: red;
  border: 1px solid red;
  border-radius: 4px;
  padding: 0.2em 1em;
 cursor: pointer;
 background-color: white;
}
.local-collect-btn.collected{
  color:green;
  border: 1px solid green;
}
 `
document.head.appendChild(style);

let interval

let collects = []

function isSameVideo(url, href) {
    return url === href || url +"/" === href || url === href+"/"
}
function normalCollect(collectBtn, card) {
    if(collects.find(item => isSameVideo(item.videoUrl, card.querySelector('.bili-video-card__info--tit a').href))) {
        collectBtn.innerHTML = "已收藏"
        collectBtn.classList.add("collected")
        collectBtn.disabled = true
    }
    collectBtn.onclick = function () {
        const authorDiv = card.querySelector('.bili-video-card__info--author');
        const titleLink = card.querySelector('.bili-video-card__info--tit a');
        const img = card.querySelector('.v-img img');
        collectBtn.innerHTML = "已收藏"
        collectBtn.classList.add("collected")
        collectBtn.disabled = true
        getItem("localCollect").then((data) => {
            if(!data || !data instanceof Array) {
               data = []
            }
            data.push({
                title: titleLink.innerHTML,
                imageUrl: img.src,
                videoUrl: titleLink.href,
                up: authorDiv.innerHTML
            })
            setItem('localCollect', data)
        })
    }
}

function searchCollect(collectBtn, card) {
    if(collects.find(item => isSameVideo(item.videoUrl, card.querySelector('.bili-video-card__info--right a').href))) {
        collectBtn.innerHTML = "已收藏"
        collectBtn.classList.add("collected")
        collectBtn.disabled = true
    }
    collectBtn.onclick = function () {
        const authorDiv = card.querySelector('.bili-video-card__info--author');
        const titleLink = card.querySelector('.bili-video-card__info--tit a');
        const img = card.querySelector('.v-img img');
        collectBtn.innerHTML = "已收藏"
        collectBtn.classList.add("collected")
        collectBtn.disabled = true
        getItem("localCollect").then((data) => {
            if(!data || !data instanceof Array) {
               data = []
            }
            data.push({
                title: titleLink.title,
                imageUrl: img.src,
                videoUrl: titleLink.href,
                up: authorDiv.innerHTML
            })
            setItem('localCollect', data)
        })
    }
}
function embedCollectBtn() {
    let cards = document.querySelectorAll('.bili-video-card:not(.embed-btn)');
    if (cards && cards.length > 0) {
        cards.forEach(card => {
            if (!card.classList.contains('embed-btn')) {
                card.classList.add('embed-btn');
                const cardBottom = card.querySelector(".bili-video-card__info--bottom ")
                if (cardBottom) {
                    let collectBtn = document.createElement('button');
                    collectBtn.classList.add('local-collect-btn');
                    collectBtn.innerHTML = '收藏';
                    // 按钮在卡片右上角
                    cardBottom.appendChild(collectBtn);
                    if(window.location.href.includes("https://search.bilibili.com/")) {
                        searchCollect(collectBtn, card)
                    } else {
                        normalCollect(collectBtn, card)
                    }
                   
                }

            }
        });
    }
}

function clearEmbedCollectBtn() {
    let cards = document.querySelectorAll('.bili-video-card.embed-btn');
    if (cards && cards.length > 0) {
        cards.forEach(card => {
            const collectBtn = card.querySelector('.local-collect-btn');
            if (collectBtn) {
                collectBtn.remove();
            }
            card.classList.remove('embed-btn');
        });
    }
}


function toogleLocalCollect(enabled) {
    if(enabled) {
        getItem("localCollect").then(data => {
            collects = data || [];
            interval = setInterval(() => {
                embedCollectBtn();
            }, 1000)
        })
       
    } else {
        clearInterval(interval)
        clearEmbedCollectBtn();
    }
}

// Listen for message
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.type === 'LOCAL_COLLECT') {
      if (request.payload && request.payload.localCollect) {
        toogleLocalCollect(true)
      } else {
        toogleLocalCollect(false)
      }
      sendResponse({});
      return true;
    }
  });
  
  getItem("switches").then(result => {
    if(result) {
        toogleLocalCollect(result.localCollect)
    }
  })