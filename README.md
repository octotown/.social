# GitHub Actions Workflows for .social Repositories

This repository contains the GitHub Actions workflows that users need to copy to their `.social` repository.

## Workflows

### `feed-sync.yml`
Runs every 5 minutes to sync posts from followed users into the local feed.

### `auto-accept-followers.yml`
Automatically accepts follower PRs where the PR author matches the filename being added.

## Installation

Copy the `.github/workflows/` folder to your `.social` repository as `.github/workflows/`.

Or use this repository as a template for your own `.social` repository.
