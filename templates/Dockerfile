# JIP Standard Dockerfile — Layer-Cached, Zero-Waste
# Dependencies are cached in separate layers. Only code changes trigger rebuilds.
# RULE: Claude must NEVER rewrite this Dockerfile. Only modify code COPY steps if needed.

# ============================================================
# Stage 1: Frontend Build (Next.js)
# ============================================================
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend

# Step 1: Copy ONLY dependency files (cached unless package.json changes)
COPY frontend/package.json frontend/package-lock.json* ./

# Step 2: Install dependencies (THIS LAYER IS CACHED if package.json unchanged)
RUN npm ci --production=false

# Step 3: Copy source code (only this rebuilds on code changes)
COPY frontend/ ./

# Step 4: Build
RUN npm run build

# ============================================================
# Stage 2: Backend Dependencies (Python)
# ============================================================
FROM python:3.11-slim AS backend-deps
WORKDIR /app/backend

# Step 1: Copy ONLY requirements (cached unless requirements.txt changes)
COPY backend/requirements.txt ./

# Step 2: Install dependencies (THIS LAYER IS CACHED if requirements.txt unchanged)
RUN pip install --no-cache-dir -r requirements.txt

# ============================================================
# Stage 3: Final Runtime Image
# ============================================================
FROM python:3.11-slim AS runtime
WORKDIR /app

# Install Nginx
RUN apt-get update && apt-get install -y nginx curl && \
    rm -rf /var/lib/apt/lists/*

# Copy Python dependencies from Stage 2 (cached)
COPY --from=backend-deps /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=backend-deps /usr/local/bin /usr/local/bin

# Copy built frontend from Stage 1 (cached unless frontend code changed)
COPY --from=frontend-build /app/frontend/out /usr/share/nginx/html

# Copy Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy backend code (this is the only layer that changes on most deploys)
COPY backend/ /app/backend/

# Copy startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080

CMD ["/app/start.sh"]
