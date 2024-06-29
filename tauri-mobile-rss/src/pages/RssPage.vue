<script setup>
import { computed, onBeforeMount, onMounted, ref, watch } from "vue";
import { invoke } from "@tauri-apps/api/core";
import moment from 'moment';
import { f7List, f7Page, f7Navbar, f7, f7BlockFooter, f7Block, f7Sheet, f7Preloader, f7NavLeft, f7NavTitle, f7Link, f7Icon, f7ListInput, f7Toolbar, f7Tab, f7Tabs } from "framework7-vue";
import { insertRSSItem, selectAllRSSItem } from "../scripts/db";

const list = ref([]);
const rssLink = ref("")
const isRssLinkValid = ref(false)
const lastUpdateTime = ref("")
const isSaveBtnAval = computed(() => {
    return rssLink.value != "" && isRssLinkValid.value;
});

async function readRSS(url) {
    console.log("readRSS", url);
    return new Promise((resolve, reject) => {
        invoke("request_rss", { url: url })
            .then(ch => {
                resolve(ch);
            }).catch(e => {
                reject(e);
            });
    });
}
onMounted(() => {
    onLoad();
})


const rssLinkList = ["https://www.ithome.com/rss/", "https://www.36kr.com/feed", "https://www.gcores.com/rss"]

async function refresh() {
    for (let urlIndex in rssLinkList) {
        try {
            let rss = await readRSS(rssLinkList[urlIndex])
            for (let index in rss.items) {
                let rssItem = rss.items[index];
                rssItem.rss_link = rss.link.replace('http://', 'https://')
                rssItem.pub_date = formatDate(rssItem.pub_date)
                try {
                    await insertRSSItem(rssItem);
                } catch (e) {
                    console.log("insert error", e);
                }
            }
        } catch (e) {
            console.log(e);
        }

    }
    localStorage.setItem("rssLastUpdate", new Date().getTime());
    lastUpdateTime.value = getFormatedLastUpdateTime();
    onLoad()

}


function getFormatedLastUpdateTime() {
    return formatLastUpdateTime(localStorage.getItem("rssLastUpdate"));
}

// 格式化上次跟新时间按照分钟，小时和天为单位 入 5分钟前，1个小时前 昨天 前天 5天前 这样子
function formatLastUpdateTime(lastUpdateTime) {
    if (!lastUpdateTime) {
        return "";
    }
    let now = new Date();
    let timeDiff = now.getTime() - lastUpdateTime;
    if (timeDiff < 60000) {
        return "刚刚";
    } else if (timeDiff < 3600000) {
        return Math.floor(timeDiff / 60000) + "分钟前";
    } else if (timeDiff < 86400000) {
        return Math.floor(timeDiff / 3600000) + "小时前";
    } else if (timeDiff < 172800000) {
        return "昨天";
    } else if (timeDiff < 259200000) {
        return "前天";
    } else {
        return Math.floor(timeDiff / 86400000) + "天前";
    }
}

function onLoad() {
    selectAllRSSItem().then(rssItems => {
        if (rssItems && rssItems.length > 0) {
            list.value = rssItems;
        } else {
            refresh();
        }
    }).catch(e => {
        console.log("select rss item from db", e);
    });
    // readRSS("https://www.ithome.com/rss/");
}

function onRefresh(done) {
    console.log("onRefresh")
    // readRSS("https://www.ithome.com/rss/");
    refresh();
    f7.toast.create({
        text: "加载完成🎉",
        position: 'top',
        closeTimeout: 2000,
    }).open();
    done();
}

function extractFirstImageUrl(htmlText) {
    const parser = new DOMParser();
    const doc = parser.parseFromString(htmlText, 'text/html');
    const imgElement = doc.querySelector('img');
    return imgElement ? imgElement.src : null;
}

function formatDate(dateStr) {
    let momentObj
    if (dateStr.includes("+0800")) {
        momentObj = moment(dateStr, "YYYY-MM-DD HH:mm:ss Z")
        if (!momentObj.isValid()) {
            momentObj = moment(dateStr)
        }
    } else {
        momentObj = moment(dateStr);
    }

    return momentObj.format("yyyy年MM月DD日 HH:mm");
}

function hasImage(content) {
    return content && content.includes('<img');
}

function goDetailPage(id) {
    f7.views.current.router.navigate({
        name: "details",
        path: '/details',
        query: {
            id: id
        }
    })

    // f7router.push({ path: '/details', query: { description: description, title: title } });
};

// onBeforeMount(() => {
//     console.log(f7.sheet)
// })
const tabs = [1, 2, 3]

</script>

<template>
    <!-- <f7-view url="/"> -->
    <f7-page hide-toolbar-on-scroll ptr :ptr-mousewheel="true" @ptr:refresh="onRefresh">
        <!-- Top Navbar-->
        <f7-navbar>
            <f7-nav-left>
                <f7-link panel-open="left"><f7-icon class="text-gray-600 dark:text-gray-300"
                        f7="ellipsis_vertical"></f7-icon></f7-link>
            </f7-nav-left>
            <f7-nav-title :subtitle="lastUpdateTime + '更新'">
                Readers
            </f7-nav-title>

        </f7-navbar>

        <f7-list v-if="list && list.length > 0" strong-ios class="p-2 mt-0">
            <div class="columns-2 gap-2 mt-2 select-none">
                <div v-for="item in list" class=" mb-2 rounded-lg break-inside-avoid-column"
                    @click="goDetailPage(item.id)">
                    <img v-if="hasImage(item.description)" :src="extractFirstImageUrl(item.description)" alt="封面图片"
                        class="rounded-t-lg max-h-52 w-full object-cover" />
                    <f7-block strong style="margin: 0px;"
                        :class="hasImage(item.description) ? 'p-2 rounded-b-lg' : 'p-2 rounded-lg'">
                        <p class="text-sm">{{ item.title }}</p>

                        <f7-block-footer class="text-xs">
                            <div class="flex">
                                <img class="rounded w-3.5 h-3.5 mr-2" :src="item.rss_link + '/favicon.ico'" />
                                <span>{{ item.pub_date }}</span>
                            </div>

                        </f7-block-footer>
                    </f7-block>
                </div>

            </div>
        </f7-list>
        <div v-else class="flex justify-center items-center h-full">
            <f7-preloader :size="42" />
        </div>



    </f7-page>
    <!-- </f7-view> -->

</template>

<style scoped></style>