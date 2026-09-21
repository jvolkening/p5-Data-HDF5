#!/usr/bin/env perl

use strict;
use warnings;
use 5.012;

use Test::More;
use Test::Output;
use FindBin;
use Data::Dumper;
use File::Temp qw/tempfile/;

use Data::HDF5 qw/:all/;

chdir $FindBin::Bin;

use constant FN => 'test.h5';

require_ok( "Data::HDF5" );

# H5Fopen
# H5Fget_access_plist
# H5Fget_intent
# H5Fget_name
# H5Fclose

my $ret = ''; # use to capture stderr_like outputs

my $file = H5Fopen(FN, H5F_ACC_RDONLY, H5P_DEFAULT);
ok( $file >= 0,
    "open good file" );
my $apl = H5Fget_access_plist($file);
my $cls = H5Pget_class($apl);
ok( H5Pequal($cls, H5P_FILE_ACCESS) == 1,
    "get good file access plist" );
H5Pclose($apl);
ok( H5Fget_intent($file) == H5F_ACC_RDONLY,
    "get good file intent" );
ok( H5Fget_name($file) eq FN,
    "get good filename" );
ok( H5Fclose($file) >= 0,
    "close good file" );

stderr_like { $ret = H5Fopen('foobar', H5F_ACC_RDONLY, H5P_DEFAULT) }
    qr/Unable to open file/im,
    "warned on opening bad filename";
ok( $ret < 0, "opening bad filename returned negative value" );
stderr_like { $ret = H5Fclose(-1) }
    qr/Not a file ID/im,
    "warned on closing bad fid";
ok( $ret < 0, "closing bad fid returned negative value" );

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

