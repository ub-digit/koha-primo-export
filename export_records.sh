#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
IFS=$'\n'
# TODO: Merge with export_records_p
for BATCH in $(koha-shell koha -c "cd \"$KOHAPATH\"; ./misc/record_batches.pl"); do
    eval $SCRIPT_DIR/record_exporter.sh $BATCH
done
