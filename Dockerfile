# Stage 1: Install
FROM oven/bun:1.1.20 AS base
WORKDIR /app

# Copy all files from your clean fork
COPY . .

# Install dependencies for the monorepo
RUN bun install --frozen-lockfile

# Stage 2: Build
# Inlining build-time vars required by Next.js
ARG NEXT_PUBLIC_APP_URL
ARG BETTER_AUTH_SECRET
ENV NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL
ENV BETTER_AUTH_SECRET=$BETTER_AUTH_SECRET
ENV NODE_ENV=production

# This runs 'turbo build' which uses your clean bun scripts
RUN bun run build

# Stage 3: Runner
FROM oven/bun:1.1.20-slim AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copy the build output
COPY --from=base /app ./

# Create the data folder for SQLite
RUN mkdir -p /app/data

EXPOSE 3000

# Start the app using your clean 'start' script
CMD ["bun", "run", "start"]