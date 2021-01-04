##11/22/2017
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

####Given rmsk annotation file, load the file into memory
####Check whether a given position is within a repeat region
####Parse out the given seq regions in the reference

####Revision on 03/04/2019
####Use interval tree to replace binary search

import os
import sys
import pysam
import global_values
from cmd_runner import *
from intervaltree import IntervalTree

####
class XAnnotation():
    def __init__(self, sf_rmsk):
        self.sf_annotation = sf_rmsk
        ##in format: m_rmsk_annotation[chrm][start_pos].append((end_pos, b_rc, sub_type, csn_start, csn_end))
        self.m_rmsk_annotation = {}
        self.m_rmsk_chrm_regions = {}
        self.b_with_chr = True
        self.m_interval_tree = {}  # by chrm

    # This indicates whether the chromosomes is in format "chr1" or "1"
    def set_with_chr(self, b_with_chr):
        self.b_with_chr = b_with_chr

    ## "self.b_with_chr" is the format gotten from the alignment file
    ## all other format should be changed to consistent with the "self.b_with_chr"
    def _process_chrm_name(self, chrm):
        b_chrm_with_chr = False
        if len(chrm) > 3 and chrm[:3] == "chr":  ##Here remove the "chr"
            b_chrm_with_chr = True
        # print chrm, self.b_with_chr, b_chrm_with_chr #################################################################
        if self.b_with_chr == True and b_chrm_with_chr == True:
            return chrm
        elif self.b_with_chr == True and b_chrm_with_chr == False:
            return "chr" + chrm
        elif self.b_with_chr == False and b_chrm_with_chr == True:
            return chrm[3:]
        else:
            return chrm

    def is_ref_chrm_with_chr(self, sf_ref):
        f_fa = pysam.FastaFile(sf_ref)
        m_ref_chrms = {}
        for tmp_chrm in f_fa.references:
            m_ref_chrms[tmp_chrm] = 1
        b_with_chr = False
        if "chr1" in m_ref_chrms:
            b_with_chr = True
        return b_with_chr
