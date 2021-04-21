#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if test "$1" = "--help"
then
    echo Usage: $0 \[greater-than-biblionumber\]
    exit 0
fi

OPTIONS=""
if [ -n $1 ]; then
    OPTIONS="--gt_biblionumber=$1"
fi

$koha_shell koha -c "cd \"$koha_path\"; ./misc/record_batches.pl $OPTIONS" | parallel --colsep ' ' -j16 $SCRIPT_DIR/record_exporter.sh {1} {2} --range-suffix"
