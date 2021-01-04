##11/04/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

##############################################################################
####originally used  in x_TEA_main.py
GLOBAL_RNA_MEDIATED=True #non-rna mediated cases will not have the polyA (so will not require polyA support at the filtering step)
def turn_off_rna_mediated():
    global GLOBAL_RNA_MEDIATED
    GLOBAL_RNA_MEDIATED=False

GLOBAL_MITCHONDRION_SWITCH='OFF'
def turn_on_mit():
    global GLOBAL_MITCHONDRION_SWITCH
    GLOBAL_MITCHONDRION_SWITCH='ON'

##############################################################################
####originally used  in clip_read.py
INITIAL_MIN_CLIP_CUTOFF_ILLUMINA=2
INITIAL_MIN_CLIP_CUTOFF_X10=3
INITIAL_MIN_CLIP_CUTOFF=2
def set_initial_min_clip_cutoff(nclip):
    global INITIAL_MIN_CLIP_CUTOFF
    INITIAL_MIN_CLIP_CUTOFF=nclip

BWA_REALIGN_CUTOFF = 9
MINIMUM_POLYA_CLIP=7 #if the clipped part is pure polyA/T, and length is large enough, then keep them
MAX_CLIP_CLIP_LEN = 8
CLIP_PHRED_SCORE_CUTOFF=15#cutoff phred score

MINIMUM_CLIP_MAPQ=12 ####minimum mapping quality when checking a read is clippped or not
def set_min_clip_mapq(mapq):
    global MINIMUM_CLIP_MAPQ
    MINIMUM_CLIP_MAPQ=mapq
CLIP_LOW_MAPQ=5 ####If the clip reads has mapq<=5, then view as low map quality clip read (counted as background reads)
MAX_LOWQ_CLIP_RATIO=0.65 #if more thant this value of clipped reads are of lowq, then view as FP.
NEARBY_LOW_Q_CLIP=35

MINIMUM_DISC_MAPQ = 20 #####minimum mapping quality when collecting discordant reads
def set_min_disc_mapq(mapq):
    global MINIMUM_DISC_MAPQ
    MINIMUM_DISC_MAPQ=mapq

MAX_BKGRND_LOW_MAPQ = 10#if a read has lower than this value mapq, then view as backgroup low mapq read
MAX_BKGRND_LOW_MAPQ_RATIO=0.1

BWA_PATH = "bwa"
SAMTOOLS_PATH = "samtools"
CLIP_FQ_SUFFIX = ".clipped.fq"
CLIP_BAM_SUFFIX = ".clipped.sam"
CLIP_BAM_SUFFIX2 = ".clipped.bam"
CLIP_POS_SUFFIX = ".clip_pos"
CLIP_RE_ALIGN_POS_SUFFIX = ".clip_realign_pos"
LCLIP_FA_SUFFIX = '.lr_clipped.fa'  # for long reads or contigs
FLAG_LEFT_CLIP = "L"
FLAG_RIGHT_CLIP = "R"
SEPERATOR = '~'
ALL_DISC_SUFFIX = ".initial.all.disc"  # this is to save all the disc reads

#only check polyA in a small region, not the whole clipped part
CK_POLYA_CLIP_WIN=25 #only check whether contain polyA for those clipped reads in a 15bp window
CK_POLYA_SEQ_MAX=20#at most check 10 bases region for polyA
POLYA_RATIO=0.4 #at least 40% A or T
###############
##############################################################################
####originally used in x_alignments.py
BARCODE_COV_CUTOFF = 600
MIN_RAW_DISC_CLUSTER_RATIO=0.3
##############################################################################
ILLUMINA="illumina"
X10="10X"
LONG_READ="long_read"
##############################################################################
####originally used x_TEI_locator.py
MIN_CLIP_FOR_CANDIDATE=2# if a site has left-right clipped reads like (1,1), (1,0), or (0,1), these will be filtered out
NEARBY_REGION = 50
CLIP_FREQ = 10
TRIM_CLIP_FREQ = 2
PEAK_WINDOW = 100
OUTPUT_BAM_SUFFIX = ".out_bam"
OUTPUT_BAM_HEADER = ".bam_header.sam"
CLIP_FOLDER = "clip"
DISC_FOLDER = "disc"
DISC_SUFFIX = '.discord_pos.txt'
DISC_SUFFIX_FILTER = '.discdt'
RAW_DISC_SUFFIX_FILTER = '.raw.discdt'
CLIP_TMP = "clip_reads_tmp"
DISC_TMP = "discordant_reads_tmp"
RAW_DISC_TMP = "raw_discordant_reads_tmp"#this is for any kind of discordant
RAW_DISC_TMP_SUFFIX=".clip_sites_raw_disc.txt"
###############################################################################
###############################################################################
####originally used in x_clip_disc_filter.py
CHECK_BY_SAMPLE=False #whether check by samples, if true, then require each sample have some support
def turn_on_check_by_sample():
    global CHECK_BY_SAMPLE
    CHECK_BY_SAMPLE=True

