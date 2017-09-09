#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"
#include "hdf5.h"
#include "hdf5_hl.h"
#include "const-c.inc"


MODULE = Data::HDF5     PACKAGE = Data::HDF5

PROTOTYPES: ENABLE

INCLUDE: const-xs.inc


#############################################################################
# H5F API
#############################################################################

hid_t
H5Fcreate(name, flags, fcpl_id, fapl_id)
	char *name
	unsigned int flags
	hid_t fcpl_id
	hid_t fapl_id

#---------------------------------------------------------------------------#

hid_t
H5Fopen(name, flags, fapl_id)
	char *name
	unsigned int flags
	hid_t fapl_id

#---------------------------------------------------------------------------#

herr_t
H5Fclose(file_id)
	hid_t file_id

#---------------------------------------------------------------------------#
		
herr_t
H5Fflush(file_id, scope)
	hid_t file_id
	H5F_scope_t scope


#############################################################################
# H5G API
#############################################################################

hid_t
H5Gcreate(loc_id, name, lcpl_id, gcpl_id, gapl_id)
	hid_t loc_id
	char *name
	hid_t lcpl_id
    hid_t gcpl_id
    hid_t gapl_id

	CODE:
		RETVAL = H5Gcreate2(loc_id, name, lcpl_id, gcpl_id, gapl_id);
	OUTPUT:	
		RETVAL

#----------------------------------------------------------------------------#

hid_t
H5Gopen(loc_id, name, gapl_id)
	hid_t loc_id
	char *name
    hid_t gapl_id

	CODE:
		RETVAL = H5Gopen2(loc_id, name, gapl_id);
	OUTPUT:
		RETVAL

#----------------------------------------------------------------------------#

herr_t
H5Gclose(group_id)
	hid_t group_id

#----------------------------------------------------------------------------#

hid_t
H5Gget_create_plist(group_id)
	hid_t group_id

#----------------------------------------------------------------------------#

SV *
H5Gget_info(group_id)
    hid_t group_id

    PREINIT:
        herr_t ret;
        HV *info_hash;
        H5G_info_t *info;
    CODE:
        info = (H5G_info_t *)malloc(sizeof(H5G_info_t));
        ret  = H5Gget_info(group_id, info);
        if (ret < 0) {
            RETVAL = newSViv(ret);
        }
        else {
            info_hash = (HV *) sv_2mortal((SV *) newHV ());
            hv_store( info_hash, "nlinks",        6, newSVuv( info->nlinks ),       0 );
            hv_store( info_hash, "max_corder",   10, newSViv( info->max_corder ),   0 );
            hv_store( info_hash, "storage_type", 12, newSViv( info->storage_type ), 0 );
            hv_store( info_hash, "mounted",       7, newSVuv( info->mounted ),      0 );
            RETVAL = newRV((SV *)info_hash);
        }
        free(info);
    OUTPUT:
        RETVAL

#----------------------------------------------------------------------------#

SV *
H5Gget_info_by_name(loc_id, group_name, lapl_id)
    hid_t loc_id
    char *group_name
    hid_t lapl_id

    PREINIT:
        herr_t ret;
        HV *info_hash;
        H5G_info_t *info;
    CODE:
        info = (H5G_info_t *)malloc(sizeof(H5G_info_t));
        ret = H5Gget_info_by_name(loc_id, group_name, info, lapl_id);
        if (ret < 0) {
            RETVAL = newSViv(ret);
        }
        else {
            info_hash = (HV *) sv_2mortal((SV *) newHV ());
            hv_store( info_hash, "nlinks",        6, newSVuv( info->nlinks ),       0 );
            hv_store( info_hash, "max_corder",   10, newSViv( info->max_corder ),   0 );
            hv_store( info_hash, "storage_type", 12, newSViv( info->storage_type ), 0 );
            hv_store( info_hash, "mounted",       7, newSVuv( info->mounted ),      0 );
            RETVAL = newRV((SV *)info_hash);
        }
        free(info);
    OUTPUT:
        RETVAL

#----------------------------------------------------------------------------#

