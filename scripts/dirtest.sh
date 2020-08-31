#!/usr/bin/env bash

# I don't think I will ever learn the intricacies of getting the containing
# directory of the original script file.

DIR1=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DIR2=$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")
DIR3=$(cd "$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "${BASH_SOURCE[0]}")")" && pwd)

echo "DIR1: $DIR1"
echo "DIR2: $DIR2"
echo "DIR3: $DIR3"
