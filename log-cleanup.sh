#!/bin/bash
# log-cleanup.sh: deletes .log files older than DAYS days under DIR.
# It only lists them unless you add --apply, so a mistake costs nothing.
# Usage: ./log-cleanup.sh DIR [DAYS] [--apply]
set -euo pipefail

if [ "$#" -lt 1 ] || [ ! -d "$1" ]; then
  echo "Usage: $0 DIR [DAYS] [--apply]   (DIR must be a folder)"
  exit 2
fi

dir=$1
days=${2:-7}
mode=${3:-dry-run}

mapfile -t old < <(find "$dir" -type f -name '*.log' -mtime +"$days")

for file in "${old[@]}"; do
  if [ "$mode" = "--apply" ]; then
    rm -- "$file"
    echo "deleted       $file"
  else
    echo "would delete  $file"
  fi
done

echo "${#old[@]} file(s) older than $days days in $dir ($mode)"