####

    ##collect all the fa sequences of all the TEs
    ##Also the flank regions, but the head(>) should also the original position.
    # For example, if parse chr1:2000-3000 with flank regions, we will get:
    # >chr1~2000~3000
    # >seq will be from [1500,3500] (suppose flank length is 500)
    ##Note: this is always same as the reference
    def collect_seqs_of_TE_from_ref(self, sf_ref, flank_lth, b_with_flank, sf_out_fa):
        f_ref = pysam.FastaFile(sf_ref)
        m_ref_chrms = {}
        for tmp_chrm in f_ref.references:
            m_ref_chrms[tmp_chrm] = 1

        m_str_map={}
        self.set_chr_map(m_str_map)
        with open(sf_out_fa, "w") as fout_fa:
            for chrm in self.m_rmsk_annotation:
                if chrm not in m_ref_chrms:
                    continue
                for start_pos in self.m_rmsk_annotation[chrm]:
                    record = self.m_rmsk_annotation[chrm][start_pos][0]
                    end_pos = record[0]
                    b_rc=record[1]
                    sub_family = record[2]

                    pstart = start_pos
                    pend = end_pos
                    if b_with_flank == True:
                        pstart = start_pos - flank_lth
                        pend = end_pos + flank_lth

                    if start_pos < 0:
                        start_pos = 0
                    if pstart < 0:
                        pstart = 0
                        continue  # skip the copies with exceed the regions

                    s_reg = f_ref.fetch(chrm, pstart, pend)
                    if b_rc==True:
                        s_reg=self.gnrt_reverse_complementary(s_reg, m_str_map)
                    s_TE_fa_head = ">{0}{1}{2}{3}{4}{5}{6}".format(chrm, global_values.S_DELIM, start_pos, global_values.S_DELIM,
                                                                   end_pos, global_values.S_DELIM, sub_family)  ###here still keep the original pos
                    fout_fa.write(s_TE_fa_head + "\n")
                    fout_fa.write(s_reg + "\n")
        f_ref.close()

    def gnrt_reverse_complementary(self, s_seq, chr_map):
        s_rc = ""
        for s in s_seq[::-1]:
            if s not in chr_map:
                s_rc += "N"
            else:
                s_rc += chr_map[s]
        return s_rc

    def set_chr_map(self, chr_map):
        chr_map['A'] = 'T'
        chr_map['a'] = 'T'
        chr_map['T'] = 'A'
        chr_map['t'] = 'A'
        chr_map['C'] = 'G'
        chr_map['c'] = 'G'
        chr_map['G'] = 'C'
        chr_map['g'] = 'C'
        chr_map['N'] = 'N'
        chr_map['n'] = 'N'

    #
    def collect_seqs_of_TE_from_ref_bed_fmt(self, sf_ref, sf_out_fa, flank_lth=0):
        i_extnd=flank_lth
        f_ref = pysam.FastaFile(sf_ref)
        m_ref_chrms = {}
        for tmp_chrm in f_ref.references:
            m_ref_chrms[tmp_chrm] = 1
        with open(sf_out_fa, "w") as fout_fa:
            with open(self.sf_annotation) as fin_bed:
                for line in fin_bed:
                    fields = line.split()
                    chrm = fields[0]
                    pstart = int(fields[1])
                    pend = int(fields[2])
                    s_type=fields[-1]
                    if "SVA" not in s_type:
                        s_type=""
                    if chrm not in m_ref_chrms:
                        continue
                    if pend <= 0:
                        continue  # skip the copies with exceed the regions

                    s_reg = f_ref.fetch(chrm, pstart-i_extnd, pend+i_extnd)
                    s_TE_fa_head = ">{0}{1}{2}{3}{4}{5}{6}".format(chrm, global_values.S_DELIM, pstart,
                                                                   global_values.S_DELIM, pend, global_values.S_DELIM, s_type)
                    fout_fa.write(s_TE_fa_head + "\n")
                    fout_fa.write(s_reg + "\n")
        f_ref.close()
####

    ####only collect the flank regions of the repeats
    def collect_flank_regions_of_TE_from_ref(self, sf_ref, flank_lth, sf_out_fa):
        f_ref = pysam.FastaFile(sf_ref)  ####
        m_ref_chrms = {}
        for tmp_chrm in f_ref.references:
            m_ref_chrms[tmp_chrm] = 1

        with open(sf_out_fa, "w") as fout_fa:
            for chrm in self.m_rmsk_annotation:
                if chrm not in m_ref_chrms:
                    continue
                for start_pos in self.m_rmsk_annotation[chrm]:
                    record = self.m_rmsk_annotation[chrm][start_pos][0]
                    end_pos = record[0]
                    b_rc=record[1]
                    sub_family = record[2]
                    bi_rc=0
                    if b_rc==True:
                        bi_rc=1

                    lflank_pstart = start_pos - flank_lth
                    if lflank_pstart < 0:
                        continue
                    lflank_pend = start_pos
                    s_lreg = f_ref.fetch(chrm, lflank_pstart, lflank_pend)  # the left flank
                    ###here still keep the original pos
                    s_TE_fa_lhead = ">{0}{1}{2}{3}{4}{5}{6}{7}{8}L".format(chrm, global_values.S_DELIM, start_pos,
                                                                           global_values.S_DELIM, end_pos, global_values.S_DELIM,
                                                                           sub_family, global_values.S_DELIM, bi_rc)
                    fout_fa.write(s_TE_fa_lhead + "\n")
                    fout_fa.write(s_lreg + "\n")

                    rflank_pstart = end_pos
                    if rflank_pstart <= 0:
                        continue
                    rflank_pend = end_pos + flank_lth

                    s_rreg = f_ref.fetch(chrm, rflank_pstart, rflank_pend)  # the right flank
                    ###here still keep the original pos
                    s_TE_fa_rhead = ">{0}{1}{2}{3}{4}{5}{6}{7}{8}R".format(chrm, global_values.S_DELIM, start_pos,
                                                                           global_values.S_DELIM, end_pos, global_values.S_DELIM,
                                                                           sub_family, global_values.S_DELIM, bi_rc)
                    fout_fa.write(s_TE_fa_rhead + "\n")
                    fout_fa.write(s_rreg + "\n")
        f_ref.close()

    ##index the sequence with "bwa index"
    def bwa_index_TE_seqs(self, sf_fa):
        cmd = "{0} index {1}".format(global_values.BWA_PATH, sf_fa)
        cmd_runner=CMD_RUNNER()
        cmd_runner.run_cmd_small_output(cmd)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
