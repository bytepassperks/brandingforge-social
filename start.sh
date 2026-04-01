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

# Start nginx and PM2 (backend + frontend)
nginx && pnpm run pm2
