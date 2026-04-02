#!/bin/sh
set -e

# Fetch xoxp- token from the backend API
if [ -n "$TOKEN_API_URL" ] && [ -n "$RICK_API_KEY" ]; then
  echo "Fetching Slack token from backend..."
  RESPONSE=$(curl -sf -H "Authorization: Bearer $RICK_API_KEY" "$TOKEN_API_URL")

  TOKEN=$(echo "$RESPONSE" | grep -o '"token":"[^"]*"' | head -1 | cut -d'"' -f4)

  if [ -z "$TOKEN" ]; then
    echo "ERROR: Failed to fetch token from $TOKEN_API_URL"
    echo "Response: $RESPONSE"
    exit 1
  fi

  export SLACK_MCP_XOXP_TOKEN="$TOKEN"
  echo "Token loaded for workspace"
else
  echo "TOKEN_API_URL or RICK_API_KEY not set, falling back to env vars"
fi

exec mcp-server "$@"
