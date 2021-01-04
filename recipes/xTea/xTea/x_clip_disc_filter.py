##03/11/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

##The input sites are guranteed by the first two steps that:
# 1) Have enough clipped reads support (nearby region)
# 2) Several discordant reads support
# 3) Clipped reads and discordant read aligned to repeat copies

##This module mainly for filtering out false positive events by:
##1) Check the alignment position on consensus, whether form a cluster
##2) And the distance between the discordant reads aligned to consensus is within 3*std_dev of the clip_pos

##Expected output:
##1) Smaller number of candidate by filter out most of the false positives
##2) For each candidate site, output the TSD if exist
##3) Transduction analysis
##

###Hard code at:
#  def check_disc_consistency(self, m_clip_checked, m_disc_pos, m_polyA, i_dist, ratio):
# def call_MEIs(self, sf_candidate_list, extnd, bin_size, sf_rep_copies, i_flank_lenth, bmapped_cutoff,
#                  sf_annotation, i_concord_dist, f_concord_ratio, sf_final_list):

####
import os
import sys
import pysam
from subprocess import *
from multiprocessing import Pool
from x_alignments import *
from x_annotation import *
from x_coverage import *
from bwa_align import *
from x_transduction import *
from x_cluster_consistency import *
from x_polyA import *
import global_values
from x_log import *
from x_genotype_feature import *

def unwrap_self_collect_clip_disc_reads(arg, **kwarg):
    return XClipDisc.collect_clipped_disc_reads_by_region(*arg, **kwarg)

def unwrap_self_calc_AF_by_clip_reads(arg, **kwarg):
    return XClipDisc.calc_AF_of_site(*arg, **kwarg)

class XClipDisc():####
    def __init__(self, sf_bam, working_folder, n_jobs, sf_ref):
        self.sf_bam = sf_bam
        self.working_folder = working_folder
        self.n_jobs = n_jobs
        self.sf_reference = sf_ref

    def get_realignment_for_sites(self):
        # Get the realignment position of the clipped parts from the output of the first step
        sf_bam_name = os.path.basename(self.sf_bam)
        sf_algnmt = self.working_folder + sf_bam_name + global_values.CLIP_BAM_SUFFIX
        ####given specific chrm, get all the related clipped reads

    ####
    ## "self.b_with_chr" is the format gotten from the alignment file
    ## all other format should be changed to consistent with the "self.b_with_chr"
    def _process_chrm_name(self, b_tmplt_with_chr, chrm):
        b_chrm_with_chr = False
        if len(chrm) > 3 and chrm[:3] == "chr":  ##Here remove the "chr"
            b_chrm_with_chr = True
        # print chrm, self.b_with_chr, b_chrm_with_chr #################################################################

        if b_tmplt_with_chr == True and b_chrm_with_chr == True:
            return chrm
        elif b_tmplt_with_chr == True and b_chrm_with_chr == False:
            return "chr" + chrm
        elif b_tmplt_with_chr == False and b_chrm_with_chr == True:
            return chrm[3:]
        else:
            return chrm
####
    ###Problem here: 1. chrm in "candidate_list" may not consistent with chrm in bam file
    ###2. all should follow the style in candidate list
    def collect_clipped_disc_reads_by_region(self, record):
        chrm = record[0][0]  ##this is the chrm style in candidate list
        insertion_pos = record[0][1]
        extnd = record[0][2]
        start_pos = insertion_pos - extnd
        if start_pos <= 0:
            start_pos = 1
        end_pos = insertion_pos + extnd
        sf_bam = record[1]
        working_folder = record[2]

        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        chrm_in_bam = self._process_chrm_name(b_with_chr, chrm)

        # load the reads, and write the related clipped part into file
        s_pos_info = "{0}_{1}".format(chrm, insertion_pos)
        sf_clip_fq = working_folder + s_pos_info + global_values.CLIP_FQ_SUFFIX  # this is to save the clipped part for re-alignment
        f_clip_fq = open(sf_clip_fq, "w")

        sf_disc_pos = working_folder + s_pos_info + global_values.DISC_POS_SUFFIX  # this is to save the discordant positions
        f_disc_pos = open(sf_disc_pos, "w")

        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        n_cnt_clip = 0  # as a index to set a different read id for collected reads clip at the same position
        n_cnt_low_mapq_clip=0 #this is to count the low mapping quality clip reads
        xpolyA = PolyA()#
        m_chrm_id=self._get_chrm_id_name(samfile)
        for algnmt in samfile.fetch(chrm_in_bam, start_pos, end_pos):  ##fetch reads mapped to "chrm:start_pos-end_pos"
            ##here need to skip the secondary and supplementary alignments?
            # if algnmt.is_secondary or algnmt.is_supplementary:
            #     continue
            if algnmt.is_duplicate == True:  ##duplciate
                continue
            b_first = True
            if algnmt.is_read2 == True:
                b_first = False
            if algnmt.is_unmapped == True:  # unmapped
                continue
            l_cigar = algnmt.cigar
            if len(l_cigar) < 1:  # wrong alignment
                continue

            query_name = algnmt.query_name
            query_seq = algnmt.query_sequence
            ##this is different from the one saved in the fastq/sam, no offset 33 to subtract
            query_quality = algnmt.query_qualities
            # anchor_map_pos=algnmt.reference_start##original mapping position
            map_pos = algnmt.reference_start
            mate_chrm = '*'
            mate_pos = 0
            is_rc = 0
            if algnmt.is_reverse == True:  # is reverse complementary
                is_rc = 1

            if (algnmt.next_reference_id in m_chrm_id) and (algnmt.mate_is_unmapped == False) \
                    and (algnmt.next_reference_id >= 0):
                mate_chrm = algnmt.next_reference_name
                mate_pos = algnmt.next_reference_start

            b_fully_mapped = False
            i_map_start = map_pos
            i_map_end=-1
            if len(l_cigar) == 1 and l_cigar[0][0] == 0:##fully mapped
                b_fully_mapped = True
                i_map_end=i_map_start+l_cigar[0][1]

            if algnmt.mapping_quality < global_values.MINIMUM_CLIP_MAPQ:##
                if algnmt.mapping_quality < global_values.CLIP_LOW_MAPQ:
                    if l_cigar[0][0] == 4:#left clip
                        if abs(map_pos - insertion_pos) < global_values.NEARBY_LOW_Q_CLIP:
                            n_cnt_low_mapq_clip+=1
                    elif l_cigar[-1][0] == 4:#right clip
                        tmp_map_lenth=global_values.READ_LENGTH-l_cigar[-1][1]
                        if abs(map_pos + tmp_map_lenth - insertion_pos) < global_values.NEARBY_LOW_Q_CLIP:
                            n_cnt_low_mapq_clip+=1
                continue

            if self.is_two_side_clipped(l_cigar, global_values.TWO_SIDE_CLIP_MIN_LEN)==True:
                continue

            b_left_clip=0#whether is left clip
            if l_cigar[0][0] == 4:  #left clipped
                if algnmt.is_supplementary or algnmt.is_secondary:###secondary and supplementary are not considered
                    continue
####
                # if map_pos in m_pos:#
                clipped_seq = query_seq[:l_cigar[0][1]]
                len_clip_seq=len(clipped_seq)
                ####Here will collect those
                if len_clip_seq >= global_values.MINIMUM_POLYA_CLIP and len_clip_seq <= global_values.BWA_REALIGN_CUTOFF:
                    if xpolyA.contain_enough_A_T(clipped_seq, len_clip_seq - 1) == False:
                        continue
                elif len_clip_seq < global_values.BWA_REALIGN_CUTOFF:
                    continue

                # require the medium quality score should higher than threshold
                l_quality_score = query_quality[:l_cigar[0][1]]
                if self._is_qualified_clip(l_quality_score) == False:
                    continue

                clipped_qulity = self._cvt_to_Ascii_quality(query_quality[:l_cigar[0][1]])
                clipped_rname = "{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}".format(chrm, global_values.SEPERATOR, map_pos,
                                                                            global_values.SEPERATOR, global_values.FLAG_LEFT_CLIP,
                                                                            global_values.SEPERATOR, is_rc, global_values.SEPERATOR,
                                                                            insertion_pos, global_values.SEPERATOR, n_cnt_clip)
                n_cnt_clip += 1

                f_clip_fq.write("@" + clipped_rname + "\n")
                f_clip_fq.write(clipped_seq + "\n")
                f_clip_fq.write("+\n")
                f_clip_fq.write(clipped_qulity + "\n")
                b_left_clip=1

            b_right_clip=0#whether is right clip
            if l_cigar[-1][0] == 4:  # right clipped
                ##calculate the exact clip position
                for (type, lenth) in l_cigar[:-1]:
                    if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                        continue
                    else:
                        map_pos += lenth

                if algnmt.is_supplementary or algnmt.is_secondary:  ###secondary and supplementary are not considered
                    continue

                # if map_pos in m_pos:  #soft-clip
                clipped_rname = "{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}".format(chrm, global_values.SEPERATOR, map_pos, global_values.SEPERATOR,
                                                                            global_values.FLAG_RIGHT_CLIP, global_values.SEPERATOR, is_rc,
                                                                            global_values.SEPERATOR,
                                                                            insertion_pos, global_values.SEPERATOR, n_cnt_clip)
                n_cnt_clip += 1

                start_pos = -1 * l_cigar[-1][1]
                clipped_seq = query_seq[start_pos:]
                len_clip_seq = len(clipped_seq)
                if len_clip_seq >= global_values.MINIMUM_POLYA_CLIP and len_clip_seq <= global_values.BWA_REALIGN_CUTOFF:
                    if xpolyA.contain_enough_A_T(clipped_seq, len_clip_seq - 1) == False:
                        continue
                if len_clip_seq < global_values.BWA_REALIGN_CUTOFF:
                    continue

                l_quality_score = query_quality[start_pos:]
                if self._is_qualified_clip(l_quality_score) == False:
                    continue

                clipped_qulity = self._cvt_to_Ascii_quality(query_quality[start_pos:])

                f_clip_fq.write("@" + clipped_rname + "\n")
                f_clip_fq.write(clipped_seq + "\n")
                f_clip_fq.write("+\n")
                f_clip_fq.write(clipped_qulity + "\n")
                b_right_clip=1

            if mate_chrm == "*":  ##unmapped reads are not interested!
                continue
            xchrom = XChromosome()  ###decoy seuqence and contigs are not interested
            if xchrom.is_decoy_contig_chrms(mate_chrm) == True:
                continue

            if algnmt.mapping_quality < global_values.MINIMUM_DISC_MAPQ:
                continue

            # we need check "is_mate_rc", because reads from alignment is always same as reference
            # so need this information to get the original orientation
            is_mate_rc = 0
            if algnmt.mate_is_reverse == True:  #mate is reverse complementary
                is_mate_rc = 1
            ## here only collect the read names for discordant reads, later will re-align the discordant reads
            if self.is_discordant(chrm_in_bam, map_pos, mate_chrm, mate_pos, global_values.DISC_THRESHOLD) == True:
                # check where the mate is mapped, if within a repeat copy, then get the position on consensus
                # f_disc_names.write(query_name + "\n")
                s_mate_first = 1  # whether the mate read is the "first read" in a pair
                if b_first == True:
                    s_mate_first = 0

                # here mate_chrm must be the style in the bam file
                # And chrm must be the style in the candidate file
                s_mate_pos_info = "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}\t{8}" \
                                  "\t{9}\t{10}\n".format(chrm, map_pos, is_rc, is_mate_rc, mate_chrm,
                                                         mate_pos, query_name, s_mate_first, insertion_pos,
                                                         b_left_clip, b_right_clip)
                f_disc_pos.write(s_mate_pos_info)

        samfile.close()
        f_clip_fq.close()
        f_disc_pos.close()
        return (chrm, insertion_pos, n_cnt_low_mapq_clip)
####
    def is_two_side_clipped(self, l_cigar, i_min_clip):
        b_two_clip=False
        if l_cigar[-1][0] == 4 and l_cigar[0][0] == 4:#both side clip
            if l_cigar[-1][1] > i_min_clip and l_cigar[0][1] > i_min_clip:
                return True
        return b_two_clip
    ####
    ##whether a pair of read is discordant (for TEI only) or not
    def is_discordant(self, chrm, map_pos, mate_chrm, mate_pos, is_threshold):
        # b_disc=False
        if chrm != mate_chrm:  ###of different chroms
            return True
        else:
            if abs(mate_pos - map_pos) > is_threshold:  # Of same chrom, but insert size are quite large
                return True
                # if first_rc==second_rc: ##direction are abnormal, by default consider (F,R) as right mode
                #     return True
        return False
####
    ####
    ####This function: Given a list of insertion sites, get all the clipped parts (in fastq) and disc reads
    ##Parameters: "sf_candidate_list" saves all the candidate sites
    #             for each site, will collect reads within [-extnd, +extnd] region
    #             "sf_rep_copies" is the repeat copy files in fasta format (including flank regions)
    def collect_clipped_disc_reads_of_given_list(self, sf_candidate_list, extnd, bin_size, sf_all_clip_fq, sf_disc_fa):
        l_chrm_records = []
        with open(sf_candidate_list) as fin_list:
            for line in fin_list:
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])  # candidate insertion site
                l_chrm_records.append(((chrm, pos, extnd), self.sf_bam, self.working_folder))
        pool = Pool(self.n_jobs)
        l_low_mapq=pool.map(unwrap_self_collect_clip_disc_reads, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

        ###I. For clipped reads
        ## get all the clipped parts for each candidate site
        ###II. For disc reads
        ### here merge all the read_id files and pos files
        ####in format:chrm, map_pos, mate_chrm, mate_pos, query_name, s_mate_first, insertion_pos
        ####it is possible there are duplicate records are merged
        sf_all_disc_pos = self.working_folder + "all_disc_pos" + global_values.DISC_POS_SUFFIX  # this is to save all the disc pos
        with open(sf_all_clip_fq, "w") as fout_merged_clip_fq, open(sf_all_disc_pos, "w") as fout_merged_disc_pos:
            # m_read_names={}####in case duplicate reads are saved
            for record in l_chrm_records:
                chrm = record[0][0]
                insertion_pos = record[0][1]
                s_pos_info = "{0}_{1}".format(chrm, insertion_pos)
                sf_clip_fq = self.working_folder + s_pos_info + global_values.CLIP_FQ_SUFFIX
                if os.path.isfile(sf_clip_fq)==True:
                    with open(sf_clip_fq) as fin_clip_fq:
                        for line in fin_clip_fq:
                            fout_merged_clip_fq.write(line)
                    if os.path.isfile(sf_clip_fq)==True:#here remove the temporary file
                        os.remove(sf_clip_fq)

                sf_disc_pos = self.working_folder + s_pos_info + global_values.DISC_POS_SUFFIX  # this is to save the disc positions
                if os.path.isfile(sf_disc_pos)==True:
                    with open(sf_disc_pos) as fin_disc_pos:
                        for line in fin_disc_pos:
                            fout_merged_disc_pos.write(line)
                if os.path.isfile(sf_disc_pos):
                    os.remove(sf_disc_pos)

        # now, need to retrieve the reads according to the read names and disc positions
        bam_info = BamInfo(self.sf_bam, self.sf_reference)
        bam_info.extract_mate_reads_by_name(sf_all_disc_pos, bin_size, self.working_folder, self.n_jobs, sf_disc_fa)
        return l_low_mapq
####

    ####
    ####This function: Given a list of insertion sites, get all the clipped parts (in fastq)
    ##Parameters: "sf_candidate_list" saves all the candidate sites
    #             for each site, will collect reads within [-extnd, +extnd] region
    #             "sf_rep_copies" is the repeat copy files in fasta format (including flank regions)
    def collect_clipped_reads_of_given_list(self, sf_candidate_list, extnd, sf_all_clip_fq):
        m_chrm_pos={}
        with open(sf_candidate_list) as fin_list:
            for line in fin_list:
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])  # candidate insertion site
                #l_chrm_records.append(((chrm, pos, extnd), self.sf_bam, self.working_folder))
                if chrm not in m_chrm_pos:
                    m_chrm_pos[chrm]=[]
                m_chrm_pos[chrm].append(pos)

                #for debug only
                #self.collect_clipped_disc_reads_by_region(((chrm, pos, extnd), self.sf_bam, self.working_folder))

        sf_all_disc_pos = self.working_folder + "all_disc_pos" + global_values.DISC_POS_SUFFIX  # this is to save all the disc pos
        with open(sf_all_clip_fq, "w") as fout_merged_clip_fq, open(sf_all_disc_pos, "w") as fout_merged_disc_pos:
            for chrm in m_chrm_pos:
                l_chrm_records = []
                for pos in m_chrm_pos[chrm]:
                    l_chrm_records.append(((chrm, pos, extnd), self.sf_bam, self.working_folder))
                pool = Pool(self.n_jobs)
                pool.map(unwrap_self_collect_clip_disc_reads, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
                pool.close()
                pool.join()

                ###I. For clipped reads
                ## get all the clipped parts for each candidate site
                ###II. For disc reads
                ### here merge all the read_id files and pos files
                ####in format:chrm, map_pos, mate_chrm, mate_pos, query_name, s_mate_first, insertion_pos
                ####it is possible there are duplicate records are merged

                # m_read_names={}####in case duplicate reads are saved
                for record in l_chrm_records:
                    chrm = record[0][0]
                    insertion_pos = record[0][1]
                    s_pos_info = "{0}_{1}".format(chrm, insertion_pos)
                    sf_clip_fq = self.working_folder + s_pos_info + global_values.CLIP_FQ_SUFFIX
                    with open(sf_clip_fq) as fin_clip_fq:
                        for line in fin_clip_fq:
                            fout_merged_clip_fq.write(line)
                    if os.path.isfile(sf_clip_fq) == True:  # here remove the temporary file
                        os.remove(sf_clip_fq)

                    sf_disc_pos = self.working_folder + s_pos_info + global_values.DISC_POS_SUFFIX  # this is to save the disc positions
                    with open(sf_disc_pos) as fin_disc_pos:
                        for line in fin_disc_pos:
                            fout_merged_disc_pos.write(line)
                    if os.path.isfile(sf_disc_pos):
                        os.remove(sf_disc_pos)
        # now, need to retrieve the reads according to the read names and disc positions
        #bam_info = BamInfo(self.sf_bam, self.sf_reference)
        #bam_info.extract_mate_reads_by_name(sf_all_disc_pos, bin_size, self.working_folder, self.n_jobs, sf_disc_fa)

    ####
    ####This function: Given a list of insertion sites, get all the clipped parts (in fastq) and disc reads
    ##Parameters: "sf_candidate_list" saves all the candidate sites
    #             for each site, will collect reads within [-extnd, +extnd] region
    #             "sf_rep_copies" is the repeat copy files in fasta format (including flank regions)
    def collect_disc_reads_of_given_list(self, sf_candidate_list, extnd, bin_size, sf_disc_fa):
        l_chrm_records = []
        with open(sf_candidate_list) as fin_list:
            for line in fin_list:
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])  # candidate insertion site
                l_chrm_records.append(((chrm, pos, extnd), self.sf_bam, self.working_folder))

        ###II. For disc reads
        ### here merge all the read_id files and pos files
        ####in format:chrm, map_pos, mate_chrm, mate_pos, query_name, s_mate_first, insertion_pos
        ####it is possible there are duplicate records are merged
        sf_all_disc_pos = self.working_folder + "all_disc_pos" + global_values.DISC_POS_SUFFIX  # this is to save all the disc pos
        # now, need to retrieve the reads according to the read names and disc positions
        bam_info = BamInfo(self.sf_bam, self.sf_reference)
        bam_info.extract_mate_reads_by_name(sf_all_disc_pos, bin_size, self.working_folder, self.n_jobs, sf_disc_fa)
        ####

####
    ####
    '''
        for each alignment in the alignment_list:
    '''

    def _cvt_to_Ascii_quality(self, l_score):
        new_score = [x + 33 for x in l_score]
        return ''.join(map(chr, new_score))

    def _is_qualified_clip(self, l_score):
        n_char=len(l_score)
        n_half=n_char/2
        n_cnt=0
        for i_score in l_score:
            if i_score < global_values.CLIP_PHRED_SCORE_CUTOFF:
                n_cnt+=1
            if n_cnt>n_half:
                return False
        return True
