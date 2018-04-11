#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/config"

FILETIMESTAMP="$(date +"%Y-%m-%d-%H-%M-%S")"
FILENAME="$FILEPREFIX$FILETIMESTAMP$FILEEXT"

if test "x$1" = "x"
then
    echo Usage: $0 last_sync_date_in_iso_8601_but_space_instead_of_T
    exit 0
fi

TIMESTAMP="$1"

mkdir -p "$EXPDIR"

$KOHASHELL koha -c "(cd $KOHAPATH; ./misc/export_records.pl --record-type=bibs --date=\"$TIMESTAMP\" --include_deleted $EXPORTRECORDSOPTS)" > $EXPDIR/$FILENAME

cd $EXPDIR

# TODO: Option for --batch_size??
BATCHFILES=$($SCRIPT_DIR/marc_split_into_batches.pl --input_file="$FILENAME" --batch_size=5000 --file_extension="$FILEEXT" --print)
for BATCHFILE in $BATCHFILES; do
    TARFILE="$BATCHFILE$TAREXT";
    tar $TAROPTS "$TARFILE" "$BATCHFILE"
    chown $PRIMOUSER:$PRIMOGROUP "$TARFILE"
    mv "$TARFILE" "$UPDATESDIR"/
done

cd $EXPROOT
rm -Rf $EXPTMP
