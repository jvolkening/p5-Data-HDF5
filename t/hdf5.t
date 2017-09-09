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
    my $name = h5lget_name_by_idx_p($root, '.', H5_INDEX_NAME, H5_ITER_INC, $i, H5P_DEFAULT);
    is( $name, $grps[$i], "get name $i increasing" );
    $name = h5lget_name_by_idx_p($root, '.', H5_INDEX_NAME, H5_ITER_DEC, $i, H5P_DEFAULT);
    is( $name, $grps[2-$i], "get name $i decreasing" );
    ok( my $sub = H5Gopen($root, $name, H5P_DEFAULT),
        "open group $i" );
    ok( my $info = h5oget_info_p($sub),
        "get info for group $i" );
    is( $info->{type}, H5O_TYPE_GROUP,
        "type is GROUP" );
    is( $info->{hdr}->{version}, 1,
        "header version is 1" );
    ok( H5Gclose($sub) >= 0,
        "close group $i" );
}

# H5Fclose

ok( H5Fclose($file) >= 0, "close file" );

done_testing();