####
    def _get_chrm_id_name(self, samfile):
        m_chrm = {}
        references = samfile.references
        for schrm in references:
            chrm_id = samfile.get_tid(schrm)
            m_chrm[chrm_id] = schrm
        m_chrm[-1] = "*"
        return m_chrm

    # calculate AF for one site
    # by default: cnt # of clipped reads within [-30, 30] of the insertion site
    ##calculate the average # of reads cover a site
    # then calculate the AF
    def calc_AF_of_site(self, record):
        chrm = record[0]  ##this is the chrm style in candidate list
        sf_bam_list = record[1]
        sf_candidate_list = record[2]
        extend = int(record[3])
        clip_extnd = int(record[4])
        af_cutoff = float(record[5])
        working_folder = record[6]
        if working_folder[-1] != "/":
            working_folder += "/"

        l_bams = []
        with open(sf_bam_list) as fin_bam_list:
            for line in fin_bam_list:
                fields=line.split()
                l_bams.append(fields[0])

        m_candidate_sites = {}
        with open(sf_candidate_list) as fin_candidates:
            for line in fin_candidates:
                fields = line.split()
                tmp_chrm = fields[0]
                pos = int(fields[1])
                if tmp_chrm not in m_candidate_sites:
                    m_candidate_sites[tmp_chrm] = []
                m_candidate_sites[tmp_chrm].append(pos)

        m_rslts = {}
        for sf_bam in l_bams:
            bam_info = BamInfo(sf_bam, self.sf_reference)
            b_with_chr = bam_info.is_chrm_contain_chr()
            chrm_in_bam = self._process_chrm_name(b_with_chr, chrm)
            samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
            m_chrm_id=self._get_chrm_id_name(samfile)
            for insertion_pos in m_candidate_sites[chrm]:
                start_pos = insertion_pos - extend
                if start_pos <= 0:
                    start_pos = 1
                end_pos = insertion_pos + extend
                cnt_all_reads = 0
                cnt_clip = 0
                cnt_disc = 0
                cnt_all_2 = 0
                lmost_region = -1
                rmost_region = -1
                for algnmt in samfile.fetch(chrm_in_bam, start_pos, end_pos):  ##fetch reads mapped to "chrm:start_pos-end_pos"
                    if algnmt.is_duplicate == True:  ##duplciate
                        continue
                    if algnmt.is_unmapped == True:  # unmapped
                        continue
                    l_cigar = algnmt.cigar
                    if len(l_cigar) < 1:  # wrong alignment
                        continue
                    if algnmt.mapping_quality < global_values.MINIMUM_DISC_MAPQ:
                        continue
                    if algnmt.is_supplementary or algnmt.is_secondary:
                        continue


                    map_pos = algnmt.reference_start
                    if lmost_region == -1:
                        lmost_region = map_pos
                    if rmost_region == -1:
                        rmost_region = map_pos

                    if map_pos < lmost_region:
                        lmost_region = map_pos
                    if map_pos > rmost_region:
                        rmost_region = map_pos

                    cnt_all_reads += 1
                    if abs(insertion_pos - map_pos) < extend:
                        cnt_all_2 += 1

                    mate_chrm = '*'
                    mate_pos = 0
                    if (algnmt.next_reference_id in m_chrm_id) and (algnmt.mate_is_unmapped == False) \
                            and (algnmt.next_reference_id >= 0):
                        mate_chrm = algnmt.next_reference_name
                        mate_pos = algnmt.next_reference_start

                    ##check disc information
                    if mate_chrm != "*":
                        if self.is_discordant(chrm_in_bam, map_pos, mate_chrm, mate_pos, global_values.DISC_THRESHOLD) == True:
                            cnt_disc += 1
                    ##check clip information
                    clip_pos = map_pos
                    if l_cigar[0][0] == 4:
                        if abs(insertion_pos - clip_pos) <= clip_extnd:
                            cnt_clip += 1
                    elif l_cigar[-1][0] == 4:
                        for (type, lenth) in l_cigar[:-1]:
                            if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                                continue
                            else:
                                clip_pos += lenth
                        if abs(insertion_pos - clip_pos) <= clip_extnd:
                            cnt_clip += 1

                if insertion_pos not in m_rslts:
                    m_rslts[insertion_pos] = []
                irange = abs(rmost_region - lmost_region)
                m_rslts[insertion_pos].append((cnt_clip, 2 * clip_extnd, cnt_all_reads, irange, cnt_disc, cnt_all_2))
            samfile.close()
        sf_tmp_out = working_folder + chrm + global_values.ALLELE_FREQUENCY_SUFFIX
        with open(sf_tmp_out, "w") as fout_tmp:
            for ins_pos in m_rslts:
                cnt_clip = 0
                cnt_all = 0
                l_af = []
                l_af_disc = []
                for tmp_rcd in m_rslts[ins_pos]:
                    cnt_clip = tmp_rcd[0]
                    clip_range = tmp_rcd[1]
                    cnt_all = tmp_rcd[2]
                    all_range = tmp_rcd[3]
                    cnt_disc = tmp_rcd[4]
                    cnt_disc_all = tmp_rcd[5]

                    if cnt_all <= 0:
                        l_af.append(str(0.0))
                        l_af_disc.append(str(0.0))
                    else:
                        af = float(cnt_clip * all_range) / float(cnt_all * clip_range)
                        if af > 1.0:
                            af = 1.0
                        l_af.append(str(af))

                        af_disc = float(cnt_disc) / float(cnt_disc_all)
                        if af_disc > 1.0:
                            af_disc = 1.0
                        l_af_disc.append(str(af_disc))

                s_af = "\t".join(l_af)
                s_af_disc = "\t".join(l_af_disc)

                b_clip_satisfield = False
                for clip_af in l_af:
                    if float(clip_af) <= af_cutoff:
                        b_clip_satisfield = True
                        break
                b_disc_satisfield = False
                for disc_af in l_af_disc:
                    if float(disc_af) <= af_cutoff:
                        b_disc_satisfield = True
                        break
                if b_clip_satisfield == True and b_disc_satisfield == True:
                    s_info = "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n".format(chrm, ins_pos, cnt_clip, cnt_all, s_af, s_af_disc)
                    fout_tmp.write(s_info)
                    ####
#
    # Given:
    #   sf_bam_list: bam files
    #   sf_candidate_list: candidate sites
    #   #
    def calc_AF_by_clip_reads_of_given_list(self, sf_bam_list, sf_candidate_list, extnd, clip_slack, af, sf_out):
        m_chrm = {}
        with open(sf_candidate_list) as fin_list:
            for line in fin_list:
                fields = line.split()
                chrm = fields[0]
                m_chrm[chrm] = 1

        l_chrm_records = []
        for chrm in m_chrm:
            l_chrm_records.append((chrm, sf_bam_list, sf_candidate_list, extnd, clip_slack, af, self.working_folder))

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_calc_AF_by_clip_reads, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

        ####
        with open(sf_out, "w") as fout_rslt:
            for chrm in m_chrm:
                sf_tmp_out = self.working_folder + chrm + global_values.ALLELE_FREQUENCY_SUFFIX
                if os.path.isfile(sf_tmp_out) == False:
                    continue
                with open(sf_tmp_out) as fin_tmp:
                    for line in fin_tmp:
                        fout_rslt.write(line)

    def collect_clip_disc_features_of_given_list(self, sf_bam_list, sf_candidate_list, extnd, clip_slack, sf_out):
        m_chrm = {}
        with open(sf_candidate_list) as fin_list:
            for line in fin_list:
                fields = line.split()
                chrm = fields[0]
                m_chrm[chrm] = 1

        l_chrm_records = []
        for chrm in m_chrm:
            l_chrm_records.append((chrm, sf_bam_list, sf_candidate_list, extnd, clip_slack, self.working_folder))

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_collect_clip_disc_features, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()
####
        ####
        with open(sf_out, "w") as fout_rslt:
            for chrm in m_chrm:
                sf_tmp_out = self.working_folder + chrm + global_values.ALLELE_FREQUENCY_SUFFIX
                if os.path.isfile(sf_tmp_out) == False:
                    continue
                with open(sf_tmp_out) as fin_tmp:
                    for line in fin_tmp:
                        fout_rslt.write(line)

####
class XClipDiscFilter():
    def __init__(self, sf_bam_list, working_folder, n_jobs, sf_reference):
        self.sf_bam_list = sf_bam_list
        self.working_folder = working_folder
        self.n_jobs = n_jobs
        self.sf_reference = sf_reference

    def _get_n_bams(self):
        n_cnt = 0
        with open(self.sf_bam_list) as fin_list:
            for line in fin_list:
                if len(line.rstrip()) > 0:
                    n_cnt += 1
        return n_cnt

    ####
    def _cnt_clip_reads(self, ins_chrm, ins_pos, peak_clip_pos, m_clip_pos):
        nclip = 0
        if (ins_chrm not in m_clip_pos) or (ins_pos not in m_clip_pos[ins_chrm]):
            print("Error in cnt clip step, {0}:{1} not in the dict!!!".format(ins_chrm, ins_pos))
            return nclip
        for tmp_pos in m_clip_pos[ins_chrm][ins_pos]:
            if abs(tmp_pos - peak_clip_pos) <= global_values.CLIP_SEARCH_WINDOW:
                nclip += len(m_clip_pos[ins_chrm][ins_pos][tmp_pos])
        return nclip

    # count the number of disc reads of given site
    # m_disc in format: {chrm:{pos:[anchor_pos]}}
    def _cnt_disc_reads(self, ins_chrm, ins_pos, clip_pos, m_disc):
        nldisc = 0
        nrdisc = 0
        if (ins_chrm not in m_disc) or (ins_pos not in m_disc[ins_chrm]):
            print("Error in cnt disc step, {0}:{1} not in the dict!!!".format(ins_chrm, ins_pos))
            return 0, 0
        # print ins_chrm, ins_pos, clip_pos, m_disc[ins_chrm][ins_pos] ####################################################
        for tmp_pos in m_disc[ins_chrm][ins_pos]:
            if tmp_pos <= (clip_pos + 5):
                nldisc += 1
            if tmp_pos >= (clip_pos - 5):
                nrdisc += 1
        return nldisc, nrdisc

    # get the representative clip position
    def _refine_represent_clip_pos(self, m_list):
        m_refined_pos = {}
        for ins_chrm in m_list:
            for ins_pos in m_list[ins_chrm]:
                lpeak_pos = -1
                rpeak_pos = -1
                record = m_list[ins_chrm][ins_pos]
                if record[0] is not None:
                    lpeak_pos = record[0]
                if record[1] is not None:
                    rpeak_pos = record[1]
                refined_pos = lpeak_pos
                if lpeak_pos == -1 or lpeak_pos == None:
                    refined_pos = rpeak_pos
                if refined_pos==-1:
                    refined_pos=ins_pos
                if ins_chrm not in m_refined_pos:
                    m_refined_pos[ins_chrm] = {}
                m_refined_pos[ins_chrm][ins_pos] = refined_pos
        return m_refined_pos
####
    ####Note, for each recode, recode[1] will be skipped
    def dump_TEI_info(self, l_candidates, sf_final_list, b_with_head):
        with open(sf_final_list, "w") as fout_final_list:
            stitle1 = "#chrm\trefined-pos\tlclip-pos\trclip-pos\tTSD\tnalclip\tnarclip\tnaldisc\t"
            stitle2 = "nardisc\tnalpolyA\tnarpolyA\tlcov\trcov\tnlclip\tnrclip\tnldisc\tnrdisc\tnlpolyA\tnrpolyA\t"
            stitle3 = "lclip-cns-start:end\trclip_cns-start:end\tldisc-cns-start:end\trdisc-cns-start:end\t"
            stitle4 = "Transduction-info\tntsd-clip\tntsd-disc\tntsd-polyA\t"
            stitle5 = "ldisc-same\tldisc-diff\trdisc-same\trdisc-diff\n"
            stitle = stitle1 + stitle2 + stitle3 + stitle4 + stitle5
            if b_with_head == True:
                fout_final_list.write(stitle)
            for (ins_chrm, ins_pos, refined_pos, lpeak_pos, rpeak_pos, TSD, n_total_lclip, n_total_rclip,
                 n_total_ldisc, n_total_rdisc, n_total_lpolyA, n_total_rpolyA, flcov, frcov, nlclip, nrclip,
                 nldisc, nrdisc, nlpolyA, nrpolyA, rc_rcd_disc, anchor_rc_rcd, lc_cns_start, lc_cns_end, rc_cns_start,
                 rc_cns_end, ldisc_cns_start, ldisc_cns_end, rdisc_cns_start, rdisc_cns_end,
                 s_trsdct_info, n_clip_trsdct, n_disc_trsdct, n_polyA_trsdct) in l_candidates:
                # output in format:
                # #chrm    refined-pos   lclip-pos    rclip-pos TSD nalclip    narclip    naldisc
                # nardisc    nalpolyA   narpolyA    nlclip  nrclip  nldisc  nrdisc  nlpolyA nrpolyA
                # lclip-cns-start:end rclip_cns-start:end    ldisc-cns-start:end   rdisc-cns-start:end
                # Transduction-info  ntsd-clip  ntsd-disc ntsd-polyA
                s_pos = ins_chrm + "\t" + str(refined_pos) + "\t" + str(lpeak_pos) + "\t" + str(
                    rpeak_pos) + "\t" + str(TSD) + "\t"
                s_cnt_all = str(n_total_lclip) + "\t" + str(n_total_rclip) + "\t" + str(n_total_ldisc) + "\t" + str(
                    n_total_rdisc) + "\t" + str(n_total_lpolyA) + "\t" + str(n_total_rpolyA) + "\t" + str(flcov) + "\t" \
                            + str(frcov) + "\t"
                s_cnt = str(nlclip) + "\t" + str(nrclip) + "\t" + str(nldisc) + "\t" + str(nrdisc) + "\t" + str(
                    nlpolyA) + "\t" + str(nrpolyA) + "\t"
                s_cns_lclip = str(lc_cns_start) + ":" + str(lc_cns_end) + "\t"
                s_cns_rclip = str(rc_cns_start) + ":" + str(rc_cns_end) + "\t"
                s_cns_ldisc = str(ldisc_cns_start) + ":" + str(ldisc_cns_end) + "\t"
                s_cns_rdisc = str(rdisc_cns_start) + ":" + str(rdisc_cns_end) + "\t"
                s_transduct_out = s_trsdct_info + "\t" + str(n_clip_trsdct) + "\t" + str(n_disc_trsdct) + "\t" + \
                                  str(n_polyA_trsdct) + "\t"

                s_inv_info = self._is_3mer_inversion(rc_rcd_disc)
                s_rc_disc = str(rc_rcd_disc[0]) + "\t" + str(rc_rcd_disc[1]) + "\t" + str(rc_rcd_disc[2]) + "\t" + str(
                    rc_rcd_disc[3]) + "\t"+s_inv_info+"\t"

                s_anchor_rc=str(anchor_rc_rcd[0])+"\t"+str(anchor_rc_rcd[1])+"\t"+str(anchor_rc_rcd[2])+"\t"+\
                            str(anchor_rc_rcd[3])

                sinfo = s_pos + s_cnt_all + s_cnt + s_cns_lclip + s_cns_rclip + s_cns_ldisc + s_cns_rdisc \
                        + s_transduct_out + s_rc_disc + s_anchor_rc +"\n"
                fout_final_list.write(sinfo)
####
####
    def load_TEI_info_from_file(self, sf_tei):
        m_tei={}
        with open(sf_tei) as fin_tei:
            for line in fin_tei:
                fields=line.split()
                ins_chrm=fields[0]
                ins_pos=int(fields[1])
                nlclip=int(fields[6])
                nrclip=int(fields[7])
                nldisc=int(fields[8])
                nrdisc=int(fields[9])
                nlpolyA=int(fields[10])
                nrpolyA=int(fields[11])
                s_cns_lclip=fields[20]
                s_cns_rclip=fields[21]
                s_cns_ldisc=fields[22]
                s_cns_rdisc=fields[23]

                if ins_chrm not in m_tei:
                    m_tei[ins_chrm]={}
                m_tei[ins_chrm][ins_pos]=(nlclip, nrclip, nldisc, nrdisc, nlpolyA, nrpolyA, s_cns_lclip, s_cns_rclip,
                                          s_cns_ldisc, s_cns_rdisc)
        return m_tei
    ####

    #separate the output to transduction and non-transduction
    def sprt_TEI_to_td_non_td(self, sf_cns, sf_td, sf_non_td):
        with open(sf_cns) as fin_cns:
            with open(sf_td,"w") as fout_td, open(sf_non_td,"w") as fout_non_td:
                for line in fin_cns:
                    fields=line.split()
                    if len(fields)>=23 and (fields[23]== global_values.NOT_TRANSDUCTION):
                        l_fields=fields[23].split(":")
                        if len(l_fields)>1:
                            fout_td.write(line)
                        else:
                            fout_non_td.write(line)
                    else:
                        fout_td.write(line)

    # separate the output to transduction and non-transduction
    def sprt_TEI_to_td_orphan_non_td(self, sf_cns, sf_non_td, sf_td, sf_orphan):
        with open(sf_cns) as fin_cns:
            with open(sf_td, "w") as fout_td, open(sf_orphan, "w") as fout_orphan, open(sf_non_td, "w") as fout_non_td:
                for line in fin_cns:
                    fields = line.split()
                    if len(fields) >= 32 and (fields[32] == global_values.ORPHAN_TRANSDUCTION):
                        fout_orphan.write(line)
                    elif len(fields) >= 23 and (fields[23] == global_values.NOT_TRANSDUCTION):
                        l_fields = fields[23].split(":")
                        if len(l_fields) > 1:
                            fout_td.write(line)
                        else:
                            fout_non_td.write(line)
                    else:
                        fout_td.write(line)
####

    ####Note, for each recode, recode[1] will be skipped
    def dump_TEI_info_with_ori_pos(self, l_candidates, sf_final_list, b_with_head):
        with open(sf_final_list, "w") as fout_final_list:
            stitle1 = "#chrm\trefined-pos\tlclip-pos\trclip-pos\tTSD\tnalclip\tnarclip\tnaldisc\t"
            stitle2 = "nardisc\tnalpolyA\tnarpolyA\tlcov\trcov\tnlclip\tnrclip\tnldisc\tnrdisc\tnlpolyA\tnrpolyA\t"
            stitle3 = "lclip-cns-start:end\trclip_cns-start:end\tldisc-cns-start:end\trdisc-cns-start:end\t"
            stitle4 = "Transduction-info\tntsd-clip\tntsd-disc\tntsd-polyA\t"
            stitle5 = "ldisc-same\tldisc-diff\trdisc-same\trdisc-diff\n"
            stitle = stitle1 + stitle2 + stitle3 + stitle4 + stitle5
            if b_with_head == True:
                fout_final_list.write(stitle)
            for (ins_chrm, ins_pos, refined_pos, lpeak_pos, rpeak_pos, TSD, n_total_lclip, n_total_rclip,
                 n_total_ldisc, n_total_rdisc, n_total_lpolyA, n_total_rpolyA, flcov, frcov, nlclip, nrclip,
                 nldisc, nrdisc, nlpolyA, nrpolyA, rc_rcd_disc, anchor_rc_rcd, lc_cns_start, lc_cns_end, rc_cns_start,
                 rc_cns_end, ldisc_cns_start, ldisc_cns_end, rdisc_cns_start, rdisc_cns_end,
                 s_trsdct_info, n_clip_trsdct, n_disc_trsdct, n_polyA_trsdct) in l_candidates:
                # output in format:
                # #chrm    refined-pos   lclip-pos    rclip-pos TSD nalclip    narclip    naldisc
                # nardisc    nalpolyA   narpolyA    nlclip  nrclip  nldisc  nrdisc  nlpolyA nrpolyA
                # lclip-cns-start:end rclip_cns-start:end    ldisc-cns-start:end   rdisc-cns-start:end
                # Transduction-info  ntsd-clip  ntsd-disc ntsd-polyA
                s_pos = ins_chrm + "\t" + str(ins_pos) + "\t" + str(refined_pos) + "\t" + str(lpeak_pos) + "\t" + str(
                    rpeak_pos) + "\t" + str(TSD) + "\t"
                s_cnt_all = str(n_total_lclip) + "\t" + str(n_total_rclip) + "\t" + str(n_total_ldisc) + "\t" + str(
                    n_total_rdisc) + "\t" + str(n_total_lpolyA) + "\t" + str(n_total_rpolyA) + "\t" + str(flcov) + "\t" \
                            + str(frcov) + "\t"
                s_cnt = str(nlclip) + "\t" + str(nrclip) + "\t" + str(nldisc) + "\t" + str(nrdisc) + "\t" + str(
                    nlpolyA) + "\t" + str(nrpolyA) + "\t"
                s_cns_lclip = str(lc_cns_start) + ":" + str(lc_cns_end) + "\t"
                s_cns_rclip = str(rc_cns_start) + ":" + str(rc_cns_end) + "\t"
                s_cns_ldisc = str(ldisc_cns_start) + ":" + str(ldisc_cns_end) + "\t"
                s_cns_rdisc = str(rdisc_cns_start) + ":" + str(rdisc_cns_end) + "\t"
                s_transduct_out = s_trsdct_info + "\t" + str(n_clip_trsdct) + "\t" + str(n_disc_trsdct) + "\t" + \
                                  str(n_polyA_trsdct) + "\t"

                s_inv_info = self._is_3mer_inversion(rc_rcd_disc)
                s_rc_disc = str(rc_rcd_disc[0]) + "\t" + str(rc_rcd_disc[1]) + "\t" + str(rc_rcd_disc[2]) + "\t" + str(
                    rc_rcd_disc[3]) + "\t"+s_inv_info +"\t"

                s_anchor_rc = str(anchor_rc_rcd[0]) + "\t" + str(anchor_rc_rcd[1]) + "\t" + str(anchor_rc_rcd[2]) \
                              + "\t" + str(anchor_rc_rcd[3])

                sinfo = s_pos + s_cnt_all + s_cnt + s_cns_lclip + s_cns_rclip + s_cns_ldisc + s_cns_rdisc \
                        + s_transduct_out + s_rc_disc + s_anchor_rc+"\n"
                fout_final_list.write(sinfo)

    ####
    def _second_stage_classify_dump(self, m_ins_categories, l_candidates, m_high_confident, m_one_side_low_confident,
                                    m_hcov, m_not_hit_end, m_gntp_features, i_cns_lth, b_with_head, sf_final_list):
        sf_final_high_confident=sf_final_list+global_values.HIGH_CONFIDENT_SUFFIX
        with open(sf_final_list, "w") as fout_final_list, open(sf_final_high_confident, "w") as fout_high_confident:
            stitle1 = "#chrm\trefined-pos\tlclip-pos\trclip-pos\tTSD\tnalclip\tnarclip\tnaldisc\t"
            stitle2 = "nardisc\tnalpolyA\tnarpolyA\tlcov\trcov\tnlclip\tnrclip\tnldisc\tnrdisc\tnlpolyA\tnrpolyA\t"
            stitle3 = "lclip-cns-start:end\trclip_cns-start:end\tldisc-cns-start:end\trdisc-cns-start:end\t"
            stitle4 = "Transduction-info\tntsd-clip\tntsd-disc\tntsd-polyA\t"
            # reverse complementary record
            # each in format: (n_l_rc, n_l_not_rc, n_r_rc, n_r_not_rc)
            stitle5 = "ldisc-same\tldisc-diff\trdisc-same\trdisc-diff\t3mer-inversion\t"
            stitle6 = "confidential\tinsertion-length\n"
            stitle = stitle1 + stitle2 + stitle3 + stitle4 + stitle5 + stitle6
            if b_with_head == True:
                fout_final_list.write(stitle)
                fout_high_confident.write(stitle)
            for (ins_chrm, ins_pos, refined_pos, lpeak_pos, rpeak_pos, TSD, n_total_lclip, n_total_rclip,
                 n_total_ldisc, n_total_rdisc, n_total_lpolyA, n_total_rpolyA, flcov, frcov, nlclip, nrclip,
                 nldisc, nrdisc, nlpolyA, nrpolyA, rc_rcd_disc, anchor_rc_rcd, lc_cns_start, lc_cns_end, rc_cns_start,
                 rc_cns_end, ldisc_cns_start, ldisc_cns_end, rdisc_cns_start, rdisc_cns_end,
                 s_trsdct_info, n_clip_trsdct, n_disc_trsdct, n_polyA_trsdct) in l_candidates:
                # output in format:
                # #chrm    refined-pos   lclip-pos    rclip-pos TSD nalclip    narclip    naldisc
                # nardisc    nalpolyA   narpolyA  lcov  rcov  nlclip  nrclip  nldisc  nrdisc  nlpolyA nrpolyA
                # lclip-cns-start:end rclip_cns-start:end    ldisc-cns-start:end   rdisc-cns-start:end
                # Transduction-info  ntsd-clip  ntsd-disc ntsd-polyA
                # (3'-inversion-info) ldisc-same ldisc-diff rdisc-same rdisc-diff
                # (extra-info) "high-confident"/""

                s_pos = ins_chrm + "\t" + str(refined_pos) + "\t" + str(lpeak_pos) + "\t" + str(
                    rpeak_pos) + "\t" + str(TSD) + "\t"
                s_cnt_all = str(n_total_lclip) + "\t" + str(n_total_rclip) + "\t" + str(
                    n_total_ldisc) + "\t" + str(
                    n_total_rdisc) + "\t" + str(n_total_lpolyA) + "\t" + str(n_total_rpolyA) + "\t" + str(
                    flcov) + "\t" \
                            + str(frcov) + "\t"
                s_cnt = str(nlclip) + "\t" + str(nrclip) + "\t" + str(nldisc) + "\t" + str(nrdisc) + "\t" + str(
                    nlpolyA) + "\t" + str(nrpolyA) + "\t"
                s_cns_lclip = str(lc_cns_start) + ":" + str(lc_cns_end) + "\t"
                s_cns_rclip = str(rc_cns_start) + ":" + str(rc_cns_end) + "\t"
                s_cns_ldisc = str(ldisc_cns_start) + ":" + str(ldisc_cns_end) + "\t"
                s_cns_rdisc = str(rdisc_cns_start) + ":" + str(rdisc_cns_end) + "\t"
                s_transduct_out = s_trsdct_info + "\t" + str(n_clip_trsdct) + "\t" + str(n_disc_trsdct) + "\t" + \
                                  str(n_polyA_trsdct) + "\t"

                s_inv_info = self._is_3mer_inversion(rc_rcd_disc)
                s_rc_disc = str(rc_rcd_disc[0]) + "\t" + str(rc_rcd_disc[1]) + "\t" + str(rc_rcd_disc[2]) + "\t" + \
                            str(rc_rcd_disc[3]) + "\t" + s_inv_info + "\t"
