<script setup>
import { onMounted, reactive, ref } from "vue";
import { open, save } from '@tauri-apps/api/dialog';
import { readBinaryFile, BaseDirectory, copyFile, readDir, writeTextFile, writeBinaryFile, exists } from '@tauri-apps/api/fs'
import { appDataDir, downloadDir, basename, join } from '@tauri-apps/api/path'
import { getClient, ResponseType } from '@tauri-apps/api/http';

import { Files } from '@element-plus/icons-vue'
import { ElMessage } from "element-plus";

const fileCopyForm = reactive({
    sourceFile: '',
    targetDir: '',
});
const writeFileForm = reactive({
    text: '',
});
const activeNames = ref('copyFile')
const readImgSrc = ref('');
const dirFiles = ref([])
const loading = ref(true)


async function openFileDialog() {
    // Open a selection dialog for directories
    const selected = await open({
        directory: false,
        multiple: false,
        filters: [{
            name: 'Image',
            extensions: ['png', 'jpg', 'jpeg']
        }],
        defaultPath: await appDataDir(),
    });
    if (Array.isArray(selected)) {

    } else if (selected === null) {

    } else {
        const content = await readBinaryFile(selected);
        // console.log(content)
        readImgSrc.value = URL.createObjectURL(
            new Blob([content.buffer], { type: 'image/png' })
        );
    }
}

async function chooseSourceFile() {
    // Open a selection dialog for directories
    const selected = await open({
        directory: false,
        multiple: false,
        defaultPath: await downloadDir(),
    });
    if (Array.isArray(selected)) {

    } else if (selected === null) {

    } else {
        fileCopyForm.sourceFile = selected;
    }
}

async function chosseTargetDir() {
    // Open a selection dialog for directories
    const selected = await open({
        directory: true,
        multiple: false,
        defaultPath: await downloadDir(),
    });
    if (Array.isArray(selected)) {

    } else if (selected === null) {

    } else {
        fileCopyForm.targetDir = selected;
    }
}

async function copyFileDemo() {
    const sourceBaseName = await basename(fileCopyForm.sourceFile);
    const targetFile = await join(fileCopyForm.targetDir, sourceBaseName);
    copyFile(fileCopyForm.sourceFile, targetFile).then(() => {
        ElMessage({
            message: '??????????????????',
            type: 'success',
        });
    }).catch((reason) => {
        ElMessage({
            message: '?????????????????????' + reason,
            type: 'error',
        });
    });
}

async function readDirDemo() {
    const downloadD = await downloadDir();
    // ????????? tauri.conf.json ????????? fs scope
    readDir('', { dir: BaseDirectory.Download, recursive: true }).catch((reason) => {
        ElMessage({
            message: '?????????????????????' + reason,
            type: 'error',
        });
    }).then((entries) => {
        dirFiles.value = [{ label: downloadD, children: [] }];
        processEntries(entries, dirFiles.value[0]);
        loading.value = false;
    });

}

async function processEntries(entries, root) {
    for (const entry of entries) {
        // const name =  await basename(entry.path);
        const node = {
            label: entry.name,
            children: []
        }
        if (entry.children) {
            processEntries(entry.children, node)
        }
        root.children.push(node)
    }

}

async function saveFileDialog() {
    const savePath = await save({
        filters: [{
            name: 'Text',
            extensions: ['txt']
        }]
    });
    if (savePath.length == 0) {
        return;
    }
    // ???????????????
    writeTextFile({ path: savePath, contents: writeFileForm.text })
        .catch((reason) => {
            ElMessage({
                message: '?????????????????????' + reason,
                type: 'error',
            });
        }).then(() => {
            ElMessage({
                message: '??????????????????',
                type: 'success',
            });
        });
}

async function saveBinaryFile() {
    const client = await getClient();
    const response = await client.get('https://tauri.app/meta/tauri_logo_light.svg', {
        responseType: ResponseType.Binary
    })

    writeBinaryFile("tauri.svg", response.data, { dir: BaseDirectory.Download })
        .catch((reason) => {
            ElMessage({
                message: '?????????????????????' + reason,
                type: 'error',
            });
        }).then(async () => {
            const downloadD = await downloadDir();
            const savePath = await join(downloadD, "tauri.svg");
            ElMessage({
                message: '?????????????????????'+savePath,
                type: 'success',
            });
        });

}

const defaultProps = {
    children: 'children',
    label: 'label',
}

function handleChange(name) {
    if ('readDir' == name) {
        loading.value = true;
        readDirDemo();
    } else {
        dirFiles.value = [];
    }
}
</script>

<template>
    <el-collapse v-model="activeNames" @change="handleChange" accordion>
        <el-collapse-item title="????????????" name="copyFile">
            <el-form :inline="true" :model="fileCopyForm">
                <el-form-item>
                    <el-input v-model="fileCopyForm.sourceFile" placeholder="????????????">
                        <template #prepend>
                            <el-button :icon="Files" @click="chooseSourceFile" />
                        </template>
                    </el-input>
                </el-form-item>
                <el-form-item>
                    <el-input v-model="fileCopyForm.targetDir" placeholder="????????????">
                        <template #prepend>
                            <el-button :icon="Files" @click="chosseTargetDir" />
                        </template>
                    </el-input>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="copyFileDemo" plain>??????</el-button>
                </el-form-item>
            </el-form>
        </el-collapse-item>
        <el-collapse-item title="?????????????????????" name="readBinaryFile">
            <el-container>
                <el-card>
                    <template #header>
                        <div class="card-header">
                            <el-button type="primary" @click="openFileDialog" plain>????????????</el-button>
                        </div>
                    </template>
                    <el-image style="width: 100px; height: 100px;" :src="readImgSrc" fit="cover"></el-image>
                </el-card>
            </el-container>
        </el-collapse-item>
        <el-collapse-item title="????????????" name="readDir">
            <el-tree v-loading="loading" :data="dirFiles" :props="defaultProps" />
        </el-collapse-item>
        <el-collapse-item title="?????????" name="writeFile">
            <el-form :model="writeFileForm">
                <el-form-item label="??????">
                    <el-input v-model="writeFileForm.text" type="textarea" />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" :disabled="writeFileForm.text.trim() == ''" @click="saveFileDialog"
                        plain>??????</el-button>
                </el-form-item>
                <el-form-item>
                    <el-image style="width: 200px; height: 100px" src="https://tauri.app/meta/tauri_logo_light.svg"
                        fit="fill" />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="saveBinaryFile" plain>????????????</el-button>
                </el-form-item>
            </el-form>


        </el-collapse-item>
    </el-collapse>

</template>

<style scoped>

</style>