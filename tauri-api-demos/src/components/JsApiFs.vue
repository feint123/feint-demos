<script setup>
import { onMounted, reactive, ref } from "vue";
import { open, save } from "@tauri-apps/api/dialog";
import {
  readBinaryFile,
  BaseDirectory,
  copyFile,
  readDir,
  writeTextFile,
  writeBinaryFile,
  exists,
} from "@tauri-apps/api/fs";
import { appDataDir, downloadDir, basename, join } from "@tauri-apps/api/path";
import { getClient, ResponseType } from "@tauri-apps/api/http";

import { Files } from "@element-plus/icons-vue";
import { ElMessage } from "element-plus";

const fileCopyForm = reactive({
  sourceFile: "",
  targetDir: "",
});

const writeFileForm = reactive({
  text: "",
});

const activeNames = ref("copyFile");
const readImgSrc = ref("");
const dirFiles = ref([]);
const loading = ref(true);

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
    const content = await readBinaryFile(selected);
    // console.log(content)
    readImgSrc.value = URL.createObjectURL(
      new Blob([content.buffer], { type: "image/png" })
    );
  }
}

async function chooseSourceFile() {
  // Open a selection dialog for directories
  const selected = await open({
    directory: false,
    multiple: false,
    defaultPath: await downloadDir(),
  });
  if (Array.isArray(selected)) {
  } else if (selected === null) {
  } else {
    fileCopyForm.sourceFile = selected;
  }
}

async function chosseTargetDir() {
  // Open a selection dialog for directories
  const selected = await open({
    directory: true,
    multiple: false,
    defaultPath: await downloadDir(),
  });
  if (Array.isArray(selected)) {
  } else if (selected === null) {
  } else {
    fileCopyForm.targetDir = selected;
  }
}

async function copyFileDemo() {
  const sourceBaseName = await basename(fileCopyForm.sourceFile);
  const targetFile = await join(fileCopyForm.targetDir, sourceBaseName);
  copyFile(fileCopyForm.sourceFile, targetFile)
    .then(() => {
      ElMessage({
        message: "文件复制成功",
        type: "success",
      });
    })
    .catch((reason) => {
      ElMessage({
        message: "文件复制失败：" + reason,
        type: "error",
      });
    });
}

async function readDirDemo() {
  const downloadD = await downloadDir();
  // 需要在 tauri.conf.json 中配置 fs scope
  readDir("", { dir: BaseDirectory.Download, recursive: true })
    .catch((reason) => {
      ElMessage({
        message: "目录读取失败：" + reason,
        type: "error",
      });
    })
    .then((entries) => {
      dirFiles.value = [{ label: downloadD, children: [] }];
      processEntries(entries, dirFiles.value[0]);
      loading.value = false;
    });
}

async function processEntries(entries, root) {
  for (const entry of entries) {
    // const name =  await basename(entry.path);
    const node = {
      label: entry.name,
      children: [],
    };
    if (entry.children) {
      processEntries(entry.children, node);
    }
    root.children.push(node);
  }
}

async function saveFileDialog() {
  const savePath = await save({
    filters: [
      {
        name: "Text",
        extensions: ["txt"],
      },
    ],
  });
  if (savePath.length == 0) {
    return;
  }
  // 写文本文件
  writeTextFile({ path: savePath, contents: writeFileForm.text })
    .catch((reason) => {
      ElMessage({
        message: "保存文件失败：" + reason,
        type: "error",
      });
    })
    .then(() => {
      ElMessage({
        message: "保存文件成功",
        type: "success",
      });
    });
}

async function saveBinaryFile() {
  const client = await getClient();
  const response = await client.get(
    "https://tauri.app/meta/tauri_logo_light.svg",
    {
      responseType: ResponseType.Binary,
    }
  );

  writeBinaryFile("tauri.svg", response.data, { dir: BaseDirectory.Download })
    .catch((reason) => {
      ElMessage({
        message: "保存图片失败：" + reason,
        type: "error",
      });
    })
    .then(async () => {
      const downloadD = await downloadDir();
      const savePath = await join(downloadD, "tauri.svg");
      ElMessage({
        message: "保存图片成功：" + savePath,
        type: "success",
      });
    });
}

const defaultProps = {
  children: "children",
  label: "label",
};

function handleChange(name) {
  if ("readDir" == name) {
    loading.value = true;
    readDirDemo();
  } else {
    dirFiles.value = [];
  }
}
</script>

<template>
  <el-collapse v-model="activeNames" @change="handleChange" accordion>
    <el-collapse-item title="复制文件" name="copyFile">
      <el-form :inline="true" :model="fileCopyForm">
        <el-form-item>
          <el-input v-model="fileCopyForm.sourceFile" placeholder="选择文件">
            <template #prepend>
              <el-button :icon="Files" @click="chooseSourceFile" />
            </template>
          </el-input>
        </el-form-item>
        <el-form-item>
          <el-input v-model="fileCopyForm.targetDir" placeholder="选择目录">
            <template #prepend>
              <el-button :icon="Files" @click="chosseTargetDir" />
            </template>
          </el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="copyFileDemo" plain>复制</el-button>
        </el-form-item>
      </el-form>
    </el-collapse-item>
    <el-collapse-item title="读取二进制文件" name="readBinaryFile">
      <el-container>
        <el-card>
          <template #header>
            <div class="card-header">
              <el-button type="primary" @click="openFileDialog" plain>选择图片</el-button>
            </div>
          </template>
          <el-image style="width: 100px; height: 100px" :src="readImgSrc" fit="cover"></el-image>
        </el-card>
      </el-container>
    </el-collapse-item>
    <el-collapse-item title="读取目录" name="readDir">
      <el-tree v-loading="loading" :data="dirFiles" :props="defaultProps" />
    </el-collapse-item>
    <el-collapse-item title="写文件" name="writeFile">
      <el-form :model="writeFileForm">
        <el-form-item label="文本">
          <el-input v-model="writeFileForm.text" type="textarea" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :disabled="writeFileForm.text.trim() == ''" @click="saveFileDialog"
            plain>保存</el-button>
        </el-form-item>
        <el-form-item>
          <el-image style="width: 200px; height: 100px" src="https://tauri.app/meta/tauri_logo_light.svg" fit="fill" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="saveBinaryFile" plain>保存图片</el-button>
        </el-form-item>
      </el-form>
    </el-collapse-item>
  </el-collapse>
</template>

<style scoped>

</style>