SV *
H5Gget_info_by_idx(loc_id, group_name, index_type, order, n, lapl_id)
    hid_t loc_id
    char *group_name
    H5_index_t index_type
    H5_iter_order_t order
    hsize_t n
    hid_t lapl_id

    PREINIT:
        herr_t ret;
        HV *info_hash;
        H5G_info_t *info;
    CODE:
        info = (H5G_info_t *)malloc(sizeof(H5G_info_t));
        ret = H5Gget_info_by_idx(
            loc_id,
            group_name,
            index_type,
            order,
            n,
            info,
            lapl_id
        );
        if (ret < 0) {
            RETVAL = newSViv(ret);
        }
        else {
            info_hash = (HV *) sv_2mortal((SV *) newHV ());
            hv_store( info_hash, "nlinks",        6, newSVuv( info->nlinks ),       0 );
            hv_store( info_hash, "max_corder",   10, newSViv( info->max_corder ),   0 );
            hv_store( info_hash, "storage_type", 12, newSViv( info->storage_type ), 0 );
            hv_store( info_hash, "mounted",       7, newSVuv( info->mounted ),      0 );
            RETVAL = newRV((SV *)info_hash);
        }
        free(info);
    OUTPUT:
        RETVAL

#TODO: Continue refactoring here

#---------------------------------------------------------------------------#
# H5A API
#---------------------------------------------------------------------------#

hid_t h5acreate_p(loc_id, name, type_id, space_id, acpl_id, aapl_id)
	hid_t loc_id
	char *name
	hid_t type_id
	hid_t space_id
	hid_t acpl_id
    hid_t aapl_id

	CODE:
		RETVAL = H5Acreate2(loc_id, name, type_id, space_id, acpl_id, aapl_id);
	OUTPUT:	
		RETVAL


int h5awrite_string_p(loc_id, name, buffer)
	int loc_id;
	char *name;
	char *buffer;

	PREINIT:
		int attr_type;
		int attr_space;
		int attr_id;
		int string_size;
	CODE:
		string_size = strlen(buffer);
		attr_space = H5Screate(H5S_SCALAR);
		attr_type = H5Tcopy(H5T_C_S1);
		H5Tset_size(attr_type, string_size);
		H5Tset_strpad(attr_type, H5T_STR_NULLTERM);
		attr_id= H5Acreate1(loc_id, name, attr_type, attr_space, H5P_DEFAULT);
		H5Awrite(attr_id, attr_type, buffer);
		RETVAL = H5Aclose(attr_id);
	OUTPUT:	
		RETVAL

int h5awrite_int8_p(attr_id, mem_type_id, buffer)
        int attr_id;
        int mem_type_id;
        AV * buffer;

        PREINIT:
                int len, i;
                SV ** elem;
                char *data;
        CODE:
                len = av_len(buffer) + 1;
                data = (char *) malloc(len * sizeof(char));
                for (i = 0; i < len; i++) {
                        elem = av_fetch(buffer, i, 0);
                        data[i] = (char) SvIV(*elem);
                }
                RETVAL = H5Awrite(attr_id, mem_type_id, data);
                free(data); 
        OUTPUT:
                RETVAL

AV * h5aread_int8_p(attr_id, mem_type_id)
        int attr_id;
        int mem_type_id;

        PREINIT:
                AV * data;
                char *read_data;
                int npoints;
                int i;
                int attr_space_id;
                SV *elem;

        INIT:
                if (attr_id < 0)
                        XSRETURN_UNDEF;
        CODE:
                data = newAV();
                attr_space_id = H5Aget_space(attr_id);
                npoints = H5Sget_select_npoints(attr_space_id);
                read_data = (char *) malloc(sizeof(char) * npoints);

                H5Aread(attr_id, mem_type_id, read_data);

                for (i = 0; i < npoints; i++) {
                                elem = newSViv(read_data[i]);
                                av_store(data, i, elem);
                }
                RETVAL = data;
                free(read_data);
        OUTPUT:
                RETVAL
	
# int h5aread_p(attr_id, mem_type_id, buf)

int h5aclose_p(attr_id)
	int attr_id

	CODE:
		RETVAL = H5Aclose(attr_id);	
	OUTPUT:
		RETVAL

