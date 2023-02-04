<script setup lang="ts">
import { ref, onMounted, provide } from "vue";
import { invoke } from "@tauri-apps/api/tauri";
import 'echarts';
import 'echarts/theme/blue'
import VChart, { THEME_KEY } from 'vue-echarts';
import { ProcessData } from "../assets/ts/monitor";
import { processOption } from "../assets/ts/options/options";
import { EChartsType } from "echarts/core";
import { useDark } from "@vueuse/core";
provide(THEME_KEY, 'blue')
const processChart = ref<EChartsType>();

function updateProcessMem(processes: ProcessData[]) {
    const source = []
    for (const key in processes) {
        source.push([processes[key].pid, processes[key].name, (processes[key].memory * 1024.).toFixed(0)])
    }
    processChart.value?.setOption({
        dataset: {
            source: source
        }
    });
}

function flushProcessData() {
    invoke<ProcessData[]>("process_info", {}).then(processes => {
        updateProcessMem(processes.slice(0, 10).reverse())
    })
    return flushProcessData
}

onMounted(async () => {
    processChart.value?.setOption(processOption);
    setInterval(flushProcessData(), 1000);
})




</script>

<template>
    <el-row>
        <el-col :span="24">
            <el-card>
                <v-chart class="chart" ref="processChart" :manual-update="true" autoresize />
            </el-card>
        </el-col>
    </el-row>

</template>

<style scoped>
.chart {
    height: 290px;
    width: 100%;
}

.el-row {
    margin-bottom: 8px;
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