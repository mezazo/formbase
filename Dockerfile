# Stage 1: Install
FROM oven/bun:1.1.20 AS base
WORKDIR /app

# Copy all files from your fork
COPY . .

# Install dependencies
RUN bun install --frozen-lockfile

# Stage 2: Build
# These ARGs must be passed by Dokploy during build time
ARG NEXT_PUBLIC_APP_URL
ARG BETTER_AUTH_SECRET
ARG DATABASE_URL="file:/app/data/formbase.db"

# We set them as ENV so the build scripts can see them
ENV NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL
ENV BETTER_AUTH_SECRET=$BETTER_AUTH_SECRET
ENV DATABASE_URL=$DATABASE_URL
ENV NODE_ENV=production

# SKIP_ENV_VALIDATION=1 is the "magic" flag for T3/Next.js apps 
# to stop them from crashing during the Docker build if Envs are missing.
RUN SKIP_ENV_VALIDATION=1 bun run build

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

# Start the app
CMD ["bun", "run", "start"]