####
                s_anchor_rc = "\t"+ str(anchor_rc_rcd[0]) + "\t" + str(anchor_rc_rcd[1]) + "\t" + str(anchor_rc_rcd[2]) \
                              + "\t" + str(anchor_rc_rcd[3])
                #here mark those have two side polyA cases as a seperate category (low confident)
                b_polyA_dominant=False
                n_raw_lclip=n_total_lclip
                n_raw_rclip=n_total_rclip

                #save a special fields to indicates whether hit the end of the consensus
                s_hit_end="\t"+global_values.HIT_END_OF_CNS
                if (ins_chrm in m_not_hit_end) and (ins_pos in m_not_hit_end[ins_chrm]):
                    s_hit_end="\t"+global_values.NOT_HIT_END_OF_CNS

                #save a fields for both end consistent
                s_both_consistent="\t"+ONE_END_CONSISTNT
                if (ins_chrm in m_high_confident) and (ins_pos in m_high_confident[ins_chrm]):
                    s_both_consistent="\t"+global_values.BOTH_END_CONSISTNT

                #save features for genotyping
                sf_gntp_info = ""
                if (ins_chrm in m_gntp_features) and (ins_pos in m_gntp_features[ins_chrm]):
                    tmp_rcd=m_gntp_features[ins_chrm][ins_pos]
                    n_af_clip=m_gntp_features[ins_chrm][ins_pos][0]
                    n_full_map=m_gntp_features[ins_chrm][ins_pos][1]
                    n_raw_lclip=m_gntp_features[ins_chrm][ins_pos][2]
                    n_raw_rclip = m_gntp_features[ins_chrm][ins_pos][3]
                    n_disc_pairs = m_gntp_features[ins_chrm][ins_pos][4]
                    n_concd_pairs= m_gntp_features[ins_chrm][ins_pos][5]
                    n_disc_large_indel= m_gntp_features[ins_chrm][ins_pos][6]
                    s_clip_lens= m_gntp_features[ins_chrm][ins_pos][7]
                    sf_gntp_info="\t{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}".format(
                        n_af_clip, n_full_map, n_raw_lclip, n_raw_rclip, n_disc_pairs, n_concd_pairs,
                        n_disc_large_indel, s_clip_lens)
                else:#because some sites with extremly large number of clipped reads at breakpoints, and are filtered out
                    continue
                if (n_raw_lclip+n_raw_rclip>0) and (float(n_total_lpolyA+n_total_rpolyA)/float(n_raw_lclip+n_raw_rclip)) \
                        > global_values.MAX_POLYA_RATIO:
                    b_polyA_dominant=True

                s_extra_info=""
                s_tmp_id="{0}{1}{2}".format(ins_chrm, global_values.SEPERATOR, ins_pos)
                b_high_confident=False
                if s_tmp_id in m_ins_categories[global_values.TWO_SIDE_TPRT_BOTH]:
                    if b_polyA_dominant == True:
                        s_extra_info = global_values.TWO_SIDE_POLYA_DOMINANT
                    else:
                        s_extra_info=global_values.TWO_SIDE_TPRT_BOTH
                    b_high_confident=True
                elif s_tmp_id in m_ins_categories[global_values.TWO_SIDE_TPRT]:
                    if b_polyA_dominant == True:
                        s_extra_info = global_values.TWO_SIDE_POLYA_DOMINANT
                    else:
                        s_extra_info =global_values.TWO_SIDE_TPRT
                    b_high_confident = True
                elif s_tmp_id in m_ins_categories[global_values.TWO_SIDE]:
                    b_high_confident = True
                    if b_polyA_dominant == True:
                        s_extra_info = global_values.TWO_SIDE_POLYA_DOMINANT
                        b_high_confident = False
                    else:
                        s_extra_info = global_values.TWO_SIDE

                elif s_trsdct_info!=global_values.NOT_TRANSDUCTION:
                    s_extra_info=global_values.ONE_SIDE_TRSDCT
                elif s_tmp_id in m_ins_categories[global_values.ONE_HALF_SIDE]:
                    s_extra_info=global_values.ONE_HALF_SIDE
                    b_high_confident = True
                    if b_polyA_dominant == True:#polyA dorminant
                        s_extra_info=global_values.ONE_HALF_SIDE_POLYA_DOMINANT
                        b_high_confident =False
                    elif s_tmp_id in m_ins_categories[global_values.ONE_HALF_SIDE_TRPT_BOTH]:
                        s_extra_info=global_values.ONE_HALF_SIDE_TRPT_BOTH
                    elif s_tmp_id in m_ins_categories[global_values.ONE_HALF_SIDE_TRPT]:
                        s_extra_info =global_values.ONE_HALF_SIDE_TRPT

                elif s_tmp_id in m_ins_categories[global_values.ONE_SIDE]:
                    s_extra_info = global_values.ONE_SIDE
                    if (ins_chrm in m_one_side_low_confident) and (ins_pos in m_one_side_low_confident[ins_chrm]):
                        s_extra_info=global_values.ONE_SIDE_COVERAGE_CONFLICT

                elif s_tmp_id in m_ins_categories[global_values.HIGH_COV_ISD]:
                    s_extra_info=global_values.HIGH_COV_ISD
                else:
                    s_extra_info =global_values.OTHER_TYPE

                if s_trsdct_info == global_values.ONE_SIDE_FLANKING:
                    if global_values.IS_CALL_SVA==True:
                        b_high_confident=True
                    s_extra_info=global_values.ONE_SIDE_FLANKING
                    s_trsdct_info=global_values.NOT_TRANSDUCTION

                i_tei_lth = self._get_insertion_length(ldisc_cns_start, ldisc_cns_end, rdisc_cns_start,
                                                       rdisc_cns_end,
                                                       i_cns_lth, s_trsdct_info)
                s_lenth_info = "\t"+str(i_tei_lth)

                sinfo = s_pos + s_cnt_all + s_cnt + s_cns_lclip + s_cns_rclip + s_cns_ldisc + s_cns_rdisc \
                        + s_transduct_out + s_rc_disc + s_extra_info + s_both_consistent + \
                        s_hit_end + sf_gntp_info + s_anchor_rc + s_lenth_info + "\n"
                fout_final_list.write(sinfo)
                if b_high_confident==True:
                    fout_high_confident.write(sinfo)

####Note:the length is re-estiamted (refined) at xtea_parser.replace_ins_length (x_post_filter.py)
    def _get_insertion_length(self, ldisc_cns_start, ldisc_cns_end, rdisc_cns_start, rdisc_cns_end, icns_lth, stsdc):
        i_tei_len=-1

        if ldisc_cns_end==-1 and rdisc_cns_start>0:
            i_tei_len=icns_lth-rdisc_cns_start
        elif rdisc_cns_end==-1 and ldisc_cns_start>0:
            i_tei_len = icns_lth - ldisc_cns_start
        elif rdisc_cns_end<0 and ldisc_cns_start<0:
            i_tei_len = -1
        else:
            if stsdc == global_values.NOT_TRANSDUCTION:
                if ldisc_cns_start>0 and rdisc_cns_start>0:
                    i_tei_len = rdisc_cns_end - ldisc_cns_start
                    if i_tei_len < 0:
                        i_tei_len = ldisc_cns_end - rdisc_cns_start

            else:
                if ldisc_cns_start<rdisc_cns_start:
                    i_tei_len=icns_lth-ldisc_cns_start
                else:
                    i_tei_len = icns_lth - rdisc_cns_start
        return i_tei_len

####
    def _is_3mer_inversion(self, rc_rcd_disc):
        n_l_ff = rc_rcd_disc[0]
        n_l_fr = rc_rcd_disc[1]
        n_r_ff = rc_rcd_disc[2]
        n_r_fr = rc_rcd_disc[3]
        b_l_ff = True
        if n_l_fr > n_l_ff:
            b_l_ff = False
        b_r_ff = True
        if n_r_fr > n_r_ff:
            b_r_ff = False
        if (b_l_ff==True and b_r_ff==True) or (b_l_ff==False and b_r_ff==False):
            return global_values.NOT_FIVE_PRIME_INV
        else:
            return global_values.FIVE_PRIME_INVERSION

####
    # m_list: candidate list
    # m_clip_lpos, m_clip_rpos: left and right clip position
    # m_disc_anchor_pos: map positions of the discord anchor reads
    # m_polyA in format: {chrm:{pos:[nleft, nright]}}
    # m_disc_peak: save the peak [start,end] positions on the consensus
    def _extract_detailed_info_TEI(self, m_disc_filtered, m_disc_bf_filter, m_clip_lpos, m_clip_rpos, m_polyA,
                                   m_clip_checked_list, m_transduct_info, m_rescued_n_src):
        l_candidates = []
        #m_new_old_match={}
        for ins_chrm in m_disc_filtered:
            for ins_pos in m_disc_filtered[ins_chrm]:
                nlclip = 0  # number of left clipped reads
                nrclip = 0  # number of right clipped reads
                nlpolyA = 0  # number of left polyA reads
                nrpolyA = 0  # number of right polyA reads
                istart_in_rep = 0  # start position in the consensus (based on the cluster of disc reads)
                n_total_lclip = 0
                n_total_rclip = 0
                n_total_ldisc = 0
                n_total_rdisc = 0
                n_total_lpolyA = 0
                n_total_rpolyA = 0
                lpeak_pos = -1
                rpeak_pos = -1
                record = m_disc_bf_filter[ins_chrm][ins_pos]
                if record[0] is not None:
                    lpeak_pos = record[0]
                if record[1] is not None:
                    rpeak_pos = record[1]

                # count the number of left-clipped and right-clipped reads
                if lpeak_pos > 0:
                    nlclip = self._cnt_clip_reads(ins_chrm, ins_pos, lpeak_pos, m_clip_lpos)
                    n_total_lclip += nlclip
                if rpeak_pos > 0:
                    nrclip = self._cnt_clip_reads(ins_chrm, ins_pos, rpeak_pos, m_clip_rpos)
                    n_total_rclip += nrclip
                # number of left and right polyA reads
                if (ins_chrm in m_polyA) and (ins_pos in m_polyA[ins_chrm]):
                    nlpolyA = m_polyA[ins_chrm][ins_pos][0]
                    nrpolyA = m_polyA[ins_chrm][ins_pos][1]
                    n_total_lpolyA += nlpolyA
                    n_total_rpolyA += nrpolyA
                    nlpolyA_seqA = m_polyA[ins_chrm][ins_pos][2]
                    nrpolyA_seqA = m_polyA[ins_chrm][ins_pos][3]
                    if nlpolyA_seqA < (nlpolyA-nlpolyA_seqA):#polyA < polyT
                        nlpolyA=-1*nlpolyA#negative means mainly polyT rather than polyA
                    if nrpolyA_seqA < (nrpolyA - nrpolyA_seqA):  # polyA < polyT
                        nrpolyA=-1*nrpolyA#negative means mainly polyT rather than polyA

                # start-end position on the consensus of the clipped parts
                lc_cns_start = -1
                lc_cns_end = -1
                rc_cns_start = -1
                rc_cns_end = -1
                if (ins_chrm in m_clip_checked_list) and (ins_pos in m_clip_checked_list[ins_chrm]):
                    lc_cns_start = m_clip_checked_list[ins_chrm][ins_pos][2]
                    lc_cns_end = m_clip_checked_list[ins_chrm][ins_pos][3]
                    rc_cns_start = m_clip_checked_list[ins_chrm][ins_pos][4]
                    rc_cns_end = m_clip_checked_list[ins_chrm][ins_pos][5]

                ####
                # check the transduction events, and correct the "peak-pos" on the reference
                b_trsdct = False
                b_ltrsdct = False  # is left transduct
                n_clip_trsdct = 0
                n_disc_trsdct = 0
                ref_clip_pos_transduct = -1
                n_polyA_trsdct = 0
                s_trsdct_info = global_values.NOT_TRANSDUCTION
                if (ins_chrm in m_transduct_info) and (ins_pos in m_transduct_info[ins_chrm]):
                    b_trsdct = True
                    s_trsdct_info = m_transduct_info[ins_chrm][ins_pos][0]
                    b_ltrsdct, n_clip_trsdct, ref_clip_pos_transduct, n_disc_trsdct, n_polyA_trsdct = \
                        m_transduct_info[ins_chrm][ins_pos][1]
                if b_trsdct == True:
                    if b_ltrsdct == True:
                        if n_clip_trsdct > nlclip:
                            lpeak_pos = ref_clip_pos_transduct

                        n_total_lclip += n_clip_trsdct
                        n_total_rdisc += n_disc_trsdct
                        n_total_lpolyA += n_polyA_trsdct
                    else:
                        if n_clip_trsdct > nrclip:
                            rpeak_pos = ref_clip_pos_transduct
                        n_total_rclip += n_clip_trsdct
                        n_total_ldisc += n_disc_trsdct
                        n_total_rpolyA += n_polyA_trsdct

                ####save the rescued cases
                if (ins_chrm in m_rescued_n_src) and (ins_pos in m_rescued_n_src[ins_chrm]):
                    s_trsdct_info=global_values.ONE_SIDE_FLANKING
                    n_rsc_lclip, n_rsc_rclip, n_rsc_disc=m_rescued_n_src[ins_chrm][ins_pos]
                    n_disc_trsdct=n_rsc_disc #save to the transuction field
                    if n_rsc_lclip>n_rsc_rclip:
                        n_clip_trsdct=n_rsc_lclip #save to the transuction field
                        n_total_lclip += n_rsc_lclip
                        n_total_rdisc += n_rsc_disc
                    else:
                        n_clip_trsdct = n_rsc_rclip #save to the transuction field
                        n_total_rclip += n_rsc_lclip
                        n_total_ldisc += n_rsc_disc

                TSD = -1
                if lpeak_pos > 0 and rpeak_pos > 0:
                    TSD = abs(rpeak_pos - lpeak_pos)

                refined_pos = lpeak_pos
                if lpeak_pos == -1 or lpeak_pos == None or n_total_rclip > n_total_lclip:
                    refined_pos = rpeak_pos

                # count the number of left and right disc reads
                # start-end position on the consensus of the disc reads
                disc_record = m_disc_filtered[ins_chrm][ins_pos]
                nldisc = disc_record[0]  # number of left disc reads
                n_total_ldisc += nldisc
                ldisc_cns_start = disc_record[1]
                ldisc_cns_end = disc_record[2]
                nrdisc = disc_record[3]  # number of right disc reads
                n_total_rdisc += nrdisc
                rdisc_cns_start = disc_record[4]
                rdisc_cns_end = disc_record[5]
                # reverse complementary record
                # each in format: (n_l_rc, n_l_not_rc, n_r_rc, n_r_not_rc)
                rc_rcd = disc_record[6]
                anchor_dir_rcd=disc_record[7]
                flcov = 0.0
                frcov = 0.0
                ####
                lrcd = list((ins_chrm, ins_pos, refined_pos, lpeak_pos, rpeak_pos, TSD, n_total_lclip, n_total_rclip,
                             n_total_ldisc, n_total_rdisc, n_total_lpolyA, n_total_rpolyA, flcov, frcov, nlclip,
                             nrclip, nldisc, nrdisc, nlpolyA, nrpolyA, rc_rcd, anchor_dir_rcd, lc_cns_start, lc_cns_end,
                             rc_cns_start, rc_cns_end, ldisc_cns_start, ldisc_cns_end, rdisc_cns_start, rdisc_cns_end,
                             s_trsdct_info, n_clip_trsdct, n_disc_trsdct, n_polyA_trsdct))
                l_candidates.append(lrcd)
                # if ins_chrm not in m_new_old_match:
                #     m_new_old_match[ins_chrm]={}
                # m_new_old_match[ins_chrm][refined_pos]=ins_pos
        return l_candidates

    ####

    # given two window, check whether they are within the
    def _is_distance_consistency(self, lstart, lend, rstart, rend, i_is):
        idist = i_is / 2 + 1
        lstart = lstart - idist
        lend = lend + idist
        rstart = rstart - idist
        rend = rend + idist
        # check whether there is overlap
        if (lstart >= rstart and lstart <= rend) or (lend >= rstart and lend <= rend):
            return True
        else:
            return False

    # is the left and right read depth are differ a lot (>= ratio)?
    def _is_depth_differ(self, flcov, frcov, b_left, ratio):
        b_differ = False
        if b_left == True:  # left is deletion
            if frcov <= 0:
                b_differ = False
            elif (frcov - flcov) / frcov >= ratio:
                b_differ = True
        else:  # right is deletion
            if flcov <= 0:
                b_differ = False
            elif (flcov - frcov) / flcov >= ratio:
                b_differ = True
        return b_differ

    # if the number <ncutoff, then will not check the consistency
    ###!!!!!!!!!!!!!!!
    ##Note: In some case TEI happen with SVs like inversion, where no coverage differ, then these will be filtered out
    def filter_by_clip_disc_polyA_consistency(self, l_candidates, m_coverage, i_is, nclip_cutoff, ndisc_cutoff,
                                              min_cns_end, depth_ratio, xlog, f_log):
        l_selected = []
        m_high_confident={}
        m_one_side_low_confident={}
        m_not_hit_end={}#save the cases that doesn't hit the end of consensus
        for record in l_candidates:
            ins_chrm = record[0]
            ins_pos = record[1]
            refined_pos=record[2]
            nlclip = record[6]
            nrclip = record[7]
            nldisc = record[8]
            nrdisc = record[9]
            nlpolyA = record[10]
            nrpolyA = record[11]

            ilclip_start = record[-12]
            ilclip_end = record[-11]
            irclip_start = record[-10]
            irclip_end = record[-9]
            ildisc_start = record[-8]
            ildisc_end = record[-7]
            irdisc_start = record[-6]
            irdisc_end = record[-5]
            s_trsdct_info = record[-4]
            flcov = m_coverage[ins_chrm][ins_pos][0]
            frcov = m_coverage[ins_chrm][ins_pos][1]
            record[12] = flcov  # revise the left local depth
            record[13] = frcov  # revise the right local depth

            # if flcov>=max_depth or frcov>=max_depth:
            #     if ins_chrm not in m_high_coverage:
            #         m_high_coverage[ins_chrm]={}
            #     m_high_coverage[ins_chrm][ins_pos]=[flcov, frcov]

            # 1.3 if have deletion happen at one side, then should consistent with the read depth
            bl_depth_differ = self._is_depth_differ(flcov, frcov, True, depth_ratio)  # left deletion
            br_depth_differ = self._is_depth_differ(flcov, frcov, False, depth_ratio)  # right deletion

            b_transduction = False
            if s_trsdct_info != global_values.NOT_TRANSDUCTION:
                b_transduction = True
            # for now pass all the transductions, also the rescued ones
            # if transduction, then not consdier deletion events
            if b_transduction == True:
                if bl_depth_differ == True or br_depth_differ == True:
                    xlog.append_to_file(f_log, "{0}:{1} is filtered out: it's called as candidate transduction, "
                                               "but left and right coverage are different!\n".format(ins_chrm, ins_pos))
                    continue
                else:
                    l_selected.append(record)
                    xlog.append_to_file(f_log, "{0}:{1} is selected as transduction (or one side in flanking region)"
                                               " event!\n".format(ins_chrm, ins_pos))
                    continue
