package HDFPerl;

use 5.008;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use HDFPerl ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.10';

require XSLoader;
XSLoader::load('HDFPerl', $VERSION);

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

HDFPerl - Perl wrappers for HDF5 libary

=head1 SYNOPSIS

  use HDFPerl;

=head1 ABSTRACT

  HDFPerl is a set of wrappers for HDF5 APIs.
  The abstract is used when making PPD (Perl Package Description) files.
  If you don't want an ABSTRACT you should also edit Makefile.PL to
  remove the ABSTRACT_FROM option.

=head1 DESCRIPTION

Stub documentation for BioHDF, created by h2xs. 


=head2 EXPORT

None by default.


=head1 SEE ALSO

Documentation can found at
http://hdfgroup.org/projects/bioinformatics/bio_software.html

=cut
