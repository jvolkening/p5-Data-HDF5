#!/usr/bin/env perl

use strict;
use warnings;
use 5.012;

use Test::More;
use FindBin;
use Data::Dumper;

use Data::HDF5 qw/:all/;

my $DEBUG = 1;

chdir $FindBin::Bin;

use constant FN => 'test.h5';

require_ok( "Data::HDF5" );

# H5Fopen

my $file = H5Fopen(FN, H5F_ACC_RDONLY, H5P_DEFAULT);
ok( $file >= 0,
    "open good file" );
ok( H5Fopen('foobar', H5F_ACC_RDONLY, H5P_DEFAULT) < 0,
    "don't open bad filename" );

# H5Gopen

my $root  = H5Gopen($file,"/", H5P_DEFAULT);
ok ($root >= 0,
    "open root" );
ok( H5Gopen($file,"/Analyses", H5P_DEFAULT) >= 0,
    "open subgroup" );
ok( H5Gopen($file,"/Foo", H5P_DEFAULT) < 0,
    "don't open nonexistent path" );

# H5Gget_info

my $info = H5Gget_info($root);
ok( $info >= 0, "H5Gget_info" );
isa_ok( $info, 'HASH', "H5Gget_info returns hash" );
is( $info->{nlinks}, 3, "get root links" );

# H5Gget_info_by_name

my $info2 = H5Gget_info_by_name($root, "Raw", H5P_DEFAULT);
ok( $info2 >= 0, "H5Gget_info_by_name" );
isa_ok( $info2, 'HASH', "H5Gget_info_by_name returns hash" );
is( $info2->{nlinks}, 1, "get sub links" );

# H5Gget_info_by_idx

my $info3 = H5Gget_info_by_idx($root, '.', H5_INDEX_NAME, H5_ITER_INC, 1, H5P_DEFAULT);
ok( $info3 >= 0, "H5Gget_info_by_idx" );
isa_ok( $info3, 'HASH', "H5Gget_info_by_idx returns hash" );
is( $info3->{nlinks}, 1, "get sub links" );

my @grps = qw/Analyses Raw UniqueGlobalKey/;

for my $i (0..$info->{nlinks}-1) {
    my $name = H5Lget_name_by_idx($root, '.', H5_INDEX_NAME, H5_ITER_INC, $i, H5P_DEFAULT);
    is( $name, $grps[$i], "get name $i increasing" );
    $name = H5Lget_name_by_idx($root, '.', H5_INDEX_NAME, H5_ITER_DEC, $i, H5P_DEFAULT);
    is( $name, $grps[2-$i], "get name $i decreasing" );
    ok( my $sub = H5Gopen($root, $name, H5P_DEFAULT),
        "open group $i" );
    ok( my $info = H5Oget_info($sub),
        "get info for group $i" );
    is( $info->{type}, H5O_TYPE_GROUP,
        "type is GROUP" );
    is( $info->{hdr}->{version}, 1,
        "header version is 1" );
    ok( H5Gclose($sub) >= 0,
        "close group $i" );
}

#my $attr = H5Aopen_by_name( $root, 'UniqueGlobalKey/context_tags', 'flowcell', H5P_DEFAULT, H5P_DEFAULT );
my $g = H5Gopen($file,"/Raw/Reads/Read_1107", H5P_DEFAULT);
#my $g = H5Gopen($file,"/Analyses/Segmentation_000/Summary/segmentation", H5P_DEFAULT);
#my $attr = H5Aopen_by_name( $root, '.', 'file_version', H5P_DEFAULT, H5P_DEFAULT );
say "GRP:", $g;
my $attr = H5Aopen_by_name( $g, '.', 'duration', H5P_DEFAULT, H5P_DEFAULT );
say "ATTR:", $attr;
my $type = H5Aget_type($attr);
say "TYPE:", $type;
my $class = H5Tget_class($type);
say "CLASS:", $class;
my $native = H5Tget_native_type($type, H5T_DIR_ASCEND);
say "NATIVE:", $native;
my $val = H5Aread($attr);
say Dumper $val;
#say "VAL:", $val;
ok( $g >= 0, "open subgroup" );
my $ds = H5Dopen($g, 'Signal', H5P_DEFAULT);
ok( $ds >= 0, "open dataset" );
$type = H5Dget_type($ds);
say "TYPE:", $type;
$class = H5Tget_class($type);
say "CLASS:", $class;
$native = H5Tget_native_type($type, H5T_DIR_ASCEND);
say "NATIVE:", $native;
my $val2 = H5Dread($ds);
say Dumper $val2;
say "VAL2:", $val2->[0];

# H5Fclose

ok( H5Fclose($file) >= 0, "close file" );

done_testing();

