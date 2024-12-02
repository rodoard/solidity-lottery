import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [sveltekit()],
  define: {
    "process.env": {}, // polyfill for web3modal
  },
  server: {
    port: process.env.PORT!== undefined ?  Number(process.env.PORT) : 3000,
    fs: {
      allow: [".."],
    },
  },
});
