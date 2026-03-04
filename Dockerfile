# Stage 1: Dependencies + Build
FROM oven/bun:1.3.2 AS builder
WORKDIR /app

COPY . .
RUN bun install

# Build-time environment variables (non-secret ones only)
ARG NEXT_PUBLIC_APP_URL
ENV NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL
ENV NODE_ENV=production
ENV SKIP_ENV_VALIDATION=1

# Runtime secrets passed at build time (required by Next.js static analysis)
ARG BETTER_AUTH_SECRET
ARG ALLOW_SIGNIN_SIGNUP
ARG DATABASE_URL
ENV BETTER_AUTH_SECRET=$BETTER_AUTH_SECRET
ENV ALLOW_SIGNIN_SIGNUP=$ALLOW_SIGNIN_SIGNUP
ENV DATABASE_URL=$DATABASE_URL

RUN mkdir -p /app/data
RUN bun run build

# Stage 2: Runner
FROM oven/bun:1.3.2-slim AS runner
ENV NODE_ENV=production
ENV PORT=3000

WORKDIR /app
COPY --from=builder /app ./
RUN mkdir -p /app/data

WORKDIR /app/apps/web
EXPOSE 3000
CMD ["bun", "run", "start"]