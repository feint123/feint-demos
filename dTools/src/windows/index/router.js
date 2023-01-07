import {createRouter, createWebHashHistory} from "vue-router";
import ClipHistory from "./pages/ClipHistory.vue";
import ColorSeeSee from "./pages/ColorSeeSee.vue";
import CodeTranslator from "./pages/CodeTranslator.vue"; 
const routes = [
    { path: '/cliphistory', component: ClipHistory },
    { path: '/colorss', component: ColorSeeSee},
    { path: '/code-translator', component: CodeTranslator},
]
const router = createRouter({
    // 4. 内部提供了 history 模式的实现。为了简单起见，我们在这里使用 hash 模式。
    history: createWebHashHistory(),
    routes, // `routes: routes` 的缩写
})
export default router;
