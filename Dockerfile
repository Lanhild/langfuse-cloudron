ARG VERSION=2

FROM cloudron/base:4.2.0@sha256:46da2fffb36353ef714f97ae8e962bd2c212ca091108d768ba473078319a47f4 AS base

FROM langfuse/langfuse:${VERSION} AS langfuse

FROM base

ENV NODE_ENV production
WORKDIR /app/code

ARG NODE_VERSION=20.15.1
RUN mkdir -p /usr/local/node-${NODE_VERSION} && curl -L https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz | tar zxf - --strip-components 1 -C /usr/local/node-${NODE_VERSION}
ENV PATH /usr/local/node-${NODE_VERSION}/bin:$PATH

RUN npm --global install pnpm

RUN pnpm install prisma prisma-erd-generator prisma-kysely

COPY --from=langfuse ./app ./langfuse

RUN npx prisma generate --schema=/app/code/langfuse/packages/shared/prisma/schema.prisma

COPY env.sh.template start.sh /app/pkg/

CMD [ "/app/pkg/start.sh" ]
