use ExtUtils::testlib;
use Data::Dumper;
use HDFPerl;
use strict;
use Init;
use POSIX;

package BioHDF_Perl;

use constant ID_LENGTH => 25;
use constant LIN_SEARCH_BUF_SIZE => 1000;
use constant DESCRIPTION_SIZE => 50;
use constant NAME_SIZE => 20;
use constant CHUNK_SIZE => 5000;
# levels 0-9. lower levels are faster but result in less compression
use constant COMPRESSION_LEVEL => 7; 
################################################
#
# HIGH LEVEL APIS FOR FASTA DATA MANAGEMENT IN
# HDF5 FILE
#
################################################


# This function creates an HDF5 sequence file.
# INPUT:	file name
# RETURN:	file identifier

sub create_sequence_file {
        my $hdf_filename = shift;
        my $fid = HDFPerl::h5fcreate_p($hdf_filename, $Init::H5F_ACC_TRUNC,
            $Init::H5P_DEFAULT, $Init::H5P_DEFAULT);
        
        return $fid;
}

# This function opens an HDF5 sequence file.
# INPUT:	file name
# RETURN:	file identifier

sub open_sequence_file {
        my $hdf_filename = shift;
        my $fid = HDFPerl::h5fopen_p($hdf_filename, $Init::H5F_ACC_RDWR,
            $Init::H5P_DEFAULT);
        
        return $fid;
}

# This function gets the description of a collection.
# INPUT:        reference to array containing objects identifiers	
# RETURN:       collection description	

sub get_collection_description {
        my $collection_ref = shift;
        my @collection = @{$collection_ref};

        my $description =  HDFPerl::h5gget_comment_p($collection[0], ".",
            DESCRIPTION_SIZE);

        return $description; 
}

# This function looks for collections names in an HDF5 sequence file.
# INPUT:	file identifier
# RETURN:	reference to array containing collections names. On error, it
#               returns a negative value

sub get_sequence_collections {
        my $fid = shift;
       
        # get number of collections in sequence file
        my $number = HDFPerl::h5gget_num_objs_p($fid);
        if ($number < 0) {
            return $number;
        }
        my $i;
        my @names=();

        # iterate on collections
        for ($i=0; $i<$number; $i++){
            $names[$i] = HDFPerl::h5gget_objname_by_idx_p($fid, $i, NAME_SIZE);
        } 
        
        return \@names;
}


# This function gets the sequence identifiers for a given collection. 
# INPUT:	reference to array containing objects identifiers
#
# RETURN:	reference to array containing sequence identifiers. On error,
#               it returns a negative value 

sub get_sequence_ids {
        my $collection_ref = shift;

        my @collection = @{$collection_ref};
        my $sid = HDFPerl::h5dget_space_p($collection[0]);

        # read "id" field from all sequences in the collection
        my $stid = HDFPerl::h5tcreate_string_p(ID_LENGTH);
        my $mtid = HDFPerl::h5tcreate_compound_p(ID_LENGTH);
        HDFPerl::h5tinsert_p($mtid, "id", 0, $stid);
        my $ref = HDFPerl::h5dread_string_p($collection[0], $mtid, $sid, $sid,
            $Init::H5P_DEFAULT);
        
        HDFPerl::h5tclose_p($mtid);
        HDFPerl::h5tclose_p($stid);
        HDFPerl::h5sclose_p($sid);

        return $ref;
}

# This function sorts the "ids" dataset with respect to the "id" field.
# Sorting is necessary to perform binary searches. At this point, the sorting
# of the entire dataset is performed in memory.
# INPUT:	collection ids
#
# RETURN:	status
 