#int h5aget_name_p(attr_id, buf_size, buf)

int h5aopen_name_p(loc_id, name)
	int loc_id
	char *name

	CODE:
		RETVAL = H5Aopen_name(loc_id, name);
	OUTPUT:	
		RETVAL

int h5aopen_idx_p(loc_id, idx)
	int loc_id
	int idx

	CODE:
		RETVAL = H5Aopen_idx(loc_id, idx);
	OUTPUT:	
		RETVAL
		
int h5aget_space_p(attr_id)
	int attr_id

	CODE:
		RETVAL = H5Aget_space(attr_id);
	OUTPUT:	
		RETVAL

int h5aget_type_p(attr_id)
	int attr_id

	CODE:
		RETVAL = H5Aget_type(attr_id);
	OUTPUT:	
		RETVAL

int h5aget_num_attrs_p(attr_id)
	int attr_id

	CODE:
		RETVAL = H5Aget_num_attrs(attr_id);
	OUTPUT:	
		RETVAL

############### H5P API

int h5pcreate_p(cls_id)
	int cls_id

	CODE:
		RETVAL = H5Pcreate(cls_id);
	OUTPUT:	
		RETVAL

int h5pclose_p(cls_id)
	int cls_id

	CODE:
		RETVAL = H5Pclose(cls_id);
	OUTPUT:	
		RETVAL

int h5pset_chunk_p(plist, ndims, dims)
	int plist
	int ndims
	SV *dims

	PREINIT:
		hsize_t *correct_dims;
		int i = 0;
	CODE:
		correct_dims = (hsize_t *) malloc(ndims * sizeof(hsize_t));
		for (i = 0; i < ndims; i++) {
			correct_dims[i] = (hsize_t)SvIV(*av_fetch((AV *)SvRV(dims), i, 0));
		}
	
		RETVAL = H5Pset_chunk(plist, ndims, correct_dims);
                free(correct_dims);
	OUTPUT:
		RETVAL

int h5pset_deflate_p(plist, level)
	int plist
	int level

	CODE:
		RETVAL = H5Pset_deflate(plist, level);
	OUTPUT:
		RETVAL
			
int h5pset_szip(plist, options_mask, pixels_per_block)
	int plist
	unsigned int options_mask
	unsigned int pixels_per_block

	CODE:
		RETVAL = H5Pset_szip(plist, options_mask, pixels_per_block);
	OUTPUT:
		RETVAL

int h5pset_layout_p(plist, layout)
	int plist
	int layout

	CODE:
		RETVAL = H5Pset_layout(plist, layout);
	OUTPUT:	
		RETVAL

int h5pset_fill_time_p(plist, alloc_time)
        int plist
        int alloc_time

        CODE:
                RETVAL = H5Pset_fill_time(plist, alloc_time);
        OUTPUT:
                RETVAL

################## H5D API

int h5dcreate_p(loc, name, dtype, sid, plist)
	int loc;
	char *name;
	int dtype;
	int sid;
	int plist;

	CODE:
		RETVAL = H5Dcreate1(loc, name, dtype, sid, plist);
	OUTPUT:
		RETVAL
		
int h5dopen_p(loc_id, name)
	int loc_id
	char *name

	CODE:
		RETVAL = H5Dopen1(loc_id, name);
	OUTPUT:
		RETVAL

int h5dclose_p(id)
	int id

	CODE:
		RETVAL = H5Dclose(id);
	OUTPUT:
		RETVAL

int h5dget_space_p(id)
	int id;

	CODE:
		RETVAL = H5Dget_space(id);	
	OUTPUT:
		RETVAL

int h5dget_type_p(id)
	int id;

	CODE:
		RETVAL = H5Dget_type(id);	
	OUTPUT:
		RETVAL

int h5tget_class_p(id)
	int id;

	CODE:
		RETVAL = H5Tget_class(id);	
	OUTPUT:
		RETVAL

