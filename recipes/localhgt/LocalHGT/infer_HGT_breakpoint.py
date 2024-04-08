#!/usr/bin/env python3

import os
import sys
import argparse
import subprocess
from shutil import which

class Accept_Parameters:

    def __init__(self, options, fastq_1, fastq_2):

        self.reference = options.r
        self.fq1 = options.fq1
        self.fq2 = options.fq2
        self.fastq_1 = fastq_1
        self.fastq_2 = fastq_2
        self.sample_ID = options.s
        self.outdir = options.o
        self.shell_script = os.path.dirname(sys.argv[0]) + "/pipeline.sh"
        self.hit_ratio = options.hit_ratio
        self.match_ratio = options.match_ratio
        self.run_order = ''
        self.k = options.k
        self.threads = options.t
        self.options = options

    def get_order(self):
        self.run_order = f"bash {self.shell_script} {self.reference} {self.fastq_1} {self.fastq_2} {self.sample_ID} {self.outdir} {self.hit_ratio} {self.match_ratio} {self.threads} {self.k} {self.options.max_peak} {self.options.e} {self.options.seed} {self.options.sample} {self.options.read_info} {self.options.a} {self.options.q}\n"
        print ("Running command:")
        print (self.run_order)

    def run(self):
        os.system(self.run_order)

def direct_alignment(options, fastq_1, fastq_2):
    command = """
        ref=%s
        fq1=%s
        fq2=%s
        ID=%s
        outdir=%s
        thread=%s
        dir=%s
        info=%s
        sample=$outdir/$ID

        if [ ! -d $outdir ]; then
        mkdir $outdir
        fi

        if [ ! -f $ref.pac ];then
        bwa index $ref
        fi

        if [ ! -f $ref.fai ];then
        samtools faidx $ref
        fi


        sort_t=`expr $thread - 1`
        bwa mem -M -t $thread -R "@RG\\tID:id\\tSM:sample\\tLB:lib" $ref $fq1 $fq2 | samtools view -q %s -bhS -@ $sort_t -> $sample.unsort.bam
        echo "samtools sort  -@ $sort_t -o $sample.unique.bam $sample.unsort.bam"
        samtools sort -@ $sort_t -o $sample.unique.bam $sample.unsort.bam
        rm $sample.unsort.bam

        samtools view -h $sample.unique.bam \
        | python3 $dir/extractSplitReads_BwaMem.py -i stdin \
        | samtools view -Sb > $sample.unsort.splitters.bam

        samtools sort -@ $sort_t -o $sample.splitters.bam $sample.unsort.splitters.bam
        rm $sample.unsort.splitters.bam

        samtools index $sample.splitters.bam
        samtools index $sample.unique.bam

        python $dir/get_raw_bkp.py -t $thread -u $sample.unique.bam -o $sample.raw.csv -n 0 -a %s
        python $dir/accurate_bkp.py -g $ref -u $sample.unique.bam -b None -s $sample.splitters.bam -a $sample.raw.csv -o $sample.repeat.acc.csv -n 0 --read_info $info

        python $dir/remove_repeat.py $sample.repeat.acc.csv $sample.acc.csv
        rm $sample.repeat.acc.csv

        if [ ! -f "$sample.acc.csv" ]; then
            echo "Error: Final HGT breakpoint file is not generated."
        else
            echo "Final HGT breakpoint file is generated."
            wc -l $sample.acc.csv
        fi

        
        # rm $sample.splitters.bam

        echo "Final result is in $sample.acc.csv"
        echo "--------------------------"
        echo "Finished!"
    """%(options.r, fastq_1, fastq_2, options.s, options.o, options.t, sys.path[0], options.read_info, options.q, options.a)
    os.system(command)

def refine_fastq(options):
    fastq_1 = options.o + "/" + options.s + "_refined_1.fq"
    fastq_2 = options.o + "/" + options.s + "_refined_2.fq"
    if options.refine_fq == 1:
        print ("refine input fastq files...")
        os.system(f'fastp -i {options.fq1} -I {options.fq2} -o {fastq_1} -O {fastq_2}')
    else:
        fastq_1 = options.fq1
        fastq_2 = options.fq2
    
    return fastq_1, fastq_2

def is_tool(name):
    """Check whether `name` is on PATH and marked as executable."""
    return which(name) is not None

