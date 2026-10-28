#!/bin/bash
# GRIDSS execution script using SvPrep BAMs

getopt --test
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
	echo 'WARNING: "getopt --test"` failed in this environment.' 1>&2
	echo "WARNING: The version of getopt(1) installed on this system might not be compatible with the GRIDSS driver script." 1>&2
fi
unset DISPLAY # Prevents errors attempting to connecting to an X server when starting the R plotting device
ulimit -n $(ulimit -Hn 2>/dev/null) 2>/dev/null # Reduce likelihood of running out of open file handles
set -o errexit -o pipefail -o noclobber -o nounset
last_command=""
current_command=""
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command completed with exit code $?."' EXIT
#253 forcing C locale for everything
export LC_ALL=C

EX_USAGE=64
EX_NOINPUT=66
EX_CANTCREAT=73
EX_CONFIG=78

workingdir="."
reference=""
output_vcf=""
assembly=""
threads=8
jvmheap="30g"
otherjvmheap="4g"
blacklist=""
metricsrecords=10000000
maxcoverage=50000
config_file=""
labels=""
bams=""
filtered_bams=""
full_bams=""
keepTempFiles="false"

steps="all"
do_preprocess=false
do_assemble=false
do_call=false

USAGE_MESSAGE="
Usage: gridss [options] -r <reference.fa> -o <output.vcf.gz> -a <assembly.bam> input1.bam [input2.bam [...]]

    -r/--reference: reference genome to use.
    -o/--output: output VCF.
    -a/--assembly: location of the GRIDSS assembly BAM. This file will be
        created by GRIDSS.
    -t/--threads: number of threads to use. (Default: $threads)
    -j/--jar: location of GRIDSS jar
    -w/--workingdir: directory to place GRIDSS intermediate and temporary files
        .gridss.working subdirectories will be created. (Default: $workingdir)
    -s/--steps: processing steps to run. Defaults to all steps.
        Multiple steps are specified using comma separators. Possible steps are:
        preprocess, assemble, call, all
    -e/--blacklist: BED file containing regions to ignore
    -c/--configuration: configuration file use to override default GRIDSS
        settings.
    -l/--labels: comma separated labels to use in the output VCF for the input
        files. Supporting read counts for input files with the same label are
        aggregated (useful for multiple sequencing runs of the same sample).
        Labels default to input filenames, unless a single read group with a
        non-empty sample name exists in which case the read group sample name
        is used (which can be disabled by \"useReadGroupSampleNameCategoryLabel=false\"
        in the configuration file). If labels are specified, they must be
        specified for all input files.
    -b/bams: comma separated full-path BAM files
    -f/filtered_bams: comma separated full-path filtered BAM files
    --jvmheap: size of JVM heap for the high-memory component of assembly and variant calling. (Default: $jvmheap)
    --otherjvmheap: size of JVM heap for everything else. Useful to prevent
        java out of memory errors when using large (>4Gb) reference genomes.
        Note that some parts of assembly and variant calling use this heap
        size. (Default: $otherjvmheap)
    "

OPTIONS=r:o:a:t:j:w:e:s:c:l:b:f:
LONGOPTS=reference:,output:,assembly:,threads:,jar:,workingdir:,jvmheap:,otherjvmheap:,blacklist:,steps:,configuration:,labels:,bams:,filtered_bams:
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	# e.g. return value is 1
	#  then getopt has complained about wrong arguments to stdout
	echo "$USAGE_MESSAGE" 1>&2
	exit $EX_USAGE
fi
eval set -- "$PARSED"

POSITIONAL_ARGS=()