####
    '''
    Each record of the annotation file is in the format:
        1306    = Smith-Waterman score of the match, usually complexity adjusted
            The SW scores are not always directly comparable. Sometimes
            the complexity adjustment has been turned off, and a variety of
            scoring-matrices are used.
        15.6    = % substitutions in matching region compared to the consensus
        6.2     = % of bases opposite a gap in the query sequence (deleted bp)
        0.0     = % of bases opposite a gap in the repeat consensus (inserted bp)
        HSU08988 = name of query sequence
        6563    = starting position of match in query sequence
        7714    = ending position of match in query sequence
        (22462) = no. of bases in query sequence past the ending position of match
        C       = match is with the Complement of the consensus sequence in the database
        MER7A   = name of the matching interspersed repeat
        DNA/MER2_type = the class of the repeat, in this case a DNA transposon 
                fossil of the MER2 group (see below for list and references)
        (0)     = no. of bases in (complement of) the repeat consensus sequence 
                prior to beginning of the match (so 0 means that the match extended 
                all the way to the end of the repeat consensus sequence)
        2418    = starting position of match in database sequence (using top-strand numbering)
        1465    = ending position of match in database sequence
    '''
####
    # 7288   1.3  0.1  0.1  chr21     32213340 32214177 (15915718) +  L1HS LINE/L1 5312 6155    (0) 4482983
    # 4741   0.6  0.0  0.0  chr21     17916705 17917238 (30212657) C  L1HS LINE/L1 (0) 6155   5622 4462908
    def load_rmsk_annotation(self):
        with open(self.sf_annotation) as fin_rmsk:
            for line in fin_rmsk:
                fields = line.split()
                tmp_chrm = fields[4]
                chrm = self._process_chrm_name(tmp_chrm)
                start_pos = int(fields[5])
                end_pos = int(fields[6])
                b_rc = False
                if fields[8] == "C":
                    b_rc = True
                sub_type = fields[9]
                csn_start = -1
                csn_end = -1
                if b_rc == True:
                    csn_start = int(fields[13])
                    csn_end = int(fields[12])
                else:
                    csn_start = int(fields[11])
                    csn_end = int(fields[12])

                if chrm not in self.m_rmsk_annotation:
                    self.m_rmsk_annotation[chrm] = {}
                if start_pos in self.m_rmsk_annotation[chrm]:  ##this is not allowed!!!!
                    print("Position {0}:{1} has more than  1 annotation!!!!".format(chrm, start_pos))

                extd_start_pos = start_pos - global_values.LOAD_RMSK_LEFT_EXTND  ###here extend the left boundary a little bit
                if extd_start_pos not in self.m_rmsk_annotation[chrm]:
                    self.m_rmsk_annotation[chrm][extd_start_pos] = []
                self.m_rmsk_annotation[chrm][extd_start_pos].append((end_pos, b_rc, sub_type, csn_start, csn_end))

    # 7288   1.3  0.1  0.1  chr21     32213340 32214177 (15915718) +  L1HS LINE/L1 5312 6155    (0) 4482983
    # 4741   0.6  0.0  0.0  chr21     17916705 17917238 (30212657) C  L1HS LINE/L1 (0) 6155   5622 4462908
    def load_rmsk_annotation_no_extnd(self):
        with open(self.sf_annotation) as fin_rmsk:
            for line in fin_rmsk:
                fields = line.split()
                tmp_chrm = fields[4]
                chrm = self._process_chrm_name(tmp_chrm)
                start_pos = int(fields[5])
                end_pos = int(fields[6])
                b_rc = False
                if fields[8] == "C":
                    b_rc = True
                sub_type = fields[9]
                csn_start = -1
                csn_end = -1
                if b_rc == True:
                    csn_start = int(fields[13])
                    csn_end = int(fields[12])
                else:
                    csn_start = int(fields[11])
                    csn_end = int(fields[12])

                if chrm not in self.m_rmsk_annotation:
                    self.m_rmsk_annotation[chrm] = {}
                if start_pos in self.m_rmsk_annotation[chrm]:  ##this is not allowed!!!!
                    print("Position {0}:{1} has more than  1 annotation!!!!".format(chrm, start_pos))

                extd_start_pos = start_pos
                if extd_start_pos not in self.m_rmsk_annotation[chrm]:
                    self.m_rmsk_annotation[chrm][extd_start_pos] = []
                self.m_rmsk_annotation[chrm][extd_start_pos].append(
                    (end_pos, b_rc, sub_type, csn_start, csn_end))

    def load_annotation_no_extnd_from_bed(self):
        with open(self.sf_annotation) as fin_rmsk:
            for line in fin_rmsk:
                fields = line.split()
                tmp_chrm = fields[0]
                chrm = self._process_chrm_name(tmp_chrm)
                start_pos = int(fields[1])
                end_pos = int(fields[2])
                s_rc=fields[-2]
                b_rc=False
                if s_rc=="C":
                    b_rc=True
                sub_type=fields[-1]
                if "SVA" not in sub_type:
                    sub_type=""

                if chrm not in self.m_rmsk_annotation:
                    self.m_rmsk_annotation[chrm] = {}
                if start_pos in self.m_rmsk_annotation[chrm]:  ##this is not allowed!!!!
                    print("Position {0}:{1} has more than  1 annotation!!!!".format(chrm, start_pos))

                extd_start_pos = start_pos
                if extd_start_pos not in self.m_rmsk_annotation[chrm]:
                    self.m_rmsk_annotation[chrm][extd_start_pos] = []
                self.m_rmsk_annotation[chrm][extd_start_pos].append(
                    (end_pos, b_rc, sub_type, None, None))
