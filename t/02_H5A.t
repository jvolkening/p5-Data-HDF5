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

# H5Aexists

ok( H5Aexists($file, "file_version") == 1,
    "real attribute exists" );
ok( H5Aexists($file, "foo_bar") == 0,
    "fake attribute doesn't exist" );

# H5Aexists

ok( H5Aexists_by_name($file, "Analyses/Basecall_1D_000", "name", H5P_DEFAULT) == 1,
    "real attribute exists by name" );
ok( H5Aexists_by_name($file, "Analyses/Basecall_1D_000", "foo",  H5P_DEFAULT) == 0,
    "fake attribute doesn't exist by name" );

# H5Aopen*

my $attr = H5Aopen($file, "file_version", H5P_DEFAULT);
ok ($attr >= 0,
    "open real attribute" );
H5Aclose($attr);
ok( H5Aopen($file, "foobar", H5P_DEFAULT) < 0,
    "don't open fake attribute" );

$attr = H5Aopen_by_name($file, "/", "file_version", H5P_DEFAULT, H5P_DEFAULT);
ok ($attr >= 0,
    "open real attribute by name" );
H5Aclose($attr);

$attr = H5Aopen_by_idx($file, '/', H5_INDEX_NAME, H5_ITER_INC, 0, H5P_DEFAULT, H5P_DEFAULT),
ok ($attr >= 0,
    "open real attribute by idx" );

# H5Aget_name
ok( H5Aget_name($attr) eq 'file_version',
    "get attr name" );

# H5Aget_space
my $spc = H5Aget_space($attr);
ok( $spc >= 0,
    "get attr space" );
H5Sclose($spc);

# H5Aget_info*

ok( my $info = H5Aget_info($attr),
    "get attribute info" );
ok(H5Aget_info(-1) < 0,
    "get bad attribute info" );
ok( $info->{cset} == H5T_CSET_ASCII,
    "get attribute cset" );
ok( $info->{data_size} == 8,
    "get attribute data size" );

ok( $info = H5Aget_info_by_name($file, "Analyses/Basecall_1D_000", "name", H5P_DEFAULT),
    "get attribute info by name" );
ok(H5Aget_info_by_name($file, "foo", "bar", H5P_DEFAULT) < 0,
    "get bad attribute info by name" );
ok( $info->{cset} == H5T_CSET_ASCII,
    "get attribute cset" );
ok( $info->{data_size} == 25,
    "get attribute data size" );

ok( $info = H5Aget_info_by_idx($file, '/', H5_INDEX_NAME, H5_ITER_INC, 0, H5P_DEFAULT),
    "get attribute info by idx" );
ok( H5Aget_info_by_idx($file, '/', H5_INDEX_NAME, H5_ITER_INC, 99, H5P_DEFAULT) < 0,
    "get bad attribute info by idx" );
ok( $info->{cset} == H5T_CSET_ASCII,
    "get attribute cset" );
ok( $info->{data_size} == 8,
    "get attribute data size" );

H5Aclose($attr);

# H5Aread

$attr = H5Aopen_by_name(
    $file,
    "Analyses/Basecall_1D_000/Summary/basecall_1d_template",
    "mean_qscore",
    H5P_DEFAULT,
    H5P_DEFAULT
);

ok (abs( H5Aread($attr)->[0] - 12.7461 ) < .01,
    "Read H5T_IEEE_F32LE" );
H5Aclose($attr);

$attr = H5Aopen_by_name(
    $file,
    "Raw/Reads/Read_1107",
    "median_before",
    H5P_DEFAULT,
    H5P_DEFAULT
);

ok (abs( H5Aread($attr)->[0] - 265.382 ) < .01,
    "Read H5T_IEEE_F64LE" );
H5Aclose($attr);

$attr = H5Aopen_by_name(
    $file,
    "Raw/Reads/Read_1107",
    "duration",
    H5P_DEFAULT,
    H5P_DEFAULT
);
ok ( H5Aread($attr)->[0] == 11863,
    "Read H5T_STD_U32LE" );
H5Aclose($attr);

$attr = H5Aopen_by_name(
    $file,
    "Raw/Reads/Read_1107",
    "start_time",
    H5P_DEFAULT,
    H5P_DEFAULT
);
ok ( H5Aread($attr)->[0] == 9472966,
    "Read H5T_STD_U64LE" );
H5Aclose($attr);

$attr = H5Aopen_by_name(
    $file,
    "UniqueGlobalKey/tracking_id",
    "bream_ont_version",
    H5P_DEFAULT,
    H5P_DEFAULT
);
ok ( H5Aread($attr)->[0] eq '1.7.14.1',
    "Read H5T_STRING" );
H5Aclose($attr);

done_testing();

