import { defineConfig } from 'vite';
import solidPlugin from 'vite-plugin-solid';

export default defineConfig({
  plugins: [solidPlugin()],
  server: {
    port: 3001,
  },
  build: {
    target: 'esnext',
    outDir: '../public',
    emptyOutDir: false,
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './vitest.setup.ts',
    testTransformMode: {
      web: ['tsx', 'ts'],
    },
  },
});
