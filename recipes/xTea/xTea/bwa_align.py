##11/04/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

import pysam
import os
import global_values
from cmd_runner import *

class BWAlign():
    def __init__(self, BWA_PATH, BWA_REALIGN_CUTOFF, n_jobs):
        self.BWA_PATH=BWA_PATH
        self.BWA_REALIGN_CUTOFF=BWA_REALIGN_CUTOFF
        self.n_jobs = n_jobs
        self.BWA_SEED_FREQ=10 #by default, this value is 500 in bwa mem
        self.BWA_SEED_MEDIUM_FREQ = 70 #by default, this value is 500 in bwa mem
        self.cmd_runner=CMD_RUNNER()

    # re-align the collected clipped and discordant reads
    def realign_clipped_reads(self, sf_ref, sf_reads, sf_out_sam):
        cmd = "{0} mem -t {1} -T {2} -k {3} -o {4} {5} {6}" \
              "".format(self.BWA_PATH, self.n_jobs, self.BWA_REALIGN_CUTOFF, self.BWA_REALIGN_CUTOFF, sf_out_sam,
                        sf_ref, sf_reads)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_small_output(cmd)

    # this is assume the clipped parts including the short polyA
    # So we need to split the original "sf_readds" to polyA-reads and non-polyA reads,
    # then, align them seperately
    # Note, input "sf_reads" is in "fastq" format
    def realign_clipped_read_with_polyA(self, sf_ref, sf_reads, sf_out_sam):
        sf_reads1=sf_reads+".non_polyA.fq"
        sf_reads2=sf_reads+".polyA.fq"

        with pysam.FastxFile(sf_reads) as fh, open(sf_reads1,"w") as fout_non, open(sf_reads2, "w") as fout_polya:
            for entry in fh:
                len_seq=len(entry.sequence)
                if len_seq<global_values.BWA_REALIGN_CUTOFF:
                    fout_polya.write(str(entry)+"\n")
                else:
                    fout_non.write(str(entry)+"\n")
        sf_sam1=sf_out_sam+".non_polyA.sam"
        self.realign_clipped_reads(sf_ref, sf_reads1, sf_sam1)
        sf_sam2 = sf_out_sam + ".polyA.sam"
        self.realign_clipped_polyA(sf_ref, sf_reads2, sf_sam2)

        #merge the alignment
        with open(sf_out_sam,"w") as fout_sam:
            with open(sf_sam1) as fin_sam1:
                for line in fin_sam1:
                    fout_sam.write(line)
            with open(sf_sam2) as fin_sam2:
                for line in fin_sam2:
                    if line[0]=="@":
                        continue
                    fout_sam.write(line)
        os.remove(sf_reads1)
        os.remove(sf_reads2)
        os.remove(sf_sam1)
        os.remove(sf_sam2)
