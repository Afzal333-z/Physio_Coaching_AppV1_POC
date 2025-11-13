import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Build configuration for Android mobile app
export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom'],
          'mediapipe-vendor': []
        }
      }
    }
  }
})