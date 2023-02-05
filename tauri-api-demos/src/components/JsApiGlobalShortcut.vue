<script setup>
import { onMounted, reactive, ref } from "vue";
import { ElMessage } from "element-plus";
import { appWindow } from "@tauri-apps/api/window";

import { register } from "@tauri-apps/api/globalShortcut";

const shortcuts = [
  {
    name: "隐藏窗口",
    sc: "CmdOrControl+Shift+H",
  },
  {
    name: "展示窗口",
    sc: "CmdOrControl+Shift+S",
  },
];
onMounted(async () => {
  await register("CmdOrControl+Shift+H", async () => {
    await appWindow.hide();
  });
  await register("CmdOrControl+Shift+S", async () => {
    await appWindow.show();
  });
});
</script>

<template>
  <el-table :data="shortcuts" style="width: 100%" stripe border>
    <el-table-column prop="name" label="动作" width="180" />
    <el-table-column prop="sc" label="快捷键" />
  </el-table>
</template>

<style scoped></style>
