<script setup>
import { onMounted, reactive, ref } from "vue";
import { getClient, ResponseType } from "@tauri-apps/api/http";
import { ElMessage } from "element-plus";

const pageInfoes = reactive({
  total: 0,
  currentPage: 1,
});

const datas = ref([]);

const baseUrl = "https://api.bilibili.com/x/web-interface/dynamic/region?";

onMounted(async () => {
  requestUrl(1, 188);
});

async function requestUrl(page, tid) {
  const requestUrl = baseUrl + `pn=${page}&ps=10&rid=${tid}`;
  const client = await getClient();
  const response = await client.get(requestUrl, {
    responseType: ResponseType.JSON,
  });
  datas.value = response.data["data"]["archives"];
  const pageData = response.data["data"]["page"];
  pageInfoes.total = pageData["count"];
}

function currentChange() {
  requestUrl(pageInfoes.currentPage, 188);
}
</script>

<template>
  <el-table
    :data="datas"
    style="width: 100%; margin-bottom: 16px"
    stripe
    border
  >
    <el-table-column prop="tname" label="分类" width="120" />
    <el-table-column prop="owner.name" label="Up名" width="150" />
    <el-table-column prop="title" label="标题" />
  </el-table>
  <el-pagination
    v-model:current-page="pageInfoes.currentPage"
    background
    layout="prev, pager, next"
    :total="pageInfoes.total"
    @current-change="currentChange"
  />
</template>

<style scoped>
.el-tag {
  margin-left: 20px;
}
</style>