sub sort_sequence_collection {
        my $collection_ref = shift;

        my @collection = @{$collection_ref};
        my @ids_buf=();
        my %ids_hash=();
        my @unit_array=(1);
        my @status=();


        # read "id" field from all sequences in the collection
        my $sid = HDFPerl::h5dget_space_p($collection[0]);
        my $stid = HDFPerl::h5tcreate_string_p(ID_LENGTH);
        my $cid1 = HDFPerl::h5tcreate_compound_p(ID_LENGTH);
        HDFPerl::h5tinsert_p($cid1, "id", 0, $stid);
        $ids_buf[0] = HDFPerl::h5dread_string_p($collection[0], $cid1, $sid,
            $sid, $Init::H5P_DEFAULT);
        HDFPerl::h5tclose_p($stid);

        # read "index" field from all sequences in the collection
        my $intsize = HDFPerl::h5tget_size_p($Init::H5T_NATIVE_INT);
        my $cid2 = HDFPerl::h5tcreate_compound_p($intsize);
        HDFPerl::h5tinsert_p($cid2, "index", 0, $Init::H5T_NATIVE_INT);
        $ids_buf[1] = HDFPerl::h5dread_int_p($collection[0], $cid2, $sid,
            $sid, $Init::H5P_DEFAULT);

        my $i;
        my $id;

        # prepare hash for sorting
        for ($i=0; $i<scalar @{$ids_buf[0]}; $i++) {
            $id = $ids_buf[0][$i];
            $ids_hash{$id} = $ids_buf[1][$i];
        }

        $i=0;

        # perform sorting in memory
        foreach $id (sort keys %ids_hash){
            $ids_buf[0][$i]=$id;
            $ids_buf[1][$i]=$ids_hash{$id};
            $i++; 
        }

        # write sorted buffer into dataset
        $status[0] = HDFPerl::h5dwrite_string_p($collection[0], $cid1, $sid,
            $sid, $Init::H5P_DEFAULT, $ids_buf[0]);

        $status[1] = HDFPerl::h5dwrite_int_p($collection[0], $cid2, $sid,
            $sid, $Init::H5P_DEFAULT, $ids_buf[1]);

        HDFPerl::h5tclose_p($cid1);
        HDFPerl::h5tclose_p($cid2);

        # set "sorted" attribute to 1 indicating that the "ids" dataset is
        # sorted
        $status[2] = HDFPerl::h5awrite_int8_p($collection[4],
            $Init::H5T_NATIVE_CHAR, \@unit_array);

        HDFPerl::h5sclose_p($sid);

        for ($i=0; $i < scalar @status; $i++) {
            if ($status[$i]<0) {
                return $status[$i];
            }
        }

        return 1;
}

# This function performs linear search of an identifier in the "ids" dataset.
# For efficiency, each I/O operation reads a number of records (op_size), which
# allows to perform linear search on the memory buffer.
#
# INPUT:	reference to collection ids
#		key to search
#               size of reading buffer
#
# RETURN:	index to "comments" dataset, or -1

