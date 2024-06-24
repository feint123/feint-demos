<script setup>
import { open } from '@tauri-apps/plugin-dialog';
import { invoke } from '@tauri-apps/api/core';
import { Store } from '@tauri-apps/plugin-store';
import { NButton, NIcon, NImage, NProgress, NTag, useMessage } from 'naive-ui';
import { Play as Play, Stop as StopIcon, Close as CloseIcon, CheckmarkCircle, Download, Copy, FileTray } from 'vicons/ionicons-v5';
import { v4 as uuid } from 'uuid';
import { message } from '@tauri-apps/plugin-dialog';
import { onUnmounted, onMounted, ref, render } from 'vue';
import { writeText } from '@tauri-apps/plugin-clipboard-manager';
import { Command } from '@tauri-apps/plugin-shell';

import { useWindowSize } from '@vueuse/core'
import { stat } from '@tauri-apps/plugin-fs';
const { width, height } = useWindowSize()
const tableHeight = computed(() => height.value - 210)
const percentage = ref(0)
const nMessage = useMessage();
var stateMap = {};
var processMap = {};
onMounted(async () => {
})
onUnmounted(async () => {
  clearInterval(interval);
  await store.save();
})
// you need to call unlisten if your handler goes out of scope e.g. the component is unmounted


const url = ref("")
// const message = useMessage()
let working_queue = [];
const store = new Store('store.bin')
var works = ref([])
async function chooseFile() {
  if (!isValidURL(url.value)) {
    await message('请输入合法的地址', { title: '链接地址', kind: 'error' });
    return
  }
  await open({
    directory: true,
    multiple: false,
    title: '选择下载目录',
  }).then(async file => {
    var work_id = uuid();
    working_queue.push(work_id);
    invoke('download_file', {
      url: url.value,
      filePath: file,
      workId: work_id
    }).catch(e => {
      console.log("error ", e)
    })
    url.value = ""
  });

}

async function continueDownLoad(workId) {
  working_queue.push(workId);
  await invoke('download_file_by_id', {
    workId: workId
  })
    .catch(e => {
      console.log("error ", e)
    })
}

const interval = setInterval(async () => {
  works.value = await store.get('works')
  // console.log(works.value)
  for (let i = 0; i < works.value.length; i++) {
    let element = works.value[i];

    let state = await store.get("state_" + element.work_id)
    if (state) {
      stateMap[element.work_id] = state.state;
    }

    let process = await store.get("process_" + element.work_id)
    if (process) {
      processMap[element.work_id] = process.process;
    }

    if (working_queue.filter(item => item === element['work_id']).length == 0) {
      if (element.state == 'Processing') {
        await invoke('stop_download_by_id', {
          workId: element.work_id
        })
          .catch(e => {
            console.log("error ", e)
          })
      }
    }
  }


}, 1000)

