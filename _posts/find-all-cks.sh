#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BOLDPURPLE='\033[1;35m'
NC='\033[0m' # No color

ignore="
obs1
obs2
obs3
obs4
reduction
ellprime
kzg-eval-proofs
"

color_ck() {
    echo ${GREEN}$1${NC}
}

find_files_with_ck() {
    egrep $1 *.md | cut -d':' -f 1 | sort | uniq
}

scriptdir=$(cd $(dirname $(readlink -f $0)); pwd -P)

refs_file="$scriptdir/../_includes/refs.md"

cks=`egrep '\[\^.*?\]' -In *.md -o | cut -d: -f 3 | sort | uniq | tr -d ']' | tr -d '[' | tr -d '^'`

echo "Filtering out the following citation keys: "
for line in $ignore; do
    echo -e " * `color_ck $line`"
    cks=`echo "$cks" | sed "/$line/d"`
done
echo

missing=0
for ck in $cks; do
    if ! grep "$ck" $refs_file &>/dev/null; then
        missing=1
        echo -e "`color_ck $ck` is missing from '`basename $refs_file`' and appears in the following file(s):"
        for file in `find_files_with_ck $ck`; do
            echo " - $file"
        done
        echo
    fi
done 

if [ $missing -eq 1 ]; then
    echo "Bibliography file: $refs_file"
    echo
else
    echo "No missing bibliography entries!"
fi
