<script setup>
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup


import { useDark } from "@vueuse/core";
import Clipboard from '../../components/Clipboard.vue';
import NomalPanel from '../../components/NomalPanel.vue';
import { listen, TauriEvent } from '@tauri-apps/api/event';

import { shortcuts } from '../../assets/js/shortcuts';
import { reactive, onMounted, onUnmounted } from "vue";

import { appWindow } from '@tauri-apps/api/window';

useDark()

const unListens = reactive({
  blur: () => { },
})
onMounted(async () => {
  try {
    unListens.blur = await listen(TauriEvent.WINDOW_BLUR, async (event) => {
      if (event.windowLabel == 'qcb') {
        appWindow.hide();
      }
    });
    // 装载快捷键
    shortcuts();
  } catch (e) {
    console.error(e)
  }
})

onUnmounted(() => {
  unListens.blur();
})

</script>

<template>

  <NomalPanel>
    <template #header>
      <span data-tauri-drag-region>快捷剪切板</span>
    </template>
    <template #main>
      <Clipboard :card-title="false" size="small" />
    </template>
  </NomalPanel>
</template>

<style scoped>
:deep() .el-header {
  justify-content: center;
}

:deep() .el-card {
  --clip-card-height: 100px;
}

:deep() .el-main {
  overflow-x: hidden;
}
</style>