IS_CALL_SVA=False
def turn_on_sva():
    global IS_CALL_SVA
    IS_CALL_SVA=True
SVA_ANNOTATION_EXTND=200

####
DISC_THRESHOLD = 2000
TSD_CUTOFF = 100
TRANSDCT_UNIQ_MAPQ=50
MINIMAL_TRANSDUCT_MAPQ = 10
N_MIN_A_T = 5  # minimu number of consecutive "A" or "T"
NEARBY_CLIP = 50
CLIP_SEARCH_WINDOW = 15
CLIP_CONSISTENT_RATIO=0.4
MAX_COV_TIMES=3 #if the coverage is larger than ave_cov*MAX_COV_TIMES, then view as abnormal
COV_SEARCH_WINDOW=1000
COV_ISD_CHK_WIN=900 #check coverage island within this window
LOCAL_COV_WIN=200
MIN_CLIP_MAPPED_RATIO=0.65
MIN_DISC_MAPPED_RATIO=0.7
TWO_SIDE_CLIP_MIN_LEN=8 #to define a two side clip, then clip length should longer than 7bp
####
DISC_NAME_SUFFIX = ".disc_names"
DISC_POS_SUFFIX = ".disc_pos"
GNTP_FEATURE_SUFFIX=".gntp_features"
ALLELE_FREQUENCY_SUFFIX = '.af'
NOT_TRANSDUCTION = "not_transduction"
ONE_SIDE_FLANKING="may_two_side_with_one_side_on_flanking"
TWO_SIDE="two_side"
TWO_SIDE_TPRT_BOTH="two_side_tprt_both"
TWO_SIDE_TPRT="two_side_tprt"
ONE_HALF_SIDE="one_half_side"
ONE_HALF_SIDE_TRPT_BOTH="one_half_side_tprt_both"
ONE_HALF_SIDE_TRPT="one_half_side_tprt"
ONE_HALF_SIDE_POLYA_DOMINANT="polyA_dominant_one-half-side_may_low_confident"
ONE_SIDE="one_side"
ONE_SIDE_COVERAGE_CONFLICT="one_side_coverage_conflict"
ONE_SIDE_TRSDCT="one_side_and_half_transduction"
ONE_SIDE_WEAK="one_side_weak" #the other side has weak signal
ONE_SIDE_OTHER="one_side_other"
ONE_SIDE_SV="one_side_sv"
ONE_SIDE_POLYA_DOMINANT="polyA_dominant_one-side_may_low_confident"

ORPHAN_TRANSDUCTION="orphan_or_sibling_transduction"
#
TWO_SIDE_POLYA_DOMINANT="polyA_dominant_both-side_may_low_confident"
HIGH_COV_ISD="high_coverage_island_low_confident"
OTHER_TYPE="other_type_low_confident"
####
HIT_END_OF_CNS="hit_end_of_consensus"
NOT_HIT_END_OF_CNS="not_hit_end_of_consensus"
BOTH_END_CONSISTNT="both_end_consistent"
ONE_END_CONSISTNT="one_end_consistent"
MAX_POLYA_RATIO=0.85
RAW_DISC_FA_SUFFIX=".raw_disc.fa"#suffix of the raw disc reads (for collecting extra transduction)
RAW_CLIP_FQ_SUFFIX=".raw_clip.fq"#suffix of the raw clip reads (for collecting extra transduction)
HIGH_CONFIDENT_SUFFIX=".high_confident"
FIVE_PRIME_INVERSION="5-prime-inversion"
NOT_FIVE_PRIME_INV="Not-5prime-inversion"
####
####
###############################################################################
###############################################################################
####Originally used in x_transduction.py
MIN_POLYMORPHIC_SOURCE_DIST=1000
TRANSDCT_MULTI_SOURCE_MIN_RATIO=0.45#from algnment may show several possible sources, should have a dominant one
TRANSDCT_OTHER_SIDE_CLUSTER_MIN_RATIO=0.1#For the other side, if also form a cluster, require at least this ratio of reads from the same cluster
TRANSDCT_REGION_CLUSTER_MIN_RATIO=0.67 #at least this number of reads are in the region cluster
TD_CLIP_QLFD_RATIO=0.8#if the clipped part have more than this ratio of bases are aligned, then view as qualified
TD_DECOY_LINE="LINE1"
TD_DECOY_SVA="SVA"
TD_DECOY_ALU="ALU"
TD_DECOY_HERV="HERV"
S_POLYMORPHIC="polymerphic"
F_MIN_TRSDCT_DISC_MAP_RATION=0.65
F_MIN_RSC_DISC_MAP_RATION=0.6
TWO_SITES_CLOSE_DIST=100
MIN_HALF_SIBLING_DISC_RATIO=0.85
TD_NON_SIBLING_SUFFIX=".all_non_sibling_td.txt"
TD_NEW_SITES_SUFFIX=".new_sites"
#####originally used in x_orphan_transdcution.py
MIN_SIBLING_FLANK_LEN=15#minimal flank region length of sibling region
MAX_SIBLING_FLANK_LEN=5000#maximum flank region length of sibling region
MIN_ORPHAN_DISC_PAIR_INSERT_SIZE=100000 #0.1M
MIN_CLUSTER_RC_RATIO=0.6 #at least this ratio of reads (each cluster) are reverse(or non)-complementary
MIN_POLYA_CLIP_RATIO=0.1 #at least 20% of the clipped reads of one side are polyA/T
DOMINANT_POLYA_T_MIN_RATIO=0.75 #if larger than this, then is dominant
###############################################################################
###############################################################################
######originally defined in x_annotation.py, x_reference.py
S_DELIM = "~"
LEFT_FLANK = 'left'
RIGHT_FLANK = 'right'
LOAD_RMSK_LEFT_EXTND=100
def set_load_rmsk_left_extnd(i_extnd):
    global LOAD_RMSK_LEFT_EXTND
    LOAD_RMSK_LEFT_EXTND=i_extnd
