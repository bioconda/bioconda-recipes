##11/22/2017
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

import os
import sys
import pysam
from subprocess import *
from multiprocessing import Pool
from x_alignments import *
from x_dispatch_jobs import *
from clip_read import LContigClipReadInfo
import global_values
from cmd_runner import *

####
####
def unwrap_align_contig(arg, **kwarg):
    return XTEContig.run_align_flank_to_contig_by_chrm(*arg, **kwarg)

def unwrap_align_phased_contig(arg, **kwarg):
    return XTEContig.run_align_flank_to_phased_contig_by_chrm(*arg, **kwarg)

def unwrap_self_filter_by_asm(arg, **kwarg):
    return XTEContig.run_filter_out_non_TE_from_asm_by_chrm(*arg, **kwarg)

def unwrap_self_validate_by_asm(arg, **kwarg):
    return XTEContig.run_select_TEI_from_algnmt_by_chrm(*arg, **kwarg)
####
def unwrap_align_flanks_to_contig(arg, **kwarg):
    return XTEContig.run_align_flank_to_contig_2(*arg, **kwarg)

def unwrap_self_align_contig_to_target_seq(arg, **kwarg):
    return XTEContig.run_align_contig_to_target_seq(*arg, **kwarg)

####
class XTEContig():
    def __init__(self, s_working_folder, n_jobs):
        self.working_folder = s_working_folder
        if self.working_folder[-1] != "/":
            self.working_folder += "/"
        self.n_jobs = n_jobs
        self.cmd_runner=CMD_RUNNER()

    def run_cmd(self, cmd):
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_small_output(cmd)

    def run_cmd_with_out(self, cmd, sf_out):
        self.cmd_runner.run_cmd_to_file(cmd, sf_out)

    def align_long_contig(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        cmd = "{0} -x asm5 --cs -a -t {1} {2} {3} > {4}".format(global_values.MINIMAP2, n_jobs, sf_ref, sf_contig, sf_algnmt)
        self.run_cmd(cmd)

    def align_short_contig_minimap2(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        cmd = "{0} -x sr --cs -a -t {1} {2} {3} > {4}".format(global_values.MINIMAP2, n_jobs, sf_ref, sf_contig, sf_algnmt)
        self.run_cmd(cmd)

    ###this version use self-defined parameters
    def align_short_contigs_minimap2_v2_sam(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        cmd = "{0} -k15 -w5 --sr --frag=yes -A2 -B8 -O12,32 -E2,1 -r150 -p.5 -N20 -f10000,50000 -n2 " \
              "-m20 -s40 -g200 -2K50m --heap-sort=yes --secondary=no --cs -a -t {1} {2} {3} " \
              "> {4}" \
            .format(global_values.MINIMAP2, n_jobs, sf_ref, sf_contig, sf_algnmt)
        #print cmd
        self.run_cmd(cmd)

    ###this version use self-defined parameters
    def align_short_contigs_minimap2_v2(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        cmd = "{0} -k15 -w5 --sr --frag=yes -A2 -B8 -O12,32 -E2,1 -r150 -p.5 -N20 -f10000,50000 -n2 " \
              "-m20 -s40 -g200 -2K50m --heap-sort=yes --secondary=no --cs -a -t {1} {2} {3} " \
              "| samtools view -hSb - | samtools sort -o {4} -" \
            .format(global_values.MINIMAP2, n_jobs, sf_ref, sf_contig, sf_algnmt)
        self.run_cmd(cmd)
        cmd = "samtools index {0}".format(sf_algnmt)
        self.run_cmd(cmd)
####
    ####this version use self-defined parameters
    ####this version has smaller penalty for gap opening and extension
    ####-Y option, use soft-clip as supplementary alignment
    def align_short_contigs_2_cns_minimap2(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        cmd = "{0} -k11 -w5 --sr --frag=yes -A2 -B4 -O4,8 -E2,1 -r150 -p.5 -N5 -n1 " \
              "-m20 -s30 -g200 -2K50m --MD --heap-sort=yes --secondary=no --cs -a -t {1} {2} {3} " \
              "| samtools view -hSb - | samtools sort -o {4} -" \
            .format(global_values.MINIMAP2, n_jobs, sf_ref, sf_contig, sf_algnmt)
        self.run_cmd(cmd)
        cmd = "samtools index {0}".format(sf_algnmt)
        self.run_cmd(cmd)

    def splice_algn_contigs_2_ref_minimap2(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        cmd = "{0} -ax splice -t {1} {2} {3} " \
              "| samtools view -hSb - | samtools sort -o {4} -" \
            .format(global_values.MINIMAP2, n_jobs, sf_ref, sf_contig, sf_algnmt)
        self.run_cmd(cmd)
        cmd = "samtools index {0}".format(sf_algnmt)
        self.run_cmd(cmd)

####

    def align_contigs_2_reference_genome(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        cmd = "{0} -ax asm5 " \
              "-t {1} {2} {3} " \
              "| samtools view -hSb - | samtools sort -o {4} -" \
            .format(global_values.MINIMAP2, n_jobs, sf_ref, sf_contig, sf_algnmt)
        self.run_cmd(cmd)
        cmd = "samtools index {0}".format(sf_algnmt)
        self.run_cmd(cmd)

    def align_short_contigs_with_secondary_supplementary(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        cmd = "{0} -k15 -w5 --sr --frag=yes -A2 -B8 -O12,32 -E2,1 -r150 -p.5 -N20 -f10000,50000 -n2 " \
              "-m20 -s40 -g200 -2K50m --heap-sort=yes --secondary=yes --cs -a -t {1} {2} {3} " \
              "| samtools view -hSb - | samtools sort -o {4} -" \
            .format(global_values.MINIMAP2, n_jobs, sf_ref, sf_contig, sf_algnmt)
        self.run_cmd(cmd)
        cmd = "samtools index {0}".format(sf_algnmt)
        self.run_cmd(cmd)

    def align_short_contigs_with_secondary_supplementary2(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        sf_tmp=sf_algnmt+".sam"
        sf_tmp2 = sf_algnmt + ".bam"
        cmd = "{0} -k15 -w5 --sr --frag=yes -A2 -B8 -O12,32 -E2,1 -r150 -p.5 -N20 -f10000,50000 -n2 " \
              "-m20 -s40 -g200 -2K50m --heap-sort=yes --secondary=yes --cs -a -t {1} {2} {3} > {4}" \
              " && samtools view -hSb {5} > {6} && samtools sort -o {7} {8}" \
            .format(global_values.MINIMAP2, n_jobs, sf_ref, sf_contig, sf_tmp, sf_tmp, sf_tmp2, sf_algnmt, sf_tmp2)
        self.run_cmd(cmd)
        cmd = "samtools index {0}".format(sf_algnmt)
        self.run_cmd(cmd)

    def align_short_contig_minimap2_in_bam(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        cmd = "{0} -x sr --cs -a -t {1} {2} {3} | samtools view -hSb - | " \
              "samtools sort -o {4} -".format(global_values.MINIMAP2, n_jobs, sf_ref, sf_contig, sf_algnmt)
        self.run_cmd(cmd)
        cmd = "samtools index {0}".format(sf_algnmt)
        self.run_cmd(cmd)

    def align_short_contig_bwa(self, sf_ref, sf_contig, n_jobs, sf_algnmt):
        if os.path.isfile(sf_ref) == False:
            return
        sf_bwt = sf_ref + ".bwt"
        if os.path.isfile(sf_bwt) == False:
            cmd = "{0} index {1}".format(global_values.BWA_PATH, sf_ref)
            self.run_cmd(cmd)
        cmd = "{0} mem -t {1} {2} {3} > {4}".format(global_values.BWA_PATH, n_jobs, sf_ref, sf_contig, sf_algnmt)
        self.run_cmd(cmd)
####
    def run_align_flank_to_contig_by_chrm(self, record):
        chrm = record[0]
        working_folder = record[1]
        sf_sites = record[2]

        with open(sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                tmp_chrm = fields[0]
                if tmp_chrm != chrm:
                    continue
                tmp_pos = fields[1]

                sf_asm = working_folder + "{0}/{1}_{2}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos)
                sf_flank = working_folder + '{0}/{1}_{2}_flanks.fa'.format(global_values.FLANK_FOLDER, chrm, tmp_pos)
                if os.path.exists(sf_asm) == False or os.path.exists(sf_flank) == False:
                    continue
                if os.stat(sf_asm).st_size == 0:
                    continue
                sf_algnmt_folder = working_folder + global_values.MAP_FOLDER
                if os.path.exists(sf_algnmt_folder) == False:
                    cmd = "mkdir {0}".format(sf_algnmt_folder)
                    self.run_cmd(cmd)
                sf_algnmt = "{0}/{1}_{2}.sam".format(sf_algnmt_folder, chrm, tmp_pos)
                self.align_short_contig_bwa(sf_asm, sf_flank, 1, sf_algnmt)

    def align_flanks_to_contig(self, sf_sites):
        l_records = []
        m_chrms = {}
        with open(sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                chrm = fields[0]
                m_chrms[chrm] = 1
        for chrm in m_chrms:
            l_records.append((chrm, self.working_folder, sf_sites))

        pool = Pool(self.n_jobs)
        pool.map(unwrap_align_contig, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()

    ###align flank to phased contigs by chromosome
    def run_align_flank_to_phased_contig_by_chrm(self, record):
        chrm = record[0]
        working_folder = record[1]
        sf_sites = record[2]

        with open(sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                tmp_chrm = fields[0]
                if tmp_chrm != chrm:
                    continue
                tmp_pos = fields[1]

                sf_flank = working_folder + '{0}/{1}~{2}_flanks.fa'.format(global_values.FLANK_FOLDER, chrm, tmp_pos)
                #print sf_flank
                if os.path.exists(sf_flank) == False:
                    continue
                sf_algnmt_folder = working_folder + global_values.MAP_FOLDER
                if os.path.exists(sf_algnmt_folder) == False:
                    cmd = "mkdir {0}".format(sf_algnmt_folder)
                    self.run_cmd(cmd)
                ###all the reads

                sf_asm_all = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos, global_values.ALL_HAP)
                print(sf_asm_all)
                if os.path.exists(sf_asm_all) != False and os.stat(sf_asm_all).st_size != 0:  ####
                    sf_algnmt_all = "{0}/{1}_{2}_{3}.sam".format(sf_algnmt_folder, chrm, tmp_pos, global_values.ALL_HAP)
                    # print sf_asm_all
                    # print sf_flank
                    self.align_short_contigs_minimap2_v2_sam(sf_asm_all, sf_flank, 1, sf_algnmt_all)
                ###haplotype 1
                sf_asm_hap1 = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos, global_values.HAP1)
                if os.path.exists(sf_asm_hap1) != False and os.stat(sf_asm_hap1).st_size != 0:  ####
                    sf_algnmt1 = "{0}/{1}_{2}_{3}.sam".format(sf_algnmt_folder, chrm, tmp_pos, global_values.HAP1)
                    self.align_short_contigs_minimap2_v2_sam(sf_asm_hap1, sf_flank, 1, sf_algnmt1)
                ###haplotype 2
                sf_asm_hap2 = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos, global_values.HAP2)
                if os.path.exists(sf_asm_hap2) != False and os.stat(sf_asm_hap2).st_size != 0:  ####
                    sf_algnmt2 = "{0}/{1}_{2}_{3}.sam".format(sf_algnmt_folder, chrm, tmp_pos, global_values.HAP2)
                    self.align_short_contigs_minimap2_v2_sam(sf_asm_hap2, sf_flank, 1, sf_algnmt2)
                ###unknown haplotype
                sf_asm_hap_unknown = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos,
                                                                                         global_values.HAP_UNKNOWN)
                if os.path.exists(sf_asm_hap_unknown) != False and os.stat(sf_asm_hap_unknown).st_size != 0:  ####
                    sf_algnmt_unknown = "{0}/{1}_{2}_{3}.sam".format(sf_algnmt_folder, chrm, tmp_pos, global_values.HAP_UNKNOWN)
                    self.align_short_contigs_minimap2_v2_sam(sf_asm_hap_unknown, sf_flank, 1, sf_algnmt_unknown)
                ###discord reads
                sf_asm_hap_discord = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos,
                                                                                         global_values.HAP_DISCORD)
                if os.path.exists(sf_asm_hap_discord) != False and os.stat(sf_asm_hap_discord).st_size != 0:  ####
                    sf_algnmt_disc = "{0}/{1}_{2}_{3}.sam".format(sf_algnmt_folder, chrm, tmp_pos, global_values.HAP_DISCORD)
                    self.align_short_contigs_minimap2_v2_sam(sf_asm_hap_discord, sf_flank, 1, sf_algnmt_disc)

    ###align flank to phased contig
    def align_flanks_to_phased_contig(self, sf_sites):
        l_records = []
        m_chrms = {}
        with open(sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                chrm = fields[0]
                m_chrms[chrm] = 1
        print(m_chrms) ###########################################################################
        for chrm in m_chrms:
            l_records.append((chrm, self.working_folder, sf_sites))
            #self.run_align_flank_to_phased_contig_by_chrm((chrm, self.working_folder, sf_sites))
        pool = Pool(self.n_jobs)
        pool.map(unwrap_align_phased_contig, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()

####
    ####align the flank to contigs specified in the l_rcds
    #each record in format (sf_asm, sf_flanks, sf_algnmt, ins_chrm, ins_pos)
    def align_flanks_to_contig_2(self, l_rcds):
        pool = Pool(self.n_jobs)
        pool.map(unwrap_align_flanks_to_contig, list(zip([self] * len(l_rcds), l_rcds)), 1)
        pool.close()
        pool.join()
#
    ####align the flank to contigs specified in the l_rcds
    #each record in format (sf_asm, sf_flanks, sf_algnmt, ins_chrm, ins_pos)
    def align_contig_to_target_ref(self, l_rcds):
        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_align_contig_to_target_seq, list(zip([self] * len(l_rcds), l_rcds)), 1)
        pool.close()
        pool.join()

    def cal_map_ratio(self, l_cigar, flank_length):
        cnt_map = 0
        for cigar in l_cigar:
            cigar_opr = int(cigar[0])
            cigar_lth = int(cigar[1])
            if cigar_opr == 0:
                cnt_map += cigar_lth
        return float(cnt_map) / float(flank_length), cnt_map

    # if one site satisfy the following two conditions, then they are marked as non-TEs
    # 1. both flank regions are full mapped to one contig
    # 2. and no gap between the two flank regions
    def run_filter_out_non_TE_from_asm_by_chrm(self, record):
        sf_sites = record[0]
        select_chrm = record[1]
        flank_length = int(record[2])
        f_map_cutoff = float(record[3])
        i_slack = int(record[4])
        sf_chrm_out = record[5]

        with open(sf_sites) as fin_sites, open(sf_chrm_out, "w") as fout_chrm_true_positive:
            for line in fin_sites:
                fields = line.split()
                chrm = fields[0]
                if chrm != select_chrm:
                    continue
                pos = int(fields[1])

                b_left_mapped = False
                b_right_mapped = False
                b_left_rc = False
                b_right_rc = False
                i_left_pos = 0
                i_right_pos = 100000000000
                r_ref = "a"
                l_ref = "b"

                sf_algnmt_folder = self.working_folder + global_values.MAP_FOLDER
                sf_algnmt = "{0}/{1}_{2}.sam".format(sf_algnmt_folder, chrm, pos)
                if os.path.isfile(sf_algnmt) == False:
                    continue

                # print sf_algnmt  #####################################################################################
                try:
                    samfile = pysam.AlignmentFile(sf_algnmt, "r")  # read in the sam file
                    for algnmt in samfile.fetch():  # check each alignment, and find "left" and "right" flanks
                        if algnmt.is_secondary or algnmt.is_supplementary:
                            continue
                        if algnmt.is_unmapped == True:  # unmapped
                            continue
                        if algnmt.is_duplicate == True:  ##duplciate
                            continue

                        ##get the mapq, map-position and cigar information
                        mapq = int(algnmt.mapping_quality)
                        l_cigar = algnmt.cigar
                        mpos = int(algnmt.reference_start)
                        f_map_ratio, cnt_map = self.cal_map_ratio(l_cigar, flank_length)
                        if f_map_ratio < f_map_cutoff:
                            continue
                        if algnmt.query_name == global_values.LEFT_FLANK:
                            b_left_mapped = True
                            if algnmt.is_reverse == True:
                                b_left_rc = True
                            i_left_pos = int(mpos)
                            l_ref = algnmt.reference_name
                        elif algnmt.query_name == global_values.RIGHT_FLANK:
                            b_right_mapped = True
                            if algnmt.is_reverse == True:
                                b_right_rc = True
                            i_right_pos = int(mpos)
                            r_ref = algnmt.reference_name
                except ValueError:
                    print(sf_algnmt, "is empty")

                if b_right_mapped == False or b_left_mapped == False:  ##both should be fully mapped
                    fout_chrm_true_positive.write(line)
                    continue
                if l_ref != r_ref:  ##both should be aligned to same contig
                    fout_chrm_true_positive.write(line)
                    continue
                if b_right_rc != b_left_rc:  ##alignment direction should be same
                    fout_chrm_true_positive.write(line)
                    continue

                if abs(i_right_pos - i_left_pos) >= (flank_length + i_slack):  ##left and right are concatenate
                    fout_chrm_true_positive.write(line)

    def filter_out_non_TE_from_asm(self, sf_sites, flank_length, f_map_cutoff, i_slack, sf_kept_sites):
        l_records = []
        m_chrms = {}
        with open(sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                chrm = fields[0]
                m_chrms[chrm] = 1
        for chrm in m_chrms:
            sf_chrm_out = self.working_folder + global_values.FILTER_FOLDER + "/"
            if os.path.isdir(sf_chrm_out) == False:
                cmd = "mkdir {0}".format(sf_chrm_out)
                self.run_cmd(cmd)
            sf_chrm_out += "{0}.filtered".format(chrm)
            record = (sf_sites, chrm, flank_length, f_map_cutoff, i_slack, sf_chrm_out)
            l_records.append(record)

            # self.run_filter_out_non_TE_from_asm_by_chrm(record) ######################################################

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_filter_by_asm, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()

        with open(sf_kept_sites, "w") as fout_final:
            for chrm in m_chrms:
                sf_chrm_list = self.working_folder + global_values.FILTER_FOLDER + "/" + "{0}.filtered".format(chrm)
                if os.path.isfile(sf_chrm_list) == False:
                    continue
                # print sf_chrm_list ###################################################################################
                with open(sf_chrm_list) as fin_chrm_list:
                    for line in fin_chrm_list:
                        fout_final.write(line)

    # parse out the inserted part, from the flank region alignments
    # left_pos and right_pos are the map position on the contigs
    def get_inserted_part_v2(self, sf_contig, s_contig_left, s_contig_right, i_left_pos, i_left_mapped,
                             bl_rc, i_right_pos, i_right_mapped, br_rc):
        s_seq1 = ""
        s_seq2 = ""
        try:
            pysam.faidx(sf_contig)# index the fasta file index
            f_fa = pysam.FastaFile(sf_contig)
            if s_contig_left == s_contig_right:  # aligned to the same contig
                istart = i_left_pos + i_left_mapped
                iend = i_right_pos
                if bl_rc == br_rc and bl_rc == True:  # reverse complementary
                    istart = i_right_pos + i_right_mapped
                    iend = i_left_pos
                if istart > iend:
                    print("Error: start position {0} is larger than end position {1}".format(istart, iend))
                    return s_seq1, s_seq2
                s_seq1 = f_fa.fetch(s_contig_left, istart, iend)
            else:
                # for left flank region
                if i_left_pos >= 0:
                    if bl_rc == True:
                        s_seq1 = f_fa.fetch(s_contig_left, 0, i_left_pos)  # get the prefix part
                    else:
                        s_seq1 = f_fa.fetch(s_contig_left, i_left_pos + i_left_mapped)  # get the suffix part

                # for right flank region
                if i_right_pos >= 0:
                    if br_rc == True:
                        s_seq2 = f_fa.fetch(s_contig_right, i_right_pos + i_right_mapped)
                    else:
                        s_seq2 = f_fa.fetch(s_contig_right, 0, i_right_pos)
            f_fa.close()
        except pysam.SamtoolsError:
            print('{0} cannot be indexed by samtools faidx\n'.format(sf_contig))
        except ValueError:
            print('Cannot open {0}\n'.format(sf_contig))
        return s_seq1, s_seq2

####
####
    # This is a strict version, that require the left and right aligned flanks should be:
    # most region are aligned, aligned to the same contig, of same orientation
    def is_qualified_TE_insertion_strict_version_v2(self, sf_contig, sf_algnmt, flank_length, f_map_cutoff, i_slack, s_open_fmt="r"):
        b_qualified = False
        b_left_mapped = False
        b_right_mapped = False
        b_left_rc = False
        b_right_rc = False
        i_left_pos = 0
        i_right_pos = 100000000000
        s_mark_l = "a"
        s_mark_r = "b"
        r_ref = s_mark_r
        l_ref = s_mark_l
        i_left_mapped = flank_length
        i_right_mapped = flank_length

        try:
            samfile = pysam.AlignmentFile(sf_algnmt, s_open_fmt)  # read in the sam file
            for algnmt in samfile.fetch():  # check each alignment, and find "left" and "right" flank
                if algnmt.is_secondary or algnmt.is_supplementary:
                    continue
                if algnmt.is_unmapped == True:  # unmapped
                    continue
                if algnmt.is_duplicate == True:  ##duplciate
                    continue

                ##get the mapq, map-position and cigar information
                mapq = int(algnmt.mapping_quality)
                b_l_clip = False  # left clip
                b_r_clip = False  # right clip
                l_cigar = algnmt.cigar
                # the clip part should be long (>99bp)
                if l_cigar[0][0] == 4 and l_cigar[0][1] >= global_values.TEI_ON_CNS_CLIP_LENTH:
                    b_l_clip = True
                if l_cigar[-1][0] == 4 and l_cigar[-1][1] >= global_values.TEI_ON_CNS_CLIP_LENTH:
                    b_r_clip = True
                mpos = int(algnmt.reference_start)
                f_map_ratio, cnt_map = self.cal_map_ratio(l_cigar, flank_length)  # mapped ratio over all sequences
                if f_map_ratio < f_map_cutoff:
                    continue
                if algnmt.query_name == global_values.LEFT_FLANK:
                    if algnmt.is_reverse == True:
                        b_left_rc = True
                    # not reverse complementary, but right clipped, this is not allowed!
                    if b_left_rc == False and b_r_clip == True:
                        continue
                    # reverse complementary, but left clipped, this is not allowed!
                    if b_left_rc == True and b_l_clip == True:
                        continue
                    b_left_mapped = True
                    i_left_pos = int(mpos)
                    l_ref = algnmt.reference_name
                    i_left_mapped = cnt_map
                elif algnmt.query_name == global_values.RIGHT_FLANK:
                    if algnmt.is_reverse == True:
                        b_right_rc = True
                    if b_right_rc == False and b_l_clip == True:
                        continue
                    if b_right_rc == True and b_r_clip == True:
                        continue
                    b_right_mapped = True
                    i_right_pos = int(mpos)
                    r_ref = algnmt.reference_name
                    i_right_mapped = cnt_map
        except ValueError:
            print(sf_algnmt, "is empty")

        if b_right_mapped == False or b_left_mapped == False:  ##both should be fully mapped
            return False, "", ""
        if l_ref != r_ref:  ##both should be aligned to same contig
            return False, "", ""
        if b_right_rc != b_left_rc:  ##alignment direction should be same
            return False, "", ""

        istart = i_left_pos + i_left_mapped
        iend = i_right_pos
        if b_right_rc == True:  # reverse complementary
            istart = i_right_pos + i_right_mapped
            iend = i_left_pos
        if istart > iend:
            print("Error: start position {0} is larger than end position {1}".format(istart, iend))
            return False, "", ""

        if (iend - istart) < i_slack:  ##left and right are concatenate
            return False, "", ""

        ##get the inserted part, return it to save into a file, then align all of them togethor.
        s_seq1, s_seq2 = self.get_inserted_part_v2(sf_contig, l_ref, r_ref, i_left_pos, i_left_mapped, b_left_rc,
                                                   i_right_pos, i_right_mapped, b_right_rc)
        return True, s_seq1, s_seq2

    # this version, we allow flank regions are aligned to different contigs
    ###and also allow flank regions are clipped mapped
    def is_qualified_TE_insertion_loosen_version_v2(self, sf_contig, sf_algnmt, flank_length, f_map_cutoff, i_slack):
        b_left_mapped = False
        b_right_mapped = False
        b_left_rc = False
        b_right_rc = False
        i_left_pos = 0
        i_right_pos = 100000000000
        s_mark_l = "a"
        s_mark_r = "b"
        r_ref = s_mark_r
        l_ref = s_mark_l
        b_same_contig = False
        i_left_mapped = flank_length
        i_right_mapped = flank_length
        try:
            samfile = pysam.AlignmentFile(sf_algnmt, "r")  # read in the sam file
            for algnmt in samfile.fetch():  # check each alignment, and find "left" and "right" flank
                if algnmt.is_secondary or algnmt.is_supplementary:
                    continue
                if algnmt.is_unmapped == True:  # unmapped
                    continue
                if algnmt.is_duplicate == True:  ##duplciate
                    continue

                ##get the mapq, map-position and cigar information
                mapq = int(algnmt.mapping_quality)
                l_cigar = algnmt.cigar
                b_l_clip = False  # left clip
                b_r_clip = False  # right clip
                if l_cigar[0][0] == 4 and l_cigar[0][
                    1] >= global_values.TEI_ON_CNS_CLIP_LENTH:  # the clip part should be long (>74bp)
                    b_l_clip = True
                if l_cigar[-1][0] == 4 and l_cigar[-1][1] >= global_values.TEI_ON_CNS_CLIP_LENTH:  #
                    b_r_clip = True
                mpos = int(algnmt.reference_start)
                f_map_ratio, cnt_map = self.cal_map_ratio(l_cigar, flank_length)  # mapped ratio over all sequences
                if f_map_ratio < f_map_cutoff:
                    continue
                if algnmt.query_name == global_values.LEFT_FLANK:
                    if algnmt.is_reverse == True:
                        b_left_rc = True
                    # not reverse complementary, but right clipped, this is not allowed!
                    if b_left_rc == False and b_r_clip == True:
                        continue
                    # reverse complementary, but left clipped, this is not allowed!
                    if b_left_rc == True and b_l_clip == True:
                        continue
                    b_left_mapped = True

                    i_left_pos = int(mpos)
                    l_ref = algnmt.reference_name
                    i_left_mapped = cnt_map
                elif algnmt.query_name == global_values.RIGHT_FLANK:
                    if algnmt.is_reverse == True:
                        b_right_rc = True
                    if b_right_rc == False and b_l_clip == True:
                        continue
                    if b_right_rc == True and b_r_clip == True:
                        continue
                    b_right_mapped = True

                    i_right_pos = int(mpos)
                    r_ref = algnmt.reference_name
                    i_right_mapped = cnt_map
        except ValueError:
            print(sf_algnmt, "is empty")

        if b_right_mapped == False and b_left_mapped == False:  ##one of the flank should be fully mapped
            return False, "", "", b_same_contig

        if l_ref == r_ref:  # aligned to same contig
            if b_left_rc != b_right_rc:  # aligned orientation are different, then false
                return False, "", "", b_same_contig
            else:
                istart = i_left_pos + i_left_mapped
                iend = i_right_pos
                if b_right_rc == True:  # reverse complementary
                    istart = i_right_pos + i_right_mapped
                    iend = i_left_pos
                if istart > iend:
                    print("Error: start position {0} is larger than end position {1}".format(istart, iend))
                    return False, "", "", b_same_contig

                if (iend - istart) < i_slack:  ##left and right are concatenate
                    return False, "", "", b_same_contig
                b_same_contig = True
        if l_ref == s_mark_l:
            i_left_pos = -1
        if r_ref == s_mark_r:
            i_right_pos = -1
        ##get the inserted part, return it to save into a file, then align all of them togethor.
        s_seq1, s_seq2 = self.get_inserted_part_v2(sf_contig, l_ref, r_ref, i_left_pos, i_left_mapped, b_left_rc,
                                                   i_right_pos, i_right_mapped, b_right_rc)
        return True, s_seq1, s_seq2, b_same_contig

    ####
    ####
    def run_select_TEI_from_algnmt_by_chrm(self, record):
        sf_sites = record[0]
        select_chrm = record[1]
        flank_length = int(record[2])
        f_map_cutoff = float(record[3])
        i_slack = int(record[4])
        working_folder = record[5]
        sf_repeat_copies = record[6]
        sf_chrm_out = record[7]

        homozygous = "homoTEI"
        all_left = "allL"
        all_right = "allR"
        haplotype1_left = "hap1L"
        haplotype1_right = "hap1R"
        haplotype1 = "hap1"
        haplotype2_left = "hap2L"
        haplotype2_right = "hap2R"
        haplotype2 = "hap2"

        unknown_type_left = "unknownL"
        unknown_type_right = "unknownR"
        unknown_type = "unknown"

        disc_type_left = "discordL"
        disc_type_right = "discordR"
        disc_type = "discord"

        mini_TEI_lenth = 35  #################################################################################hard code!!!

        sf_TEI_seq_folder = working_folder + global_values.TEI_SEQ_FOLDER
        if os.path.exists(sf_TEI_seq_folder) == False:
            return
        sf_TEI_seq_chrm = sf_TEI_seq_folder + "/" + "{0}_tei_seqs.fa".format(select_chrm)
        with open(sf_sites) as fin_sites, open(sf_TEI_seq_chrm, "w") as fout_tei_seqs:
            for line in fin_sites:  ###for each candidate site
                fields = line.split()
                chrm = fields[0]
                if chrm != select_chrm:
                    continue
                tmp_pos = int(fields[1])

                sf_algnmt_folder = working_folder + global_values.MAP_FOLDER
                # 1. First, check the combined contigs (assembled from all the reads)
                sf_algnmt_all = "{0}/{1}_{2}_{3}.sam".format(sf_algnmt_folder, chrm, tmp_pos, global_values.ALL_HAP)
                if os.path.isfile(sf_algnmt_all) == False:
                    continue
                sf_asm_all = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos, global_values.ALL_HAP)
                if os.path.exists(sf_asm_all) == False or os.stat(sf_asm_all).st_size == 0:
                    continue
                b_qualifed, seq1, seq2 = self.is_qualified_TE_insertion_strict_version_v2(sf_asm_all, sf_algnmt_all,
                                                                                          flank_length, f_map_cutoff,
                                                                                          i_slack)
                ###Note, here use global_values.SEPERATOR to seperate chrm and pos, in case chrm contains "_"
                s_site = "{0}{1}{2}".format(select_chrm, global_values.SEPERATOR, tmp_pos)
                if b_qualifed == True and seq1 != "" and len(seq1) >= mini_TEI_lenth:
                    fout_tei_seqs.write(">" + s_site + "_" + homozygous + "\n")
                    fout_tei_seqs.write(seq1 + "\n")
                    continue  # no need to check other haplotypes
                ####
                ####Here some cases that: only in one end of the merged assembly, with the L1 attached.
                ### So need to use the loosen version for the merged asm.
                ####
                if os.path.isfile(sf_algnmt_all) != False and os.path.isfile(sf_asm_all) != False:
                    b_qualifed, seq1, seq2, bsame = self.is_qualified_TE_insertion_loosen_version_v2(sf_asm_all,
                                                                                                     sf_algnmt_all,
                                                                                                     flank_length,
                                                                                                     f_map_cutoff,
                                                                                                     i_slack)
                    if b_qualifed == True:
                        if seq1 != "" and len(seq1) >= mini_TEI_lenth:
                            fout_tei_seqs.write(">" + s_site + "_" + all_left + "\n")
                            fout_tei_seqs.write(seq1 + "\n")
                        if seq2 != "" and len(seq2) >= mini_TEI_lenth:
                            fout_tei_seqs.write(">" + s_site + "_" + all_right + "\n")
                            fout_tei_seqs.write(seq2 + "\n")

                # 2. check hap1 contig alignments
                sf_algnmt_hap1 = "{0}/{1}_{2}_{3}.sam".format(sf_algnmt_folder, chrm, tmp_pos, global_values.HAP1)
                sf_asm_hap1 = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos,
                                                                                  global_values.HAP1)
                if os.path.isfile(sf_algnmt_hap1) != False and os.path.isfile(sf_asm_hap1) != False:
                    b_qualifed, seq1, seq2, bsame = self.is_qualified_TE_insertion_loosen_version_v2(sf_asm_hap1,
                                                                                                     sf_algnmt_hap1,
                                                                                                     flank_length,
                                                                                                     f_map_cutoff,
                                                                                                     i_slack)
                    if b_qualifed == True:
                        if bsame == True:
                            if seq1 != "" and len(seq1) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + haplotype1 + "\n")
                                fout_tei_seqs.write(seq1 + "\n")
                        else:
                            if seq1 != "" and len(seq1) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + haplotype1_left + "\n")
                                fout_tei_seqs.write(seq1 + "\n")
                            if seq2 != "" and len(seq2) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + haplotype1_right + "\n")
                                fout_tei_seqs.write(seq2 + "\n")

                # 3. check hap2 contigs alignments
                sf_algnmt_hap2 = "{0}/{1}_{2}_{3}.sam".format(sf_algnmt_folder, chrm, tmp_pos, global_values.HAP2)
                sf_asm_hap2 = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos,
                                                                                  global_values.HAP2)
                if os.path.isfile(sf_algnmt_hap2) != False and os.path.isfile(sf_asm_hap2) != False:
                    b_qualifed, seq1, seq2, bsame = self.is_qualified_TE_insertion_loosen_version_v2(sf_asm_hap2,
                                                                                                     sf_algnmt_hap2,
                                                                                                     flank_length,
                                                                                                     f_map_cutoff,
                                                                                                     i_slack)
                    if b_qualifed == True:
                        if bsame == True:
                            if seq1 != "" and len(seq1) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + haplotype2 + "\n")
                                fout_tei_seqs.write(seq1 + "\n")
                        else:
                            if seq1 != "" and len(seq1) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + haplotype2_left + "\n")
                                fout_tei_seqs.write(seq1 + "\n")
                            if seq2 != "" and len(seq2) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + haplotype2_right + "\n")
                                fout_tei_seqs.write(seq2 + "\n")

                # 4. check unknown contigs alignments
                sf_algnmt_hap_unknown = "{0}/{1}_{2}_{3}.sam".format(sf_algnmt_folder, chrm, tmp_pos, global_values.HAP_UNKNOWN)
                sf_asm_hap_unknown = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos,
                                                                                         global_values.HAP_UNKNOWN)
                if os.path.isfile(sf_algnmt_hap_unknown) != False and os.path.isfile(sf_asm_hap_unknown) != False:
                    b_qualifed, seq1, seq2, bsame = self.is_qualified_TE_insertion_loosen_version_v2(sf_asm_hap_unknown,
                                                                                                     sf_algnmt_hap_unknown,
                                                                                                     flank_length,
                                                                                                     f_map_cutoff,
                                                                                                     i_slack)
                    if b_qualifed == True:
                        if bsame == True:
                            if seq1 != "" and len(seq1) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + unknown_type + "\n")
                                fout_tei_seqs.write(seq1 + "\n")
                        else:
                            if seq1 != "" and len(seq1) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + unknown_type_left + "\n")
                                fout_tei_seqs.write(seq1 + "\n")
                            if seq2 != "" and len(seq2) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + unknown_type_right + "\n")
                                fout_tei_seqs.write(seq2 + "\n")

                # 5. check discord contigs alignments
                sf_algnmt_hap_disc = "{0}/{1}_{2}_{3}.sam".format(sf_algnmt_folder, chrm, tmp_pos, global_values.HAP_DISCORD)
                sf_asm_hap_disc = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos,
                                                                                      global_values.HAP_DISCORD)
                if os.path.isfile(sf_algnmt_hap_disc) != False and os.path.isfile(sf_asm_hap_disc) != False:
                    b_qualifed, seq1, seq2, bsame = self.is_qualified_TE_insertion_loosen_version_v2(sf_asm_hap_disc,
                                                                                                     sf_algnmt_hap_disc,
                                                                                                     flank_length,
                                                                                                     f_map_cutoff,
                                                                                                     i_slack)
                    if b_qualifed == True:
                        if bsame == True:
                            if seq1 != "" and len(seq1) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + disc_type + "\n")
                                fout_tei_seqs.write(seq1 + "\n")
                        else:
                            if seq1 != "" and len(seq1) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + disc_type_left + "\n")
                                fout_tei_seqs.write(seq1 + "\n")
                            if seq2 != "" and len(seq2) >= mini_TEI_lenth:
                                fout_tei_seqs.write(">" + s_site + "_" + disc_type_right + "\n")
                                fout_tei_seqs.write(seq2 + "\n")
        ####Now, align the parsed out TEI seqs to the repeat copies
        sf_tei_algnmt = sf_TEI_seq_folder + "/" + "{0}_tei_seqs.sam".format(select_chrm)
        # self.align_short_contig_bwa(sf_repeat_copies, sf_TEI_seq_chrm, 1, sf_tei_algnmt)
        self.align_short_contigs_minimap2_v2_sam(sf_repeat_copies, sf_TEI_seq_chrm, 1, sf_tei_algnmt)

        with open(sf_chrm_out, "w") as fout_chrm_true_positive:
            f_full_map_cutoff = 0.5  #################################################################################
            m_selected, m_candidate = self.select_TEI_from_alignment(sf_tei_algnmt, f_full_map_cutoff)
            # for contig_id in m_selected:
            m_final = {}
            for contig_id in m_candidate:
                fields = contig_id.split("_")
                s_pos = "_".join(fields[:-1])
                asm_source = fields[-1]
                if contig_id in m_selected:
                    m_final[s_pos] = (m_selected[contig_id], asm_source, "B")
                else:
                    m_final[s_pos] = (m_candidate[contig_id], asm_source, fields[-1])

            for s_pos in m_final:
                s_pos_fields = s_pos.split(global_values.SEPERATOR)
                fout_chrm_true_positive.write(
                    s_pos_fields[0] + "\t" + s_pos_fields[1] + "\t" + str(m_final[s_pos][0]) + "\t" + m_final[s_pos][1]
                    + "\t" + m_final[s_pos][2] + "\n")


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

    ####
    ####For return value:
    ####1) m_selected: save the candidate sites have both left and right flanks
    ####2) m_selected_candidate: save the candidate sites have either left or right flank
    def select_TEI_from_alignment(self, sf_algnmt, f_full_map_cutoff):
        m_selected = {}
        m_selected_candidate = {}
        try:
            samfile = pysam.AlignmentFile(sf_algnmt, "r")  # read in the sam file
            for algnmt in samfile.fetch():  # check each alignment, and find "left" and "right" flank
                if algnmt.is_secondary or algnmt.is_supplementary:
                    continue
                if algnmt.is_unmapped == True:  # unmapped
                    continue
                if algnmt.is_duplicate == True:  ##duplciate
                    continue

                ##get the cigar information, and check whether fully mapped
                l_cigar = algnmt.cigar
                b_full_map, cnt_map = self.is_fully_mapped(l_cigar, f_full_map_cutoff)  # mapped ratio over all seqs
                if b_full_map == False:
                    continue

                contig_id = algnmt.query_name
                if contig_id[-1] != "L" and contig_id[-1] != "R":
                    m_selected[contig_id] = cnt_map
                    m_selected_candidate[contig_id] = cnt_map
                else:  # have both left and right aligned contig of the same id
                    if contig_id[-1] == "L":
                        s_tmp = contig_id[:-1] + "R"
                        if s_tmp in m_selected_candidate:
                            if contig_id[:-1] in m_selected:
                                if m_selected[contig_id[:-1]] < (m_selected_candidate[s_tmp] + cnt_map):
                                    m_selected[contig_id[:-1]] = m_selected_candidate[s_tmp] + cnt_map
                            else:
                                m_selected[contig_id[:-1]] = m_selected_candidate[s_tmp] + cnt_map
                        m_selected_candidate[contig_id] = cnt_map
                    else:
                        s_tmp = contig_id[:-1] + "L"
                        if s_tmp in m_selected_candidate:
                            if contig_id[:-1] in m_selected:
                                if m_selected[contig_id[:-1]] < (m_selected_candidate[s_tmp] + cnt_map):
                                    m_selected[contig_id[:-1]] = m_selected_candidate[s_tmp] + cnt_map
                            else:
                                m_selected[contig_id[:-1]] = m_selected_candidate[s_tmp] + cnt_map
                        m_selected_candidate[contig_id] = cnt_map
        except ValueError:
            print(sf_algnmt, "is empty")
        return m_selected, m_selected_candidate

    ####
    def validate_TEI_from_phased_asm_algnmt(self, sf_sites, flank_length, f_map_cutoff, i_slack, sf_repeat_copies,
                                            sf_kept_sites):
        l_records = []
        m_chrms = {}
        with open(sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                chrm = fields[0]
                m_chrms[chrm] = 1

        sf_TEI_seq_folder = self.working_folder + global_values.TEI_SEQ_FOLDER  ####create the folder
        if os.path.exists(sf_TEI_seq_folder) == False:
            cmd = "mkdir {0}".format(sf_TEI_seq_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.run_cmd(cmd)

        for chrm in m_chrms:
            sf_chrm_out = self.working_folder + global_values.FILTER_FOLDER + "/"
            if os.path.isdir(sf_chrm_out) == False:
                cmd = "mkdir {0}".format(sf_chrm_out)
                self.run_cmd(cmd)
            sf_chrm_out += "{0}.filtered".format(chrm)
            record = (sf_sites, chrm, flank_length, f_map_cutoff, i_slack, self.working_folder, sf_repeat_copies,
                      sf_chrm_out)
            l_records.append(record)

            #self.run_select_TEI_from_algnmt_by_chrm(record)

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_validate_by_asm, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()

        #merge the seqs of the sites
        sf_tei_seq=sf_kept_sites+".fa"
        with open(sf_kept_sites, "w") as fout_final, open(sf_tei_seq,"w") as fout_tei:
            for chrm in m_chrms:
                sf_chrm_out = self.working_folder + global_values.FILTER_FOLDER + "/"
                sf_chrm_out += "{0}.filtered".format(chrm)
                if os.path.isfile(sf_chrm_out) != False:
                    with open(sf_chrm_out) as fin_chrm:
                        for line in fin_chrm:
                            fout_final.write(line)

                sf_TEI_seq_chrm = sf_TEI_seq_folder + "/" + "{0}_tei_seqs.fa".format(chrm)
                if os.path.isfile(sf_TEI_seq_chrm)==True:
                    with open(sf_TEI_seq_chrm) as fin_tmp:
                        for line in fin_tmp:
                            fout_tei.write(line)

    ####################################################################################################################
    ####for contigs and long reads align to reference ##################################################################
    ####################################################################################################################
    ####merge the contigs of one type (global_values.ALL_HAP, global_values.HAP1, global_values.HAP2, global_values.HAP_UNKNOWN, global_values.HAP_DISCORD) to a single file
    def creat_new_folder_no_exist(self, s_folder):
        if os.path.exists(s_folder) == False:
            cmd = 'mkdir -p {0}'.format(s_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.run_cmd(cmd)
            #

    def save_site_info(self, site_chrm, site_pos, map_pos, query_seq, m_selected, m_seqs):
        if site_chrm not in m_selected:
            m_selected[site_chrm] = {}
            m_seqs[site_chrm] = {}
        if site_pos not in m_selected:
            m_selected[site_chrm][site_pos] = map_pos
            m_seqs[site_chrm][site_pos] = []
            m_seqs[site_chrm][site_pos].append(query_seq)
        else:
            cur_pos = m_selected[site_chrm][site_pos]
            if map_pos < cur_pos:
                m_selected[site_chrm][site_pos] = map_pos
            m_seqs[site_chrm][site_pos].append(query_seq)

            ####

    # save the seq to the dict
    def save_seqs_to_dict(self, site_chrm, site_pos, s_seq, s_dir, m_seqs):
        if site_chrm not in m_seqs:
            m_seqs[site_chrm] = {}
        if site_pos not in m_seqs[site_chrm]:
            m_seqs[site_chrm][site_pos] = []
            m_seqs[site_chrm][site_pos].append((s_seq, s_dir))
        else:
            m_seqs[site_chrm][site_pos].append((s_seq, s_dir))

    # call out the MEIs
    ##Ouput: 1. the masked part, position aligned on consensus
    ##       2. the clipped part, will be used for realignment.
    def call_MEIs_from_masked_algnmt(self, sf_msk_algmt, sf_ref, sf_out_list, sf_seqs, sf_2clip):
        bamfile = pysam.AlignmentFile(sf_msk_algmt, "rb", reference_filename=sf_ref)
        m_selected = {}
        m_seqs = {}
        m_clip_seqs = {}
        iter_algnmts = bamfile.fetch()
        for algnmt in iter_algnmts:
            if algnmt.is_unmapped == True:  # unmapped
                continue
            query_name = algnmt.query_name
            map_pos = algnmt.reference_start
            query_seq = algnmt.query_sequence
            site_fields = query_name.split(global_values.SEPERATOR)
            site_chrm = site_fields[0]
            site_pos = int(site_fields[1])
            s_dir = query_name[-1]  # L or R, direction of the 1st align on ref (before the masking step)
            l_cigar = algnmt.cigar
            if len(l_cigar) < 1:  # wrong alignment
                continue
            if len(l_cigar) == 1 and l_cigar[0][0] == 0:  ##fully mapped
                if len(query_seq) < global_values.MIN_CONTIG_CLIP_LENTH:
                    continue
                self.save_site_info(site_chrm, site_pos, map_pos, query_seq, m_selected, m_seqs)

            elif l_cigar[0][0] == 4 and l_cigar[-1][0] == 4:  # both end clip
                l_clip_lenth = l_cigar[0][1]
                r_clip_lenth = l_cigar[-1][1]
                mapped_seq = query_seq[l_clip_lenth: r_clip_lenth]
                if len(mapped_seq) < global_values.MIN_CONTIG_CLIP_LENTH:
                    continue
                self.save_site_info(site_chrm, site_pos, map_pos, mapped_seq, m_selected, m_seqs)
                l_clip_seq = query_seq[:l_clip_lenth]
                self.save_seqs_to_dict(site_chrm, site_pos, l_clip_seq, s_dir, m_clip_seqs)  # save the left clip seq
                r_clip_seq = query_seq[-1 * r_clip_lenth:]
                self.save_seqs_to_dict(site_chrm, site_pos, r_clip_seq, s_dir, m_clip_seqs)  # save the right clip seq
            elif l_cigar[0][0] == 4:  # only left clipped
                l_clip_lenth = l_cigar[0][1]
                clip_seq = query_seq[:l_clip_lenth]
                mapped_seq = query_seq[l_clip_lenth:]
                if len(mapped_seq) < global_values.MIN_CONTIG_CLIP_LENTH:
                    continue
                self.save_site_info(site_chrm, site_pos, map_pos, mapped_seq, m_selected, m_seqs)
                self.save_seqs_to_dict(site_chrm, site_pos, clip_seq, s_dir, m_clip_seqs)  # save the left clip seq
            elif l_cigar[-1][0] == 4:  # right clipped
                r_clip_lenth = l_cigar[-1][1]
                clip_seq = query_seq[r_clip_lenth:]
                mapped_seq = query_seq[:r_clip_lenth]
                if len(mapped_seq) < global_values.MIN_CONTIG_CLIP_LENTH:
                    continue
                self.save_site_info(site_chrm, site_pos, map_pos, mapped_seq, m_selected, m_seqs)
                self.save_seqs_to_dict(site_chrm, site_pos, clip_seq, s_dir, m_clip_seqs)  # save the right clip seq
        bamfile.close()

        ####save the masked part and clipped part into file
        with open(sf_out_list, "w") as fout_rslt, open(sf_seqs, "w") as fout_seqs, open(sf_2clip, "w") as fout_clip:
            for site_chrm in m_selected:
                for site_pos in m_selected[site_chrm]:
                    sinfo = "{0}\t{1}\t{2}\n".format(site_chrm, site_pos, m_selected[site_chrm][site_pos])
                    fout_rslt.write(sinfo)
                    icnt = 0
                    for s_seq in m_seqs[site_chrm][site_pos]:
                        shead = ">{0}{1}{2}{3}{4}\n".format(site_chrm, global_values.SEPERATOR, site_pos,
                                                            global_values.SEPERATOR, icnt)
                        icnt += 1
                        fout_seqs.write(shead)
                        fout_seqs.write(s_seq + "\n")

                    if site_chrm in m_clip_seqs and site_pos in m_clip_seqs[site_chrm]:
                        icnt = 0
                        for (s_seq, s_dir) in m_clip_seqs[site_chrm][site_pos]:
                            ####
                            shead = ">{0}{1}{2}{3}{4}{5}{6}\n".format(site_chrm, global_values.SEPERATOR, site_pos,
                                                                      global_values.SEPERATOR, s_dir,
                                                                      global_values.SEPERATOR, icnt)
                            icnt += 1
                            fout_clip.write(shead)
                            fout_clip.write(s_seq + "\n")

    ####
    # get out the clipped part and align to repeat consensus to mask out the repeats part
    def call_MEIs_from_group_contigs(self, sf_ref, sf_cns, s_working_folder, stype, sf_in, sf_out, sf_seqs):
        s_algnmt_folder = s_working_folder + global_values.MAP_FOLDER + "/"
        sf_hap_bam = s_algnmt_folder + stype + ".sorted.bam"
        if os.path.isfile(sf_hap_bam) is False:
            return
        ####
        s_seq_folder = s_working_folder + global_values.TEI_SEQ_FOLDER + "/"
        self.creat_new_folder_no_exist(s_seq_folder)

        lrclip = LContigClipReadInfo(sf_hap_bam, self.n_jobs, sf_ref, s_seq_folder)
        islack = 200
        sf_clip_fa = s_seq_folder + stype + ".contig_clipped.fa"
        lrclip.collect_clipped_parts(sf_in, islack, sf_clip_fa)
        # realign the clipped part to the repeat copies --second stage realign [mask the contig]
        sf_clip_bam = s_seq_folder + stype + ".contig_2_cns.bam"
        self.align_short_contigs_minimap2_v2(sf_cns, sf_clip_fa, self.n_jobs, sf_clip_bam)
        sf_2clip = s_seq_folder + stype + ".contig_2nd_clip.fa"
        self.call_MEIs_from_masked_algnmt(sf_clip_bam, sf_ref, sf_out, sf_seqs, sf_2clip)
        # realign the clipped part after masked by repeat consensus --thrid stage realign [align the unmasked part]
        ###One more step here !!!!!!!!!!!!!!!!
        ###align the second  clipped part
        sf_2clip_algnmt = s_seq_folder + stype + ".2nd_clip_2_ref.bam"
        self.align_short_contigs_minimap2_v2(sf_ref, sf_2clip, self.n_jobs, sf_2clip_algnmt)
###
    ####
    ####
    def add_to_final_rslt(self, m_list, m_seqs, sf_list, sf_seq):
        with open(sf_list) as fin_list:
            for line in fin_list:
                fields = line.split()

    def call_final_list_from_hap(self, sf_list, gntp, m_final_list):
        with open(sf_list) as fin_list:
            for line in fin_list:
                fields = line.split()
                chrm = fields[0]
                pos = fields[1]
                if chrm not in m_final_list:
                    m_final_list[chrm] = {}
                if pos not in m_final_list[chrm]:
                    m_final_list[chrm][pos] = {}
                m_final_list[chrm][pos][gntp] = 1

    ####
    def call_MEIs_from_all_group_contigs(self, sf_sites, sf_ref, sf_cns, s_working_folder, sf_out_sites, sf_out_seqs):
        s_seq_folder = s_working_folder + global_values.TEI_SEQ_FOLDER + "/"
        self.creat_new_folder_no_exist(s_seq_folder)
        m_final_list = {}
        # m_final_seqs = {}

        ####Hap1
        sf_out_hap1 = s_seq_folder + global_values.HAP1 + ".candidate.list"  ###candidate list called from hap1
        sf_seqs_hap1 = s_seq_folder + global_values.HAP1 + ".seqs.fa"
        self.call_MEIs_from_group_contigs(sf_ref, sf_cns, s_working_folder, global_values.HAP1, sf_sites, sf_out_hap1, sf_seqs_hap1)
        self.call_final_list_from_hap(sf_out_hap1, "1/0", m_final_list)

        ####Hap2
        sf_out_hap2 = s_seq_folder + global_values.HAP2 + ".candidate.list"  ###candidate list called from hap2
        sf_seqs_hap2 = s_seq_folder + global_values.HAP2 + ".seqs.fa"
        self.call_MEIs_from_group_contigs(sf_ref, sf_cns, s_working_folder, global_values.HAP2, sf_sites, sf_out_hap2, sf_seqs_hap2)
        self.call_final_list_from_hap(sf_out_hap2, "0/1", m_final_list)

        ####Hap_all
        sf_out_hap_all = s_seq_folder + global_values.ALL_HAP + ".candidate.list"  ###candidate list called from all hap
        sf_seqs_hap_all = s_seq_folder + global_values.ALL_HAP + ".seqs.fa"
        self.call_MEIs_from_group_contigs(sf_ref, sf_cns, s_working_folder, global_values.ALL_HAP, sf_sites, sf_out_hap_all,
                                          sf_seqs_hap_all)
        self.call_final_list_from_hap(sf_out_hap_all, "1/1", m_final_list)

        ####Hap_unkown
        sf_out_hap_uk = s_seq_folder + global_values.HAP_UNKNOWN + ".candidate.list"  ###candidate list called from unkown hap
        sf_seqs_hap_uk = s_seq_folder + global_values.HAP_UNKNOWN + ".seqs.fa"
        self.call_MEIs_from_group_contigs(sf_ref, sf_cns, s_working_folder, global_values.HAP_UNKNOWN, sf_sites, sf_out_hap_uk,
                                          sf_seqs_hap_uk)
        self.call_final_list_from_hap(sf_out_hap_uk, "un", m_final_list)

        ####Hap_discord
        sf_out_hap_disc = s_seq_folder + global_values.HAP_DISCORD + ".candidate.list"  ###candidate list called from disc hap
        sf_seqs_hap_disc = s_seq_folder + global_values.HAP_DISCORD + ".seqs.fa"
        self.call_MEIs_from_group_contigs(sf_ref, sf_cns, s_working_folder, global_values.HAP_DISCORD, sf_sites, sf_out_hap_disc,
                                          sf_seqs_hap_disc)
        self.call_final_list_from_hap(sf_out_hap_disc, "disc", m_final_list)

        ###merge the results
        with open(sf_out_sites, "w")  as fout_sites:
            for chrm in m_final_list:
                for pos in m_final_list[chrm]:
                    s_gntp = ""
                    for gntp_tmp in m_final_list[chrm][pos]:
                        s_gntp += (gntp_tmp + "|")
                    s_info = "{0}\t{1}\t{2}\n".format(chrm, pos, s_gntp)
                    fout_sites.write(s_info)

        # with open(sf_out_seqs, "w") as fout_seqs:
        cmd = "cat {0} {1} {2} {3} {4}".format(sf_seqs_hap1, sf_seqs_hap2, sf_seqs_hap_all, sf_seqs_hap_uk,
                                                     sf_seqs_hap_disc)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.run_cmd_with_out(cmd, sf_out_seqs)

    #####
    #####
    def merge_contigs_by_type(self, sf_sites, stype, working_folder, sf_out):
        with open(sf_out, "w") as fout_fa, open(sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                chrm = fields[0]
                tmp_pos = fields[1]
                sf_asm = working_folder + "{0}/{1}_{2}/{3}/contig.fa".format(global_values.ASM_FOLDER, chrm, tmp_pos, stype)
                if os.path.isfile(sf_asm) == False:
                    continue
                s_prefix = "{0}~{1}~{2}~".format(chrm, tmp_pos, stype)
                with open(sf_asm) as fin_asm:
                    for line in fin_asm:
                        if len(line) > 0 and line[0] == ">":
                            s_head = ">" + s_prefix + line[1:]
                            fout_fa.write(s_head)
                        else:
                            fout_fa.write(line)

    def align_one_group_contigs(self, sf_sites, stype, working_folder, sf_ref):
        s_asm_folder = working_folder + global_values.ASM_FOLDER + "/"
        self.creat_new_folder_no_exist(s_asm_folder)
        s_algnmt_folder = working_folder + global_values.MAP_FOLDER + "/"
        self.creat_new_folder_no_exist(s_algnmt_folder)
        # merge for hap1
        sf_hap_asm = s_asm_folder + stype + ".fa"
        self.merge_contigs_by_type(sf_sites, stype, working_folder, sf_hap_asm)
        # align to ref
        sf_hap_bam = s_algnmt_folder + stype + ".sorted.bam"
        self.align_short_contig_minimap2_in_bam(sf_ref, sf_hap_asm, self.n_jobs, sf_hap_bam)

    # align the contigs to the reference genome
    def align_asm_contigs_to_reference(self, sf_sites, sf_ref, working_folder):
        # merge and align for hap1
        self.align_one_group_contigs(sf_sites, global_values.HAP1, working_folder, sf_ref)
        # merge and align for hap2
        self.align_one_group_contigs(sf_sites, global_values.HAP2, working_folder, sf_ref)
        # merge and align for all-hap
        self.align_one_group_contigs(sf_sites, global_values.ALL_HAP, working_folder, sf_ref)
        # merge and align for unknown
        self.align_one_group_contigs(sf_sites, global_values.HAP_UNKNOWN, working_folder, sf_ref)
        # merge and align for discord
        self.align_one_group_contigs(sf_sites, global_values.HAP_DISCORD, working_folder, sf_ref)

####
    ####for long reads
    # this is initially desiged for the long read asm
    # for each record in format: (sf_asm, sf_flanks, sf_algnmt, ins_chrm, ins_pos)
    def run_align_flank_to_contig_2(self, record):
        sf_asm = record[0]
        sf_flank = record[1]
        sf_algnmt = record[2]

        if os.path.exists(sf_asm) == False or os.path.exists(sf_flank) == False:
            return
        if os.stat(sf_asm).st_size == 0:
            return
        n_job = 1
        self.align_short_contigs_minimap2_v2(sf_asm, sf_flank, n_job, sf_algnmt)

    ####for long reads
    # this is initially desiged for the long read asm
    # for each record in format: (sf_asm, sf_flanks, sf_algnmt, ins_chrm, ins_pos)
    def run_align_contig_to_target_seq(self, record):
        sf_asm = record[0]
        sf_target_flank = record[1]
        sf_algnmt = record[2]

        if os.path.exists(sf_asm) == False or os.path.exists(sf_target_flank) == False:
            return
        if os.stat(sf_asm).st_size == 0:
            return
        n_job = 1
        self.align_short_contigs_with_secondary_supplementary(sf_target_flank, sf_asm, n_job, sf_algnmt)
####