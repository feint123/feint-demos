<script setup lang="ts">
import { ref, reactive, onMounted, Ref, provide } from "vue";
import { invoke } from "@tauri-apps/api/tauri";
import 'echarts';
import 'echarts/theme/blue'
import VChart, { THEME_KEY } from 'vue-echarts';
import { SysMonitorData, CpuCoreData, MemoryData } from "../assets/ts/monitor";
import { gaugeOption } from "../assets/ts/options/options";
import { setSpecialGuage } from "../assets/ts/options/gaugeOption";
import { EChartsType } from "echarts/core";
import { useDark } from "@vueuse/core";
provide(THEME_KEY, 'blue')

const socSensorChart = ref<EChartsType>();

function flushSensorData() {
    invoke<SysMonitorData>("system_info", {}).then(sysMonitor => {
        setSpecialGuage(socSensorChart.value!, '温度', sysMonitor.sensors['SOC MTR Temp Sensor0'].toFixed(2),);
    })
    return flushSensorData;
}

onMounted(async () => {
    socSensorChart.value?.setOption(gaugeOption);
    setInterval(flushSensorData(), 5000);

})


</script>

<template>
    <el-card>
        <template #header>
            <div class="card-header">
                <span>SOC温度</span>
            </div>
        </template>
        <v-chart class="chart" ref="socSensorChart" :manual-update="true" autoresize />
    </el-card>
</template>

<style scoped>
.chart {
    height: 100px;
    width: 100%;
}

.el-row:last-child {
    margin-bottom: 0;
}

.el-card {
    --el-card-padding: 8px
}

.card-header {
    font-size: smaller;
    /* font-weight: bold; */
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: var(--el-text-color-regular);
}
</style>