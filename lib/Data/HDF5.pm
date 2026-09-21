package Data::HDF5;

use 5.008;
use strict;
use warnings;
use Carp;

require Exporter;

our @ISA = qw(Exporter);

my @functions = qw/

    H5Fclose
    H5Fcreate
    H5Fflush
    H5Fget_access_plist
    H5Fget_intent
    H5Fget_name
    H5Fopen

    H5Gclose
    H5Gcreate
    H5Gget_create_plist
    H5Gget_info
    H5Gget_info_by_idx
    H5Gget_info_by_name
    H5Gopen

    H5Aclose
    H5Aexists
    H5Aexists_by_name
    H5Aget_info
    H5Aget_info_by_idx
    H5Aget_info_by_name
    H5Aget_name
    H5Aget_type
    H5Aget_space
    H5Aopen
    H5Aopen_by_idx
    H5Aopen_by_name
    H5Aread

    H5Dread
    H5Dopen
    H5Dclose
    H5Dget_space
    H5Dget_type

    H5Tclose
    H5Tcopy
    H5Tget_class
    H5Tget_cset
    H5Tget_native_type
    H5Tget_order
    H5Tget_precision
    H5Tget_sign
    H5Tget_size
    H5Tget_strpad
    H5Tget_super
    H5Tequal

    H5Lexists
    H5Lget_name_by_idx

    H5Oexists_by_name
    H5Oget_info
    H5Oopen

    H5Sclose
    H5Sget_simple_extent_dims
    H5Sget_simple_extent_ndims
    H5Sget_simple_extent_npoints

    H5Pclose
    H5Pcopy
    H5Pcreate
    H5Pequal
    H5Pget_class

/;


