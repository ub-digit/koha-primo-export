#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$script_dir/config"

if test "$1" = "--help"
then
    echo Usage: $0 \[greater-than-biblionumber\]
    exit 0
fi

OPTIONS=""
if [ -n $1 ]; then
    OPTIONS="--gt_biblionumber=$1"
fi

$koha_shell $koha_instance -c "cd \"$koha_path\"; ./misc/record_batches.pl $OPTIONS" | parallel --colsep ' ' -j16 $SCRIPT_DIR/export_records_batch.sh {1} {2} --range-suffix"
