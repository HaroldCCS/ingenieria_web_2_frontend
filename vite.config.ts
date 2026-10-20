import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  // En desarrollo (pnpm dev) Vite reenvía /api a la API, igual que Nginx en Docker:
  // el navegador ve un solo origen y no hace falta CORS.
  const apiTarget = env.VITE_DEV_API_TARGET || 'http://localhost:8000'

  return {
    plugins: [
      tailwindcss(),
      react({
        babel: {
          plugins: [['babel-plugin-react-compiler']],
        },
      }),
    ],
    server: {
      proxy: {
        '/api': { target: apiTarget, changeOrigin: true },
      },
    },
  }
})
