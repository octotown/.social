#!/bin/bash
# Fetch the list of users the owner is following from GitHub API

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

REPO_OWNER=$(get_repo_owner)

echo "Fetching following list for: $REPO_OWNER"

page=1
all_following="[]"

while true; do
  response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/users/$REPO_OWNER/following?per_page=100&page=$page")
  
  if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    echo "Error fetching following list" >&2
    break
  fi
  
  count=$(echo "$response" | jq 'length')
  if [ "$count" -eq 0 ]; then
    break
  fi
  
  all_following=$(echo "$all_following $response" | jq -s 'add')
  page=$((page + 1))
done

# Output the JSON array
echo "$all_following"
