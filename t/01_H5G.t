#!/usr/bin/env perl

use strict;
use warnings;
use 5.012;

use Test::More;
use FindBin;
use Data::Dumper;
use File::Temp qw/tempfile/;

use Data::HDF5 qw/:all/;

chdir $FindBin::Bin;

use constant FN => 'test.h5';

require_ok( "Data::HDF5" );

my $file = H5Fopen(FN, H5F_ACC_RDONLY, H5P_DEFAULT);

# H5Gopen

my $g_id = H5Gopen($file, "/Analyses/Basecall_1D_000", H5P_DEFAULT);
ok( $g_id >= 0,
    "open good group" );
ok( H5Gopen($file, "/FooBar", H5P_DEFAULT) < 0,
    "open bad group" );

# H5Gget_info

ok( my $info = H5Gget_info($g_id),
    "get good group info" );
ok( H5Gget_info(-1) < 0,
    "get bad group info" );
ok( $info->{nlinks} == 2,
    "correct nlinks" );
ok( $info->{mounted} == 0,
    "correct mounted" );

# H5Gget_info_by_idx

ok( $info = H5Gget_info_by_idx($g_id, '.', H5_INDEX_NAME, H5_ITER_INC, 0, H5P_DEFAULT),
    "get good group info by index" );
ok( $info->{nlinks} == 1,
    "correct subgroup nlinks" );

ok (H5Gclose($g_id) >= 0,
    "close good group" );

H5Fclose($file);

my ($fh_tmp, $fn_tmp) = tempfile('H5FXXXX', UNLINK => 1);

my $f_new = H5Fcreate(
    $fn_tmp,
    H5F_ACC_TRUNC,
    H5P_DEFAULT,
    H5P_DEFAULT
);

# H5Gcreate

my $g_new = H5Gcreate(
    $f_new,
    "test_group",
    H5P_DEFAULT,
    H5P_DEFAULT,
    H5P_DEFAULT,
);

ok( $g_new >= 0,
    "create new group" );

my $p = H5Gget_create_plist($g_new);
ok( $p >= 0,
    "get creation property list" );
H5Pclose($p);
ok( H5Pequal( $p, H5P_DEFAULT ),
    "got correct property list" );

done_testing();

