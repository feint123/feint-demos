<!-- app.vue -->
<script setup>
import { onMounted, onBeforeMount,ref } from 'vue';
import { init } from './scripts/init';
import { f7, f7App, f7View, f7Navbar, f7Panel, f7Page, f7Block } from 'framework7-vue';
import { routes} from './routes'
import LeftPanelPage from './pages/LeftPanelPage.vue';
// import routes from './routes';
onMounted(() => {
  init();
})
// const components = {
//   f7App,
//   f7View
// }
const f7params = ref({
  name: "mobileRSS",
  theme: 'auto',
  routes: routes,
  darkMode: 'auto',
})
onBeforeMount(() => {
  document.body.style.height = `${window.outerHeight}px`;
  let darkMode = localStorage.getItem("appTheme")
  if (darkMode == "dark") {
    f7params.value.darkMode = true
  } else if (darkMode == "light") {
    f7params.value.darkMode = false
  } else {
    f7params.value.darkMode = 'auto'
  }
})
</script>

<template>

  <f7-app v-bind="f7params">
    <f7-panel left cover>
      <f7-view>
        <LeftPanelPage />
      </f7-view>
    </f7-panel>

    <f7-view main id="main">
    </f7-view>
  </f7-app>
</template>
<style scoped></style>
