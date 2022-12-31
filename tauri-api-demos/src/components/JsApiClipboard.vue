<script setup>
import { onMounted, reactive, ref } from "vue";
import {readText, writeText} from '@tauri-apps/api/clipboard';
import { ElMessage } from 'element-plus'

const form = reactive({
    clipboard: ''
});

async function paste() {
    form.clipboard = await readText();
}

async function copy() {
    await writeText(form.clipboard);
    ElMessage({
        message: '内容已复制到剪切板！',
        type: 'success',
    });
}

</script>

<template>
  <el-form :model="form">
    <el-form-item label="剪切板">
        <el-input v-model="form.clipboard" type="textarea" />
    </el-form-item>
    <el-form-item>
        <el-button @click="copy" plain>复制</el-button>
        <el-button @click="paste" plain>黏贴</el-button>
    </el-form-item>
  </el-form>
 
</template>

<style scoped>
</style>