####
            bl_partial = False
            br_partial = False
            if nldisc < ndisc_cutoff and nrclip<=0:  ###num of clip and discordant reads smaller than threshold
                bl_partial = True
            if nrdisc < ndisc_cutoff and nlclip<=0:
                br_partial = True
            if bl_partial == True:  # left is deletion (or other type of SV)
                if bl_depth_differ == False:
                    xlog.append_to_file(f_log, "{0}:{1} is filtered out: no left side feature, but coverage for "
                                               "left and right are similar!\n".format(ins_chrm, ins_pos))
                    if ins_chrm not in m_one_side_low_confident:#save as low confident
                        m_one_side_low_confident[ins_chrm]={}
                    m_one_side_low_confident[ins_chrm][ins_pos]=1
                    #continue
            if br_partial == True:  # right is deletion (or other type of SV)
                if br_depth_differ == False:
                    xlog.append_to_file(f_log, "{0}:{1} is filtered out: no right side feature, but coverage for "
                                               "left and right are similar!\n".format(ins_chrm, ins_pos))
                    if ins_chrm not in m_one_side_low_confident:#save as low confident
                        m_one_side_low_confident[ins_chrm]={}
                    m_one_side_low_confident[ins_chrm][ins_pos]=1
                    #continue
####
            # 1. check clip-disc consistency
            # 1.1 position consistency
            bl_consist = False
            br_consist = False
            b_both_end_consist=False
            # Note here: left clip is corresponded to right disc
            if nlclip >= nclip_cutoff and nrdisc >= ndisc_cutoff:
                bl_consist = self._is_distance_consistency(ilclip_start, ilclip_end, irdisc_start, irdisc_end, i_is)
                # print record[0], record[1], nlclip_start, nlclip_end, nrdisc_start, nrdisc_end, i_is, "left", bl_consist
            if nrclip >= nclip_cutoff and nldisc >= ndisc_cutoff:
                br_consist = self._is_distance_consistency(irclip_start, irclip_end, ildisc_start, ildisc_end, i_is)
                # print record[0], record[1], nrclip_start, nrclip_end, nldisc_start, nldisc_end, i_is, "right", br_consist
            #skip SVA, as VNTR expansion may cause copy length is different
            if bl_consist == False and br_consist == False and global_values.IS_CALL_SVA==False:
                xlog.append_to_file(f_log, "{0}:{1} is filtered out: Neither of the sides are"
                                           " consistent!\n".format(ins_chrm, ins_pos))
                continue
            elif bl_consist == True and br_consist == True:
                b_both_end_consist=True
                # 1.2 If not partial clip or disc, then both should be consistent
                # if nlclip >= ncutoff and nrdisc >= ncutoff and nrclip >= ncutoff and nldisc >= ncutoff:
                #     if bl_consist==False or br_consist==False:
                #         continue
            ####
            # 1.3 if have the side-clip, but no side-disc, then filter out
            if (nlclip >= nclip_cutoff and nrdisc < ndisc_cutoff) and (nrclip >= nclip_cutoff and nldisc < ndisc_cutoff):
                xlog.append_to_file(f_log, "{0}:{1} is filtered out: Have both side clipped reads, "
                                           "but don't have enough discordant support!\n".format(ins_chrm, ins_pos))
                continue

            b_tailed_disc = False
            if ildisc_end >= min_cns_end or irdisc_end >= min_cns_end:
                b_tailed_disc = True
            b_tailed_clip = False
            if ilclip_end >= min_cns_end or irclip_end >= min_cns_end:
                b_tailed_clip = True
            b_partial_disc = False
            if nldisc < ndisc_cutoff or nrdisc < ndisc_cutoff:
                b_partial_disc = True

            # 2. check polyA consistency
            if nlpolyA == 0 and nrpolyA == 0  and global_values.GLOBAL_RNA_MEDIATED == True:
                b_both_end_consist = False
                # there are some cases polyA is really short, so we also check whether hit the end of cns
                if nlclip >= nclip_cutoff and nrclip >= nclip_cutoff and (b_tailed_disc==False and b_tailed_clip==False):
                    xlog.append_to_file(f_log, "{0}:{1} is filtered out: Have both side clipped reads, "
                                               "but no polyA!\n".format(ins_chrm, ins_pos))
                    continue

            # 3. At least one disc end reach the end part of the consensus, unless one-side-clip or one-side-discord
            # here also check clip reads and coverage differ
            if bl_depth_differ == False and nrclip < nclip_cutoff:  # left deletion
                bl_depth_differ = self._is_depth_differ(flcov, frcov, True, depth_ratio)
            if br_depth_differ == False and nlclip < nclip_cutoff:  # right deletion
                br_depth_differ = self._is_depth_differ(flcov, frcov, False, depth_ratio)
            b_partial_clip = False
            if (nlclip < nclip_cutoff and br_depth_differ == True) or (nrclip < nclip_cutoff and bl_depth_differ == True):
                b_partial_clip = True

            if b_tailed_disc == False and b_partial_disc == False and b_tailed_clip == False and b_partial_clip == False:
                xlog.append_to_file(f_log, "{0}:{1} is filtered out: {2} {3} {4} {5}!\n".format(ins_chrm, ins_pos, min_cns_end, ildisc_end, irdisc_end, ilclip_end, irclip_end))
                xlog.append_to_file(f_log, "{0}:{1} is filtered out: Disc or clip cluster doesn't reach the end of cns"
                                           "!\n".format(ins_chrm, ins_pos))
                continue

            l_selected.append(record)
            #both clip and disc doesn't reach the end
            if b_tailed_clip==False and b_tailed_disc==False:
                if ins_chrm not in m_not_hit_end:
                    m_not_hit_end[ins_chrm]={}
                m_not_hit_end[ins_chrm][ins_pos]=1

            if b_both_end_consist==True:
                if ins_chrm not in m_high_confident:
                    m_high_confident[ins_chrm]={}
                m_high_confident[ins_chrm][refined_pos]=1
        return l_selected, m_high_confident, m_one_side_low_confident, m_not_hit_end

####
    def clean_file_by_path(self, sf_path):
        if os.path.isfile(sf_path)==True:
            os.remove(sf_path)

    ####
    #this function is called at the somatic calling step, with given sites and control bam, check whether:
    #1. there are clip cluster
    #2. there are disc cluster
    #3. count # of clippe reads aligned to consensus
    #4. count # of disc reads aligned to consensus
    def call_clip_disc_cluster(self, sf_candidate_list, extnd, bin_size, sf_rep_cns, bmapped_cutoff,
                               i_concord_dist, f_concord_ratio, nclip_cutoff, ndisc_cutoff, working_folder, sf_out):
        # collect the clipped and discordant reads
        # each record in format like: @20~41951715~L~1~41952104~0~0,
        # (chrm, map_pos, global_values.FLAG_LEFT_CLIP, is_rc, insertion_pos, n_cnt_clip, sample_id)
        sf_clip_fq = working_folder + "candidate_sites_all_clip_from_control.fq"
        sf_disc_fa = working_folder + "candidate_sites_all_disc_from_control.fa"
        self.collect_clipped_disc_reads(sf_candidate_list, extnd, bin_size, sf_clip_fq, sf_disc_fa)
        # # ##re-align the clipped reads
        bwa_align = BWAlign(global_values.BWA_PATH, global_values.BWA_REALIGN_CUTOFF, self.n_jobs)
        sf_clip_algnmt = working_folder + "temp_clip.sam"

        bwa_align.realign_clipped_read_with_polyA(sf_rep_cns, sf_clip_fq, sf_clip_algnmt)
        self.clean_file_by_path(sf_clip_fq)

        # ##re-align the disc reads
        sf_disc_algnmt = working_folder + "temp_disc.sam"
        bwa_align.realign_disc_reads(sf_rep_cns, sf_disc_fa, sf_disc_algnmt)
        self.clean_file_by_path(sf_disc_fa)

        m_ins_lpos, m_ins_rpos, m_cns_lpos, m_cns_rpos, m_clip_sample, m_polyA = \
            self.parse_clip_realignment_consensus(sf_clip_algnmt, bmapped_cutoff)

        idist = global_values.CLIP_SEARCH_WINDOW  # count number of clipped reads within this range (default 15)
        # at lease "ratio" percent of the clipped reads are clipped within the region
        ratio = global_values.CLIP_CONSISTENT_RATIO
        # Each returned record in format: (l_peak_pos, r_peak_pos, cns_peak_start, cns_peak_end)
        EXD_BIN_SIZE = idist
        # 1. check clip consistency
        # check left side and right side seperately: Check whether they form cluster (> ratio of reads within a cluster)
        # here require lclip+rclip<=nclip_cutoff, and if lclip or rclip is zero, then use half of this value
        m_clip_checked_list, m_clip_only_cluster = self.check_clip_alone_consistency_for_somatic(
            m_ins_lpos, m_ins_rpos, sf_candidate_list, idist, ratio, nclip_cutoff, EXD_BIN_SIZE)
####################temp usage###############
        with open(sf_out+".tmp_clip_chk.txt", "w") as fout_clip:
            for ins_chrm in m_clip_checked_list:
                for ins_pos in m_clip_checked_list[ins_chrm]:
                    s_tmp1=str(m_clip_checked_list[ins_chrm][ins_pos][2])
                    s_tmp2 = str(m_clip_checked_list[ins_chrm][ins_pos][3])
                    s_tmp3 = str(m_clip_checked_list[ins_chrm][ins_pos][4])
                    s_tmp4 = str(m_clip_checked_list[ins_chrm][ins_pos][5])
                    s_tmp_info=s_tmp1+":"+s_tmp2+"\t"+s_tmp3+":"+s_tmp4
                    fout_clip.write(ins_chrm+"\t"+str(ins_pos)+"\t"+s_tmp_info+"\n")
##############################################

        # 2.1 This is only parse the alignment to count the number
        # disc map position on the repeat consensus
        ####In format: m_rep_pos_disc[ins_chrm][ins_pos].append((anchor_map_pos, pos_in_consensus))
        ####Note that: use the middle-map-pos of a read as the pos_in_consensus
        # m_rep_pos_disc, each record in format: (anchor_map_pos, pos_in_consensus, b_rc)
        # m_disc_anchor_dir[ins_chrm][ins_pos]: save (l_disc_rc[i_anchor_pos], l_disc_not_rc[i_anchor_pos])
        m_rep_pos_disc, m_disc_sample, m_disc_polyA = \
            self.parse_disc_algnmt_consensus(sf_disc_algnmt, bmapped_cutoff)

        ####Potential problem: some sample may be of low coverage, in this way, ndisc_cutoff should be an array based on cov
        #########!!!!!!!!!!!!!In to-do-list
        # 2.2 check whether all the samples have enough disc reads support
        n_disc_half_cutoff = ndisc_cutoff / 2  # here cutoff value, should be an arrary for each sample, here is arbitary
        nclip_half_cutoff = nclip_cutoff / 2
        m_disc_consist_list = None
        if global_values.CHECK_BY_SAMPLE == True:
            m_disc_consist_list = self.check_disc_sample_consistency(m_clip_checked_list, m_disc_sample,
                                                                     n_disc_half_cutoff)
        else:
            m_disc_consist_list = dict(m_clip_checked_list)

        ##get the representative clip position
        m_represent_clip_pos = self._refine_represent_clip_pos(m_disc_consist_list)

        # 2.3 Filter by checking whether discordant reads form clusters
        # First, check whether left and right form seperate cluster (>f_concord_ratio disc reads suport that)
        # Then, if both ends form cluster, then total number of disc reads should > ndisc_cutoff
        # m_disc_filtered format: [ins_chrm][ins_pos] = (n_l_disc, lcns_start, lcns_end, n_r_disc, rcns_start, rcns_end)
        m_disc_filtered = self.check_seprt_disc_consistency(m_represent_clip_pos, m_rep_pos_disc,
                                                            i_concord_dist, f_concord_ratio, ndisc_cutoff)
        m_transdct_info = {}  # by default, this is empty
        # l_candidates: [(ins_chrm, ins_pos, refined_pos, ...), ...]
        # keep ins_chrm, and ins_pos to keep 1-1 match between dicts
        m_rescued = {}
        l_candidates = self._extract_detailed_info_TEI(m_disc_filtered, m_disc_consist_list, m_ins_lpos, m_ins_rpos,
                                                       m_polyA, m_clip_checked_list, m_transdct_info, m_rescued)
        b_with_head = False
        self.dump_TEI_info_with_ori_pos(l_candidates, sf_out, b_with_head)#keep the insertion position unchanged
        return m_clip_only_cluster

####

####
    ####
    # Note: sf_rep_copies are copies with two end flank regions
    # this version align the reads to the consensus
    #Parameters:
    # 1. bmapped_cutoff: by default 0.7, if more than half of the bases are mapped, then view the read is mapped (to cns)
    # 2. i_concord_dist:
    # 3. nclip_cutoff:
    # 4. ndisc_cutoff:
    # 5. max_depth: by default: 4*calc-depth
    # 6. check the background clipped reads (reads clipped at the location, but with low mapping quality)
    def call_MEIs_consensus(self, sf_candidate_list, sf_raw_disc, extnd, bin_size, sf_rep_cns, sf_flank, i_flank_lenth,
                            bmapped_cutoff, i_concord_dist, f_concord_ratio, nclip_cutoff, ndisc_cutoff, sf_final_list):
        sf_cns_log=self.working_folder + "filtering_log.txt"
        xlog=XLog()
        f_log=xlog.open_file(sf_cns_log)
####
        # collect the clipped and discordant reads
        # each record in format like: @20~41951715~L~1~41952104~0~0,
        # (chrm, map_pos, global_values.FLAG_LEFT_CLIP, is_rc, insertion_pos, n_cnt_clip, sample_id)
        sf_clip_fq = self.working_folder + "candidate_sites_all_clip.fq"
        sf_disc_fa = self.working_folder + "candidate_sites_all_disc.fa"
        xlog.append_to_file(f_log, "[Filtering:collect_clipped_disc_reads:Starts...]\n")
        m_lowq_clip_cnt = self.collect_clipped_disc_reads(sf_candidate_list, extnd, bin_size, sf_clip_fq,
                                                          sf_disc_fa, sf_raw_disc)
#need to be comment out !!!!!
        # sf_temp_lowq_clip=self.working_folder + "low_mapq_clip_cnt.txt"
        # with open(sf_temp_lowq_clip, "w") as fout_lowq:
        #     for tmp_chrm in m_lowq_clip_cnt:
        #         for tmp_pos in m_lowq_clip_cnt[tmp_chrm]:
        #             sinfo="{0} {1} {2}\n".format(tmp_chrm, tmp_pos, m_lowq_clip_cnt[tmp_chrm][tmp_pos])
        #             fout_lowq.write(sinfo)

        xlog.append_to_file(f_log, "[Filtering:collect_clipped_disc_reads:Finished]\n")

        # # ##re-align the clipped reads
        bwa_align = BWAlign(global_values.BWA_PATH, global_values.BWA_REALIGN_CUTOFF, self.n_jobs)
        sf_clip_algnmt = self.working_folder + "temp_clip.sam"
        xlog.append_to_file(f_log, "[Filtering:realign_clipped_read_with_polyA:Starts...]\n")
        bwa_align.realign_clipped_read_with_polyA(sf_rep_cns, sf_clip_fq, sf_clip_algnmt)
        self.clean_file_by_path(sf_clip_fq)

        xlog.append_to_file(f_log, "[Filtering:realign_clipped_read_with_polyA:Finished]\n")
        # ##re-align the disc reads
        sf_disc_algnmt = self.working_folder + "temp_disc.sam"
        xlog.append_to_file(f_log, "[Filtering:realign_disc_reads:Starts...]\n")
        bwa_align.realign_disc_reads(sf_rep_cns, sf_disc_fa, sf_disc_algnmt)
        self.clean_file_by_path(sf_disc_fa)
        xlog.append_to_file(f_log, "[Filtering:realign_disc_reads:Finished...]\n")

        ####analysis the re-aligned clipped reads, called out:
        # left-max-clip-position, right-max-clip-position, TSD
        # peak clip position on the repeat consensus
        xlog.append_to_file(f_log, "[Filtering:Clip-Consistency-Checking:Starts...]\n")
        m_ins_lpos, m_ins_rpos, m_cns_lpos, m_cns_rpos, m_clip_sample, m_polyA = \
            self.parse_clip_realignment_consensus(sf_clip_algnmt, bmapped_cutoff)####

        idist = global_values.CLIP_SEARCH_WINDOW  # count number of clipped reads within this range (default 15)
        # at lease "ratio" percent of the clipped reads are clipped within the region
        ratio = global_values.CLIP_CONSISTENT_RATIO
        # Each returned record in format: (l_peak_pos, r_peak_pos, cns_peak_start, cns_peak_end)
        EXD_BIN_SIZE = idist
        n_bam = self.cnt_n_bams(self.sf_bam_list)
####
        #1. check clip consistency
        #check left side and right side seperately: Check whether they form cluster (> ratio of reads within a cluster)
        #here require lclip+rclip<=nclip_cutoff, and if lclip or rclip is zero, then use half of this value
        m_clip_checked_list = self.check_clip_alone_consistency2(m_ins_lpos, m_ins_rpos, idist,
                                                                 ratio, nclip_cutoff, EXD_BIN_SIZE, m_lowq_clip_cnt)
        xlog.append_to_file(f_log, "[Filtering:Clip-Consistency-Checking:Finished...]\n")
        m_qlfd_clip = {}
        m_qlfd_clip_no_polyA = {}
        m_potential_complex = {}
####
        for ins_chrm in m_clip_checked_list:
            for ins_pos in m_clip_checked_list[ins_chrm]:
                b_polyA = m_clip_checked_list[ins_chrm][ins_pos][-1]
                b_consist = m_clip_checked_list[ins_chrm][ins_pos][-2]
                if b_consist == True and b_polyA == True:
                    if ins_chrm not in m_qlfd_clip:
                        m_qlfd_clip[ins_chrm] = {}
                    m_qlfd_clip[ins_chrm][ins_pos] = m_clip_checked_list[ins_chrm][ins_pos]

                if b_consist == True:
                    if ins_chrm not in m_qlfd_clip_no_polyA:
                        m_qlfd_clip_no_polyA[ins_chrm] = {}
                    m_qlfd_clip_no_polyA[ins_chrm][ins_pos] = m_clip_checked_list[ins_chrm][ins_pos]

                b_no_lclip = m_clip_checked_list[ins_chrm][ins_pos][-4]
                b_no_rclip = m_clip_checked_list[ins_chrm][ins_pos][-3]
                if (b_no_rclip == False and b_no_lclip == True) or (b_no_rclip == True and b_no_lclip == False):
                    if ins_chrm not in m_potential_complex:
                        m_potential_complex[ins_chrm] = {}
                    m_potential_complex[ins_chrm][ins_pos] = m_clip_checked_list[ins_chrm][ins_pos]
####
        #2.1 This is only parse the alignment to count the number
        # disc map position on the repeat consensus
        ####In format: m_rep_pos_disc[ins_chrm][ins_pos].append((anchor_map_pos, pos_in_consensus))
        ####Note that: use the middle-map-pos of a read as the pos_in_consensus
        # m_rep_pos_disc, each record in format: (anchor_map_pos, pos_in_consensus, b_rc)
        #m_disc_anchor_dir[ins_chrm][ins_pos]: save (l_disc_rc[i_anchor_pos], l_disc_not_rc[i_anchor_pos])
        xlog.append_to_file(f_log, "[Filtering:Disc-Consistency-Checking:Starts...]\n")
        m_rep_pos_disc, m_disc_sample, m_disc_polyA = \
            self.parse_disc_algnmt_consensus(sf_disc_algnmt, bmapped_cutoff)

        ####Potential problem: some sample may be of low coverage, in this way, ndisc_cutoff should be an array based on cov
####
#########!!!!!!!!!!!!!In to-do-list
        #2.2 check whether all the samples have enough disc reads support
        n_disc_half_cutoff = ndisc_cutoff / 2 # here cutoff value, should be an arrary for each sample, here is arbitary
        nclip_half_cutoff = nclip_cutoff / 2
        m_disc_consist_list=None
        if global_values.CHECK_BY_SAMPLE==True:
            m_disc_consist_list = self.check_disc_sample_consistency(m_clip_checked_list, m_disc_sample, n_disc_half_cutoff)
        else:
            m_disc_consist_list=dict(m_clip_checked_list)

        xlog.append_to_file(f_log, "[Filtering:Disc-Consistency-Checking: "
                                   "m_disc_consist_list size is {0}]\n".format(len(m_disc_consist_list)))
########
        ##get the representative clip position
        m_represent_clip_pos = self._refine_represent_clip_pos(m_disc_consist_list)

        #2.3 Filter by checking whether discordant reads form clusters
        #First, check whether left and right form seperate cluster (>f_concord_ratio disc reads suport that)
        #Then, if both ends form cluster, then total number of disc reads should > ndisc_cutoff
        # m_disc_filtered format: [ins_chrm][ins_pos] = (n_l_disc, lcns_start, lcns_end, n_r_disc, rcns_start, rcns_end)
        m_disc_filtered = self.check_seprt_disc_consistency(m_represent_clip_pos, m_rep_pos_disc,
                                                            i_concord_dist, f_concord_ratio, ndisc_cutoff)
        xlog.append_to_file(f_log, "[Filtering:Disc-Consistency-Checking:Finished...]\n")
        m_transdct_info = {}  #by default, this is empty
        #l_candidates: [(ins_chrm, ins_pos, refined_pos, ...), ...]
        #keep ins_chrm, and ins_pos to keep 1-1 match between dicts
        m_rescued={}
        l_candidates = self._extract_detailed_info_TEI(m_disc_filtered, m_disc_consist_list, m_ins_lpos, m_ins_rpos,
                                                       m_polyA, m_clip_checked_list, m_transdct_info, m_rescued)