####
    # 7288   1.3  0.1  0.1  chr21     32213340 32214177 (15915718) +  L1HS LINE/L1 5312 6155    (0) 4482983
    # 4741   0.6  0.0  0.0  chr21     17916705 17917238 (30212657) C  L1HS LINE/L1 (0) 6155   5622 4462908
    def load_rmsk_annotation_with_extnd_with_lenth_cutoff(self, i_extnd, i_min_len):
        with open(self.sf_annotation) as fin_rmsk:
            for line in fin_rmsk:
                fields = line.split()
                tmp_chrm = fields[4]
                chrm = self._process_chrm_name(tmp_chrm)
                start_pos = int(fields[5])
                end_pos = int(fields[6])
                b_rc = False
                if fields[8] == "C":
                    b_rc = True
                sub_type = fields[9]
                csn_start = -1
                csn_end = -1
                if b_rc == True:
                    csn_start = int(fields[13])
                    csn_end = int(fields[12])
                else:
                    csn_start = int(fields[11])
                    csn_end = int(fields[12])

                if abs(end_pos-start_pos)<i_min_len:
                    continue

                if chrm not in self.m_rmsk_annotation:
                    self.m_rmsk_annotation[chrm] = {}
                if start_pos in self.m_rmsk_annotation[chrm]:  ##this is not allowed!!!!
                    print("Position {0}:{1} has more than  1 annotation!!!!".format(chrm, start_pos))

                extd_start_pos = start_pos - i_extnd
                extd_end_pos=end_pos+i_extnd
                if extd_start_pos not in self.m_rmsk_annotation[chrm]:
                    self.m_rmsk_annotation[chrm][extd_start_pos] = []
                self.m_rmsk_annotation[chrm][extd_start_pos].append(
                    (extd_end_pos, b_rc, sub_type, csn_start, csn_end))

    # 7288   1.3  0.1  0.1  chr21     32213340 32214177 (15915718) +  L1HS LINE/L1 5312 6155    (0) 4482983
    # 4741   0.6  0.0  0.0  chr21     17916705 17917238 (30212657) C  L1HS LINE/L1 (0) 6155   5622 4462908
    def load_rmsk_annotation_with_divgnt(self):
        with open(self.sf_annotation) as fin_rmsk:
            for line in fin_rmsk:
                fields = line.split()
                mismatch_rate = float(fields[1])
                tmp_chrm = fields[4]
                chrm = self._process_chrm_name(tmp_chrm)
                start_pos = int(fields[5])
                end_pos = int(fields[6])
                b_rc = False
                if fields[8] == "C":
                    b_rc = True
                sub_type = fields[9]
                csn_start = -1
                csn_end = -1
                if b_rc == True:
                    csn_start = int(fields[13])
                    csn_end = int(fields[12])
                else:
                    csn_start = int(fields[11])
                    csn_end = int(fields[12])

                if chrm not in self.m_rmsk_annotation:
                    self.m_rmsk_annotation[chrm] = {}
                if start_pos in self.m_rmsk_annotation[chrm]:  ##this is not allowed!!!!
                    print("Position {0}:{1} has more than  1 annotation!!!!".format(chrm, start_pos))

                extd_start_pos = start_pos - 100  ###here extend the left boundary a little bit
                if extd_start_pos not in self.m_rmsk_annotation[chrm]:
                    self.m_rmsk_annotation[chrm][extd_start_pos] = []
                self.m_rmsk_annotation[chrm][extd_start_pos].append(
                    (end_pos, mismatch_rate, b_rc, sub_type, csn_start, csn_end))
