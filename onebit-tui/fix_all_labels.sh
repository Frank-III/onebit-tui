#!/bin/bash
for file in src/components/*.mbt; do
  echo "Fixing $file"
  # Fix labeled arguments - move ~ to after parameter name
  perl -i -pe 's/~(\w+)\s*:/\1~:/g' "$file"
done
