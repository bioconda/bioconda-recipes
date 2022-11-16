#!/bin/bash
set -e

# ptGAUL represents plastid genome assembly using long reads data.
# We prefer using the long reads corrected by fmlrc (https://github.com/holtjma/fmlrc).
# This pipeline is used for plastome assembly using long reads data.
# It can help resolve the fragmented contigs results from getorganelles.
# It is more suitable for long reads data with large N50.
# Please contact Wenbin (Bean) Zhou. Email: wenbin.evolution@gmail.com

start=$(date +%s)

######## get prepared ########
#### using conda install the following modules ####
# 1. minimap2
# 2. seqkit
# 3. assembly-stats
# 4. seqtk
# 5. flye

function filter_fasta () {
	awk 'BEGIN{keep=0;}
	NR==FNR{remove[$1]=1}
	NR!=FNR{
	if(substr($1,1,1)==">"){if(substr($1,2) in remove){keep=1}else{keep=0}}
	if(keep==1){print}
	}' $1 $2
}

function filter_fastq () {
	awk 'BEGIN{keep=0;}
	NR==FNR{remove[$1]=1}
	NR!=FNR{
	if(FNR%4==1){if(substr($1,2) in remove){keep=1}else{keep=0}}
	if(keep==1){print}
	}' $1 $2
}


function filter_fastq_gz (){
	awk 'BEGIN{keep=0;}
	NR==FNR{remove[$1]=1}
	NR!=FNR{
	if(FNR%4==1){if(substr($1,2) in remove){keep=1}else{keep=0}}
	if(keep==1){print}
	}' $1 <(zcat $2)
}

function usage () {
  echo "Usage: this script is used for plastome assembly using long read data."
  echo "ptGAUL.sh [options]"
  echo "Options: "
  echo "-r <MANDATORY: contigs or scaffolds in fasta format>"
  echo "-l <MANDATORY: long reads in fasta/fastq/fq.gz format>"
  echo "-t <number of threads, default:1>" 
  echo "-f <filter the long reads less than this number; default: 3000>"
  echo ""
  echo ""
  echo ""
  echo "                     _____           _        _         _    _"
  echo "  ___      _       /  ___  \       / _ \     | |       | |  | |"
  echo " / _ \    | |     / /     \ \     / / \ \    | |       | |  | |"
  echo "/ / \ \ __| |__  | |       \_|    / / \ \    | |       | |  | |"
  echo "||   |||__   __| | |             / / _ \ \   | |       | |  | |"
  echo "| \_/ /   | |    | |      ___    /  ___  \   | |       | |  | |"
  echo "|  __/    | |_   | |     |__ |  / /     \ \  \ \       / /  | |        _"
  echo "| |       |   |   \ \ ___ / /   / /     \ \   \ \ ___ / /   | | _____ | |"
  echo "|_|       |__/     \ _____ /   /_/       \_\   \ _____ /    | _________ |"
  echo ""
  echo ""
  echo ""
}


NUM_THREADS=1
FRL=3000

if [ $# -lt 1 ]; then
	usage
fi

while [[ $# > 0 ]]
do
    key="$1"

    case $key in
        -t|--threads)
            NUM_THREADS="$2"
            shift
            ;;
        -l|--longreads)
            LR="$2"
            shift
            ;;
        -r|--reference)
            REF="$2"
            shift
            ;;
        -f|--filtered)
            FRL="$2"
            shift
            ;;
		-h|--help|-u|--usage)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1        # unknown option
            ;;
    esac
    shift
done


echo ""
echo ""
echo ""
echo "                     _____           _        _         _    _"
echo "  ___      _       /  ___  \       / _ \     | |       | |  | |"
echo " / _ \    | |     / /     \ \     / / \ \    | |       | |  | |"
echo "/ / \ \ __| |__  | |       \_|    / / \ \    | |       | |  | |"
echo "||   |||__   __| | |             / / _ \ \   | |       | |  | |"
echo "| \_/ /   | |    | |      ___    /  ___  \   | |       | |  | |"
echo "|  __/    | |_   | |     |__ |  / /     \ \  \ \       / /  | |        _"
echo "| |       |   |   \ \ ___ / /   / /     \ \   \ \ ___ / /   | | _____ | |"
echo "|_|       |__/     \ _____ /   /_/       \_\   \ _____ /    | _________ |"
echo ""
echo ""
echo ""