sub lin_search_ids {
	my $collection_ref = shift;
        my $key = shift;
        my $op_size = shift;
        
        my $did = ${$collection_ref}[0]; 
        my $retval;

        # if "ids" dataset is empty, return -1  
        my $sorted = HDFPerl::h5aread_int8_p(${$collection_ref}[4],
            $Init::H5T_NATIVE_CHAR);
        if (${$sorted}[0] == 0) {
            $retval = -1;
            goto LINE;
        }

        my $sid = HDFPerl::h5dget_space_p($did);
        my $dsize = HDFPerl::h5sget_simple_extent_dims_p($sid);
        my $n = POSIX::floor(${$dsize}[0]/$op_size);
        my $i;
        my $j;
        my @h5offset=(0);
        my @h5length=($op_size);
        my @unit_array=(1);
        my $ids;
        my $index;
        my $retval;

        my $mid = HDFPerl::h5screate_simple_p(1, \@h5length, \@h5length);

        # create compound datatype for "id" field
        my $stid = HDFPerl::h5tcreate_string_p(ID_LENGTH);
        my $kid = HDFPerl::h5tcreate_compound_p(ID_LENGTH);
        HDFPerl::h5tinsert_p($kid, "id", 0, $stid);

        # create compound datatype for "index" field
        my $intsize = HDFPerl::h5tget_size_p($Init::H5T_NATIVE_INT);
        my $vid = HDFPerl::h5tcreate_compound_p($intsize);
        HDFPerl::h5tinsert_p($vid, "index", 0, $Init::H5T_NATIVE_INT);

        # main loop for linear search
        for ($i=0; $i<$n; $i++) {

            #read op_size records at offset for efficiency
            HDFPerl::h5sselect_hyperslab_p($sid, $Init::H5S_SELECT_SET,
                \@h5offset, \@unit_array, \@h5length, \@unit_array);
            $ids = HDFPerl::h5dread_string_p($did, $kid, $mid, $sid,
                $Init::H5P_DEFAULT);
            $index = HDFPerl::h5dread_int_p($did, $vid, $mid, $sid,
                $Init::H5P_DEFAULT);

            # perform linear search in memory buffer
            for ($j=0; $j<$op_size; $j++) {
                if (${$ids}[$j] eq $key){
                    # key found, read the record index
                    $retval = ${$index}[$j];
                    goto LINE;
                }
                
            }
            $h5offset[0]=$h5offset[0]+$op_size;
        }

        # search on the remainder
        $op_size = ${$dsize}[0] - $n*$op_size;

        if ($op_size == 0) {
            $retval = -1;
            goto LINE;
        }

        $h5length[0] = $op_size;
        HDFPerl::h5sclose_p($mid);
        $mid = HDFPerl::h5screate_simple_p(1, \@h5length, \@h5length);

        #read op_size records at offset for efficiency
        HDFPerl::h5sselect_hyperslab_p($sid, $Init::H5S_SELECT_SET,
                \@h5offset, \@unit_array, \@h5length, \@unit_array);
        $ids = HDFPerl::h5dread_string_p($did, $kid, $mid, $sid,
                $Init::H5P_DEFAULT);
        $index = HDFPerl::h5dread_int_p($did, $vid, $mid, $sid,
                $Init::H5P_DEFAULT);

        # perform linear search in memory buffer
        for ($j=0; $j<$op_size; $j++) {
            if (${$ids}[$j] eq $key){
                #key found, read the record index
                $retval = ${$index}[$j];
                goto LINE;
            }
        }

        # identifier was not found
        $retval = -1;
        
        LINE:

        HDFPerl::h5tclose_p($kid); 
        HDFPerl::h5tclose_p($vid); 
        HDFPerl::h5tclose_p($stid); 
        HDFPerl::h5sclose_p($sid); 
        HDFPerl::h5sclose_p($mid); 

        return $retval;            
}


# This function performs binary search for a given identifier in the "ids"
# dataset.
#
# INPUT:	reference to collection ids
#		key to search
#
# RETURN:	index to "comments" dataset, or -1


