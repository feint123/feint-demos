<script setup>
import { onMounted, reactive, ref } from "vue";
import "@tauri-apps/api/path";
import { ElMessage } from "element-plus";
import {
  appCacheDir,
  appConfigDir,
  appDataDir,
  appDir,
  appLocalDataDir,
  appLogDir,
  audioDir,
  basename,
  cacheDir,
  configDir,
  dataDir,
  desktopDir,
  dirname,
  documentDir,
  downloadDir,
  executableDir,
  extname,
  fontDir,
  homeDir,
  isAbsolute,
  join,
  localDataDir,
  logDir,
  normalize,
  pictureDir,
  publicDir,
  resolve,
  resolveResource,
  resourceDir,
  runtimeDir,
  templateDir,
  videoDir,
} from "@tauri-apps/api/path";

const defaultPaths = ref([]);
const pathOpt = reactive({
  originPath: "",
  baseName: "",
  extName: "",
  dirName: "",
  isAbsolute: false,
  joinPath: "",
  normalizePath: "",
  resolvePath: "",
});
const dynamicPaths = ref(["..", "test", ".", "abc.txt"]);
onMounted(async () => {
  getDirOrDefault("appCacheDir", appCacheDir());
  getDirOrDefault("appConfigDir", appConfigDir());
  getDirOrDefault("appDataDir", appDataDir());
  getDirOrDefault("appConfigDir", appConfigDir());
  getDirOrDefault("appDir", appDir());
  getDirOrDefault("appLocalDataDir", appLocalDataDir());
  getDirOrDefault("appLogDir", appLogDir());
  getDirOrDefault("audioDir", audioDir());
  getDirOrDefault("cacheDir", cacheDir());
  getDirOrDefault("configDir", configDir());
  getDirOrDefault("dataDir", dataDir());
  getDirOrDefault("desktopDir", desktopDir());
  getDirOrDefault("documentDir", documentDir());
  getDirOrDefault("downloadDir", downloadDir());
  getDirOrDefault("executableDir", executableDir());
  getDirOrDefault("fontDir", fontDir());
  getDirOrDefault("homeDir", homeDir());
  getDirOrDefault("localDataDir", localDataDir());
  getDirOrDefault("logDir", logDir());
  getDirOrDefault("pictureDir", pictureDir());
  getDirOrDefault("publicDir", publicDir());
  getDirOrDefault("resourceDir", resourceDir());
  getDirOrDefault("runtimeDir", runtimeDir());
  getDirOrDefault("templateDir", templateDir());
  getDirOrDefault("videoDir", videoDir());

  pathOpt.originPath = await resolveResource("app.config");
  pathOpt.baseName = await basename(pathOpt.originPath);
  pathOpt.extName = await extname(pathOpt.originPath);
  pathOpt.dirName = await dirname(pathOpt.originPath);
  pathOpt.isAbsolute = await isAbsolute(pathOpt.originPath);
  pathOpt.joinPath = await join(pathOpt.dirName, ...dynamicPaths.value);
  pathOpt.normalizePath = await normalize(
    pathOpt.dirName + "/" + dynamicPaths.value.join("/")
  );
  pathOpt.resolvePath = await resolve(pathOpt.dirName, ...dynamicPaths.value);
});

function getDirOrDefault(name, result) {
  result
    .then((value) => {
      defaultPaths.value.push({
        name: name,
        value: value,
      });
    })
    .catch((reason) => {
      defaultPaths.value.push({
        name: name,
        value: reason,
      });
    });
}
</script>

<template>
  <el-descriptions
    title=""
    direction="horizontal"
    :column="3"
    :size="size"
    border
  >
    <el-descriptions-item label="原始路径" :span="3">
      {{ pathOpt.originPath }}</el-descriptions-item
    >
    <el-descriptions-item label="文件名称">{{
      pathOpt.baseName
    }}</el-descriptions-item>
    <el-descriptions-item label="扩展名"
      ><el-tag>{{ pathOpt.extName }}</el-tag></el-descriptions-item
    >
    <el-descriptions-item label="绝对路径">{{
      pathOpt.isAbsolute
    }}</el-descriptions-item>
    <el-descriptions-item label="目录名称" :span="3">{{
      pathOpt.dirName
    }}</el-descriptions-item>
    <el-descriptions-item label="路径列表" :span="3">
      {{ pathOpt.dirName }}
      <el-tag v-for="tag in dynamicPaths" :key="tag" style="margin-right: 4px">
        /{{ tag }}
      </el-tag>
    </el-descriptions-item>
    <el-descriptions-item label="Join" :span="3">{{
      pathOpt.joinPath
    }}</el-descriptions-item>
    <el-descriptions-item label="Normalize" :span="3">{{
      pathOpt.normalizePath
    }}</el-descriptions-item>
    <el-descriptions-item label="Resolve" :span="3">{{
      pathOpt.resolvePath
    }}</el-descriptions-item>
  </el-descriptions>
  <br />
  <el-table :data="defaultPaths" style="width: 100%" stripe border>
    <el-table-column prop="name" label="目录名称" width="180" />
    <el-table-column prop="value" label="路径" />
  </el-table>
</template>

<style scoped></style>
