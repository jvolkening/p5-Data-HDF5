#!/usr/bin/env perl

use strict;
use warnings;
use 5.012;

use Data::HDF5 qw/:all/;

my $fn = $ARGV[0] // die "No filename specified";

# open file
my $fd = H5Fopen(
    $fn,
    H5F_ACC_RDONLY,
    H5P_DEFAULT
);
die "Error opening file\n" if ($fd < 0);

my $level = 0;
my $tab = '   ';

my $root = H5Gopen(
    $fd,
    '/',
    H5P_DEFAULT
);
die "Error opening root\n" if ($root < 0);

printlns("HDF5 \"$fn\" {");
process_object($root, '/');

exit;

sub process_object {

    my ($o_id, $o_name) = @_;

    my $info = H5Oget_info($o_id)
        or die "failed to get info for meta group\n";

    my $lbl = $info->{type} == H5O_TYPE_GROUP ? 'GROUP'
            : $info->{type} == H5O_TYPE_DATASET ? 'DATASET'
            : die "unsupported object type $info->{type}\n";

    printlns("$lbl \"$o_name\" {");

    ++$level;

    # print attributes
    my $n_attrs = $info->{num_attrs} // die "No attribute count specified\n";

    for my $i (0..$n_attrs-1) {

        my $aid = H5Aopen_by_idx(
            $o_id,
            '.',
            &H5_INDEX_NAME,
            &H5_ITER_INC,
            $i,
            &H5P_DEFAULT,
            &H5P_DEFAULT
        );
        my $name = H5Aget_name($aid);
        my $vals = H5Aread($aid);

        printlns("ATTRIBUTE \"$name\" {");
        ++$level;
        printlns(
            "DATA {",
            "(O): " . join(', ', @$vals),
            '}',
        );

        --$level;
        printlns('}');
        
        H5Aclose($aid);
    }

    if ($info->{type} == H5O_TYPE_DATASET) {
        ++$level;
        my $vals = H5Dread($o_id);
        printlns(
            "DATA {",
            "(O): " . join(', ', @$vals),
            '}',
        );
        --$level;
    }
    elsif ($info->{type} == H5O_TYPE_GROUP) {

        my $info = H5Gget_info($o_id)
            or die "failed to get info for group $o_name\n";
        my $n_links = $info->{nlinks} // die "No attribute count specified\n";

        for my $i (0..$n_links-1) {

            my $sub_name = H5Lget_name_by_idx(
                $o_id,
                '.',
                &H5_INDEX_NAME,
                &H5_ITER_INC,
                $i,
                &H5P_DEFAULT
            );
            die "Failed to get group name\n"
                if ($sub_name lt 0);

            my $sub = H5Oopen(
                $o_id,
                $sub_name,
                &H5P_DEFAULT
            );
            process_object($sub, $sub_name);

        }

    }

    --$level;

}

sub printlns {

    for my $line (@_) {
        say $tab x $level, $line;
    }

}