sub bin_search_ids {
	my $collection_ref = shift;
        my $key = shift;
        
        my $did = ${$collection_ref}[0];
        my $retval; 
        
        # if "ids" dataset is empty or not sorted, return -1  
        my $sorted = HDFPerl::h5aread_int8_p(${$collection_ref}[4],
            $Init::H5T_NATIVE_CHAR);
        if (${$sorted}[0] <= 0) {
            $retval = -1;
            goto LINE;
        }

        my $sid = HDFPerl::h5dget_space_p($did);
        my $dsize = HDFPerl::h5sget_simple_extent_dims_p($sid);
        my $low = 0; 
        my $high = ${$dsize}[0] - 1;
        my $mid;
        my $index;
        my @unit_array=(1);
        my @h5offset=();
        my $id;
        my $uid = HDFPerl::h5screate_simple_p(1, \@unit_array, \@unit_array);

        # create compound datatype to read "id" field
        my $stid = HDFPerl::h5tcreate_string_p(ID_LENGTH);
        my $kid = HDFPerl::h5tcreate_compound_p(ID_LENGTH);
        HDFPerl::h5tinsert_p($kid, "id", 0, $stid);

        # create compound datatype to read "index" field
        my $intsize = HDFPerl::h5tget_size_p($Init::H5T_NATIVE_INT);
        my $vid = HDFPerl::h5tcreate_compound_p($intsize);
        HDFPerl::h5tinsert_p($vid, "index", 0, $Init::H5T_NATIVE_INT);

        # main loop of binary search
        while ($low <= $high) {
            $mid = POSIX::floor(($low + $high) / 2);
            $h5offset[0]= $mid;
            HDFPerl::h5sselect_hyperslab_p($sid, $Init::H5S_SELECT_SET,
                \@h5offset, \@unit_array, \@unit_array, \@unit_array);
            $id = HDFPerl::h5dread_string_p($did, $kid, $uid, $sid,
                $Init::H5P_DEFAULT);
            if (${$id}[0] gt $key) {
                $high = $mid - 1;
            } else {
                if (${$id}[0] lt $key) {
                    $low = $mid + 1;
                } else {
                    # found key, read the record index
                    $index = HDFPerl::h5dread_int_p($did, $vid, $uid, $sid,
                        $Init::H5P_DEFAULT);
                    $retval = ${$index}[0];
                    goto LINE;
                }
            }
        }

        # key not found
        $retval = -1;
            
        LINE:
        HDFPerl::h5tclose_p($kid); 
        HDFPerl::h5tclose_p($vid); 
        HDFPerl::h5tclose_p($stid); 
        HDFPerl::h5sclose_p($sid); 
        HDFPerl::h5sclose_p($uid); 

        return $retval;            

}

# This function finds and returns data from a sequence associated with the
# given identifier.
# INPUT:	reference to array containing objects identifiers
#		sequence identifier
# RETURN:	reference to array containing sequence data. On error, it
#		returns a negative value
sub get_sequence {
        my $collection_ref = shift;
        my $id = shift;

        my @collection = @{$collection_ref};
        my @ids_buf=();
        my $index;
        my @seq=();
        my @h5offset=();
        my @unitarray=(1);
        my $intsize = HDFPerl::h5tget_size_p($Init::H5T_NATIVE_INT);

        # check "sorted" attr
        my $sorted = HDFPerl::h5aread_int8_p($collection[4],
            $Init::H5T_NATIVE_CHAR);

        # if collection is sorted, do a binary search
        if (${$sorted}[0]==1) {
            $index = BioHDF_Perl::bin_search_ids(\@collection, $id);
        } else {
            # otherwise, do a linear search
            if (${$sorted}[0]==-1) {
                $index = BioHDF_Perl::lin_search_ids(\@collection, $id, LIN_SEARCH_BUF_SIZE);
            # if collection is empty, return -1
            } else {
                return -1;

            }
        } 

        # if sequence identifier not found, return -1
        if ($index<0) {
            return -1;
        }

        # read data from "comments" dataset 
        $h5offset[0]=$index;
        my $did = $collection[1];
        my $sid = HDFPerl::h5dget_space_p($did);

        # create compound dataset to read "comment" field
        my $vlstid = HDFPerl::h5tcreate_string_p($Init::H5T_VARIABLE);
        my $vlsize = HDFPerl::h5tget_size_p($vlstid);
        my $ctid = HDFPerl::h5tcreate_compound_p($vlsize);
        HDFPerl::h5tinsert_p($ctid, "comment", 0, $vlstid);

        my $mid = HDFPerl::h5screate_simple_p(1, \@unitarray, \@unitarray);

        HDFPerl::h5sselect_hyperslab_p($sid, $Init::H5S_SELECT_SET, \@h5offset,
            \@unitarray, \@unitarray, \@unitarray);

        # read "comment" field
        my $ref = HDFPerl::h5dread_vlstring_p($did, $ctid, $mid, $sid,
            $Init::H5P_DEFAULT);

        $seq[0] = @{$ref}[0];
        HDFPerl::h5tclose_p($ctid);
        HDFPerl::h5tclose_p($vlstid);

        # read "offset" field
        my $ctid = HDFPerl::h5tcreate_compound_p($intsize);
        HDFPerl::h5tinsert_p($ctid, "offset", 0, $Init::H5T_NATIVE_INT);
        my $offset = HDFPerl::h5dread_int_p($did, $ctid, $mid, $sid,
            $Init::H5P_DEFAULT);
        HDFPerl::h5tclose_p($ctid);

        # read "length" field
        my $ctid = HDFPerl::h5tcreate_compound_p($intsize);
        HDFPerl::h5tinsert_p($ctid, "length", 0, $Init::H5T_NATIVE_INT);
        my $length = HDFPerl::h5dread_int_p($did, $ctid, $mid, $sid,
            $Init::H5P_DEFAULT);
        HDFPerl::h5tclose_p($ctid);
        
        HDFPerl::h5sclose_p($sid);
        HDFPerl::h5sclose_p($mid);


        # read data from "sequences" dataset
        my $did = $collection[2];
        my $sid = HDFPerl::h5dget_space_p($did);
        my $mid = HDFPerl::h5screate_simple_p(1, $length, $length);

        HDFPerl::h5sselect_hyperslab_p($sid, $Init::H5S_SELECT_SET, $offset,
            \@unitarray, $length, \@unitarray);
        $seq[1] = HDFPerl::h5dread_string_p($did, $Init::H5T_NATIVE_CHAR, $mid,
            $sid, $Init::H5P_DEFAULT);
       
        # read data from "quals" dataset 
        my $did = $collection[3];
        $seq[2] = HDFPerl::h5dread_int_p($did, $Init::H5T_NATIVE_INT, $mid,
            $sid, $Init::H5P_DEFAULT);
        
        HDFPerl::h5sclose_p($mid);
        HDFPerl::h5sclose_p($sid);
        
        return \@seq ;
}

