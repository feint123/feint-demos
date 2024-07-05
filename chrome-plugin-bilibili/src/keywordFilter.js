
import { getItem } from "./storage";


let interval
let filters = []
function normalFilter(card) {
    const authorDiv = card.querySelector('.bili-video-card__info--author');
    const titleLink = card.querySelector('.bili-video-card__info--tit a');
    const title = titleLink ? titleLink.innerHTML : '';
    const up = authorDiv ? authorDiv.innerHTML : '';
    filterNode(card, title, up)
}

function liveNormalFilter(card) {
    const authorDiv = card.querySelector('.bili-live-card__info--author');
    const titleLink = card.querySelector('.bili-live-card__info--tit a');
    const title = titleLink ? titleLink.innerHTML : '';
    const up = authorDiv ? authorDiv.innerHTML : '';
    filterNode(card, title, up)
}
function searchFilter(card) {
    const authorDiv = card.querySelector('.bili-video-card__info--author');
    const titleLink = card.querySelector('.bili-video-card__info--tit a');
    const title = titleLink ? titleLink.title : '';
    const up = authorDiv ? authorDiv.innerHTML : '';
    filterNode(card, title, up)

}

/**
 * 
 * @param {HTMLElement} node 
 * @param {String} title 
 * @param {String} up 
 */
function filterNode(node, title, up) {
    filters.forEach(filter => {
        if (filter.type == 'title') {
            if (title.includes(filter.keyword)) {
                console.log(title)
                node.remove();
            }
        } else if (filter.type == 'up') {
            if (up === filter.keyword) {
                console.log(up)
                node.remove();
            }
        } else if (filter.type == 'ad') {
            const adSvg = node.querySelector('.bili-video-card__info--ad');
            if (adSvg) {
                node.remove();
            }
        } else if (filter.type == 'live') {
            if (node.classList.contains("bili-live-card") || node.querySelector(".living")) {
                node.remove();
            }
        }
    })
}
/**
 * 
 * @param {HTMLElement} floatCard 
 */
function floatNormalFilter(floatCard) {
    const titleDiv = floatCard.querySelector('.title')
    const title = titleDiv ? titleDiv.title : '';

    const upDiv = floatCard.querySelector('.sub-title')
    const up = upDiv ? upDiv.innerText : '';

    filterNode(floatCard, title, up)
}
function filterCards() {

    const feedCard = document.querySelectorAll('.feed-card:not(.keyword-filter');
    if (feedCard && feedCard.length > 0) {
        feedCard.forEach(card => {
            card.classList.add('keyword-filter');
            normalFilter(card)
        });
    }

    const cards = document.querySelectorAll('.bili-video-card:not(.keyword-filter');
    if (cards && cards.length > 0) {
        cards.forEach(card => {
            card.classList.add('keyword-filter');
            if (window.location.href.includes("https://search.bilibili.com/")) {
                searchFilter(card)
            } else {
                normalFilter(card)
            }

        });
    }

    const floatCards = document.querySelectorAll('.floor-single-card:not(.keyword-filter');
    if (floatCards && floatCards.length > 0) {
        floatCards.forEach(card => {
            card.classList.add('keyword-filter');
            floatNormalFilter(card)
        });
    }

    const liveCards = document.querySelectorAll('.bili-live-card:not(.keyword-filter');
    if (liveCards && liveCards.length > 0) {
        liveCards.forEach(card => {
            card.classList.add('keyword-filter');
            liveNormalFilter(card)
        });
    }

}

function clearFilterCards() {
    const cards = document.querySelectorAll('.keyword-filter');
    cards.forEach(card => {
        card.style.display = 'block';
        card.classList.remove('keyword-filter');
    })
}

let currentState = false
function toogleKeywordFilter(enabled) {
    currentState = enabled
    if (enabled) {
        getItem("keywordFilter").then(data => {
            filters = data || [];
            interval = setInterval(() => {
                filterCards();
            }, 1000)
        })

    } else {
        clearInterval(interval)
        clearFilterCards();
    }
}

// Listen for message
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.type === 'KEYWORD_FILTER') {
        if (request.payload && request.payload.keywordFilter) {
            toogleKeywordFilter(true)
        } else {
            toogleKeywordFilter(false)
        }
        sendResponse({});
        return true;
    } else if (request.type === 'UPDATE_KEYWORD' && currentState) {
        toogleKeywordFilter(false)
        toogleKeywordFilter(true)
        sendResponse({});
        return true;
    }
});

getItem("switches").then(result => {
    if (result) {
        toogleKeywordFilter(result.keywordFilter)
    }
})