<script setup>
import { Close } from '@element-plus/icons-vue';
import { copied, isColor, perferColor } from "../assets/js/tools";

// const props = defineProps(["card-title"])
const props = defineProps({
    "model": Object,
})


function copyContent(content, type) {
    copied(content, type, true);
}


</script>

<template>
    <el-card shadow="never" @click="copyContent(props.model.hexColor, 1)">
        <div style="height: 100%; justify-content: center;">
            <div class="card-content" :style="{ 'background-color': props.model.hexColor, 'color': perferColor(props.model.hexColor)}">
                <span class="color-text">{{ props.model.cnName }}  <small>{{ props.model.enName }}</small> </span>  
            </div>
        </div>
    </el-card>
</template>
<style scoped>
.color-text{
    align-self: center;
    font-size: medium;
    filter: grayscale(1) contrast(999) invert(1);
    word-wrap: break-word;
    display: -webkit-box;
    -webkit-box-orient: vertical;
    word-wrap: break-word;
    width: 134px;
}

.card-content {
    height: 34px;
    display: flex;
    justify-content: flex-start;
    padding: 8px;
    width: 100%;
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--clip-card-header-padding);
    height: var(--clip-card-header-height);
}

.el-card {
    --el-card-padding: 0;
    width: 150px;
    height: 50px;
    border: none;
    border-radius: 0;
}
</style>

