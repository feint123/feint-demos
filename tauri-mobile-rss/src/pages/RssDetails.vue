<script setup>
import { onMounted, onBeforeMount, ref } from 'vue';
import { selectRSSItemById } from '../scripts/db';
import AudioPlayer from '../components/AudioPlayer.vue'
import { f7Page, f7Navbar, f7, f7Block, f7NavTitle, f7NavRight, f7Link, f7Icon } from 'framework7-vue';
const description = ref("");
const title = ref("");
const audioUrl = ref("")
const link = ref("")
setTimeout(() => {
    let id = f7.view.current.router.currentRoute.query.id
    console.log("id", id)
    selectRSSItemById(f7.view.current.router.currentRoute.query.id).then(items => {
        console.log("finished select")
        console.log(items)
        if (items && items.length == 1) {
            let rssItem = items[0]
            description.value = rssItem.description
            title.value = rssItem.title
            link.value = rssItem.link.replace("http://","https://")
            console.log("rssItem", rssItem)
            if (rssItem.enclosure) {
                console.log("enclosure", rssItem.enclosure)
                audioUrl.value = JSON.parse(rssItem.enclosure).url
            }
        }
    }).catch(e => {
        console.log("query rss detail error", e)
    })
}, 100)

onMounted(() => {
    let darkMode = f7.darkMode
    document.documentElement.classList.toggle('dark', darkMode)
})

function shareLink() {
    navigator.share({
        title: "来自Readers分享的文章",
        text: title.value,
        url: link.value,
    })
        .then(() => {
            console.log('Share completed successfuly')
        })
        .catch((error) => { console.log(`share failed: ${error}`) });
}

</script>

<template>
    <f7-page class="bg-white dark:bg-black">
        <f7-navbar back-link="返回">
            <f7-nav-title>详情</f7-nav-title>
            <f7-nav-right>
                <f7-link @click="shareLink"><f7-icon f7="square_arrow_up"></f7-icon></f7-link>
            </f7-nav-right>
        </f7-navbar>
        <div class="title border-l-8 dark:border-red-800 border-red-500 px-4 my-4 text-xl font-extrabold break-words">{{
                    title }}
        </div>
        <div v-html="description" class="container p-2 px-4">
        </div>
        <!-- <f7-block v-if="audioUrl && audioUrl.length > 0" class="place-content-center">
            <audio controls autoplay>
                <source :src="audioUrl.replace('http://', 'https://')" type="audio/mpeg">
                您的浏览器不支持audio标签，请升级您的浏览器。
            </audio>
        </f7-block> -->
    </f7-page>
</template>

<style scoped>
.container {
    @apply text-lg font-light break-words
}

.container:deep(p) {
    @apply mb-4 text-lg font-light break-words;
}

.container:deep(img) {
    @apply rounded-lg mb-4;
}

.container:deep(p img) {
    @apply mb-0;
}

.container:deep(h1),
.container:deep(h2),
.container:deep(h3),
.container:deep(h4),
.container:deep(h5),
.container:deep(h6) {
    @apply border-l-4 border-red-500 dark:border-red-800 pl-2 mt-2 mb-4 py-1 font-serif;
}

.container:deep(h6) {
    @apply text-base font-medium;
}

.container:deep(h5) {
    @apply text-base font-semibold;
}

.container:deep(h4) {
    @apply text-lg font-semibold;
}

.container:deep(h3) {
    @apply text-xl font-extrabold;
}

.container:deep(h2) {
    @apply text-2xl font-extrabold;
}

.container:deep(h1) {
    @apply text-3xl font-black;
}

.container:deep(ul) {
    @apply list-decimal list-inside;
}

.container:deep(li > p) {
    @apply text-base pl-2 font-extralight;
}

.container:deep(table) {
    @apply table-auto mb-4;
}

.container:deep(tr) {
    @apply first:dark:bg-gray-800 first:font-bold font-light text-base;
}

.container:deep(tr:nth-child(odd)) {
    @apply bg-gray-200 dark:bg-gray-800;
}

.container:deep(tr:nth-child(even)) {
    @apply bg-white dark:bg-black;
}

.container:deep(td) {
    @apply p-2 text-sm;
}

.container:deep(.card) {
    @apply flex dark:bg-gray-900 bg-gray-100 rounded-lg overflow-hidden max-w-sm w-full mx-auto;
}

.container:deep(.card-logo img) {
    @apply w-20 object-cover rounded-none rounded-l-lg;
}

.container:deep(.card-info) {
    @apply w-2/3 p-2 text-amber-600 text-sm;
}

.container:deep(dir) {
    padding: 0px;
}

.container:deep(.card-name) {
    @apply text-gray-900 dark:text-gray-300 truncate;
    display: block;
}

.container:deep(figcaption),
.container:deep(.img-desc) {
    @apply flex justify-center text-gray-500 text-xs mb-4;
    margin-top: -8px;
}

.container:deep(a) {
    @apply underline decoration-sky-500 dark:decoration-sky-800 decoration-4 font-medium font-mono;
}

.container:deep(.van-nav-bar__text) {
    @apply text-base;
}
</style>