####
    ####this version allow the start and end position extend some distance
    ####also return the diverant rate
    def load_rmsk_annotation_with_divgnt_extnd(self, iextnd):
        with open(self.sf_annotation) as fin_rmsk:
            for line in fin_rmsk:
                if len(line.rstrip())<1:
                    continue
                fields = line.split()
                if len(fields)<15:
                    continue
                if fields[0].rstrip()=="SW" or fields[0].rstrip()=="score":
                    continue

                mismatch_rate = float(fields[1])
                tmp_chrm = fields[4]
                chrm = self._process_chrm_name(tmp_chrm)
                start_pos = int(fields[5])-iextnd
                end_pos = int(fields[6])+iextnd
                b_rc = False
                if fields[8] == "C":
                    b_rc = True
                sub_type = fields[9]
                family = fields[10]
                csn_start = -1
                csn_end = -1
                if b_rc == True:
                    csn_start = int(fields[13])
                    csn_end = int(fields[12])
                else:
                    csn_start = int(fields[11])
                    csn_end = int(fields[12])

                if chrm not in self.m_rmsk_annotation:
                    self.m_rmsk_annotation[chrm] = {}
                if start_pos in self.m_rmsk_annotation[chrm]:  ##this is not allowed!!!!
                    print("Position {0}:{1} has more than  1 annotation!!!!".format(chrm, start_pos))

                extd_start_pos = start_pos - 100  ###here extend the left boundary a little bit
                if extd_start_pos not in self.m_rmsk_annotation[chrm]:
                    self.m_rmsk_annotation[chrm][extd_start_pos] = []
                self.m_rmsk_annotation[chrm][extd_start_pos].append(
                    (end_pos, mismatch_rate, b_rc, sub_type, family, csn_start, csn_end))

    ####this version allow the start and end position extend some distance
    ####also return the diverant rate
    def load_rmsk_annotation_with_divgnt_no_slack_with_extnd(self, iextnd):
        with open(self.sf_annotation) as fin_rmsk:
            for line in fin_rmsk:
                if len(line.rstrip()) < 1:
                    continue
                fields = line.split()
                if len(fields) < 15:
                    continue
                if fields[0].rstrip() == "SW" or fields[0].rstrip() == "score":
                    continue

                mismatch_rate = float(fields[1])
                tmp_chrm = fields[4]
                chrm = self._process_chrm_name(tmp_chrm)
                start_pos = int(fields[5]) - iextnd
                end_pos = int(fields[6]) + iextnd
                b_rc = False
                if fields[8] == "C":
                    b_rc = True
                sub_type = fields[9]
                family = fields[10]
                csn_start = -1
                csn_end = -1
                if b_rc == True:
                    csn_start = int(fields[13])
                    csn_end = int(fields[12])
                else:
                    csn_start = int(fields[11])
                    csn_end = int(fields[12])

                if chrm not in self.m_rmsk_annotation:
                    self.m_rmsk_annotation[chrm] = {}
                if start_pos in self.m_rmsk_annotation[chrm]:  ##this is not allowed!!!!
                    print("Position {0}:{1} has more than  1 annotation!!!!".format(chrm, start_pos))

                extd_start_pos = start_pos
                if extd_start_pos not in self.m_rmsk_annotation[chrm]:
                    self.m_rmsk_annotation[chrm][extd_start_pos] = []
                self.m_rmsk_annotation[chrm][extd_start_pos].append(
                    (end_pos, mismatch_rate, b_rc, sub_type, family, csn_start, csn_end))

    # 7288   1.3  0.1  0.1  chr21     32213340 32214177 (15915718) +  L1HS LINE/L1 5312 6155    (0) 4482983
    # 4741   0.6  0.0  0.0  chr21     17916705 17917238 (30212657) C  L1HS LINE/L1 (0) 6155   5622 4462908
    def load_rmsk_annotation_with_extnd_div_with_lenth_cutoff(self, i_extnd, i_min_len):
        with open(self.sf_annotation) as fin_rmsk:
            for line in fin_rmsk:
                if len(line.rstrip()) < 1:
                    continue
                fields = line.split()
                if len(fields) < 15:
                    continue
                if fields[0].rstrip() == "SW" or fields[0].rstrip() == "score":
                    continue

                mismatch_rate = float(fields[1])
                tmp_chrm = fields[4]
                chrm = self._process_chrm_name(tmp_chrm)
                start_pos = int(fields[5])
                end_pos = int(fields[6])
                b_rc = False
                if fields[8] == "C":
                    b_rc = True
                sub_type = fields[9]
                family = fields[10]
                csn_start = -1
                csn_end = -1
                if b_rc == True:
                    csn_start = int(fields[13])
                    csn_end = int(fields[12])
                else:
                    csn_start = int(fields[11])
                    csn_end = int(fields[12])

                if abs(end_pos - start_pos) < i_min_len:
                    continue

                if chrm not in self.m_rmsk_annotation:
                    self.m_rmsk_annotation[chrm] = {}
                if start_pos in self.m_rmsk_annotation[chrm]:  ##this is not allowed!!!!
                    print("Position {0}:{1} has more than  1 annotation!!!!".format(chrm, start_pos))

                extd_start_pos = start_pos - i_extnd
                extd_end_pos = end_pos + i_extnd
                if extd_start_pos not in self.m_rmsk_annotation[chrm]:
                    self.m_rmsk_annotation[chrm][extd_start_pos] = []
                self.m_rmsk_annotation[chrm][extd_start_pos].append(
                    (extd_end_pos, mismatch_rate, b_rc, sub_type, family, csn_start, csn_end))
    ####
    def load_rmsk_annotation_L1(self):  #
        with open(self.sf_annotation) as fin_rmsk:
            for line in fin_rmsk:
                fields = line.split()
                tmp_chrm = fields[4]
                repeat_type = fields[10]
                if repeat_type != "LINE/L1":  ###Here only keep the L1 repeats
                    continue
                chrm = self._process_chrm_name(tmp_chrm)
                start_pos = int(fields[5])
                end_pos = int(fields[6])
                b_rc = False
                if fields[8] == "C":
                    b_rc = True
                sub_type = fields[9]
                csn_start = -1
                csn_end = -1
                if b_rc == True:
                    csn_start = int(fields[13])
                    csn_end = int(fields[12])
                else:
                    csn_start = int(fields[11])
                    csn_end = int(fields[12])

                if chrm not in self.m_rmsk_annotation:
                    self.m_rmsk_annotation[chrm] = {}
                if start_pos in self.m_rmsk_annotation[chrm]:  ##this is not allowed!!!!
                    print("Position {0}:{1} has more than  1 annotation!!!!".format(chrm, start_pos))

                extd_start_pos=start_pos-100 ###here extend the left boundary a little bit
                if extd_start_pos not in self.m_rmsk_annotation[chrm]:
                    self.m_rmsk_annotation[chrm][extd_start_pos] = []
                self.m_rmsk_annotation[chrm][extd_start_pos].append((end_pos, b_rc, sub_type, csn_start, csn_end))

    ##For each chrom, sort according to the start position of each region
    def index_rmsk_annotation(self):
        for chrm in self.m_rmsk_annotation:
            l_tmp = []
            for pos in self.m_rmsk_annotation[chrm]:
                l_tmp.append(pos)
            l_tmp.sort()
            self.m_rmsk_chrm_regions[chrm] = l_tmp

    # For a given position, check whether it falls in a region
    # If hit, then return "True, chrm, start_pos_of_region "
    ##This is implemented by binary search !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ##Search rmsk annotation
    def is_within_repeat_region(self, chrm, pos):
        if chrm not in self.m_rmsk_chrm_regions:
            return False, -1
        lo, hi = 0, len(self.m_rmsk_chrm_regions[chrm]) - 1
        while lo <= hi:#binary search
            mid = (lo + hi) / 2
            mid_start_pos = self.m_rmsk_chrm_regions[chrm][mid]
            mid_end_pos = self.m_rmsk_annotation[chrm][mid_start_pos][0][0]
            if pos >= mid_start_pos and pos <= mid_end_pos:
                return True, mid_start_pos
            elif pos > mid_start_pos:
                lo = mid + 1
            else:
                hi = mid - 1
        return False, -1