####
        ####check the coverage, and remove those near a high coverage island
        xlog.append_to_file(f_log, "[Filtering:calc_coverage_samples:Starts...]\n")
        rd = ReadDepth(self.working_folder, self.n_jobs, self.sf_reference)

        i_total_cov = global_values.AVE_COVERAGE
        # if global_values.GLOBAL_USER_SPECIFIC==True:
        #     i_search_win=500
        #     m_sample_cov=rd.calc_coverage_samples(self.sf_bam_list, self.sf_reference, i_search_win)
        #     i_total_cov=rd.get_total_cov(m_sample_cov)

        xlog.append_to_file(f_log, "[Filtering:calc_coverage_samples:Finished with estimated coverage:"
                                   "{0}]\n".format(i_total_cov))
####
        # the maximum coverage should smaller than this
        i_max_cov=global_values.MAX_COV_TIMES * i_total_cov

        sf_before_filtering = sf_final_list + ".before_calling_transduction"
        b_with_head = False
        self.dump_TEI_info(l_candidates, sf_before_filtering, b_with_head)

        ####
        # calc the left and right local depth for the sites
        search_win = global_values.COV_SEARCH_WINDOW #this region is to collect the reads, by default 1000
        focal_win = global_values.LOCAL_COV_WIN #this region is used to search for coverage island, by default 900
        focal_win2=global_values.COV_ISD_CHK_WIN #this region is to calculate the local coverage, by default 200
        # m_read_depth in format: {ins_chrm: {ins_pos: [lfcov, rfcov]}}
        m_read_depth = rd.calc_coverage_of_two_regions(m_disc_filtered, self.sf_bam_list, search_win,
                                                       focal_win, focal_win2)
####
        sf_cov=sf_before_filtering+".sites_cov"
        rd.dump_coverage_info(m_read_depth, sf_cov)
        #here define those with high coverage islands nearby
        m_hcov={} #{chrm:{refined_pos}}
        for ins_chrm in m_read_depth:
            for ins_pos in m_read_depth[ins_chrm]:
                i_cur_lcov = int(m_read_depth[ins_chrm][ins_pos][2])
                i_cur_rcov = int(m_read_depth[ins_chrm][ins_pos][3])
                if i_cur_lcov > i_max_cov or i_cur_rcov > i_max_cov:
                    if ins_chrm not in m_hcov:
                        m_hcov[ins_chrm]={}
                    if ins_pos not in m_hcov[ins_chrm]:
                        m_hcov[ins_chrm][ins_pos]=[i_cur_lcov, i_cur_rcov]
####
        ####potential issue here (for SVA)!!!
        i_cns_lth = self._get_min_cns_length(sf_rep_cns)  #if multiple, then use the average length
        #first stage classification of the candidates
        m_ins_categories=self._first_stage_classify(l_candidates, m_hcov)

        xlog.append_to_file(f_log, "[Filtering:Filter-Dump-Insertion-Info:Starts...]\n")
        sf_before_filtering = sf_final_list + ".before_filtering"
        b_with_head = False
        self.dump_TEI_info_with_ori_pos(l_candidates, sf_before_filtering, b_with_head)

        #here extract the features for genotyping
        x_gntper = XGenotyper(self.sf_reference, self.working_folder, self.n_jobs)
        is_extnd = global_values.DFT_IS
        xlog.append_to_file(f_log, "[extension length is: {0}]\n".format(is_extnd))#####################################
        sf_gntp_feature=sf_final_list + ".gntp.features"
        x_gntper.call_genotype(self.sf_bam_list, sf_before_filtering, is_extnd, sf_gntp_feature)
        #load in features, also filter out sites with very large clipped reads at the breakpoints
        m_gntp_info=x_gntper.load_in_features_from_file_with_cov_cutoff(sf_gntp_feature, i_max_cov)

        min_l1_end=i_cns_lth-150
        depth_ratio = 0.35  ##left-right read depth ratio
        l_final_candidates, m_high_confidt, m_one_side_low_confident, m_not_hit_end = \
            self.filter_by_clip_disc_polyA_consistency(l_candidates, m_read_depth, i_concord_dist, nclip_half_cutoff,
                                                       n_disc_half_cutoff, min_l1_end, depth_ratio, xlog, f_log)
####
        ##save to file
        b_with_head = False
        self._second_stage_classify_dump(m_ins_categories, l_final_candidates, m_high_confidt, m_one_side_low_confident,
                                         m_hcov, m_not_hit_end, m_gntp_info, i_cns_lth, b_with_head, sf_final_list)
        xlog.append_to_file(f_log, "[Filtering:Filter-Dump-Insertion-Info:Finished...]\n")
        xlog.close_file(f_log)
####
####

    ####Rescue those have one side information, but the other side is aligned to dispersed flanking regions (non transduction),
    ####Potential reason is the repeat copy is different from the consensus and annotation, like SVA
    def rescue_one_side_with_flanking_hits(self, m_disc_filtered, m_n_src_lclip, m_n_src_rclip, m_n_src_disc,
                                           nclip_cutoff, ndisc_cutoff, i_dist, ratio):
        m_rescued={}
        #first require having both clip and disc reads aligned to the flanking regions
        for ins_chrm in m_disc_filtered:
            for ins_pos in m_disc_filtered[ins_chrm]:
                if (ins_chrm not in m_n_src_disc) or (ins_pos not in m_n_src_disc[ins_chrm]):#doesn't have disc reads support
                    continue
                elif len(m_n_src_disc[ins_chrm][ins_pos])<ndisc_cutoff:#no enough disc reads
                    continue

                l_dist_from_rep=m_n_src_disc[ins_chrm][ins_pos]

#Here we don't require the distance from repeat to be consistent;
#Same reason here: the annotation maybe have been broken to pieces
                #check whether disc reads form cluster
                # cluster_ck=ClusterChecker()
                # b_cluster, lbound, rbound=cluster_ck._is_disc_cluster(l_dist_from_rep, i_dist, ratio)
                # if b_cluster==False:
                #     continue
                n_disc = len(m_n_src_disc[ins_chrm][ins_pos])

                b_lclip=True
                n_lclip=0
                if (ins_chrm not in m_n_src_lclip) or (ins_pos not in m_n_src_lclip[ins_chrm]):
                    b_lclip=False
                elif len(m_n_src_lclip[ins_chrm][ins_pos])<nclip_cutoff: #no enough clip reads support
                    b_lclip=False
                    n_lclip=len(m_n_src_lclip[ins_chrm][ins_pos])
                b_rclip=True
                n_rclip=0
                if (ins_chrm not in m_n_src_rclip) or (ins_pos not in m_n_src_rclip[ins_chrm]):
                    b_rclip = False
                elif len(m_n_src_rclip[ins_chrm][ins_pos])<nclip_cutoff: #no enough clip reads support
                    b_rclip=False
                    n_rclip=len(m_n_src_rclip[ins_chrm][ins_pos])

                if b_lclip==False and b_rclip==False:#no any clip support, then skip
                    continue

                #check whether clipped parts form cluster
                #To do list

                if ins_chrm not in m_rescued:
                    m_rescued[ins_chrm]={}
                m_rescued[ins_chrm][ins_pos]=(n_lclip, n_rclip, n_disc)
        return m_rescued

    ####
    def _dump_old_site_pos(self, l_selected, m_new_old_match, sf_out):
        with open(sf_out, "w") as fout_info:
            for rcd in l_selected:
                if len(rcd)<2:
                    continue
                ins_chrm=rcd[0]
                ins_old_pos=rcd[1]
                # ins_old_pos=-1
                # if (ins_chrm in m_new_old_match) and (ins_new_pos in m_new_old_match[ins_chrm]):
                #     ins_old_pos=m_new_old_match[ins_chrm][ins_new_pos]
                # if ins_old_pos!=-1:
                fout_info.write(ins_chrm+"\t"+str(ins_old_pos)+"\n")
    ####

    ####
    # classify to: 2-side supported, 1-side supported categories
    def _first_stage_classify(self, l_candidates, m_hcov):
        m_ins_categories={}#use dict, thus we can check later
        #for two side
        m_ins_categories[global_values.TWO_SIDE]={}#as long as have the four clusters
        m_ins_categories[global_values.TWO_SIDE_TPRT] = {} #TSD or polyA
        m_ins_categories[global_values.TWO_SIDE_TPRT_BOTH] = {} #TSD and polyA
        #for one and a half side
        m_ins_categories[global_values.ONE_HALF_SIDE] = {}
        m_ins_categories[global_values.ONE_HALF_SIDE_TRPT_BOTH] = {}
        m_ins_categories[global_values.ONE_HALF_SIDE_TRPT] = {}
        #for one side
        m_ins_categories[global_values.ONE_SIDE] = {}
        m_ins_categories[global_values.ONE_SIDE_TRSDCT] = {}
        m_ins_categories[global_values.ONE_SIDE_WEAK] = {}
        m_ins_categories[global_values.ONE_SIDE_OTHER] = {}
        m_ins_categories[global_values.ONE_SIDE_SV] = {}
        #low confident ones
        m_ins_categories[global_values.HIGH_COV_ISD]={}
        m_ins_categories[global_values.OTHER_TYPE] = {}
        m_ins_categories[global_values.TWO_SIDE_POLYA_DOMINANT] = {}

        for (ins_chrm, ins_pos, refined_pos, lpeak_pos, rpeak_pos, TSD, n_total_lclip, n_total_rclip,
             n_total_ldisc, n_total_rdisc, n_total_lpolyA, n_total_rpolyA, flcov, frcov, nlclip, nrclip,
             nldisc, nrdisc, nlpolyA, nrpolyA, rc_rcd_disc, anchor_rc_rcd, lc_cns_start, lc_cns_end, rc_cns_start,
             rc_cns_end, ldisc_cns_start, ldisc_cns_end, rdisc_cns_start, rdisc_cns_end,
             s_trsdct_info, n_clip_trsdct, n_disc_trsdct, n_polyA_trsdct) in l_candidates:

            s_id = "{0}{1}{2}".format(ins_chrm, global_values.SEPERATOR, ins_pos)
            # skip those nearby the high coverage island
            if (ins_chrm in m_hcov) and (ins_pos in m_hcov[ins_chrm]):
                m_ins_categories[global_values.HIGH_COV_ISD][s_id]=1
                continue

            b_lc_hit=False
            b_lc_half_hit=False
            if lc_cns_start!=-1 and lc_cns_end!=-1:
                b_lc_hit=True
            elif lc_cns_start!=-1 or lc_cns_end!=-1:
                b_lc_half_hit=True
            b_rc_hit=False
            b_rc_half_hit = False
            if rc_cns_start!=-1 and rc_cns_end!=-1:
                b_rc_hit=True
            elif rc_cns_start!=-1 or rc_cns_end!=-1:
                b_rc_half_hit=True
            b_ld_hit=False
            b_ld_half_hit=False
            if ldisc_cns_start!=-1 and ldisc_cns_end!=-1:
                b_ld_hit=True
            elif ldisc_cns_start!=-1 or ldisc_cns_end!=-1:
                b_ld_half_hit=True
            b_rd_hit=False
            b_rd_half_hit=False
            if rdisc_cns_start!=-1 and rdisc_cns_end!=-1:
                b_rd_hit=True
            elif rdisc_cns_start!=-1 or rdisc_cns_end!=-1:
                b_rd_half_hit=True

            if b_lc_hit and b_rc_hit and b_ld_hit and b_rd_hit:
                m_ins_categories[global_values.TWO_SIDE][s_id]=1
                if (n_total_rpolyA+n_total_lpolyA)>0 and (TSD>0 and TSD<global_values.TSD_CUTOFF):
                    m_ins_categories[global_values.TWO_SIDE_TPRT_BOTH][s_id] = 1
                elif (n_total_rpolyA+n_total_lpolyA)>0 or (TSD>0 and TSD<global_values.TSD_CUTOFF):
                    m_ins_categories[global_values.TWO_SIDE_TPRT][s_id] = 1
            elif (b_lc_hit and b_rd_hit) and (b_rc_hit==False and b_ld_hit==False):
                m_ins_categories[global_values.ONE_SIDE][s_id]=1
            elif (b_rc_hit and b_ld_hit) and (b_lc_hit==False and b_rd_hit==False):
                m_ins_categories[global_values.ONE_SIDE][s_id] = 1
            elif (b_lc_hit and b_rd_hit) and (b_rc_hit or b_ld_hit):#left-side:full feature, right-side: half feature
                m_ins_categories[global_values.ONE_HALF_SIDE][s_id] = 1
                if (n_total_rpolyA + n_total_lpolyA) > 0 and (TSD > 0 and TSD < global_values.TSD_CUTOFF):
                    m_ins_categories[global_values.ONE_HALF_SIDE_TRPT_BOTH][s_id] = 1
                elif (n_total_rpolyA + n_total_lpolyA) > 0 or (TSD > 0 and TSD < global_values.TSD_CUTOFF):
                    m_ins_categories[global_values.ONE_HALF_SIDE_TRPT][s_id] = 1
            elif (b_rc_hit and b_ld_hit) and (b_lc_hit or b_rd_hit):#right-side:full feature, left-side: half feature
                m_ins_categories[global_values.ONE_HALF_SIDE][s_id] = 1
                if (n_total_rpolyA + n_total_lpolyA) > 0 and (TSD > 0 and TSD < global_values.TSD_CUTOFF):
                    m_ins_categories[global_values.ONE_HALF_SIDE_TRPT_BOTH][s_id] = 1
                elif (n_total_rpolyA + n_total_lpolyA) > 0 or (TSD > 0 and TSD < global_values.TSD_CUTOFF):
                    m_ins_categories[global_values.ONE_HALF_SIDE_TRPT][s_id] = 1
            else:
                m_ins_categories[global_values.OTHER_TYPE][s_id] = 1
        return m_ins_categories

####
####
    ####Used to find out the potential full length polymorphic L1
    ####The flanking regions for these full length L1s will be collected for transduction calling
    def _call_full_length_TE_insertion(self, l_candidates, m_hcov, ileftmost):
        l_picked = []
        for record in l_candidates:
            # check whether hit the front of TE consensus
            ins_chrm = record[0]
            ins_pos = record[1]

            #skip those nearby the high coverage island
            if (ins_chrm in m_hcov) and (ins_pos in m_hcov[ins_chrm]):
                continue

            # #Here check the TSD length, and if doesn't satisfied, then skip
            # i_TSD_len=int(record[4])
            # if i_TSD_len>0 and i_TSD_len<=global_values.TSD_CUTOFF:
            #     continue
####
            ilclip_start = record[-12]
            ilclip_end = record[-11]
            irclip_start = record[-10]
            irclip_end = record[-9]

            ildisc_start = record[-8]
            ildisc_end = record[-7]
            irdisc_start = record[-6]
            irdisc_end = record[-5]

            bhit = False

            if (ildisc_start <= ileftmost and ildisc_start>0) or (irdisc_start <= ileftmost and irdisc_start>0):
                bhit = True
            if (ilclip_start <= ileftmost and ilclip_start>0) or (irclip_start <= ileftmost and irclip_start>0):
                bhit = True
            if bhit == True:
                l_picked.append((ins_chrm, ins_pos))
        return l_picked
####
####
    def _get_cns_length(self, sf_cns):
        l_rep = 0
        n_copies=0
        with open(sf_cns) as fin_cns:
            for line in fin_cns:
                if line[0] == ">":
                    n_copies+=1
                    continue
                l_rep += len(line.rstrip())
        ave_len=int(l_rep/n_copies)
        return ave_len

