<script setup>
import { onMounted,onBeforeMount, ref } from 'vue';

import { f7Page, f7Navbar, f7, f7Icon, f7List, f7ListItem, f7Link, f7BlockTitle } from 'framework7-vue';


onBeforeMount(() => {
    
})
</script>

<template>
    <f7-page>
        <f7-navbar>
        </f7-navbar>

        <f7-list dividers-ios class="mt-1">
            <f7-list-item title="管理" link="#">
                <template #media>
                    <f7-icon :size="22" f7="list_dash" />
                </template>

            </f7-list-item>

            <f7-list-item title="关于" link="#">
                <template #media>
                    <f7-icon :size="22" f7="info_circle" />
                </template>
            </f7-list-item>
            <f7-list-item panel-close title="设置" link="/settings" view="#main">
                <template #media>
                    <f7-icon :size="22" f7="gear" />
                </template>
            </f7-list-item>
        </f7-list>

    </f7-page>
</template>

<style scoped></style>