##09/05/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

import os
import sys
import pysam
from subprocess import *
from multiprocessing import Pool
from x_sites import *
from bwa_align import *
import global_values
from cmd_runner import *

def unwrap_self_algn_read(arg, **kwarg):
    return XMutation.align_reads_to_cns_one_site(*arg, **kwarg)
def unwrap_self_call_snp(arg, **kwarg):
    return XMutation.call_snp_one_site(*arg, **kwarg)
####
class XMutation():
    def __init__(self, s_working_folder):
        #note, the working_folder should be same as the reads collection step
        self.working_folder = s_working_folder
        if "/" != self.working_folder[-1]:
            self.working_folder[-1] += "/"

        self.cmd_runner = CMD_RUNNER()
        #create the mutation folder
        sf_mutation_folder=self.working_folder+global_values.MUTATION_FOLDER
        if os.path.exists(sf_mutation_folder)==False:
            cmd="mkdir {0}".format(sf_mutation_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)


    def call_mutations_from_reads_algnmt(self, sf_sites, sf_cns, i_len_cutoff, n_jobs, sf_merged_vcf):
        xsites = XSites(sf_sites)
        #m_sites = xsites.load_in_sites()
        m_sites=xsites.load_in_qualified_sites_from_xTEA_output(i_len_cutoff)

        l_records = []
        for site_chrm in m_sites:
            for pos in m_sites[site_chrm]:
                l_records.append((site_chrm, pos, 1, sf_cns))  # here use 1 core for each job
        #align reads to cns, and collect the qualified reads
        self.align_reads_to_cns_in_parallel(l_records, n_jobs)
        #call the mutations from the alignments
        self.call_snp_in_parallel(l_records, n_jobs, sf_merged_vcf)

    ####
    def align_reads_to_cns_in_parallel(self, l_records, n_jobs):
        pool = Pool(n_jobs)
        pool.map(unwrap_self_algn_read, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()

    ####
    def call_snp_in_parallel(self, l_records, n_jobs, sf_merged_vcf):
        pool = Pool(n_jobs)
        pool.map(unwrap_self_call_snp, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()
        #merge all the vcf.gz files, and then index it
        #also remove those sites only happen in one sites
        s_mutation_flder = self.working_folder + global_values.MUTATION_FOLDER + "/"
        cmd="{0} merge ".format(global_values.BCFTOOLS_PATH)
        for rcd in l_records:
            site_chrm = rcd[0]
            pos = rcd[1]
            sf_vcf = s_mutation_flder + "{0}_{1}_{2}.vcf.gz".format(site_chrm, pos, global_values.ALL_HAP_SLCT)
            cmd+=(sf_vcf+" ")
        cmd+="-o {0}".format(sf_merged_vcf)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_small_output(cmd)

    def align_reads_to_cns_one_site(self, record):
        site_chrm=record[0]
        pos=record[1]
        n_cores=record[2] #by default, is 1
        sf_cns=record[3]
        s_reads_folder=self.working_folder + global_values.READS_FOLDER + "/"
        bwa_align = BWAlign(global_values.BWA_PATH, global_values.BWA_REALIGN_CUTOFF, n_cores)
        sfa_hap1_slct = s_reads_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.HAP1_SLCT)
        sfa_hap2_slct = s_reads_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.HAP2_SLCT)
        sfa_hap_unknown_slct = s_reads_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.HAP_UNKNOWN_SLCT)
        sfa_hap_all_slct = s_reads_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.ALL_HAP_SLCT)

        s_mutation_flder = self.working_folder + global_values.MUTATION_FOLDER + "/"
        ssam_hap1_tmp = s_mutation_flder + "{0}_{1}_{2}.tmp.bam".format(site_chrm, pos, global_values.HAP1_SLCT)
        ssam_hap2_tmp = s_mutation_flder + "{0}_{1}_{2}.tmp.bam".format(site_chrm, pos, global_values.HAP2_SLCT)
        ssam_hap_unknown_tmp = s_mutation_flder + "{0}_{1}_{2}.tmp.bam".format(site_chrm, pos, global_values.HAP_UNKNOWN_SLCT)
        ssam_hap_all_tmp = s_mutation_flder + "{0}_{1}_{2}.tmp.bam".format(site_chrm, pos, global_values.ALL_HAP_SLCT)

        # align reads to the consensus
        bwa_align.realign_reads_to_bam(global_values.SAMTOOLS_PATH, sf_cns, sfa_hap1_slct, ssam_hap1_tmp)
        bwa_align.realign_reads_to_bam(global_values.SAMTOOLS_PATH, sf_cns, sfa_hap2_slct, ssam_hap2_tmp)
        bwa_align.realign_reads_to_bam(global_values.SAMTOOLS_PATH, sf_cns, sfa_hap_unknown_slct, ssam_hap_unknown_tmp)
        bwa_align.realign_reads_to_bam(global_values.SAMTOOLS_PATH, sf_cns, sfa_hap_all_slct, ssam_hap_all_tmp)

        ssam_hap1_slct = s_mutation_flder + "{0}_{1}_{2}.sorted.bam".format(site_chrm, pos, global_values.HAP1_SLCT)
        ssam_hap2_slct = s_mutation_flder + "{0}_{1}_{2}.sorted.bam".format(site_chrm, pos, global_values.HAP2_SLCT)
        ssam_hap_unknown_slct = s_mutation_flder + "{0}_{1}_{2}.sorted.bam".format(site_chrm, pos, global_values.HAP_UNKNOWN_SLCT)
        ssam_hap_all_slct = s_mutation_flder + "{0}_{1}_{2}.sorted.bam".format(site_chrm, pos, global_values.ALL_HAP_SLCT)
        self.select_qualified_alignments(ssam_hap1_tmp, sf_cns, ssam_hap1_slct)
        self.select_qualified_alignments(ssam_hap2_tmp, sf_cns, ssam_hap2_slct)
        self.select_qualified_alignments(ssam_hap_unknown_tmp, sf_cns, ssam_hap_unknown_slct)
        self.select_qualified_alignments(ssam_hap_all_tmp, sf_cns, ssam_hap_all_slct)

    def call_snp_one_site(self, record):
        site_chrm = record[0]
        pos = record[1]
        sf_cns = record[3]

        s_mutation_flder = self.working_folder + global_values.MUTATION_FOLDER + "/"
        ssam_hap_all_slct = s_mutation_flder + "{0}_{1}_{2}.sorted.bam".format(site_chrm, pos, global_values.ALL_HAP_SLCT)
        sf_vcf=s_mutation_flder+"{0}_{1}_{2}.vcf.gz".format(site_chrm, pos, global_values.ALL_HAP_SLCT)
        self.call_snp_from_reads_alignment(ssam_hap_all_slct, sf_cns, sf_vcf)


    #realign_reads_to_bam(self, SAMTOOLS, sf_ref, sf_reads, sf_out_bam)
    #call out the snp and indels from the haplotype-based alignment
    #1. Call out all 1/1 snps for each haplotype, and get the genotype for each snp
    #2. Create a matrix all the insertions.
    #output in vcf.gz format
    def call_snp_from_reads_alignment(self, sf_algnmt, sf_ref, sf_vcf):
        sf_vcf_tmp=sf_vcf+".tmp"
        cmd="{0} mpileup -IOu -f {1} {2} | {3} call -vmO z -o {4}".format(global_values.BCFTOOLS_PATH, sf_ref, sf_algnmt,
                                                                     global_values.BCFTOOLS_PATH, sf_vcf_tmp)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_small_output(cmd)
        ####index the vcf gz file
        self._index_vcf_gz(sf_vcf_tmp)
        ####filter the results  Hard code here !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        cmd="{0} filter -O z -e 'DP<8 || %QUAL<50' -o {1} {2}".format(global_values.BCFTOOLS_PATH, sf_vcf, sf_vcf_tmp)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_small_output(cmd)
        ####
        self._index_vcf_gz(sf_vcf)

    ####Index xxx.vcf.gz file
    def _index_vcf_gz(self, sf_input):
        cmd = "{0} -f -p vcf {1}".format(global_values.TABIX_PATH, sf_input)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_small_output(cmd)

    ####
    def is_fully_mapped(self, l_cigar, f_cutoff):
        cnt_map = 0
        cnt_total = 0
        for cigar in l_cigar:
            cigar_opr = int(cigar[0])
            cigar_lth = int(cigar[1])
            if cigar_opr == 0:
                cnt_map += cigar_lth
            if cigar_opr != 2:
                cnt_total += cigar_lth
        if cnt_total == 0:
            return False, cnt_map
        if float(cnt_map) / float(cnt_total) >= f_cutoff:
            return True, cnt_map
        return False, cnt_map

    # select reads aligned to consensus (with no or little mutations)
    def select_qualified_alignments(self, sf_algnmt, sf_ref, sf_out_bam):
        bam_in = pysam.AlignmentFile(sf_algnmt, "rb", reference_filename=sf_ref)
        bam_out = pysam.Samfile(sf_out_bam, 'wb', template=bam_in)
        for alignment in bam_in.fetch():
            if alignment.is_unmapped == True:  # unmapped
                continue
            if alignment.is_secondary or alignment.is_supplementary:
                continue
            if alignment.is_duplicate == True:  ##duplciate
                continue
            rlth = len(alignment.query_sequence)
            l_cigar=alignment.cigar
            ####here select fully mapped and at most 3 mismatch
            #####Hard code here !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            b_full_map, cnt_map=self.is_fully_mapped(l_cigar, 0.93)
            if b_full_map==False:
                continue
            if alignment.has_tag("MD") == False:
                continue
            s_tag = alignment.get_tag("MD")
            cnt_mismatch = 0
            for ctmp in s_tag:
                if ctmp >= "A" and ctmp <= "Z":
                    cnt_mismatch += 1
            if rlth>=100:
                if cnt_mismatch>2:
                    continue
            if rlth>=50 and rlth<100:
                if cnt_mismatch>1:
                    continue
            if rlth<50:
                if cnt_mismatch>1:
                    continue
            bam_out.write(alignment)
        bam_out.close()
        bam_in.close()
    ###################################################################################
    ####
    ####

    # 0T38G7G1
    # 49M
    # GCTCTGTGTGTGTGTGTGTGTGTGTGTGTGTGTGTGTGTCTGTGTGTTT
    # [(0, 803, 't'), (1, 804, 'C'), (2, 805, 'T'), (3, 806, 'C'), (4, 807, 'T'), (5, 808, 'G'), (6, 809, 'T'),
    #  (7, 810, 'G'), (8, 811, 'T'), (9, 812, 'G'), (10, 813, 'T'), (11, 814, 'G'), (12, 815, 'T'), (13, 816, 'G'),
    #  (14, 817, 'T'), (15, 818, 'G'), (16, 819, 'T'), (17, 820, 'G'), (18, 821, 'T'), (19, 822, 'G'), (20, 823, 'T'),
    #  (21, 824, 'G'), (22, 825, 'T'), (23, 826, 'G'), (24, 827, 'T'), (25, 828, 'G'), (26, 829, 'T'), (27, 830, 'G'),
    #  (28, 831, 'T'), (29, 832, 'G'), (30, 833, 'T'), (31, 834, 'G'), (32, 835, 'T'), (33, 836, 'G'), (34, 837, 'T'),
    #  (35, 838, 'G'), (36, 839, 'T'), (37, 840, 'G'), (38, 841, 'T'), (39, 842, 'g'), (40, 843, 'T'), (41, 844, 'G'),
    #  (42, 845, 'T'), (43, 846, 'G'), (44, 847, 'T'), (45, 848, 'G'), (46, 849, 'T'), (47, 850, 'g'), (48, 851, 'T')]
####
    ####Call out the snp from repeat copy alignments: From the MD field
    def call_snp_indel_from_rep_copy_algnmt(self):
        sf_bam = "/n/data1/hms/dbmi/park/simon_chu/projects/XTEA/NA12878_10x_v2/tmp_dbg/cns/picked_disc.sorted.bam"
        sf_reference = "/n/data1/hms/dbmi/park/SOFTWARE/LongRanger/refdata-b37-2.1.0/fasta/genome.fa"
        bamfile = pysam.AlignmentFile(sf_bam, "r", reference_filename=sf_reference)
        ncnt = 0
        for algnmt in bamfile.fetch():
            l_mismatch = algnmt.get_aligned_pairs(False, True)
            if algnmt.has_tag("MD") == False:
                continue
            print(algnmt.get_tag("MD"))
            print(algnmt.cigarstring)
            print(algnmt.query_sequence)
            print(l_mismatch)
            if ncnt > 20:
                break
            ncnt += 1
        bamfile.close()
####


####