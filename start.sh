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

if [[ ! -f /app/data/.encryption_key ]]; then
  echo "=> Generating ENCRYPTION_KEY"
  openssl rand -hex 32 > /app/data/.encryption_key
fi

echo "=> Loading configuration"
export NEXTAUTH_SECRET="$(cat /app/data/.nextauth_secret)"
export SALT="$(cat /app/data/.salt)"
export ENCRYPTION_KEY="$(cat /app/data/.encryption_key)"
export DATABASE_URL="$CLOUDRON_POSTGRESQL_URL"
export NEXTAUTH_URL="$CLOUDRON_APP_ORIGIN"

# What's the syntax? Pending question in upstream's Discord.
export SMTP_CONNECTION_URL=""

[[ ! -f /app/data/env.sh ]] && cp /app/pkg/env.sh.template /app/data/env.sh

# Overrides
source /app/data/env.sh

echo "=> Setting permissions"
chown -R cloudron:cloudron /app/data /run/*.npm

echo "=> Applying migrations"
/app/code/node_modules/.bin/prisma db execute --url "$DATABASE_URL" --file "/app/code/langfuse/packages/shared/scripts/cleanup.sql"
DIRECT_URL="$DATABASE_URL" /app/code/node_modules/.bin/prisma migrate deploy --schema=/app/code/langfuse/packages/shared/prisma/schema.prisma

echo "=> Starting Langfuse"
exec gosu cloudron:cloudron node /app/code/langfuse/web/server.js
