##01/11/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

##collect the featues of each insertion

from x_alignments import *
from global_values import *
from x_polyA import *
import pysam

def unwrap_self_collect_clip_disc_features(arg, **kwarg):
    return XGenotyper.collect_features_one_site(*arg, **kwarg)

class XGntpFeatures():
    def __init__(self):
        self.n_lclip=0
        self.n_lfmap=0
        self.n_rclip=0
        self.n_rfmap=0
        self.n_ldisc=0
        self.n_lcncodnt=0
        self.n_rdisc=0
        self.n_rcncodnt=0
        self.ldepth=0.0
        self.rdepth=0.0

    def set_clip(self, n_lclip, n_lfmap, n_rclip, n_rfmap):
        self.n_lclip = n_lclip
        self.n_lfmap = n_lfmap
        self.n_rclip = n_rclip
        self.n_rfmap = n_rfmap

    def set_disc(self, n_ldisc, n_lcncodnt, n_rdisc, n_rcncodnt):
        self.n_ldisc = n_ldisc
        self.n_lcncodnt = n_lcncodnt
        self.n_rdisc = n_rdisc
        self.n_rcncodnt = n_rcncodnt

    def set_depth(self, ldepth, rdepth):
        self.ldepth = ldepth
        self.rdepth = rdepth

####
class XGenotyper():
    def __init__(self, sf_ref, working_folder, n_jobs):
        self.sf_reference=sf_ref
        self.working_folder=working_folder
        self.n_jobs=n_jobs

    def call_genotype(self, sf_bam_list, sf_candidate_list, extnd, sf_out):
        l_bams=[]
        sf_merged_out=sf_out
        with open(sf_bam_list) as fin_bam_list:
            for line in fin_bam_list:
                fields=line.split()
                sf_bam=fields[0]
                l_bams.append(sf_bam)
        i_cnt = 0
        for sf_bam in l_bams:
            sf_out_features=sf_out+"{0}.out".format(i_cnt)
            i_cnt+=1
            # if len(l_bams) == 1:
            #     sf_out_features = sf_out
            l_chrm_records = []
            with open(sf_candidate_list) as fin_list:
                for line in fin_list:
                    fields = line.split()
                    chrm = fields[0]
                    pos = int(fields[1])  # candidate insertion sites
                    tmp_rcd=((chrm, pos, extnd), sf_bam, self.working_folder)
                    l_chrm_records.append(tmp_rcd)
                    #self.collect_features_one_site(tmp_rcd)
