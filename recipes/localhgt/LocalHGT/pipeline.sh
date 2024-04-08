#!/bin/bash

### pipeline to identify precise HGT breakpoints

original_ref=$1
fq1=$2
fq2=$3
ID=$4
outdir=$5
accept_hit_ratio=$6
accept_perfect_hit_ratio=$7
thread=$8
k=$9
max_peak=${10}
coder_num=${11}
seed=${12}
base_num=${13}
read_info=${14}
xa_tag=${15}
read_q=${16}

interval_file=$outdir/$ID.interval.txt
sample=$outdir/$ID
extracted_ref=$outdir/$ID.specific.ref.fasta
start=$(date +%s)
dir=$(cd `dirname $0`; pwd)


if [ ! -d $outdir ]; then
  mkdir $outdir
fi

# :<<!
#### Extract HGT-related segments using fuzzy kmer matching
$dir/extract_ref $fq1 $fq2 $original_ref $interval_file $accept_hit_ratio $accept_perfect_hit_ratio $thread $k $max_peak $coder_num $seed $base_num
python $dir/get_bed_file.py $original_ref $interval_file > ${sample}.log
samtools faidx -r ${interval_file}.bed $original_ref > $extracted_ref

bwa index $extracted_ref
samtools faidx $extracted_ref
end=$(date +%s)
take=$(( end - start ))
echo Time taken to prepare ref is ${take} seconds. >> ${sample}.log


#### Map all reads onto the HGT-related segments
sort_t=`expr $thread - 1`
bwa mem -M -t $thread -R "@RG\tID:id\tSM:sample\tLB:lib" $extracted_ref $fq1 $fq2 | samtools view -q $read_q -bhS -@ $sort_t -> $sample.unsort.bam

echo "samtools sort -@ $sort_t -o $sample.unique.bam $sample.unsort.bam"
samtools sort -@ $sort_t -o $sample.unique.bam $sample.unsort.bam


#### extract split reads
samtools view -h $sample.unique.bam \
| python3 $dir/extractSplitReads_BwaMem.py -i stdin \
| samtools view -Sb > $sample.unsort.splitters.bam
samtools sort -@ $sort_t -o $sample.splitters.bam $sample.unsort.splitters.bam
samtools index $sample.splitters.bam
samtools index $sample.unique.bam

end=$(date +%s)
take=$(( end - start ))
echo Time taken to map reads is ${take} seconds. >> ${sample}.log

#### Identify precise HGT breakpoints
python $dir/get_raw_bkp.py -t $thread -u $sample.unique.bam -o $sample.raw.csv -a $xa_tag 
# !
python $dir/accurate_bkp.py -g $original_ref -u $sample.unique.bam -b ${interval_file}.bed \
-s $sample.splitters.bam -a $sample.raw.csv -o $sample.repeat.acc.csv --read_info $read_info

python $dir/remove_repeat.py $sample.repeat.acc.csv $sample.acc.csv
rm $sample.repeat.acc.csv

if [ ! -f "$sample.acc.csv" ]; then
    echo "Error: Final HGT breakpoint file is not generated."
else
    echo "Final HGT breakpoint file is generated."
    wc -l $sample.acc.csv
fi

rm $extracted_ref*
rm $sample.unsort.splitters.bam
rm $sample.unsort.bam
# rm $sample.splitters.bam

end=$(date +%s)
take=$(( end - start ))
echo Time taken to execute commands is ${take} seconds. >> ${sample}.log
echo "Final result is in $sample.acc.csv"
echo "log info is in $sample.log"
echo "--------------------------"
echo "Finished!"

