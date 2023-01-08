<script setup>
import { onMounted, onUnmounted, onUpdated, reactive, ref } from "vue";
import { appWindow, LogicalSize } from "@tauri-apps/api/window";
import { ElMessage } from "element-plus";
import { listen, TauriEvent } from "@tauri-apps/api/event";
import { useDark, useToggle } from "@vueuse/core";

const windowInfoes = reactive({
  factor: 0,
  position: { x: 0, y: 0 },
  size: { width: 0, height: 0 },
  logicPos: { x: 0, y: 0 },
  logicSize: { width: 0, height: 0 },
});

const isDark = useDark();

const isTop = ref(false);
const isDecor = ref(true);
const isFullscreen = ref(false);
const isResize = ref(true);
const isDarkTheme = ref(false);

const unListens = reactive({
  resize: () => { },
  moved: () => { },
  scale: () => { },
  theme: () => { },
});
onMounted(async () => {
  // 设置窗口最小尺寸
  await appWindow.setMinSize(new LogicalSize(800, 600));
  isDarkTheme.value = "dark" === (await appWindow.theme());
  windowInfoes.factor = await appWindow.scaleFactor();
  windowInfoes.position = await appWindow.innerPosition();
  windowInfoes.size = await appWindow.innerSize();
  windowInfoes.logicPos = windowInfoes.position.toLogical(windowInfoes.factor);
  windowInfoes.logicSize = windowInfoes.size.toLogical(windowInfoes.factor);

  unListens.resize = await listen(TauriEvent.WINDOW_RESIZED, async (event) => {
    windowInfoes.size = await appWindow.innerSize();
    windowInfoes.logicSize = windowInfoes.size.toLogical(windowInfoes.factor);
  });

  unListens.moved = await listen(TauriEvent.WINDOW_MOVED, async (event) => {
    windowInfoes.position = await appWindow.innerPosition();
    windowInfoes.logicPos = windowInfoes.position.toLogical(
      windowInfoes.factor
    );
  });

  unListens.scale = await listen(
    TauriEvent.WINDOW_SCALE_FACTOR_CHANGED,
    async (event) => {
      windowInfoes.factor = await appWindow.scaleFactor();
    }
  );

  unListens.theme = await listen(
    TauriEvent.WINDOW_THEME_CHANGED,
    async (event) => {
      if ("light" === event.payload) {
        isDarkTheme.value = false;
      } else {
        isDarkTheme.value = true;
      }
    }
  );
});

onUnmounted(() => {
  unListens.resize();
  unListens.moved();
  unListens.scale();
  unListens.theme();
});

async function centerWindow() {
  await appWindow.center();
}

async function closeWindow() {
  await appWindow.close();
}

async function maximizeWindow() {
  await appWindow.maximize();
}

async function minimizeWindow() {
  await appWindow.minimize();
}

async function updateAlwaysOnTop(val) {
  await appWindow.setAlwaysOnTop(val);
}

async function updateDecorations(val) {
  await appWindow.setDecorations(val);
}

async function updateFullscreen(val) {
  await appWindow.setFullscreen(val);
}

async function updateResize(val) {
  await appWindow.setResizable(val);
}
</script>

<template>
  <el-descriptions title="" direction="horizontal" :column="3" :size="size" border>
    <el-descriptions-item label="窗口缩放">
      {{ windowInfoes.factor }}
    </el-descriptions-item>
    <el-descriptions-item label="位置">
      {{ windowInfoes.position.x }}, {{ windowInfoes.position.y }}
    </el-descriptions-item>
    <el-descriptions-item label="尺寸">
      {{ windowInfoes.size.width }}, {{ windowInfoes.size.height }}
    </el-descriptions-item>
    <el-descriptions-item label="逻辑位置">
      {{ windowInfoes.logicPos.x }}, {{ windowInfoes.logicPos.y }}
    </el-descriptions-item>
    <el-descriptions-item label="逻辑尺寸" :span="2">
      {{ windowInfoes.logicSize.width }}, {{ windowInfoes.logicSize.height }}
    </el-descriptions-item>
    <el-descriptions-item label="窗口操作" :span="3">
      <el-button type="primary" @click="centerWindow" plain>局中</el-button>
      <el-button type="danger" @click="closeWindow" plain>关闭</el-button>
      <el-button type="primary" @click="maximizeWindow" plain>最大化</el-button>
      <el-button type="primary" @click="minimizeWindow" plain>最小化</el-button>
    </el-descriptions-item>
    <el-descriptions-item label="窗口置顶">
      <el-switch v-model="isTop" @change="updateAlwaysOnTop" inline-prompt style="margin-left: 8px" active-text="是"
        inactive-text="否" />
    </el-descriptions-item>
    <el-descriptions-item label="窗口装饰">
      <el-switch v-model="isDecor" @change="updateDecorations" inline-prompt style="margin-left: 8px" active-text="是"
        inactive-text="否" />
    </el-descriptions-item>
    <el-descriptions-item label="全屏">
      <el-switch v-model="isFullscreen" @change="updateFullscreen" inline-prompt style="margin-left: 8px"
        active-text="是" inactive-text="否" />
    </el-descriptions-item>
    <el-descriptions-item label="调整尺寸">
      <el-switch v-model="isResize" @change="updateResize" inline-prompt style="margin-left: 8px" active-text="是"
        inactive-text="否" />
    </el-descriptions-item>
    <el-descriptions-item label="主题">
      <el-switch v-model="isDarkTheme" inline-prompt style="margin-left: 8px" active-text="黑暗" inactive-text="明亮"
        disabled />
    </el-descriptions-item>
  </el-descriptions>
</template>

<style scoped>
.el-tag {
  margin-left: 20px;
}
</style>