#while true; do
while [[ $# -gt 0 ]]; do
	case "$1" in
		-r|--reference)
			reference="$2"
			shift 2
			;;
		-l|--labels)
			labels="$2"
			shift 2
			;;
		-b|--bams)
			bams="$2"
			shift 2
			;;
		-f|--filtered_bams)
			filtered_bams="$2"
			shift 2
			;;
		-s|--steps)
			steps="$2"
			shift 2
			;;
		-w|--workingdir)
			workingdir="$2"
			shift 2
			;;
		-o|--output)
			output_vcf="$2"
			shift 2
			;;
		-a|--assembly)
			if [[ "$assembly" == "" ]] ; then
				assembly="$2"
			else
				assembly="$assembly $2"
			fi
			# TODO: support multiple assembly files
			shift 2
			;;
		-e|--blacklist)
			blacklist="$2"
			shift 2
			;;
		-j|--jar)
			GRIDSS_JAR="$2"
			shift 2
			;;
		--jvmheap)
			jvmheap="$2"
			shift 2
			;;
		--otherjvmheap)
			otherjvmheap="$2"
			shift 2
			;;
		-t|--threads)
			printf -v threads '%d\n' "$2" 2>/dev/null
			printf -v threads '%d' "$2" 2>/dev/null
			shift 2
			;;
		-c|--configuration)
			config_file=$2
			shift 2
			;;
		*)
            POSITIONAL_ARGS+=("$1") # save positional arg
			# echo "Unparsed param"
			shift
			;;
	esac
done

##### --workingdir
echo "Using working directory \"$workingdir\"" 1>&2
if [[ "$workingdir" == "" ]] ; then
	echo "$USAGE_MESSAGE"  1>&2
	echo "Working directory must be specified. Specify using the --workingdir command line argument" 1>&2
	exit $EX_USAGE
fi
if [[ "$(tr -d ' 	\n' <<< "$workingdir")" != "$workingdir" ]] ; then
		echo "workingdir cannot contain whitespace" 1>&2
		exit $EX_USAGE
	fi
if [[ ! -d $workingdir ]] ; then
	mkdir -p $workingdir
	if [[ ! -d $workingdir ]] ; then
		echo Unable to create working directory $workingdir 1>&2
		exit $EX_CANTCREAT
	fi
fi
workingdir=$(dirname $workingdir/placeholder)
timestamp=$(date +%Y%m%d_%H%M%S)
# Logging
logfile=$workingdir/gridss.full.$timestamp.$HOSTNAME.$$.log
# $1 is message to write
write_status() {
	echo "$(date): $1" | tee -a $logfile 1>&2
}
write_status "Full log file is: $logfile"
trap 'echo "\"${last_command}\" command completed with exit code $?.
*****
The underlying error message can be found in $logfile
*****"' EXIT
# Timing instrumentation
timinglogfile=$workingdir/gridss.timing.$timestamp.$HOSTNAME.$$.log
if which /usr/bin/time >/dev/null ; then
	timecmd="/usr/bin/time"
	write_status "Found /usr/bin/time"
else
	timecmd=""
	write_status "Not found /usr/bin/time"
fi
if [[ "$timecmd" != "" ]] ; then
	timecmd="/usr/bin/time --verbose -a -o $timinglogfile"
	if ! $timecmd echo 2>&1 > /dev/null; then
		timecmd="/usr/bin/time -a -o $timinglogfile"
	fi
	if ! $timecmd echo 2>&1 > /dev/null ; then
		timecmd=""
		write_status "Unexpected /usr/bin/time version. Not logging timing information."
	fi
	# We don't need timing info of the echo
	rm -f $timinglogfile
fi

### Find the jars
find_jar() {
	env_name=$1
	if [[ -f "${!env_name:-}" ]] ; then
		echo "${!env_name}"
	else
		write_status "Unable to find $2 jar. Specify using the environment variant $env_name, or the --jar command line parameter."
		exit $EX_NOINPUT
	fi
}
gridss_jar=$(find_jar GRIDSS_JAR gridss)
write_status "Using GRIDSS jar $gridss_jar"

# Check all key inputs:

if [[ "$labels" == "" ]] ; then
	write_status "Labels must be specified"
	exit $EX_USAGE
fi

if [[ "$bams" == "" ]] ; then
	write_status "Full BAMs must be specified"
	exit $EX_USAGE
fi

if [[ "$filtered_bams" == "" ]] ; then
	write_status "Filtered BAMs must be specified"
	exit $EX_USAGE
