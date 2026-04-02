#!/bin/sh
set -e

# Fetch xoxp- token from the backend API
if [ -n "$TOKEN_API_URL" ] && [ -n "$RICK_API_KEY" ]; then
  echo "Fetching Slack token from backend..."

  # Retry up to 5 times (backend may be waking up on Render free tier)
  ATTEMPTS=0
  MAX_ATTEMPTS=5
  TOKEN=""

  while [ $ATTEMPTS -lt $MAX_ATTEMPTS ] && [ -z "$TOKEN" ]; do
    ATTEMPTS=$((ATTEMPTS + 1))
    echo "Attempt $ATTEMPTS/$MAX_ATTEMPTS..."

    RESPONSE=$(curl -s --max-time 30 -H "Authorization: Bearer $RICK_API_KEY" "$TOKEN_API_URL" 2>&1) || true

    TOKEN=$(echo "$RESPONSE" | grep -o '"token":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -z "$TOKEN" ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; then
      echo "Backend not ready, retrying in 10s..."
      sleep 10
    fi
  done

  if [ -z "$TOKEN" ]; then
    echo "ERROR: Failed to fetch token after $MAX_ATTEMPTS attempts"
    echo "Last response: $RESPONSE"
    exit 1
  fi

  export SLACK_MCP_XOXP_TOKEN="$TOKEN"
  echo "Token loaded successfully"
else
  echo "TOKEN_API_URL or RICK_API_KEY not set, falling back to env vars"
fi

exec mcp-server "$@"