####
    def _get_min_cns_length(self, sf_cns):
        min_len = 100000000000000000
        i_acm_len = 0
        with open(sf_cns) as fin_cns:
            for line in fin_cns:
                if line[0] == ">":
                    if (i_acm_len is not 0) and (min_len > i_acm_len):
                        min_len = i_acm_len
                    i_acm_len = 0
                    continue
                i_tmp_len = len(line.rstrip())
                i_acm_len += i_tmp_len
        if min_len > i_acm_len:
            min_len = i_acm_len
        return min_len

    ####
    def cnt_n_bams(self, sf_bam):
        n_cnt = 0
        with open(sf_bam) as fin_bam:
            for line in fin_bam:
                sinfo = line.rstrip()
                if len(sinfo) > 1:
                    n_cnt += 1
        return n_cnt

    ####
    def is_sam_header_contain_chr(self, sf_sam):
        samfile = pysam.AlignmentFile(sf_sam, "r", reference_filename=self.sf_reference)
        header = samfile.header
        samfile.close()
        l_chrms = header['SQ']
        m_chrms = {}
        for record in l_chrms:
            sinfo = record['SN']
            fields = sinfo.split(global_values.SEPERATOR)
            chrm_name = fields[0]
            m_chrms[chrm_name] = 1
        if ("1" in m_chrms) or ("2" in m_chrms):
            return False
        else:
            return True

    ####find out candidate transduction events from "clip transduct" events
    # m_clip_transduct in format:
    # m_transduction[ori_chrm][ori_insertion_pos][transduct_pos]=[list of positions
    # !!!!should also consider whether clip within a region
    # also one insertion may have multiple candidate transduction positions, so find the maximum one
    def call_transduction_from_clip(self, m_clip_transduct, n_cutoff):
        m_transduct_candidates = {}
        for ins_chrm in m_clip_transduct:
            for ins_pos in m_clip_transduct[ins_chrm]:
                s_picked_pos = ""
                n_max = 0
                for transduct_pos in m_clip_transduct[ins_chrm][ins_pos]:
                    n_support_read = len(m_clip_transduct[ins_chrm][ins_pos][transduct_pos])
                    if n_support_read > n_max:
                        n_max = n_support_read
                        s_picked_pos = transduct_pos
                if n_max > n_cutoff:
                    if ins_chrm not in m_transduct_candidates:
                        m_transduct_candidates[ins_chrm] = {}
                    m_transduct_candidates[ins_chrm][ins_pos] = s_picked_pos
        return m_transduct_candidates

    ####
    ####
    ####Given the transduction candidate list from clipped reads, check the disc candidates
    ####Note that: some candidate may only exist in disc candidates, so need to add them to the finaly list
    ####This is because the "disc transduct" are gotten from the "clip list", which may not cover "clip transduct"
    # !!!!!!should also consider whether form cluster
    # also one insertion may have multiple candidate transduction positions, so find the maximum one
    def call_transduction_from_disc(self, m_disc_transduct, n_cutoff):
        m_transduct_candidates = {}
        for ins_chrm in m_disc_transduct:
            for ins_pos in m_disc_transduct[ins_chrm]:
                s_picked_pos = ""
                n_max = 0
                for trsdct_pos in m_disc_transduct[ins_chrm][ins_pos]:
                    n_support_read = len(m_disc_transduct[ins_chrm][ins_pos][trsdct_pos])
                    if n_support_read > n_max:
                        n_max = n_support_read
                        s_picked_pos = trsdct_pos
                if n_max > n_cutoff:
                    if ins_chrm not in m_transduct_candidates:
                        m_transduct_candidates[ins_chrm] = {}
                    m_transduct_candidates[ins_chrm][ins_pos] = s_picked_pos
        return m_transduct_candidates

    # m_ins_lpos in format: m_ins_lpos[ori_chrm][ori_insertion_pos][ori_mpos]=cnt
    def call_TSD_pos_transduction_gntp(self, m_clip_checked_list, m_transduct, TSD_cutoff):
        # first get the peak left clip position
        # then get the peak right clip position
        # call out the TSD, if the len<=25, also need to get the "seq" of the TSD
        # check whether it is transduction, if yes, report the linked copy position
        # call out the genotype information

        # The candidate sites will have both left and right clipped reads in a region
        # so we can just traverse the m_ins_lpos
        m_pos_TSD_transduct = {}
        for ins_chrm in m_clip_checked_list:
            for ins_pos in m_clip_checked_list[ins_chrm]:
                record = m_clip_checked_list[ins_chrm][ins_pos]
                lpeak_pos = record[0]
                rpeak_pos = record[1]

                TSD = ""
                if abs(rpeak_pos - lpeak_pos) <= TSD_cutoff:
                    TSD = "{0}~{1}~{2}".format(ins_chrm, lpeak_pos, rpeak_pos)

                s_transduct = ""
                if (ins_chrm in m_transduct) and (ins_pos in m_transduct[ins_chrm]):
                    s_transduct = "{0}~{1}".format(m_transduct[ins_chrm][ins_pos][0], m_transduct[ins_chrm][ins_pos][1])

                if ins_chrm not in m_pos_TSD_transduct:
                    m_pos_TSD_transduct[ins_chrm] = {}
                if ins_pos not in m_pos_TSD_transduct[ins_chrm]:
                    m_pos_TSD_transduct[ins_chrm][ins_pos] = (lpeak_pos, TSD, s_transduct)
        return m_pos_TSD_transduct

    # m_ins_lpos in format: m_ins_lpos[ori_chrm][ori_insertion_pos][ori_mpos]=cnt
    def call_TSD_pos_gntp(self, m_clip_checked_list, TSD_cutoff):
        # first get the peak left clip position
        # then get the peak right clip position
        # call out the TSD, if the len<=25, also need to get the "seq" of the TSD
        # check whether it is transduction, if yes, report the linked copy position
        # call out the genotype information

        # The candidate sites will have both left and right clipped reads in a region
        # so we can just traverse the m_ins_lpos
        m_pos_TSD_transduct = {}
        for ins_chrm in m_clip_checked_list:
            for ins_pos in m_clip_checked_list[ins_chrm]:
                record = m_clip_checked_list[ins_chrm][ins_pos]
                lpeak_pos = record[0]
                rpeak_pos = record[1]

                TSD = ""
                if abs(rpeak_pos - lpeak_pos) <= TSD_cutoff:
                    TSD = "{0}~{1}~{2}".format(ins_chrm, lpeak_pos, rpeak_pos)

                if ins_chrm not in m_pos_TSD_transduct:
                    m_pos_TSD_transduct[ins_chrm] = {}
                if ins_pos not in m_pos_TSD_transduct[ins_chrm]:
                    m_pos_TSD_transduct[ins_chrm][ins_pos] = (lpeak_pos, TSD)
        return m_pos_TSD_transduct

    ####
    ####left and right, both should be considered!!!
    #
    ####
    def merge_sites(self, m_1, m_2):
        m_check_sites = {}
        for ins_chrm in m_1:
            if ins_chrm not in m_check_sites:
                m_check_sites[ins_chrm] = {}
            for ins_pos in m_1[ins_chrm]:
                if ins_pos not in m_check_sites[ins_chrm]:
                    m_check_sites[ins_chrm][ins_pos] = 1
        for ins_chrm in m_2:
            if ins_chrm not in m_check_sites:
                m_check_sites[ins_chrm] = {}
            for ins_pos in m_2[ins_chrm]:
                if ins_pos not in m_check_sites[ins_chrm]:
                    m_check_sites[ins_chrm][ins_pos] = 1
        return m_check_sites

    # check whether tranduction exists
    def check_transduction(self, m_clip_transduct, m_disc_transduct, flank_length, n_cutoff):
        m_check_sites = self.merge_sites(m_clip_transduct, m_disc_transduct)
        m_candidate_transduct = {}
        for ins_chrm in m_check_sites:
            for ins_pos in m_check_sites[ins_chrm]:
                cnt_clip_support = 0
                cnt_disc_support = 0
                cnt_max_support = 0
                max_copy_pos = ""

                if (ins_chrm in m_clip_transduct) and (ins_pos in m_clip_transduct[ins_chrm]):
                    for rep_copy_pos in m_clip_transduct[ins_chrm][ins_pos]:
                        cnt_clip_support = len(m_clip_transduct[ins_chrm][ins_pos][rep_copy_pos])
                        if (ins_chrm in m_disc_transduct) and (ins_pos in m_disc_transduct[ins_chrm]) and (
                                    rep_copy_pos in m_disc_transduct[ins_chrm][ins_pos]):
                            cnt_disc_support = len(m_disc_transduct[ins_chrm][ins_pos][rep_copy_pos])
                        tmp_all = cnt_clip_support + cnt_disc_support
                        if cnt_max_support < tmp_all:
                            cnt_max_support = tmp_all
                            max_copy_pos = rep_copy_pos
                elif (ins_chrm in m_disc_transduct) and (ins_pos in m_disc_transduct[ins_chrm]):
                    for rep_copy_pos in m_disc_transduct[ins_chrm][ins_pos]:
                        cnt_disc_support = len(m_disc_transduct[ins_chrm][ins_pos][rep_copy_pos])
                        if cnt_max_support < cnt_disc_support:
                            cnt_max_support = cnt_disc_support
                            max_copy_pos = rep_copy_pos

                # find out it's 3' or 5' transduction
                # first find the peak is at first or end
                # fields=max_copy_pos.split(global_values.SEPERATOR)
                # copy_length=int(fields[-1]) - int(fields[-2])
                cnt_3 = 0
                cnt_5 = 0
                if (ins_chrm in m_clip_transduct) and (ins_pos in m_clip_transduct[ins_chrm]) and (
                            max_copy_pos in m_clip_transduct[ins_chrm][ins_pos]):
                    for map_pos_flank in m_clip_transduct[ins_chrm][ins_pos][max_copy_pos]:
                        if map_pos_flank < flank_length:
                            cnt_5 += 1
                        else:
                            cnt_3 += 1
                if (ins_chrm in m_disc_transduct) and (ins_pos in m_disc_transduct[ins_chrm]) and (
                            max_copy_pos in m_disc_transduct[ins_chrm][ins_pos]):
                    for map_pos_flank in m_disc_transduct[ins_chrm][ins_pos][max_copy_pos]:
                        if map_pos_flank < flank_length:
                            cnt_5 += 1
                        else:
                            cnt_3 += 1

                b_3mer = 1
                if cnt_5 >= cnt_3:
                    b_3mer = 0

                b_transduct = False
                if (b_3mer == True and cnt_3 > n_cutoff) or (b_3mer == False and cnt_5 > n_cutoff):
                    b_transduct = True
                # here also need to get the positions on the consensus, to get the estimated length of the insertion
                if ins_chrm not in m_candidate_transduct:
                    m_candidate_transduct[ins_chrm] = {}

                if b_transduct == True:
                    m_candidate_transduct[ins_chrm][ins_pos] = (max_copy_pos, b_3mer)
        return m_candidate_transduct

    # find the best combination of left and right peak
    def find_best_combination(self, l1, l2, l1a, l2a, r1, r2, r1a, r2a, TSD_cutoff):
        b_TSD = True
        if abs(l1 - r1) <= TSD_cutoff:
            return l1, r1, b_TSD, l1a, r1a
        else:
            # for combination of l1 and r2
            if abs(l1 - r2) <= TSD_cutoff and abs(l2 - r1) > TSD_cutoff:
                return l1, r2, b_TSD, l1a, r2a
            elif abs(l2 - r1) <= TSD_cutoff and abs(l1 - r2) > TSD_cutoff:
                return l2, r1, b_TSD, l2a, r1a
            elif abs(l1 - r2) <= TSD_cutoff and abs(
                            l2 - r1) <= TSD_cutoff:  # both satisfied, then check accumulated values
                if (l1a + r2a) > (l2a + r1a):
                    return l1, r2, b_TSD, l1a, r2a
                else:
                    return l2, r1, b_TSD, l2a, r1a
            else:  # none of the combination is satisfied, then check poly-A
                b_TSD = False
                return l1, r1, b_TSD, l1a, r1a
                #####

    ##find the window with the maximum of clip position
    # ins_chrm is the ori reported insertion chrm on the reference
    # ins_pos is the ori reported insertion pos on the reference
    def find_peak_window(self, m_clip_pos, ins_chrm, ins_pos, BIN_SIZE):
        ##first check whether m_clip_pos[ins_chrm][ins_pos] exist
        peak_pos = -1
        peak_acm = 0
        mpos = m_clip_pos[ins_chrm][ins_pos]  # is a dictionary {ref_pos:[cns_pos]}
        istart = -1 * BIN_SIZE / 2
        iend = BIN_SIZE / 2
        for pos in mpos:  # cns_pos may be -1
            if pos <= 0:
                continue
            cur_acm = 0
            for offset in range(istart, iend):
                tmp_pos = pos + offset
                if tmp_pos in mpos:
                    cur_acm += len(mpos[tmp_pos])
            if cur_acm > peak_acm:
                peak_acm = cur_acm
                peak_pos = pos
        l_peak_nbr = []
        for offset in range(istart, iend):
            tmp_pos = peak_pos + offset
            if tmp_pos in mpos:
                l_peak_nbr.append(tmp_pos)
        return peak_pos, l_peak_nbr, peak_acm

    ####
    # check whether the clipped parts aligned on the repeat copies are clustered in a region
    # return True/False, and the peak window
    def check_clip_rep_consistency(self, m_ref_clip_pos, ins_chrm, ins_pos, l_ngbr_pos, imax_dist, ratio_cutoff):
        m_cns_pos = {}
        # 1. collect all the positions
        for map_pos_ref in l_ngbr_pos:  # this is the map position on the reference
            for cns_pos in m_ref_clip_pos[ins_chrm][ins_pos][map_pos_ref]:
                if cns_pos not in m_cns_pos:
                    m_cns_pos[cns_pos] = 1
                else:
                    m_cns_pos[cns_pos] += 1

        peak_win_start = 0
        peak_win_end = 0
        if len(m_cns_pos) == 0:
            return False, peak_win_start, peak_win_end

        # 2. find the peak window of m_cns_pos
        l_pos = list(m_cns_pos.keys())
        l_pos.sort()  ###sort the candidate sites
        peak_win_cnt = 0
        cur_win_cnt = 0
        cur_win_start = l_pos[0]
        cur_win_end = 0
        pre_pos = 0
        for cur_pos in l_pos:
            if (cur_pos - pre_pos) > imax_dist and pre_pos != 0:
                if cur_win_cnt > peak_win_cnt:
                    peak_win_cnt = cur_win_cnt
                    peak_win_start = cur_win_start
                    peak_win_end = cur_win_end

                cur_win_start = cur_pos
                cur_win_cnt = 0

            cur_win_end = cur_pos
            cur_win_cnt += m_cns_pos[cur_pos]
            pre_pos = cur_pos

        ##for the last comparison
        if cur_win_cnt > peak_win_cnt:
            peak_win_cnt = cur_win_cnt
            peak_win_start = cur_win_start
            peak_win_end = cur_win_end

        # 3. check the consistency, the ratio of reads fall in the peak window
        n_hit = 0
        for pos in l_pos:
            if pos >= peak_win_start and pos <= peak_win_end:
                n_hit += 1

        if (float(n_hit) / float(len(l_pos))) >= ratio_cutoff:
            return True, peak_win_start, peak_win_end
        else:
            return False, peak_win_start, peak_win_end
            ####
            ####

    def check_clip_sample_consistency(self, m_sample, ins_chrm, ins_pos, n_bam, ncutoff):
        if len(m_sample[ins_chrm][ins_pos]) < n_bam:
            # print "AAAA", len(m_sample[ins_chrm][ins_pos]), n_bam
            return False
        n_qualified_sample = 0
        # require all the samples must have certain number of clipped reads
        for sample_id in m_sample[ins_chrm][ins_pos]:
            n_left = m_sample[ins_chrm][ins_pos][sample_id][0]
            n_right = m_sample[ins_chrm][ins_pos][sample_id][1]
            if (n_left + n_right) >= ncutoff:
                n_qualified_sample += 1
        if n_qualified_sample < n_bam:
            # print "BBB", n_qualified_sample, n_bam
            return False
        return True
####
    # this is to check one side of the clipped reads, whether they form a cluster on the consensus repeat
    def check_one_side_clip_consistency(self, m_clip_pos, idist, ratio, BSIZE):
        m_checked_list = {}
        ckcluster = ClusterChecker()
        for ins_chrm in m_clip_pos:
            for ins_pos in m_clip_pos[ins_chrm]:
                l1_pos, l1_nbr, l1_acm, l2_pos, l2_nbr, l2_acm = ckcluster.find_first_second_peak(m_clip_pos,
                                                                                                  ins_chrm, ins_pos,
                                                                                                  BSIZE)

                # 1.2 check whether the clip reads aligned on consensus are clustered
                # make sure the peak window is at the end of consensus
                # the right part form a peak cluster
                b_lconsist, cns_lpeak_start, cns_lpeak_end = self.check_clip_rep_consistency(m_clip_pos,
                                                                                             ins_chrm, ins_pos,
                                                                                             l1_nbr, idist, ratio)

                if ins_chrm not in m_checked_list:
                    m_checked_list[ins_chrm] = {}
                m_checked_list[ins_chrm][ins_pos] = (l1_pos, cns_lpeak_start, cns_lpeak_end, b_lconsist, l1_acm)
        return m_checked_list

    #whether this is lowq clip
    def _is_high_lowq_clip(self, n_lowq_clip, n_all_clip, f_ratio):
        if n_all_clip==0:
            return True
        if float(n_lowq_clip)/float(n_all_clip) > f_ratio:
            return True
        return False

####
    ####
    ###this version consider the left and right clip positions seperatelly, thus we can include some complex events:
    # like TE insertion with deletion
    ##Also check TSD consistency (now is comment out):
    # if candidate site has both left and right clipped reads
    # then the left and right peak clip position should satisfy the TSD constrain
    # otherwise, if only have left or right clip, then no need to check this TSD constrain
    # for ins_chrm in m_clip_checked_list
    def check_clip_alone_consistency2(self, m_left_clip_pos, m_right_clip_pos, idist, ratio, n_cutoff, BSIZE, m_lowq_clip=None):
        m_checked_list = {}
        m_left_checked = self.check_one_side_clip_consistency(m_left_clip_pos, idist, ratio, BSIZE)
        m_right_checked = self.check_one_side_clip_consistency(m_right_clip_pos, idist, ratio, BSIZE)

        for ins_chrm in m_left_checked:
            for ins_pos in m_left_checked[ins_chrm]:  # this is for events have both left and right clipped reads
                # if (ins_chrm not in m_polyA) or (ins_pos not in m_polyA[ins_chrm]): ##################################
                #     continue
                ##In format: (l1_pos, cns_lpeak_start, cns_lpeak_end, b_lconsist, n_clip)
                lrecord = m_left_checked[ins_chrm][ins_pos]
                cnt_clip = lrecord[-1]
                if (ins_chrm in m_right_checked) and (ins_pos in m_right_checked[ins_chrm]):
                    rrecord = m_right_checked[ins_chrm][ins_pos]#(l1_pos, cns_peak_start, cns_peak_end, b_lconsist, nclip)
                    ##here make sure the TSD is consistency
                    # if abs(lrecord[0] - rrecord[0]) > global_values.TSD_CUTOFF:####
                    #     #print "MMMM", ins_chrm, ins_pos, lrecord[0], rrecord[0] #####################################
                    #     continue
                    cnt_clip += rrecord[-1]
                    if cnt_clip < n_cutoff:
                        continue
                    if m_lowq_clip is not None:
                        if (ins_chrm in m_lowq_clip) and (ins_pos in m_lowq_clip[ins_chrm]):
                            n_lowq_clip = m_lowq_clip[ins_chrm][ins_pos]
                            if self._is_high_lowq_clip(n_lowq_clip, n_lowq_clip+cnt_clip,
                                                       global_values.MAX_LOWQ_CLIP_RATIO)==True:
                                continue

                    if ins_chrm not in m_checked_list:
                        m_checked_list[ins_chrm] = {}
                    m_checked_list[ins_chrm][ins_pos] = (lrecord[0], rrecord[0], lrecord[1], lrecord[2], rrecord[1],
                                                         rrecord[2], False, False, True, False)
                else:#this is those only have left-clipped
                    if cnt_clip < (n_cutoff/2)+1:
                        continue
                    if m_lowq_clip is not None:
                        if (ins_chrm in m_lowq_clip) and (ins_pos in m_lowq_clip[ins_chrm]):
                            n_lowq_clip = m_lowq_clip[ins_chrm][ins_pos]
                            if self._is_high_lowq_clip(n_lowq_clip, n_lowq_clip+cnt_clip,
                                                       global_values.MAX_LOWQ_CLIP_RATIO)==True:
                                continue
                    if ins_chrm not in m_checked_list:
                        m_checked_list[ins_chrm] = {}
                    m_checked_list[ins_chrm][ins_pos] = (lrecord[0], None, lrecord[1], lrecord[2], -1,
                                                         -1, False, True, True, False)

        # this is to focus on the events only have right-clipped
        for ins_chrm in m_right_checked:
            for ins_pos in m_right_checked[ins_chrm]:
                # if (ins_chrm not in m_polyA) or (ins_pos not in m_polyA[ins_chrm]): ##################################
                #     continue
                rrecord = m_right_checked[ins_chrm][ins_pos]
                cnt_clip = rrecord[-1]
                if cnt_clip < (n_cutoff/2)+1:
                    continue
                if m_lowq_clip is not None:
                    if (ins_chrm in m_lowq_clip) and (ins_pos in m_lowq_clip[ins_chrm]):
                        n_lowq_clip = m_lowq_clip[ins_chrm][ins_pos]
                        if self._is_high_lowq_clip(n_lowq_clip, n_lowq_clip + cnt_clip,
                                                   global_values.MAX_LOWQ_CLIP_RATIO) == True:
                            continue
                if (ins_chrm in m_left_checked) and (ins_pos in m_left_checked[ins_chrm]):
                    continue
                if ins_chrm not in m_checked_list:
                    m_checked_list[ins_chrm] = {}
                m_checked_list[ins_chrm][ins_pos] = (None, rrecord[0], -1, -1, rrecord[1], rrecord[2],
                                                     True, False, True, False)
        return m_checked_list
####

    ####
    ###this version consider the left and right clip positions seperatelly, thus we can include some complex events:
    # like TE insertion with deletion
    ##Also check TSD consistency (now is comment out):
    # if candidate site has both left and right clipped reads
    # then the left and right peak clip position should satisfy the TSD constrain
    # otherwise, if only have left or right clip, then no need to check this TSD constrain
    # for ins_chrm in m_clip_checked_list
    def check_clip_alone_consistency_for_somatic(self, m_left_clip_pos, m_right_clip_pos, sf_ori_list,
                                                 idist, ratio, n_cutoff, BSIZE):
        m_checked_list = {}
        m_form_clip_cluster={}#save those already form clip cluster
        m_left_checked = self.check_one_side_clip_consistency(m_left_clip_pos, idist, ratio, BSIZE)
        m_right_checked = self.check_one_side_clip_consistency(m_right_clip_pos, idist, ratio, BSIZE)

        for ins_chrm in m_left_checked:
            for ins_pos in m_left_checked[ins_chrm]:  # this is for events have both left and right clipped reads
                lrecord = m_left_checked[ins_chrm][ins_pos]
                cnt_clip = lrecord[-1]
                if (ins_chrm in m_right_checked) and (ins_pos in m_right_checked[ins_chrm]):
                    rrecord = m_right_checked[ins_chrm][ins_pos]#(l1_pos, cns_peak_start, cns_peak_end, b_lconsist, nclip)
                    cnt_clip += rrecord[-1]
                    if ins_chrm not in m_checked_list:
                        m_checked_list[ins_chrm] = {}
                    if cnt_clip < n_cutoff:
                        m_checked_list[ins_chrm][ins_pos] = (None, None, -1, -1, -1,
                                                             -1, False, False, False, False)
                        continue
                    m_checked_list[ins_chrm][ins_pos] = (lrecord[0], rrecord[0], lrecord[1], lrecord[2], rrecord[1],
                                                         rrecord[2], False, False, True, False)
                    if ins_chrm not in m_form_clip_cluster:
                        m_form_clip_cluster[ins_chrm]={}
                    m_form_clip_cluster[ins_chrm][ins_pos]=(lrecord[0], rrecord[0], lrecord[1], lrecord[2], rrecord[1],
                                                         rrecord[2], False, False, True, False)
                else:  # this is those only have left-clipped
                    if ins_chrm not in m_checked_list:
                        m_checked_list[ins_chrm] = {}
                    if cnt_clip < (n_cutoff / 2) + 1:
                        m_checked_list[ins_chrm][ins_pos] = (None, None, -1, -1, -1,
                                                             -1, False, False, False, False)
                        continue
                    m_checked_list[ins_chrm][ins_pos] = (lrecord[0], None, lrecord[1], lrecord[2], -1,
                                                         -1, False, True, True, False)
                    if ins_chrm not in m_form_clip_cluster:
                        m_form_clip_cluster[ins_chrm] = {}
                    m_form_clip_cluster[ins_chrm][ins_pos]=(lrecord[0], None, lrecord[1], lrecord[2], -1,
                                                            -1, False, True, True, False)

        # this is to focus on the events only have right-clipped
        for ins_chrm in m_right_checked:
            for ins_pos in m_right_checked[ins_chrm]:
                rrecord = m_right_checked[ins_chrm][ins_pos]
                cnt_clip = rrecord[-1]
                if (ins_chrm in m_left_checked) and (ins_pos in m_left_checked[ins_chrm]):
                    continue
                if ins_chrm not in m_checked_list:
                    m_checked_list[ins_chrm] = {}
                if cnt_clip < (n_cutoff / 2) + 1:
                    m_checked_list[ins_chrm][ins_pos] = (None, None, -1, -1, -1,
                                                         -1, False, False, False, False)
                    continue
                m_checked_list[ins_chrm][ins_pos] = (None, rrecord[0], -1, -1, rrecord[1], rrecord[2],
                                                     True, False, True, False)
                if ins_chrm not in m_form_clip_cluster:
                    m_form_clip_cluster[ins_chrm] = {}
                m_form_clip_cluster[ins_chrm][ins_pos] =(None, rrecord[0], -1, -1, rrecord[1], rrecord[2],
                                                     True, False, True, False)
        #add those in the original list, but not caught here
        with open(sf_ori_list) as fin_ori:
            for line in fin_ori:
                fields=line.split()
                ins_chrm=fields[0]
                ins_pos=int(fields[1])
                if ins_chrm not in m_checked_list:
                    m_checked_list[ins_chrm]={}
                if (ins_pos not in m_checked_list[ins_chrm]):
                    m_checked_list[ins_chrm][ins_pos] = (None, None, -1, -1, -1,
                                                         -1, False, False, False, False)
        return m_checked_list, m_form_clip_cluster

    # First, all samples should at least have n_disc_cutoff disc reads
    def check_disc_sample_consistency(self, m_clip_checked, m_sample_disc, n_disc_cutoff):
        m_selected = {}
        n_bams_all = self._get_n_bams()  # all the bams
        for ins_chrm in m_clip_checked:
            for ins_pos in m_clip_checked[ins_chrm]:
                # require all the bams should at least have some discordant reads
                # n_cutoff_disc_read = 4  ####At least 2 discordant reads#########################Hard code !!!!!!!!!!!!!
                b_sample_consist = True
                tmp_n_bams = 0
                if (ins_chrm in m_sample_disc) and (ins_pos in m_sample_disc[ins_chrm]):
                    for sample_id in m_sample_disc[ins_chrm][ins_pos]:
                        tmp_n_bams += 1
                        if m_sample_disc[ins_chrm][ins_pos][sample_id] < n_disc_cutoff:  # all the bams have support
                            b_sample_consist = False
                            break

                if b_sample_consist == False:
                    continue

                if tmp_n_bams < n_bams_all:  # require discordant reads exist at all the bams
                    continue

                if ins_chrm not in m_selected:
                    m_selected[ins_chrm] = {}
                if ins_pos not in m_selected[ins_chrm]:
                    m_selected[ins_chrm][ins_pos] = m_clip_checked[ins_chrm][ins_pos]
        return m_selected


    # First, seperate the disc reads to left and right
    # Second, check (left, right seperately) whether most of the disc reads (> ratio) will form cluster
    def check_seprt_disc_consistency(self, m_repsnt_pos, m_disc, icorcord, ratio, ndisc_cutoff, b_transduct=False):
        m_selected = {}
        ckcluster = ClusterChecker()
        for ins_chrm in m_repsnt_pos:
            for ins_pos in m_repsnt_pos[ins_chrm]:
                clip_pos = m_repsnt_pos[ins_chrm][ins_pos]
                l_l_cns_pos = []
                l_r_cns_pos = []
                n_l_rc = 0
                n_l_not_rc = 0
                n_r_rc = 0
                n_r_not_rc = 0
                n_l_rc2 = n_l_non_rc = n_r_rc2 = n_r_non_rc = 0 #save # of left-(non)rc and right-(non)rc reads
