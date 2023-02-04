<script setup lang="ts">
import { ref, reactive, onMounted, Ref, provide } from "vue";
import { invoke } from "@tauri-apps/api/tauri";
import 'echarts';
import 'echarts/theme/blue'
import VChart, { THEME_KEY } from 'vue-echarts';
import { BatteryData } from "../assets/ts/monitor";
import { batteryOption } from "../assets/ts/options/options";
provide(THEME_KEY, 'blue')

const battery = ref<BatteryData>();

const batteryChart = ref<any>(null);

function updateBattery(batteryData: BatteryData) {
    batteryChart.value.setOption({
        dataset: {
            source: [['battery', batteryData.percentage, 100]]
        }
    })

    battery.value = batteryData;
}

function flushBattery() {
    invoke<BatteryData>("battery_info", {}).then(battery=> {
        updateBattery(battery);
    })
    return flushBattery;
}

onMounted(async () => {
    batteryChart.value.setOption(batteryOption);
    setInterval(flushBattery(), 30 * 1000);
})




</script>

<template>
    <el-row>
        <el-col>
            <el-card>
                <template #header>
                    <div class="card-header">
                        <span>电量</span>

                        <div class="card-header">
                            <v-chart class="chart" style="height: 24px; width: 60%" ref="batteryChart"
                                :manual-update="true" autoresize />
                            <span>{{ battery?.percentage.toFixed(0) }}%</span>
                        </div>
                    </div>
                </template>

                <el-descriptions :column="2" size="small" border>
                    <el-descriptions-item label="状态">
                        <span v-if="battery?.state == 1"> 已充满 </span>
                        <span v-if="battery?.state == 2"> 充电中 </span>
                        <span v-if="battery?.state == 3"> 未充电 </span>
                        <span v-if="battery?.state == 0"> 电量用尽 </span>
                        <span v-if="battery?.state == -1"> 未知 </span>
                    </el-descriptions-item>
                    <el-descriptions-item label="健康">
                        {{ battery?.state_of_health }}
                    </el-descriptions-item>
                </el-descriptions>

            </el-card>
        </el-col>
    </el-row>
</template>

<style scoped>
.chart {
    height: 80px;
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