if [ ! -s $REF ];then
error_exit "reference $REF does not exist or size zero"
fi

if [ ! -s $LR ];then
error_exit "Long reads of ONT or PACBIO $LR does not exist or size zero"
fi

#echo $LR
#echo $NUM_THREADS
#echo $REF

#if [ -e result_$FRL ];then
#	rm -rf result_$FRL
#fi

mkdir -p result_$FRL

#module add minimap2
### Step1 minimap to generate a table including the matching reads heads.
if [ ! -s result_$FRL/filter_name ];then
	#minimap2 -cx map-ont $REF $LR | awk '{print $1}' > result_$FRL/filter_name 2>error.txt
	# more filters
	minimap2 -cx map-ont $REF $LR > result_$FRL/filter.paf 2>>error.txt
	awk '{print $1, $10, $11, $10/$11}' result_$FRL/filter.paf > result_$FRL/filter_1.paf
	awk '{if (($4>=0.7) && ($3 >=1000)) {print}}' result_$FRL/filter_1.paf > result_$FRL/filter_2.paf
	awk '{print $1}' result_$FRL/filter_2.paf > result_$FRL/filter_name

fi

echo ""
echo "####################################"
echo "########## Step1 results ###########"
echo "####################################"
echo "$LR is your sequence input."
echo "$REF is your reference file."
echo 'Step1 has been finished!! The filter_name includes all names of plastid long reads match to the reference.'

checkpoint1=$(date +%s)
echo "Step1 takes $(($checkpoint1 - $start)) sec."

#module add seqkit
### Step2 keep the matching reads. 
### $1 is bash script for the filter.
if [ ! -s result_$FRL/filter_reads ];then
	if [[ $LR = *.fasta || $LR = *.fa ]];then		
		filter_fasta result_$FRL/filter_name $LR > result_$FRL/filter_reads

	elif [[ $LR = *.fastq || $LR = *.fq ]];then
		filter_fastq result_$FRL/filter_name $LR > result_$FRL/filter_reads.fq
		seqkit fq2fa result_$FRL/filter_reads.fq > result_$FRL/filter_reads 2>>error.txt
		rm result_$FRL/filter_reads.fq
	elif [[ $LR = *.fq.gz || $LR = *.fastq.gz ]];then
		filter_fastq_gz result_$FRL/filter_name $LR > result_$FRL/filter_reads.fq
		seqkit fq2fa result_$FRL/filter_reads.fq > result_$FRL/filter_reads 2>>error.txt
		rm result_$FRL/filter_reads.fq
	fi
fi

echo ""
echo "####################################"
echo "########## Step2 results ###########"
echo "####################################"
echo "filter_reads is your filtered sequence reads with all plastid seuqneces matching to the reference."
echo ""
echo 'Step2 has been finished!!'
checkpoint2=$(date +%s)
echo "Step2 takes $(($checkpoint2 - $checkpoint1)) sec."

# module add seqkit
#if [ ! -s filter_reads_final ]; then
### Step3 filter reads > $FRL bp, and keep a fraction of reads
### make sure loaded seqkit, seqtk, and assembly-stats module.


if [ ! -s result_$FRL/new_filter_gt$FRL.fa ];then
	seqkit seq -g -m $FRL result_$FRL/filter_reads \
	> result_$FRL/new_filter_gt$FRL.fa 2>>error.txt

	echo ""
	echo "####################################"
	echo "########## Step3 results ###########"
	echo "####################################"
	echo "new_filter_gt$FRL.fa is done. It keeps all plastid long reads greater than $FRL bp."
	echo 'Step3 has been finished!!'

fi
checkpoint3=$(date +%s)
echo "Step3 takes $(($checkpoint3 - $checkpoint2)) sec."

