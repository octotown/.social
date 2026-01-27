#!/bin/bash
# Sync profile data for followed users

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

ensure_directories

# Read following list from stdin or argument
if [ -n "$1" ]; then
  all_following="$1"
else
  all_following=$(cat)
fi

HIDDEN_USERS=$(get_hidden_users)
CURRENT_FOLLOWING=""

echo "Processing followed users..."

echo "$all_following" | jq -c '.[]' | while read -r user_obj; do
  username=$(echo "$user_obj" | jq -r '.login')
  
  # Skip if hidden
  if [ -n "$HIDDEN_USERS" ] && echo "$username" | grep -qE "^($HIDDEN_USERS)$"; then
    echo "Skipping hidden user: $username"
    continue
  fi
  
  # Track current following (write to temp file for cleanup step)
  echo "$username" >> /tmp/current_following.txt
  
  PROFILE_FILE="$FOLLOWING_DIR/$username.yml"
  
  # Check if we have a cached profile and if it's still fresh
  NEEDS_REFRESH="true"
  if [ -f "$PROFILE_FILE" ]; then
    cached_timestamp=$(grep "^last_updated:" "$PROFILE_FILE" | sed 's/last_updated: //' || echo "")
    if [ -n "$cached_timestamp" ]; then
      cache_epoch=$(date -d "$cached_timestamp" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$cached_timestamp" +%s 2>/dev/null || echo "0")
      now_epoch=$(date +%s)
      age_hours=$(( (now_epoch - cache_epoch) / 3600 ))
      
      if [ "$age_hours" -lt "$PROFILE_REFRESH_HOURS" ]; then
        echo "Using cached profile for: $username (${age_hours}h old)"
        NEEDS_REFRESH="false"
      fi
    fi
  fi
  
  if [ "$NEEDS_REFRESH" = "true" ]; then
    echo "Fetching profile for: $username"
    
    # Fetch full user profile
    profile=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/users/$username")
    
    # Check if user has a .social repository
    social_repo=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$username/.social")
    
    has_social="false"
    if [ "$social_repo" = "200" ]; then
      has_social="true"
    fi
    
    # Extract profile fields and write YAML
    node "$SCRIPT_DIR/write-profile.js" "$PROFILE_FILE" "$has_social" <<< "$profile"
  fi
done

# Clean up profiles for unfollowed users
echo "Cleaning up unfollowed users..."
for profile_file in "$FOLLOWING_DIR"/*.yml; do
  if [ ! -f "$profile_file" ]; then
    continue
  fi
  
  username=$(basename "$profile_file" .yml)
  if [ -f /tmp/current_following.txt ]; then
    if ! grep -qw "$username" /tmp/current_following.txt; then
      echo "Removing unfollowed user: $username"
      rm "$profile_file"
    fi
  fi
done

# Clean up temp file
rm -f /tmp/current_following.txt
