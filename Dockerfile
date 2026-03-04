# Stage 1: Install
FROM oven/bun:1.1.20 AS base
WORKDIR /app
COPY . .
RUN bun install --frozen-lockfile

# Stage 2: Build
# Dokploy pulls from the "Build-time Arguments" tab into these ARGs:
ARG NEXT_PUBLIC_APP_URL
ARG BETTER_AUTH_SECRET
ARG ALLOW_SIGNIN_SIGNUP
ARG DATABASE_URL

# Map them to ENVs so the Bun/Turbo process can see them
ENV NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL
ENV BETTER_AUTH_SECRET=$BETTER_AUTH_SECRET
ENV ALLOW_SIGNIN_SIGNUP=$ALLOW_SIGNIN_SIGNUP
ENV DATABASE_URL=$DATABASE_URL
ENV NODE_ENV=production
ENV SKIP_ENV_VALIDATION=1

ENV TSUP_SKIP_DTS=1

# This will now find ALLOW_SIGNIN_SIGNUP and stop complaining
RUN bun run build

# Stage 3: Runner
FROM oven/bun:1.1.20-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
COPY --from=base /app ./
RUN mkdir -p /app/data
EXPOSE 3000
CMD ["bun", "run", "start"]