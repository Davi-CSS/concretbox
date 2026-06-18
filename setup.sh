#!/bin/bash

# ─────────────────────────────────────────────
#  ConcretBox — setup.sh
#  Roda na raiz do projeto (onde este arquivo está)
#  Requisitos: PHP 8.2+, Composer, Node 18+, npm
# ─────────────────────────────────────────────

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

ok()   { echo -e "${GREEN}✔${NC} $1"; }
info() { echo -e "${CYAN}→${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
err()  { echo -e "${RED}✘ ERRO:${NC} $1"; exit 1; }
step() { echo -e "\n${BOLD}$1${NC}"; }

echo -e "${BOLD}"
echo "  ██████╗ ██████╗ ███╗   ██╗ ██████╗██████╗ ███████╗████████╗██████╗  ██████╗ ██╗  ██╗"
echo "  ██╔════╝██╔═══██╗████╗  ██║██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗╚██╗██╔╝"
echo "  ██║     ██║   ██║██╔██╗ ██║██║     ██████╔╝█████╗     ██║   ██████╔╝██║   ██║ ╚███╔╝ "
echo "  ██║     ██║   ██║██║╚██╗██║██║     ██╔══██╗██╔══╝     ██║   ██╔══██╗██║   ██║ ██╔██╗ "
echo "  ╚██████╗╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗   ██║   ██████╔╝╚██████╔╝██╔╝ ██╗"
echo "   ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝  ╚═════╝ ╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "  Registro diário de metragem de concreto\n"

# ── Verificar dependências ─────────────────────
step "[ 1/6 ] Verificando dependências"

command -v php      >/dev/null 2>&1 || err "PHP não encontrado. Instale PHP 8.2+."
command -v composer >/dev/null 2>&1 || err "Composer não encontrado. Instale em https://getcomposer.org"
command -v node     >/dev/null 2>&1 || err "Node.js não encontrado. Instale Node 18+."
command -v npm      >/dev/null 2>&1 || err "npm não encontrado."

PHP_VER=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
NODE_VER=$(node -e "process.stdout.write(process.version.slice(1).split('.')[0])")

ok "PHP $PHP_VER"
ok "Composer $(composer --version --no-ansi 2>/dev/null | awk '{print $3}')"
ok "Node $NODE_VER"
ok "npm $(npm --version)"

# ── Salvar arquivos do ConcretBox antes de sobrescrever ───
TEMP_BACKEND="$ROOT_DIR/.cb_backend_files"
TEMP_FRONTEND="$ROOT_DIR/.cb_frontend_files"

mkdir -p "$TEMP_BACKEND" "$TEMP_FRONTEND"

# Copiar arquivos do backend para temporário
cp -r "$ROOT_DIR/backend/app"       "$TEMP_BACKEND/" 2>/dev/null || true
cp -r "$ROOT_DIR/backend/config"    "$TEMP_BACKEND/" 2>/dev/null || true
cp -r "$ROOT_DIR/backend/routes"    "$TEMP_BACKEND/" 2>/dev/null || true
cp -r "$ROOT_DIR/backend/database"  "$TEMP_BACKEND/" 2>/dev/null || true
cp    "$ROOT_DIR/backend/Procfile"  "$TEMP_BACKEND/" 2>/dev/null || true
cp    "$ROOT_DIR/backend/.env.example" "$TEMP_BACKEND/" 2>/dev/null || true
cp    "$ROOT_DIR/backend/composer.json" "$TEMP_BACKEND/composer.json.cb" 2>/dev/null || true

# Copiar arquivos do frontend para temporário
cp -r "$ROOT_DIR/frontend/src"      "$TEMP_FRONTEND/" 2>/dev/null || true
cp    "$ROOT_DIR/frontend/vercel.json"   "$TEMP_FRONTEND/" 2>/dev/null || true
cp    "$ROOT_DIR/frontend/.env.example"  "$TEMP_FRONTEND/" 2>/dev/null || true

# ── Backend: criar projeto Laravel ────────────
step "[ 2/6 ] Criando projeto Laravel 11 no backend/"

cd "$ROOT_DIR"

if [ -f "$ROOT_DIR/backend/artisan" ]; then
  warn "Laravel já instalado em backend/ — pulando criação."
else
  info "Rodando: composer create-project laravel/laravel backend"
  rm -rf "$ROOT_DIR/backend"
  composer create-project laravel/laravel backend --prefer-dist --no-interaction -q
  ok "Laravel criado"
fi

# ── Backend: injetar arquivos do ConcretBox ───
step "[ 3/6 ] Injetando arquivos do ConcretBox no backend"

cd "$ROOT_DIR/backend"

# Models
mkdir -p app/Models
cp -f "$TEMP_BACKEND/app/Models/Registro.php" app/Models/Registro.php
ok "Model Registro"

# Controller
mkdir -p app/Http/Controllers
cp -f "$TEMP_BACKEND/app/Http/Controllers/RegistroController.php" app/Http/Controllers/RegistroController.php
ok "Controller RegistroController"

# Config CORS
cp -f "$TEMP_BACKEND/config/cors.php" config/cors.php
ok "Config CORS"

# Routes API
cp -f "$TEMP_BACKEND/routes/api.php" routes/api.php
ok "Routes api.php"

# Migration
mkdir -p database/migrations
cp -f "$TEMP_BACKEND/database/migrations/"*.php database/migrations/ 2>/dev/null || true
ok "Migration registros"

# Procfile
cp -f "$TEMP_BACKEND/Procfile" Procfile
ok "Procfile"

# .env
if [ ! -f .env ]; then
  cp "$TEMP_BACKEND/.env.example" .env.example
  cp .env.example .env
  ok ".env criado a partir do .env.example"
else
  warn ".env já existe — não sobrescrito."
fi

# Gerar APP_KEY
info "Gerando APP_KEY..."
php artisan key:generate --force -q
ok "APP_KEY gerada"

# ── Frontend: criar projeto Vue 3 ─────────────
step "[ 4/6 ] Criando projeto Vue 3 no frontend/"

cd "$ROOT_DIR"

if [ -f "$ROOT_DIR/frontend/vite.config.js" ] && [ -d "$ROOT_DIR/frontend/node_modules" ]; then
  warn "Frontend já configurado — pulando criação."
else
  info "Rodando: npm create vue@latest"
  rm -rf "$ROOT_DIR/frontend"

  # Criar via npm init vue com flags para não pedir interação
  npm create vue@latest frontend -- \
    --router \
    --pinia \
    --no-ts \
    --no-jsx \
    --no-vitest \
    --no-eslint \
    --no-playwright \
    --force 2>/dev/null || {
      # fallback: scaffold manual se o --force não funcionar
      mkdir -p frontend
      cd frontend
      npm init -y -q
    }

  ok "Vue 3 criado"
fi

# ── Frontend: injetar arquivos do ConcretBox ──
step "[ 5/6 ] Injetando arquivos do ConcretBox no frontend"

cd "$ROOT_DIR/frontend"

# Apagar views e stores geradas pelo scaffold (vamos substituir)
rm -rf src/views src/stores src/components src/router src/services src/assets 2>/dev/null || true
mkdir -p src/views src/stores src/router src/services

cp -f "$TEMP_FRONTEND/src/main.js"           src/main.js
cp -f "$TEMP_FRONTEND/src/App.vue"           src/App.vue
cp -f "$TEMP_FRONTEND/src/router/index.js"   src/router/index.js
cp -f "$TEMP_FRONTEND/src/services/api.js"   src/services/api.js
cp -f "$TEMP_FRONTEND/src/stores/registros.js" src/stores/registros.js
cp -f "$TEMP_FRONTEND/src/views/Home.vue"    src/views/Home.vue
cp -f "$TEMP_FRONTEND/src/views/Historico.vue" src/views/Historico.vue
cp -f "$TEMP_FRONTEND/vercel.json"           vercel.json

ok "Arquivos Vue injetados"

# .env.local do frontend
if [ ! -f .env.local ]; then
  cp "$TEMP_FRONTEND/.env.example" .env.example
  cp .env.example .env.local
  ok ".env.local criado (configure VITE_API_URL)"
else
  warn ".env.local já existe — não sobrescrito."
fi

info "Instalando dependências npm (Vue, Vite, Pinia, Router, Axios)..."
npm install -q
npm install axios -q
ok "Dependências instaladas"

# ── Limpeza ───────────────────────────────────
rm -rf "$TEMP_BACKEND" "$TEMP_FRONTEND"

# ── Resumo final ──────────────────────────────
step "[ 6/6 ] Tudo pronto!"

echo ""
echo -e "${GREEN}${BOLD}ConcretBox configurado com sucesso!${NC}"
echo ""
echo -e "${BOLD}Próximos passos:${NC}"
echo ""
echo -e "  ${CYAN}Backend${NC}"
echo    "  1. Abra backend/.env e configure o banco MySQL:"
echo    "     DB_DATABASE=concretbox"
echo    "     DB_USERNAME=seu_usuario"
echo    "     DB_PASSWORD=sua_senha"
echo    ""
echo    "  2. Rode a migration:"
echo    "     cd backend && php artisan migrate"
echo    ""
echo    "  3. Suba o servidor local:"
echo    "     cd backend && php artisan serve"
echo    ""
echo -e "  ${CYAN}Frontend${NC}"
echo    "  4. Abra frontend/.env.local e configure:"
echo    "     VITE_API_URL=http://localhost:8000/api"
echo    ""
echo    "  5. Suba o servidor local:"
echo    "     cd frontend && npm run dev"
echo    ""
echo -e "  ${CYAN}Deploy${NC}"
echo    "  • Backend  → Railway  (setar variáveis do .env no painel)"
echo    "  • Frontend → Vercel   (root: frontend/, build: npm run build, output: dist)"
echo    "  • Lembre de atualizar VITE_API_URL e FRONTEND_URL com as URLs reais"
echo ""
