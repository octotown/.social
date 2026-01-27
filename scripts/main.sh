#!/bin/bash
# Main orchestrator script for OctoTown (runs both profile and feed sync)
# This script is kept for manual/local testing. In production, use:
#   - profile-sync.sh (runs every 30 min)
#   - feed-sync.sh (runs every 5 min)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== OctoTown Full Sync ==="
echo "Started at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# Run profile sync
"$SCRIPT_DIR/profile-sync.sh"
echo ""

# Run feed sync
"$SCRIPT_DIR/feed-sync.sh"
echo ""

echo "=== Full Sync Complete ==="
echo "Finished at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"

echo "=== Feed sync complete ==="
echo "Finished at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
