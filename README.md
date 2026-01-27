# GitHub Actions Workflows for .social Repositories

This is a template repository of OctoTown's `.social` protocol, containing the GitHub Actions workflow that users need to maintain their feeds.

## Workflows

### `feed-sync.yml`
Runs every 5 minutes to sync posts from followed users into the local feed. Uses GitHub's REST API (`GET /users/{username}/following`) to determine which users to fetch posts from.

## Social Graph

OctoTown uses GitHub's native follow system instead of managing followers/following in the repository. Simply follow users on GitHub, and if they have a `.social` repository, their posts will appear in your feed!

## Installation

Clone this repository into your own `.social` repository.