# This function closes the HDF5 file
# INPUT:	file identifier
#
# RETURN:	status	

sub close_sequence_file {
        my $fid = shift;
        my $status = HDFPerl::h5fclose_p($fid);
        return $status;
}

# This function creates a sequence collection in the form of 4 datasets:
# ids, comments, sequences, quals
# It also creates an attribute on the "ids" dataset to store the sorting 
# status.
# INPUT:   file identifier
#          collection name
#          collection description
#
# RETURN:  reference to array containing objects identifiers, i.e.
#          (ids, comments, sequences, quals, sorted attr, container group).
#          On error, returns a negative value.

sub create_sequence_collection {
        my $fid = shift;
        my $name = shift;
        my $description = shift;
        my @collection = ();

        my $group_id = HDFPerl::h5gcreate_p($fid, $name, 0);

        # create the "sequences" and "quals" datasets. Both have the same
        # structure, and only differ in datatype.
        my @cur_dims = (0);
        my @chk_dims = (CHUNK_SIZE);
        my @max_dims=($Init::H5S_UNLIMITED);
        my $sid = HDFPerl::h5screate_simple_p(1, \@cur_dims, \@max_dims);
        my $pid = HDFPerl::h5pcreate_p($Init::H5P_DATASET_CREATE);
        HDFPerl::h5pset_chunk_p($pid, 1, \@chk_dims);
        HDFPerl::h5pset_deflate_p($pid, COMPRESSION_LEVEL);
        $collection[2] = HDFPerl::h5dcreate_p($group_id, "sequences",
            $Init::H5T_NATIVE_CHAR, $sid, $pid);
        $collection[3] = HDFPerl::h5dcreate_p($group_id, "quals",
            $Init::H5T_NATIVE_INT, $sid, $pid);

        # create compound datatype for "ids" dataset
        my $stid = HDFPerl::h5tcreate_string_p(ID_LENGTH);
        my $intsize = HDFPerl::h5tget_size_p($Init::H5T_NATIVE_INT);
        my $tid = HDFPerl::h5tcreate_compound_p(ID_LENGTH+$intsize);
        HDFPerl::h5tinsert_p($tid, "id", 0, $stid);
        HDFPerl::h5tinsert_p($tid, "index", ID_LENGTH, $Init::H5T_NATIVE_INT);

        # create chunked and compressed "ids" dataset along with "sorted"
        # attribute
        $collection[0] = HDFPerl::h5dcreate_p($group_id, "ids", $tid,
                $sid, $pid);
        HDFPerl::h5tclose_p($tid);

        HDFPerl::h5gset_comment_p($collection[0], ".", $description);

        my @unit_array = (1);
        my $a_space = HDFPerl::h5screate_simple_p(1, \@unit_array,
            \@unit_array);
        $collection[4] = HDFPerl::h5acreate_p($collection[0], "sorted",
            $Init::H5T_NATIVE_CHAR, $a_space, $Init::H5P_DEFAULT);
        #$collection[5] = $group_id;
        HDFPerl::h5sclose_p($a_space);

        # create compound datatype for "comments" dataset
        my $vlstid = HDFPerl::h5tcreate_string_p($Init::H5T_VARIABLE);
        my $vlsize = HDFPerl::h5tget_size_p($vlstid);
        my $tid = HDFPerl::h5tcreate_compound_p($vlsize+2*$intsize);
        HDFPerl::h5tinsert_p($tid, "comment", 0, $vlstid); 
        HDFPerl::h5tinsert_p($tid, "offset", $vlsize, $Init::H5T_NATIVE_INT); 
        HDFPerl::h5tinsert_p($tid, "length", $vlsize+$intsize,
            $Init::H5T_NATIVE_INT); 

        # create chunked and compressed "comments" dataset
        $collection[1] = HDFPerl::h5dcreate_p($group_id, "comments", $tid, $sid,
            $pid);
        HDFPerl::h5pclose_p($pid);
        HDFPerl::h5tclose_p($tid);
        HDFPerl::h5sclose_p($sid);
        HDFPerl::h5gclose_p($group_id);

        my $i;
        for ($i=0; $i<scalar @collection; $i++) {
            if ($collection[$i] < 0) {
                return $collection[$i];
            }
        } 
        
        return \@collection;
}