####
    def index_ref_file(self, sf_fa):
        cmd="%s index %s" % (self.BWA_PATH, sf_fa)
        self.cmd_runner.run_cmd_small_output(cmd)

    # re-align the collected clipped and discordant reads
    def realign_clipped_polyA(self, sf_ref, sf_reads, sf_out_sam):
        cmd = "{0} mem -t {1} -T {2} -k {3} -o {4} -c {5} {6} {7}".format(self.BWA_PATH, self.n_jobs,
                                                                   global_values.MINIMUM_POLYA_CLIP,
                                                                   global_values.MINIMUM_POLYA_CLIP, sf_out_sam,
                                                                          self.BWA_SEED_MEDIUM_FREQ, sf_ref, sf_reads)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        #self.cmd_runner.run_cmd_to_file(cmd, sf_out_sam)
        self.cmd_runner.run_cmd_small_output(cmd)

    # re-align the collected clipped and discordant reads
    def realign_clipped_reads_low_mem(self, sf_ref, sf_reads, sf_out_sam):
        n_cores = self.n_jobs - 1
        if n_cores <= 0:
            n_cores = 1
        cmd = "{0} mem -t {1} -T {2} -k {3} -c {4} -o {5} {6} {7}".format(self.BWA_PATH, n_cores,
                                                                  self.BWA_REALIGN_CUTOFF,
                                                                  self.BWA_REALIGN_CUTOFF, self.BWA_SEED_FREQ,
                                                                  sf_out_sam, sf_ref, sf_reads)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        #self.cmd_runner.run_cmd_small_output(cmd)
        self.cmd_runner.run_cmd_to_file(cmd, sf_out_sam + ".std_out")

    # re-align the collected clipped and discordant reads
    def realign_clipped_reads_low_mem_add_head(self, sf_ref, sf_reads, sf_head, sf_out_sam):
        n_cores = self.n_jobs - 1
        if n_cores <= 0:
            n_cores = 1

        cmd = "{0} mem -t {1} -T {2} -k {3} -c {4} -D 0.9 -h 2 -H {5} {6} {7} | " \
              "{8} view -hS -F 4 -o {9} -".format(self.BWA_PATH, n_cores,
                                                   self.BWA_REALIGN_CUTOFF,
                                                   self.BWA_REALIGN_CUTOFF,
                                                   self.BWA_SEED_FREQ,
                                                   sf_head, sf_ref, sf_reads,
                                                   global_values.SAMTOOLS_PATH, sf_out_sam)
        # cmd = "{0} mem -t {1} -T {2} -k {3} -c {4} -D 0.9 -h 2 -H {5} -o {6} {7} {8}".format(self.BWA_PATH, n_cores,
        #                                                            self.BWA_REALIGN_CUTOFF,
        #                                                            self.BWA_REALIGN_CUTOFF, self.BWA_SEED_FREQ,
        #                                                            sf_head, sf_out_sam, sf_ref, sf_reads)
        print("Run command: {0}".format(cmd))#
        # Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_to_file(cmd, sf_out_sam+".std_out")
        #self.cmd_runner.run_cmd_small_output(cmd)
#####For test only now!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        #self.cmd_runner.run_cmd2(cmd, sf_out_sam)

    def align_exon_to_contig(self, sf_ref, sf_reads, sf_out_bam):
        cmd = "{0} mem -t {1} {2} {3} | samtools view -hSb - | {4} sort -o {5} - && samtools index {5}"\
            .format(self.BWA_PATH, self.n_jobs,  sf_ref, sf_reads, global_values.SAMTOOLS_PATH, sf_out_bam)
        print(("Run command: {0}".format(cmd)))
        self.cmd_runner.run_cmd_small_output(cmd)

    # re-align the collected clipped and discordant reads
    def realign_disc_reads(self, sf_ref, sf_reads, sf_out_sam):
        cmd = "{0} mem -t {1} -o {2} {3} {4}".format(self.BWA_PATH, self.n_jobs, sf_out_sam, sf_ref, sf_reads)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_small_output(cmd)

    # re-align the collected clipped and discordant reads
    def realign_disc_reads_low_mem(self, sf_ref, sf_reads, sf_out_sam):
        cmd = "{0} mem -t {1} -c {2} -o {3} {4} {5}".format(self.BWA_PATH, self.n_jobs, self.BWA_SEED_FREQ, sf_out_sam,
                                                            sf_ref, sf_reads)
        # Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_small_output(cmd)
####

####need to test this one
    # re-align the collected reads
    # re-align the collected reads
    def realign_reads_to_bam(self, SAMTOOLS, sf_ref, sf_reads, sf_out_bam):
        cmd = "{0} mem -t {1} {2} {3} | {4} view -hSb - | {5} sort - ".format(
            self.BWA_PATH, self.n_jobs, sf_ref, sf_reads, SAMTOOLS, SAMTOOLS)
        print("Run command: {0}".format(cmd))
        str_err=self.cmd_runner.run_cmd_to_file(cmd, sf_out_bam)

        cmd2 = "{0} index {1}".format(SAMTOOLS, sf_out_bam)
        # Popen(cmd, shell=True, stdout=PIPE).communicate()
        str_err = self.cmd_runner.run_cmd_small_output(cmd2)

