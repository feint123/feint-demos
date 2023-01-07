<script setup>
import { onMounted, ref } from "vue";
import NomalPanel from '../../..//components/NomalPanel.vue';
import ColorCard from '../../..//components/ColorCard.vue';
import { selectAllColors } from "../../../assets/js/db";
import { computed } from "@vue/reactivity";
import { CirclePlus } from '@element-plus/icons-vue'

const colorArr = ref([]);

const colorTypes = ref(["WEB颜色"]);

const activeName = computed(()=> {
    return colorTypes.value[0];
})

onMounted(() => {
    selectAllColors((result) => {
        result.forEach(row => {
            colorArr.value.push({
                enName: row.EN_NAME,
                cnName: row.CN_NAME,
                hexColor: row.HEX_VAL,
            })
        });

    })
})

</script>


<template>
    <NomalPanel>
        <template #header>
            <el-icon @click="toggleAside()" size="20" style="right: 20px;">
              <CirclePlus />
            </el-icon>
        </template>
        <template #main>
            <el-tabs v-model="activeName" class="color-tabs" @tab-click="" type="border-card">
                <el-tab-pane v-for="ct in colorTypes" :label="ct" :name="ct">
                    <el-space wrap :size="2" style="justify-content:center;">
                <div v-for="color in colorArr" placement="top">
                    <ColorCard :model="color" />
                </div>
            </el-space>
                </el-tab-pane>
            </el-tabs>
        </template>
    </NomalPanel>
</template>


<style scoped>
.el-tabs {
    height: 100%;
}
.color-tabs {
    border: none;
    background-color: var(--el-bg-color);
}
:deep() .el-main {
    padding: 0;
    overflow: hidden;
}
:deep() .el-tabs__content {
    /* position: fixed;
    z-index: 2000; */
    height: calc(100% - var(--el-tabs-header-height) - 15px * 2);
    overflow: auto;
}

:deep() .el-tabs__item.is-top.is-active{
    background-color: var(--el-bg-color);
}
:deep() .el-tabs__header{
    margin-bottom:  0px;
}

</style>