# This function closes datasets associated with a collection, along with
# sorting attribute and container group.
# INPUT:	reference to array containing identifiers
#
# RETURN:       status
#

sub close_sequence_collection {
        my $collection_ref = shift;
        my @collection = @{$collection_ref};

        my @status=(); 
        $status[0]=HDFPerl::h5dclose_p($collection[0]);
        $status[1]=HDFPerl::h5dclose_p($collection[1]);
        $status[2]=HDFPerl::h5dclose_p($collection[2]);
        $status[3]=HDFPerl::h5dclose_p($collection[3]);
        $status[4]=HDFPerl::h5aclose_p($collection[4]);
        #$status[5]=HDFPerl::h5gclose_p($collection[5]);
        my $i;
        for ($i=0; $i<scalar @status; $i++) {
            if ($status[$i] < 0) {
                return $status[$i];
            }
        }   
}

# This function opens a sequence collection.
# INPUT:	file identifier
#		collection name
#
# RETURN:	reference to array objects identifiers. On error, it returns
#		a negative value

sub open_sequence_collection {
        my $fid = shift;
        my $group_name = shift;
        my @collection = (); 

        # open the container group for the collection
        my $group_id = HDFPerl::h5gopen_p($fid, $group_name); 
        $collection[0] = HDFPerl::h5dopen_p($group_id, "ids"); 
        $collection[1] = HDFPerl::h5dopen_p($group_id, "comments"); 
        $collection[2] = HDFPerl::h5dopen_p($group_id, "sequences"); 
        $collection[3] = HDFPerl::h5dopen_p($group_id, "quals");
        $collection[4] = HDFPerl::h5aopen_name_p($collection[0], "sorted");
        #$collection[5] = $group_id;
        
        my $i;
        for ($i=0; $i<scalar @collection; $i++) {
            if ($collection[$i] < 0) {
                return $collection[$i];
            }
        } 
        return \@collection;
}