fi

##### --reference
if [[ "$reference" == "" ]] ; then
	write_status "$USAGE_MESSAGE"
	write_status "Reference genome must be specified. Specify using the --reference command line argument"
	exit $EX_USAGE
fi

if [ ! -f $reference ] ; then
	write_status "$USAGE_MESSAGE"
	write_status "Missing reference genome $reference. Specify reference location using the --reference command line argument"
	exit $EX_USAGE
fi
write_status "Using reference genome \"$reference\""

##### --output
if [[ $do_call == "true" ]] ; then
	if [[ "$output_vcf" == "" ]] ; then
		write_status "$USAGE_MESSAGE"
		write_status "Output VCF not specified. Use --output to specify output file."
		exit $EX_USAGE
	fi
	mkdir -p $(dirname $output_vcf)
	if [[ ! -d $(dirname $output_vcf) ]] ; then
		write_status "Unable to create directory for $output_vcf for output VCF."
		exit $EX_CANTCREAT
	fi
	write_status "Using output VCF $output_vcf"
fi

##### --assembly
if [[ $do_assemble == "true" ]] || [[ $do_call == "true" ]]; then
	if [[ "$assembly" == "" ]] ; then
		if [[ "$output_vcf" == "" ]] ; then
			write_status "Either the assembly output file must explicitly specified with -a, or the output VCF specified with -o"
			exit $EX_USAGE
		fi
		assembly=$output_vcf.assembly.bam
	fi
	write_status "Using assembly bam $assembly"
	if [[ $do_assemble == "true" ]] ; then
		mkdir -p $(dirname $assembly)
		if [[ ! -d $(dirname $assembly) ]] ; then
			write_status "Unable to parent create directory for $assembly"
			exit $EX_CANTCREAT
		fi
	else
		if [[ ! -f $assembly ]] ; then
			write_status "Missing assembly file $assembly"
			write_status "Ensure the GRIDSS assembly step has been run"
			exit $EX_NOINPUT
		fi
	fi
fi

##### --threads
if [[ "$threads" -lt 1 ]] ; then
	write_status "$USAGE_MESSAGE"
	write_status "Illegal thread count: $threads. Specify an integer thread count using the --threads command line argument"
	exit $EX_USAGE
fi
if [[ "$threads" -gt 8 ]] ; then
	write_status "WARNING: GRIDSS scales sub-linearly at high thread count. Up to 8 threads is the recommended level of parallelism."
fi
write_status  "Using $threads worker threads."

if [[ "$blacklist" == "" ]] ; then
	blacklist_arg=""
	write_status  "Using no blacklist bed. The encode DAC blacklist is recommended for hg19."
elif [[ ! -f $blacklist ]] ; then
	write_status  "$USAGE_MESSAGE"
	write_status  "Missing blacklist file $blacklist"
	exit $EX_NOINPUT
else
	blacklist_arg="BLACKLIST=$blacklist"
	write_status  "Using blacklist $blacklist"
	if [[ "$(tr -d ' 	\n' <<< "$blacklist_arg")" != "$blacklist_arg" ]] ; then
		write_status  "blacklist cannot contain whitespace"
		exit $EX_USAGE
	fi
fi

if [[ "$jvmheap" == "" ]] ; then
	if [[ $threads -gt 8 ]] ; then
		write_status "Warning: GRIDSS assembly may stall and run out of memory. with $threads and $jvmheap heap size."
	fi
fi

write_status  "Using JVM maximum heap size of $jvmheap for assembly and variant calling."

config_args=""
if [[ "$config_file" != "" ]] ; then
	if [[ ! -f $config_file ]] ; then
		write_status "Configuration file $config_file does not exist"
		exit $EX_NOINPUT
	fi
	config_args="CONFIGURATION_FILE=$config_file"
fi

input_args=""
input_filtered_args=""

# no longer read in the BAM file list from the end of the arguments list

nows_labels=$(tr -d ' 	\n' <<< "$labels")
if [[ "$nows_labels" != "$labels" ]] ; then
	write_status "input labels cannot contain whitespace"
	exit $EX_USAGE
