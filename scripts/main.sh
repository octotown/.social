#!/bin/bash
# Main orchestrator script for OctoTown feed sync

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== OctoTown Feed Sync ==="
echo "Started at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# Source configuration
source "$SCRIPT_DIR/config.sh"

# Ensure directories exist
ensure_directories

# Step 1: Fetch following list
echo "=== Step 1: Fetching following list ==="
FOLLOWING_LIST=$("$SCRIPT_DIR/fetch-following.sh")

if [ -z "$FOLLOWING_LIST" ] || [ "$FOLLOWING_LIST" = "[]" ]; then
  echo "No users being followed or error fetching list"
  following_count=0
else
  following_count=$(echo "$FOLLOWING_LIST" | jq 'length' 2>/dev/null || echo "0")
fi

echo "Found $following_count users being followed"
echo ""

# Step 2: Sync profiles (only if we have users to process)
if [ "$following_count" -gt 0 ]; then
  echo "=== Step 2: Syncing profiles ==="
  echo "$FOLLOWING_LIST" | "$SCRIPT_DIR/sync-profiles.sh"
  echo ""
else
  echo "=== Step 2: Skipping profile sync (no users) ==="
  echo ""
fi

# Step 3: Sync feed posts
echo "=== Step 3: Syncing feed posts ==="
node "$SCRIPT_DIR/sync-feed.js"
echo ""

# Step 4: Archive old posts
echo "=== Step 4: Archiving old posts ==="
"$SCRIPT_DIR/archive-old-posts.sh"
echo ""

echo "=== Feed sync complete ==="
echo "Finished at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
