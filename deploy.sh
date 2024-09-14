#!/bin/bash

# Exit immediately if any command fails
set -e

# Check if a commit message was passed as an argument
if [ -z "$1" ]; then
  echo "Error: No commit message provided."
  echo "Usage: $0 <commit-message>"
  exit 1
fi

# Define branches
HUGO_BRANCH="hugo"
MAIN_BRANCH="main"

# Step 1: Build the site (optional, you can skip if `public` is pre-built)
hugo --gc --minify
terser public/js/darkmode.js --compress --mangle -o public/js/darkmode.js

# Step 2: Copy contents from the public folder into a temporary directory
# (we store them here before switching branches)
TEMP_DIR=$(mktemp -d)
cp -r public/* "$TEMP_DIR"

git add .
git commit -m "$1"
git push origin $MAIN_BRANCH

# Step 3: Switch to the main branch
git checkout $MAIN_BRANCH
git pull origin $MAIN_BRANCH

# Step 4: Delete all contents from the main branch except the .git directory
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Step 5: Copy contents from the temporary directory into the main branch
cp -r "$TEMP_DIR"/* .
echo "arasgrasa.me" > CNAME

# Step 6: Stage all changes, commit with the provided message, and push to the main branch
git add .
git commit -m "DEPLOY"
git push origin $MAIN_BRANCH

# Step 7: Switch back to the hugo branch
git checkout $HUGO_BRANCH

# Step 8: Clean up the temporary directory
rm -rf "$TEMP_DIR"

echo "Deployment complete!"
