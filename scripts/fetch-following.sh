#!/bin/bash
# Fetch the list of users the owner is following from GitHub API
# Uses unauthenticated requests (works for public profiles, 60 requests/hour limit)

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

REPO_OWNER=$(get_repo_owner)

echo "Fetching following list for: $REPO_OWNER" >&2

page=1
all_following="[]"

while true; do
  # Use unauthenticated request - works for public user data
  response=$(curl -s -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/users/$REPO_OWNER/following?per_page=100&page=$page")
  
  # Check for error response
  if echo "$response" | jq -e '.message' > /dev/null 2>&1; then
    error_msg=$(echo "$response" | jq -r '.message')
    echo "GitHub API error: $error_msg" >&2
    # Return empty array on error
    echo "[]"
    exit 0
  fi
  
  if ! echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    echo "Error: Invalid response from GitHub API" >&2
    echo "Response: $response" >&2
    echo "[]"
    exit 0
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
