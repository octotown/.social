#!/bin/bash
# Feed sync script - syncs posts from followed users into local feed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== OctoTown Feed Sync ==="
echo "Started at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# Source configuration
source "$SCRIPT_DIR/config.sh"

# Ensure directories exist
ensure_directories

# Step 1: Sync feed posts from cached profiles
echo "=== Step 1: Syncing feed posts ==="
node "$SCRIPT_DIR/sync-feed.js"
echo ""

# Step 2: Archive old posts
echo "=== Step 2: Archiving old posts ==="
"$SCRIPT_DIR/archive-old-posts.sh"
echo ""

echo "=== Feed Sync Complete ==="
echo "Finished at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