####
    ####
    # in this version, to reduce the memory consuming, we
    # 1) First, align to consensus, to collect those can be fully aligned to repeat copies
    # 2) Second, for those unmapped or poorly mapped, realign the copies with flank regions, use small value for "-c"
    def is_full_map(self, algnmt, max_clip_len):
        l_cigar = algnmt.cigar
        if len(l_cigar) < 1:  # wrong alignment
            return False
        if len(l_cigar) == 1 and l_cigar[0][0] == 0:  ##fully mapped
            return True
        elif (l_cigar[0][0] == 4 or l_cigar[0][0] == 5) and (l_cigar[0][1] <= max_clip_len) and l_cigar[-1][
            0] == 0:  # left clipped
            return True
        elif (l_cigar[-1][0] == 4 or l_cigar[-1][0] == 5) and (l_cigar[-1][1] <= max_clip_len) and l_cigar[0][
            0] == 0:  # right clipped
            return True
        return False


    def get_fully_mapped_algnmts(self, sf_sam, sf_reference, max_clip_len, sf_fully_sam, sf_unmap_fa, sf_polyA_fa):
        bamfile = pysam.AlignmentFile(sf_sam, "r", reference_filename=sf_reference)  #
        out_tmp_bam = pysam.AlignmentFile(sf_fully_sam, 'w', template=bamfile)
        with open(sf_unmap_fa, "w") as fout_fa, open(sf_polyA_fa, "w") as fout_polyA:
            iter_algnmts = bamfile.fetch()
            for alnmt in iter_algnmts:  # each in "pysam.AlignedSegment" format
                #first check whether it is primary alignment, if not then skip
                if alnmt.is_duplicate == True or alnmt.is_supplementary == True:##skip duplicate and supplementary ones
                    continue
                if alnmt.is_secondary == True:  ##skip secondary alignment
                    continue
                if self.is_full_map(alnmt, max_clip_len) == True:
                    out_tmp_bam.write(alnmt)
                else:
                    len_seq=len(alnmt.query_sequence)
                    if len_seq>=global_values.MINIMUM_POLYA_CLIP and len_seq<global_values.BWA_REALIGN_CUTOFF:
                        fout_polyA.write(">" + alnmt.query_name + "\n")
                        fout_polyA.write(alnmt.query_sequence + "\n")
                    else:
                        fout_fa.write(">" + alnmt.query_name + "\n")
                        fout_fa.write(alnmt.query_sequence + "\n")
        out_tmp_bam.close()
        bamfile.close()


    ##append sam records to another sam
    def append_to_sam(self, sf_in_sam, sf_out):
        with open(sf_out, "a") as fout, open(sf_in_sam) as fin_sam:
            for line in fin_sam:
                if line[0]!="@":
                    fout.write(line)
####

    ##may potentially have trouble for the @PG fields, as this is not merged, but just use the one from sf_copy_sam
    def merge_all_sam(self, sf_cns_sam, sf_polyA_sam, sf_copy_sam, sf_merged_sam):
        # then merge the two sam files
        #first collect the @SN fields from sf_cns_sam
        l_cns_SN=[]
        with open(sf_cns_sam) as fin_cns:
            for line in fin_cns:
                if line[0]=="@":
                    fields=line.split()
                    if fields[0]=="@SQ":
                        l_cns_SN.append(line)
                else:
                    break

        #then merge the two sam file
        with open(sf_merged_sam, "w") as fout_merged, open(sf_cns_sam) as fin_cns_sam, \
                open(sf_polyA_sam) as fin_polyA_sam, open(sf_copy_sam) as fin_copy_sam:
            b_head_merged=False
            for line in fin_copy_sam:
                if line[0]=="@":
                    fields=line.split()
                    if fields[0]=="@SQ":
                        if b_head_merged==False:
                            for s_rcd in l_cns_SN:
                                fout_merged.write(s_rcd)
                            b_head_merged=True
                fout_merged.write(line)

            for line in fin_polyA_sam:
                if line[0]!="@":
                    fout_merged.write(line)

            for line in fin_cns_sam:
                if line[0]!="@":
                    fout_merged.write(line)
