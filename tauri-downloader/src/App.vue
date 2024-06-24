<script setup>
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
import Greet from "./components/Greet.vue";
import { useOsTheme, darkTheme } from 'naive-ui'
import { computed, watch } from "vue";

import { NConfigProvider } from 'naive-ui'
const osThemeRef = useOsTheme();
let theme = computed(() => (osThemeRef.value === 'dark' ? darkTheme : null))
let osTheme = osThemeRef
function updateHtmlBackground(themeRef) {
  if (themeRef.value === 'dark') {
    document.body.style.backgroundColor = 'rgb(16, 16, 20)';
  } else {
    document.body.style.backgroundColor = '#fff';
  }
}

updateHtmlBackground(osThemeRef)

watch(osThemeRef, () => {
  updateHtmlBackground(osThemeRef)
})

document.body.style.userSelect = "none"; // 标准浏览器
document.body.style.MozUserSelect = "none"; // Firefox
document.body.style.WebkitUserSelect = "none"; // Chrome, Safari, Opera
document.body.style.msUserSelect = "none"; // IE, Edge


/**
 * js 文件下使用这个做类型提示
 * @type import('naive-ui').GlobalThemeOverrides
 */
const themeOverrides = {
  Dropdown: {
    borderRadius: '8px',
  }
  // ...
}
</script>

<template>
  <n-config-provider :theme="theme" style="height: 100%;" :theme-overrides="themeOverrides">
    <n-layout style="height: 100%;">
      <n-message-provider>
        <Suspense>
          <Greet />
        </Suspense>
      </n-message-provider>
    </n-layout>
  </n-config-provider>

</template>

<style scoped></style>