# This function adds a sequence to a collection.
# INPUT:	reference to array containing objects identifiers
#		reference to array containing sequence ids
#		sequence description
#		reference to array containing sequence data
#		reference to array containing quality data
#
# RETURN:	status

sub add_sequence {
        my $collection_ref = shift;
        my $id_ref = shift;
        my $comment = shift;
        my $seq_ref = shift;
        my $qual_ref = shift;

        my @collection = @{$collection_ref};
        my @id=@{$id_ref};
        my @seq=@{$seq_ref};
        my @qual=@{$qual_ref};
        my @h5length=();
        my @h5offset=();
        my @cur_dims=();
        my @status=();
        my @negative_array = (-1);

        if (scalar @id == 0) {
            print "No identifier specified\n";
            return -1;
        }


        if (scalar @seq != scalar @qual) {
            print "Lengths of sequence and quality are different\n";
            return -1;
        }

        # extend "sequences" and "quals" datasets to accomodate new data
        $h5length[0] = scalar @qual;
        my $sid = HDFPerl::h5dget_space_p($collection[3]);
        my $ref=HDFPerl::h5sget_simple_extent_dims_p($sid);
        @h5offset = @{$ref};
        my @unitarray = (1);
        $cur_dims[0] = $h5offset[0]+$h5length[0];
        HDFPerl::h5dextend_p($collection[2], \@cur_dims);
        HDFPerl::h5dextend_p($collection[3], \@cur_dims);
        HDFPerl::h5sclose_p($sid);
        $sid = HDFPerl::h5dget_space_p($collection[3]);

        # selects location and length on the dataset space for writing
        HDFPerl::h5sselect_hyperslab_p($sid, $Init::H5S_SELECT_SET, \@h5offset,
            \@unitarray, \@h5length, \@unitarray);

        my $mid = HDFPerl::h5screate_simple_p(1, \@h5length, \@h5length);

        # writes into the datasets
        $status[0] = HDFPerl::h5dwrite_string_p($collection[2],
            $Init::H5T_NATIVE_CHAR, $mid, $sid, $Init::H5P_DEFAULT, \@seq);

        $status[1] = HDFPerl::h5dwrite_int_p($collection[3],
            $Init::H5T_NATIVE_INT, $mid, $sid, $Init::H5P_DEFAULT, \@qual);

        HDFPerl::h5sclose_p($sid);
        HDFPerl::h5sclose_p($mid);

        # data for "comments" dataset
        my @comments_buf=();
        $comments_buf[0][0] = $comment;
        $comments_buf[1][0] = $h5offset[0];
        $comments_buf[2][0] = $h5length[0];

        my $vlstid = HDFPerl::h5tcreate_string_p($Init::H5T_VARIABLE);
        my $vlsize = HDFPerl::h5tget_size_p($vlstid);
        my $intsize = HDFPerl::h5tget_size_p($Init::H5T_NATIVE_INT);

        # extend the "comments" dataset to accomodate new data 
        $h5length[0] = (1);
        $sid = HDFPerl::h5dget_space_p($collection[1]);
        my $ref=HDFPerl::h5sget_simple_extent_dims_p($sid);
        my @h5offset = @{$ref};
        my @unitarray = (1);
        $cur_dims[0] = $h5offset[0]+$h5length[0];
        HDFPerl::h5dextend_p($collection[1], \@cur_dims);
        HDFPerl::h5sclose_p($sid);
        $sid = HDFPerl::h5dget_space_p($collection[1]);

        # selects location and length on the dataset space for writing
        HDFPerl::h5sselect_hyperslab_p($sid, $Init::H5S_SELECT_SET, \@h5offset,
            \@unitarray, \@h5length, \@unitarray);

        my $mid = HDFPerl::h5screate_simple_p(1, \@h5length, \@h5length);

        # write field "comment" data into "comments" dataset
        my $ctid = HDFPerl::h5tcreate_compound_p($vlsize);
        HDFPerl::h5tinsert_p($ctid, "comment", 0, $vlstid);
        $status[2] = HDFPerl::h5dwrite_vlstring_p($collection[1], $ctid, $mid,
            $sid, $Init::H5P_DEFAULT, $comments_buf[0]);
        HDFPerl::h5tclose_p($ctid);

        # write field "offset" data into "comments" dataset
        my $ctid = HDFPerl::h5tcreate_compound_p($intsize);
        HDFPerl::h5tinsert_p($ctid, "offset", 0, $Init::H5T_NATIVE_INT);
        $status[3] = HDFPerl::h5dwrite_int_p($collection[1], $ctid, $mid, $sid,
            $Init::H5P_DEFAULT, $comments_buf[1]);
        HDFPerl::h5tclose_p($ctid);

        # write field "length" data into "comments" dataset
        my $ctid = HDFPerl::h5tcreate_compound_p($intsize);
        HDFPerl::h5tinsert_p($ctid, "length", 0, $Init::H5T_NATIVE_INT);
        $status[4] = HDFPerl::h5dwrite_int_p($collection[1], $ctid, $mid, $sid,
            $Init::H5P_DEFAULT, $comments_buf[2]);
        HDFPerl::h5tclose_p($ctid);

        # close resources
        HDFPerl::h5sclose_p($mid);
        HDFPerl::h5sclose_p($sid);

        # data for "ids" dataset 
        my @ids_buf=();
        my $i;
        $h5length[0] = scalar @id;
        for ($i=0; $i<$h5length[0]; $i++) {
            $ids_buf[0][$i]=$id[$i];
            $ids_buf[1][$i]=$h5offset[0];
        }
        
        my $stid = HDFPerl::h5tcreate_string_p(ID_LENGTH);

        # extend "ids" dataset to accomodate new data
        $sid = HDFPerl::h5dget_space_p($collection[0]);
        my $ref=HDFPerl::h5sget_simple_extent_dims_p($sid);
        my @h5offset = @{$ref};
        my @unitarray = (1);
        $cur_dims[0] = $h5offset[0]+$h5length[0];
        HDFPerl::h5dextend_p($collection[0], \@cur_dims);
        HDFPerl::h5sclose_p($sid);
        $sid = HDFPerl::h5dget_space_p($collection[0]);

        # selects location and length on the dataset space for writing
        HDFPerl::h5sselect_hyperslab_p($sid, $Init::H5S_SELECT_SET, \@h5offset,
            \@unitarray, \@h5length, \@unitarray);

        my $mid = HDFPerl::h5screate_simple_p(1, \@h5length, \@h5length);

        # write field "id" data into "ids" dataset
        my $mtid = HDFPerl::h5tcreate_compound_p(ID_LENGTH);
        HDFPerl::h5tinsert_p($mtid, "id", 0, $stid);
        $status[5] = HDFPerl::h5dwrite_string_p($collection[0], $mtid, $mid,
            $sid, $Init::H5P_DEFAULT, $ids_buf[0]);
        HDFPerl::h5tclose_p($mtid);

        # write field "index" data into "ids" dataset
        $mtid = HDFPerl::h5tcreate_compound_p($intsize);
        HDFPerl::h5tinsert_p($mtid, "index", 0, $Init::H5T_NATIVE_INT);
        $status[6] = HDFPerl::h5dwrite_int_p($collection[0], $mtid, $mid, $sid,
            $Init::H5P_DEFAULT, $ids_buf[1]);
        HDFPerl::h5tclose_p($mtid);

        # write a negative value into the "sorted" attribute indicating that
        # the "ids" dataset is not sorted 
        $status[7] = HDFPerl::h5awrite_int8_p($collection[4],
            $Init::H5T_NATIVE_CHAR, \@negative_array);

        # close resources
        HDFPerl::h5sclose_p($mid);
        HDFPerl::h5sclose_p($sid);

        my $i;
        for ($i=0; $i < scalar @status; $i++) {
            if ($status[$i]<0) {
                return $status[$i];
            }
        }

        return 1;
}

return 1;
