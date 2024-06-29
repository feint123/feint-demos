import { createApp } from "vue";
import App from "./App.vue";
// import 'vant/lib/index.css';
import router from './routes.js';
import './styles/main.css';

import Framework7Vue , { registerComponents }from 'framework7-vue/bundle';

// Import Framework7 Styles
// import ' /framework7.css';

// Import Framework7 Core (optional)
import Framework7 from 'framework7/lite';
import SheetComponent from "framework7/components/sheet";
import PanelComponent from "framework7/components/panel";
import PullToRefreshComponent from "framework7/components/pull-to-refresh";
import SmartSelectComponent from "framework7/components/smart-select";
import PopoverComponent from "framework7/components/popover";
import ToggleComponent from "framework7/components/toggle";
import ToastComponent from "framework7/components/toast";


const app = createApp(App);
Framework7.use(SheetComponent)
Framework7.use(PanelComponent)
Framework7.use(PullToRefreshComponent)
Framework7.use(Framework7Vue)
Framework7.use(SmartSelectComponent)
Framework7.use(PopoverComponent)
Framework7.use(ToggleComponent)
Framework7.use(ToastComponent)
app.use(router);
registerComponents(app);
app.mount("#app");
