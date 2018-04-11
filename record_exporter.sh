#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/config"

FILETIMESTAMP="$(date +"%Y-%m-%d-%H-%M-%S")"

if test "x$2" = "x"
then
    echo Usage: $0 start-bib end-bib \[--range-suffix\]
    exit 0
fi

STARTBIB="$1"
ENDBIB="$2"
RANGESUFFIX=""
if [ -n "$3" ]; then
    if [ "$3" == "--range-suffix" ]; then
        RANGESUFFIX=".$STARTBIB-$ENDBIB"
    else
        echo "Unknown option: $3"
        exit 1
    fi
fi

FILENAME="$FILEPREFIX$FILETIMESTAMP$RANGESUFFIX$FILEEXT"
TARFILE="$FILEPREFIX$FILETIMESTAMP$RANGESUFFIX$TAREXT"

mkdir -p "$EXPDIR"
$KOHASHELL koha -c "(cd $KOHAPATH; ./misc/export_records.pl --record-type=bibs --starting_biblionumber=$STARTBIB --ending_biblionumber=$ENDBIB $EXPORTRECORDSOPTS)" > $EXPDIR/$FILENAME
cd $EXPDIR
tar $TAROPTS $TARFILE $FILENAME
chown $PRIMOUSER:$PRIMOGROUP $TARFILE
mv $TARFILE "$UPDATESDIR"/
cd $EXPROOT
rm -Rf $EXPTMP
