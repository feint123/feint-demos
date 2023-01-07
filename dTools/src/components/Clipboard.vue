<script setup>
import { onMounted, defineProps, ref, onUnmounted } from "vue";
import { selectAllClips, deleteClipsById, closeDb, selectClipsByMd5 } from '../assets/js/db';
import { copied, paste, insertClipContent, isColor, insertToClipArr } from "../assets/js/tools";
import { useArrayFilter, useIntervalFn } from "@vueuse/shared";
import ClipCard from '../components/ClipCard.vue'

// const props = defineProps(["card-title"])
const props = defineProps({
    "card-title": {
        type: Boolean,
        default: true,
        require: false,
    },
    "size": {
        type: String,
        default: "default"
    }
})

const clipHistories = ref([])

function load() {
    selectAllClips((result) => {
        insertToClipArr(result.reverse(), clipHistories)
    })
}


function removeClip(id) {
    deleteClipsById(id, (result) => {
        clipHistories.value = useArrayFilter(clipHistories, val => val.id != id).value;
    })
}


useIntervalFn(async () => {
    // 获取剪切板的内容
    const clipboard = await paste();
    // 入库
    insertClipContent(clipboard.content, clipboard.md5, clipboard.type, (res) => {
        if (res) {
            // reload clipboard
            selectClipsByMd5(clipboard.md5, (result) => {
                // console.log(result);
                clipHistories.value = useArrayFilter(clipHistories, val => val.id != result[0].ID).value;
                insertToClipArr(result, clipHistories);
            })
        }
    });

}, 1000);


onMounted(async () => {
    load();
})

onUnmounted(() => {
    closeDb();
})

</script>

<template>

    <el-space wrap :size="props.size" style="justify-content:center">
        <div v-for="history in clipHistories" placement="top">
            <ClipCard :card-title="props.cardTitle" :model="history" @delete="removeClip(history.id)" :text-line="5"/>
        </div>
    </el-space>
</template>
<style scoped>

</style>