############
            pool = Pool(self.n_jobs)
            pool.map(unwrap_self_collect_clip_disc_features, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
            pool.close()
            pool.join()

            with open(sf_out_features, "w") as fout_all:
                for rcd in l_chrm_records:
                    chrm=rcd[0][0]
                    ins_pos=rcd[0][1]
                    s_pos_info = "{0}_{1}".format(chrm, ins_pos)
                    sf_gntp_features = self.working_folder + s_pos_info + global_values.GNTP_FEATURE_SUFFIX
                    if os.path.isfile(sf_gntp_features) == False:
                        continue
                    with open(sf_gntp_features) as fin_site:
                        for line in fin_site:
                            fout_all.write(line)
                    os.remove(sf_gntp_features)

        #merge the features of different bams
        i_cnt=0
        with open(sf_merged_out, "w") as fout_merged:
            m_merged={}
            for sf_bam in l_bams:
                sf_out_features = sf_out + "{0}.out".format(i_cnt)
                i_cnt += 1
                m_info=self.load_in_features_from_file(sf_out_features)
                for ins_chrm in m_info:
                    for ins_pos in m_info[ins_chrm]:
                        if (ins_chrm in m_merged) and (ins_pos in m_merged[ins_chrm]):
                            #merge the information
                            n_af_clip = int(m_info[ins_chrm][ins_pos][0]) + int(m_merged[ins_chrm][ins_pos][0])
                            n_full_map = int(m_info[chrm][pos][1]) + int(m_merged[ins_chrm][ins_pos][1])
                            n_l_raw_clip = int(m_info[chrm][pos][2]) + int(m_merged[ins_chrm][ins_pos][2])
                            n_r_raw_clip = int(m_info[chrm][pos][3]) + int(m_merged[ins_chrm][ins_pos][3])
                            n_disc_pairs = int(m_info[chrm][pos][4]) + int(m_merged[ins_chrm][ins_pos][4])
                            n_concd_pairs = int(m_info[chrm][pos][5]) + int(m_merged[ins_chrm][ins_pos][5])
                            n_disc_large_indel = int(m_info[chrm][pos][6]) + int(m_merged[ins_chrm][ins_pos][6])
                            s_clip_lens=m_info[chrm][pos][7]+":"+m_merged[ins_chrm][ins_pos][7]
                            n_polyA=int(m_info[chrm][pos][8]) + int(m_merged[ins_chrm][ins_pos][8])
                            n_disc_chrms=int(m_info[chrm][pos][9]) + int(m_merged[ins_chrm][ins_pos][9])
                            m_merged[ins_chrm][ins_pos]=(n_af_clip, n_full_map, n_l_raw_clip, n_r_raw_clip, n_disc_pairs,
                                           n_concd_pairs, n_disc_large_indel, s_clip_lens, n_polyA, n_disc_chrms)
                        else:
                            if ins_chrm not in m_merged:
                                m_merged[ins_chrm]={}
                            m_merged[ins_chrm][ins_pos]=m_info[ins_chrm][ins_pos]

            for ins_chrm in m_merged:
                for ins_pos in m_merged[ins_chrm]:
                    rcd=m_merged[ins_chrm][ins_pos]
                    sinfo="{0}\t{1}".format(ins_chrm, ins_pos)
                    for rcd_fld in rcd:
                        sinfo+="\t{0}".format(rcd_fld)
                    sinfo+="\n"
                    fout_merged.write(sinfo)
####
####
####
    ####collect clip and discordant features of given site
    ####for each candidate site:
    #Collect: 1. # of left clipped reads; 2. # of right clipped reads;
    ####3. # of fully mapped reads bypass the site; 4. # of reads contain small indels
    ####5. clip position vector; 9. # of clipped reads nearby
    # 6. # of left-disc reads; 7. # of right-disc reads; 8. # of concordant pairs
    #return info:
    ####chrm pos n_af_clip n_full_map n_l_raw_clip n_r_raw_clip n_disc_pairs n_concd_pairs n_disc_large_indel s_clip_lens
    def collect_features_one_site(self, record):
        chrm = record[0][0]  ##this is the chrm style in candidate list
        ins_pos = record[0][1]
        extnd = record[0][2]
        start_pos = ins_pos - extnd
        if start_pos <= 0:
            start_pos = 1
        end_pos = ins_pos + extnd
        sf_bam = record[1]
        working_folder = record[2]

        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        chrm_in_bam = self._process_chrm_name(b_with_chr, chrm)
        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        m_chrm_id=self._get_chrm_id_name(samfile)
        n_disc_pairs = 0
        n_concd_pairs = 0
        n_l_raw_clip = 0 #num of left clipped reads within the region
        n_r_raw_clip = 0 #num of right clipped reads within the region
        n_l_all_clip=0 #all the left clip, including secondary, supplementary, hard-clip, and soft-clip
        n_r_all_clip=0 #all the right clip, including secondary, supplementary, hard-clip and soft-clip
        n_l_af_clip=0# num of left clipped reads for checking allel freqency
        n_r_af_clip=0# num of right clipped reads for checking allel frequency
        n_full_map = 0
        n_l_full_map=0#left full map: most mapped part at the left of the "breakpoint"
        n_r_full_map=0#right full map: most mapped part at the right of the "breakpoint"
        l_lclip_lens = []
        l_rclip_lens = []
        n_disc_large_indel = 0
        n_polyA=0 #number of polyA reads
        n_disc_chrms=0 #number of chromosomes the mate falls in
        m_mate_chrms={}
####
        s_pos_info = "{0}_{1}".format(chrm, ins_pos)
        sf_gntp_features = working_folder + s_pos_info + global_values.GNTP_FEATURE_SUFFIX  #save the genotype features
        f_gntp_fetures = open(sf_gntp_features, "w")

        l_check_concord=[]
        m_clip_qname={}
        xpolyA = PolyA()
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
####
            query_name = algnmt.query_name
            query_seq = algnmt.query_sequence
            ##this is different from the one saved in the fastq/sam, no offset 33 to subtract
            query_quality = algnmt.query_qualities
            # anchor_map_pos=algnmt.reference_start##original mapping position
            map_pos = algnmt.reference_start
            mate_chrm = '*'
            mate_pos = 0
            b_clip_part_rc = False
            if algnmt.is_reverse == True:  # is reverse complementary
                b_clip_part_rc = True
####
            if (algnmt.next_reference_id in m_chrm_id) and (algnmt.mate_is_unmapped == False)\
                    and (algnmt.next_reference_id >= 0):
                mate_chrm = algnmt.next_reference_name
                mate_pos = algnmt.next_reference_start

            b_fully_mapped = False
            i_map_start = map_pos #map start position for fully mapped reads
            i_map_end=-1 #map end position for fully mapped reads
            if len(l_cigar) == 1 and l_cigar[0][0] == 0:  ##fully mapped
                b_fully_mapped = True
                i_map_end=i_map_start+l_cigar[0][1]

            #check fully mapped reads cover the breakpoint
            #Note that, here we skip some region with short segments cover, as clipped reads (mapped part is small) will
            #not showed in the alignment
            if b_fully_mapped==True:
                if ins_pos>=i_map_start and ins_pos<=i_map_end:
                    n_full_map+=1
                    if abs(i_map_start-ins_pos)<global_values.BWA_HALF_READ_MIN_SCORE:
                        n_r_full_map += 1
                    elif abs(i_map_end-ins_pos)<global_values.BWA_HALF_READ_MIN_SCORE:
                        n_l_full_map += 1

            s_clip_seq_ck = ""
            if l_cigar[0][0] == 4:  #left clipped
                if algnmt.is_supplementary or algnmt.is_secondary:###secondary and supplementary are not considered
                    continue

                # if map_pos in m_pos:
                clipped_seq = query_seq[:l_cigar[0][1]]
                len_clip_seq=len(clipped_seq)
                if abs(map_pos-ins_pos)<global_values.TSD_CUTOFF:
                    n_l_raw_clip+=1
                    m_clip_qname[query_name] = 1
                if abs(map_pos - ins_pos) < global_values.CK_POLYA_CLIP_WIN:
                    if b_clip_part_rc == False:  # not reverse complementary
                        if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                            s_clip_seq_ck = clipped_seq[-1*global_values.CK_POLYA_SEQ_MAX:]
                        else:
                            s_clip_seq_ck = clipped_seq
                    else:
                        if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                            s_clip_seq_ck = clipped_seq[:global_values.CK_POLYA_SEQ_MAX]
                        else:
                            s_clip_seq_ck = clipped_seq

                if abs(map_pos-ins_pos)<global_values.CLIP_EXACT_CLIP_SLACK:
                    n_l_af_clip+=1
                    l_lclip_lens.append(str(len_clip_seq))

            if l_cigar[-1][0] == 4:  # right clipped
                ##calculate the exact clip position
                for (type, lenth) in l_cigar[:-1]:
                    if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                        continue
                    else:
                        map_pos += lenth

                if algnmt.is_supplementary or algnmt.is_secondary:###secondary and supplementary are not considered
                    continue

                start_pos = -1 * l_cigar[-1][1]
                clipped_seq = query_seq[start_pos:]
                len_clip_seq = len(clipped_seq)

                if abs(map_pos - ins_pos) < global_values.TSD_CUTOFF:
                    n_r_raw_clip += 1
                    m_clip_qname[query_name] = 1
                if abs(map_pos - ins_pos) <  global_values.CK_POLYA_CLIP_WIN:
                    if b_clip_part_rc == False:  # not reverse complementary
                        if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                            s_clip_seq_ck = clipped_seq[:global_values.CK_POLYA_SEQ_MAX]
                        else:
                            s_clip_seq_ck = clipped_seq
                    else:
                        if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                            s_clip_seq_ck = clipped_seq[-1 * global_values.CK_POLYA_SEQ_MAX:]
                        else:
                            s_clip_seq_ck = clipped_seq

                if abs(map_pos - ins_pos) < global_values.CLIP_EXACT_CLIP_SLACK:
                    n_r_af_clip += 1
                    l_rclip_lens.append(str(len_clip_seq))

            b_polya = xpolyA.is_consecutive_polyA_T(s_clip_seq_ck)
            if b_polya is True:
                n_polyA+=1

            if mate_chrm == "*":  ##unmapped reads are not interested!
                continue
            xchrom = XChromosome()  ###decoy seuqence and contigs are not interested
            if xchrom.is_decoy_contig_chrms(mate_chrm) == True:
                continue
####
            m_mate_chrms[mate_chrm]=1
            ## here only collect the read names for discordant reads, later will re-align the discordant reads
            if self.is_discordant(chrm_in_bam, map_pos, mate_chrm, mate_pos, global_values.DISC_THRESHOLD) == True:
                # check where the mate is mapped, if within a repeat copy, then get the position on consensus
                # f_disc_names.write(query_name + "\n")
                # check whether have indels within the read
                if self._has_large_indel_in_read(l_cigar)==True:
                    n_disc_large_indel+=1

                if abs(map_pos-ins_pos)<=global_values.DFT_IS:
                    n_disc_pairs+=1

            else:
                l_check_concord.append((query_name, chrm_in_bam, map_pos, mate_chrm, mate_pos))
####
        #print m_clip_qname
        for rcd_tmp in l_check_concord:
            if rcd_tmp[0] in m_clip_qname:
                continue
            if self.is_concrdant(rcd_tmp[1],rcd_tmp[2],rcd_tmp[3],rcd_tmp[4], ins_pos, global_values.DFT_IS) == True:
                #print rcd_tmp[0], rcd_tmp[1],rcd_tmp[2],rcd_tmp[3],rcd_tmp[4]
                n_concd_pairs += 1

        n_af_clip=n_l_af_clip
        n_full_map=n_full_map-n_l_full_map #if left-clip, then remove those "right dominant full map"
        s_clip_lens=":".join(l_lclip_lens)
        if n_l_af_clip<n_r_af_clip:
            n_af_clip = n_r_af_clip
            n_full_map=n_full_map-n_r_full_map #if right-clip, then remove those "left dominant full map"
            s_clip_lens = ":".join(l_rclip_lens)
        if len(s_clip_lens)<=0:
            s_clip_lens="none"

        n_disc_chrms=len(m_mate_chrms)

        sinfo="{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t".format(chrm, ins_pos, n_af_clip, n_full_map, n_l_raw_clip, n_r_raw_clip)
        sinfo1="{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n".format(n_disc_pairs, n_concd_pairs, n_disc_large_indel,
                                                       s_clip_lens, n_polyA, n_disc_chrms)
        f_gntp_fetures.write(sinfo+sinfo1)

        f_gntp_fetures.close()
        samfile.close()
#
####
    def _get_chrm_id_name(self, samfile):
        m_chrm = {}
        references = samfile.references
        for schrm in references:
            chrm_id = samfile.get_tid(schrm)
            m_chrm[chrm_id] = schrm
        m_chrm[-1] = "*"
        return m_chrm
####
    def _has_large_indel_in_read(self, l_cigar):
        for (type, lenth) in l_cigar[:-1]:
            if (type==1 or type==2) and (lenth>=global_values.LARGE_INDEL_IN_READ):
                return True
        return False

####Need to be merged later~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
####This is drectly copies from x_clip_disc_filter.py,
    ## "self.b_with_chr" is the format gotten from the alignment file
    ## all other format should be changed to consistent with the "self.b_with_chr"
    def _process_chrm_name(self, b_tmplt_with_chr, chrm):
        b_chrm_with_chr = False
        if len(chrm) > 3 and chrm[:3] == "chr":  ##Here remove the "chr"
            b_chrm_with_chr = True

        if b_tmplt_with_chr == True and b_chrm_with_chr == True:
            return chrm
        elif b_tmplt_with_chr == True and b_chrm_with_chr == False:
            return "chr" + chrm
        elif b_tmplt_with_chr == False and b_chrm_with_chr == True:
            return chrm[3:]
        else:
            return chrm


####Need to be merged later~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
####This is drectly copies from x_clip_disc_filter.py
    ##whether a pair of read is discordant (for TEI only) or not
    def is_discordant(self, chrm, map_pos, mate_chrm, mate_pos, is_threshold):
        if chrm != mate_chrm:  ###of different chroms
            return True
        else:
            if abs(mate_pos - map_pos) > is_threshold:  # Of same chrom, but insert size are quite large
                return True
        return False

    #here require two reads are at the two sides of the insertion
    def is_concrdant(self, chrm, map_pos, mate_chrm, mate_pos, ins_pos, i_is):
        if chrm == mate_chrm:
            i_start=map_pos
            i_end=mate_pos+global_values.READ_LENGTH
            if map_pos>mate_pos:
                i_start=mate_pos
                i_end=map_pos+global_values.READ_LENGTH

            if i_start<=ins_pos and i_end>=ins_pos:
                if (ins_pos-i_start)<=i_is and (i_end-ins_pos)<=i_is:
                    return True
        return False

####
    def load_in_features_from_file(self, sf_features):
        m_features={}
        with open(sf_features) as fin_features:
            for line in fin_features:
                fields=line.split()
                chrm=fields[0]
                pos=int(fields[1])
                n_af_clip=int(fields[2])
                n_full_map=int(fields[3])
                n_l_raw_clip=int(fields[4])
                n_r_raw_clip=int(fields[5])
                n_disc_pairs=int(fields[6])
                n_concd_pairs=int(fields[7])
                n_disc_large_indel=int(fields[8])
                s_clip_lens=fields[9]
                n_polyA=int(fields[10])
                n_disc_chrms=int(fields[11])

                if chrm not in m_features:
                    m_features[chrm]={}
                if pos not in m_features[chrm]:
                    m_features[chrm][pos]=(n_af_clip, n_full_map, n_l_raw_clip, n_r_raw_clip, n_disc_pairs,
                                           n_concd_pairs, n_disc_large_indel, s_clip_lens, n_polyA, n_disc_chrms)
        return m_features

    def load_in_features_from_file_with_cov_cutoff(self, sf_features, i_cov_cutoff):
        m_features = {}
        with open(sf_features) as fin_features:
            for line in fin_features:
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])
                n_af_clip = int(fields[2])
                n_full_map = int(fields[3])
                n_l_raw_clip = int(fields[4])
                n_r_raw_clip = int(fields[5])
                n_disc_pairs = int(fields[6])
                n_concd_pairs = int(fields[7])
                n_disc_large_indel = int(fields[8])
                s_clip_lens = fields[9]

                l_clip_len=s_clip_lens.split(":")
                if len(l_clip_len)>i_cov_cutoff:#skip those with extremly large number of clipped reads
                    continue
                n_polyA = int(fields[10])
                n_disc_chrms = int(fields[11])

                if chrm not in m_features:
                    m_features[chrm] = {}
                if pos not in m_features[chrm]:
                    m_features[chrm][pos] = (n_af_clip, n_full_map, n_l_raw_clip, n_r_raw_clip, n_disc_pairs,
                                             n_concd_pairs, n_disc_large_indel, s_clip_lens, n_polyA, n_disc_chrms)
        return m_features