function bytesToSize(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function isValidURL(url) {
  // 定义URL的正则表达式
  return url.includes('http://') || url.includes('https://');
}

function statusToChinese(status) {
  const statusMap = {
    'Init': '初始化',
    'Queued': '已排队',
    'Finished': '已完成',
    'Failed': '失败',
    'Processing': '处理中',
    'Stopped': '已停止',
  };
  return statusMap[status] || '未知状态';
}

function stopAll() {
  working_queue = []
}

function startAll() {
  works.value.filter(item => item.state === 'Stopped').forEach(item => {
    continueDownLoad(item.work_id)
  })
}
function isStop(workId, state) {
  if (state === 'Stopped') {
    return true
  } else {
    return false
  }
}

function hasStoppedWorks() {
  return works.value.filter(item => item.state === 'Stopped').length > 0
}

function hasProcessingWorks() {
  return works.value.filter(item => item.state === 'Processing').length > 0
}
async function clearRecords() {
  const confirmation = await confirm(
    '您将删除所有下载记录哦，确定吗?',
    { title: '删除', kind: 'warning' }
  );
  if (confirmation) {
    await store.set('works', [])
  }
}

const createColumns = ({
  play
}) => {
  return [
    {
      title: "",
      key: "file_path",
      width: 80,
      align: "center",
      render(row) {
        if (row.url.includes(".png") || row.url.includes(".jpg") || row.url.includes(".jpeg") || row.url.includes(".gif")
          || row.url.includes(".bmp") || row.url.includes(".svg") || row.url.includes(".webp") || row.url.includes(".ico")
          || row.url.includes(".avif")) {
          return h(NImage, {
            src: row.url,
            width: "50",
            height: "50",
            objectFit: "scale-down"
          });
        } else if (row.url.includes(".mp4") || row.url.includes(".avi") || row.url.includes(".mkv") || row.url.includes(".mov") || row.url.includes(".wmv") || row.url.includes(".flv") || row.url.includes(".rmvb") || row.url.includes(".webm")) {
          return h(NButton, {
            strong: true,
            secondary: true,
            circle: true,
            type: 'info',
            disabled: row.state != "Finished",
            onClick: async () => {
              let result = await Command.create('open-video', [
                row.file_path,
              ]).execute();
              if (result.code === 1) {
                await message(result.stderr, { title: '打开失败', kind: 'error' });
              }
            },
          }, {
            icon: renderIcon(Play),
          }
          )
        } else {
          return "-"
        }
      }
    },
    {
      title: "名称",
      key: "file_name",
      ellipsis: true,
      resizable: true,
      minWidth: 200,
    },
    {
      title: "大小",
      key: "file_size",
      width: 130,
      render(row) {
        return bytesToSize(row["file_size"]);
      },
      sorter: (row1, row2) => row1["file_size"] - row2["file_size"]
    },
    {
      title: "状态",
      width: 300,
      render(row) {
        row.state = stateMap[row.work_id]
        row.process = processMap[row.work_id]
        if (isStop(row["work_id"], row.state)) {
          return h(NButton, {
            strong: true,
            secondary: true,
            size: 'tiny',
            round: true,
            type: 'info',
            onClick: () => continueDownLoad(row["work_id"]),
          }, {
            default: () => '继续下载',
            icon: renderIcon(Play),
          }
          )

        } else if (row.state === 'Processing') {
          return h(NProgress, {
            type: 'line',
            percentage: row.process,
          });

        } else if (row.state === 'Finished') {
          return h(NTag, {
            type: 'success',
            size: 'small',
            round: true,
          }, {
            default: () => statusToChinese(row.state),
            icon: renderIcon(CheckmarkCircle),
          });
        } else {
          return h(NTag, {
            type: 'info',
            size: 'small',
            round: true,
          }, {
            default: () => statusToChinese(row.state),
          });
        }
      }
    }
  ];
};
const renderIcon = (icon) => {
  return () => {
    return h(NIcon, null, {
      default: () => h(icon)
    });
  };
};
const options = [
  {
    label: "暂停下载",
    key: "stop",
    icon: renderIcon(Copy),
  },
  {
    label: "复制链接地址",
    key: "copyUrl",
    icon: renderIcon(StopIcon)
  },
  {
    label: "删除下载项",
    key: "delete",
    icon: renderIcon(CloseIcon)
  },
  {
    label: "在访达中显示",
    key: "open",
    icon: renderIcon(FileTray)
  }
];
const showDropdown = ref(false)
const x = ref(0)
const y = ref(0)

async function delRelationWorkInfo(workId) {
  await store.delete('state_' + workId)
  await store.delete("process_" + workId)
  await store.delete("chunk_" + workId)
}

async function handleSelect(key) {
  showDropdown.value = false;
  if (rightClickRow.value) {
    if (key === "stop") {
      working_queue = working_queue.filter(item => item !== rightClickRow.value.work_id)
    } else if (key === "delete") {
      const confirmation = await confirm(
        '您将删除下载记录哦，确定吗?',
        { title: '删除', kind: 'warning' }
      );
      if (confirmation) {
        let currentWorks = await store.get('works')
        currentWorks = currentWorks.filter(item => item.work_id !== rightClickRow.value.work_id)
        await delRelationWorkInfo(currentWorks.work_id)
        await store.set('works', currentWorks)
      }
    } else if (key === "copyUrl") {
      await writeText(rightClickRow.value.url);
      nMessage.info("已复制链接地址到剪贴板")
    } else if (key === "open") {
      let result = await Command.create('exec-sh', [
        '-R',
        rightClickRow.value.file_path,
      ]).execute();
      if (result.code === 1) {
        await message(result.stderr, { title: '打开失败', kind: 'error' });
      }
    }
  }
}
function onClickoutside() {
  showDropdown.value = false;
}
const rightClickRow = ref({})
const rowProps = (row) => {
  return {
    onContextmenu: (e) => {
      e.preventDefault();
      showDropdown.value = false;
      nextTick().then(() => {
        rightClickRow.value = row;
        showDropdown.value = true;
        x.value = e.clientX;
        y.value = e.clientY;
      });
    },
    style: 'cursor: pointer;',
    ondblclick: async () => {
      await writeText(row.file_name);
      nMessage.info("已复制文件名到剪贴板")
    }
  };

}

var columns = createColumns({
  play: (row) => {
    console.log("play ", row)
    continueDownLoad(row.workId)
  }
});




</script>

<template>
  <div style="height: 100%; overflow-y: hidden">
    <n-space vertical :size="12" style="padding: 24px;">
      <n-grid :x-gap="12" :y-gap="8" :cols="4" style="margin-bottom: 12px;">
        <n-grid-item span="3 400:3 600:1 800:1 1200:1">
          <n-input size="large" round placeholder="请输入链接地址" v-model:value="url" type="info" />
        </n-grid-item>
        <n-grid-item>
          <n-button strong secondary size="large" round type="info" @click="chooseFile()" :disabled="url.length == 0">
            <template #icon>
              <n-icon>
                <download />
              </n-icon>
            </template>

            下载
          </n-button>
        </n-grid-item>
      </n-grid>
      <n-space>
        <n-button @click="startAll" strong secondary round :disabled="working_queue.length > 0 || !hasStoppedWorks()">
          <template #icon>
            <n-icon>
              <play />
            </n-icon>
          </template>
          全部开始
        </n-button>
        <n-button @click="stopAll" strong secondary round
          :disabled="working_queue.length == 0 || !hasProcessingWorks()">
          <template #icon>
            <n-icon>
              <stop-icon />
            </n-icon>
          </template>
          全部暂停
        </n-button>
        <n-button @click="clearRecords" type="error" strong secondary round :disabled="works.length == 0">
          <template #icon>
            <n-icon>
              <close-icon />
            </n-icon>
          </template>
          清空记录
        </n-button>
      </n-space>
      <n-space>
        <n-data-table :columns="columns" :data="works" :row-props="rowProps" :bordered="true" :scroll-x="600"
          :max-height="tableHeight" />
        <n-dropdown placement="bottom-start" trigger="manual" :x="x" :y="y" :options="options" :show="showDropdown"
          :on-clickoutside="onClickoutside" @select="handleSelect" />
      </n-space>
    </n-space>
  </div>
</template>

<style scoped></style>