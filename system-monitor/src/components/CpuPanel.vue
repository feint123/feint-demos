<script setup lang="ts">
import { ref, reactive, onMounted, Ref, computed, watch, h, Component, VNode, render } from "vue";
import { invoke } from "@tauri-apps/api/tauri";
import * as echarts from 'echarts';
import 'echarts/theme/blue'
import VChart from 'vue-echarts';
import { CpuData } from "../assets/ts/monitor";
import { getCpuUsageDatas } from "../assets/ts/options/cpuOption";
import { cpuOption } from "../assets/ts/options/options";
import { EChartsType } from "echarts/core";
import { ElCol, ElRow } from "element-plus";
const cpuBrand = ref<string>("");
const cpuUsageCharts = ref<echarts.ECharts[]>([]);
const cpuRootNode = ref<VNode>();
const cpuTotalChart = ref<EChartsType>();
const cpuCores = ref<number>(0);
const cpuGraphCols = computed(() => {
    if (cpuCores.value <= 4) {
        return 2;
    } else if (cpuCores.value <= 12) {
        return 4;
    }
    else if (cpuCores.value <= 18) {
        return 6;
    } else if (cpuCores.value <= 32) {
        return 8;
    } else if (cpuCores.value <= 48) {
        return 12;
    } else {
        return 24;
    }
});
const cpuGraphRows = computed(() => {
    return Math.ceil(cpuCores.value / cpuGraphCols.value)
});
const fitSize = computed(() => {
    return { height: `${80 / cpuGraphRows.value * 2}px` }
});
const cpuUsageData: number[][] = [];
const globalCpuUsageData: number[][] = [];


function updateCpuUsage(cpu: CpuData) {
    if (cpuUsageData.length > 30) {
        cpuUsageData.shift();
        globalCpuUsageData.shift();
    }
    cpuUsageData.push(getCpuUsageDatas(cpu.cores));
    for (var i = 0; i < cpuUsageCharts.value.length; i++) {
        cpuUsageCharts.value[i].setOption({
            dataset: {
                source: cpuUsageData
            }
        })
    }
    globalCpuUsageData.push([new Date().getTime(), new Date().getTime(), cpu.global_usage])
    cpuTotalChart.value?.setOption({
        dataset: {
            source: globalCpuUsageData
        }
    })
}



function flushCpuData() {
    invoke<CpuData>("cpu_info", {}).then(cpu => {
        cpuBrand.value = cpu.chip_name;
        updateCpuUsage(cpu);
    });
    return flushCpuData;
}

onMounted(async () => {
    // 获取机器cpu核心数
    cpuCores.value = (await invoke<CpuData>("cpu_info", {})).cores.length;
    // 创建虚拟节点
    const cpuRowElems: VNode[] = [];
    for (var i = 0; i < cpuGraphRows.value; i++) {
        const cpuColsElems: VNode[] = [];
        for (var j = 0; j < cpuGraphCols.value; j++) {
            const vchart = h('div', {
                class: ['chart'], style: fitSize.value, id: `cpuUsage${i * cpuGraphCols.value + j}`,
            });
            cpuColsElems.push(h(ElCol, { span: 24 / cpuGraphCols.value },() => vchart));
        }
        cpuRowElems.push(h(ElRow, { gutter: 2 },()=> cpuColsElems));
    }
    const cpuRoot = h('div', cpuRowElems);
    // 渲染节点
    render(cpuRoot, document.getElementById('cpuRoot')!);
    // 初始化echarts。
    for (var i = 0; i < cpuCores.value; i++) {
        const chartInstance = echarts.init(document.getElementById(`cpuUsage${i}`)!,'blue')
        cpuUsageCharts.value.push(chartInstance);
        chartInstance.setOption(cpuOption);
        chartInstance.setOption({
            series: [
                {
                    encode: {
                        y: i + 2,
                        x: 0,
                        itemId: 1
                    }
                }
            ]
        })
    }
    cpuTotalChart.value?.setOption(cpuOption);
    cpuTotalChart.value?.setOption({
        series: [{
            type: 'bar',
            encode: {
                y: 2,
                x: 0,
                itemId: 1
            }
        }]
    })

    setInterval(flushCpuData(), 2000);

})




</script>

<template>
    <el-row>
        <el-col :span="24">
            <el-card>
                <template #header>
                    <div class="card-header">
                        <span>Cpu核心负载</span>
                        <span>{{ cpuBrand }}</span>
                        <v-chart style="height: 24px; width: 100px;" ref="cpuTotalChart" :manual-update="true"
                            autoresize />
                    </div>
                </template>
                <div ref="cpuRoot" id="cpuRoot">

                </div>
                <!-- <el-row v-for="i in cpuGraphRows - 1" :gutter="2">
                    <el-col :span="24/cpuGraphCols" v-for="j in cpuGraphCols">
                        <v-chart class="chart" :style="fitSize" :ref="cpuUsageCharts[(i - 1) * cpuGraphCols + j - 1]"
                            :manual-update="true" autoresize />
                    </el-col>
                </el-row>
                <el-row :gutter="2">
                    <el-col :span="24/cpuGraphCols" v-for="j in (cpuCores - (cpuGraphRows - 1) * cpuGraphCols)">
                        <v-chart class="chart" :style="fitSize" :ref="cpuUsageCharts[(cpuGraphRows - 1) * cpuGraphCols + j - 1]"
                            :manual-update="true" autoresize />
                    </el-col>
                </el-row> -->
            </el-card>
        </el-col>
    </el-row>
</template>

<style scoped>
.chart {
    height: 80px;
    width: 100%;
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