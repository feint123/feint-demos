import { createApp } from "vue";
import "./style.css";
import ElementPlus from "element-plus";
import "element-plus/dist/index.css";
import "element-plus/theme-chalk/dark/css-vars.css";
import devtools from "@vue/devtools";
import App from "./App.vue";

console.log("process.env", process.env.NODE_ENV);
if (process.env.NODE_ENV === "development") {
  devtools.connect("http://localhost", 1420);
}
const app = createApp(App);
app.use(ElementPlus);
app.mount("#app");
