<script setup lang="ts">
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import Greet from "./components/Greet.vue";
import { appWindow } from '@tauri-apps/api/window';
import { listen, TauriEvent } from '@tauri-apps/api/event';
import { onMounted, onUnmounted, reactive } from "vue";


const unListens = reactive({
    blur: () => { },
})

onMounted(async () => {
    unListens.blur = await listen(TauriEvent.WINDOW_BLUR, async (event) => {
        if (event.windowLabel == 'main') {
            appWindow.hide();
        }
    });
})
onUnmounted(() => {
    unListens.blur();
})
</script>

<template>
    <el-container class="unselectable">
        <el-main>
            <Greet />
        </el-main>
    </el-container>

</template>

<style scoped>
.el-main {
    padding: 8px;
}
</style>
