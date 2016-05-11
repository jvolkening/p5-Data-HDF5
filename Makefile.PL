use 5.008;
use ExtUtils::MakeMaker;
use ExtUtils::Constant qw/WriteConstants/;

my @names = qw/
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
/;
my @enums = qw/
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

push @names, map { {name => $_, macro => 1} } @enums;
WriteConstants(
    NAME => 'Data::HDF5',
    DEFAULT_TYPE => 'IV',
    NAMES => \@names,
);

WriteMakefile(
    NAME          => 'Data::HDF5',
    AUTHOR        => q{Jeremy Volkening <jdv@base2bio.com>},
    VERSION_FROM  => 'lib/Data/HDF5.pm',
    ABSTRACT_FROM => 'lib/Data/HDF5.pm',
    LICENSE       => 'GPL_3',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
        'ExtUtils::Constant'  => 0,
    },
    PREREQ_PM     => {},

    # These are Debian-specific locations.
    # Hopefully in other distros libs will be in standard locations
    LIBS => [ qw{-L/usr/lib/x86_64-linux-gnu/hdf5/serial/
        -lhdf5 -L/usr/lib/x86_64-linux-gnu/hdf5/serial/libhdf5_hl.a'} ],
    INC  => '-I. -I/usr/include/hdf5/serial',
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url => 'https://github.com/jvolkening/p5-Data-HDF5.git',
                web => 'https://github.com/jvolkening/p5-Data-HDF5',
            },
        },
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Data-HDF5-*' },
);
