#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"
source "$script_dir/config"

file_timestamp="$(date +"%Y-%m-%d-%H-%M-%S")"

if test "x$2" = "x"
then
    echo Usage: $0 start-bib end-bib \[--range-suffix\]
    exit 0
fi

start_bib="$1"
end_bib="$2"
range_suffix=""
if [ -n "$3" ]; then
    if [ "$3" == "--range-suffix" ]; then
        range_suffix=".$start_bib-$end_bib"
    else
        echo "Unknown option: $3"
        exit 1
    fi
fi

filename="$file_prefix$file_timestamp$range_suffix$file_ext"
tar_file="$file_prefix$file_timestamp$range_suffix$tar_ext"

mkdir -p "$exp_dir"

$koha_shell $koha_instance -c "(cd $koha_path; ./misc/export_records.pl --record-type=bibs --starting_biblionumber=$start_bib --ending_biblionumber=$end_bib $export_records_opts)" > $exp_dir/$filename
cd $exp_dir
tar $tar_opts $tar_file $filename
chown $primo_user:$primo_group $tar_file
mv $tar_file "{$export_dir}/full/"
rm -Rf "$exp_root/$exp_tmp"
