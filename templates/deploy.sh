#!/bin/bash
# JIP Zero-Downtime Deploy — Blue-Green on Single EC2
# Usage: bash deploy.sh <platform-name> <port>
# Example: bash deploy.sh mfpulse 8005
#
# What this does:
# 1. Build new image (with layer cache — fast if only code changed)
# 2. Start new container on a TEMP port (old one keeps running)
# 3. Health check new container (retry 5 times)
# 4. If healthy: swap Nginx upstream → reload → stop old container
# 5. If unhealthy: stop new container, old one never touched. SAFE.

set -e

PLATFORM="$1"
PORT="$2"
TEMP_PORT=$((PORT + 1000))  # e.g., 8005 → 9005

if [ -z "$PLATFORM" ] || [ -z "$PORT" ]; then
    echo "Usage: bash deploy.sh <platform-name> <port>"
    echo "Example: bash deploy.sh mfpulse 8005"
    exit 1
fi

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo ""
echo "═══ Zero-Downtime Deploy: $PLATFORM (port $PORT) ═══"
echo ""

# ── Step 1: Build new image with cache ──
echo -e "${YELLOW}[1/6] Building image (layer-cached)...${NC}"
docker build \
    --cache-from "$PLATFORM:latest" \
    -t "$PLATFORM:new" \
    -t "$PLATFORM:$(date +%Y%m%d-%H%M%S)" \
    .

BUILD_EXIT=$?
if [ $BUILD_EXIT -ne 0 ]; then
    echo -e "${RED}Build failed. Old container untouched. Aborting.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Image built${NC}"

# ── Step 2: Start new container on temp port (old keeps running) ──
echo -e "${YELLOW}[2/6] Starting new container on temp port $TEMP_PORT...${NC}"
docker stop "${PLATFORM}-new" 2>/dev/null || true
docker rm "${PLATFORM}-new" 2>/dev/null || true
docker run -d \
    --name "${PLATFORM}-new" \
    --env-file .env \
    -p "$TEMP_PORT:8080" \
    --restart unless-stopped \
    "$PLATFORM:new"

echo -e "${GREEN}✓ New container started on port $TEMP_PORT${NC}"
echo "  Old container still running on port $PORT — zero downtime so far"

# ── Step 3: Health check new container ──
echo -e "${YELLOW}[3/6] Health checking new container...${NC}"
HEALTHY=false
for i in 1 2 3 4 5 6 7 8 9 10; do
    sleep 3
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$TEMP_PORT/health" 2>/dev/null || echo "000")
    echo "  Attempt $i/10: HTTP $RESPONSE"
    if [ "$RESPONSE" = "200" ]; then
        HEALTHY=true
        break
    fi
done

if [ "$HEALTHY" = false ]; then
    echo -e "${RED}✗ New container failed health check!${NC}"
    echo -e "${RED}  Stopping new container. Old container UNTOUCHED.${NC}"
    docker stop "${PLATFORM}-new" 2>/dev/null || true
    docker rm "${PLATFORM}-new" 2>/dev/null || true
    echo -e "${RED}  DEPLOY ABORTED. Production is still running the old version safely.${NC}"
    echo ""
    echo "  Debug: docker logs ${PLATFORM}-new"
    exit 1
fi
echo -e "${GREEN}✓ New container is healthy${NC}"

# ── Step 4: Swap Nginx upstream ──
echo -e "${YELLOW}[4/6] Swapping Nginx to new container...${NC}"

# Update Nginx config to point to new port
NGINX_CONF="/etc/nginx/sites-available/${PLATFORM}.jslwealth.in"
if [ -f "$NGINX_CONF" ]; then
    # Replace the proxy_pass port
    sudo sed -i "s/proxy_pass http:\/\/127.0.0.1:[0-9]*/proxy_pass http:\/\/127.0.0.1:$TEMP_PORT/" "$NGINX_CONF"
    sudo nginx -t
    if [ $? -ne 0 ]; then
        echo -e "${RED}Nginx config test failed! Reverting...${NC}"
        sudo sed -i "s/proxy_pass http:\/\/127.0.0.1:$TEMP_PORT/proxy_pass http:\/\/127.0.0.1:$PORT/" "$NGINX_CONF"
        docker stop "${PLATFORM}-new" 2>/dev/null || true
        docker rm "${PLATFORM}-new" 2>/dev/null || true
        echo -e "${RED}DEPLOY ABORTED. Old config restored.${NC}"
        exit 1
    fi
    sudo systemctl reload nginx
    echo -e "${GREEN}✓ Nginx reloaded — traffic now going to new container${NC}"
else
    echo -e "${YELLOW}⚠ No Nginx config found at $NGINX_CONF — manual Nginx update needed${NC}"
fi

# ── Step 5: Stop old container ──
echo -e "${YELLOW}[5/6] Stopping old container...${NC}"
# Wait a few seconds for in-flight requests to complete
sleep 5
docker stop "$PLATFORM" 2>/dev/null || true
docker rename "$PLATFORM" "${PLATFORM}-old" 2>/dev/null || true
docker rename "${PLATFORM}-new" "$PLATFORM" 2>/dev/null || true

# Update port mapping: stop and restart with correct port
docker stop "$PLATFORM" 2>/dev/null || true
docker rm "$PLATFORM" 2>/dev/null || true
docker run -d \
    --name "$PLATFORM" \
    --env-file .env \
    -p "$PORT:8080" \
    --restart unless-stopped \
    "$PLATFORM:new"

# Re-point Nginx back to original port
if [ -f "$NGINX_CONF" ]; then
    sudo sed -i "s/proxy_pass http:\/\/127.0.0.1:$TEMP_PORT/proxy_pass http:\/\/127.0.0.1:$PORT/" "$NGINX_CONF"
    sudo systemctl reload nginx
fi

# Clean up old container
docker stop "${PLATFORM}-old" 2>/dev/null || true
docker rm "${PLATFORM}-old" 2>/dev/null || true
echo -e "${GREEN}✓ Old container stopped and cleaned up${NC}"

# ── Step 6: Final verification ──
echo -e "${YELLOW}[6/6] Final verification...${NC}"
sleep 3
FINAL=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/health" 2>/dev/null || echo "000")
if [ "$FINAL" = "200" ]; then
    echo -e "${GREEN}✓ Production healthy on port $PORT${NC}"
else
    echo -e "${RED}✗ WARNING: Production health check returned $FINAL — investigate immediately${NC}"
fi

# Tag the working image as :latest and :previous
docker tag "$PLATFORM:new" "$PLATFORM:latest"
PREV_IMAGE=$(docker images --format '{{.Tag}}' "$PLATFORM" | grep -v new | grep -v latest | head -1)
[ -n "$PREV_IMAGE" ] && echo -e "${GREEN}✓ Rollback available: docker run -d --name $PLATFORM -p $PORT:8080 $PLATFORM:$PREV_IMAGE${NC}"

echo ""
echo -e "${GREEN}═══ Deploy Complete: $PLATFORM on port $PORT ═══${NC}"
echo "  New image: $PLATFORM:latest"
echo "  Rollback:  docker stop $PLATFORM && docker run -d --name $PLATFORM -p $PORT:8080 $PLATFORM:previous"
echo ""