###############################################################################
#####Originally used in x_reads_collection.py
#####This is to collect the reads based on the barcode
READS_FOLDER = "reads_fa"
HAP1 = 'hap1'
HAP2 = 'hap2'
HAP_UNKNOWN = 'hap_unknown'
ALL_HAP = 'all_hap'
HAP_DISCORD = 'hap_discord'
HAP1_SLCT = 'hap1_slct'
HAP2_SLCT = 'hap2_slct'
HAP_UNKNOWN_SLCT = 'hap_unknown_slct'
ALL_HAP_SLCT = 'all_hap_slct'
DISC_HAP_SLCT='disc_slct'
UNIQUE_MAP_CUTOFF = 60  # if mapping quality larger than 50, then consider as "unique map"

###############################################################################
###############################################################################
####Originally used in x_contig.py and x_local_assembly.py
IDBA_UD = "idba_ud"
MINIMAP2 = 'minimap2'
BWA = 'bwa'
CMD_FOLDER = "command"
ASM_FOLDER = "asm_contig"
FLANK_FOLDER = "flank_regions"
MAP_FOLDER = "contig_alignmt"
FILTER_FOLDER = "filter_out"
TEI_SEQ_FOLDER = "tei_seq"
TEI_ON_CNS_CLIP_LENTH = 100  # if clipped part (align to cns) is longer than this, then see as clip
MIN_CONTIG_CLIP_LENTH = 30
###############################################################################
###############################################################################
####originally used in x_mutation.py
MUTATION_FOLDER="mutations"
BCFTOOLS_PATH="bcftools"
TABIX_PATH="tabix"
###############################################################################
###############################################################################
####originally used in x_gene_annotation.py
UP_STREAM_REGION="up_stream"
DOWN_STREAM_REGION="down_stream"
###############################################################################
###############################################################################
########originally used in x_TEA_main.py and x_gene_annotation.py
UP_DOWN_GENE=1500
NON_GENE="not_gene_region"

#force to clean the file
FORCE_CLEAN=False
def set_force_clean():
    global FORCE_CLEAN
    FORCE_CLEAN=True
###############################################################################
###############################################################################
####originally used in l_asm.py
WTDBG2="wtdbg2"
RACON="racon"
WTPOA="wtpoa-cns"
FAIL_CLP='COLLECT_CLIP_FAIL'
FAIL_ASM='ASM_FAIL'
FAIL_CNS="POLISH_FAIL"
SUCCD="succeed"
LRD_CNS_SUFFIX="_wtdbg2.ctg.lay.fa"
LRD_ALNMT_SUFFIX="_aln_flank_2_ctg.bam"
LRD_CLIP_SEARCH_WIN=20000
LRD_MIN_CLIP_LTH=50
BRKPNT_CK_WIN=500 #if the long read cliped within this distance, then it's collected
###############################################################################
####originally used in l_clip_collect.py
LRD_MIN_INS_LTH=40#minimum insertion length when checking the insertion fully contained in cigar
LRD_MAX_BRKPNT_CHK_REGION=300#If the contained insertion breakpoints should not farther than this distance
#LRD_COLLECT_BRKPNT_CHK_REGION=350#If the contained insertion breakpoints should not farther than this distance
LRD_MIN_CLIP_COLLECT_LTH=200
LRD_MIN_CTN_COLLECT_LTH=50
LRD_EXTND_LEN=2000#extend at the clip (or contained) breakpoint
def set_lrd_extnd_len(ilen):
    global LRD_EXTND_LEN
    LRD_EXTND_LEN=ilen
