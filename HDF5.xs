#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"
#include "hdf5.h"
#include "hdf5_hl.h"
#include "const-c.inc"

#include <string.h>


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


#############################################################################
# H5A API
#############################################################################

hid_t
H5Aopen_by_name(loc_id, obj_name, attr_name, aapl_id, lapl_id)
    hid_t loc_id
	char *obj_name
	char *attr_name
	hid_t aapl_id
	hid_t lapl_id

#---------------------------------------------------------------------------#

hid_t
H5Aopen_by_idx(loc_id, obj_name, idx_type, order, n, aapl_id, lapl_id)
    hid_t loc_id
	char *obj_name
    H5_index_t idx_type
    H5_iter_order_t order
    hsize_t n
	hid_t aapl_id
	hid_t lapl_id

#---------------------------------------------------------------------------#

herr_t
H5Aclose(attr_id)
	hid_t attr_id

#---------------------------------------------------------------------------#

hid_t
H5Aget_type(attr_id)
	hid_t attr_id

#---------------------------------------------------------------------------#

SV *
H5Aget_name(attr_id)
    hid_t attr_id

    INIT:
        char *name;
        SV *data;

    CODE:
        size_t size = H5Aget_name(
            attr_id,
            0,
            NULL
        ) + 1;
        name = (char *)malloc(sizeof(char)*size);
        H5Aget_name(
            attr_id,
            size,
            name
        );

        data = newSVpv(name, 0);
        RETVAL = data;
        free(name);
    OUTPUT:
        RETVAL

#---------------------------------------------------------------------------#

