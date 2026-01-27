# GitHub Actions Workflows for .social Repositories

This is a template repository of OctoTown's `.social` protocol, containing the GitHub Actions workflows that users need to maintain their feeds.

## Workflows

The sync process is split into two independent workflows:

### `profile-sync.yml`
Runs every **30 minutes** to sync profile data for followed users.
- Fetches your following list from GitHub API
- Caches profile data in `following/*.yml` files (24-hour TTL)
- Commits changes to `following/` directory

### `feed-sync.yml`
Runs every **5 minutes** to sync posts from followed users.
- Reads cached profiles from `following/*.yml`
- Fetches recent posts (Issues with `post:` or `repost:` prefixes) from their `.social` repos
- Writes posts to `feed/*.md` files
- Archives posts older than 7 days
- Commits changes to `feed/` directory

**Why two workflows?**
- Profiles change infrequently → less frequent sync saves API calls
- Posts need faster updates → more frequent sync
- Separate files touched → fewer git conflicts
- Independent failures → one can fail without blocking the other

## Scripts

The sync logic is modularized into separate scripts:

| Script | Purpose | Used by |
|--------|---------|---------|
| `scripts/profile-sync.sh` | Orchestrates profile sync workflow | `profile-sync.yml` |
| `scripts/feed-sync.sh` | Orchestrates feed sync workflow | `feed-sync.yml` |
| `scripts/main.sh` | Runs both syncs (for local testing) | Manual use |
| `scripts/config.sh` | Shared configuration and helpers | All scripts |
| `scripts/fetch-following.sh` | Fetches following list from GitHub API | `profile-sync.sh` |
| `scripts/sync-profiles.sh` | Fetches and caches profile data | `profile-sync.sh` |
| `scripts/write-profile.js` | Writes profile YAML files | `sync-profiles.sh` |
| `scripts/sync-feed.js` | Fetches and writes feed posts | `feed-sync.sh` |
| `scripts/archive-old-posts.sh` | Archives posts older than 7 days | `feed-sync.sh` |

## Social Graph

OctoTown uses GitHub's native follow system instead of managing followers/following in the repository. Simply follow users on GitHub, and if they have a `.social` repository, their posts will appear in your feed!

## Installation

1. Create a new repository named `.social` on your GitHub account
2. Copy the contents of this template into your `.social` repository
3. Enable GitHub Actions in your repository settings
4. The workflows will run automatically on their schedules

**Note:** The workflows use GitHub's public API to fetch your following list (no authentication required for public profiles). The default `GITHUB_TOKEN` is only used for repository operations like fetching issues and committing updates.
