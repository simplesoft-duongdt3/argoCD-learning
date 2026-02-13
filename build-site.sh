#!/bin/bash
set -e

echo "🧹 Cleaning up..."
rm -rf docs site

echo "📂 Preparing content in docs/..."
mkdir -p docs
cp README.md docs/index.md
cp next-action.md docs/
cp -r day-* docs/

echo "🔨 Building MkDocs site..."
mkdocs build

echo "✅ Build complete! Site is in 'site/' directory."
echo "👉 Run 'mkdocs serve' to preview if you want (requires running this script first to prep 'docs/')."
