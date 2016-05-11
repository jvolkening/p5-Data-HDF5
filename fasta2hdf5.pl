#!/usr/bin/perl

# This script reads a fasta file and writes an hdf5 file with 3 datasets:
# ids is an ordered dataset with sequence id as key and a pointer to comments
# comments contains the comment, offset and length information about sequences
# stored in the sequences dataset
# sequences stores all the sequences in a single array

use lib "/install_path";
use HDFPerl;
use strict;
use Init;

Init::initialize();

if ($#ARGV+1 < 2){
    print "\nUsage:\n";
    print "\t./fasta2hdf5.pl fasta_file hdf5_file\n\n";
    exit(1);
}

my $input_filename = $ARGV[0];
my $hdf_filename=$ARGV[1];
my %ids_hash = ();
my @comments_buf = ();
my @unitarray=(1);
my @h5offset=(0);
my @h5length=();
my $compression_level=7; # from 0 to 9
my $i=0;
my @dims=();

# create a new HDF File.
my $fid = HDFPerl::h5fcreate_p($hdf_filename, $Init::H5F_ACC_TRUNC,
         $Init::H5P_DEFAULT,    $Init::H5P_DEFAULT);

# create chunked and compressed "sequences" dataset
my @cur_dims=(1);
my @chk_dims=(5000);
my @maxdims=($Init::H5S_UNLIMITED);
my $sid = HDFPerl::h5screate_simple_p(1, \@cur_dims, \@maxdims);
my $pid = HDFPerl::h5pcreate_p($Init::H5P_DATASET_CREATE);
HDFPerl::h5pset_chunk_p($pid, 1, \@chk_dims);
HDFPerl::h5pset_deflate_p($pid, $compression_level);
my $buf_name="sequences";
my $did = HDFPerl::h5dcreate_p($fid, $buf_name, $Init::H5T_NATIVE_CHAR,
                $sid, $pid);
HDFPerl::h5pclose_p($pid);

open(FILE, "< $input_filename");
my $line = <FILE>;

