#!/bin/bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <file>" >&2
  exit 1
fi

input="$1"

# Read file content
content=$(<"$input")

# 1️⃣ Remove HTML comment markers around Doxygen config blocks
#    This looks for <!-- Doxygen config ... --> and extracts the middle.
content=$(printf "%s" "$content" | sed -E '/<!--[[:space:]]*Doxygen config[[:space:]]*$/,/-->/{ 
    /<!--/d
    /-->/d
}' )

# 2️⃣ Remove YAML-style front matter (--- ... --- at file start)
content=$(printf "%s" "$content" | awk '
BEGIN {inblock=0}
/^---[[:space:]]*$/ {
  if (NR == 1 || inblock == 1) { inblock = 1 - inblock; next }
}
!inblock
')

# Output the processed text
printf "%s\n" "$content"