my @constants = qw/

    H5F_ACC_TRUNC
    H5F_ACC_RDONLY
    H5F_ACC_RDWR
    H5F_ACC_EXCL
    H5F_ACC_CREAT
    H5F_ACC_SWMR_WRITE
    H5F_ACC_SWMR_READ
    H5F_ACC_DEFAULT
    H5F_SCOPE_GLOBAL
    H5F_SCOPE_LOCAL

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
    H5P_DEFAULT
    H5P_FILE_CREATE
    H5P_FILE_ACCESS
    H5P_GROUP_CREATE
    H5P_GROUP_ACCESS
    H5P_DATASET_CREATE
    H5P_DATASET_XFER
    H5P_FILE_MOUNT
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

    H5T_DIR_DEFAULT
    H5T_DIR_ASCEND
    H5T_DIR_DESCEND

    H5T_NO_CLASS
    H5T_INTEGER
    H5T_FLOAT
    H5T_TIME
    H5T_STRING
    H5T_BITFIELD
    H5T_OPAQUE
    H5T_COMPOUND
    H5T_REFERENCE
    H5T_ENUM
    H5T_VLEN
    H5T_ARRAY
    H5T_NCLASSES

    H5T_ORDER_ERROR
    H5T_ORDER_LE
    H5T_ORDER_BE
    H5T_ORDER_VAX
    H5T_ORDER_MIXED
    H5T_ORDER_NONE

    H5T_SGN_NONE
    H5T_SGN_2

    H5T_STR_ERROR
    H5T_STR_NULLTERM
    H5T_STR_NULLPAD
    H5T_STR_SPACEPAD

    H5T_CSET_ERROR
    H5T_CSET_ASCII
    H5T_CSET_UTF8

    H5T_ALPHA_B16
    H5T_ALPHA_B32
    H5T_ALPHA_B64
    H5T_ALPHA_B8
    H5T_ALPHA_F32
    H5T_ALPHA_F64
    H5T_ALPHA_I16
    H5T_ALPHA_I32
    H5T_ALPHA_I64
    H5T_ALPHA_I8
    H5T_ALPHA_U16
    H5T_ALPHA_U32
    H5T_ALPHA_U64
    H5T_ALPHA_U8
    H5T_C_S1
    H5T_FORTRAN_S1
    H5T_IEEE_F32BE
    H5T_IEEE_F32LE
    H5T_IEEE_F64BE
    H5T_IEEE_F64LE
    H5T_INTEL_B16
    H5T_INTEL_B32
    H5T_INTEL_B64
    H5T_INTEL_B8
    H5T_INTEL_F32
    H5T_INTEL_F64
    H5T_INTEL_I16
    H5T_INTEL_I32
    H5T_INTEL_I64
    H5T_INTEL_I8
    H5T_INTEL_U16
    H5T_INTEL_U32
    H5T_INTEL_U64
    H5T_INTEL_U8
    H5T_MIPS_B16
    H5T_MIPS_B32
    H5T_MIPS_B64
    H5T_MIPS_B8
    H5T_MIPS_F32
    H5T_MIPS_F64
    H5T_MIPS_I16
    H5T_MIPS_I32
    H5T_MIPS_I64
    H5T_MIPS_I8
    H5T_MIPS_U16
    H5T_MIPS_U32
    H5T_MIPS_U64
    H5T_MIPS_U8
    H5T_NATIVE_B16
    H5T_NATIVE_B32
    H5T_NATIVE_B64
    H5T_NATIVE_B8
    H5T_NATIVE_CHAR
    H5T_NATIVE_CHARACTER
    H5T_NATIVE_DOUBLE
    H5T_NATIVE_FLOAT
    H5T_NATIVE_HADDR
    H5T_NATIVE_HBOOL
    H5T_NATIVE_HERR
    H5T_NATIVE_HSIZE
    H5T_NATIVE_HSSIZE
    H5T_NATIVE_INT
    H5T_NATIVE_INT16
    H5T_NATIVE_INT32
    H5T_NATIVE_INT64
    H5T_NATIVE_INT8
    H5T_NATIVE_INTEGER
    H5T_NATIVE_INT_FAST16
    H5T_NATIVE_INT_FAST32
    H5T_NATIVE_INT_FAST64
    H5T_NATIVE_INT_FAST8
    H5T_NATIVE_INT_LEAST16
    H5T_NATIVE_INT_LEAST32
    H5T_NATIVE_INT_LEAST64
    H5T_NATIVE_INT_LEAST8
    H5T_NATIVE_LDOUBLE
    H5T_NATIVE_LLONG
    H5T_NATIVE_LONG
    H5T_NATIVE_OPAQUE
    H5T_NATIVE_REAL
    H5T_NATIVE_SCHAR
    H5T_NATIVE_SHORT
    H5T_NATIVE_UCHAR
    H5T_NATIVE_UINT
    H5T_NATIVE_UINT16
    H5T_NATIVE_UINT32
    H5T_NATIVE_UINT64
    H5T_NATIVE_UINT8
    H5T_NATIVE_UINT_FAST16
    H5T_NATIVE_UINT_FAST32
    H5T_NATIVE_UINT_FAST64
    H5T_NATIVE_UINT_FAST8
    H5T_NATIVE_UINT_LEAST16
    H5T_NATIVE_UINT_LEAST32
    H5T_NATIVE_UINT_LEAST64
    H5T_NATIVE_UINT_LEAST8
    H5T_NATIVE_ULLONG
    H5T_NATIVE_ULONG
    H5T_NATIVE_USHORT
    H5T_STD_B16BE
    H5T_STD_B16LE
    H5T_STD_B32BE
    H5T_STD_B32LE
    H5T_STD_B64BE
    H5T_STD_B64LE
    H5T_STD_B8BE
    H5T_STD_B8LE
    H5T_STD_I16BE
    H5T_STD_I16LE
    H5T_STD_I32BE
    H5T_STD_I32LE
    H5T_STD_I64BE
    H5T_STD_I64LE
    H5T_STD_I8BE
    H5T_STD_I8LE
    H5T_STD_REF_DSETREG
    H5T_STD_REF_OBJ
    H5T_STD_U16BE
    H5T_STD_U16LE
    H5T_STD_U32BE
    H5T_STD_U32LE
    H5T_STD_U64BE
    H5T_STD_U64LE
    H5T_STD_U8BE
    H5T_STD_U8LE
    H5T_UNIX_D32BE
    H5T_UNIX_D32LE
    H5T_UNIX_D64BE
    H5T_UNIX_D64LE
    H5T_VAX_F32
    H5T_VAX_F64

/;

