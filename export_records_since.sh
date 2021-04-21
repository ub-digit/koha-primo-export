#!/bin/bash
script_dir="$(dirname "$(readlink -f "$0")")"
source "$script_dir/config"

file_timestamp="$(date +"%Y-%m-%d-%H-%M-%S")"
filename="$file_prefix$file_timestamp$file_ext"

if test "x$1" = "x"
then
    echo Usage: $0 last_sync_date_in_iso_8601_but_space_instead_of_T
    exit 0
fi

timestamp="$1"
mkdir -p "$exp_dir"

$koha_shell $koha_instance -c "(cd $koha_path; ./misc/export_records.pl --record-type=bibs --date=\"$timestamp\" --include_deleted $export_records_opts)" > $exp_dir/$filename

cd $exp_dir

# TODO: Option for --batch_size??
batch_files=$($script_dir/marc_split_into_batches.pl --input_file="$filename" --batch_size=5000 --file_extension="$file_ext" --print)
for batch_file in $batch_files; do
    tar_file="$batch_file$tar_ext";
    tar $tar_opts "$tar_file" "$batch_file"
    chown $primo_user:$primo_group "$tar_file"
    mv "$tar_file" "${export_dir}/updates/"
done

rm -Rf "$exp_root/$exp_tmp"
