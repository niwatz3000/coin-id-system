#!/usr/bin/env bash
# Initializes this project as a git repo and pushes it to a new GitHub repository.
# Usage: ./push-to-github.sh <github-username> <repo-name>
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <github-username> <repo-name>"
  exit 1
fi

USERNAME="$1"
REPO_NAME="$2"

git init
git add .
git commit -m "Initial commit: Online Coin Identification & Catalog System (MVP 1) scaffold"
git branch -M main
git remote add origin "https://github.com/${USERNAME}/${REPO_NAME}.git"
git push -u origin main

echo "Pushed to https://github.com/${USERNAME}/${REPO_NAME}"
