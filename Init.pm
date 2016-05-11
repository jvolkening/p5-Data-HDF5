use ExtUtils::testlib;
use strict;
use HDFPerl;

package Init;

our $H5T_NATIVE_INT;
our $H5T_NATIVE_DOUBLE;
our $H5T_NATIVE_FLOAT;
our $H5T_NATIVE_CHAR;
our $H5T_VARIABLE;
our $H5F_ACC_TRUNC;
our $H5P_DEFAULT;
our $H5F_ACC_RDONLY;
our $H5F_ACC_RDWR;
our $H5P_FILE_CREATE;
our	$H5P_FILE_ACCESS;
our	$H5P_DATASET_CREATE;
our	$H5P_DATASET_XFER;
our	$H5P_MOUNT;
our $H5D_COMPACT;
our $H5D_CONTIGUOUS;
our $H5D_CHUNKED;
our $H5F_SCOPE_GLOBAL;
our $H5F_SCOPE_LOCAL;
our $H5S_UNLIMITED;
our $H5S_SELECT_SET;
our $H5T_C_S1;
our $H5D_FILL_TIME_ALLOC;
sub initialize {
	$H5T_NATIVE_INT = HDFPerl::h5tget_native_int_p();
	$H5T_NATIVE_FLOAT = HDFPerl::h5tget_native_float_p();
	$H5T_NATIVE_DOUBLE = HDFPerl::h5tget_native_double_p();
	$H5T_NATIVE_CHAR = HDFPerl::h5tget_native_char_p();
	$H5F_ACC_TRUNC = HDFPerl::h5fget_ftrunc_p();
  $H5F_ACC_RDWR = HDFPerl::h5fget_frdrw_p();
  $H5F_ACC_RDONLY = HDFPerl::h5fget_frdonly_p();
	$H5P_DEFAULT = HDFPerl::h5pget_pdefault_p();
	$H5T_VARIABLE = HDFPerl::h5tget_variable_p();
	$H5P_FILE_CREATE = HDFPerl::h5pget_file_create_p();
	$H5P_FILE_ACCESS = HDFPerl::h5pget_file_access_p();
	$H5P_DATASET_CREATE = HDFPerl::h5pget_dataset_create_p();
	$H5P_DATASET_XFER = HDFPerl::h5pget_dataset_xfer_p();
	$H5P_MOUNT = HDFPerl::h5pget_mount_p();
	$H5D_COMPACT = HDFPerl::h5dget_compact_p();
	$H5D_CONTIGUOUS = HDFPerl::h5dget_contiguous_p();
	$H5D_CHUNKED = HDFPerl::h5dget_chunked_p();
	$H5F_SCOPE_GLOBAL = HDFPerl::h5fget_scope_global();
	$H5F_SCOPE_LOCAL = HDFPerl::h5fget_scope_local();
        $H5S_UNLIMITED = HDFPerl::h5sget_unlimited_p();
        $H5S_SELECT_SET = HDFPerl::h5sget_select_set_p();
	$H5T_C_S1 = HDFPerl::h5tget_c_s1_p();
        $H5D_FILL_TIME_ALLOC = HDFPerl::h5dget_fill_time_alloc_p();
	return 1;
}

return 1;