####Here, for anchor_pos, it's better to use the middle position as representative position
####!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                if (ins_chrm not in m_disc) or (ins_pos not in m_disc[ins_chrm]):
                    continue

                for (anchor_pos, is_anchor_lclip, is_anchor_rclip, cns_pos, b_same_ori, b_anchor_rc) \
                        in m_disc[ins_chrm][ins_pos]:
                    #here anchor_pos is the clip-position if the disc read is clipped at the same time
                    #Otherwise, if the read is fully mapped, then is the left-most position mappable position
                    b_lclip_disc=False #left clip and also discordant
                    b_rclip_disc=False #right clip and also discordant
                    if abs(anchor_pos-clip_pos)<global_values.NEARBY_CLIP:#
                        if is_anchor_lclip==True and is_anchor_rclip==False:
                            b_lclip_disc=True
                        if is_anchor_rclip==True and is_anchor_lclip==False:
                            b_rclip_disc=True

                    if b_lclip_disc==True:#read is disc and left-clip
                        l_r_cns_pos.append(cns_pos)
                        if b_same_ori == True:
                            n_r_rc += 1
                        else:
                            n_r_not_rc += 1
                        if b_anchor_rc==True:
                            n_r_rc2+=1
                        else:
                            n_r_non_rc+=1

                    elif b_rclip_disc==True:
                        l_l_cns_pos.append(cns_pos)
                        if b_same_ori == True:
                            n_l_rc += 1
                        else:
                            n_l_not_rc += 1

                        if b_anchor_rc==True:
                            n_l_rc2+=1
                        else:
                            n_l_non_rc+=1
                    else:
                        if anchor_pos < clip_pos:
                            l_l_cns_pos.append(cns_pos)
                            if b_same_ori == True:
                                n_l_rc += 1
                            else:
                                n_l_not_rc += 1

                            if b_anchor_rc == True:
                                n_l_rc2 += 1
                            else:
                                n_l_non_rc += 1
                        else:
                            l_r_cns_pos.append(cns_pos)
                            if b_same_ori == True:
                                n_r_rc += 1
                            else:
                                n_r_not_rc += 1

                            if b_anchor_rc == True:
                                n_r_rc2 += 1
                            else:
                                n_r_non_rc += 1
                n_l_disc = len(l_l_cns_pos)
                n_r_disc = len(l_r_cns_pos)

                #if return false, cns_start and cns_end will be set to -1
                b_lcluster, lcns_start, lcns_end = ckcluster._is_disc_cluster(l_l_cns_pos, icorcord, ratio)
                b_rcluster, rcns_start, rcns_end = ckcluster._is_disc_cluster(l_r_cns_pos, icorcord, ratio)

                ####Here require either left or right form the cluster
                if b_lcluster == False and b_rcluster == False:
                    continue
                ####If have both side cluster, than require at least n_disc_cutoff support
                if b_lcluster ==True and b_rcluster == True and (n_l_disc+n_r_disc)<ndisc_cutoff:
                    continue
                if b_transduct==True:
                    if b_lcluster ==True and b_rcluster == False and n_l_disc<(ndisc_cutoff/2):
                        continue
                    elif b_lcluster == False and b_rcluster == True and n_r_disc<(ndisc_cutoff/2):
                        continue
                ####
####should use a different cutoff
####skip for now
                # b_disc_dir_consist=ckcluster._is_disc_orientation_consistency(n_l_rc, n_l_non_rc, n_r_rc, n_r_non_rc, ratio)
                # if b_disc_dir_consist==False:
                #     continue

                rc_rcd = (n_l_rc, n_l_not_rc, n_r_rc, n_r_not_rc) #this is the pair whether are of same orientation
                anchor_rc_rcd=(n_l_rc2, n_l_non_rc, n_r_rc2, n_r_non_rc)
                if ins_chrm not in m_selected:
                    m_selected[ins_chrm] = {}
                m_selected[ins_chrm][ins_pos] = (n_l_disc, lcns_start, lcns_end, n_r_disc, rcns_start, rcns_end,
                                                rc_rcd, anchor_rc_rcd)
        return m_selected

####
    # This version is for somatic filtering step, we will keep all sites, no matter whether it has disc cluster or not
    # First, seperate the disc reads to left and right
    # Second, check (left, right seperately) whether most of the disc reads (> ratio) will form cluster
    def check_seprt_disc_consistency_for_somatic(self, m_repsnt_pos, m_disc, icorcord, ratio, ndisc_cutoff):
        m_selected = {}
        ckcluster = ClusterChecker()
        for ins_chrm in m_repsnt_pos:
            for ins_pos in m_repsnt_pos[ins_chrm]:
                clip_pos = m_repsnt_pos[ins_chrm][ins_pos]
                l_l_cns_pos = []
                l_r_cns_pos = []
                n_l_rc = 0
                n_l_not_rc = 0
                n_r_rc = 0
                n_r_not_rc = 0
                n_l_rc = n_l_non_rc = n_r_rc = n_r_non_rc = 0  # save # of left-(non)rc and right-(non)rc reads
                ####Here, for anchor_pos, it's better to use the middle position as representative position
                ####!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                if (ins_chrm not in m_disc) or (ins_pos not in m_disc[ins_chrm]):
                    rc_rcd = (
                    n_l_rc, n_l_not_rc, n_r_rc, n_r_not_rc)  # this is the pair whether are of same orientation
                    anchor_rc_rcd = (n_l_rc, n_l_non_rc, n_r_rc, n_r_non_rc)
                    if ins_chrm not in m_selected:
                        m_selected[ins_chrm] = {}
                    m_selected[ins_chrm][ins_pos] = (0, -1, -1, 0, -1, -1,
                                                     rc_rcd, anchor_rc_rcd)
                    continue

                for (anchor_pos, is_anchor_lclip, is_anchor_rclip, cns_pos, b_same_ori, b_anchor_rc) \
                        in m_disc[ins_chrm][ins_pos]:
                    # here anchor_pos is the clip-position if the disc read is clipped at the same time
                    # Otherwise, if the read is fully mapped, then is the left-most position mappable position
                    b_lclip_disc = False  # left clip and also discordant
                    b_rclip_disc = False  # right clip and also discordant
                    if abs(anchor_pos - clip_pos) < global_values.NEARBY_CLIP:  #
                        if is_anchor_lclip == True and is_anchor_rclip == False:
                            b_lclip_disc = True
                        if is_anchor_rclip == True and is_anchor_lclip == False:
                            b_rclip_disc = True

                    if b_lclip_disc == True:  # read is disc and left-clip
                        l_r_cns_pos.append(cns_pos)
                        if b_same_ori == True:
                            n_r_rc += 1
                        else:
                            n_r_not_rc += 1
                        if b_anchor_rc == True:
                            n_r_rc += 1
                        else:
                            n_r_non_rc += 1

                    elif b_rclip_disc == True:
                        l_l_cns_pos.append(cns_pos)
                        if b_same_ori == True:
                            n_l_rc += 1
                        else:
                            n_l_not_rc += 1

                        if b_anchor_rc == True:
                            n_l_rc += 1
                        else:
                            n_l_non_rc += 1
                    else:
                        if anchor_pos < clip_pos:
                            l_l_cns_pos.append(cns_pos)
                            if b_same_ori == True:
                                n_l_rc += 1
                            else:
                                n_l_not_rc += 1

                            if b_anchor_rc == True:
                                n_l_rc += 1
                            else:
                                n_l_non_rc += 1
                        else:
                            l_r_cns_pos.append(cns_pos)
                            if b_same_ori == True:
                                n_r_rc += 1
                            else:
                                n_r_not_rc += 1

                            if b_anchor_rc == True:
                                n_r_rc += 1
                            else:
                                n_r_non_rc += 1
                n_l_disc = len(l_l_cns_pos)
                n_r_disc = len(l_r_cns_pos)

                # if return false, cns_start and cns_end will be set to -1
                b_lcluster, lcns_start, lcns_end = ckcluster._is_disc_cluster(l_l_cns_pos, icorcord, ratio)
                b_rcluster, rcns_start, rcns_end = ckcluster._is_disc_cluster(l_r_cns_pos, icorcord, ratio)

                # ####Here require either left or right form the cluster
                # if b_lcluster == False and b_rcluster == False:
                #     continue
                #
                # ####If have both side cluster, than require at least n_disc_cutoff support
                # if b_lcluster == True and b_rcluster == True and (n_l_disc + n_r_disc) < ndisc_cutoff:
                #     continue

                rc_rcd = (n_l_rc, n_l_not_rc, n_r_rc, n_r_not_rc)#this is the pair whether are of same orientation
                anchor_rc_rcd = (n_l_rc, n_l_non_rc, n_r_rc, n_r_non_rc)
                if ins_chrm not in m_selected:
                    m_selected[ins_chrm] = {}
                m_selected[ins_chrm][ins_pos] = (n_l_disc, lcns_start, lcns_end, n_r_disc, rcns_start, rcns_end,
                                                 rc_rcd, anchor_rc_rcd)
        return m_selected

    ####
    # check the clipped part is qualified aligned or not
    def is_clipped_part_qualified_algnmt(self, l_cigar, ratio_cutoff):
        if len(l_cigar) < 1:  # wrong alignment
            return False, 0
        if len(l_cigar) > 2:
            ####check the cigar
            ###if both clipped, and the clipped part is large, then skip
            b_left_clip = False
            i_left_clip_len = 0
            if l_cigar[0][0] == 4 or l_cigar[0][0] == 5:  # left clipped
                b_left_clip = True
                i_left_clip_len = l_cigar[0][1]
            b_right_clip = False
            i_right_clip_len = 0
            if l_cigar[-1][0] == 4 or l_cigar[-1][0] == 5:  # right clipped
                b_right_clip = True
                i_right_clip_len = l_cigar[-1][1]

            if b_left_clip == True and b_right_clip == True:
                if (i_left_clip_len > global_values.MAX_CLIP_CLIP_LEN) and (i_right_clip_len > global_values.MAX_CLIP_CLIP_LEN):
                    return False, 0

        ####for the alignment (of the clipped read), if the mapped part is smaller than the clipped part,
        ####then skip
        n_total = 0
        n_map = 0
        for (type, lenth) in l_cigar:
            if type == 0:
                n_map += lenth
            if type != 2:  # deletion is not added to the total length
                n_total += lenth

        if n_map < (n_total * ratio_cutoff):  ########################require at least 3/4 of the seq is mapped !!!!!!!!
            return False, 0
        return True, n_map

        ####
        # Parse the re-aligned clipped parts, and find the
        # 1) max-left(right)-clip on reference, and max-clip pos on consensus
        # 2) get the potential TSD
        # 3) transduction
        ##parameter: 1) sf_clip_alignmt: the re-aligned clipped part, 2) minimum mapped ratio for realigned clip part

    ####
    # Here only consider the clipped reads within [-extend, extend] around the original insertion position
    ####
    def parse_clip_realignment(self, sf_clip_alignmt, bmapped_cutoff, mrmsk, i_flank_lenth):
        samfile = pysam.AlignmentFile(sf_clip_alignmt, "r", reference_filename=self.sf_reference)
        m_ins_pos_left = {}  ##this is to statistic the insertion positions for left-clip on the reference
        m_ins_pos_right = {}  # for the right clipped positions
        m_rep_pos_left = {}  # this is to save the posiion on the repeat consensus of the left clipped reads
        m_rep_pos_right = {}  # this is to save the posiion on the repeat consensus of the right clipped reads
        m_transduction = {}  # save the candidate transduction positions

        m_ins_pos_sample = {}  # sample information of the clip position
        m_polyA = {}
        xpolyA=PolyA()
        for algnmt in samfile.fetch():
            if algnmt.is_unmapped == True:  ####skip the unmapped reads
                continue

            # In format:chrm~map_pos~FLAG_RIGHT(LEFT)_CLIP~is_reverse_complementary~insertion_position~rid~sample_id
            read_info = algnmt.query_name
            read_info_fields = read_info.split(global_values.SEPERATOR)

            ori_chrm = read_info_fields[0]
            ref_mpos = int(read_info_fields[1])
            ori_clip_flag = read_info_fields[2]
            ori_is_rc = read_info_fields[3]  ##############this is not used here now
            ori_insertion_pos = int(read_info_fields[4])
            sample_id = read_info_fields[6]  ####sample id
            #####Hard code here#########################################################################################
            if abs(ref_mpos - ori_insertion_pos) > 50:
                continue

            b_left = True  # left clip
            if ori_clip_flag == global_values.FLAG_RIGHT_CLIP:
                b_left = False  # right clip

            # first check whether the clipped part is qualified aligned
            l_cigar = algnmt.cigar
            b_clip_qualified_algned, n_map_bases = self.is_clipped_part_qualified_algnmt(l_cigar, bmapped_cutoff)

            if b_clip_qualified_algned == False:  # skip the unqualified re-aligned parts
                continue

            # map position on repeat consensus
            map_pos_copy = algnmt.reference_start  # map position on which repeat copy
            b_clip_part_rc = algnmt.is_reverse
            # id in format: chrm~start_pos~end_pos~sub-family
            mapped_copy_id = algnmt.reference_name  # map to which repeat copy

            mapped_copy_fields = mapped_copy_id.split(global_values.SEPERATOR)
            copy_chrm = mapped_copy_fields[0]
            copy_start = int(mapped_copy_fields[1])
            copy_end = int(mapped_copy_fields[2])
            # copy_sub_family=mapped_copy_fields[3]
            clipped_seq = algnmt.query_sequence
            ##if it is mapped to the left flank regions
            # here make sure it is not poly-A
            b_polya = xpolyA.contain_poly_A_T(clipped_seq, global_values.N_MIN_A_T)  # by default, at least 5A or 5T
            mapq = algnmt.mapping_quality

            if b_polya == True:
                if ori_chrm not in m_polyA:
                    m_polyA[ori_chrm] = {}
                if ori_insertion_pos not in m_polyA[ori_chrm]:
                    m_polyA[ori_chrm][ori_insertion_pos] = []
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                if b_left == True:
                    m_polyA[ori_chrm][ori_insertion_pos][0] += 1
                else:
                    m_polyA[ori_chrm][ori_insertion_pos][1] += 1

            # for those mapped to the flanks
            # each insertion have two sides, so if both sides are transduction (very rare), then will be missed
            #
            if (map_pos_copy < (i_flank_lenth - 5)) or (
                        map_pos_copy > (copy_end - copy_start + i_flank_lenth - 5)):

                if (mapq >= global_values.MINIMAL_TRANSDUCT_MAPQ) and b_polya == False:  # possible transduction
                    if ori_chrm not in m_transduction:
                        m_transduction[ori_chrm] = {}
                    if ori_insertion_pos not in m_transduction[ori_chrm]:
                        m_transduction[ori_chrm][ori_insertion_pos] = {}
                    transduct_pos = "{0}~{1}~{2}".format(copy_chrm, copy_start, copy_end)
                    if transduct_pos not in m_transduction[ori_chrm][ori_insertion_pos]:
                        m_transduction[ori_chrm][ori_insertion_pos][transduct_pos] = []

                    # TDList:convert this to ref pos
                    m_transduction[ori_chrm][ori_insertion_pos][transduct_pos].append(map_pos_copy)
                continue
            #
            # calculate the position in consensus
            pos_in_consensus = -1
            if copy_chrm in mrmsk:
                if copy_start in mrmsk[copy_chrm]:
                    copy_record = mrmsk[copy_chrm][copy_start][0]
                    cns_start = copy_record[-2]
                    cns_end = copy_record[-1]
                    b_copy_rc = copy_record[1]

                    # first, get the clip position on the copy
                    if (b_clip_part_rc and b_left) or (b_clip_part_rc == False and b_left == False):
                        map_pos_copy += n_map_bases

                    # here need to pay attention whether the copy is masked "reverse complementary" or not.
                    # If the copy is masked "reverse complementary", then the position in consensus should be reversed
                    i_offset = map_pos_copy - i_flank_lenth
                    if b_copy_rc == True:
                        i_offset = (cns_end - cns_start) - map_pos_copy + i_flank_lenth

                    # convert the map_pos on repeat copy to position on consensus
                    pos_in_consensus = cns_start + i_offset

                    # if pos_in_consensus< -2:##########################################################################
                    #     print map_pos_copy, mapped_copy_id, copy_record, pos_in_consensus

            ###save the clip position on the refernece
            if b_left == True:  # left clipped, save to "m_ins_pos_left"
                if ori_chrm not in m_ins_pos_left:
                    m_ins_pos_left[ori_chrm] = {}
                if ori_insertion_pos not in m_ins_pos_left[ori_chrm]:
                    m_ins_pos_left[ori_chrm][ori_insertion_pos] = {}
                if ref_mpos not in m_ins_pos_left[ori_chrm][ori_insertion_pos]:
                    m_ins_pos_left[ori_chrm][ori_insertion_pos][ref_mpos] = []
                m_ins_pos_left[ori_chrm][ori_insertion_pos][ref_mpos].append(pos_in_consensus)  # note  "-1"
            else:
                if ori_chrm not in m_ins_pos_right:
                    m_ins_pos_right[ori_chrm] = {}
                if ori_insertion_pos not in m_ins_pos_right[ori_chrm]:
                    m_ins_pos_right[ori_chrm][ori_insertion_pos] = {}
                if ref_mpos not in m_ins_pos_right[ori_chrm][ori_insertion_pos]:
                    m_ins_pos_right[ori_chrm][ori_insertion_pos][ref_mpos] = []
                m_ins_pos_right[ori_chrm][ori_insertion_pos][ref_mpos].append(pos_in_consensus)  # note  "-1"

            ##save the clip position on the repeat consensus
            if b_left == True:
                if ori_chrm not in m_rep_pos_left:
                    m_rep_pos_left[ori_chrm] = {}
                if ori_insertion_pos not in m_rep_pos_left[ori_chrm]:
                    m_rep_pos_left[ori_chrm][ori_insertion_pos] = {}
                if pos_in_consensus not in m_rep_pos_left[ori_chrm][ori_insertion_pos]:
                    m_rep_pos_left[ori_chrm][ori_insertion_pos][pos_in_consensus] = 1
                else:
                    m_rep_pos_left[ori_chrm][ori_insertion_pos][pos_in_consensus] += 1
            else:
                if ori_chrm not in m_rep_pos_right:
                    m_rep_pos_right[ori_chrm] = {}
                if ori_insertion_pos not in m_rep_pos_right[ori_chrm]:
                    m_rep_pos_right[ori_chrm][ori_insertion_pos] = {}
                if pos_in_consensus not in m_rep_pos_right[ori_chrm][ori_insertion_pos]:
                    m_rep_pos_right[ori_chrm][ori_insertion_pos][pos_in_consensus] = 1
                else:
                    m_rep_pos_right[ori_chrm][ori_insertion_pos][pos_in_consensus] += 1

            # save the sample information
            if ori_chrm not in m_ins_pos_sample:
                m_ins_pos_sample[ori_chrm] = {}
            if ori_insertion_pos not in m_ins_pos_sample[ori_chrm]:
                m_ins_pos_sample[ori_chrm][ori_insertion_pos] = {}
            if sample_id not in m_ins_pos_sample[ori_chrm][ori_insertion_pos]:
                m_ins_pos_sample[ori_chrm][ori_insertion_pos][sample_id] = []
                m_ins_pos_sample[ori_chrm][ori_insertion_pos][sample_id].append(0)
                m_ins_pos_sample[ori_chrm][ori_insertion_pos][sample_id].append(0)
            if b_left == True:
                m_ins_pos_sample[ori_chrm][ori_insertion_pos][sample_id][0] += 1
            else:
                m_ins_pos_sample[ori_chrm][ori_insertion_pos][sample_id][1] += 1

        samfile.close()
        return m_ins_pos_left, m_ins_pos_right, m_ins_pos_sample, m_transduction, m_polyA
####
####
    # for this version, the clipped parts are realigned to the consensus, not all the repeat copies
    def parse_clip_realignment_consensus(self, sf_clip_alignmt, bmapped_cutoff):
        samfile = pysam.AlignmentFile(sf_clip_alignmt, "r", reference_filename=self.sf_reference)
        m_ins_pos_left = {}  ##this is to statistic the insertion positions for left-clip on the reference
        m_ins_pos_right = {}  # for the right clipped positions
        m_rep_pos_left = {}  # this is to save the posiion on the repeat consensus of the left clipped reads
        m_rep_pos_right = {}  # this is to save the posiion on the repeat consensus of the right clipped reads
        # m_transduction = {}  # save the candidate transduction positions

        m_ins_pos_sample = {}  # sample information of the clip position
        m_polyA = {}
        xpolyA=PolyA()
        for algnmt in samfile.fetch():
            # also check the mapping quality
            # mapq = algnmt.mapping_quality
            # if mapq<global_values.MINIMUM_DISC_MAPQ:##############Here should be very careful for SVA and Alu!!!!!!!!!!!!!!!!!!!!!!!
            #     continue

            # In format:chrm~map_pos~FLAG_RIGHT(LEFT)_CLIP~is_reverse_complementary~insertion_position~rid~sample_id
            read_info = algnmt.query_name
            read_info_fields = read_info.split(global_values.SEPERATOR)

            ori_chrm = read_info_fields[0]
            ref_mpos = int(read_info_fields[1])
            ori_clip_flag = read_info_fields[2]
            ori_is_rc = read_info_fields[3]  ##############this is not used here now
            ori_insertion_pos = int(read_info_fields[4])
            sample_id = read_info_fields[6]  ####sample id

            #####Hard code here#######################################################################################
            if abs(ref_mpos - ori_insertion_pos) > global_values.NEARBY_CLIP:  # only focus on the nearby clipped reads
                continue

            b_left = True  # left clip
            if ori_clip_flag == global_values.FLAG_RIGHT_CLIP:
                b_left = False  # right clip


            if algnmt.is_unmapped == True:  ####skip the unmapped reads
                continue
            # first check whether the clipped part is qualified aligned
            l_cigar = algnmt.cigar
            b_clip_qualified_algned, n_map_bases = self.is_clipped_part_qualified_algnmt(l_cigar, bmapped_cutoff)

            if b_clip_qualified_algned == False:  # skip the unqualified re-aligned parts
                continue

            clipped_seq = algnmt.query_sequence
            b_clip_part_rc = algnmt.is_reverse #whether the aligned clip part is reverse complementary
