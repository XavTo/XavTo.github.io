#!/bin/bash

# Exit immediately if any command fails
set -e

# Check if a commit message was passed as an argument
if [ -z "$1" ]; then
  echo "Error: Aucun message de commit fourni."
  echo "Usage: $0 <message-de-commit>"
  exit 1
fi

# Define branches
HUGO_BRANCH="hugo"
MAIN_BRANCH="main"

# Step 1: Build the site with minification
hugo --gc --minify --config config_prod.toml

# Step 2: Minify JavaScript files (ensure 'terser' is installed)
if command -v terser >/dev/null 2>&1; then
  terser public/js/darkmode.js --compress --mangle -o public/js/darkmode.js
else
  echo "Terser n'est pas installé. Minification JS ignorée."
fi

# Step 3: Copy contents from the public folder into a temporary directory
TEMP_DIR=$(mktemp -d)
cp -r public/* "$TEMP_DIR"

# Step 4: Commit changes on the current branch (assumed to be 'hugo' branch)
git add .
git commit -m "$1" || echo "Aucun changement à committer sur la branche $HUGO_BRANCH."
git push origin $HUGO_BRANCH

# Step 5: Switch to 'main' branch
git checkout $MAIN_BRANCH
git pull origin $MAIN_BRANCH

# Step 6: Remove all contents from the main branch except the .git directory and .gitignore
find . -mindepth 1 -maxdepth 1 ! -name '.git' ! -name '.gitignore' -exec rm -rf {} +

# Step 7: Copy contents from the temporary directory into the main branch
cp -r "$TEMP_DIR"/* .

# Step 8: Add CNAME file if you have a custom domain (optional)
echo "arasgrasa.me" > CNAME

# Step 9: Stage all changes, commit, and push to the main branch
git add .
git commit -m "Déploiement du site : $1" || echo "Aucun changement à committer sur la branche $MAIN_BRANCH."
git push origin $MAIN_BRANCH

# Step 10: Switch back to the 'hugo' branch
git checkout $HUGO_BRANCH

# Step 11: Clean up the temporary directory
rm -rf "$TEMP_DIR"

echo "Déploiement terminé avec succès !"
