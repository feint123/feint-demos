/** @type {import('vite').UserConfig} */

import { resolve } from 'path';
import ChildProcess from 'child_process';
import { defineConfig, loadEnv } from 'vite';
import vue from '@vitejs/plugin-vue';
import vueJsx from '@vitejs/plugin-vue-jsx';
import pkg from './package.json';

const __APP_INFO__ = {
  pkg: { name: pkg.name, version: pkg.version },
  lastBuildTime: +new Date(),
  version: ChildProcess.execSync('git rev-parse --short HEAD')
    .toString()
    .replace('\n', ''),
};

export default defineConfig(({ command, mode, env }) => {
  const viteEnv = loadEnv(mode, process.cwd(), '');
  return {
    plugins: [vue(), vueJsx()],

    clearScreen: false,
    // tauri expects a fixed port, fail if that port is not available
    server: {
      port: 1420,
      strictPort: true,
    },
    resolve: {
      alias: {
        '@': resolve(__dirname, '.', 'src'),
      },
    },
    // to make use of `TAURI_DEBUG` and other env variables
    // https://tauri.studio/v1/api/config#buildconfig.beforedevcommand
    envPrefix: ['VITE_', 'TAURI_'],
    build: {
      // Tauri supports es2021
      target: ['es2021', 'chrome100', 'safari13'],
      // don't minify for debug builds
      minify: !process.env.TAURI_DEBUG ? 'esbuild' : false,
      // produce sourcemaps for debug builds
      sourcemap: !!process.env.TAURI_DEBUG,
    },
    define: {
      __APP_ENV__: viteEnv.APP_ENV,
      __APP_INFO__,
    },
  };
});
