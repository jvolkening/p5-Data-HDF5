#!/usr/bin/env perl

use strict;
use warnings;
use 5.012;

use Data::HDF5 qw/:all/;
use FindBin;
use Data::Dumper;

no strict 'refs';

my $fn = $ARGV[0] // die "No filename specified";

# parse predefined datatypes
my %types;
open my $fn_types, '<', "$FindBin::Bin/../predefined_types.list";
while (my $type = <$fn_types>) {
    chomp $type;
    $types{ &$type() } = $type;
}
close $fn_types;

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
        my $type = H5Aget_type($aid);
        my $str_type = make_string_type($type);
        H5Tclose($type);
        my $s_id = H5Aget_space($aid);
        my $n_dims = H5Sget_simple_extent_ndims($s_id);
        H5Sclose($s_id);

        printlns("ATTRIBUTE \"$name\" {");
        ++$level;
        printlns(
            "DATATYPE $str_type",
            "NDIMS $n_dims",
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
        my $type = H5Dget_type($o_id);
        my $str_type = make_string_type($type);
        H5Tclose($type);
        my $s_id = H5Dget_space($o_id);
        my $n_dims = H5Sget_simple_extent_ndims($s_id);
        H5Sclose($s_id);
        printlns(
            "DATATYPE $str_type",
            "NDIMS $n_dims",
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

sub make_string_type {
    
    my ($id) = @_;
    my $class = H5Tget_class($id);

    if ($class == H5T_STRING) {
        return 'H5T_STRING';
    }

    my $p = H5Tget_precision($id);

    if ($class == H5T_INTEGER) {
        my $sign = H5Tget_sign($id);
        my $s = $sign == H5T_SGN_NONE ? 'U'
              : $sign == H5T_SGN_2   ? 'I'
              : die "unknown sign type $sign\n";
        my $order = H5Tget_order($id);
        my $e = $order == H5T_ORDER_LE ? 'LE'
              : $order == H5T_ORDER_BE ? 'BE'
              : die "unexpected byte order $order\n";
        return "H5T_STD_$s$p$e";
    }
    elsif ($class == H5T_FLOAT) {
        my $order = H5Tget_order($id);
        my $e = $order == H5T_ORDER_LE  ? 'LE'
              : $order == H5T_ORDER_BE  ? 'BE'
              : $order == H5T_ORDER_VAX ? 'VAX'
              : die "unexpected byte order $order\n";
        if ($order eq 'VAX') {
            return "H5T_VAX_F$p";
        }
        else {
            return "H5T_IEEE_F$p$e";
        }
    }
    else {
        die "unsupported datatype\n";
    }
} 
