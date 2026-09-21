#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Data::HDF5' ) || print "Bail out!\n";
}

diag( "Testing Data::HDF5 $Data::HDF5::VERSION, Perl $], $^X" );
