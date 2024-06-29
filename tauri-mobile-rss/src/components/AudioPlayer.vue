<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
const props = defineProps({
  audioSrc: {
    type: String,
    required: true
  }
});

const audioRef = ref(null);
const isPlaying = ref(false);
const progress = ref(0);

// 控制播放或暂停
const playOrPause = () => {
  if (audioRef.value.paused) {
    audioRef.value.play();
    isPlaying.value = true;
  } else {
    audioRef.value.pause();
    isPlaying.value = false;
  }
};

// 更新播放进度条
const onTimeUpdate = () => {
  progress.value = audioRef.value.currentTime / audioRef.value.duration * 100;
};

// 进度条手动调整时更新音频播放位置
const updateProgress = (event) => {
  audioRef.value.currentTime = event.target.value / 100 * audioRef.value.duration;
};

// 音频结束时重置进度
const onEnded = () => {
  progress.value = 0;
  isPlaying.value = false;
};

onMounted(() => {
  audioRef.value.addEventListener('loadedmetadata', () => {
    progress.value = 0;
  });
});

onUnmounted(() => {
  audioRef.value.removeEventListener('loadedmetadata', () => { });
});
</script>

<template>
  <div class="audio-player">
    <audio ref="audioRef" :src="props.audioSrc" @timeupdate="onTimeUpdate" @ended="onEnded"></audio>
    <button @click="playOrPause">{{ isPlaying ? 'Pause' : 'Play' }}</button>
    <input type="range" min="0" max="100" v-model="progress" @input="updateProgress" />
  </div>
</template>



<style scoped>
.audio-player {
  /* 添加自定义样式 */
}
</style>