####
    #Index by interval tree
    def index_rmsk_annotation_interval_tree(self):
        for chrm in self.m_rmsk_annotation:
            interval_tree = IntervalTree()
            for pos in self.m_rmsk_annotation[chrm]:
                end_pos=self.m_rmsk_annotation[chrm][pos][0][0]
                interval_tree.addi(pos, end_pos)
            self.m_interval_tree[chrm] = interval_tree

    def is_within_repeat_region_interval_tree(self, chrm1, pos):
        chrm=self._process_chrm_name(chrm1)
        if chrm not in self.m_interval_tree:
            return False, -1
        tmp_tree = self.m_interval_tree[chrm]
        set_rslt = tmp_tree[pos]
        if len(set_rslt)==0:
            return False, -1
        for rcd in set_rslt:
            start_pos=rcd[0]
            return True, start_pos
        return False, -1

    #this version will reture all the possible hits
    def is_within_repeat_region_interval_tree2(self, chrm1, pos):
        l_hits=[]
        chrm=self._process_chrm_name(chrm1)
        if chrm not in self.m_interval_tree:
            return l_hits
        tmp_tree = self.m_interval_tree[chrm]
        set_rslt = tmp_tree[pos]
        if len(set_rslt)==0:
            return l_hits
        for rcd in set_rslt:
            start_pos=rcd[0]
            l_hits.append((True, start_pos))
        return l_hits

    ####get divergent rate and subfamily of the given repeat
    def get_div_subfamily(self, chrm1, pos):
        chrm = self._process_chrm_name(chrm1)
        if chrm not in self.m_rmsk_annotation:
            return -1, "", None, None, None
        if pos not in self.m_rmsk_annotation[chrm]:
            return -1, "", None, None, None

        div_rate=self.m_rmsk_annotation[chrm][pos][0][1]
        sub_family=self.m_rmsk_annotation[chrm][pos][0][3]
        family=self.m_rmsk_annotation[chrm][pos][0][4]
        # cns_start=int(self.m_rmsk_annotation[chrm][pos][0][-2])
        # cns_end=int(self.m_rmsk_annotation[chrm][pos][0][-1])
        # rep_lenth=cns_end-cns_start
        pos_end=int(self.m_rmsk_annotation[chrm][pos][0][0])
        return div_rate, sub_family, family, pos, pos_end

    ####get divergent rate and subfamily of the given repeat
    ####If have several hits, then return them all
    def get_div_subfamily_with_min_div(self, chrm1, pos):
        chrm = self._process_chrm_name(chrm1)
        if chrm not in self.m_rmsk_annotation:
            return -1, "", None, None, None
        if pos not in self.m_rmsk_annotation[chrm]:
            return -1, "", None, None, None

        div_rate = self.m_rmsk_annotation[chrm][pos][0][1]
        sub_family = self.m_rmsk_annotation[chrm][pos][0][3]
        family = self.m_rmsk_annotation[chrm][pos][0][4]
        # cns_start=int(self.m_rmsk_annotation[chrm][pos][0][-2])
        # cns_end=int(self.m_rmsk_annotation[chrm][pos][0][-1])
        # rep_lenth=cns_end-cns_start
        pos_end = int(self.m_rmsk_annotation[chrm][pos][0][0])
        if len(self.m_rmsk_annotation[chrm][pos])>1:
            for rcd in self.m_rmsk_annotation[chrm][pos][1:]:
                tmp_div_rate = rcd[1]
                if tmp_div_rate < div_rate:
                    div_rate = tmp_div_rate
                    sub_family = rcd[3]
                    family = rcd[4]
                    pos_end = int(rcd[0])
        return div_rate, sub_family, family, pos, pos_end

    ####this version will reture all the possible hits
    ####get divergent rate and subfamily of the given repeat
    ####If have several hits, then return them all
    def get_div_subfamily_with_min_div2(self, chrm1, pos):
        l_hits = []
        chrm = self._process_chrm_name(chrm1)
        if chrm not in self.m_rmsk_annotation:
            return l_hits
        if pos not in self.m_rmsk_annotation[chrm]:
            return l_hits

        for rcd in self.m_rmsk_annotation[chrm][pos]:
            div_rate=rcd[1]
            sub_family=rcd[3]
            family=rcd[4]
            pos_end=int(rcd[0])
            l_hits.append((div_rate, sub_family, family, pos, pos_end))
        return l_hits
