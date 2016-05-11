#!/usr/bin/perl
# This script reads two fasta files and writes an hdf5 file with four datasets:
# "ids" is a dataset with sequence id and a pointer to "comments"
# "comments" contains the comment, offset and length information about sequences
# and quality values 
# "sequences" stores all the sequences in a single array
# "quals" stores all the quality values in a single array

use lib "/install_path";
use strict;
use BioHDF_Perl;
use Init;

# initialize HDF5 environment
Init::initialize();

# input and output files
my $seq_filename = "FACTORVIII_01.fsa";
my $qual_filename = "FACTORVIII_01.qual";
my $hdf_filename = "FACTORVIII_01.h5";

# working vars
my $i=0;
my $ref;
my @header=();
my @ids=();
my @pre_ids=();

# create a new HDF File.
my $fid = BioHDF_Perl::create_sequence_file($hdf_filename);

# create sequence collection 
$ref = BioHDF_Perl::create_sequence_collection($fid, "collection1", "sequences from iFinch");
my @collection = @{$ref};

open(QUAL, "< $qual_filename");
my $line_qual = <QUAL>;

open(SEQ, "< $seq_filename");
my $line_seq = <SEQ>;

chomp $line_qual;
chomp $line_seq;

# iterate over every record
while ($line_qual){

    # sequence IDs is extracted from each sequence header line
    @header=split(/ /, $line_qual);
    @pre_ids=split(/>/, $header[0]);
    @ids=($pre_ids[1]);

    # rest of string is stored in $comments. We extract the comment from the
    # quality file because it is more consistent 
    my $comment=join(' ',@header[1 .. $#header]);

    # working vars for iteration on each line of belonging to the current
    # record in both FASTA files (sequences and qualities)
    my $j=0;
    my @seq=();
    my @qual=();
    $qual[$j] = <QUAL>;
    $seq[$j] = <SEQ>;
    chomp $qual[$j];
    chomp $seq[$j];

    # iterate over every line of current record 
    while ( ($qual[$j] !~ /^>/) && ($qual[$j]) ){
        $j++;
        $qual[$j] = <QUAL>;
        $seq[$j] = <SEQ>;
        chomp $qual[$j];
        chomp $seq[$j];
    }

    # quality data is arranged as an array of numbers
    my $quality = join(' ',@qual[0 .. $#qual-1]);
    my @post_quality = split(/ /, $quality);

    # sequence data is arranged as an array of bases. Both arrays must have the
    # same length.
    my $sequence = join('',@seq[0 .. $#seq-1]);
    my @post_sequence = (""); 
    if (length($sequence) != 0) {
        @post_sequence = split(//, $sequence);
    }

    # add sequence into the collection
    BioHDF_Perl::add_sequence(\@collection, \@ids, $comment, \@post_sequence,
        \@post_quality);

    # settings for next iteration
    $i++; 
    $line_qual=$qual[$#qual];
}
print "RECORDS READ\n$i\n\n";

# sort the sequence prior searching
BioHDF_Perl::sort_sequence_collection(\@collection);

# set ID of sequence to be found
my $key="FACTORVIII_01F_02.ab1";

# search sequence in the collection
my $ref = BioHDF_Perl::get_sequence(\@collection, $key);
print "ID\n$key\n\n";
if ($ref >= 0) {
    my @seq=@{$ref};
    print "COMMENT\n$seq[0]\n\n";
    print "SEQUENCE\n@{$seq[1]}\n\n";
    print "QUALITIES\n@{$seq[2]}\n\n";
} else {
    print "$key not found \n\n";
}

# display collection description
my $description = BioHDF_Perl::get_collection_description(\@collection);
print "COLLECTION DESCRIPTION\n$description\n";

# close sequence collection and file
BioHDF_Perl::close_sequence_collection(\@collection);
BioHDF_Perl::close_sequence_file($fid);

