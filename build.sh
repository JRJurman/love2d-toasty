#!/bin/bash

# Ensure Homebrew tools (node/npx) are on PATH even when invoked by
# non-interactive shells like the "Run on Save" VS Code extension.
export PATH="/opt/homebrew/bin:$PATH"

# Build the .love package (a .zip)
echo 'building toasty.love'
cd src; zip "../toasty.love" -r *; cd ..
echo 'completed toasty.love'

## =========== Web Build =====================
echo 'starting web build'

# Run love.js on the project - this will create a new folder with the love.js assets
npx love.js "toasty.love" "docs" -t "toasty" -c

# Copy the template assets to the love.js project
cp template.html "docs/index.html"

echo 'completed web build'

## =========== Android Build =====================
echo 'completed android build'

cp -r src/ android/app/src/embed/assets

echo 'completed android build'

## =========== iOS Build =====================
