#!/usr/bin/env node
/**
 * Sync feed posts from followed users with .social repos
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const FEED_DIR = './feed';
const ARCHIVE_DIR = './feed/archive';
const LAST_FILE = './feed/.last';
const FOLLOWING_DIR = './following';

async function fetchJSON(url) {
  const response = await fetch(url, {
    headers: {
      'Authorization': `token ${process.env.GITHUB_TOKEN}`,
      'Accept': 'application/vnd.github.v3+json'
    }
  });
  return response.json();
}

function getLastSync() {
  if (fs.existsSync(LAST_FILE)) {
    return fs.readFileSync(LAST_FILE, 'utf8').trim();
  }
  // Default to 7 days ago
  const date = new Date();
  date.setDate(date.getDate() - 7);
  return date.toISOString();
}

function getUsersToFetch() {
  const repoOwner = process.env.GITHUB_REPOSITORY?.split('/')[0] || 
    execSync('git remote get-url origin').toString().match(/github\.com[:/]([^/]+)/)?.[1];
  
  const users = [repoOwner];
  
  if (fs.existsSync(FOLLOWING_DIR)) {
    const files = fs.readdirSync(FOLLOWING_DIR).filter(f => f.endsWith('.yml'));
    for (const file of files) {
      const content = fs.readFileSync(path.join(FOLLOWING_DIR, file), 'utf8');
      if (content.includes('has_social_repo: true')) {
        users.push(file.replace('.yml', ''));
      }
    }
  }
  
  return users;
}

function formatTimestamp(isoString) {
  return isoString.replace(/:/g, '-').replace(/\.\d{3}Z$/, 'Z');
}

async function resolveOriginalPost(repostUrl) {
  const match = repostUrl.match(/^https:\/\/github\.com\/([^/]+)\/\.social\/issues\/(\d+)$/);
  if (!match) return null;
  
  let [, user, id] = match;
  let response = await fetchJSON(`https://api.github.com/repos/${user}/.social/issues/${id}`);
  
  // Follow repost chain
  while (response.title?.startsWith('repost:')) {
    const chainUrl = response.title.replace('repost: ', '');
    const chainMatch = chainUrl.match(/^https:\/\/github\.com\/([^/]+)\/\.social\/issues\/(\d+)$/);
    if (!chainMatch) break;
    
    [, user, id] = chainMatch;
    response = await fetchJSON(`https://api.github.com/repos/${user}/.social/issues/${id}`);
  }
  
  return {
    author: user,
    id: id,
    url: response.html_url,
    timestamp: response.created_at,
    content: response.title?.startsWith('post:') ? response.title.replace('post: ', '') : response.title
  };
}

async function processIssue(issue, author) {
  const { title, number: id, created_at, body, html_url, labels } = issue;
  
  let postType, content, original;
  
  if (title.startsWith('post:')) {
    postType = 'post';
    content = title.replace('post: ', '');
  } else if (title.startsWith('repost:')) {
    const repostUrl = title.replace('repost: ', '');
    postType = body ? 'quote' : 'repost';
    original = await resolveOriginalPost(repostUrl);
  } else {
    console.log(`Skipping malformed post: ${title}`);
    return null;
  }
  
  const safeTimestamp = formatTimestamp(created_at);
  const filename = `${safeTimestamp}-${author}-${id}.md`;
  const filepath = path.join(FEED_DIR, filename);
  const archivePath = path.join(ARCHIVE_DIR, filename);
  
  // Skip if already exists
  if (fs.existsSync(filepath) || fs.existsSync(archivePath)) {
    console.log(`Skipping existing post: ${filename}`);
    return null;
  }
  
  console.log(`Creating feed file: ${filename}`);
  
  let frontmatter = `---
id: ${id}
author: ${author}
timestamp: ${created_at}
type: ${postType}
url: ${html_url}`;
  
  if (original) {
    frontmatter += `
original_author: ${original.author}
original_id: ${original.id}
original_url: ${original.url}
original_timestamp: ${original.timestamp}`;
  }
  
  // Add labels if present
  if (labels && labels.length > 0) {
    frontmatter += '\nlabels:';
    for (const label of labels) {
      frontmatter += `\n  - name: "${label.name}"`;
      frontmatter += `\n    color: "${label.color}"`;
      if (label.description) {
        frontmatter += `\n    description: "${label.description}"`;
      }
    }
  }
  
  frontmatter += '\n---\n';
  
  let postContent;
  if (postType === 'post') {
    postContent = content;
  } else if (postType === 'quote') {
    postContent = `${(body || '').substring(0, 250)}\n\n> ${original?.content || ''}`;
  } else {
    postContent = `> ${original?.content || ''}`;
  }
  
  fs.writeFileSync(filepath, frontmatter + postContent);
  return filename;
}

async function syncFeed() {
  const lastSync = getLastSync();
  const users = getUsersToFetch();
  
  console.log(`Last sync: ${lastSync}`);
  console.log(`Users to fetch posts from: ${users.join(', ')}`);
  
  for (const user of users) {
    console.log(`Fetching posts from: ${user}`);
    
    try {
      const issues = await fetchJSON(
        `https://api.github.com/repos/${user}/.social/issues?since=${lastSync}&state=open&sort=created&direction=desc&per_page=100`
      );
      
      if (!Array.isArray(issues)) {
        console.log(`Failed to fetch issues for ${user}`);
        continue;
      }
      
      for (const issue of issues) {
        await processIssue(issue, user);
      }
    } catch (err) {
      console.error(`Error fetching from ${user}:`, err.message);
    }
  }
  
  // Update last sync timestamp
  fs.writeFileSync(LAST_FILE, new Date().toISOString().replace(/\.\d{3}Z$/, 'Z'));
  console.log('Updated last sync timestamp');
}

syncFeed().catch(err => {
  console.error(err);
  process.exit(1);
});