#module add seqtk
#module add flye
#module add anaconda/2021.11
#source activate grasstool
if [ ! -s result_$FRL/total_length ];then
	assembly-stats result_$FRL/new_filter_gt$FRL.fa 2>>error.txt \
	| awk 'FNR == 2 {print $3}' \
	| sed 's/,//' > result_$FRL/total_length

	num=$(awk '$1/160000>15 && $1/160000<50{print $1/160000}' result_$FRL/total_length)
	echo ""
	echo "####################################"
	echo "########## Step4 results ###########"
	echo "####################################"
	echo $num
	if [[ $num = "" ]];then
		echo 'Step4 has been finished!! The coverage of plastome is greater than 50x coverage.'
		echo "It needs to reduce reads to 50x coverage"
		frac=$(awk '{print 160000*50/$1}' result_$FRL/total_length)
		echo "The fraction number is" $frac
		

		if [ $frac != 0 ];then
			seqtk sample -s100 result_$FRL/new_filter_gt$FRL.fa $frac \
			> result_$FRL/filter_reads_final.fa 
			echo ""
			echo "####################################"
			echo "########## Step5 results ###########"
			echo "####################################"
			echo "filter_reads_final.fa"
			echo 'Step5 has been finished!! The filter_reads_final.fa includes about 50x coverage of long reads.'
			echo "It is ready for flye assembly."
			flye --nano-raw result_$FRL/filter_reads_final.fa --genome-size 0.16m \
			--out-dir ./result_$FRL/flye_cpONT --threads $NUM_THREADS 2>>error.txt
			
		fi
	else
		echo 'Step4 has been finished!! The coverage of plastome is between 15-50x coverage.'
		echo "It is ready for flye assembly"

		flye --nano-raw result_$FRL/new_filter_gt$FRL.fa --genome-size 0.16m \
		--out-dir ./result_$FRL/flye_cpONT --threads $NUM_THREADS 2>>error.txt

	fi
fi

checkpoint6=$(date +%s)
echo "Step4, 5, and 6 take $(($checkpoint6 - $checkpoint3)) sec."

if [ -s ./result_$FRL/flye_cpONT/assembly.fasta ];then
	echo ""
	echo "####################################"
	echo "########## Step6 results ###########"
	echo "####################################"
    echo "Assembly is done. All results are in ./flye_cpONT/"
	echo "Please use the Bandage to visualize the assembly result."
	echo 'If the edges are three, it is a well-assembled result! Congratulations!!'
	echo "Otherwise, you need to manually check the graph results."
	echo "You can use blast the aseembly sequence itself to check the IR region, and use either long reads and short reads to check the evenness of the coverages."
fi


if [ ! -s ./result_$FRL/edges.fa ];then
	awk '/^S/{print ">"$2"\n"$3}' ./result_$FRL/flye_cpONT/assembly_graph.gfa \
	| fold > ./result_$FRL/edges.fa
	awk -F ":" '/^S/{print substr($1,3,7)"\t"$3}' ./result_$FRL/flye_cpONT/assembly_graph.gfa \
	| sort -k 2 -n -r > ./result_$FRL/sorted_depth
fi	

number_edge=$(grep ">" ./result_$FRL/edges.fa | wc -l)

echo ""
echo "####################################"
echo "########## Step7 results ###########"
echo "####################################"
if [[ $number_edge -eq 3 ]]; then
	echo ""
	echo '==============================================='
	echo '-------------- Congratulations ----------------'
	echo '==============================================='
	echo "The gfa file has 3 edges. It is ready for the combine_gfa.py script. See the output of Path1.fasta and Path2.fasta."
	combine_gfa.py -e ./result_$FRL/edges.fa -d ./result_$FRL/sorted_depth 2>>error.txt
	end=$(date +%s)
	echo "It takes $(($end - $start)) sec in total."

elif [[ $number_edge -eq 1 ]]; then
	echo ""
	echo '==============================================='
	echo '---------------- Attentions -------------------'
	echo '==============================================='
	echo "The gfa file only has 1 edges. Please manually check the gfa file in Bandage."
	echo "Confirm the assembly result is a circle with a reasonable result (~160k bp)."
	echo "Congratulations!!!"
	ln ./result_$FRL/flye_cpONT/assembly.fasta ./final_assembly.fasta
	echo "./final_assembly.fasta is your final result. You can check the details in the flye output."

else
	echo "edge number is $number_edge" '!'
	echo ""
	echo '==============================================='
	echo '-------- Oops! Detect a weird result ----------'
	echo '==============================================='
	echo "The gfa file has more than/less than three edges. Please manually check the gfa file in Bandage."
	echo "After confirming the assembly result, keep three edges in the edges.fa and three lines in sorted_depth files."
	echo "then run python script as follows manually. You can run:"
	echo "combine_gfa.py -e ./PATH_OF_EDGES_FILE/edges.fa -d ./PATH_OF_SORTED_DEPTH_FILE/sorted_depth"

fi


end=$(date +%s)
echo '==============================================='
echo '------------- total running time --------------'
echo '==============================================='
echo "It takes $(($end - $start)) sec in total."