fi
IFS=',' read -ra LABEL_ARRAY  <<< "$nows_labels"
label_count=${#LABEL_ARRAY[@]}

for label in "${LABEL_ARRAY[@]}" ; do
	input_args="$input_args INPUT_LABEL=$label"
	input_filtered_args="$input_filtered_args INPUT_LABEL=$label"
	#write_status "label is $label"
done

nows_bams=$(tr -d ' 	\n' <<< "$bams")
if [[ "$nows_bams" != "$bams" ]] ; then
	write_status "input filtered BAMs cannot contain whitespace"
	exit $EX_USAGE
fi
IFS=',' read -ra BAM_ARRAY  <<< "$nows_bams"
for bam_file in "${BAM_ARRAY[@]}" ; do

	if [[ "$(basename $bam_file)" == "$(basename $assembly)" ]] ; then
		write_status "assembly and input filtered bam files must have different filenames"
		exit $EX_USAGE
	fi

	input_args="$input_args INPUT=$bam_file"
	# write_status "full bam file is $bam_file"
done

nows_bams=$(tr -d ' 	\n' <<< "$filtered_bams")
if [[ "$nows_bams" != "$filtered_bams" ]] ; then
	write_status "input filtered BAMs cannot contain whitespace"
	exit $EX_USAGE
fi
IFS=',' read -ra FILT_BAM_ARRAY  <<< "$nows_bams"
for filtered_bam_file in "${FILT_BAM_ARRAY[@]}" ; do

	if [[ "$(basename $filtered_bam_file)" == "$(basename $assembly)" ]] ; then
		write_status "assembly and input filtered bam files must have different filenames"
		exit $EX_USAGE
	fi

	input_filtered_args="$input_filtered_args INPUT=$filtered_bam_file"
	# write_status "filtered bam file is $filtered_bam_file"
done

for (( i=0; i < $label_count; ++i ))
do
    write_status "Label $i: name=${LABEL_ARRAY[$i]} full-bam=${BAM_ARRAY[$i]} filtered-bam=${FILT_BAM_ARRAY[$i]}"
done

write_status "Full BAM args: $input_args"
write_status "Filtered BAM args: $input_filtered_args"


# Validate tools exist on path
for tool in Rscript samtools java bwa ; do #minimap2
	if ! which $tool >/dev/null; then
		write_status "Error: unable to find $tool on \$PATH"
		exit $EX_CONFIG
	fi
	write_status "Found $(which $tool)"
done
if $(samtools --version-only >/dev/null) ; then
	write_status "samtools version: $(samtools --version-only 2>&1)"
else
	write_status "Your samtools version does not support --version-only. Update samtools."
	exit $EX_CONFIG
fi
if [[ "$(samtools --version-only)" =~ ^([0-9]+)[.]([0-9]+) ]] ; then
	samtools_major_version=${BASH_REMATCH[1]}
	samtools_minor_version=${BASH_REMATCH[2]}
	if [[ "$samtools_major_version" -le 1 ]] && [[ "$samtools_minor_version" -lt 10 ]] ; then
		write_status "samtools 1.13 or later is required."
		exit $EX_CONFIG
	fi
else
	write_status "Unable to determine samtools version"
	exit $EX_CONFIG
fi

# write_status "R version: $(Rscript --version 2>&1)"

write_status "bwa $(bwa 2>&1 | grep Version || echo -n)"

if [[ "$timecmd" != "" ]] ; then
	if which /usr/bin/time >/dev/null ; then
		write_status "time version: $(/usr/bin/time --version 2>&1)"
	fi
fi
write_status "bash version: $(/bin/bash --version 2>&1 | head -1)"

# check java version is ok using the gridss.Echo entry point
if java -cp $gridss_jar gridss.Echo ; then
	write_status "java version: $(java -version 2>&1 | tr '\n' '\t')"
else
	write_status "Unable to run GRIDSS jar - requires java 1.8 or later"
	write_status "java version: $(java -version  2>&1)"
	exit $EX_CONFIG
fi

if ! java -Xms$jvmheap -cp $gridss_jar gridss.Echo ; then
	write_status "Failure invoking java with --jvmheap parameter of \"$jvmheap\". Specify a JVM heap size (e.g. \"31g\") that is valid for this machine."
	exit 1
fi

write_status "Max file handles: $(ulimit -n)" 1>&2

steps_message="Running GRIDSS steps:"

for step in $(echo $steps | tr ',' ' ' ) ; do
	if [[ "$step" == "all" ]] ; then
		do_preprocess=true
		do_assemble=true
		do_call=true
		steps_message="$steps_message all"
	elif [[ "$step" == "preprocess" ]] ; then
		do_preprocess=true
		steps_message="$steps_message pre-process"
	elif [[ "$step" == "assemble" ]] ; then
		do_assemble=true
		steps_message="$steps_message assembly"
	elif [[ "$step" == "call" ]] ; then
		do_call=true
		steps_message="$steps_message call"
	else
		write_status "Unknown step \"$step\""
		exit $EX_USAGE
	fi
done

write_status "$steps_message"

# don't keep files
if [[ $keepTempFiles == "true" ]] ; then
	rmcmd="echo rm disabled:"
	jvm_args="-Dgridss.keepTempFiles=true"
else
	rmcmd="rm"
	jvm_args=""
fi

jvm_args="$jvm_args \
	-XX:ParallelGCThreads=$threads \
	-Dsamjdk.reference_fasta=$reference \
	-Dsamjdk.use_async_io_read_samtools=true \
	-Dsamjdk.use_async_io_write_samtools=true \
	-Dsamjdk.use_async_io_write_tribble=true \
	-Dsamjdk.buffer_size=4194304 \
	-Dsamjdk.async_io_read_threads=$threads"

aligner_args='
 ALIGNER_COMMAND_LINE=null
 ALIGNER_COMMAND_LINE=bwa
 ALIGNER_COMMAND_LINE=mem
 ALIGNER_COMMAND_LINE=-K
 ALIGNER_COMMAND_LINE=10000000
 ALIGNER_COMMAND_LINE=-L
 ALIGNER_COMMAND_LINE=0,0
 ALIGNER_COMMAND_LINE=-t
 ALIGNER_COMMAND_LINE=%3$d
 ALIGNER_COMMAND_LINE=%2$s
 ALIGNER_COMMAND_LINE=%1$s'

samtools_sort="samtools sort --no-PG -@ $threads"

readpairing_args="READ_PAIR_CONCORDANT_PERCENT=null"


# set-up reference has been removed since can assume to exist

####
# Pre-process for each filtered BAM file
####

if [[ $do_preprocess == true ]] ; then
	write_status "*** PRE-PROCESS ***"

	for (( i=0; i < $label_count; ++i ))
	do
		label=${LABEL_ARRAY[$i]}
		bam_file=${FILT_BAM_ARRAY[$i]}
	    write_status "Processing: sample ${LABEL_ARRAY[$i]}, filtered-bam ${FILT_BAM_ARRAY[$i]}"

		dir=$workingdir/$(basename $bam_file).gridss.working
		prefix=$dir/$(basename $bam_file)
		write_status "Start pre-processing: $bam_file, working dir: $dir, prefix: $prefix"

		tmp_prefix=$workingdir/$(basename $bam_file).gridss.working/tmp.$(basename $bam_file)
		mkdir -p $dir
		if [[ ! -d $dir ]] ; then
			write_status "Unable to create directory $dir"
			exit $EX_CANTCREAT
		fi

		name_sorted_bam=$tmp_prefix.namedsorted.bam
		write_status "Creating name-sorted BAM from $bam_file, writing to $name_sorted_bam"

		$timecmd $samtools_sort -l 1 -n \
			-T $tmp_prefix.namedsorted-tmp \
			-Obam \
			-o ${name_sorted_bam} \
			${bam_file}

		write_status "Running ComputeSamTags|samtools: $bam_file"

		rm -f $tmp_prefix.coordinate-tmp*

		{ $timecmd java -Xmx$otherjvmheap $jvm_args \
				-cp $gridss_jar gridss.ComputeSamTags \
				TMP_DIR=$dir \
				WORKING_DIR=$workingdir \
				REFERENCE_SEQUENCE=$reference \
				COMPRESSION_LEVEL=0 \
				I=$name_sorted_bam \
				O=/dev/stdout \
				WORKER_THREADS=$threads \
				ASSUME_SORTED=true \
				REMOVE_TAGS=aa \
				MODIFICATION_SUMMARY_FILE=$prefix.computesamtags.changes.tsv \
		| $timecmd $samtools_sort \
				-l 1 \
				-T $tmp_prefix.coordinate-tmp \
				-Obam \
				-o $tmp_prefix.coordinate.bam \
				/dev/stdin \
		; } 1>&2 2>> $logfile

		write_status "Removing name-sorted bam: $tmp_prefix.namedsorted.bam"
		$rmcmd $tmp_prefix.namedsorted.bam

		write_status "Running SoftClipsToSplitReads: sample $label, input: $tmp_prefix.coordinate.bam, output: $tmp_prefix.sc2sr.primary.sv.bam"
		rm -f $tmp_prefix.sc2sr.suppsorted.sv-tmp*
		{ $timecmd java -Xmx$otherjvmheap $jvm_args \
				-Dsamjdk.create_index=false \
				-cp $gridss_jar gridss.SoftClipsToSplitReads \
				TMP_DIR=$workingdir \
				WORKING_DIR=$workingdir \
				REFERENCE_SEQUENCE=$reference \
				I=$tmp_prefix.coordinate.bam \
				O=$tmp_prefix.sc2sr.primary.sv.bam \
				COMPRESSION_LEVEL=1 \
				OUTPUT_UNORDERED_RECORDS=$tmp_prefix.sc2sr.supp.sv.bam \
				WORKER_THREADS=$threads \
				$aligner_args \
		&& $rmcmd $tmp_prefix.coordinate.bam \
		&& $timecmd $samtools_sort \
				-l 1 \
				-T $tmp_prefix.sc2sr.suppsorted.sv-tmp \
				-Obam \
				-o $tmp_prefix.sc2sr.suppsorted.sv.bam \
				$tmp_prefix.sc2sr.supp.sv.bam \
		&& $rmcmd $tmp_prefix.sc2sr.supp.sv.bam \
		&& $rmcmd -f $prefix.sv.tmp.bam $prefix.sv.tmp.bam.bai \
		&& $timecmd samtools merge \
				-c \
				-p \
				--write-index \
				-@ $threads \
				$prefix.sv.tmp.bam \
				$tmp_prefix.sc2sr.primary.sv.bam \
				$tmp_prefix.sc2sr.suppsorted.sv.bam \
		&& $rmcmd $tmp_prefix.sc2sr.primary.sv.bam \
		&& $rmcmd $tmp_prefix.sc2sr.suppsorted.sv.bam \
		&& mv $prefix.sv.tmp.bam $prefix.sv.bam \
		&& mv $prefix.sv.tmp.bam.csi $prefix.sv.bam.csi \
		; } 1>&2 2>> $logfile

		write_status "Produced SV bam:: $prefix.sv.bam"

		# create metrics on the full BAM and then copy these over the metrics made from the filtered BAMs
		full_bam_file=${BAM_ARRAY[$i]}
		write_status "Running CollectGridssMetrics on $label full BAM $full_bam_file"

		# test_prefix=$prefix.cp

		{ $timecmd java -Xmx$otherjvmheap $jvm_args \
				-cp $gridss_jar gridss.analysis.CollectGridssMetrics \
				REFERENCE_SEQUENCE=$reference \
				TMP_DIR=$dir \
				ASSUME_SORTED=true \
				I=$full_bam_file \
				O=$prefix \
				THRESHOLD_COVERAGE=$maxcoverage \
				FILE_EXTENSION=null \
				GRIDSS_PROGRAM=null \
				GRIDSS_PROGRAM=CollectCigarMetrics \
				GRIDSS_PROGRAM=CollectMapqMetrics \
				GRIDSS_PROGRAM=CollectTagMetrics \
				GRIDSS_PROGRAM=CollectIdsvMetrics \
				PROGRAM=null \
				PROGRAM=CollectInsertSizeMetrics \
				STOP_AFTER=$metricsrecords \
		; } 1>&2 2>> $logfile

		write_status "Complete pre-processing sample: $label"
	done

	write_status "*** PRE-PROCESS COMPLETE ***"
fi

#####
# ASSEMBLY
####

assembly_args="ASSEMBLY=$assembly"

if [[ $do_assemble == true ]] ; then

	write_status "*** ASSEMBLY ***"
	write_status "Running AssembleBreakends: writing output to dir $assembly"
	{ $timecmd java -Xmx$jvmheap $jvm_args \
			-Dgridss.output_to_temp_file=true \
			-cp $gridss_jar gridss.AssembleBreakends \
			JOB_INDEX=0 \
			JOB_NODES=1 \
			TMP_DIR=$workingdir \
			WORKING_DIR=$workingdir \
			REFERENCE_SEQUENCE=$reference \
			WORKER_THREADS=$threads \
			$input_filtered_args \
			$blacklist_arg \
			$config_args \
			$readpairing_args \
			O=$assembly \
	; } 1>&2 2>> $logfile

	write_status "AssemblyBreakends complete"

	dir=$workingdir/$(basename $assembly).gridss.working/
	prefix=$dir/$(basename $assembly)
	tmp_prefix=$dir/tmp.$(basename $assembly)

	write_status "RunningSoftClipsToSplitReads: running on assembly output dir $assembly"
	rm -f $tmp_prefix.sc2sr.suppsorted.sv-tmp*
	{ $timecmd java -Xmx$otherjvmheap $jvm_args \
			-Dgridss.async.buffersize=16 \
			-Dsamjdk.create_index=false \
			-Dgridss.output_to_temp_file=true \
			-cp $gridss_jar gridss.SoftClipsToSplitReads \
			TMP_DIR=$dir \
			WORKING_DIR=$workingdir \
			REFERENCE_SEQUENCE=$reference \
			WORKER_THREADS=$threads \
			I=$assembly \
			O=$tmp_prefix.sc2sr.primary.sv.bam \
			OUTPUT_UNORDERED_RECORDS=$tmp_prefix.sc2sr.supp.sv.bam \
			REALIGN_ENTIRE_READ=true \
			READJUST_PRIMARY_ALIGNMENT_POSITION=true \
			$aligner_args \
	&& $timecmd $samtools_sort \
			-T $tmp_prefix.sc2sr.suppsorted.sv-tmp \
			-Obam \
			-o $tmp_prefix.sc2sr.suppsorted.sv.bam \
			$tmp_prefix.sc2sr.supp.sv.bam \
	&& $rmcmd $tmp_prefix.sc2sr.supp.sv.bam \
	&& $rmcmd -f $prefix.sv.tmp.bam $prefix.sv.tmp.bam.bai \
	&& $timecmd samtools merge \
			-c \
			-p \
			-@ $threads \
			$prefix.sv.tmp.bam \
			$tmp_prefix.sc2sr.primary.sv.bam \
			$tmp_prefix.sc2sr.suppsorted.sv.bam \
	&& $timecmd samtools index $prefix.sv.tmp.bam \
	&& $rmcmd $tmp_prefix.sc2sr.primary.sv.bam \
	&& $rmcmd $tmp_prefix.sc2sr.suppsorted.sv.bam \
	&& mv $prefix.sv.tmp.bam $prefix.sv.bam \
	&& mv $prefix.sv.tmp.bam.bai $prefix.sv.bam.bai \
	; } 1>&2 2>> $logfile

	write_status "Produced assembly BAM: $prefix.sv.bam"

	write_status "Complete Assembly"

	# no idea why this is a for loop, could just be: ASSEMBLY=$assembly
	#assembly_args=""
	#for ass in $assembly ; do
	#	assembly_args="$assembly_args ASSEMBLY=$ass"
	#done
	write_status "Assembly args: $assembly_args"

	write_status "*** ASSEMBLY COMPLETE ***"
fi

####
# VARIANT CALLING
####

if [[ $do_call == true ]] ; then
	write_status "*** VARIANT CALLING ***"

	write_status "Creating variant VCF: $output_vcf"

	dir=$workingdir/$(basename $output_vcf).gridss.working
	prefix=$dir/$(basename $output_vcf)
	mkdir -p $dir
	if [[ ! -d $dir ]] ; then
		write_status "Unable to create directory $dir"
		exit $EX_CANTCREAT
	fi

	# create symbolic links to the full BAM as though they were produced by the pre-process step
	# eg: ./gridss_02/COLO829R.bam.gridss.working/COLO829R.bam.sv.bam
	for (( i=0; i < $label_count; ++i ))
	do
		bam_file=${BAM_ARRAY[$i]}
		bam_dir=$workingdir/$(basename $bam_file).gridss.working

		if [[ ! -d $bam_dir ]] ; then
			mkdir -p $bam_dir
		fi

		sv_bam_file=$bam_dir/$(basename $bam_file).sv.bam
		# write_status "Making soft-link to ${sv_bam_file}"
		#ln -sfr ${bam_file} ${sv_bam_file}
		#ln -sfr ${bam_file}.bai ${sv_bam_file}.bai
	done

	write_status "Running IdentifyVariants"
	{ $timecmd java -Xmx$jvmheap $jvm_args \
			-Dgridss.output_to_temp_file=true \
			-cp $gridss_jar gridss.IdentifyVariants \
			TMP_DIR=$workingdir \
			WORKING_DIR=$workingdir \
			REFERENCE_SEQUENCE=$reference \
			WORKER_THREADS=$threads \
			$input_filtered_args \
			$blacklist_arg \
			$config_args \
			$assembly_args \
			OUTPUT_VCF=$prefix.unallocated.vcf \
			$readpairing_args \
	; } 1>&2 2>> $logfile
	write_status "IdentifyVariants complete, produced $prefix.unallocated.vcf"

	write_status "Running AnnotateVariants"
	{ $timecmd java -Xmx$jvmheap $jvm_args \
			-Dgridss.output_to_temp_file=true \
			-Dgridss.async.buffersize=2048 \
			-cp $gridss_jar gridss.AnnotateVariants \
			TMP_DIR=$workingdir \
			WORKING_DIR=$workingdir \
			REFERENCE_SEQUENCE=$reference \
			WORKER_THREADS=$threads \
			$input_filtered_args \
			$blacklist_arg \
			$config_args \
			$assembly_args \
			INPUT_VCF=$prefix.unallocated.vcf \
			OUTPUT_VCF=$prefix.allocated.vcf \
			$readpairing_args \
	; } 1>&2 2>> $logfile
	$rmcmd $prefix.unallocated.vcf
	write_status "AnnotateVariants complete, produced $prefix.allocated.vcf"

	write_status "Running AnnotateInsertedSequence"

	{ $timecmd java -Xmx$otherjvmheap $jvm_args \
			-Dgridss.output_to_temp_file=true \
			-cp $gridss_jar gridss.AnnotateInsertedSequence \
			TMP_DIR=$workingdir \
			WORKING_DIR=$workingdir \
			REFERENCE_SEQUENCE=$reference \
			WORKER_THREADS=$threads \
			INPUT=$prefix.allocated.vcf \
			OUTPUT=$output_vcf \
	&& $rmcmd $prefix.allocated.vcf \
	; } 1>&2 2>> $logfile
	write_status "AnnotateInsertedSequence complete, produced $output_vcf"

	write_status "*** VARIANT CALLING COMPLETE ***"
fi

if [[ -f $logfile ]] ; then
	write_status "Run complete with $(grep WARNING $logfile | wc -l) warnings and $(grep ERROR $logfile | wc -l) errors."
fi
trap - EXIT
exit 0 # success!