int h5dwrite_double_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist, buffer)
	int dataset_id;
	int mem_type_id;
	int mem_space_id;
	int file_space_id;
	int xfer_plist;
	AV * buffer;

	PREINIT:
		int len, i;
		SV ** elem;
		double *data;
	CODE:
		len = av_len(buffer) + 1;
		data = (double *) malloc(len * sizeof(double));
		for (i = 0; i < len; i++) {
			elem = av_fetch(buffer, i, 0);
			data[i] = SvIV(*elem);
		}
		RETVAL = H5Dwrite(dataset_id, mem_type_id, mem_space_id,
                    file_space_id, xfer_plist, data);
                free(data);
	OUTPUT:
		RETVAL

int h5dwrite_float_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist, buffer)
	int dataset_id;
	int mem_type_id;
	int mem_space_id;
	int file_space_id;
	int xfer_plist;
	AV * buffer;

	PREINIT:
		int len, i;
		SV ** elem;
		float *data;
	CODE:
		len = av_len(buffer) + 1;
		data = (float *) malloc(len * sizeof(float));
		for (i = 0; i < len; i++) {
			elem = av_fetch(buffer, i, 0);
			data[i] = (float) SvIV(*elem);
		}
		RETVAL = H5Dwrite(dataset_id, mem_type_id, mem_space_id,
                    file_space_id, xfer_plist, data);
                free(data);
	OUTPUT:
		RETVAL

int h5dwrite_int8_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist, buffer)
	int dataset_id;
	int mem_type_id;
	int mem_space_id;
	int file_space_id;
	int xfer_plist;
	AV * buffer;

	PREINIT:
		int len, i;
		SV ** elem;
		char *data;
	CODE:
		len = av_len(buffer) + 1;
		data = (char *) malloc(len * sizeof(int));
		for (i = 0; i < len; i++) {
			elem = av_fetch(buffer, i, 0);
			data[i] = (char) SvIV(*elem);
		}
		RETVAL = H5Dwrite(dataset_id, mem_type_id, mem_space_id,
                    file_space_id, xfer_plist, data);
                free(data);
	OUTPUT:
		RETVAL

int h5dwrite_int_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist, buffer)
	int dataset_id;
	int mem_type_id;
	int mem_space_id;
	int file_space_id;
	int xfer_plist;
	AV * buffer;

	PREINIT:
		int len, i;
		SV ** elem;
		int *data;
	CODE:
		len = av_len(buffer) + 1;
		data = (int *) malloc(len * sizeof(int));
		for (i = 0; i < len; i++) {
			elem = av_fetch(buffer, i, 0);
			data[i] = SvIV(*elem);
		}
		RETVAL = H5Dwrite(dataset_id, mem_type_id, mem_space_id,
                    file_space_id, xfer_plist, data);
                free(data);
	OUTPUT:
		RETVAL

int h5dwrite_char_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist, buffer)
	int dataset_id;
	int mem_type_id;
	int mem_space_id;
	int file_space_id;
	int xfer_plist;
	char *buffer;

	CODE:
		RETVAL = H5Dwrite(dataset_id, mem_type_id, mem_space_id, file_space_id,
				xfer_plist, buffer);
	OUTPUT:
		RETVAL

int h5dwrite_string_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist, buffer)
	int dataset_id;
	int mem_type_id;
	int mem_space_id;
	int file_space_id;
	int xfer_plist;
	AV * buffer;

	PREINIT:
		int len, i;
		SV ** elem;
		char *data;
	CODE:
		len = av_len(buffer) + 1;
		data = (char *) calloc(len,  H5Tget_size(mem_type_id));
		for (i = 0; i < len; i++) {
			elem = av_fetch(buffer, i, 0);
			/*memcpy(data + i * H5Tget_size(mem_type_id), SvPV(*elem, PL_na),*/
			memcpy(data + i * H5Tget_size(mem_type_id),
                            SvPV(*elem, PL_na),
                            H5Tget_size(mem_type_id));
		}
		RETVAL = H5Dwrite(dataset_id, mem_type_id, mem_space_id,
                    file_space_id, xfer_plist, data);
                free(data);
	OUTPUT:
		RETVAL

