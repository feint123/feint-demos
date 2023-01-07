<script setup>
import {platformStyle} from '../assets/js/styles'

const { headerStyle, innerMainStyle } = platformStyle();

</script>

<template>
    <el-container>
        <el-header :style="headerStyle" data-tauri-drag-region class="unselectable">
            <slot name="header"></slot>
        </el-header>
        <el-main class="unselectable" :style="innerMainStyle">
            <slot name="main"></slot>
        </el-main>

    </el-container>
</template>

<style scoped>


.el-main {
    background-color: var(--el-bg-color);
}

.el-header {
    background-color: var(--el-fill-color-light);
    padding: 0px;
}


</style>