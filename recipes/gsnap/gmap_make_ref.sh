genome=$1
input_fasta=$2
gtf_file=$3
gmapdb_loc=null
gmapdb=$CONDA_PREFIX/$gmapdb_loc
gtf_prefix=$(echo $(basename $gtf_file) | sed "s/\.gtf//")
gmap_build -d $genome $input_fasta
cat $gtf_file | gtf_splicesites > $gmapdb/$genome/$gtf_prefix.splicesites
cat $gtf_file | gtf_introns > $gmapdb/$genome/$gtf_prefix.introns
cat $gmapdb/$genome/$gtf_prefix.splicesites | iit_store -o $gmapdb/$genome/$gtf_prefix.splicesites
cat $gmapdb/$genome/$gtf_prefix.introns | iit_store -o $gmapdb/$genome/$gtf_prefix.introns
mv -v $gmapdb/$genome/$gtf_prefix.splicesites.iit $gmapdb/$genome/$genome.maps/
mv -v $gmapdb/$genome/$gtf_prefix.introns.iit $gmapdb/$genome/$genome.maps
cp -v $input_fasta  $gmapdb/$genome/
cp -v $gtf_file  $gmapdb/$genome/