####
    def get_annotation_TE_region_lenth(self, chrm, start_pos):
        end_pos = self.m_rmsk_annotation[chrm][start_pos][0][0]
        return end_pos - start_pos


    def get_rmsk_annotation(self):
        return self.m_rmsk_annotation

    # #Given one position like: 4~135176492~135176779~L1MA4, get the position on consensus
    # def map_annotation_pos_to_consensus_pos(self, b_with_flank, flank_length, in_pos):
    #

    ####given the original repeatmasker file, generate the file contain the selected records
    def select_L1_annotation_from_rmsk(self, lth_cutoff, sf_out):
        with open(self.sf_annotation) as fin_rmsk, open(sf_out, "w") as fout_selected:
            for line in fin_rmsk:
                if len(line.rstrip())<1:
                    continue
                fields = line.split()
                if len(fields)<15:
                    continue
                if fields[0].rstrip()=="SW" or fields[0].rstrip()=="score":
                    continue

                tmp_chrm = fields[4]
                b_rc = False
                if fields[8] == "C":
                    b_rc = True
                sub_type = fields[9]
                family = fields[10]
                if family!="LINE/L1":
                    continue
                csn_start = -1
                csn_end = -1
                if b_rc == True:
                    csn_start = int(fields[13])
                    csn_end = int(fields[12])
                else:
                    csn_start = int(fields[11])
                    csn_end = int(fields[12])

                if abs(csn_end-csn_start)>=lth_cutoff or sub_type=="L1HS":
                    fout_selected.write(line)
####