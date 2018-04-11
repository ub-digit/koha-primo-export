#!/usr/bin/perl

use Modern::Perl;
use Getopt::Long;
use File::Basename;
use File::Copy;
use Cwd 'abs_path';
#use utf8;

use constant RECORD_TERMINATOR => "\x1D";

my (
    $batch_size,
    $input_file,
    $file_extension,
    $output_directory,
    $print,
);

GetOptions(
    'batch_size=s' => \$batch_size,
    'input_file=s' => \$input_file,
    'file_extension=s' => \$file_extension,
    'output_directory=s' => \$output_directory,
    'print' => \$print,
);

# TODO: Use pod2usage instead, also add --help option
unless ($batch_size) {
    print "--batch_size required\n";
    exit 1;
}

unless ($input_file) {
    print "--filename required\n";
    exit 1;
}

# TODO: Could default to pattern (everything after last dot)
unless ($file_extension) {
    print "--file_extension required\n";
    exit 1;
}

{
    local $/ = RECORD_TERMINATOR;
    open FILE, $input_file or die("Could not open file ${input_file}: $!");
    my ($base_filename, $directory, $suffix) = fileparse($input_file, $file_extension);

    if ($output_directory) {
        die("--output_directory=$output_directory does not exist!") unless (-d $output_directory);
    }
    else {
        $output_directory = $directory;
    }

    unless ($suffix) {
        die("$base_filename does not match --file_extension=$file_extension");
    }

    my @output_files;
    my $write_batch = sub {
        my ($records, $current_batch_number) = @_;
        my $output_file = "${output_directory}${base_filename}-${current_batch_number}${file_extension}";
        open(my $fh, '>', $output_file) or die("Could not open file ${output_file}: $!");
        print $fh (join('', @{$records}));
        close($fh);
        push @output_files, $output_file;
    };
    my $current_batch_number = 1;
    my @current_batch;

    while (my $record = <FILE>) {
        push @current_batch, $record;
        if($batch_size == ($#current_batch + 1)) {
            # Really bad practice to exploit sneaky post increment
            # but this works :)
            $write_batch->(\@current_batch, $current_batch_number++);
            @current_batch = ();
        }
    }
    # Done reading, close input file
    close(FILE);

    if ($current_batch_number == 1) {
        # Number of records < batch size
        my $output_file = "${output_directory}${base_filename}${file_extension}";
        if (abs_path($output_file) ne abs_path($input_file)) {
            copy($input_file, $output_file);
            push @output_files, $output_file;
        }
        else {
            # Nothing to do, just print the filename we got
            push @output_files, $input_file;
        }
    }
    else {
        $write_batch->(\@current_batch, $current_batch_number);
    }
    print join(' ', @output_files) if ($print);
}
