#!/bin/bash
# BrandingForge Social - Startup script optimized for 512MB RAM
# Skips orchestrator (Temporal) to reduce memory footprint
# Limits Node.js heap size per process

set -e

echo "==> Running Prisma database push..."
pnpm dlx prisma@6.5.0 db push --accept-data-loss --schema ./libraries/nestjs-libraries/src/database/prisma/schema.prisma

echo "==> Starting nginx..."
nginx

echo "==> Starting backend with memory limit..."
NODE_OPTIONS="--max-old-space-size=200" pm2 start pnpm --name backend -- --filter ./apps/backend run start

echo "==> Starting frontend with memory limit..."
NODE_OPTIONS="--max-old-space-size=200" pm2 start pnpm --name frontend -- --filter ./apps/frontend run start

echo "==> All services started. Tailing PM2 logs..."
pm2 logs