our %EXPORT_TAGS = (
    constants => [ @constants ],
    functions => [ @functions ],
    all       => [ @constants, @functions ],
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.003';

require XSLoader;
XSLoader::load('Data::HDF5', $VERSION);

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    # uncoverable branch true
    croak "&Data::HDF5::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    # uncoverable branch true
    if ($error) {
        croak $error;
    }
    {
        no strict 'refs';
        *$AUTOLOAD = sub { $val };
    }
    goto &$AUTOLOAD;
}


1;
__END__

=head1 NAME

Data::HDF5 - Perl wrappers for the HDF5 data storage library

=head1 SYNOPSIS

  use Data::HDF5 qw(:functions :constants);

  my $file = H5Fopen($filename, H5F_ACC_RDONLY, H5P_DEFAULT);
  my $group = H5Gopen($file, '/data', H5P_DEFAULT);
  my $dataset = H5Dopen($group, 'values', H5P_DEFAULT);
  my $values = H5Dread($dataset);

=head1 DESCRIPTION

Data::HDF5 provides thin Perl bindings to the HDF5 C library. The XS
functions use HDF5 identifiers (integer handles) as arguments and return
values. Unless noted otherwise, HDF5 status values are passed through
unchanged: a negative value indicates failure, zero indicates false, and a
positive value indicates success or true.

Identifiers returned by open, create, copy, or get functions should be
released with the corresponding C<close> function. C<H5Aread> and C<H5Dread>
return array references. The current read implementations support
one-dimensional integer, floating-point, and fixed-length string data.

=head1 FUNCTIONS

=head2 File functions

=over 4

=item H5Fclose($file_id)

Close a file and return the HDF5 status code.

=item H5Fcreate($name, $flags, $fcpl_id, $fapl_id)

Create the file named by C<$name>, using the supplied file-creation and
file-access property lists, and return its identifier.

=item H5Fflush($file_id, $scope)

Flush buffered data for a file. C<$scope> is normally
C<H5F_SCOPE_LOCAL> or C<H5F_SCOPE_GLOBAL>.

=item H5Fget_access_plist($file_id)

Return the file-access property-list identifier associated with the file.
The returned property list must be closed with C<H5Pclose>.

=item H5Fget_intent($file_id)

Return the file access flags, such as C<H5F_ACC_RDONLY> or C<H5F_ACC_RDWR>.

=item H5Fget_name($obj_id)

Return the name of the file containing the supplied object identifier.

=item H5Fopen($name, $flags, $fapl_id)

Open an existing file and return its identifier.

=back

=head2 Group functions

=over 4

=item H5Gclose($group_id)

Close a group.

=item H5Gcreate($loc_id, $name, $lcpl_id, $gcpl_id, $gapl_id)

Create the group named by C<$name> below C<$loc_id> and return its
identifier.

=item H5Gget_create_plist($group_id)

Return the group-creation property-list identifier.

=item H5Gget_info($group_id)

Return a hash reference containing C<nlinks>, C<max_corder>,
C<storage_type>, and C<mounted> for the group.

=item H5Gget_info_by_idx($loc_id, $group_name, $index_type, $order, $n, $lapl_id)

Return group information for the group link at position C<$n> in
C<$group_name>.

=item H5Gget_info_by_name($loc_id, $group_name, $lapl_id)

Return information for the group identified by C<$group_name>.

=item H5Gopen($loc_id, $name, $gapl_id)

Open a group by name and return its identifier.

=back

=head2 Attribute functions

=over 4

=item H5Aclose($attr_id)

Close an attribute.

=item H5Aexists($obj_id, $attr_name)

Test whether C<$obj_id> has an attribute named C<$attr_name>.

=item H5Aexists_by_name($loc_id, $obj_name, $attr_name, $lapl_id)

Test whether the named object has the named attribute.

=item H5Aget_info($attr_id)

Return an attribute-information hash reference containing C<corder_valid>,
C<corder>, C<cset>, and C<data_size>.

=item H5Aget_info_by_idx($loc_id, $obj_name, $idx_type, $order, $n, $lapl_id)

Return information for the attribute at index C<$n>.

=item H5Aget_info_by_name($loc_id, $obj_name, $attr_name, $lapl_id)

Return information for the named attribute.

=item H5Aget_name($attr_id)

Return the attribute name.

