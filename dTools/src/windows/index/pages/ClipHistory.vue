<script setup>
import { onMounted, onUnmounted, ref } from "vue";
import { Search } from '@element-plus/icons-vue';
import NomalPanel from '../../../components/NomalPanel.vue';
import Clipboard from '../../../components/Clipboard.vue';
import ClipCard from '../../../components/ClipCard.vue';
import { closeDb, selectClipsByKey } from '../../../assets/js/db';
import { isColor, insertToClipArr, copied } from "../../../assets/js/tools";
import { platformSize } from "../../../assets/js/styles";
import { computed } from "@vue/reactivity";
import { onClickOutside, useToggle, useWindowSize } from "@vueuse/core";

const showSearchDrawer = ref(false);
const { width, height } = useWindowSize()
const [searchFocused, toggle] = useToggle()
const { asideWidth } = platformSize();
const searchWidth = 400;
const searchOffset = computed(() => {
    return (width.value - asideWidth.value - searchWidth) / 2;
})
const drawerOffset = computed(() => {
    return (width.value + asideWidth.value - searchWidth) / 2;
})
const drawerStyle = computed(() => {
    return { width: "400px", "z-index": 100, left: `${drawerOffset.value}px` }
});

const searchFocusedStyle = computed(() => {
    return { width: "400px", right: `${searchOffset.value}px` }
});

const searchNormalStyle = {
    right: "20px", width: "250px"
}

const inputStyle = computed(() => {
    if (searchStatus.value) {
        return searchFocusedStyle.value;
    } else {
        return searchNormalStyle;
    }
})

const searchResults = ref([])
const searchKeywords = ref("")
const searchStatus = computed(() => {
    return searchFocused.value || showSearchDrawer.value
})
const target = ref(null)

function search(keyword) {
    searchResults.value = [];
    if (null != keyword && keyword.length > 0) {
        selectClipsByKey(keyword, (result) => {
            insertToClipArr(result, searchResults);
            showSearchDrawer.value = true;
        })
        searchKeywords.value = "";
    }
}

onMounted(async () => {
    onClickOutside(target, (event) => {
        showSearchDrawer.value = false;
    })
})

onUnmounted(()=> {
    closeDb();
})

</script>

<template>
    <NomalPanel>
        <template #header>
            <el-input v-model="searchKeywords" placeholder="请输入关键词" class="input-with-select" @change="search"
                @focus="searchFocused = true" @blur="searchFocused = false" :style="inputStyle" clearable
                :suffix-icon="Search" />
            <el-drawer v-model="showSearchDrawer" v-if="showSearchDrawer" title="I am the title" direction="ttb"
                size="450" :with-header="false" :style="drawerStyle" :modal="false" class="search-drawer" ref="target">
                <el-scrollbar>
                    <el-space wrap size="small" style="justify-content:center;">
                        <div v-for="history in searchResults" :timestamp="history.timestamp" placement="top">
                            <ClipCard :model="history" :card-title="false" :text-line="3" />
                        </div>
                    </el-space>
                </el-scrollbar>
            </el-drawer>
        </template>
        <template #main>
            <Clipboard />
        </template>
    </NomalPanel>
</template>


<style scoped>
:deep() .search-drawer {
    border-radius: 8px;
    top: var(--toolbar-height);
    background-color: var(--el-bg-color);
    transition: none;
}

:deep() .multi-text {
    margin: 8px;
}

.el-card {
    --el-card-padding: 0;
    width: 350px;
    --clip-card-height: 75px;
}

.el-input {
    z-index: 3000;
    background-color: var(--el-fill-color);
    transition: 0.3s width ease;
}
</style>

