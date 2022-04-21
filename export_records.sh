#!/bin/bash
# This script will export all records in batches
script_dir="$(dirname "$(readlink -f "$0")")"
source "$script_dir/config"

IFS=$'\n'
# TODO: Merge with export_records_p
for batch in $($koha_shell $koha_instance -c "cd \"$koha_path\"; ./misc/record_batches.pl"); do
    eval $script_dir/export_records_batch.sh $batch
done
