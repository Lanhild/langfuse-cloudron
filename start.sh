#!/bin/bash

set -eu

echo "=> Ensure directories"
mkdir -p /app/data

if [[ ! -f /app/data/.salt ]]; then
  echo "=> Generating password salt"
  openssl rand -base64 32 > /app/data/.salt
fi

if [[ ! -f /app/data/.nextauth_secret ]]; then
  echo "=> Generating NEXTAUTH_SECRET"
  openssl rand -base64 32 > /app/data/.nextauth_secret
fi

echo "=> Loading configuration"
export NEXTAUTH_SECRET="$(cat /app/data/.nextauth_secret)"
export SALT="$(cat /app/data/.salt)"
export DATABASE_URL="$CLOUDRON_POSTGRESQL_URL"
export NEXTAUTH_URL="$CLOUDRON_APP_ORIGIN"

[[ ! -f /app/data/env.sh ]] && cp /app/pkg/env.sh.template /app/data/env.sh

# Overrides
source /app/data/env.sh

echo "=> Setting permissions"
chown -R cloudron:cloudron /app/data /run/*.npm

echo "=> Applying migrations"
prisma db execute --url "$DATABASE_URL" --file "/app/code/langfuse/packages/shared/scripts/cleanup.sql"
DIRECT_URL="$DATABASE_URL" prisma migrate deploy --schema=/app/code/langfuse/packages/shared/prisma/schema.prisma

echo "=> Starting Langfuse"
exec gosu cloudron:cloudron node /app/code/langfuse/web/server.js
