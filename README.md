# GitHub Actions Workflows for .social Repositories

This is a template repository of OctoTown's `.social` protocol, containing the GitHub Actions workflow that users need to maintain their feeds.

## Workflows

### `feed-sync.yml`
Runs every 5 minutes to sync posts from followed users into the local feed. Uses GitHub's REST API (`GET /users/{username}/following`) to determine which users to fetch posts from.

## Scripts

The feed sync logic is modularized into separate scripts for easier maintenance:

| Script | Description |
|--------|-------------|
| `scripts/main.sh` | Main orchestrator that runs all sync steps |
| `scripts/config.sh` | Shared configuration and helper functions |
| `scripts/fetch-following.sh` | Fetches the list of followed users from GitHub API |
| `scripts/sync-profiles.sh` | Syncs profile data for followed users |
| `scripts/write-profile.js` | Node.js helper to write profile YAML files |
| `scripts/sync-feed.js` | Node.js script to sync feed posts |
| `scripts/archive-old-posts.sh` | Archives posts older than 7 days |

## Social Graph

OctoTown uses GitHub's native follow system instead of managing followers/following in the repository. Simply follow users on GitHub, and if they have a `.social` repository, their posts will appear in your feed!

## Installation

1. Create a new repository named `.social` on your GitHub account
2. Copy the contents of this template into your `.social` repository
3. Enable GitHub Actions in your repository settings
4. The workflow will run automatically every 5 minutes

**Note:** The workflow uses GitHub's public API to fetch your following list (no authentication required for public profiles). The default `GITHUB_TOKEN` is only used for repository operations like fetching issues and committing feed updates.
