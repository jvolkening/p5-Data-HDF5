use 5.008;
use ExtUtils::MakeMaker;
use ExtUtils::Constant qw/WriteConstants/;

my @predefined_types;
open my $types, '<', 'predefined_types.list';
while (my $line = <$types>) {
    chomp $line;
    push @predefined_types, $line;
};
close $types;

my @names = qw/
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
/;

push @names, map { {name => $_, macro => 1} } @enums;
push @names, @predefined_types;
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

    LIBS => '-lhdf5 -lhdf5_hl',
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
    clean => { FILES => [
        'Data-HDF5-*',
        '*.inc',
        '*.gcov',
        '*.gcno',
        '*.gcda',
        'cover_db',
    ] },
);
