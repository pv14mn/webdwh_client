FROM node:lts-alpine3.23 AS builder
USER node
WORKDIR /app
COPY ./app/package.json .
RUN npm install
FROM node:lts-alpine3.23 AS runner
USER node
WORKDIR /app
COPY --from=builder /app/node_modules /app/node_modules
