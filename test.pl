use strict;
use warnings;
use Data::Dumper;

use Data::HDF5 qw/:all/;

my $file = h5fopen_p($ARGV[0], H5F_ACC_RDONLY, H5P_DEFAULT);
my $grp  = h5gopen_p($file,"/");
my $n = h5gget_num_objs_p($grp);
for my $i (0..$n-1) {
    my $size = 100;
    my $name = h5gget_objname_by_idx_p($grp,$i,$size);
    my $type = h5gget_objtype_by_idx_p($grp,$i);
    print "$name\t$type\n";
    if ($type eq H5G_DATASET) {
        my $dsid = h5dopen_p($grp, $name);
        do_set($dsid);
        h5dclose_p($dsid);
    }
}

sub do_set {

    my ($dsid) = @_;
    my $type = h5dget_type_p($dsid);
    my $did = h5dget_space_p($dsid);
    my @dims = h5sget_simple_extent_dims_p($did);
    my $c = h5tget_class_p($type);
    print "class: $c\n";
    print Dumper @dims;

}
