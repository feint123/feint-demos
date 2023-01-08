<script setup>
import { onMounted, ref } from "vue";
import {
  getName,
  getTauriVersion,
  getVersion,
  hide,
  show,
} from "@tauri-apps/api/app";

const appName = ref("");
const tauriVersion = ref("");
const version = ref("");

onMounted(async () => {
  appName.value = await getName();
  tauriVersion.value = await getTauriVersion();
  version.value = await getVersion();
});

async function hideApp() {
  await hide();
}

async function showApp() {
  await show();
}
</script>

<template>
  <el-descriptions class="margin-top" :column="3" :size="size" border>
    <el-descriptions-item>
      <template #label>
        <div class="cell-item">App 名称</div>
      </template>
      {{ appName }}
    </el-descriptions-item>
    <el-descriptions-item>
      <template #label>
        <div class="cell-item">Tauri 版本</div>
      </template>
      <el-tag size="small">
        {{ tauriVersion }}
      </el-tag>
    </el-descriptions-item>
    <el-descriptions-item>
      <template #label>
        <div class="cell-item">App 版本</div>
      </template>
      <el-tag size="small">
        {{ version }}
      </el-tag>
    </el-descriptions-item>
    <el-descriptions-item>
      <template #label>
        <div class="cell-item">操作</div>
      </template>
      <el-button type="primary" @click="hideApp" plain>隐藏</el-button>
      <el-button type="success" @click="showApp" plain>展示</el-button>
    </el-descriptions-item>
  </el-descriptions>
</template>

<style scoped>

</style>
