# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) (or [oxc](https://oxc.rs) when used in [rolldown-vite](https://vite.dev/guide/rolldown)) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## React Compiler

The React Compiler is enabled on this template. See [this documentation](https://react.dev/learn/react-compiler) for more information.

Note: This will impact Vite dev & build performances.

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type-aware lint rules:

```js
export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...

      // Remove tseslint.configs.recommended and replace with this
      tseslint.configs.recommendedTypeChecked,
      // Alternatively, use this for stricter rules
      tseslint.configs.strictTypeChecked,
      // Optionally, add this for stylistic rules
      tseslint.configs.stylisticTypeChecked,

      // Other configs...
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

---

## Contenedores (Ingeniería Web II — sesiones 9-10)

> Sección agregada al migrar el proyecto a Docker. El README original de la plantilla de Vite está arriba.

| Archivo | Propósito |
|---|---|
| `Dockerfile` | Multi-etapa: `node:22-alpine` + pnpm compilan; `nginx-unprivileged:1.27-alpine` sirve `dist/` en el puerto **8080** como usuario no root |
| `.dockerignore` | Excluye `node_modules`, `dist`, `.env*` y `.git` del contexto de construcción |
| `nginx.conf` | Plantilla (envsubst) que sirve la SPA y reenvía `/api/` a `API_UPSTREAM` (por defecto `http://api:8000`) |
| `vite.config.ts` | Proxy `/api` → `VITE_DEV_API_TARGET` en `pnpm dev`, para no depender de CORS |
| `.env.example` | Variables públicas de Vite (nunca secretos) |

Levantar todo el stack (web + api + db + redis): ver `../infra/README.md`.

Solo esta imagen:

```bash
docker build --target build -t umb-planifica-web:build .   # etapa con Node (para comparar tamaño)
docker build -t umb-planifica-web:1.0 .
```

Desarrollo local sin Docker: `pnpm install && pnpm dev` (con la API corriendo en `localhost:8000`).