int h5dwrite_vlstring_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist, buffer)
	int dataset_id
	int mem_type_id
	int mem_space_id
	int file_space_id
	int xfer_plist
	AV *buffer

	PREINIT:
		int len, i;
		SV **elem;
		char **data;
	CODE:
		len = av_len(buffer) + 1;
		data = (char **) malloc(len*sizeof(char *));
		for (i = 0; i < len; i++) {
			elem = av_fetch(buffer, i, 0);
			data[i] = SvPV(*elem, PL_na);
		}
		RETVAL = H5Dwrite(dataset_id, mem_type_id, mem_space_id,
                    file_space_id, xfer_plist, data);
                free(data);
	OUTPUT:
		RETVAL

AV * h5dread_int8_p(dataset_id, mem_space_id, file_space_id, xfer_plist)
	int dataset_id
	int mem_space_id
	int file_space_id
	int xfer_plist

	PREINIT:
		AV * data;
		char *read_data;	
		int npoints;
		int i;
		SV *elem;

	INIT:	
		if (dataset_id < 0)
			XSRETURN_UNDEF;
	CODE:
		data = newAV();
		npoints = H5Sget_select_npoints(file_space_id);
		read_data = (char *) malloc(sizeof(char) * npoints);

		H5Dread(dataset_id, H5T_NATIVE_CHAR, mem_space_id,
                    file_space_id, xfer_plist, read_data);

		for (i = 0; i < npoints; i++) {
				elem = newSViv(read_data[i]);
				av_store(data, i, elem);
		}
		RETVAL = data;
                free(read_data);
	OUTPUT:	
		RETVAL
	
AV * h5dread_int_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist)
	int dataset_id
	int mem_type_id
	int mem_space_id
	int file_space_id
	int xfer_plist

	PREINIT:
		AV * data;
	
	INIT:
		int *read_data;	
		int npoints;
		int i;
		SV *elem;
	CODE:
		data = newAV();
		npoints = H5Sget_select_npoints(file_space_id);
		read_data = (int *) malloc(sizeof(int) * npoints);

		H5Dread(dataset_id, mem_type_id, mem_space_id, file_space_id,
                    xfer_plist,	read_data);

		for (i = 0; i < npoints; i++) {
				elem = newSViv(read_data[i]);
				av_store(data, i, elem);
		}
		RETVAL = data;
                free(read_data);
	OUTPUT:	
		RETVAL
		
AV * h5dread_double_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist)
	int dataset_id
	int mem_type_id
	int mem_space_id
	int file_space_id
	int xfer_plist

	PREINIT:
		AV * data;
	
	INIT:
		double *read_data;	
		int npoints;
		int i;
		SV *elem;
	CODE:
		data = newAV();
		npoints = H5Sget_select_npoints(file_space_id);
		read_data = (double *) malloc(sizeof(double) * npoints);

		H5Dread(dataset_id, mem_type_id, mem_space_id, file_space_id,
                    xfer_plist, read_data);

		for (i = 0; i < npoints; i++) {
				elem = newSVnv(read_data[i]);
				av_store(data, i, elem);
		}
		RETVAL = data;
                free(read_data);
	OUTPUT:	
		RETVAL

AV * h5dread_string_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist)
        int dataset_id
        int mem_type_id
        int mem_space_id
        int file_space_id
        int xfer_plist

        PREINIT:
                AV * data;

        INIT:
                char *read_data;
                int npoints;
                int i;
                int len; 
                SV *elem;
        CODE:
                data = newAV();
                npoints = H5Sget_select_npoints(file_space_id);
                /* mem_type_id = H5Dget_type(dataset_id);*/
                len=0;
                if (H5Tequal(H5T_NATIVE_CHAR, mem_type_id)>0)
                    len = 1;
                read_data = (char *) malloc(H5Tget_size(mem_type_id) * npoints);

                H5Dread(dataset_id, mem_type_id, mem_space_id, file_space_id,
                    xfer_plist, read_data);

                for (i = 0; i < npoints; i++) {
                     elem = newSVpv(&read_data[i*H5Tget_size(mem_type_id)], len);
                                av_store(data, i, elem);
                }
                RETVAL = data;
                free(read_data);
        OUTPUT:
                RETVAL

