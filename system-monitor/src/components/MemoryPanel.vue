<script setup lang="ts">
import { ref, onMounted, provide } from "vue";
import { invoke } from "@tauri-apps/api/tauri";
import 'echarts';
import 'echarts/theme/blue'
import VChart, { THEME_KEY } from 'vue-echarts';
import { MemoryData } from "../assets/ts/monitor";
import { memoryOption } from "../assets/ts/options/options";
import { EChartsType } from "echarts/core";
provide(THEME_KEY, 'blue')

const totalMemory = ref<string>("16");
const memoryChart = ref<EChartsType>();


function updateMemoryUsage(memory: MemoryData) {
    memoryChart.value?.setOption({
        dataset: {
            source: [['memory', (memory.used_memory+memory.used_swap).toFixed(1), memory.total_memory, memory.total_swap]]
        }
    });
}

function flushMemoryUsage() {
    invoke<MemoryData>("memory_info", {}).then(memory => {
        console.log(memory)
        totalMemory.value = (memory.total_memory + memory.total_swap).toFixed(0);
        memoryOption.xAxis.max = Number.parseInt(totalMemory.value);
        updateMemoryUsage(memory);
    });
    return flushMemoryUsage;
}

onMounted(async () => {
    memoryChart.value?.setOption(memoryOption);
    setInterval(flushMemoryUsage(), 10 * 1000);
})

</script>

<template>
    <el-row>
        <el-col>
            <el-card>
                <div class="card-header">
                    <span style="width: 40px">内存</span>
                    <v-chart class="chart" ref="memoryChart" :manual-update="true" autoresize />
                    <!-- <span>{{ totalMemory }}GB</span> -->
                </div>
            </el-card>
        </el-col>
    </el-row>
</template>

<style scoped>
.chart {
    height: 41px;
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