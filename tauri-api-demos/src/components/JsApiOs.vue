<script setup>
import { onMounted, reactive, ref } from "vue";
import { arch, platform, tempdir, type, version} from '@tauri-apps/api/os';
import { ElMessage } from "element-plus";

const osInfoes = reactive({
    archName:"",
    platformName:"",
    tempDir:"",
    osType:"",
    osVersion:"",
})

onMounted(async () => {
    osInfoes.archName = await arch();
    osInfoes.platformName = await platform();
    osInfoes.tempDir = await tempdir();
    osInfoes.osType = await type();
    osInfoes.osVersion = await version();
})

</script>

<template>
    <el-descriptions title="" direction="horizontal" :column="3" :size="size" border>
        <el-descriptions-item label="arch">  
            {{ osInfoes.archName }}
        </el-descriptions-item>
        <el-descriptions-item label="platform">  
            {{ osInfoes.platformName }}
        </el-descriptions-item>
        <el-descriptions-item label="os type">  
            {{ osInfoes.osType }}
        </el-descriptions-item>
        <el-descriptions-item label="os version">  
            {{ osInfoes.osVersion }}
        </el-descriptions-item>
        <el-descriptions-item label="tempdir">  
            {{ osInfoes.tempDir }}
        </el-descriptions-item>
        
    </el-descriptions>
   
    
</template>

<style scoped>
.el-tag {
    margin-left: 20px;
}
</style>
