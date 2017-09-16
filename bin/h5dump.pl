#!/usr/bin/env perl

use strict;
use warnings;
use 5.012;

use Data::HDF5 qw/:all/;
use FindBin;
use Data::Dumper;
use Math::SigFigs;

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
printlns('}');

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

        my $s_id = H5Aget_space($aid);
        my $str_space = make_string_space($s_id);
        H5Sclose($s_id);

        printlns("ATTRIBUTE \"$name\" {");
        ++$level;

        my $type = H5Aget_type($aid);
        print_string_type($type);

        printlns(
            "DATASPACE  $str_space",
            "DATA {",
            make_value_block($type, @$vals),
            '}',
        );

        H5Tclose($type);

        --$level;
        printlns('}');
        
        H5Aclose($aid);
    }

    if ($info->{type} == H5O_TYPE_DATASET) {
        my $vals = H5Dread($o_id);
        my $s_id = H5Dget_space($o_id);
        my $str_space = make_string_space($s_id);
        H5Sclose($s_id);

        my $type = H5Dget_type($o_id);
        print_string_type($type);

        printlns(
            "DATASPACE  $str_space",
            "DATA {",
            make_value_block($type, @$vals),
            '}',
        );
        H5Tclose($type);
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
    printlns('}');

}

sub printlns {

    for my $line (@_) {
        say $tab x $level, $line;
    }

}

sub print_string_type {
    
    my ($id) = @_;
    my $class = H5Tget_class($id);

    my $p = H5Tget_precision($id);

    if ($class == H5T_STRING) {
        my $sz = $p/8;
        my $pad = H5Tget_strpad($id);
        my $pd = $pad == H5T_STR_NULLTERM ? 'H5T_STR_NULLTERM'
               : $pad == H5T_STR_NULLPAD  ? 'H5T_STR_NULLPAD'
               : $pad == H5T_STR_SPACEPAD ? 'H5T_STR_SPACEPAD'
               : die "unrecognized pad type $pad\n";
        my $cset = H5Tget_cset($id);
        my $cs = $cset == H5T_CSET_ASCII ? 'H5T_CSET_ASCII'
               : $cset == H5T_CSET_UTF8  ? 'H5T_CSET_UTF8'
               : die "unrecognized cset type $cset\n";
        my $ct = 'H5T_C_S1'; # when is this not the case?
        printlns("DATATYPE  H5T_STRING {");
        ++$level;
        printlns(
            "STRSIZE $sz;",
            "STRPAD $pd;",
            "CSET $cs;",
            "CTYPE $ct;",
        );
        --$level;
        printlns('}');
    }

    elsif ($class == H5T_INTEGER) {
        my $sign = H5Tget_sign($id);
        my $s = $sign == H5T_SGN_NONE ? 'U'
              : $sign == H5T_SGN_2   ? 'I'
              : die "unknown sign type $sign\n";
        my $order = H5Tget_order($id);
        my $e = $order == H5T_ORDER_LE ? 'LE'
              : $order == H5T_ORDER_BE ? 'BE'
              : die "unexpected byte order $order\n";
        printlns("DATATYPE  H5T_STD_$s$p$e");
    }
    elsif ($class == H5T_FLOAT) {
        my $order = H5Tget_order($id);
        my $e = $order == H5T_ORDER_LE  ? 'LE'
              : $order == H5T_ORDER_BE  ? 'BE'
              : $order == H5T_ORDER_VAX ? 'VAX'
              : die "unexpected byte order $order\n";
        if ($order eq 'VAX') {
            printlns("DATATYPE  H5T_VAX_F$p");
        }
        else {
            printlns("DATATYPE  H5T_IEEE_F$p$e");
        }
    }
    else {
        die "unsupported datatype\n";
    }
} 

sub make_string_space {

    my ($s_id) = @_;

    my $n_dims = H5Sget_simple_extent_ndims($s_id);
    my $str_space = $n_dims == 0 ? 'SCALAR'
                    : 'SIMPLE';
    if ($n_dims > 0) {

        my $dims = H5Sget_simple_extent_dims($s_id);
        my $size = $dims->[0];
        my $max  = $dims->[1];
        @$max = map {$_ == H5S_UNLIMITED ? 'H5S_UNLIMITED' : $_} @$max;
        $str_space .= ' { ( '
            . join(', ', @$size)
            . ' ) / ( '
            . join(', ', @$max)
            . ' ) }'
        ;
    }

    return $str_space;
}

sub make_value_block {

    my ($type, @vals) = @_;
    my @lines;

    # wrap string values in double quotes
    if (H5Tget_class($type) == H5T_STRING) {
        @vals = map {"\"$_\""} @vals;
        @vals = map {$_ =~ s/\n/\n           /gs; $_;} @vals;
    }
    if (H5Tget_class($type) == H5T_FLOAT) {
        @vals = map {sprintf('%.6g', $_)} @vals;
    }

    my $ll = 77 - length($tab x $level);

    my @set;
    my $i = 0;
    my $ri = $i;

    while (scalar(@vals)) {
        ++$i;
        push @set, shift @vals;
        my $tmp = "($ri): " . join( ', ', @set );
        $tmp .= ',' if (scalar @vals);
        if (length($tmp) > $ll && scalar(@set) > 1) {
            unshift @vals, pop @set;
            --$i;
            my $str = "($ri): " . join( ', ', @set );
            $str .= ',' if (scalar @vals);
            push @lines, $str;
            @set = ();
            $ri = $i;
        }
    }
    if (scalar @set) {
        push @lines, "($ri): " . join( ', ', @set );
    }

    return @lines;

}


                
        