AV * h5dread_vlstring_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist)
        int dataset_id
        int mem_type_id
        int mem_space_id
        int file_space_id
        int xfer_plist

        PREINIT:
                AV * data;

        INIT:
                char **read_data;
                int npoints;
                int i;
                SV *elem;
        CODE:
                data = newAV();
                npoints = H5Sget_select_npoints(file_space_id);
                read_data = (char **) malloc(sizeof(char *) * npoints);

                H5Dread(dataset_id, mem_type_id, mem_space_id, file_space_id,
                    xfer_plist, read_data);

                for (i = 0; i < npoints; i++) {
                                elem = newSVpv(read_data[i], 0);
                                av_store(data, i, elem);
                }
                RETVAL = data;
                free(read_data);
        OUTPUT:
                RETVAL

SV * h5dread_char_p(dataset_id, mem_type_id, mem_space_id, file_space_id, xfer_plist)
	int dataset_id;
	int mem_type_id;
	int mem_space_id;
	int file_space_id;
	int xfer_plist;

        PREINIT:
	        AV * data;

        INIT:
	        char *read_data;
                int npoints;
                SV *elem;

	CODE:
                data = newAV();
                npoints = H5Sget_select_npoints(file_space_id);
                read_data = (char *) malloc(H5Tget_size(mem_type_id) * (npoints+1));

                H5Dread(dataset_id, mem_type_id, mem_space_id, file_space_id,
                    xfer_plist, read_data);
                read_data[npoints+1]='\0';
                elem = newSVpv(read_data, 0);
               /* for (i = 0; i < npoints; i++) {
                                elem = newSVpv(&read_data[i*H5Tget_size(mem_type_id)], 1);
                                av_store(data, i, elem);
                }*/
                RETVAL = elem;
                free(read_data); 
	OUTPUT:
		RETVAL


int h5dextend_p(dset_id, dims)
        int dset_id;
        AV * dims;

        PREINIT:
                hsize_t *correct_dims;
                int i, rank;
                SV **elem;

        CODE:
		rank = av_len(dims)+1;
                correct_dims = (hsize_t *) malloc(rank * sizeof(hsize_t));
                for (i = 0; i < rank; i++) {
			elem = av_fetch(dims, i, 0);
			correct_dims[i] = SvIV(*elem);
                }

                RETVAL = H5Dextend(dset_id, correct_dims);
                free(correct_dims);
        OUTPUT:
                RETVAL

############## H5S API
int h5screate_p(rank, dims)
        int rank;
        SV *dims;

        INIT:
                hsize_t *correct_dims;
                int i = 0;
        CODE:
                correct_dims = (hsize_t *) malloc(rank * sizeof(hsize_t));
                for (i = 0; i < rank; i++) {
                        correct_dims[i] = (hsize_t)SvIV(*av_fetch((AV *)SvRV(dims), i, 0));
                }

                RETVAL = H5Screate_simple(rank, correct_dims, NULL);
                free(correct_dims);
        OUTPUT:
                RETVAL


int h5screate_simple_p(rank, dims, maxdims)
	int rank;
	SV *dims;
	SV *maxdims;

	INIT:
		hsize_t *correct_dims;
		hsize_t *correct_maxdims;
		int i = 0;
	CODE:
		correct_dims = (hsize_t *) malloc(rank * sizeof(hsize_t));
		correct_maxdims = (hsize_t *) malloc(rank * sizeof(hsize_t));
		for (i = 0; i < rank; i++) {
			correct_dims[i] = (hsize_t)SvIV(*av_fetch((AV *)SvRV(dims), i, 0));
			correct_maxdims[i] = (hsize_t)SvIV(*av_fetch((AV *)SvRV(maxdims), i, 0));
		}
	
		RETVAL = H5Screate_simple(rank, correct_dims, correct_maxdims);
		free(correct_dims);
		free(correct_maxdims);
	OUTPUT:	
		RETVAL