def check_input(options):
    if options.r[-3:] == ".gz":
        print ("Error: reference file should be uncompressed.")
        sys.exit(1)

    if not is_tool("samtools"):
        print ("Error: samtools is not installed.")
        sys.exit(1)

    if not is_tool("bwa"):
        print ("Error: bwa is not installed.")
        sys.exit(1)

    if options.refine_fq == 1:
        if not is_tool("fastp"):
            print ("Error: fastp is not installed.")
            sys.exit(1)

    if not os.path.isfile(options.r + ".fai"):
        print ("construct samtools index for the refernece...")
        os.system(f"samtools faidx {options.r}")

    if options.fq1[-3:] == ".gz" or options.fq2[-3:] == ".gz":
        if options.refine_fq == 0:
            print ("Error: input fastq file should be uncompressed.")
            sys.exit(1)

def detect_breakpoint(options):
    
    check_input(options)
    fastq_1, fastq_2 = refine_fastq(options)
    if options.use_kmer == 1: # default
        acc_pa = Accept_Parameters(options, fastq_1, fastq_2)
        acc_pa.get_order()
        acc_pa.run()
    elif options.use_kmer == 0:
        direct_alignment(options, fastq_1, fastq_2)
    else:
        print ("## wrong value for the parameter --use_kmer. ")


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Detect HGT breakpoints from metagenomics sequencing data.", add_help=False, \
    usage="python %(prog)s -h", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    required = parser.add_argument_group("required arguments")
    optional = parser.add_argument_group("optional arguments")
    required.add_argument("-r", type=str, help="<str> Uncompressed reference file, which contains all the representative references of concerned bacteria.", metavar="\b")
    required.add_argument("--fq1", type=str, help="<str> Uncompressed fastq 1 file.", metavar="\b")
    required.add_argument("--fq2", type=str, help="<str> Uncompressed fastq 2 file.", metavar="\b")
    required.add_argument("-s", type=str, default="sample", help="<str> Sample name.", metavar="\b")
    required.add_argument("-o", type=str, default="./", help="<str> Output folder.", metavar="\b")

    optional.add_argument("-k", type=int, default=32, help="<int> kmer length.", metavar="\b")
    optional.add_argument("-t", type=int, default=10, help="<int> number of threads.", metavar="\b")
    optional.add_argument("-e", type=int, default=3, help="<int> number of hash functions (1-9).", metavar="\b")
    optional.add_argument("-a", type=int, default=1, help="<0/1> 1 indicates retain reads with XA tag.", metavar="\b")
    optional.add_argument("-q", type=int, default=20, help="<int> minimum read mapping quality in BAM.", metavar="\b")
    optional.add_argument("--seed", type=int, default=1, help="<int> seed to initialize a pseudorandom number generator.", metavar="\b")
    optional.add_argument("--use_kmer", type=int, default=1, help="<1/0> 1 means using kmer to extract HGT-related segment, 0 means using original reference.", metavar="\b")
    optional.add_argument("--hit_ratio", type=float, default=0.1, help="<float> minimum fuzzy kmer match ratio to extract a reference fragment.", metavar="\b")
    optional.add_argument("--match_ratio", type=float, default=0.08, help="<float> minimum exact kmer match ratio to extract a reference fragment.", metavar="\b")
    optional.add_argument("--max_peak", type=int, default=300000000, help="<int> maximum candidate BKP count.", metavar="\b")
    optional.add_argument("--sample", type=float, default=2000000000, help="<float> down-sample in kmer counting: (0-1) means sampling proportion, (>1) means sampling base count (bp).", metavar="\b")
    optional.add_argument("--refine_fq", type=int, default=0, help="<0/1> 1 indicates refine the input fastq file using fastp (recommended).", metavar="\b")
    optional.add_argument("--read_info", type=int, default=1, help="<0/1> 1 indicates including reads info, 0 indicates not (just for evaluation).", metavar="\b")
    optional.add_argument("-h", "--help", action="help")

    options = parser.parse_args()

    if len(sys.argv) == 1:
        # print (f"see python {sys.argv[0]} -h")
        os.system(f"python {sys.argv[0]} -h")
    else:
        detect_breakpoint(options)
        # check_input(options)
        # fastq_1, fastq_2 = refine_fastq(options)
        # if options.use_kmer == 1: # default
        #     acc_pa = Accept_Parameters(options)
        #     acc_pa.get_order()
        #     acc_pa.run()
        # elif options.use_kmer == 0:
        #     direct_alignment(options)
        # else:
        #     print ("## wrong value for the parameter --use_kmer. ")
