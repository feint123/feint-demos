<script setup>
import { Close } from '@element-plus/icons-vue';
import { copied, isColor, perferColor } from "../assets/js/tools";

// const props = defineProps(["card-title"])
const props = defineProps({
    "card-title": {
        type: Boolean,
        default: true,
    },
    "model": Object,
    "text-line": {
        type: Number,
        default: 4,
    }
})

const emits = defineEmits(["delete"])


async function copyContent(content, type) {
    copied(content, type);
}


</script>

<template>

    <el-card shadow="never">
        <template #header v-if="props.cardTitle">
            <div class="card-header">
                <el-tag type="info" effect="plain" style="border:none; background-color: var(--el-fill-color-light);">{{ props.model.timestamp }}</el-tag>
                <el-button @click="emits('delete')" :icon="Close" type="danger" size="small" round text />
            </div>
        </template>
        <div @click="copyContent(props.model.content, props.model.type)" 
        :style="{ height: props.cardTitle ? `calc(var(--clip-card-height) - var(--clip-card-header-height) - var(--clip-card-header-padding)*2)`:`calc(var(--clip-card-height) `, width:'100%'}">
            <div v-if="props.model.type == 1" style="height: 100%; display: flex; justify-content: center;">
                <div v-if="isColor(props.model.content)" class="card-content"
                    :style="{ 'background-color': props.model.content, 'color': perferColor(props.model.content) }">
                    <span class="color-text">{{ props.model.content }}</span>
                </div>
                <span v-else class="multi-text" :style="{'-webkit-line-clamp': props.textLine, 'align-self':'center'}">{{ props.model.content }}</span>
            </div>
            <div v-if="props.model.type == 2" class="card-content">
                <el-image :src="props.model.imgUrl" fit="cover" style="width: 100%;"></el-image>
            </div>
        </div>
    </el-card>
</template>
<style scoped>
.card-content .color-text {
    align-self: center;
    font-size: large;
    font-weight: bold;
    filter: grayscale(1) contrast(999) invert(1)
}

.card-content {
    height: 100%;
    width: 100%;
    display: flex;
    justify-content: center;
    filter: var(--dt-brightness);
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--clip-card-header-padding);
    height: var(--clip-card-header-height);
}

.multi-text {
    display: -webkit-box;
    overflow: hidden;
    text-overflow: ellipsis;
    -webkit-box-orient: vertical;
    word-break: break-all;
    word-wrap: break-word;
    overflow: hidden;
    margin: 20px;
    user-select: text;
    font-size: var(--el-font-size-small);
}

.el-card {
    --el-card-padding: 0;
    width: 300px;
    height: var(--clip-card-height);   
    background-color: var(--el-fill-color-light);
}

</style>