int h5sselect_hyperslab_p(space_id, op, start, stride, count, block)
	int space_id;
	int op;
	AV *start;
	AV *stride;
	AV *count;
	AV *block;

	PREINIT:
		hsize_t *correct_start;
		hsize_t *correct_stride;
		hsize_t *correct_count;
		hsize_t *correct_block;
		int len;
		int i;
                SV **elem;

	CODE:	
		len = av_len(start) + 1;
                correct_start = (hsize_t *) malloc(len * sizeof(hsize_t));
		correct_stride = (hsize_t *) malloc(len * sizeof(hsize_t));
		correct_count = (hsize_t *) malloc(len * sizeof(hsize_t));
		correct_block = (hsize_t *) malloc(len * sizeof(hsize_t));
		
		for (i = 0; i < len; i++) {
			elem = av_fetch(start, i, 0);
			correct_start[i] = SvIV(*elem);
			elem = av_fetch(stride, i, 0);
			correct_stride[i] = SvIV(*elem);
			elem = av_fetch(count, i, 0);
			correct_count[i] = SvIV(*elem);
			elem = av_fetch(block, i, 0);
			correct_block[i] = SvIV(*elem);
		}

		RETVAL = H5Sselect_hyperslab(space_id, op, correct_start, correct_stride,
				correct_count, correct_block);
		free(correct_start);
		free(correct_stride);
		free(correct_count);
		free(correct_block);
	OUTPUT:
		RETVAL
	
AV * h5sget_simple_extent_dims_p(space_id)
	int space_id

	PREINIT:
		AV * dims;
		AV * maxdims;
	
	INIT:
		hsize_t *read_dims;	
		hsize_t *read_maxdims;	
		int rank;
		int i;
		SV *elem;
	CODE:
		dims = newAV();
		maxdims = newAV();
                rank = H5Sget_simple_extent_ndims(space_id);
		read_dims = (hsize_t *) malloc(sizeof(hsize_t) * rank);
		read_maxdims = (hsize_t *) malloc(sizeof(hsize_t) * rank);

                H5Sget_simple_extent_dims(space_id, read_dims, read_maxdims);

		for (i = 0; i < rank; i++) {
                                elem = newSViv(read_dims[i]);
				av_store(dims, i, elem);

                                elem = newSViv(read_maxdims[i]);
				av_store(maxdims, i, elem);
		}

		RETVAL = dims;
	OUTPUT:
                RETVAL	





	
int h5sclose_p(id)
	int id

	CODE:
		RETVAL = H5Sclose(id);
	OUTPUT:
		RETVAL

		
###### H5T API

int h5tcreate_enum_p(base)
	int base;

	CODE:
		RETVAL = H5Tenum_create(base);
	OUTPUT:
		RETVAL

int h5tenum_insert_char_p(type, name, value)
	int type;
	char *name;
	int value;

	PREINIT:
		char c_value;
	CODE:
		c_value = (char) value;
		RETVAL = H5Tenum_insert(type, name, &c_value);
	OUTPUT:
		RETVAL	
		
int h5tcreate_string_p(size)
	size_t size;

	CODE:	
		RETVAL = H5Tcopy(H5T_C_S1);
		H5Tset_size(RETVAL, size);
	OUTPUT:
		RETVAL

int h5tcreate_compound_p(size)
	size_t size

	CODE:
		RETVAL = H5Tcreate(H5T_COMPOUND, size);
		if (RETVAL < 0)
			printf("ERROR CREATING DTYPE\n");
	OUTPUT:	
		RETVAL

int h5tinsert_p(type, name, offset, field)
	int type;
	char *name;
	size_t offset;
	int field;

	CODE:
		RETVAL = H5Tinsert((hid_t)type, name, offset, field);
	OUTPUT:
		RETVAL

int h5tget_size_p(tid)
	int tid	

	CODE:
		RETVAL = H5Tget_size(tid);
	OUTPUT:
		RETVAL

int h5tcopy(tid)
	int tid	

	CODE:
		RETVAL = H5Tcopy(tid);
	OUTPUT:
		RETVAL

int h5tclose_p(id)
	int id

	CODE:
		RETVAL = H5Tclose(id);
	OUTPUT:
		RETVAL

