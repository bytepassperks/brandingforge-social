#!/bin/bash
# BrandingForge Social - Startup script for Render Standard plan (2GB RAM)
# Runs full Postiz stack: nginx + backend + frontend via PM2
# Temporal is kept disabled until Temporal Cloud is configured

set -e

echo "==> Running Prisma database push..."
pnpm dlx prisma@6.5.0 db push --accept-data-loss --schema ./libraries/nestjs-libraries/src/database/prisma/schema.prisma

echo "==> Starting full Postiz stack (Standard plan - 2GB RAM)..."
# Disable Temporal until Temporal Cloud namespace is configured
export DISABLE_TEMPORAL=true

# Ensure Node.js has enough heap memory (1.5GB of 2GB total)
export NODE_OPTIONS="--max-old-space-size=1536"

# Fix port routing: Render sets PORT (e.g. 10000) which nginx must listen on.
# Backend must use port 3000 and frontend port 4200 (what nginx.conf expects).
RENDER_PORT="${PORT:-5000}"
echo "==> Render PORT=$RENDER_PORT, setting nginx to listen on it..."

# Update nginx config to listen on the Render PORT instead of hardcoded 5000
sed -i "s/listen 5000;/listen ${RENDER_PORT};/" /etc/nginx/nginx.conf

# Create .env file that dotenv-cli reads (backend/orchestrator use "dotenv -e ../../.env").
# This ensures PORT=3000 reaches the backend even though Render injects PORT=10000.
# The .env file is at /app/.env (resolved from apps/backend via ../../.env).
cat > /app/.env << 'ENVEOF'
PORT=3000
DISABLE_TEMPORAL=true
ENVEOF
echo "==> Created /app/.env with PORT=3000 and DISABLE_TEMPORAL=true"

# Also override in shell env so any direct child processes get PORT=3000
export PORT=3000

# Start nginx and PM2 (backend + frontend)
nginx && pnpm run pm2