# iterate over every record
while ($line){
    chomp $line;
    my @header=();
    my @ids=();
    @header=split(/ /, $line);

    # string starting with ">" and ending with first " " is splitted at "|" 
    # to form the array @ids. IDs are extracted at locations 1, 3, and 4
    # and stored in the %ids_hash data structure
    @ids=split(/\|/, $header[0]);
    $ids_hash{$ids[1]}=$i;
    $ids_hash{$ids[3]}=$i;
    $ids_hash{$ids[4]}=$i;

    # rest of string is stored in $comments 
    my $comment=join(' ',@header[1 .. $#header]);
    my $j=0;
    my @seq=();
    $seq[$j] = <FILE>;

    # iterate over every line of a sequence 
    while ( ($seq[$j] !~ /^>/) && ($seq[$j]) ){
        chomp $seq[$j];
        $j++;
        $seq[$j] = <FILE>;
    }

    # store record information in @comments_buf data structure
    my $sequence = join('',@seq[0 .. $j-1]);
    @h5length = (length($sequence));
    $comments_buf[0][$i] = $comment;
    $comments_buf[1][$i] = $h5offset[0];
    $comments_buf[2][$i] = $h5length[0];

    $cur_dims[0] = $h5offset[0]+$h5length[0]; 
    HDFPerl::h5dextend_p($did, \@cur_dims);
    HDFPerl::h5sclose_p($sid);
    $sid = HDFPerl::h5dget_space_p($did);

    # selects location and length on the dataset space for writing
    HDFPerl::h5sselect_hyperslab_p($sid, $Init::H5S_SELECT_SET, \@h5offset, \@unitarray, \@h5length, \@unitarray);
    my $mid = HDFPerl::h5screate_simple_p(1, \@h5length, \@h5length);
 
    # writes into the dataset
    HDFPerl::h5dwrite_char_p($did, $Init::H5T_NATIVE_CHAR, $mid, $sid,
                $Init::H5P_DEFAULT, $sequence);
    HDFPerl::h5sclose_p($mid);

    # settings for next iteration
    $h5offset[0]=$h5offset[0]+$h5length[0];
    $i++; 
    $line=$seq[$j];
}
my $num_recs = $i;
HDFPerl::h5dclose_p($did);
HDFPerl::h5sclose_p($sid);

my $id;
my $j = 0;
my @ids_buf;

# sorts %ids_hash and prepares @ids_buf data structure for writing
foreach $id (sort keys %ids_hash){
    $ids_buf[0][$j]=$id;
    $ids_buf[1][$j]=$ids_hash{$id};
    $j++;
}
my $num_ids = $j;

# create compound datatype for "ids" dataset
my $stid = HDFPerl::h5tcreate_string_p(10);
my $intsize = HDFPerl::h5tget_size_p($Init::H5T_NATIVE_INT);
my $tid = HDFPerl::h5tcreate_compound_p(10+$intsize);
HDFPerl::h5tinsert_p($tid, "id", 0, $stid);
HDFPerl::h5tinsert_p($tid, "index", 10, $Init::H5T_NATIVE_INT);

# create chunked and compressed "ids" dataset
@dims=($num_ids);
@chk_dims=(int($num_ids/10)+1000);
$sid = HDFPerl::h5screate_simple_p(1, \@dims, \@maxdims);
$pid = HDFPerl::h5pcreate_p($Init::H5P_DATASET_CREATE);
HDFPerl::h5pset_chunk_p($pid, 1, \@chk_dims);
HDFPerl::h5pset_deflate_p($pid, $compression_level);
my $did = HDFPerl::h5dcreate_p($fid, "ids", $tid,
                $sid, $pid);

# write field "id" data into "ids" dataset
my $mtid = HDFPerl::h5tcreate_compound_p(10);
HDFPerl::h5tinsert_p($mtid, "id", 0, $stid);
HDFPerl::h5dwrite_string_p($did, $mtid, $sid, $sid, $Init::H5P_DEFAULT,
    $ids_buf[0]);
HDFPerl::h5tclose_p($mtid);

# write field "index" data into "ids" dataset
$mtid = HDFPerl::h5tcreate_compound_p($intsize);
HDFPerl::h5tinsert_p($mtid, "index", 0, $Init::H5T_NATIVE_INT);
HDFPerl::h5dwrite_int_p($did, $mtid, $sid, $sid, $Init::H5P_DEFAULT,
    $ids_buf[1]);
HDFPerl::h5tclose_p($mtid);

# close resources
HDFPerl::h5dclose_p($did);
HDFPerl::h5sclose_p($sid);
HDFPerl::h5pclose_p($pid);

# create compound datatype for "comments" dataset
my $vlstid = HDFPerl::h5tcreate_string_p($Init::H5T_VARIABLE);
my $vlsize = HDFPerl::h5tget_size_p($vlstid);
my $tid = HDFPerl::h5tcreate_compound_p($vlsize+2*$intsize);
HDFPerl::h5tinsert_p($tid, "comment", 0, $vlstid); 
HDFPerl::h5tinsert_p($tid, "offset", $vlsize, $Init::H5T_NATIVE_INT); 
HDFPerl::h5tinsert_p($tid, "length", $vlsize+$intsize, $Init::H5T_NATIVE_INT); 

# create chunked and compressed "comments" dataset
@dims=($num_recs);
@chk_dims=(int($num_recs/10)+1000);
$sid = HDFPerl::h5screate_simple_p(1, \@dims, \@maxdims);
$pid = HDFPerl::h5pcreate_p($Init::H5P_DATASET_CREATE);
HDFPerl::h5pset_chunk_p($pid, 1, \@chk_dims);
HDFPerl::h5pset_deflate_p($pid, $compression_level);
$did = HDFPerl::h5dcreate_p($fid, "comments", $tid, $sid,
       $pid);

# write field "comment" data into "comments" dataset
my $ctid = HDFPerl::h5tcreate_compound_p($vlsize);
HDFPerl::h5tinsert_p($ctid, "comment", 0, $vlstid);       
HDFPerl::h5dwrite_vlstring_p($did, $ctid, $sid, $sid, $Init::H5P_DEFAULT,
        $comments_buf[0]);
HDFPerl::h5tclose_p($ctid);

# write field "offset" data into "comments" dataset
my $ctid = HDFPerl::h5tcreate_compound_p($intsize);
HDFPerl::h5tinsert_p($ctid, "offset", 0, $Init::H5T_NATIVE_INT);       
HDFPerl::h5dwrite_int_p($did, $ctid, $sid, $sid, $Init::H5P_DEFAULT,
       $comments_buf[1]);
HDFPerl::h5tclose_p($ctid);

# write field "length" data into "comments" dataset
my $ctid = HDFPerl::h5tcreate_compound_p($intsize);
HDFPerl::h5tinsert_p($ctid, "length", 0, $Init::H5T_NATIVE_INT);       
HDFPerl::h5dwrite_int_p($did, $ctid, $sid, $sid, $Init::H5P_DEFAULT,
       $comments_buf[2]);
HDFPerl::h5tclose_p($ctid);

# close resources
HDFPerl::h5dclose_p($did);
HDFPerl::h5sclose_p($sid);
HDFPerl::h5pclose_p($pid);
HDFPerl::h5fclose_p($fid);

