#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project. 
hugo -b "http://nadavc.github.io"

# Go To Public folder
cd public
# Add changes to git.
git add -A

# Commit changes.
msg="Rebuild site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push -f origin master