####06-11-2019: bug here, didn't conosider whether the alignment is reverse-complementary or not
####Now add module to check whether the aligmnment is reverse complementary or not
            s_clip_seq_ck = ""
            if b_clip_part_rc==False:#not reverse complementary
                if b_left == False:  # right clip
                    if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                        s_clip_seq_ck = clipped_seq[:global_values.CK_POLYA_SEQ_MAX]
                    else:
                        s_clip_seq_ck = clipped_seq
                else:  # left clip
                    if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                        s_clip_seq_ck = clipped_seq[-1 * global_values.CK_POLYA_SEQ_MAX:]
                    else:
                        s_clip_seq_ck = clipped_seq
            else:# clip part is reverse complementary
                if b_left == True:  # left clip
                    if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                        s_clip_seq_ck = clipped_seq[:global_values.CK_POLYA_SEQ_MAX]
                    else:
                        s_clip_seq_ck = clipped_seq
                else:  # right clip
                    if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                        s_clip_seq_ck = clipped_seq[-1 * global_values.CK_POLYA_SEQ_MAX:]
                    else:
                        s_clip_seq_ck = clipped_seq

            ##if it is mapped to the left flank regions
            # here make sure it is not poly-A
            # b_polya = self.contain_poly_A_T(clipped_seq, global_values.N_MIN_A_T)  # by default, at least 5A or 5T
            # b_polya = xpolyA.is_consecutive_polyA_T(s_clip_seq_ck)
            #b_polya = xpolyA.contain_enough_A_T(s_clip_seq_ck, int(len(s_clip_seq_ck) * global_values.POLYA_RATIO))


            ##if it is mapped to the left flank regions
            # here make sure it is not poly-A
            #b_polya = self.contain_poly_A_T(clipped_seq, global_values.N_MIN_A_T)  # by default, at least 5A or 5T
##!!!!!!!!!!!!!!!!!!!!!!!
####Note that: as this is aligned to consensus, only have AAAAA, but no TTTTTT
            b_polya = xpolyA.is_consecutive_polyA(s_clip_seq_ck)
            if b_polya == True:
                if ori_chrm not in m_polyA:
                    m_polyA[ori_chrm] = {}
                if ori_insertion_pos not in m_polyA[ori_chrm]:
                    m_polyA[ori_chrm][ori_insertion_pos] = []
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                if b_left == True:
                    m_polyA[ori_chrm][ori_insertion_pos][0] += 1
                    if b_clip_part_rc==False:#False means polyA, True means polyT
                        m_polyA[ori_chrm][ori_insertion_pos][2] += 1
                else:
                    m_polyA[ori_chrm][ori_insertion_pos][1] += 1
                    if b_clip_part_rc==False:#False means polyA, True means polyT
                        m_polyA[ori_chrm][ori_insertion_pos][3] += 1

            # calculate the position in consensus
            pos_in_consensus = algnmt.reference_start  # map position on which repeat copy

            # first, get the clip position on the copy
            if (b_clip_part_rc and b_left) or (b_clip_part_rc == False and b_left == False):
                pos_in_consensus += n_map_bases

            ###save the clip position on the refernece
            ##potential problem here:If the read is both-end clipped, then will be only considered as left-clipped
            ##When collect the clipped reads at function: collect_clipped_disc_reads,
            #### both-end clipped reads (clipped parts are long) are saved as left-clipped and right-clipped.
            if b_left == True:  # left clipped, save to "m_ins_pos_left"
                if ori_chrm not in m_ins_pos_left:
                    m_ins_pos_left[ori_chrm] = {}
                if ori_insertion_pos not in m_ins_pos_left[ori_chrm]:
                    m_ins_pos_left[ori_chrm][ori_insertion_pos] = {}
                if ref_mpos not in m_ins_pos_left[ori_chrm][ori_insertion_pos]:
                    m_ins_pos_left[ori_chrm][ori_insertion_pos][ref_mpos] = []
                m_ins_pos_left[ori_chrm][ori_insertion_pos][ref_mpos].append(pos_in_consensus)  # note  "-1"
            else:
                if ori_chrm not in m_ins_pos_right:
                    m_ins_pos_right[ori_chrm] = {}
                if ori_insertion_pos not in m_ins_pos_right[ori_chrm]:
                    m_ins_pos_right[ori_chrm][ori_insertion_pos] = {}
                if ref_mpos not in m_ins_pos_right[ori_chrm][ori_insertion_pos]:
                    m_ins_pos_right[ori_chrm][ori_insertion_pos][ref_mpos] = []
                m_ins_pos_right[ori_chrm][ori_insertion_pos][ref_mpos].append(pos_in_consensus)  # note  "-1"

            ##save the clip position on the repeat consensus
            if b_left == True:
                if ori_chrm not in m_rep_pos_left:
                    m_rep_pos_left[ori_chrm] = {}
                if ori_insertion_pos not in m_rep_pos_left[ori_chrm]:
                    m_rep_pos_left[ori_chrm][ori_insertion_pos] = {}
                if pos_in_consensus not in m_rep_pos_left[ori_chrm][ori_insertion_pos]:
                    m_rep_pos_left[ori_chrm][ori_insertion_pos][pos_in_consensus] = 1
                else:
                    m_rep_pos_left[ori_chrm][ori_insertion_pos][pos_in_consensus] += 1
            else:
                if ori_chrm not in m_rep_pos_right:
                    m_rep_pos_right[ori_chrm] = {}
                if ori_insertion_pos not in m_rep_pos_right[ori_chrm]:
                    m_rep_pos_right[ori_chrm][ori_insertion_pos] = {}
                if pos_in_consensus not in m_rep_pos_right[ori_chrm][ori_insertion_pos]:
                    m_rep_pos_right[ori_chrm][ori_insertion_pos][pos_in_consensus] = 1
                else:
                    m_rep_pos_right[ori_chrm][ori_insertion_pos][pos_in_consensus] += 1

            # save the sample information
            if ori_chrm not in m_ins_pos_sample:
                m_ins_pos_sample[ori_chrm] = {}
            if ori_insertion_pos not in m_ins_pos_sample[ori_chrm]:
                m_ins_pos_sample[ori_chrm][ori_insertion_pos] = {}
            if sample_id not in m_ins_pos_sample[ori_chrm][ori_insertion_pos]:
                m_ins_pos_sample[ori_chrm][ori_insertion_pos][sample_id] = []
                m_ins_pos_sample[ori_chrm][ori_insertion_pos][sample_id].append(0)
                m_ins_pos_sample[ori_chrm][ori_insertion_pos][sample_id].append(0)
            if b_left == True:
                m_ins_pos_sample[ori_chrm][ori_insertion_pos][sample_id][0] += 1
            else:
                m_ins_pos_sample[ori_chrm][ori_insertion_pos][sample_id][1] += 1

        samfile.close()
        return m_ins_pos_left, m_ins_pos_right, m_rep_pos_left, m_rep_pos_right, m_ins_pos_sample, m_polyA

    ####
    # parse the re-aligned discordant reads
    # return two dict: 1) the aligned position on the repeat; 2) candidate transductions
    def parse_disc_algnmt(self, sf_disc_alignmt, bmapped_cutoff, mrmsk, i_flank_lenth):
        samfile = pysam.AlignmentFile(sf_disc_alignmt, "r", reference_filename=self.sf_reference)
        m_disc_pos = {}
        m_transduction_disc = {}
        m_polyA = {}
        m_disc_sample = {}
        xpolyA=PolyA()
        for algnmt in samfile.fetch():
            if algnmt.is_unmapped == True:  ####skip the unmapped reads
                continue
            mapq = algnmt.mapping_quality
            ####also, for clipped mapped reads, need to check the clipped parts whether can be split to two parts!!!!!!
            read_info = algnmt.query_name  # in format: #read_id~is_first~s_insertion_chrm~s_insertion_pos~sample_id
            read_info_fields = read_info.split(global_values.SEPERATOR)
            ins_chrm = read_info_fields[-3]
            ins_pos = int(read_info_fields[-2])
            sample_id = read_info_fields[-1]

            # first check whether read is qualified mapped
            l_cigar = algnmt.cigar
            b_clip_qualified_algned, n_map_bases = self.is_clipped_part_qualified_algnmt(l_cigar, bmapped_cutoff)
            if b_clip_qualified_algned == False:  # skip the unqualified re-aligned parts
                continue

            map_pos_copy = algnmt.reference_start  # map position on repeat copy
            mapped_copy_id = algnmt.reference_name  # map to which repeat copy
            mapped_copy_fields = mapped_copy_id.split(global_values.SEPERATOR)
            copy_chrm = mapped_copy_fields[0]
            copy_start = int(mapped_copy_fields[1])
            copy_end = int(mapped_copy_fields[2])

            read_seq = algnmt.query_sequence
            b_polya = xpolyA.contain_poly_A_T(read_seq, global_values.N_MIN_A_T)
            if b_polya == True:
                if ins_chrm not in m_polyA:
                    m_polyA[ins_chrm] = {}
                if ins_pos not in m_polyA[ins_chrm]:
                    m_polyA[ins_chrm][ins_pos] = 1
                else:
                    m_polyA[ins_chrm][ins_pos] += 1
            # mapped to flank region of the copy
            # transduction situation
            if ((mapq >= global_values.MINIMAL_TRANSDUCT_MAPQ) and (map_pos_copy < (i_flank_lenth - 15)) or (
                        map_pos_copy > (copy_end - copy_start + i_flank_lenth - 15))) and b_polya == False:
                if ins_chrm not in m_transduction_disc:
                    m_transduction_disc[ins_chrm] = {}
                if ins_pos not in m_transduction_disc[ins_chrm]:
                    m_transduction_disc[ins_chrm][ins_pos] = {}
                transduct_pos = "{0}~{1}~{2}".format(copy_chrm, copy_start, copy_end)
                if transduct_pos not in m_transduction_disc[ins_chrm][ins_pos]:
                    m_transduction_disc[ins_chrm][ins_pos][transduct_pos] = []
                m_transduction_disc[ins_chrm][ins_pos][transduct_pos].append(map_pos_copy)
                continue

            map_pos_copy += (len(read_seq) / 2)  ####use the middle as the map position
            ###not transduction, then find the position on consensus
            if copy_chrm in mrmsk:
                if copy_start in mrmsk[copy_chrm]:
                    copy_record = mrmsk[copy_chrm][copy_start][0]
                    cns_start = copy_record[-2]
                    cns_end = copy_record[-1]
                    b_copy_rc = copy_record[1]

                    i_offset = map_pos_copy - i_flank_lenth
                    if b_copy_rc == True:
                        i_offset = (cns_end - cns_start) - map_pos_copy + i_flank_lenth
                    # convert the map_pos on repeat copy to position on consensus
                    pos_in_consensus = cns_start + i_offset
                    if ins_chrm not in m_disc_pos:
                        m_disc_pos[ins_chrm] = {}
                    if ins_pos not in m_disc_pos[ins_chrm]:
                        m_disc_pos[ins_chrm][ins_pos] = []
                    m_disc_pos[ins_chrm][ins_pos].append(pos_in_consensus)

            ###
            if ins_chrm not in m_disc_sample:
                m_disc_sample[ins_chrm] = {}
            if ins_pos not in m_disc_sample[ins_chrm]:
                m_disc_sample[ins_chrm][ins_pos] = {}
            if sample_id not in m_disc_sample[ins_chrm][ins_pos]:
                m_disc_sample[ins_chrm][ins_pos][sample_id] = 1
            else:
                m_disc_sample[ins_chrm][ins_pos][sample_id] += 1

        samfile.close()
        return m_disc_pos, m_disc_sample, m_transduction_disc, m_polyA

####
    # For this version, reads are aligned to the consensus sequence
    # Note that the poly-A part in the consensus has been removed, so it's possible reads will be clipped mapped (at end)
    def parse_disc_algnmt_consensus(self, sf_disc_alignmt, bmapped_cutoff):
        samfile = pysam.AlignmentFile(sf_disc_alignmt, "r", reference_filename=self.sf_reference)
        m_disc_pos = {}
        m_polyA = {}
        m_disc_sample = {}
        xpolyA = PolyA()
        for algnmt in samfile.fetch():
            # mapq = algnmt.mapping_quality
            # if mapq<global_values.MINIMUM_DISC_MAPQ:##############Here should be very careful for SVA and Alu!!!!!!!!!!!!!!!!!!!!!!!
            #     continue
            ####also, for clipped mapped reads, need to check the clipped parts whether can be split to two parts!!!!!!
            # fmt:read_id~is_first~is_anchor_rc~is_anchor_mate_rc~anchor_pos~s_insertion_chrm~s_insertion_pos~sample_id
            if algnmt.is_unmapped == True:  ####skip the unmapped reads
                continue
            # first check whether read is qualified mapped
            l_cigar = algnmt.cigar
            b_clip_qualified_algned, n_map_bases = self.is_clipped_part_qualified_algnmt(l_cigar, bmapped_cutoff)
            if b_clip_qualified_algned == False:  # skip the unqualified re-aligned parts
                continue

            read_info = algnmt.query_name
            read_info_fields = read_info.split(global_values.SEPERATOR)
            s_anchor_lclip=read_info_fields[-8] #anchor read is left clip or not: 1 indicates clip
            s_anchor_rclip=read_info_fields[-7] #anchor read is right clip or not: 1 indicates clip
            s_anchor_rc = read_info_fields[-6]
            s_anchor_mate_rc = read_info_fields[-5]
            anchor_map_pos = int(read_info_fields[-4]) #this is the position of the left-most mapped base
            ins_chrm = read_info_fields[-3]
            ins_pos = int(read_info_fields[-2])
            sample_id = read_info_fields[-1]
            read_seq = algnmt.query_sequence

            b_polya = xpolyA.is_consecutive_polyA_T(read_seq)
            if b_polya == True:
                if ins_chrm not in m_polyA:
                    m_polyA[ins_chrm] = {}
                if ins_pos not in m_polyA[ins_chrm]:
                    m_polyA[ins_chrm][ins_pos] = 1
                else:
                    m_polyA[ins_chrm][ins_pos] += 1

            # map position on repeat consensus
            pos_in_consensus = algnmt.reference_start + len(read_seq) / 2
            if ins_chrm not in m_disc_pos:
                m_disc_pos[ins_chrm] = {}
            if ins_pos not in m_disc_pos[ins_chrm]:
                m_disc_pos[ins_chrm][ins_pos] = []

            ##Here to check orientation of the two reads, and later will be used to detect inversion
            b_anchor_mate_rc = False
            if s_anchor_mate_rc == "1":
                b_anchor_mate_rc = True
            b_masked_rc = algnmt.is_reverse
            if b_anchor_mate_rc == True:
                b_masked_rc = (not algnmt.is_reverse)

            b_anchor_rc = False
            if s_anchor_rc == "1":####
                b_anchor_rc = True

            # if b_anchor_rc==True:
            #     l_disc_anchor_rc.append(anchor_map_pos)
            # else:
            #     l_disc_anchor_not_rc.append(anchor_map_pos)

            b_anchor_lclip=False
            if s_anchor_lclip=="1":
                b_anchor_lclip=True

            b_anchor_rclip=False
            if s_anchor_rclip=="1":
                b_anchor_rclip=True

            b_same_dir_xor = (b_masked_rc != b_anchor_rc)  # check the xor results
            m_disc_pos[ins_chrm][ins_pos].append((anchor_map_pos, b_anchor_lclip, b_anchor_rclip, pos_in_consensus,
                                                  b_same_dir_xor, b_anchor_rc))

            if ins_chrm not in m_disc_sample:
                m_disc_sample[ins_chrm] = {}
            if ins_pos not in m_disc_sample[ins_chrm]:
                m_disc_sample[ins_chrm][ins_pos] = {}
            if sample_id not in m_disc_sample[ins_chrm][ins_pos]:
                m_disc_sample[ins_chrm][ins_pos][sample_id] = 1
            else:
                m_disc_sample[ins_chrm][ins_pos][sample_id] += 1
        samfile.close()
        return m_disc_pos, m_disc_sample, m_polyA

    ####
    # # Given annotation file, flank region length,
    # def re_locate_in_consensus(self, xannotation, i_flank_length, chrm, map_pos):
    #     return
    #####

    # for given a lits of candidate sites, and a given list of bam files
    # get all the clipped and discordant reads
    # also add the sample id when merging the reads
    def collect_clipped_disc_reads(self, sf_candidate_list, extnd, bin_size, sf_clip_fq, sf_disc_fa, sf_raw_sites=""):
        #sf_raw_clip_fq=sf_raw_sites+global_values.RAW_CLIP_FQ_SUFFIX
        sf_raw_disc_fa=sf_raw_sites+global_values.RAW_DISC_FA_SUFFIX
        m_lowq_clip = {}
        with open(sf_clip_fq, "w") as fout_clip_fq, open(sf_disc_fa, "w") as fout_disc_fa:
            # first collect all the clipped and discordant reads
            sample_cnt = 0
            with open(self.sf_bam_list) as fin_bam_list:
                for line in fin_bam_list:  # for each bam file
                    fields=line.split()
                    sf_bam = fields[0]
                    xclip_disc = XClipDisc(sf_bam, self.working_folder, self.n_jobs, self.sf_reference)
                    sf_disc_fa_tmp = self.working_folder + "temp_disc.fa" + str(sample_cnt)
                    sf_clip_fa_tmp = self.working_folder + "temp_clip.fq" + str(sample_cnt)

                    ####collect clipped and disc reads
                    l_low_mapq_clip=xclip_disc.collect_clipped_disc_reads_of_given_list(sf_candidate_list, extnd,
                                                                                        bin_size, sf_clip_fa_tmp,
                                                                                        sf_disc_fa_tmp)
                    for lowq_rcd in l_low_mapq_clip:
                        tmp_chrm=lowq_rcd[0]
                        tmp_pos=int(lowq_rcd[1])
                        n_lowq_clip=int(lowq_rcd[2])
                        if tmp_chrm not in m_lowq_clip:
                            m_lowq_clip[tmp_chrm]={}
                        if tmp_pos not in m_lowq_clip[tmp_chrm]:
                            m_lowq_clip[tmp_chrm][tmp_pos]=0
                        m_lowq_clip[tmp_chrm][tmp_pos] += n_lowq_clip

                    with open(sf_disc_fa_tmp) as fin_tmp_fa:
                        n_cnt = 0
                        for line in fin_tmp_fa:
                            if n_cnt % 2 == 0:
                                line = line.rstrip() + global_values.SEPERATOR + str(sample_cnt) + "\n"  ###here add the sample id
                            fout_disc_fa.write(line)
                            n_cnt += 1
                    with open(sf_clip_fa_tmp) as fin_clip_fq:
                        n_cnt = 0
                        for line in fin_clip_fq:
                            if n_cnt % 4 == 0:
                                line = line.rstrip() + global_values.SEPERATOR + str(sample_cnt) + "\n"
                            fout_clip_fq.write(line)
                            n_cnt += 1
                    sample_cnt += 1
                    #clean the temporary files
                    self.clean_file_by_path(sf_disc_fa_tmp)
                    self.clean_file_by_path(sf_clip_fa_tmp)
        return m_lowq_clip

####
    # for given a lits of candidate sites, and a given list of bam files
    # get all the clipped and discordant reads
    # also add the sample id when merging the reads
    def collect_clipped_reads(self, sf_candidate_list, extnd, sf_clip_fq):
        with open(sf_clip_fq, "w") as fout_clip_fq:
            # first collect all the clipped and discordant reads
            sample_cnt = 0
            with open(self.sf_bam_list) as fin_bam_list:
                for line in fin_bam_list:  # for each bam file
                    fields=line.split()
                    sf_bam = fields[0]
                    xclip_disc = XClipDisc(sf_bam, self.working_folder, self.n_jobs, self.sf_reference)
                    sf_clip_fa_tmp = self.working_folder + "temp_clip.fq" + str(sample_cnt)
                    ####collect clipped and disc reads
                    xclip_disc.collect_clipped_reads_of_given_list(sf_candidate_list, extnd, sf_clip_fa_tmp)
                    with open(sf_clip_fa_tmp) as fin_clip_fq:
                        n_cnt = 0
                        for line in fin_clip_fq:
                            if n_cnt % 4 == 0:
                                line = line.rstrip() + global_values.SEPERATOR + str(sample_cnt) + "\n"
                            fout_clip_fq.write(line)
                            n_cnt += 1
                    sample_cnt += 1
                    #clean the temporary files
                    self.clean_file_by_path(sf_clip_fa_tmp)

    # for given a lits of candidate sites, and a given list of bam files
    # get all the clipped and discordant reads
    # also add the sample id when merging the reads
    def collect_disc_reads(self, sf_candidate_list, extnd, bin_size, sf_disc_fa):
        with open(sf_disc_fa, "w") as fout_disc_fa:
            # first collect all the clipped and discordant reads
            sample_cnt = 0
            with open(self.sf_bam_list) as fin_bam_list:
                for line in fin_bam_list:  # for each bam file
                    fields=line.split()
                    sf_bam = fields[0]
                    xclip_disc = XClipDisc(sf_bam, self.working_folder, self.n_jobs, self.sf_reference)
                    sf_disc_fa_tmp = self.working_folder + "temp_disc.fa" + str(sample_cnt)

                    ####collect clipped and disc reads
                    xclip_disc.collect_disc_reads_of_given_list(sf_candidate_list, extnd, bin_size, sf_disc_fa_tmp)
                    with open(sf_disc_fa_tmp) as fin_tmp_fa:
                        n_cnt = 0
                        for line in fin_tmp_fa:
                            if n_cnt % 2 == 0:
                                line = line.rstrip() + global_values.SEPERATOR + str(sample_cnt) + "\n"  ###here add the sample id
                            fout_disc_fa.write(line)
                            n_cnt += 1
                    sample_cnt += 1
                    #clean the temporary files
                    self.clean_file_by_path(sf_disc_fa_tmp)
####clean the file