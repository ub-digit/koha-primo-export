#!/bin/bash
# This script will export all records in batches
script_dir="$(dirname "$(readlink -f "$0")")"
IFS=$'\n'
# TODO: Merge with export_records_p
for batch in $($koha_shell koha -c "cd \"$koha_path\"; ./misc/record_batches.pl"); do
    eval $script_dir/record_exporter.sh $batch
done