####
    def filter_by_af(self, m_features, f_af_min, f_af_max, sf_out):
        with open(sf_out, "w") as fout_new:
            for chrm in m_features:
                for pos in m_features[chrm]:
                    n_af_clip = int(m_features[chrm][pos][0])
                    n_full_map = int(m_features[chrm][pos][1])
                    n_l_raw_clip=int(m_features[chrm][pos][2])
                    n_r_raw_clip=int(m_features[chrm][pos][3])
                    n_disc_pairs=int(m_features[chrm][pos][4])
                    n_concd_pairs=int(m_features[chrm][pos][5])
                    n_disc_large_indel=int(m_features[chrm][pos][6])
                    s_clip_lens=m_features[chrm][pos][7]
                    f_clip_af=0.0
                    if (n_full_map+n_af_clip)!=0:
                        f_clip_af=float(n_af_clip)/float(n_full_map+n_af_clip)

                    f_disc_af = 0.0
                    n_all_pairs=n_disc_pairs+n_concd_pairs
                    if n_all_pairs!=0:
                        f_disc_af=float(n_disc_pairs)/float(n_all_pairs)

                    if (f_clip_af >= f_af_min and f_clip_af <= f_af_max) \
                            and (f_disc_af >= f_af_min and f_disc_af <= f_af_max):
                        sinfo = "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t".format(chrm, pos, n_af_clip, n_full_map,
                                                                        n_l_raw_clip, n_r_raw_clip)
                        sinfo1 = "{0}\t{1}\t{2}\t{3}\n".format(n_disc_pairs, n_concd_pairs, n_disc_large_indel,
                                                               s_clip_lens)
                        fout_new.write(sinfo + sinfo1)

####