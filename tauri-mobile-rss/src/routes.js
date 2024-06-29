import { createRouter, createWebHistory } from 'vue-router';
import RssPage from './pages/RssPage.vue';
import RssDetails from "./pages/RssDetails.vue"
import SettingsPage from "./pages/SettingsPage.vue"
import { path } from '@tauri-apps/api';
export const routes = [
    {
      path: '/',
      component: RssPage
    },
    {
      name: "details",
      path: '/details',
      component: RssDetails
    },
    {
      name: "settings",
      path: '/settings',
      component: SettingsPage
    },
  ]
const router = createRouter({
    history: createWebHistory(""),
    routes,
});

export default router;