AV * 
H5Aread(attr_id)
    hid_t attr_id;

    PREINIT:

        AV *data;
        int npoints;
        int i;
        hid_t attr_space_id;
        SV *elem;

    INIT:
        if (attr_id < 0)
                XSRETURN_UNDEF;
        hid_t type;
        hid_t native;
        H5T_class_t class;
    CODE:
        type = H5Aget_type(attr_id);
        class = H5Tget_class(type);
        native = H5Tget_native_type(type, H5T_DIR_ASCEND);

        data = (AV *)sv_2mortal((SV *)newAV());
        attr_space_id = H5Aget_space(attr_id);
        npoints = H5Sget_select_npoints(attr_space_id);

        hsize_t size;
        size = H5Tget_size(type);
        int sign;
        sign = H5Tget_sign(type);


        if (class == H5T_INTEGER) {

            if (size == 1) {
                if (sign == H5T_SGN_NONE) {
                    uint8_t *read_data;
                    read_data = (uint8_t *) malloc(sizeof(uint8_t) * npoints);
                    H5Aread(attr_id, native, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSVuv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
                else if (sign == H5T_SGN_2) {
                    int8_t *read_data;
                    read_data = (int8_t *) malloc(sizeof(int8_t) * npoints);
                    H5Aread(attr_id, native, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSViv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
            }
            else if (size == 2) {
                if (sign == H5T_SGN_NONE) {
                    uint16_t *read_data;
                    read_data = (uint16_t *) malloc(sizeof(uint16_t) * npoints);
                    H5Aread(attr_id, native, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSVuv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
                else if (sign == H5T_SGN_2) {
                    int16_t *read_data;
                    read_data = (int16_t *) malloc(sizeof(int16_t) * npoints);
                    H5Aread(attr_id, native, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSViv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
            }
            else if (size == 4) {
                if (sign == H5T_SGN_NONE) {
                    uint32_t *read_data;
                    read_data = (uint32_t *) malloc(sizeof(uint32_t) * npoints);
                    H5Aread(attr_id, native, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSVuv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
                else if (sign == H5T_SGN_2) {
                    int32_t *read_data;
                    read_data = (int32_t *) malloc(sizeof(int32_t) * npoints);
                    H5Aread(attr_id, native, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSViv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
            }
            else {
                if (sign == H5T_SGN_NONE) {
                    uint64_t *read_data;
                    read_data = (uint64_t *) malloc(sizeof(uint64_t) * npoints);
                    H5Aread(attr_id, native, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSVuv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
                else if (sign == H5T_SGN_2) {
                    int64_t *read_data;
                    read_data = (int64_t *) malloc(sizeof(int64_t) * npoints);
                    H5Aread(attr_id, native, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSViv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
            }


        }
        else if (class == H5T_FLOAT) {

            double *read_data;
            read_data = (double *) malloc(sizeof(double) * npoints);
            H5Aread(attr_id, native, read_data);
            for (i = 0; i < npoints; i++) {
                elem = newSVnv(read_data[i]);
                av_store(data, i, elem);
            }
            free(read_data);

        }
        else if (class == H5T_STRING) {

            char *read_data;
            read_data = (char *) malloc(size*sizeof(char)*npoints);
            H5Aread(attr_id, native, read_data);
            char *j;
            j = read_data;
            for (i = 0; i < npoints; i++) {
                char field[size];
                strcpy(field, j);
                elem = newSVpv(field, 0);
                av_store(data, i, elem);
                j += size;
            }
            free(read_data);

        }
        H5Sclose(attr_space_id);
        H5Tclose(type);
        H5Tclose(native);
        RETVAL = data;
    OUTPUT:
        RETVAL


#############################################################################
# H5D API
#############################################################################


AV * 
H5Dread(dataset_id)
    hid_t dataset_id;

    PREINIT:

        AV *data;
        int npoints;
        int i;
        hid_t dataset_space_id;
        SV *elem;

    INIT:
        if (dataset_id < 0)
                XSRETURN_UNDEF;
        hid_t type;
        hid_t native;
        H5T_class_t class;
    CODE:
        type = H5Dget_type(dataset_id);
        class = H5Tget_class(type);
        native = H5Tget_native_type(type, H5T_DIR_ASCEND);

        data = (AV *)sv_2mortal((SV *)newAV());
        dataset_space_id = H5Dget_space(dataset_id);
        npoints = H5Sget_select_npoints(dataset_space_id);

        hsize_t size;
        size = H5Tget_size(type);
        int sign;
        sign = H5Tget_sign(type);

        if (class == H5T_INTEGER) {

            if (size == 1) {
                if (sign == H5T_SGN_NONE) {
                    uint8_t *read_data;
                    read_data = (uint8_t *) malloc(sizeof(uint8_t) * npoints);
                    H5Dread(dataset_id, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSVuv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
                else if (sign == H5T_SGN_2) {
                    int8_t *read_data;
                    read_data = (int8_t *) malloc(sizeof(int8_t) * npoints);
                    H5Dread(dataset_id, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSViv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
            }
            else if (size == 2) {
                if (sign == H5T_SGN_NONE) {
                    uint16_t *read_data;
                    read_data = (uint16_t *) malloc(sizeof(uint16_t) * npoints);
                    H5Dread(dataset_id, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSVuv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
                else if (sign == H5T_SGN_2) {
                    int16_t *read_data;
                    read_data = (int16_t *) malloc(sizeof(int16_t) * npoints);
                    H5Dread(dataset_id, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSViv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
            }
            else if (size == 4) {
                if (sign == H5T_SGN_NONE) {
                    uint32_t *read_data;
                    read_data = (uint32_t *) malloc(sizeof(uint32_t) * npoints);
                    H5Dread(dataset_id, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSVuv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
                else if (sign == H5T_SGN_2) {
                    int32_t *read_data;
                    read_data = (int32_t *) malloc(sizeof(int32_t) * npoints);
                    H5Dread(dataset_id, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSViv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
            }
            else {
                if (sign == H5T_SGN_NONE) {
                    uint64_t *read_data;
                    read_data = (uint64_t *) malloc(sizeof(uint64_t) * npoints);
                    H5Dread(dataset_id, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSVuv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
                else if (sign == H5T_SGN_2) {
                    int64_t *read_data;
                    read_data = (int64_t *) malloc(sizeof(int64_t) * npoints);
                    H5Dread(dataset_id, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, read_data);
                    for (i = 0; i < npoints; i++) {
                        elem = newSViv(read_data[i]);
                        av_store(data, i, elem);
                    }
                    free(read_data);
                }
            }

        }
        else if (class == H5T_FLOAT) {

            double *read_data;
            read_data = (double *) malloc(sizeof(double) * npoints);
            H5Dread(dataset_id, native, H5S_ALL, H5S_ALL, H5P_DEFAULT, read_data);
            for (i = 0; i < npoints; i++) {
                elem = newSVnv(read_data[i]);
                av_store(data, i, elem);
            }
            free(read_data);

        }
        else if (class == H5T_STRING) {

            hsize_t size;
            size = H5Tget_size(type);
            char *read_data;
            read_data = (char *) malloc(size*npoints);
            H5Dread(dataset_id, native, H5S_ALL, H5S_ALL, H5P_DEFAULT, read_data);
            char *j;
            j = read_data;
            for (i = 0; i < npoints; i++) {
                char field[size];
                strcpy(field, j);
                elem = newSVpv(field, 0);
                av_store(data, i, elem);
                j += size;
            }
            free(read_data);

        }
        else {
            av_store(data, 0, newSViv(0));
        }
        H5Sclose(dataset_space_id);
        H5Tclose(type);
        H5Tclose(native);
        RETVAL = data;
    OUTPUT:
        RETVAL

#---------------------------------------------------------------------------#

hid_t
H5Dopen(loc_id, name, dapl_id)
	hid_t loc_id
	char *name
    hid_t dapl_id

	CODE:
		RETVAL = H5Dopen2(loc_id, name, dapl_id);
	OUTPUT:
		RETVAL

#---------------------------------------------------------------------------#

herr_t
H5Dclose(id)
	hid_t id

#---------------------------------------------------------------------------#

hid_t
H5Dget_space(id)
	hid_t id;

#---------------------------------------------------------------------------#

hid_t
H5Dget_type(id)
    hid_t id;


#############################################################################
# H5T API
#############################################################################

		
H5T_class_t
H5Tget_class(id)
	hid_t id

#---------------------------------------------------------------------------#

hid_t
H5Tget_native_type(id, direction)
	hid_t id
    H5T_direction_t direction

#---------------------------------------------------------------------------#

herr_t
H5Tclose(id)
	hid_t id


#############################################################################
# H5L API
#############################################################################


SV *
H5Lget_name_by_idx(loc_id, group_name, index_field, order, n, lapl_id)
    hid_t loc_id
    char *group_name
    H5_index_t index_field
    H5_iter_order_t order
    hsize_t n
    hid_t lapl_id

    INIT:
        char *name;
        SV *data;

    CODE:
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


#############################################################################
# H5O API
#############################################################################


SV *
H5Oget_info(object_id)
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

        hv_store( hdr_hash, "version", 7, newSVuv( hdr.version ),    0 );
        hv_store( hdr_hash, "nmesgs",  6, newSVuv( hdr.nmesgs ),     0 );
        hv_store( hdr_hash, "nchunks", 7, newSVuv( hdr.nchunks ),    0 );
        hv_store( hdr_hash, "flags",   5, newSVuv( hdr.flags ),      0 );
        hv_store( hdr_hash, "space",   5, newRV(  (SV *)space_hash), 0 );
        hv_store( hdr_hash, "mesg",    4, newRV(  (SV *)mesg_hash),  0 );

        hv_store( info_hash, "fileno",    6, newSVuv( info->fileno    ), 0 );
        hv_store( info_hash, "addr",      4, newSVuv( info->addr      ), 0 );
        hv_store( info_hash, "type",      4, newSViv( info->type      ), 0 );
        hv_store( info_hash, "rc",        2, newSVuv( info->rc        ), 0 );
        hv_store( info_hash, "atime",     5, newSViv( info->atime     ), 0 );
        hv_store( info_hash, "mtime",     5, newSViv( info->mtime     ), 0 );
        hv_store( info_hash, "ctime",     5, newSViv( info->ctime     ), 0 );
        hv_store( info_hash, "btime",     5, newSViv( info->btime     ), 0 );
        hv_store( info_hash, "num_attrs", 9, newSVuv( info->num_attrs ), 0 );
        hv_store( info_hash, "hdr",       3, newRV(   (SV *)hdr_hash  ), 0 );

        RETVAL = newRV((SV *)info_hash);
        free(info);
    OUTPUT:
        RETVAL
