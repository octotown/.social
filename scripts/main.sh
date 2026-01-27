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
following_count=$(echo "$FOLLOWING_LIST" | jq 'length')
echo "Found $following_count users being followed"
echo ""

# Step 2: Sync profiles
echo "=== Step 2: Syncing profiles ==="
echo "$FOLLOWING_LIST" | "$SCRIPT_DIR/sync-profiles.sh"
echo ""

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
