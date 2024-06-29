<script setup>
import { onMounted, onBeforeMount, ref, watch } from 'vue';

import { f7Page, f7Navbar, f7, f7Link, f7List, f7ListItem, f7Toggle } from 'framework7-vue';

import { deleteAllRSSItems } from '../scripts/db'

const appTheme = ref("auto")
const autoClearCircle = ref(7)
onBeforeMount(() => {
    let cacheTheme = localStorage.getItem("appTheme")
    if (cacheTheme) {
        appTheme.value = cacheTheme
    }

})
watch(() => appTheme.value, (newVal, oldVal) => {
    localStorage.setItem("appTheme", newVal)
    if (newVal == "light") {
        f7.setDarkMode(false)
    } else if (newVal == "dark") {
        f7.setDarkMode(true)
    } else {
        f7.setDarkMode('auto')
    }
})

function clearCache() {
    deleteAllRSSItems().then(() => {
        f7.toast.create({
            text: "清理完成✌️",
            position: 'center',
            closeTimeout: 2000,
        }).open();
    })

}
</script>

<template>
    <f7-page>
        <f7-navbar back-link="返回" title="设置">

        </f7-navbar>
        <f7-list dividers-ios strong-ios inset>
            <f7-list-item title="主题" smart-select :smart-select-params="{ openIn: 'popover' }">
                <select name="appTheme" v-model="appTheme">
                    <option value="light" selected>明亮</option>
                    <option value="dark">黑暗</option>
                    <option value="auto">跟随系统</option>
                </select>
            </f7-list-item>
            <f7-list-item title="隐藏已读文章">
                <template #after>
                    <f7-toggle />
                </template>
            </f7-list-item>

            <f7-list-item title="无图模式">
                <template #after>
                    <f7-toggle />
                </template>
            </f7-list-item>
        </f7-list>
        <f7-block-footer class="ml-2">你可以自定义阅读体验</f7-block-footer>

        <f7-list dividers-ios strong-ios inset>
            <f7-list-item title="清理缓存" @click="clearCache" link="#">
            </f7-list-item>
            <f7-list-item title="自动清理" smart-select :smart-select-params="{ openIn: 'popover' }">
                <select name="autoClearCircle" v-model="autoClearCircle">
                    <option value="7" selected>一个星期</option>
                    <option value="14">两个星期</option>
                    <option value="30">一个月</option>
                </select>
            </f7-list-item>
        </f7-list>
        <f7-block-footer class="ml-2">管理Readers在你设备上的存储空间</f7-block-footer>

    </f7-page>
</template>

<style scoped></style>