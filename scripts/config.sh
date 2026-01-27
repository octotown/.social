#!/bin/bash
# Configuration for OctoTown feed sync

# Directories
export FEED_DIR="./feed"
export ARCHIVE_DIR="./feed/archive"
export LAST_FILE="./feed/.last"
export FOLLOWING_DIR="./following"
export HIDDEN_DIR="./hidden"

# Settings
export DAYS_TO_KEEP=7
export PROFILE_REFRESH_HOURS=24

# Get repository owner from GitHub environment or git config
get_repo_owner() {
  if [ -n "$GITHUB_REPOSITORY" ]; then
    echo "$GITHUB_REPOSITORY" | cut -d'/' -f1
  else
    # Fallback for local testing
    git remote get-url origin 2>/dev/null | sed -n 's/.*github\.com[:/]\([^/]*\)\/.*/\1/p'
  fi
}

# Ensure all required directories exist
ensure_directories() {
  mkdir -p "$FEED_DIR" "$ARCHIVE_DIR" "$FOLLOWING_DIR"
}

# Get list of hidden users as pipe-separated string for grep
get_hidden_users() {
  if [ -d "$HIDDEN_DIR" ]; then
    ls "$HIDDEN_DIR" 2>/dev/null | tr '\n' '|' | sed 's/|$//'
  else
    echo ""
  fi
}
