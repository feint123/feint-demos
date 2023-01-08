<script setup>
import { ref } from "vue";
import { ask, confirm, message, open, save } from "@tauri-apps/api/dialog";
import { appDataDir } from "@tauri-apps/api/path";

const dialogs = ref([
  {
    title: "Ask",
    fn: ask,
  },
  {
    title: "Confirm",
    fn: confirm,
  },
  {
    title: "Message",
    fn: message,
  },
]);

async function infoDialog(dialog) {
  await dialog("你确定吗？", { title: "Tauri", type: "info" });
}

async function warningDialog(dialog) {
  await dialog("你确定吗？", { title: "Tauri", type: "warning" });
}

async function errorDialog(dialog) {
  await dialog("你确定吗？", { title: "Tauri", type: "error" });
}

const fileName = ref("");

async function openFileDialog() {
  // Open a selection dialog for directories
  const selected = await open({
    directory: false,
    multiple: false,
    filters: [
      {
        name: "Image",
        extensions: ["png", "jpg", "jpeg"],
      },
    ],
    defaultPath: await appDataDir(),
  });
  if (Array.isArray(selected)) {
  } else if (selected === null) {
  } else {
    fileName.value = selected;
  }
}
const savePath = ref("");
async function saveFileDialog() {
  savePath.value = await save({
    filters: [
      {
        name: "Image",
        extensions: ["png", "jpeg"],
      },
      {
        name: "Text",
        extensions: ["txt"],
      },
    ],
  });
}
</script>

<template>
  <el-descriptions title="" direction="horizontal" :column="1" :size="size" border>
    <el-descriptions-item v-for="dialog in dialogs" :label="dialog.title">
      <el-button type="info" @click="infoDialog(dialog.fn)" plain>
        Info
      </el-button>
      <el-button type="warning" @click="warningDialog(dialog.fn)" plain>Warning</el-button>
      <el-button type="danger" @click="errorDialog(dialog.fn)" plain>Error</el-button>
    </el-descriptions-item>
    <el-descriptions-item label="Open" :span="2">
      <el-button type="primary" @click="openFileDialog" plain>选择图片</el-button>
      <el-tag v-if="fileName.trim() != ''">{{ fileName }}</el-tag>
    </el-descriptions-item>
    <el-descriptions-item label="Save" :span="2">
      <el-button type="primary" @click="saveFileDialog" plain>保存文件</el-button>
      <el-tag v-if="savePath.trim() != ''">{{ savePath }}</el-tag>
    </el-descriptions-item>
  </el-descriptions>
</template>

<style scoped>
.el-tag {
  margin-left: 20px;
}
</style>
