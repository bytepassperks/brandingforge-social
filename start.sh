#!/bin/bash
# BrandingForge Social - Startup script optimized for 512MB RAM (Render Starter plan)
# Runs ONLY the backend API (no frontend, no orchestrator) to fit memory constraints
# BrandingForge only needs the Postiz API for cross-posting, not the UI
# Frontend can be enabled by upgrading to Standard plan (2GB RAM)

set -e

echo "==> Running Prisma database push..."
pnpm dlx prisma@6.5.0 db push --accept-data-loss --schema ./libraries/nestjs-libraries/src/database/prisma/schema.prisma

echo "==> Starting backend API (API-only mode for 512MB plan)..."
# Give backend 384MB heap - enough for NestJS + Prisma with headroom
# The remaining ~128MB is for OS, Node runtime overhead
export NODE_OPTIONS="--max-old-space-size=384"
cd /app/apps/backend
exec pnpm run start
