<script setup>
import { onMounted, ref } from "vue";
import { isPermissionGranted, requestPermission, sendNotification } from '@tauri-apps/api/notification';
import { ElMessage } from "element-plus";

const fileName = ref('');
const isNotifPermission = ref(false);
async function requestPermissionDemo() {
    let permissionGranted = await isPermissionGranted();
    if (!permissionGranted) {
        const permission = await requestPermission();
        isNotifPermission.value = permission === 'granted';
        if (isNotifPermission.value) {
            ElMessage({
                message: '权限请求成功',
                type: 'success',
            });
        }
    }
}
async function sendNotificationDemo() {
    sendNotification({ title: 'TAURI', body: 'Tauri is awesome!' });
}

onMounted(async () => {
    isNotifPermission.value = await isPermissionGranted();
})

</script>

<template>
    <el-descriptions title="" direction="horizontal" :column="2" :size="size" border>
        <el-descriptions-item label="通知权限">  
            <el-switch v-model="isNotifPermission" inline-prompt active-text="是" inactive-text="否" disabled/>
        </el-descriptions-item>
        <el-descriptions-item label="通知">
            <el-button :disabled="isNotifPermission" type="primary" @click="requestPermissionDemo" plain>请求通知权限</el-button>
            <el-button :disabled="!isNotifPermission" type="success" @click="sendNotificationDemo" plain>发送通知</el-button>
        </el-descriptions-item>
    </el-descriptions>
   
    
</template>

<style scoped>
.el-tag {
    margin-left: 20px;
}
</style>
