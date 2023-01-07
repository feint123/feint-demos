<script setup>
import { onMounted, reactive, ref } from "vue";
import { copied } from "../../../assets/js/tools";
import NomalPanel from '../../../components/NomalPanel.vue';
import { useDateFormat, useIntervalFn, } from "@vueuse/shared";
import { computed } from "@vue/reactivity";
import { useNow } from "@vueuse/core";

const encodeForm = reactive({
    urlEncode: "",
    unicodeEncode: "",
    currentTimestamp: useNow(),
    currentTime: "",
    inputTimestamp: 0,
    timestampUnit: "1",
    datetime: "",
    stDate: new Date(),
    stTimestampe: 0
});

const computedDate = computed(() => {
    if ("" === encodeForm.inputTimestamp) {
        encodeForm.inputTimestamp = "0"
    }
    return new Date(parseInt(encodeForm.inputTimestamp) * parseInt(encodeForm.timestampUnit))
})

encodeForm.stTimestampe = computed(() => {
    return encodeForm.stDate.getTime();
});

encodeForm.datetime = computed(() => {
    return useDateFormat(computedDate.value, 'YYYY-MM-DD HH:mm:ss').value
})

encodeForm.currentTime = computed(() => {
    return useDateFormat(encodeForm.currentTimestamp, 'YYYY-MM-DD HH:mm:ss').value
})


function urlEncode() {
    encodeForm.urlEncode = encodeURI(encodeForm.urlEncode)
}

function urlDecode() {
    encodeForm.urlEncode = decodeURI(encodeForm.urlEncode)
}

function unicodeEncode() {
    encodeForm.unicodeEncode = escape(encodeForm.unicodeEncode).replace(/\%u/g, '\\u')
}
function unicodeDecode() {
    encodeForm.unicodeEncode = unescape(encodeForm.unicodeEncode.replace(/\\u/g, '\%u'))
}

function setTimestampe() {
    encodeForm.inputTimestamp = encodeForm.currentTimestamp / encodeForm.timestampUnit;
}

const { pause, resume, isActive } = useIntervalFn(() => {
    encodeForm.currentTimestamp = useNow();
}, 1)


onMounted(()=> {

})
</script>

<template>
    <NomalPanel>
        <template #main>

            <el-form :model="encodeForm" label-width="0px">
                <h1>URL编码</h1>
                <el-form-item>
                    <el-input v-model="encodeForm.urlEncode" type="textarea" rows="6" resize="none" show-word-limit
                        maxlength="2000" placeholder="Please input" />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="urlEncode" plain>URL编码</el-button>
                    <el-button type="info" @click="urlDecode" plain>URL解码</el-button>
                    <el-button @click="copied(encodeForm.urlEncode, 1)" plain>复制</el-button>
                </el-form-item>

                <h1>Unicode编码</h1>
                <el-form-item>
                    <el-input v-model="encodeForm.unicodeEncode" type="textarea" rows="6" resize="none" show-word-limit
                        maxlength="2000" placeholder="Please input" />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="unicodeEncode" plain>Unicode编码</el-button>
                    <el-button type="info" @click="unicodeDecode" plain>Unicode解码</el-button>
                    <el-button @click="copied(encodeForm.unicodeEncode, 1)" plain>复制</el-button>
                </el-form-item>

            </el-form>


            <el-form :model="encodeForm" label-position="left" label-width="100px">
                <h1> 时间戳 </h1>
                <el-form-item label="当前时间戳 :">
                    <el-tooltip class="box-item" effect="light" content="双击我" placement="right">
                        <el-tag size="large" @dblclick="setTimestampe">{{
                            encodeForm.currentTimestamp.getTime()
                        }}</el-tag>
                    </el-tooltip>
                </el-form-item>
                <el-form-item label="当前时间 :">
                    <span>{{ encodeForm.currentTime }}</span>
                </el-form-item>
            </el-form>
            <el-form :model="encodeForm" :inline="true" label-position="left" label-width="100px">
                <el-form-item label="时间戳 :">
                    <el-input v-model="encodeForm.inputTimestamp">
                        <template #append>
                            <el-select v-model="encodeForm.timestampUnit" placeholder="Select" style="width: 115px">
                                <el-option label="毫秒" value="1" />
                                <el-option label="秒" value="1000" />
                            </el-select>
                        </template>
                    </el-input>
                </el-form-item>
                <el-form-item label="标准时间 :">
                    <el-input v-model="encodeForm.datetime" disabled>
                        <template #append>
                            <el-button @click="copy(encodeForm.datetime)" plain>复制</el-button>
                        </template>
                    </el-input>
                </el-form-item>
            </el-form>

            <el-form :model="encodeForm" :inline="true" label-position="left" label-width="100px">
                <el-form-item label="标准时间 :">
                    <el-date-picker v-model="encodeForm.stDate" type="datetime" placeholder="选择时间" />
                </el-form-item>
                <el-form-item label="时间戳 :">
                    <el-input v-model="encodeForm.stTimestampe" disabled>
                        <template #append>
                            <el-button @click="copy(encodeForm.stTimestampe.toString())" plain>复制</el-button>
                        </template>
                    </el-input>
                </el-form-item>
            </el-form>

        </template>

    </NomalPanel>
</template>

<style scoped>
.el-textarea {
    --el-input-bg-color: var(--el-fill-color);
    --el-fill-color-blank: var(--el-fill-color);
}
</style>