int h5tequal_p(id1, id2)
	int id1;
	int id2;

	CODE:
		RETVAL = H5Tequal(id1, id2);
	OUTPUT:	
		RETVAL

 #---------------------------------------------------------------------------#
 # H5L API
 #---------------------------------------------------------------------------#

SV * h5lget_name_by_idx_p(loc_id, group_name, index_field, order, n, lapl_id)
    hid_t loc_id
    char *group_name
    H5_index_t index_field
    H5_iter_order_t order
    hsize_t n
    hid_t lapl_id

    INIT:
        char *name;
        SV *data;
        //size_t size;

    CODE:
            //size = (size_t *)malloc(sizeof(size_t));
            size_t size = H5Lget_name_by_idx(
                loc_id,
                group_name,
                index_field,
                order,
                n,
                NULL,
                0,
                lapl_id
            ) + 1;
            name = (char *)malloc(sizeof(char)*size);
            H5Lget_name_by_idx(
                loc_id,
                group_name,
                index_field,
                order,
                n,
                name,
                size,
                lapl_id
            );

            data = newSVpv(name, 0);
            RETVAL = data;
            free(name);
    OUTPUT:
            RETVAL

 #---------------------------------------------------------------------------#
 # H5O API
 #---------------------------------------------------------------------------#

SV * h5oget_info_p(object_id)
        hid_t object_id

        PREINIT:
            herr_t ret;
            HV *info_hash;
            HV *hdr_hash;
            HV *space_hash;
            HV *mesg_hash;
            H5O_info_t *info;

        CODE:
            info = (H5O_info_t *)malloc(sizeof(H5O_info_t));
            ret = H5Oget_info(object_id, info);

            H5O_hdr_info_t hdr = info->hdr;

            info_hash  = (HV *) sv_2mortal((SV *) newHV ());
            hdr_hash   = (HV *) sv_2mortal((SV *) newHV ());
            space_hash = (HV *) sv_2mortal((SV *) newHV ());
            mesg_hash  = (HV *) sv_2mortal((SV *) newHV ());

            hv_store( space_hash, "total", 5, newSVuv( hdr.space.total ), 0 );
            hv_store( space_hash, "meta",  4, newSVuv( hdr.space.meta  ), 0 );
            hv_store( space_hash, "mesg",  4, newSVuv( hdr.space.mesg  ), 0 );
            hv_store( space_hash, "free",  4, newSVuv( hdr.space.free  ), 0 );

            hv_store( mesg_hash, "present", 7, newSVuv( hdr.mesg.present ), 0 );
            hv_store( mesg_hash, "shared",  6, newSVuv( hdr.mesg.shared  ), 0 );

            hv_store( hdr_hash, "version", 7, newSVuv( hdr.version ), 0 );
            hv_store( hdr_hash, "nmesgs",  6, newSVuv( hdr.nmesgs ),  0 );
            hv_store( hdr_hash, "nchunks", 7, newSVuv( hdr.nchunks ), 0 );
            hv_store( hdr_hash, "flags",   5, newSVuv( hdr.flags ),   0 );
            hv_store( hdr_hash, "space",   5, newRV((SV *)space_hash), 0 );
            hv_store( hdr_hash, "mesg",    4, newRV((SV *)mesg_hash),  0 );


            hv_store( info_hash, "fileno", 6, newSVuv( info->fileno ), 0 );
            hv_store( info_hash, "addr",   4, newSVuv( info->addr ),   0 );
            hv_store( info_hash, "type",   4, newSViv( info->type ),   0 );
            hv_store( info_hash, "rc",     2, newSVuv( info->rc ),     0 );
            hv_store( info_hash, "atime",  5, newSViv( info->atime ),  0 );
            hv_store( info_hash, "mtime",  5, newSViv( info->mtime ),  0 );
            hv_store( info_hash, "ctime",  5, newSViv( info->ctime ),  0 );
            hv_store( info_hash, "btime",  5, newSViv( info->btime ),  0 );
            hv_store( info_hash, "hdr",    3, newRV((SV *)hdr_hash),   0 );

            RETVAL = newRV((SV *)info_hash);
            free(info);
        OUTPUT:
            RETVAL
