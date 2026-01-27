# GitHub Actions Workflows for .social Repositories

This is a template repository of OctoTown's `.social` protocol, containing the GitHub Actions workflows that users need to maintain their feeds and followers.

## Workflows

### `feed-sync.yml`
Runs every 5 minutes to sync posts from followed users into the local feed.

### `auto-accept-followers.yml`
Automatically accepts follower PRs where the PR author matches the filename being added.

## Installation

Clone this repository into your own `.social` repository.
