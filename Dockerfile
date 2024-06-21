ARG VERSION=2

FROM cloudron/base:4.2.0@sha256:46da2fffb36353ef714f97ae8e962bd2c212ca091108d768ba473078319a47f4 as base

FROM langfuse/langfuse:${VERSION} as langfuse

FROM base

ENV NODE_ENV production
WORKDIR /app/code

RUN npm install -g --no-package-lock --no-save prisma

COPY --from=langfuse ./app ./langfuse

COPY env.sh.template start.sh /app/pkg/

CMD [ "/app/pkg/start.sh" ]
