#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"
source "$script_dir/config"

last_sync_date_file="$DATA_DIR/last_sync_date"
this_sync_date="$(date +"%Y-%m-%d %H:%M:%S")"

if [ -f "$last_sync_date_file" ]; then
     # File found, only export records changed since last time
    last_sync_date=$(cat "$last_sync_date_file")
    # TODO: Error handling, right nog koha-shell will fail silently
    $script_dir/export_records_since.sh "$last_sync_date"
    echo "$this_sync_date" > "$last_sync_date_file"
else
    # No file found, perform full export
    $script_dir/export_records.sh
fi
