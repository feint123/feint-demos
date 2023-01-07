<script setup>
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import { DocumentCopy, Reading, MagicStick, SwitchFilled, Search } from '@element-plus/icons-vue'
import { ref, reactive, onMounted, onUnmounted, computed } from 'vue'
// import { listen, TauriEvent } from '@tauri-apps/api/event';
// import { appWindow } from '@tauri-apps/api/window';
import { useRouter } from 'vue-router';
import { useDark, useIntervalFn } from "@vueuse/core";
import { closeDb } from '../../assets/js/db';
import { paste, insertClipContent } from '../../assets/js/tools'
import { platformStyle } from '../../assets/js/styles';
import { init } from '../../assets/js/init';
import { appWindow } from '@tauri-apps/api/window';



useDark()

const { innerAsideStyle, mainStyle, headerStyle, asideStyle, toggleAside, asideSwitchStyle } = platformStyle();
const router = useRouter();

const CLIP_MENU = '/cliphistory'
const selectedMenu = ref(CLIP_MENU)
const unListens = reactive({
  close: () => { },
})

router.push(CLIP_MENU);

onMounted(async () => {
  // 点击关闭窗口按钮只隐藏，不关闭
  unListens.close = appWindow.onCloseRequested(async (event) => {
    event.preventDefault();
    appWindow.hide();
  })
  init()
});

onUnmounted(async () => {
  closeDb();
  unListens.close();
})

useIntervalFn(async () => {
  // 防止在 clipboard 菜单时重复插入
  if (selectedMenu.value != CLIP_MENU) {
    // 全局更新剪切板内容
    const clipboard = await paste();
    insertClipContent(clipboard.content, clipboard.md5, clipboard.type, (result) => { });
  }
}, 1000);


function updateSelectMenu(index) {
  selectedMenu.value = index;
}

</script>

<template>

  <el-container>

    <!-- 菜单栏 -->
    <el-aside :style="asideStyle">
      <el-container>
        <el-header data-tauri-drag-region :style="headerStyle">
          <div class="toolbar-left" :style="asideSwitchStyle">
            <el-icon @click="toggleAside()" size="20">
              <SwitchFilled />
            </el-icon>
          </div>
        </el-header>
        <el-main :style="innerAsideStyle">
          <el-menu default-active="/cliphistory" class="unselectable" @select="updateSelectMenu" router>
            <el-menu-item index="/cliphistory">
              <el-icon>
                <DocumentCopy />
              </el-icon>
              剪切板历史
            </el-menu-item>
            <el-menu-item index="/colorss">
              <el-icon>
                <Reading />
              </el-icon>
              给点颜色看看
            </el-menu-item>
            <!-- <el-menu-item index="/cos">
              <el-icon>
                <Search />
              </el-icon>
              镜像大全
            </el-menu-item> -->
            <el-menu-item index="/code-translator">
              <el-icon>
                <MagicStick />
              </el-icon>
              编码转换
            </el-menu-item>
          </el-menu>

        </el-main>
      </el-container>
    </el-aside>

    <!-- 功能区 -->
    <el-main :style="mainStyle">
      <router-view></router-view>
    </el-main>


  </el-container>

</template>

<style scoped>
.el-aside {
  transition: 0.3s width ease;
}

.toolbar-left {
  transition: 0.3s left ease;
  z-index: 2000;
}

.el-header {
  border: none ;
  border-right: 1px solid var(--el-border-color-light);
}

.el-main {
  padding: 0px;
}

.el-menu {
  padding: 8px;
  background-color: rgba(0, 38, 39, 0);
  height: 100%;
}

.el-menu-item {
  height: 30px;
  margin-bottom: 4px;
}

.el-menu-item.is-active {
  background-color: rgb(27, 107, 199);
  color: #E5EAF3;
  font-weight: bold;
  border-radius: 5px;
}

.el-menu-item:hover {
  border-radius: 5px;
}
</style>
