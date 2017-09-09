package Data::HDF5;

use 5.008;
use strict;
use warnings;
use Carp;

require Exporter;

our @ISA = qw(Exporter);

my @functions = qw/

    H5Fcreate
    H5Fopen
    H5Fclose
    H5Fflush

    H5Gcreate
    H5Gopen
    H5Gclose
    H5Gget_create_plist
    H5Gget_info
    H5Gget_info_by_name
    H5Gget_info_by_idx

    h5oget_info_p
    h5lget_name_by_idx_p

    h5acreate_p
    h5awrite_string_p
    h5awrite_int8_p
    h5aread_int8_p
    h5aread_p
    h5aclose_p
    h5aget_name_p
    h5aopen_name_p
    h5aopen_idx_p
    h5aget_space_p
    h5aget_type_p
    h5aget_num_attrs_p

    h5pcreate_p
    h5pclose_p
    h5pset_chunk_p
    h5pset_deflate_p
    h5pset_layout_p
    h5pget_file_create_p
    h5pget_file_access_p
    h5pget_dataset_create_p
    h5pget_dataset_xfer_p
    h5pget_mount_p
    h5pset_fill_time_p
    h5dget_fill_time_alloc_p
    h5dcreate_p
    h5dopen_p
    h5dclose_p
    h5dget_space_p
    h5dget_type_p
    h5dwrite_double_p
    h5dwrite_float_p
    h5dwrite_int8_p
    h5dwrite_int_p
    h5dwrite_char_p
    h5dwrite_string_p
    h5dwrite_vlstring_p
    h5dread_int8_p
    h5dread_int_p
    h5dread_double_p
    h5dread_string_p
    h5dread_vlstring_p
    h5dread_char_p
    h5dextend_p
    h5screate_p
    h5screate_simple_p
    h5sselect_hyperslab_p
    h5sget_simple_extent_dims_p
    h5sclose_p
    h5tcreate_enum_p
    h5tenum_insert_char_p
    h5tcreate_string_p
    h5tcreate_compound_p
    h5tinsert_p
    h5tget_native_int_p
    h5tget_native_double_p
    h5tget_native_float_p
    h5tget_variable_p
    h5tget_native_char_p
    h5tget_size_p
    h5tclose_p
    h5tequal_p
    h5fget_ftrunc_p
    h5pget_pdefault_p
    h5fget_frdrw_p
    h5fget_frdonly_p
    h5dget_compact_p
    h5dget_contiguous_p
    h5dget_chunked_p
    h5sget_unlimited_p
    h5sget_select_set_p
    h5tget_c_s1_p
    h5tget_class_p
/;


my @constants = qw/

    H5_ITER_UNKNOWN
    H5_ITER_INC
    H5_ITER_DEC
    H5_ITER_NATIVE
    H5_ITER_N

    H5_INDEX_UNKNOWN
    H5_INDEX_NAME
    H5_INDEX_CRT_ORDER
    H5_INDEX_N

    H5O_TYPE_UNKNOWN
    H5O_TYPE_GROUP
    H5O_TYPE_DATASET
    H5O_TYPE_NAMED_DATATYPE
    H5O_TYPE_NTYPES

    H5T_NATIVE_INT
    H5T_NATIVE_DOUBLE
    H5T_NATIVE_FLOAT
    H5T_NATIVE_CHAR
    H5T_VARIABLE
    H5F_ACC_TRUNC
    H5P_DEFAULT
    H5F_ACC_RDONLY
    H5F_ACC_RDWR
    H5P_FILE_CREATE
    H5P_FILE_ACCESS
    H5P_DATASET_CREATE
    H5P_DATASET_XFER
    H5P_FILE_MOUNT
    H5F_SCOPE_GLOBAL
    H5F_SCOPE_LOCAL
    H5S_UNLIMITED
    H5S_SELECT_SET
    H5T_C_S1
    H5D_FILL_TIME_ALLOC

    H5G_NTYPES
    H5G_NLIBTYPES
    H5G_NUSERTYPES
    H5G_SAME_LOC
    H5G_LINK_ERROR
    H5G_LINK_HARD
    H5G_LINK_SOFT

    H5G_UNKNOWN
    H5G_GROUP
    H5G_DATASET
    H5G_TYPE
    H5G_LINK
    H5G_UDLINK

    H5I_UNINIT
    H5I_BADID
    H5I_FILE
    H5I_GROUP
    H5I_DATATYPE
    H5I_DATASPACE
    H5I_DATASET
    H5I_ATTR
    H5I_REFERENCE
    H5I_VFL
    H5I_GENPROP_CLS
    H5I_GENPROP_LST
    H5I_ERROR_CLASS
    H5I_ERROR_MSG
    H5I_ERROR_STACK
    H5I_NTYPES

    H5D_LAYOUT_ERROR
    H5D_COMPACT
    H5D_CONTIGUOUS
    H5D_CHUNKED
    H5D_NLAYOUTS
/;

our %EXPORT_TAGS = (
    constants => [ @constants ],
    functions => [ @functions ],
    all       => [ @constants, @functions ],
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.001';

require XSLoader;
XSLoader::load('Data::HDF5', $VERSION);

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&Data::HDF5::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
        no strict 'refs';
	    *$AUTOLOAD = sub { $val };
    }
    goto &$AUTOLOAD;
}


1;
__END__

=head1 NAME

Data::HDF5 - Perl wrappers for HDF5 libary

=head1 SYNOPSIS

  use Data::HDF5;

=head1 ABSTRACT

Bindings to the HDF5 library 

=head1 DESCRIPTION


=head1 SEE ALSO

Documentation can found at
http://hdfgroup.org/projects/bioinformatics/bio_software.html

=cut
