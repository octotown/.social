#!/bin/bash
# Archive posts older than DAYS_TO_KEEP

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "Archiving posts older than $DAYS_TO_KEEP days..."

cutoff_date=$(date -u -d "$DAYS_TO_KEEP days ago" +"%Y-%m-%dT%H-%M-%SZ" 2>/dev/null || date -u -v-${DAYS_TO_KEEP}d +"%Y-%m-%dT%H-%M-%SZ")

for file in "$FEED_DIR"/*.md; do
  if [ ! -f "$file" ]; then
    continue
  fi
  
  filename=$(basename "$file")
  # Extract timestamp from filename (first part before the username)
  file_timestamp=$(echo "$filename" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-[0-9]{2}Z')
  
  if [ -n "$file_timestamp" ] && [[ "$file_timestamp" < "$cutoff_date" ]]; then
    echo "Archiving: $filename"
    mv "$file" "$ARCHIVE_DIR/"
  fi
done

echo "Archive complete"
