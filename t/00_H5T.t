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

# H5Fopen
# H5Fclose

my $file = H5Fopen(FN, H5F_ACC_RDONLY, H5P_DEFAULT);
ok( $file >= 0,
    "open good file" );
ok( H5Fclose($file) >= 0,
    "close good file" );

ok( H5Fopen('foobar', H5F_ACC_RDONLY, H5P_DEFAULT) < 0,
    "don't open bad filename" );
ok( H5Fclose(-1) < 0,
    "don't close bad fid" );

#H5Fcreate
#H5Fflush

my ($fh_tmp, $fn_tmp) = tempfile('H5FXXXX', UNLINK => 1);

my $new = H5Fcreate(
    $fn_tmp,
    H5F_ACC_TRUNC,
    H5P_DEFAULT,
    H5P_DEFAULT
);

ok( $new >= 0,
    "create new file" );
ok( H5Fflush($new, H5F_SCOPE_GLOBAL) >= 0,
    "flush new file" );
ok( H5Fclose($new) >= 0,
    "close new file" );

done_testing();