###############################################################################
####originally used in x_coverage.py##############################################################
N_RANDOM_SITES=3000# # of random selected sites for calc coverage
MIN_COV_RANDOM_SITE=5#minium coverage when select a site for calc the average coverage

AVE_COVERAGE=30
def set_average_cov(icov):
    global AVE_COVERAGE
    AVE_COVERAGE=icov
####
####x_genotype.py#############################################################
#MINIMUM_GNTP_MAPQ=0
BWA_HALF_READ_MIN_SCORE=45 #This is half of read length (maybe a little bit smaller than that)
CLIP_EXACT_CLIP_SLACK=3#check number of exact clip
LARGE_INDEL_IN_READ=3#if have 3D or 3I or larger indels within the read, then view as with large indels
DFT_IS=550
def set_insert_size(i_is):
    global DFT_IS
    DFT_IS=i_is

READ_LENGTH=100
def set_read_length(rlth):
    global READ_LENGTH
    READ_LENGTH=rlth

####originally used in x_basic_info.py########################################
BASIC_INFO_FILE="basic_cov_is_rlth_info.txt"
MAX_NORMAL_INSERT_SIZE = 2000

####originally used in x_insert_size.py#######################################
ISIZE_MEAN_SUFFIX = ".mean_temp_is"
####
####originally used in x_tprt_filter.py#######################################
ONE_SIDE_POLYA_CUTOFF=0.75

####initially used at l_alignmt_breakpoints.py
LRD_MIN_MAPQ=20 #minimum mapping quality for long reads
LRD_MIN_MAP_LEN=1000 #minimum mapped length for long reads
LRD_MIN_FOCUS_INS_LEN=50
####initially used at x_intermediate_sites.py
LRD_BRKPNT_FOCAL_REGIN=75 #search breakpoints in [-/+] of this range, and if 85% of breakpoints or > cutoff breakpoints then pass
LRD_BRKPNT_FOCAL_CLIP_RATIO=1
LRD_BRKPNT_MAXIMUM_STD=250
####
####initially used at l_ghost_TE.py
LRD_POLYMORPHIC_MIN_CLIP_LEN=1500
LRD_POLYM_BRK_CHK_WIN=250
def set_polymorphic_brk_chk_win(i_val):
    global LRD_POLYM_BRK_CHK_WIN
    LRD_POLYM_BRK_CHK_WIN=i_val
LRD_PRI_SUP_MAX_OVRLAP=100
LRD_PRI_SUP_MAX_GAP_IN_SEQ=75
LRD_PRI_SUP_DOMINANT_POLYA_RATIO=0.45#the gap between the two segenemnts is dominant by AAAAA, if the ratio is larger
LRD_PRI_SUP_MAX_GAP_MAP_RATIO=0.25
LRD_PRI_SUP_MAX_CLIP=45#if the clip region is smaller than this one, than view it as fully map
#LRD_PRI_MAX_CLIP=75 #if the clip region is smaller than this one, than view it as fully map
####
LRD_MIN_INTERNAL_DEL=50 #if gap is longer than 50, then view as a deletion
LRD_TRSDCT_MIN_MAP_RATION=0.8
LRD_MAX_TSD_LEN=80
LRD_MIN_TSD_LEN=4
LRD_MIN_TSD_MATCH_RATIO=0.85 ####at least 85% matched, then view as matched
####
LRD_PSEUDOGENE_INPUT_SUF=".for_pseudogene.fa"#
####
#originally used in x_post_filter.py
TWO_CLIP_CLUSTER_DIFF_CUTOFF=300
def set_two_clip_cluster_diff_cutoff(i_cutoff):
    global TWO_CLIP_CLUSTER_DIFF_CUTOFF
    TWO_CLIP_CLUSTER_DIFF_CUTOFF=i_cutoff
####
REP_DIVERGENT_CUTOFF=15#at least divergent rate is 15%
REP_LOW_DIVERGENT_CUTOFF=7 #if lower than 7%, then directly filter out (by default for L1)
####
TD_REP_DIVERGENT_CUTOFF=5#at least divergent rate is 5%, as this is transduction region, tolerate the wrong discordant reads from repeats
####
#originally defined in l_ghost_TE.py
ALPHA_SAT_RMSK="ALR/Alpha"
HSATII_SAT_RMSK="HSATII"
####