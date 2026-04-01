#!/bin/bash
# BrandingForge Social - Startup script optimized for 512MB RAM (Render Starter plan)
# Runs ONLY the backend API (no frontend, no orchestrator) to fit memory constraints
# BrandingForge only needs the Postiz API for cross-posting, not the UI
# Frontend can be enabled by upgrading to Standard plan (2GB RAM)

set -e

echo "==> Running Prisma database push..."
pnpm dlx prisma@6.5.0 db push --accept-data-loss --schema ./libraries/nestjs-libraries/src/database/prisma/schema.prisma

echo "==> Starting backend API (API-only mode for 512MB plan)..."
# Run node directly with 384MB heap limit to ensure NODE_OPTIONS is respected
# pnpm run start -> dotenv -> node chain may not pass NODE_OPTIONS through
# Render injects env vars directly, so dotenv is not needed
cd /app
exec node --max-old-space-size=384 --experimental-require-module ./dist/apps/backend/src/main.js
