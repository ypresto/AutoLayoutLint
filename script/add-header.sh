#!/bin/bash

find Pod Example -name '*.m' -or -name '*.h' | while read file; do
  grep '//  The MIT License (MIT)' "$file" > /dev/null && continue
  # echo for last newline
  echo | cat script/header.txt - "$file" > "${file}.new"
  mv "${file}.new" "$file"
done
