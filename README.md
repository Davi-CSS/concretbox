# ConcretBox

Registro diário de metragem de concreto com cálculo de valor.

## Stack

- **Backend:** Laravel 11 + MySQL → Railway
- **Frontend:** Vue 3 + Vite + Axios → Vercel

## Estrutura

```
concretbox/
├── backend/    # Laravel API
└── frontend/   # Vue 3 SPA
```

## Setup local

### Backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

## Deploy

- Backend → Railway (adicionar serviço MySQL + Web)
- Frontend → Vercel (root: `frontend/`, build: `npm run build`, output: `dist`)