=item H5Aget_space($attr_id)

Return the attribute dataspace identifier.

=item H5Aget_type($attr_id)

Return the attribute datatype identifier.

=item H5Aopen($obj_id, $attr_name, $aapl_id)

Open the attribute named by C<$attr_name> on C<$obj_id>.

=item H5Aopen_by_idx($loc_id, $obj_name, $idx_type, $order, $n, $aapl_id, $lapl_id)

Open the attribute at index C<$n>.

=item H5Aopen_by_name($loc_id, $obj_name, $attr_name, $aapl_id, $lapl_id)

Open the named attribute.

=item H5Aread($attr_id)

Read an attribute and return an array reference containing its values.
Multidimensional attributes and selections are not supported.

=back

=head2 Dataset functions

=over 4

=item H5Dread($dataset_id)

Read a dataset and return an array reference containing its values.
Multidimensional datasets and selections are not supported.

=item H5Dopen($loc_id, $name, $dapl_id)

Open the dataset named by C<$name> and return its identifier.

=item H5Dclose($id)

Close a dataset.

=item H5Dget_space($id)

Return the dataset dataspace identifier.

=item H5Dget_type($id)

Return the dataset datatype identifier.

=back

=head2 Datatype functions

=over 4

=item H5Tclose($id)

Close a datatype identifier.

=item H5Tcopy($id)

Copy a datatype and return the new identifier.

=item H5Tget_class($id)

Return the datatype class, such as C<H5T_INTEGER>, C<H5T_FLOAT>, or
C<H5T_STRING>.

=item H5Tget_cset($id)

Return the character set for a string datatype.

=item H5Tget_native_type($id, $direction)

Return a native representation of a datatype. C<$direction> is one of the
C<H5T_DIR_*> constants.

=item H5Tget_order($id)

Return the byte order of a datatype.

=item H5Tget_precision($id)

Return datatype precision in bits.

=item H5Tget_sign($id)

Return the integer sign convention.

=item H5Tget_size($id)

Return the datatype size in bytes.

=item H5Tget_strpad($id)

Return the string padding mode.

=item H5Tget_super($id)

Return the parent datatype of a derived datatype.

=item H5Tequal($id1, $id2)

Compare two datatypes and return the HDF5 truth value.

=back

=head2 Link and object functions

=over 4

=item H5Lexists($loc_id, $name, $lapl_id)

Test whether a link exists at the specified location.

=item H5Lget_name_by_idx($loc_id, $group_name, $index_type, $order, $n, $lapl_id)

Return the name of the link at index C<$n>.

=item H5Oexists_by_name($loc_id, $name, $lapl_id)

Test whether an object exists at the supplied name.

=item H5Oget_info($obj_id)

Return an object-information hash reference, including the object type and
header information.

=item H5Oopen($loc_id, $name, $lapl_id)

Open an object by name and return its identifier.

=back

=head2 Dataspace functions

=over 4

=item H5Sclose($space_id)

Close a dataspace.

=item H5Sget_simple_extent_dims($space_id)

Return the dimensions of a simple dataspace.

=item H5Sget_simple_extent_ndims($space_id)

Return the number of dimensions in a simple dataspace.

=item H5Sget_simple_extent_npoints($space_id)

Return the total number of points in a simple dataspace.

=back

=head2 Property-list functions

=over 4

=item H5Pclose($plist_id)

Close a property list.

=item H5Pcopy($plist_id)

Copy a property list and return the new identifier.

=item H5Pcreate($class_id)

Create a property list for C<$class_id>.

=item H5Pequal($id1, $id2)

Compare two property lists and return the HDF5 truth value.

=item H5Pget_class($plist_id)

Return the property-list class identifier.

=back

=head1 CONSTANTS

Constants are available through the C<:constants> export tag or individually.
They include file, iteration, index, object, datatype, dataset, group,
identifier, dataspace, and property-list constants, including the
C<H5T_NATIVE_*> and C<H5T_STD_*> datatype families.

=head1 EXPORTS

Nothing is exported by default. Use C<:functions>, C<:constants>, or C<:all>
with C<use>, or import individual names.

=head1 SEE ALSO

L<https://www.hdfgroup.org/solutions/hdf5/>.

=cut
