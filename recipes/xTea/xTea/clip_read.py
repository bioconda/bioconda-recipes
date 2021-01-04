##11/04/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu


import pysam
from x_annotation import *
from x_alignments import *
from x_intermediate_sites import *
import global_values
from x_polyA import *
from bwa_align import *

class OneClipRead():
    def __init__(self):
        self.left_brk_pos = -1
        self.left_brk_lth = 0
        self.right_brk_pos = -1
        self.right_brk_lth = 0

    def is_left_clip(self):
        if self.left_brk_pos == -1:
            return False
        else:
            return True

    def is_right_clip(self):
        if self.right_brk_pos == -1:
            return False
        else:
            return True

####
##Function: pool.map doesnt' accept function in the class
##So, use this wrapper to solve this
def unwrap_self_cnt_clip(arg, **kwarg):
    return ClipReadInfo.collect_clipped_reads_with_position_by_chrm(*arg, **kwarg)


def unwrap_self_cnt_clip_pos(arg, **kwarg):
    return ClipReadInfo.collect_clip_positions_by_chrm(*arg, **kwarg)


def unwrap_self_collect_clip_parts(arg, **kwarg):
    return ClipReadInfo.collect_clipped_parts_by_chrm(*arg, **kwarg)


def unwrap_self_cnt_clip_parts(arg, **kwarg):
    return ClipReadInfo.run_cnt_clip_part_aligned_to_rep_by_chrm(*arg, **kwarg)

def unwrap_self_cnt_clip_parts_mosaic(arg, **kwarg):
    return ClipReadInfo.run_cnt_clip_part_aligned_to_rep_by_chrm_mosaic(*arg, **kwarg)


def unwrap_self_collect_clip_parts_l(arg, **kwarg):
    return LContigClipReadInfo.collect_clipped_parts_lr_by_chrm(*arg, **kwarg)

####

