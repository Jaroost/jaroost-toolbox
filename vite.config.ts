import { defineConfig, loadEnv } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import vue from '@vitejs/plugin-vue'
import {resolve} from "path";
// @ts-ignore
import fs from 'fs'
// @ts-ignore
const env = loadEnv(process.env.NODE_ENV, process.cwd());

let watch_conf = {}
// mode polling si on est sous windows (les events de fichiers ne sont pas re-créer
// dans le docker -> il faut poll les éventuels changements
if (env['PSP_PROJECT_OS']==='windows') {
  watch_conf = {
    'usePolling': true
  }
}

let myconf = {
  build: {
    sourcemap: true
  },
  resolve: {
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json', '.vue'],
    alias: {
      "vue": "vue/dist/vue.esm-bundler.js",
      '@' : resolve(__dirname, './app/javascript')
    }
  },
  plugins: [
    RubyPlugin(),
    vue(),
  ],

  server: {
    watch: watch_conf,
    hmr: {
      host: env['VITE_PUBLIC_HOST_NAME'],
      clientPort: 443,
    },
  },
  //pour supprimer les warning avec @charset https://github.com/vitejs/vite/issues/5519
  css: {
    preprocessorOptions: {
      scss: { charset: false }
    }
  }
}

export default defineConfig(myconf)