####
####
    def _gnrt_SQ_from_fa(self, sf_fa, sf_sq):
        s_sq=""
        with pysam.FastxFile(sf_fa) as fh, open(sf_sq, "w") as fout_sq:
            for entry in fh:
                sinfo="@SQ\tSN:{0}\tLN:{1}\n".format(entry.name, len(entry.sequence))
                fout_sq.write(sinfo)
        return s_sq
    ####
    # here need to add the consensus to the repeat copy library file
    def two_stage_realign(self, sf_ref_cns, sf_ref2, sf_reads, sf_out):
        # align to consensus first
        sf_sam_cns = sf_out + "_cns.sam"
        n_cores = self.n_jobs - 1
        if n_cores <= 0:
            n_cores = 1
        cmd = "{0} mem -t {1} -T {2} -k {3} -o {4} {5} {6}".format(self.BWA_PATH, n_cores,
                                                                   self.BWA_REALIGN_CUTOFF, self.BWA_REALIGN_CUTOFF,
                                                                   sf_sam_cns, sf_ref_cns, sf_reads)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        #self.cmd_runner.run_cmd_to_file(cmd, sf_sam_cns)
        self.cmd_runner.run_cmd_small_output(cmd)

        sf_fully_sam = sf_out + ".sam"
        sf_unmap_fa = sf_out + "_unmapped_phase1.fa"
        max_clip_len = 2
        #here at the same time, will keep those short polyA ones in a seperate file
        sf_polyA_fa=sf_out+"_partial_polyA.fa"
        self.get_fully_mapped_algnmts(sf_sam_cns, sf_ref_cns, max_clip_len, sf_fully_sam, sf_unmap_fa, sf_polyA_fa)

        #align the small polyA regions to repeat consensus
        sf_polyA_sam=sf_out+"_partial_polyA.sam"
        self.realign_clipped_polyA(sf_ref_cns, sf_polyA_fa, sf_polyA_sam)

        #create a new SQ header file, which contains all the repeat copies also the consensus
        sf_sq=sf_out+"_sq.txt"
        #create the SQ fields from the rep-copy file
        self._gnrt_SQ_from_fa(sf_ref2, sf_sq)

        with open(sf_sq,"a") as fout_fq:
            samfile = pysam.AlignmentFile(sf_sam_cns, 'r')
            m_header = samfile.header.copy()
            if 'SQ' in m_header:#get the SQ fields
                l_sq = m_header['SQ']
                for sq_rcd in l_sq:
                    sq_ln = sq_rcd['LN']
                    sq_sn = sq_rcd['SN']
                    s_sq = "@SQ\tSN:{0}\tLN:{1}\n".format(sq_sn, sq_ln)
                    fout_fq.write(s_sq)
            samfile.close()

        # then align again to the repeat copies
        #sf_realign_sam = sf_out
        self.realign_clipped_reads_low_mem_add_head(sf_ref2, sf_unmap_fa, sf_sq, sf_out)

        #sf_merged_sam = sf_out_prefix + ".merged.sam"
        #self.merge_all_sam(sf_fully_sam, sf_polyA_sam, sf_realign_sam, sf_out)
        self.append_to_sam(sf_fully_sam, sf_out)
        self.append_to_sam(sf_polyA_sam, sf_out)


        #clean the temporary files
        os.remove(sf_sam_cns)
        os.remove(sf_fully_sam)
        os.remove(sf_unmap_fa)
        os.remove(sf_polyA_fa)
        os.remove(sf_polyA_sam)

    ####
    def calmd_from_algnmt(self, sf_sam, sf_ref, sf_calmd_sam):
        cmd = "{0} calmd -e {1} {2}".format(global_values.SAMTOOLS_PATH, sf_sam, sf_ref)
        self.cmd_runner.run_cmd_to_file(cmd, sf_calmd_sam)
    ####
####
#
# ####
# ## for test only
# ##main function
# if __name__ == '__main__':
#     wfolder='/n/data1/hms/dbmi/park/simon_chu/projects/XTEA/Venter_genome/Illumina/SRR7097859/tmp/'
#     sf_fq=wfolder + 'SRR7097859_v37_decoy_mem_aligned_sorted_markdup.bam.clipped.fq'
#
#     sf_ori_sam=wfolder+'SRR7097859_v37_decoy_mem_aligned_sorted_markdup.bam.clipped.sam'
#
#     sf_cns='/n/data1/hms/dbmi/park/simon_chu/projects/XTEA/rep_lib_annotation/consensus/LINE1.fa'
#     sf_rep_copy="/n/data1/hms/dbmi/park/simon_chu/projects/XTEA/rep_lib_annotation/LINE/hg19/" \
#                 "hg19_L1HS_copies_larger_5K_with_flank.fa"
#     #
#     BWA_PATH="bwa"
#     BWA_REALIGN_CUTOFF=11
#     n_jobs=8
#     bwa_algn=BWAlign(BWA_PATH, BWA_REALIGN_CUTOFF, n_jobs)
#     sf_out_prefix=wfolder+"test_algn"
#     bwa_algn.two_stage_realign(sf_cns, sf_rep_copy, sf_fq, sf_out_prefix)
#
####