####This class used for collect clip-read related information from the alignment
class ClipReadInfo():
    def __init__(self, sf_bam, n_jobs, sf_ref):
        self.sf_bam = sf_bam
        self.working_folder = "./"
        self.n_jobs = n_jobs
        self.sf_reference = sf_ref

    def set_working_folder(self, working_folder):
        self.working_folder = working_folder
        if working_folder[-1] != "/":
            self.working_folder += "/"


    ####return two files:
    ####1. the clip_position file
    ####2. the soft-clipped part for re-alignment
    ####Here as part of a preprocessing step, also output all the discordant pairs in a single file (ALL_DISC_SUFFIX)
    def collect_clipped_reads_with_position_by_chrm(self, record):
        chrm = record[0]
        sf_bam = record[1]
        working_folder = record[2]
        sf_annotation = record[3]
        b_with_chr = record[4]

        xannotation = XAnnotation(sf_annotation)
        xannotation.set_with_chr(b_with_chr)
        xannotation.load_rmsk_annotation()
        xannotation.index_rmsk_annotation()

        sf_clip_fq = working_folder + chrm + global_values.CLIP_FQ_SUFFIX  # this is to save the clipped part for re-alignment
        f_clip_fq = open(sf_clip_fq, "w")

        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        m_clip_pos = {}
        sf_all_disc = sf_bam + global_values.ALL_DISC_SUFFIX
        out_disc_bam = pysam.Samfile(sf_all_disc, 'wb', template=samfile)
        xalgnmt = XAlignment()
        m_chrm_id=self._get_chrm_id_name(samfile)
        for algnmt in samfile.fetch(chrm):  ##fetch reads mapped to "chrm"
            ##here need to skip the secondary and supplementary alignments?
            # if algnmt.is_secondary or algnmt.is_supplementary:
            #     continue
            if algnmt.is_duplicate == True:  ##duplciate
                continue
            b_first = True
            if algnmt.is_read2 == True:
                b_first = False
            if algnmt.is_unmapped == True:  # unmapped hai
                continue
            l_cigar = algnmt.cigar
            if len(l_cigar) < 1:  # wrong alignment
                continue
            if len(l_cigar) == 1 and l_cigar[0][0] == 0:  ##fully mapped
                continue

            query_name = algnmt.query_name
            query_seq = algnmt.query_sequence
            query_quality = algnmt.query_qualities  ##this is different from the one saved in the fastq/sam, no offset 33 to subtract
            map_pos = algnmt.reference_start
            mate_chrm = '*'
            mate_pos = 0
            if algnmt.next_reference_id not in m_chrm_id:
                continue
            if algnmt.mate_is_unmapped == False and algnmt.next_reference_id>=0:
                mate_chrm = algnmt.next_reference_name
                mate_pos = algnmt.next_reference_start

            # if xalgnmt.is_discordant_pair_no_unmap(chrm, map_pos, )
            b_mate_in_rep, rep_start_pos = xannotation.is_within_repeat_region(mate_chrm, mate_pos)
            if l_cigar[0][0] == 4 or l_cigar[0][0] == 5:  # left clipped
                if map_pos not in m_clip_pos:
                    m_clip_pos[map_pos] = []
                    m_clip_pos[map_pos].append(1)  ##record # of left clip
                    m_clip_pos[map_pos].append(0)  ##record # of right clip
                    if b_mate_in_rep:
                        m_clip_pos[map_pos].append(1)  ##record # of mate-reads within repeat region
                    else:
                        m_clip_pos[map_pos].append(0)
                else:
                    m_clip_pos[map_pos][0] += 1
                    if b_mate_in_rep:
                        m_clip_pos[map_pos][2] += 1

                if algnmt.is_supplementary or algnmt.is_secondary:  ###secondary and supplementary are not considered
                    continue
                if l_cigar[0][0] == 4:  # soft-clip
                    clipped_seq = query_seq[:l_cigar[0][1]]
                    clipped_qulity = self._cvt_to_Ascii_quality(query_quality[:l_cigar[0][1]])
                    clipped_rname = query_name + global_values.SEPERATOR + mate_chrm + \
                                    global_values.SEPERATOR + str(mate_pos) + global_values.SEPERATOR
                    s_tmp = "{0}{1}{2}{3}{4}{5}2".format(chrm, global_values.SEPERATOR, map_pos, global_values.SEPERATOR,
                                                         global_values.FLAG_LEFT_CLIP,
                                                         global_values.SEPERATOR)
                    clipped_rname += s_tmp
                    if b_first:
                        clipped_rname = query_name + global_values.SEPERATOR + mate_chrm + global_values.SEPERATOR + \
                                        str(mate_pos) + global_values.SEPERATOR
                        s_tmp = "{0}{1}{2}{3}{4}{5}1".format(chrm, global_values.SEPERATOR, map_pos, global_values.SEPERATOR,
                                                             global_values.FLAG_LEFT_CLIP,
                                                             global_values.SEPERATOR)
                        clipped_rname += s_tmp

                    f_clip_fq.write("@" + clipped_rname + "\n")
                    f_clip_fq.write(clipped_seq + "\n+\n")
                    f_clip_fq.write(clipped_qulity + "\n")  ####

            if l_cigar[-1][0] == 4 or l_cigar[-1][0] == 5:  # right clipped
                ##calculate the exact clip position
                for (type, lenth) in l_cigar[:-1]:
                    if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                        continue
                    else:
                        map_pos += lenth

                if map_pos not in m_clip_pos:
                    m_clip_pos[map_pos] = []
                    m_clip_pos[map_pos].append(0)
                    m_clip_pos[map_pos].append(1)
                    if b_mate_in_rep:
                        m_clip_pos[map_pos].append(1)  ##record # of mate-reads within repeat region
                    else:
                        m_clip_pos[map_pos].append(0)
                else:
                    m_clip_pos[map_pos][1] += 1
                    if b_mate_in_rep:
                        m_clip_pos[map_pos][2] += 1

                if algnmt.is_supplementary or algnmt.is_secondary:  ###secondary and supplementary are not considered
                    continue
                if l_cigar[-1][0] == 4:  # soft-clip
                    clipped_rname = query_name + global_values.SEPERATOR + mate_chrm + global_values.SEPERATOR + \
                                    str(mate_pos) + global_values.SEPERATOR
                    s_tmp = "{0}{1}{2}{3}{4}{5}2".format(chrm, global_values.SEPERATOR, map_pos, global_values.SEPERATOR,
                                                         global_values.FLAG_RIGHT_CLIP, global_values.SEPERATOR)
                    clipped_rname += s_tmp
                    start_pos = -1 * l_cigar[-1][1]
                    clipped_seq = query_seq[start_pos:]
                    clipped_qulity = self._cvt_to_Ascii_quality(query_quality[start_pos:])
                    if b_first:
                        clipped_rname = query_name + global_values.SEPERATOR + mate_chrm + global_values.SEPERATOR + \
                                        str(mate_pos) + global_values.SEPERATOR
                        s_tmp = "{0}{1}{2}{3}{4}{5}1".format(chrm, global_values.SEPERATOR, map_pos, global_values.SEPERATOR,
                                                             global_values.FLAG_RIGHT_CLIP, global_values.SEPERATOR)
                        clipped_rname += s_tmp

                    f_clip_fq.write("@" + clipped_rname + "\n")
                    f_clip_fq.write(clipped_seq + "\n+\n")
                    f_clip_fq.write(clipped_qulity + "\n")
        f_clip_fq.close()

        sf_clip_pos = working_folder + chrm + global_values.CLIP_POS_SUFFIX
        with open(sf_clip_pos, "w") as fout_clip_pos:
            for pos in m_clip_pos:
                fout_clip_pos.write(
                    str(pos) + "\t" + str(m_clip_pos[pos][0]) + "\t" + str(m_clip_pos[pos][1]) + "\t" +
                    str(m_clip_pos[pos][2]) + "\n")
        samfile.close()
        out_disc_bam.close()

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

    ####This function return:
    ####1. dictionary of clip position, ##in format {chrm: {map_pos: (left_cnt, right_cnt)}}
    ####2. all the clipped part in fastq format
    def collect_clipped_reads_with_position(self, sf_all_clip_fq, sf_annotation):
        samfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        bam_info = BamInfo(self.sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()

        references = samfile.references
        l_chrm_records = []
        for chrm in references:
            l_chrm_records.append((chrm, self.sf_bam, self.working_folder, sf_annotation, b_with_chr))
        samfile.close()

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_cnt_clip, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

        m_clip_freq = {}  ##in format {chrm: {map_pos: (left_cnt, right_cnt, mate_within_rep_cnt)}}
        for chrm in references:#
            sf_clip_pos = self.working_folder + chrm + global_values.CLIP_POS_SUFFIX
            if os.path.isfile(sf_clip_pos) == False:
                print("Error: Position file for chrom {0} doesn't exist!!!!".format(chrm))
                continue

            m_clip_pos_freq = {}
            with open(sf_clip_pos) as fin_clip_pos:
                for line in fin_clip_pos:
                    fields = line.split()
                    cur_pos = int(fields[0])
                    left_cnt = int(fields[1])
                    right_cnt = int(fields[2])
                    mate_within_rep_cnt = int(fields[3])
                    m_clip_pos_freq[cur_pos] = []
                    m_clip_pos_freq[cur_pos].append(left_cnt)
                    m_clip_pos_freq[cur_pos].append(right_cnt)
                    m_clip_pos_freq[cur_pos].append(mate_within_rep_cnt)
            m_clip_freq[chrm] = m_clip_pos_freq

        ##merge the clipped reads
        with open(sf_all_clip_fq, "w") as fout_all:
            for chrm in references:
                sf_clip_fq = self.working_folder + chrm + global_values.CLIP_FQ_SUFFIX
                with open(sf_clip_fq) as fin_clip:
                    for line in fin_clip:
                        fout_all.write(line)
        return m_clip_freq

    def _get_chrm_id_name(self, samfile):
        m_chrm = {}
        references = samfile.references
        for schrm in references:
            chrm_id = samfile.get_tid(schrm)
            m_chrm[chrm_id] = schrm
        m_chrm[-1] = "*"
        return m_chrm

    ####return two files:
    ####1. the clip_position
    def collect_clip_positions_by_chrm(self, record):
        chrm = record[0]
        sf_bam = record[1]
        working_folder = record[2]
        sf_annotation = record[3]
        b_with_chr = record[4]
        i_clip_cutoff = int(record[5])
        b_se = record[6] #whether this is single end reads
####
        xannotation = XAnnotation(sf_annotation)
        xannotation.set_with_chr(b_with_chr)
        #xannotation.load_rmsk_annotation()
        i_min_copy_len=0
        i_boundary_extnd=0
        if global_values.IS_CALL_SVA==True:
            i_boundary_extnd=global_values.SVA_ANNOTATION_EXTND
        xannotation.load_rmsk_annotation_with_extnd_with_lenth_cutoff(i_boundary_extnd, i_min_copy_len)
        xannotation.index_rmsk_annotation_interval_tree()

        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        m_clip_pos = {}
        m_chrm_id_name = self._get_chrm_id_name(samfile)
        for algnmt in samfile.fetch(chrm):  ##fetch reads mapped to "chrm"
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
            if len(l_cigar) == 1 and l_cigar[0][0] == 0:  ##fully mapped
                continue
            if algnmt.mapping_quality < global_values.MINIMUM_CLIP_MAPQ:#by default this is set to 10
                continue
####
            if algnmt.next_reference_id not in m_chrm_id_name:
                continue
            map_pos = algnmt.reference_start
            mate_chrm = '*'
            mate_pos = 0

            if algnmt.mate_is_unmapped == False and algnmt.next_reference_id>=0:
                mate_chrm = algnmt.next_reference_name
                mate_pos = algnmt.next_reference_start
            # print mate_chrm, mate_pos ################################################################################
            b_mate_in_rep = False
            rep_start_pos = 0
            #b_mate_in_rep, rep_start_pos = xannotation.is_within_repeat_region(mate_chrm, mate_pos)
            if b_se == False:
                b_mate_in_rep, rep_start_pos = xannotation.is_within_repeat_region_interval_tree(mate_chrm, mate_pos)

            # print b_mate_in_rep, rep_start_pos #######################################################################
            if l_cigar[0][0] == 4 or l_cigar[0][0] == 5:  # left clipped
                if map_pos not in m_clip_pos:
                    m_clip_pos[map_pos] = []
                    m_clip_pos[map_pos].append(1)  ##record # of left clip
                    m_clip_pos[map_pos].append(0)  ##record # of right clip
                    if b_mate_in_rep:
                        m_clip_pos[map_pos].append(1)  ##record # of mate-reads within repeat region
                    else:
                        m_clip_pos[map_pos].append(0)
                else:
                    m_clip_pos[map_pos][0] += 1
                    if b_mate_in_rep:
                        m_clip_pos[map_pos][2] += 1

                if algnmt.is_supplementary or algnmt.is_secondary:  ###secondary and supplementary are not considered
                    continue

            if l_cigar[-1][0] == 4 or l_cigar[-1][0] == 5:  # right clipped
                ##calculate the exact clip position
                for (type, lenth) in l_cigar[:-1]:
                    if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                        continue
                    else:
                        map_pos += lenth

                if map_pos not in m_clip_pos:
                    m_clip_pos[map_pos] = []
                    m_clip_pos[map_pos].append(0)
                    m_clip_pos[map_pos].append(1)
                    if b_mate_in_rep:
                        m_clip_pos[map_pos].append(1)  ##record # of mate-reads within repeat region
                    else:
                        m_clip_pos[map_pos].append(0)
                else:
                    m_clip_pos[map_pos][1] += 1
                    if b_mate_in_rep:
                        m_clip_pos[map_pos][2] += 1

        sf_clip_pos = working_folder + chrm + global_values.CLIP_POS_SUFFIX
        with open(sf_clip_pos, "w") as fout_clip_pos:
            for pos in m_clip_pos:
                i_all_clip = m_clip_pos[pos][0] + m_clip_pos[pos][1]
                if i_all_clip >= i_clip_cutoff:  ####set a cutoff for the total number of clipped ones
                    fout_clip_pos.write(
                        str(pos) + "\t" + str(m_clip_pos[pos][0]) + "\t" + str(m_clip_pos[pos][1]) + "\t" +
                        str(m_clip_pos[pos][2]) + "\n")
        samfile.close()


    ####This function return:
    ########1. dictionary of clip position, ##in format {chrm: {map_pos: (left_cnt, right_cnt)}}
    def collect_clip_positions(self, sf_annotation, i_clip_cutoff, b_se, sf_pub_folder):
        bam_info = BamInfo(self.sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        samfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        references = samfile.references
        xchrom=XChromosome()
        l_chrm_records = []
        for chrm in references:
            if xchrom.is_decoy_contig_chrms(chrm) == True:  ###decoy sequnces and contigs are not considered
                continue
            l_chrm_records.append((chrm, self.sf_bam, self.working_folder, sf_annotation, b_with_chr, i_clip_cutoff,
                                   b_se))
        samfile.close()

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_cnt_clip_pos, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

        #soft_link clip pos
        for rcd in l_chrm_records:
            sf_clip_pos = self.working_folder + rcd[0] + global_values.CLIP_POS_SUFFIX
            sf_pub_pos=sf_pub_folder + rcd[0] + global_values.CLIP_POS_SUFFIX
            if os.path.islink(sf_pub_pos)==True or os.path.isfile(sf_pub_pos)==True:
                os.remove(sf_pub_pos)
            cmd="ln -s {0} {1}".format(sf_clip_pos, sf_pub_folder)
            Popen(cmd, shell=True, stdout=PIPE).communicate()

    ####given specific chrm, get all the related clipped reads
    #Here besides the long clipped parts, we keep the very short clipped parts that have dominant A or T
    def collect_clipped_parts_by_chrm(self, record):
        chrm = record[0]
        sf_bam = record[1]
        working_folder = record[2]

        # first load in the positions by chromosome
        sf_clip_pos = working_folder + chrm + global_values.CLIP_POS_SUFFIX
        m_pos = {}
        if os.path.exists(sf_clip_pos) == False:
            return
        with open(sf_clip_pos) as fin_clip_pos:
            for line in fin_clip_pos:
                fields = line.split()
                pos = int(fields[0])
                m_pos[pos] = 1
        # second, load the reads, and write the related clipped part into file
        sf_clip_fq = working_folder + chrm + global_values.CLIP_FQ_SUFFIX  # this is to save the clipped part for re-alignment
        f_clip_fq = open(sf_clip_fq, "w")
        xpolyA=PolyA()
        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference) #
        m_chrm_id=self._get_chrm_id_name(samfile)
        for algnmt in samfile.fetch(chrm):  ##fetch reads mapped to "chrm"
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
            if len(l_cigar) == 1 and l_cigar[0][0] == 0:  ##fully mapped
                continue

            query_name = algnmt.query_name
            query_seq = algnmt.query_sequence
            query_quality = algnmt.query_qualities  ##this is different from the one saved in the fastq/sam, no offset 33 to subtract
            map_pos = algnmt.reference_start
            mate_chrm = '*'
            mate_pos = 0
            if algnmt.next_reference_id not in m_chrm_id:
                continue
            if algnmt.mate_is_unmapped == False and algnmt.next_reference_id>=0:
                mate_chrm = algnmt.next_reference_name
                mate_pos = algnmt.next_reference_start

            if l_cigar[0][0] == 4:  # left clipped
                if algnmt.is_supplementary or algnmt.is_secondary:  ###secondary and supplementary are not considered
                    continue

                if map_pos in m_pos:
                    clipped_seq = query_seq[:l_cigar[0][1]]
                    len_clip_seq=len(clipped_seq)
                    if len_clip_seq>=global_values.MINIMUM_POLYA_CLIP and len_clip_seq<=global_values.BWA_REALIGN_CUTOFF:
                        #check whether this the polyA side
                        #Here have more strict require ment
                        if xpolyA.contain_enough_A_T(clipped_seq, len_clip_seq)==False:
                            continue
                    elif len_clip_seq < global_values.BWA_REALIGN_CUTOFF:
                        continue

                    #require the medium quality score should higher than threshold
                    l_quality_score=query_quality[:l_cigar[0][1]]
                    if self._is_qualified_clip(l_quality_score)==False:
                        continue
                    clipped_qulity = self._cvt_to_Ascii_quality(query_quality[:l_cigar[0][1]])
                    clipped_rname = query_name + global_values.SEPERATOR + mate_chrm + global_values.SEPERATOR + \
                                    str(mate_pos) + global_values.SEPERATOR
                    s_tmp = "{0}{1}{2}{3}{4}{5}2".format(chrm, global_values.SEPERATOR, map_pos, global_values.SEPERATOR,
                                                         global_values.FLAG_LEFT_CLIP, global_values.SEPERATOR)
                    clipped_rname += s_tmp
                    if b_first:
                        clipped_rname = query_name + global_values.SEPERATOR + mate_chrm + global_values.SEPERATOR + \
                                        str(mate_pos) + global_values.SEPERATOR
                        s_tmp = "{0}{1}{2}{3}{4}{5}1".format(chrm, global_values.SEPERATOR, map_pos, global_values.SEPERATOR,
                                                             global_values.FLAG_LEFT_CLIP, global_values.SEPERATOR)
                        clipped_rname += s_tmp

                    f_clip_fq.write("@" + clipped_rname + "\n")
                    f_clip_fq.write(clipped_seq + "\n+\n")
                    f_clip_fq.write(clipped_qulity + "\n")

            if l_cigar[-1][0] == 4:  #right clipped
                ##calculate the exact clip position
                for (type, lenth) in l_cigar[:-1]:
                    if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                        continue
                    else:
                        map_pos += lenth

                if algnmt.is_supplementary or algnmt.is_secondary:  ###secondary and supplementary are not considered
                    continue
                if map_pos in m_pos:  # soft-clip
                    clipped_rname = query_name + global_values.SEPERATOR + mate_chrm + global_values.SEPERATOR + \
                                    str(mate_pos) + global_values.SEPERATOR
                    s_tmp = "{0}{1}{2}{3}{4}{5}2".format(chrm, global_values.SEPERATOR, map_pos, global_values.SEPERATOR,
                                                         global_values.FLAG_RIGHT_CLIP, global_values.SEPERATOR)
                    clipped_rname += s_tmp
                    start_pos = -1 * l_cigar[-1][1]
                    clipped_seq = query_seq[start_pos:]
                    len_clip_seq = len(clipped_seq)
                    if len_clip_seq >= global_values.MINIMUM_POLYA_CLIP and len_clip_seq <= global_values.BWA_REALIGN_CUTOFF:
                        if xpolyA.contain_enough_A_T(clipped_seq, len_clip_seq)==False:
                            continue
                    elif len_clip_seq < global_values.BWA_REALIGN_CUTOFF:
                        continue

                    l_quality_score = query_quality[start_pos:]
                    if self._is_qualified_clip(l_quality_score) == False:
                        continue

                    clipped_qulity = self._cvt_to_Ascii_quality(query_quality[start_pos:])
                    if b_first:
                        clipped_rname = query_name + global_values.SEPERATOR + mate_chrm + global_values.SEPERATOR + \
                                        str(mate_pos) + global_values.SEPERATOR
                        s_tmp = "{0}{1}{2}{3}{4}{5}1".format(chrm, global_values.SEPERATOR, map_pos, global_values.SEPERATOR,
                                                             global_values.FLAG_RIGHT_CLIP, global_values.SEPERATOR)
                        clipped_rname += s_tmp

                    f_clip_fq.write("@" + clipped_rname + "\n")
                    f_clip_fq.write(clipped_seq + "\n+\n")
                    f_clip_fq.write(clipped_qulity + "\n")
        samfile.close()
        f_clip_fq.close()

    ####This function:
    ####1. given dictionary of clip position, ##in format {chrm: {map_pos: (left_cnt, right_cnt)}}
    ####2. write the clipped part into files
    def collect_clipped_parts(self, sf_all_clip_fq):
        samfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        references = samfile.references
        l_chrm_records = []
        xchrom = XChromosome()
        for chrm in references:
            if xchrom.is_decoy_contig_chrms(chrm) == True:  ###Here filter out those aligned to decoy sequences
                print("Skip chromosome {0}".format(chrm))  ##
                continue
            l_chrm_records.append((chrm, self.sf_bam, self.working_folder))
        samfile.close()

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_collect_clip_parts, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

        ##merge the clipped reads
        with open(sf_all_clip_fq, "w") as fout_all:
            for chrm in references:
                sf_clip_fq = self.working_folder + chrm + global_values.CLIP_FQ_SUFFIX
                if os.path.isfile(sf_clip_fq) == False:
                    continue
                with open(sf_clip_fq) as fin_clip:
                    for line in fin_clip:
                        fout_all.write(line)
                os.remove(sf_clip_fq)#clean the temporary file
####

    def decrease_clip_freq(self, chrm, mpos, sflag, m_clip_freq):
        if sflag == global_values.FLAG_LEFT_CLIP:
            m_clip_freq[chrm][mpos][0] -= 1
        else:
            m_clip_freq[chrm][mpos][1] -= 1

    ##note, the clip_pos and chrm is saved in the read name
    def correct_num_of_clip_by_realignment(self, sf_ref, sf_annotation, sf_all_clip_fq, m_clip_freq):
        bam_info = BamInfo(self.sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()

        xannotation = XAnnotation(sf_annotation)
        xannotation.set_with_chr(b_with_chr)
        xannotation.load_rmsk_annotation()
        xannotation.index_rmsk_annotation()

        sf_clip_bam = self.working_folder + "all" + global_values.CLIP_BAM_SUFFIX
        bwa_algn=BWAlign(global_values.BWA_PATH, global_values.BWA_REALIGN_CUTOFF, self.n_jobs)
        bwa_algn.realign_clipped_reads(sf_ref, sf_all_clip_fq, sf_clip_bam)

        with open(sf_clip_bam) as fin_sam:
            for line in fin_sam:
                fields = line.split()
                if line[0] == "@":
                    continue

                qname = fields[0]
                flag = int(fields[1])
                if flag & 256 != 0:  # secondary alignment
                    continue
                if flag & 2048 != 0:  # supplementary alignment
                    continue

                b_fake = False
                if flag & 4 != 0:  # unmapped read
                    b_fake = True
                chrm = fields[2]
                pos = int(fields[3])

                b_within_rep, rep_start = xannotation.is_within_repeat_region(chrm, pos)
                if b_within_rep == False:
                    b_fake = True
                if b_fake == True:
                    qname_fields = qname.split(global_values.SEPERATOR)
                    # chrm, map_pos, global_values.FLAG_LEFT_CLIP, first_read
                    ori_chrm = qname_fields[-4]
                    ori_mpos = int(qname_fields[-3])
                    sflag = qname_fields[-2]
                    self.decrease_clip_freq(ori_chrm, ori_mpos, sflag, m_clip_freq)
        return m_clip_freq

    ###this version, first get all the list for each chrom, then sort, and then count the number
    ###This version will consume less memory
    ####This version hasn't been tested!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    def run_cnt_clip_part_aligned_to_rep_by_chrm_sort_version(self, record):
        ref_chrm = record[0]
        sf_sam = record[1]
        working_folder = record[2]

        ####clip positions for specific chrm
        sf_clip_pos = working_folder + ref_chrm + global_values.CLIP_POS_SUFFIX
        if os.path.isfile(sf_clip_pos) == False:
            print("Error: Position file for chrom {0} doesn't exist!!!!".format(ref_chrm))
            return
        ###clip positions for specific chrm with extra #left_clip #right_clip (mapped parts)
        sf_out_clip_pos = working_folder + ref_chrm + global_values.CLIP_RE_ALIGN_POS_SUFFIX
        sf_re_align_ori_clip_pos_list = sf_out_clip_pos + ".only_realign_clip.tmp"
        with open(sf_re_align_ori_clip_pos_list, "w") as fout_ori_clip_pos:
            samfile = pysam.AlignmentFile(sf_sam, "r")
            for algnmt in samfile.fetch():  ##fetch reads mapped to "chrm"
                ##here need to skip the secondary and supplementary alignments?
                if algnmt.is_secondary or algnmt.is_supplementary:
                    continue
                if algnmt.is_duplicate == True:  ##duplciate
                    continue

                if algnmt.is_unmapped == True:  # unmapped
                    continue

                qname = algnmt.query_name
                qname_fields = qname.split(global_values.SEPERATOR)
                # chrm, map_pos, global_values.FLAG_LEFT_CLIP, first_read
                ori_chrm = qname_fields[-4]  #############check reverse-complementary consistent here ??????????????
                ori_mpos = int(qname_fields[-3])

                if ori_chrm != ref_chrm:  ###not the inerested chromosome
                    continue

                l_cigar = algnmt.cigar
                if len(l_cigar) < 1:  # wrong alignment
                    continue
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
                            continue

                ####for the alignment (of the clipped read), if the mapped part is smaller than the clipped part,
                ####then skip
                n_total = 0
                n_map = 0
                for (type, lenth) in l_cigar:
                    if type == 0:
                        n_map += lenth
                    if type != 2:  # deletion is not added to the total length
                        n_total += lenth
                # if n_map < (n_total / 2):  ########################require at least half of the seq is mapped !!!!!!!!!
                #     continue

                if n_map < (
                        n_total * 3 / 4):  ########################require at least half of the seq is mapped !!!!!!!!!
                    continue

                ####write out the original clip positions
                s_clip_info = "{0}\t{1}\n".format(ori_mpos, qname_fields[-2])
                fout_ori_clip_pos.write(s_clip_info)

        ###sort the file s_clip_info
        sf_re_align_ori_clip_pos_list_sorted = sf_re_align_ori_clip_pos_list + ".sorted.txt"
        cmd_sort = "sort {0} -o {1}".format(sf_re_align_ori_clip_pos_list, sf_re_align_ori_clip_pos_list_sorted)
        Popen(cmd_sort, shell=True, stdout=PIPE).communicate()

        # parse the sorted file list.
        with open(sf_re_align_ori_clip_pos_list_sorted) as fin_ori_sorted, open(sf_out_clip_pos, "w") as fout_clip_pos:
            b_first = True
            s_last = ""
            cnt_left_tmp = 0
            cnt_right_tmp = 0
            for line in fin_ori_sorted:
                fields = line.split()
                sinfo = fields[0]
                if sinfo != s_last and b_first != True:  ####different
                    fout_clip_pos.write(s_last + "\t" + str(cnt_left_tmp) + "\t" + str(cnt_right_tmp) + "\n")
                    cnt_left_tmp = 0
                    cnt_right_tmp = 0

                if b_first == True:
                    b_first = False
                if fields[1] == global_values.FLAG_LEFT_CLIP:
                    cnt_left_tmp += 1
                elif fields[1] == global_values.FLAG_RIGHT_CLIP:
                    cnt_right_tmp += 1
                s_last = sinfo
            # write in the last one
            fout_clip_pos.write(s_last + "\t" + str(cnt_left_tmp) + "\t" + str(cnt_right_tmp) + "\n")

    ####
    def run_cnt_clip_part_aligned_to_rep_by_chrm(self, record):
        ref_chrm = record[0]
        sf_sam = record[1]
        working_folder = record[2]

        ####clip positions for specific chrm
        # sf_clip_pos = working_folder + ref_chrm + global_values.CLIP_POS_SUFFIX
        # if os.path.isfile(sf_clip_pos) == False:
        #     print "Error: Position file for chrom {0} doesn't exist!!!!".format(ref_chrm)
        #     return
        ###clip positions for specific chrm with extra #left_clip #right_clip (mapped parts)
        sf_out_clip_pos = working_folder + ref_chrm + global_values.CLIP_RE_ALIGN_POS_SUFFIX

        m_sites_chrm = {}
        samfile = pysam.AlignmentFile(sf_sam, "r")
        for algnmt in samfile.fetch():  ##fetch reads mapped to "chrm"
            ##here need to skip the secondary and supplementary alignments?
            if algnmt.is_secondary or algnmt.is_supplementary:
                continue
            # if algnmt.is_duplicate == True:  ##duplciate
            #     continue
            if algnmt.is_unmapped == True:
                continue

            qname = algnmt.query_name
            qname_fields = qname.split(global_values.SEPERATOR)
            # chrm, map_pos, global_values.FLAG_LEFT_CLIP, first_read
            ori_chrm = qname_fields[-4]  #############check reverse-complementary consistent here ??????????????
            ori_mpos = int(qname_fields[-3])

            if ori_chrm != ref_chrm:  ###not the inerested chromosome
                continue

            l_cigar = algnmt.cigar
            if len(l_cigar) < 1:  # wrong alignment
                continue
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
                        continue

            ####for the alignment (of the clipped read), if the mapped part is smaller than the clipped part,
            ####then skip
            n_total = 0
            n_map = 0
            for (type, lenth) in l_cigar:
                if type == 0:
                    n_map += lenth
                if type != 2:  # deletion is not added to the total length data
                    n_total += lenth
            # if n_map < (n_total / 2):  ########################require at least half of the seq is mapped !!!!!!!!!!!!!
            #     continue
            if n_map < (n_total * 3 / 4):  ########################require at least 3/4 of the seq is mapped !!!!!!!!!!!
                continue

            b_left = True
            if qname_fields[-2] == global_values.FLAG_RIGHT_CLIP:
                b_left = False

            if (ori_mpos in m_sites_chrm) == False:
                m_sites_chrm[ori_mpos] = []
                if b_left == True:
                    m_sites_chrm[ori_mpos].append(1)
                    m_sites_chrm[ori_mpos].append(0)
                else:
                    m_sites_chrm[ori_mpos].append(0)
                    m_sites_chrm[ori_mpos].append(1)
            else:
                if b_left == True:
                    m_sites_chrm[ori_mpos][-2] += 1
                else:
                    m_sites_chrm[ori_mpos][-1] += 1

        with open(sf_out_clip_pos, "w") as fout_clip_pos:
            for pos in m_sites_chrm:
                lth = len(m_sites_chrm[pos])
                fout_clip_pos.write(str(pos) + "\t")
                for i in range(lth):
                    fout_clip_pos.write(str(m_sites_chrm[pos][i]) + "\t")
                fout_clip_pos.write("\n")

    ####Input:1. the re-aligned clipped parts
    def cnt_clip_part_aligned_to_rep(self, sf_clip_sam):
        samfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        references = samfile.references
        l_chrm_records = []
        #here filter out those uninterested contigs
        xchrom=XChromosome()
        for chrm in references:
            if xchrom.is_decoy_contig_chrms(chrm) == True:  ###filter out decoy and other contigs
                continue
            l_chrm_records.append((chrm, sf_clip_sam, self.working_folder))
        samfile.close()

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_cnt_clip_parts, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

    ####
    def run_cnt_clip_part_aligned_to_rep_by_chrm_mosaic(self, record):
        ref_chrm = record[0]
        sf_sam = record[1]
        working_folder = record[2]

        ####clip positions for specific chrm
        # sf_clip_pos = working_folder + ref_chrm + global_values.CLIP_POS_SUFFIX
        # if os.path.isfile(sf_clip_pos) == False:
        #     print "Error: Position file for chrom {0} doesn't exist!!!!".format(ref_chrm)
        #     return
        ###clip positions for specific chrm with extra #left_clip #right_clip (mapped parts)
        sf_out_clip_pos = working_folder + ref_chrm + global_values.CLIP_RE_ALIGN_POS_SUFFIX

        m_sites_chrm = {}
        xpolyA = PolyA()
        m_polyA={}#
        samfile = pysam.AlignmentFile(sf_sam, "r")
        for algnmt in samfile.fetch():  ##fetch reads mapped to "chrm"
            ##here need to skip the secondary and supplementary alignments?
            if algnmt.is_secondary or algnmt.is_supplementary:
                continue
            # if algnmt.is_duplicate == True:  ##duplciate
            #     continue
            if algnmt.is_unmapped == True:
                continue

            qname = algnmt.query_name
            qname_fields = qname.split(global_values.SEPERATOR)
            # chrm, map_pos, global_values.FLAG_LEFT_CLIP, first_read
            ori_chrm = qname_fields[-4]  #############check reverse-complementary consistent here ??????????????
            ori_mpos = int(qname_fields[-3])

            if ori_chrm != ref_chrm:  ###not the inerested chromosome
                continue

            l_cigar = algnmt.cigar
            if len(l_cigar) < 1:  # wrong alignment
                continue
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
                        continue

            ####for the alignment (of the clipped read), if the mapped part is smaller than the clipped part,
            ####then skip
            n_total = 0
            n_map = 0
            for (type, lenth) in l_cigar:
                if type == 0:
                    n_map += lenth
                if type != 2:  # deletion is not added to the total length data
                    n_total += lenth
            # if n_map < (n_total / 2):  ########################require at least half of the seq is mapped !!!!!!!!!!!!!
            #     continue
            if n_map < (n_total * 3 / 4):  ########################require at least 3/4 of the seq is mapped !!!!!!!!!!!
                continue

            b_left = True
            if qname_fields[-2] == global_values.FLAG_RIGHT_CLIP:
                b_left = False

            ################################################
            b_clip_rc=algnmt.is_reverse
            clipped_seq = algnmt.query_sequence
            s_clip_seq_ck = ""
            if b_clip_rc==False:
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
            else:
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
            b_polya = xpolyA.is_consecutive_polyA_T(s_clip_seq_ck)
            if ori_mpos not in m_polyA:
                m_polyA[ori_mpos]=[]
                m_polyA[ori_mpos].append(0)
                m_polyA[ori_mpos].append(0)
            if b_polya==True:
                if b_left == True:
                    m_polyA[ori_mpos][0] += 1
                else:
                    m_polyA[ori_mpos][1] += 1
            ######################################################

            if (ori_mpos in m_sites_chrm) == False:
                m_sites_chrm[ori_mpos] = []
                if b_left == True:
                    m_sites_chrm[ori_mpos].append(1)
                    m_sites_chrm[ori_mpos].append(0)
                else:
                    m_sites_chrm[ori_mpos].append(0)
                    m_sites_chrm[ori_mpos].append(1)
            else:
                if b_left == True:
                    m_sites_chrm[ori_mpos][-2] += 1
                else:
                    m_sites_chrm[ori_mpos][-1] += 1

        with open(sf_out_clip_pos, "w") as fout_clip_pos:#
            for pos in m_sites_chrm:
                lth = len(m_sites_chrm[pos])
                fout_clip_pos.write(str(pos) + "\t")
                for i in range(lth):
                    fout_clip_pos.write(str(m_sites_chrm[pos][i]) + "\t")
                fout_clip_pos.write(str(m_polyA[pos][0])+"\t"+str(m_polyA[pos][1])+"\n") #add the polyA reads count
####
####
    ####Input:1. the re-aligned clipped parts
    ####2. Also check the polyA reads.
    def cnt_clip_part_aligned_to_rep_mosaic(self, sf_clip_sam):
        samfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        references = samfile.references
        l_chrm_records = []
        #here filter out those uninterested contigs
        xchrom=XChromosome()
        for chrm in references:
            if xchrom.is_decoy_contig_chrms(chrm) == True:  ###filter out decoy and other contigs
                continue
            l_chrm_records.append((chrm, sf_clip_sam, self.working_folder))
        samfile.close()

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_cnt_clip_parts_mosaic, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

    ####
    def merge_clip_positions(self, sf_pclip, sf_out):
        samfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        references = samfile.references

        with open(sf_out, "w") as fout_clip_pos:
            for chrm in references:
                ##first, load in the whole file into dict
                m_realign_pos = {}
                sf_chrm_re_align_clip_pos = self.working_folder + chrm + global_values.CLIP_RE_ALIGN_POS_SUFFIX
                if os.path.isfile(sf_chrm_re_align_clip_pos) == True:
                    with open(sf_chrm_re_align_clip_pos) as fin_realign_clip_chrm:
                        for line in fin_realign_clip_chrm:
                            fields = line.split()
                            m_realign_pos[int(fields[0])] = "\t".join(fields[1:])

                sf_clip_pos = sf_pclip + chrm + global_values.CLIP_POS_SUFFIX
                if os.path.isfile(sf_clip_pos) == False:
                    continue
                with open(sf_clip_pos) as fin_clip_pos:
                    for line in fin_clip_pos:
                        fields = line.split()
                        pos = int(fields[0])
                        if pos in m_realign_pos:
                            fout_clip_pos.write(chrm + "\t")
                            fout_clip_pos.write(line.rstrip() + "\t")
                            fout_clip_pos.write(m_realign_pos[pos] + "\n")
                        else:
                            fout_clip_pos.write(chrm + "\t")
                            fout_clip_pos.write(line.rstrip() + "\t")
                            fout_clip_pos.write("0\t0\n")
                #os.remove(sf_clip_pos)
        samfile.close()
####
    ####
    def merge_clip_positions_with_cutoff(self, cutoff_left_clip, cutoff_right_clip, max_cov_cutoff, sf_pclip, sf_out):
        samfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        references = samfile.references

        with open(sf_out, "w") as fout_clip_pos:
            for chrm in references:
                ##first, load in the whole file into dict
                m_realign_pos = {}
                sf_chrm_re_align_clip_pos = self.working_folder + chrm + global_values.CLIP_RE_ALIGN_POS_SUFFIX
                if os.path.isfile(sf_chrm_re_align_clip_pos) == True:
                    with open(sf_chrm_re_align_clip_pos) as fin_realign_clip_chrm:
                        for line in fin_realign_clip_chrm:
                            fields = line.split()
                            m_realign_pos[int(fields[0])] = "\t".join(fields[1:])

                sf_clip_pos = sf_pclip + chrm + global_values.CLIP_POS_SUFFIX
                if os.path.isfile(sf_clip_pos) == False:
                    continue
                with open(sf_clip_pos) as fin_clip_pos:
                    for line in fin_clip_pos:
                        fields = line.split()
                        pos = int(fields[0])
                        i_left_clip = int(fields[1])
                        i_right_clip = int(fields[2])
                        if i_left_clip < cutoff_left_clip and i_right_clip < cutoff_right_clip:
                            continue
                        if (i_left_clip+i_right_clip) > max_cov_cutoff:
                            continue
                        if pos in m_realign_pos:
                            fout_clip_pos.write(chrm + "\t")
                            fout_clip_pos.write(line.rstrip() + "\t")
                            fout_clip_pos.write(m_realign_pos[pos] + "\n")
                        else:
                            fout_clip_pos.write(chrm + "\t")
                            fout_clip_pos.write(line.rstrip() + "\t")
                            fout_clip_pos.write("0\t0\n")
                #os.remove(sf_clip_pos)
        samfile.close()

    ####
    def merge_clip_positions_with_cutoff_polyA(
            self, cutoff_left_clip, cutoff_right_clip, max_cov_cutoff, sf_pclip, sf_out):
        samfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        references = samfile.references

        with open(sf_out, "w") as fout_clip_pos:
            for chrm in references:
                ##first, load in the whole file into dict
                m_realign_pos = {}
                sf_chrm_re_align_clip_pos = self.working_folder + chrm + global_values.CLIP_RE_ALIGN_POS_SUFFIX
                if os.path.isfile(sf_chrm_re_align_clip_pos) == True:
                    with open(sf_chrm_re_align_clip_pos) as fin_realign_clip_chrm:
                        for line in fin_realign_clip_chrm:
                            fields = line.split()
                            m_realign_pos[int(fields[0])] = "\t".join(fields[1:])

                sf_clip_pos = sf_pclip + chrm + global_values.CLIP_POS_SUFFIX
                if os.path.isfile(sf_clip_pos) == False:
                    continue
                with open(sf_clip_pos) as fin_clip_pos:
                    for line in fin_clip_pos:
                        fields = line.split()
                        pos = int(fields[0])
                        i_left_clip = int(fields[1])
                        i_right_clip = int(fields[2])
                        if i_left_clip < cutoff_left_clip and i_right_clip < cutoff_right_clip:
                            continue
                        if (i_left_clip+i_right_clip) > max_cov_cutoff:
                            continue
                        if pos in m_realign_pos:
                            fout_clip_pos.write(chrm + "\t")
                            fout_clip_pos.write(line.rstrip() + "\t")
                            fout_clip_pos.write(m_realign_pos[pos] + "\n")
                        else:
                            fout_clip_pos.write(chrm + "\t")
                            fout_clip_pos.write(line.rstrip() + "\t")
                            fout_clip_pos.write("0\t0\t0\t0\n")
                #os.remove(sf_clip_pos)
        samfile.close()


####This is for long read or long contig
class LContigClipReadInfo():
    def __init__(self, sf_bam, n_jobs, sf_ref, s_working_folder):
        self.sf_bam = sf_bam
        self.working_folder = s_working_folder
        self.n_jobs = n_jobs
        self.sf_reference = sf_ref

    # collect the clipped parts for contigs or long reads of given chromosome
    def collect_clipped_parts_lr_by_chrm(self, record):
        chrm = record[0]  #this is the chrm in the bam file
        sf_bam = record[1]
        sf_sites = record[2]
        islack=record[3]
        working_folder = record[4]

        m_sites = {}
        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        with open(sf_sites) as fin_sites:  # first load in all the sites
            for line in fin_sites:
                fields = line.split()
                site_chrm1 = fields[0]
                site_pos = int(fields[1])
                site_chrm = bam_info.process_chrm_name(site_chrm1, b_with_chr)
                if site_chrm == chrm:
                    m_sites[site_pos]=1

        bamfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        sf_out = working_folder + chrm + global_values.LCLIP_FA_SUFFIX
        with open(sf_out, "w") as fout_clip:
            for algnmt in bamfile.fetch(chrm):
                if algnmt.is_unmapped == True:  # unmapped
                    continue
                l_cigar = algnmt.cigar
                if len(l_cigar) < 1:  # wrong alignment
                    continue
                if len(l_cigar) == 1 and l_cigar[0][0] == 0:  ##fully mapped
                    continue
                if algnmt.is_supplementary or algnmt.is_secondary:###secondary and supplementary are not considered
                    continue
                query_name = algnmt.query_name
                query_seq = algnmt.query_sequence
                map_pos = algnmt.reference_start
                l_clip_pos=-1
                l_clip_lenth=0
                r_clip_pos=-1
                r_clip_lenth=0
                if l_cigar[0][0] == 4:  # left clipped
                    l_clip_pos=map_pos
                    ###check whether within the range of called clip position
                    hit_site=-1
                    for i in range(-1*islack, islack):
                        tmp_pos=l_clip_pos+i
                        if tmp_pos in m_sites:
                            hit_site=tmp_pos
                            break
                    if hit_site<0:
                        continue

                    l_clip_lenth=l_cigar[0][1]
                    clip_seq=query_seq[:l_clip_lenth]
                    shead=chrm+global_values.SEPERATOR+str(hit_site)+global_values.SEPERATOR+query_name+"L"
                    fout_clip.write(">"+shead+"\n")
                    fout_clip.write(clip_seq+"\n")
                if l_cigar[-1][0] == 4:  # right clipped
                    ##calculate the exact clip position
                    for (type, lenth) in l_cigar[:-1]:
                        if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                            continue
                        else:
                            map_pos += lenth
                    r_clip_pos=map_pos
                    hit_site = -1
                    for i in range(-1 * islack, islack):
                        tmp_pos = r_clip_pos + i
                        if tmp_pos in m_sites:
                            hit_site = tmp_pos
                            break
                    if hit_site < 0:
                        continue

                    r_clip_lenth = l_cigar[-1][1]
                    clip_seq = query_seq[-1 * r_clip_lenth:]
                    shead = chrm + global_values.SEPERATOR + str(hit_site) + global_values.SEPERATOR + query_name + "R"
                    fout_clip.write(">" + shead + "\n")
                    fout_clip.write(clip_seq + "\n")
        bamfile.close()
####
####
    # collect the clipped parts for contigs or long reads of given site
    def collect_clipped_parts_lr_by_region(self, record):
        sf_bam = record[0]
        chrm = record[1]# this is the chrm in the bam file
        ins_pos=record[2]
        iextend=record[3]#will extract reads in region chrm:(ins_pos+/- iextend)
        islack = record[4] #slack around the breakpoint
        working_folder = record[5]

        left_boundary=ins_pos-iextend
        if left_boundary<0:
            left_boundary=0
        right_boundary=ins_pos+iextend

        bamfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        s_site="{0}_{1}".format(chrm, ins_pos)
        sf_out = working_folder + s_site + global_values.LCLIP_FA_SUFFIX
        with open(sf_out, "w") as fout_clip:
            for algnmt in bamfile.fetch(chrm, left_boundary, right_boundary):#
                l_cigar = algnmt.cigar
                map_pos = algnmt.reference_start  # the mapping position
                query_seq = algnmt.query_sequence
                query_name=algnmt.query_name
                if query_seq == None: ###why this happen??????
                    continue
                seq_lenth = len(query_seq)
                lclip_len = 0
                if l_cigar[0][0] == 4:# left-clip
                    brkpnt = ins_pos - islack
                    lclip_len = l_cigar[0][1]
                    clip_pos = map_pos
                    if lclip_len > 100:
                        if brkpnt < clip_pos and brkpnt > (clip_pos - lclip_len):
                            #print "left-clip", algnmt.query_name
                            clip_seq = query_seq[:lclip_len]
                            shead = chrm + global_values.SEPERATOR + str(ins_pos) + global_values.SEPERATOR + query_name + "L"
                            fout_clip.write(">" + shead + "\n")
                            fout_clip.write(clip_seq + "\n")

                if l_cigar[-1][0] == 4:# right clipped
                    brkpnt = ins_pos + islack
                    rclip_len = l_cigar[-1][1]
                    if rclip_len < 100:
                        continue
                    clip_pos = map_pos + seq_lenth - lclip_len - rclip_len
                    if brkpnt > clip_pos and brkpnt < (clip_pos + rclip_len):
                        #print "right-clip", algnmt.query_name
                        clip_seq = query_seq[-1 * rclip_len:]
                        shead = chrm + global_values.SEPERATOR + str(ins_pos) + global_values.SEPERATOR + query_name + "R"
                        fout_clip.write(">" + shead + "\n")
                        fout_clip.write(clip_seq + "\n")

                #####also to consider the case that totally contained in the long read
                #####whole inserted ones
                #####
        bamfile.close()

    ####This function:
    ####1. given dictionary of clip position, ##in format {chrm: {map_pos: (left_cnt, right_cnt)}}
    ####2. write the clipped part into files
    ####iextnd: is the range [-iextnd, iextnd] where to collect the reads.
    ####islack: if the clip position is <= islack distance from insertion-position, then consider it clip at the pos
    def collect_clipped_parts(self, sf_sites, islack, sf_all_clip_fa):
        samfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        references = samfile.references
        l_chrm_records = []
        xchrom = XChromosome()
        for chrm in references:
            if xchrom.is_decoy_contig_chrms(chrm) == True:  ###Here filter out those aligned to decoy sequences
                print("Skip chromosome {0}".format(chrm))  ##
                continue
            l_chrm_records.append((chrm, self.sf_bam, sf_sites, islack, self.working_folder))
        samfile.close()

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_collect_clip_parts_l, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

        ##merge the clipped reads
        with open(sf_all_clip_fa, "w") as fout_all:
            for chrm in references:
                sf_clip_fa = self.working_folder + chrm + global_values.LCLIP_FA_SUFFIX
                if os.path.isfile(sf_clip_fa) == False:
                    continue
                with open(sf_clip_fa) as fin_clip:
                    for line in fin_clip:
                        fout_all.write(line)

####