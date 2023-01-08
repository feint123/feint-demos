<script setup>
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import JsApiApp from "./components/JsApiApp.vue";
import JsApiClipboard from "./components/JsApiClipboard.vue";
import JsApiDialog from "./components/JsApiDialog.vue";
import JsApiFs from "./components/JsApiFs.vue";
import { onMounted, ref } from "vue";
import JsApiPath from "./components/JsApiPath.vue";
import JsApiHttp from "./components/JsApiHttp.vue";
import JsApiNotification from "./components/JsApiNotification.vue";
import JsApiOs from "./components/JsApiOs.vue";
import JsApiWindow from "./components/JsApiWindow.vue";
import JsApiGlobalShortcut from "./components/JsApiGlobalShortcut.vue";
const activeName = ref("app");
</script>

<template>
  <div class="container">
    <el-tabs type="border-card" v-model="activeName" class="js-api-tabs">
      <el-tab-pane label="App" name="app">
        <JsApiApp />
      </el-tab-pane>
      <el-tab-pane label="Clipboard" name="clipboard">
        <JsApiClipboard />
      </el-tab-pane>
      <el-tab-pane label="Dialog" name="dialog">
        <JsApiDialog />
      </el-tab-pane>
      <el-tab-pane label="Path" name="path">
        <JsApiPath />
      </el-tab-pane>
      <el-tab-pane label="FS" name="fs">
        <JsApiFs />
      </el-tab-pane>
      <el-tab-pane label="Http" name="http">
        <JsApiHttp />
      </el-tab-pane>
      <el-tab-pane label="Notification" name="notification">
        <JsApiNotification />
      </el-tab-pane>
      <el-tab-pane label="GlobalShortcut" name="globalshortcut">
        <JsApiGlobalShortcut />
      </el-tab-pane>
      <el-tab-pane label="OS" name="os">
        <JsApiOs />
      </el-tab-pane>
      <el-tab-pane label="Window" name="window">
        <JsApiWindow />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<style scoped>
.container {
  padding-top: 0;
  user-select: none;
}
</style>
