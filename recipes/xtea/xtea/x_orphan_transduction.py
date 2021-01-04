##09/15/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong.simon.chu@gmail.com

from multiprocessing import Pool
from x_transduction import *
from x_polyA import *
from x_black_list import *
from x_post_filter import XTEARsltParser
import global_values


def unwrap_parse_td_sibling_from_bam(arg, **kwarg):
    return XOrphanTransduction.parse_td_sibling_by_site(*arg, **kwarg)

def unwrap_parse_novel_td_sibling_from_bam(arg, **kwarg):
    return XOrphanTransduction.parse_td_sibling_by_site_novel_sites(*arg, **kwarg)

def unwrap_filter_ori_td_from_bam(arg, **kwarg):
    return XOrphanTransduction.filter_ori_td_by_clip_disc_position(*arg, **kwarg)

def unwrap_check_candidate_source_region_from_bam(arg, **kwarg):
    return XOrphanTransduction.is_qualified_source_region(*arg, **kwarg)

def unwrap_check_features_for_one_site(arg, **kwarg):
    return XOrphanTransduction.check_features_for_one_site(*arg, **kwarg)

class XOrphanTransduction(XTransduction):
    def __init__(self, working_folder, n_jobs, sf_reference):
        XTransduction.__init__(self, working_folder, n_jobs, sf_reference)

    ####
    ####"sibling transduction: Because the source insertion (with TD) is absent from the reference genome,
    #                           but has one orphan transduction within the genome, thus discordant pairs will point here."
    def call_sibling_TD_from_existing_list(self, sf_cns_sites, sf_bam_list, extnd, n_half_disc_cutoff, i_search_win,
                                           xannotation, i_rep_type, i_max_cov, sf_updated_cns, sf_sibling_TD):
        # for each site, parse the alignment
        m_merged_info = {}
        with open(sf_bam_list) as fin_bam_list:
            icnt = 0
            for bam_line in fin_bam_list:  # for each bam file
                bam_fields = bam_line.split()
                sf_bam = bam_fields[0]
                ####
                l_chrm_records = []
                with open(sf_cns_sites) as fin_list:
                    for line in fin_list:
                        sline = line.rstrip()
                        fields = sline.split()
                        if len(fields) <= 1:
                            continue
                        chrm = fields[0]
                        pos = int(fields[1])  # candidate insertion site
                        # here the last par is set to "0", as we don't set cutoff here
                        one_record = ((chrm, pos, extnd), sf_bam, self.working_folder, 0)
                        l_chrm_records.append(one_record)
                        # tmp_rslt=self.parse_td_sibling_by_site(one_record)
                        # rslts.append(tmp_rslt)
                ####
                pool = Pool(self.n_jobs)
                rslts = pool.map(unwrap_parse_td_sibling_from_bam,
                                 list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
                pool.close()
                pool.join()

                #chrm, insertion_pos, True, False, s_lmchrm, i_lpos
                for (tmp_chrm, tmp_pos, blcluster, brcluster, s_src_chrm, i_src_pos, nspot) in rslts:
                    if blcluster == False and brcluster == False:
                        continue
                    if blcluster == True and brcluster == True:
                        continue
                    if tmp_chrm not in m_merged_info:
                        m_merged_info[tmp_chrm] = {}
                    if tmp_pos not in m_merged_info[tmp_chrm]:
                        m_merged_info[tmp_chrm][tmp_pos] = (blcluster, brcluster, s_src_chrm, i_src_pos, nspot)
                    else:  # already exist:
                        tmp_rcd = m_merged_info[tmp_chrm][tmp_pos]
                        # different bams must have same pattern! (same source, same-side-cluster)
                        if blcluster != tmp_rcd[0] or brcluster != tmp_rcd[1] or s_src_chrm != tmp_rcd[2]:
                            continue
                        if abs(i_src_pos - tmp_rcd[3]) > global_values.MAX_NORMAL_INSERT_SIZE:
                            continue
                        if tmp_rcd[4] > nspot:
                            m_merged_info[tmp_chrm][tmp_pos] = (
                            blcluster, brcluster, s_src_chrm, tmp_rcd[3], nspot + tmp_rcd[4])
                        else:
                            m_merged_info[tmp_chrm][tmp_pos] = (
                            blcluster, brcluster, s_src_chrm, i_src_pos, nspot + tmp_rcd[4])
####
        # load in the "one-side" related candidates
        rslt_parser = XTEARsltParser()
        l_rcd = rslt_parser.load_in_xTEA_rslt_ori(sf_cns_sites)
        m_slct_one_side = {}
        for tmp_ins in l_rcd:
            if rslt_parser.is_sibling_transduction_related_ins(tmp_ins) == True:
                s_chrm = tmp_ins[0]
                i_pos = int(tmp_ins[1])
                if s_chrm not in m_slct_one_side:
                    m_slct_one_side[s_chrm] = {}
                m_slct_one_side[s_chrm][i_pos] = rslt_parser.get_two_side_coverage_diff(tmp_ins)

        m_new_ins, m_depth = self.filter_transduction(m_merged_info, xannotation, i_rep_type, sf_bam_list,
                                                      i_max_cov, {}, 0)
        ####update the sibling TD
        self._update_existing_results(sf_cns_sites, m_new_ins, self.same_sites_extnd, sf_updated_cns, None)
        with open(sf_sibling_TD, "w") as fout_td:
            # check whether there is nearby "one-side" event
            for tmp_chrm in m_new_ins:
                for tmp_pos in m_new_ins[tmp_chrm]:
                    tmp_rcd = m_new_ins[tmp_chrm][tmp_pos]
                    n_sprt = tmp_rcd[4]
                    if n_sprt < n_half_disc_cutoff:
                        continue
                    src_chrm = tmp_rcd[2]
                    src_pos = tmp_rcd[3]
                    # check whether there is some candidate that falls in the range
                    hit_chrm, hit_pos, hit_cov_diff = self._is_sibling_within_candidates(m_slct_one_side, src_chrm,
                                                                                         src_pos, i_search_win)
                    sinfo = "{0}\t{1}\t{2}\t{3}\n".format(tmp_chrm, tmp_pos, hit_chrm, hit_pos)
                    if hit_chrm is None:
                        sinfo = "{0}\t{1}\t{2}\t{3}\n".format(tmp_chrm, tmp_pos, src_chrm, src_pos)
                        # continue
                    else:  # check which is the sibling source, which is the insertion
                        if (tmp_chrm in m_slct_one_side) and (tmp_pos in m_slct_one_side[tmp_chrm]):
                            if m_slct_one_side[tmp_chrm][tmp_pos] > hit_cov_diff:
                                sinfo = "{0}\t{1}\t{2}\t{3}\n".format(hit_chrm, hit_pos, tmp_chrm, tmp_pos)
                    fout_td.write(sinfo)
                    ####

    ####
    def parse_td_sibling_by_site(self, record):
        chrm = record[0][0]  ##this is the chrm style in candidate list
        insertion_pos = record[0][1]
        extnd = record[0][2]
        start_pos = insertion_pos - extnd
        if start_pos <= 0:
            start_pos = 1
        end_pos = insertion_pos + extnd
        sf_bam = record[1]
        working_folder = record[2]
        n_half_disc_cutoff = record[3]

        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        chrm_in_bam = self._process_chrm_name(b_with_chr, chrm)
        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        m_chrm_id = self._get_chrm_id_name(samfile)
        m_ldisc = {}
        m_rdisc = {}
        l_local_nrc_disc_pos=[]
        l_local_rc_disc_pos=[]
        max_is = global_values.MAX_NORMAL_INSERT_SIZE
        xchrm = XChromosome()
        for algnmt in samfile.fetch(chrm_in_bam, start_pos, end_pos):##fetch reads mapped to "chrm:start_pos-end_pos"
            ##here need to skip the secondary and supplementary alignments?
            if algnmt.is_secondary or algnmt.is_supplementary:
                continue
            if algnmt.is_duplicate == True:  ##duplciate
                continue
            b_first = True
            if algnmt.is_read2 == True:
                b_first = False
            if algnmt.is_unmapped == True:  # unmapped
                continue
            l_cigar = algnmt.cigar
            if len(l_cigar) < 1:  #wrong alignment
                continue
            if algnmt.mapping_quality < global_values.MINIMUM_DISC_MAPQ:
                continue

            query_name = algnmt.query_name
            query_seq = algnmt.query_sequence
            ##this is different from the one saved in the fastq/sam, no offset 33 to subtract
            query_quality = algnmt.query_qualities
            # anchor_map_pos=algnmt.reference_start##original mapping position
            map_pos = algnmt.reference_start
            is_rc = 0
            if algnmt.is_reverse == True:  # is reverse complementary
                is_rc = 1

            if (algnmt.next_reference_id in m_chrm_id) and (algnmt.mate_is_unmapped == False) \
                    and (algnmt.next_reference_id >= 0):
                mate_chrm = algnmt.next_reference_name
                # skip the decoy sequence and contigs
                if xchrm.is_decoy_contig_chrms(mate_chrm) == True:
                    continue

                mate_pos = algnmt.next_reference_start
                # first, discordant pair
                # second, one side dominant
                if (chrm != mate_chrm) or (chrm == mate_chrm and abs(mate_pos - insertion_pos) > max_is):
                    if (map_pos < insertion_pos):
                        if mate_chrm not in m_ldisc:
                            m_ldisc[mate_chrm] = []
                        m_ldisc[mate_chrm].append(mate_pos)
                        if is_rc==0:
                            l_local_nrc_disc_pos.append(map_pos)
                        else:
                            l_local_rc_disc_pos.append(map_pos)
                    else:
                        if mate_chrm not in m_rdisc:
                            m_rdisc[mate_chrm] = []
                        m_rdisc[mate_chrm].append(mate_pos)
                        if is_rc == 0:
                            l_local_nrc_disc_pos.append(map_pos)
                        else:
                            l_local_rc_disc_pos.append(map_pos)
        # make sure, one of the side form unique cluster (come from dominant chromosome)
        b_lclstr, s_lmchrm, i_lpos, nlspt = self._form_unique_cluster(m_ldisc, n_half_disc_cutoff,
                                                                      global_values.TRANSDCT_MULTI_SOURCE_MIN_RATIO,
                                                                      global_values.TRANSDCT_MULTI_SOURCE_MIN_RATIO)
        b_rclstr, s_rmchrm, i_rpos, nrspt = self._form_unique_cluster(m_rdisc, n_half_disc_cutoff,
                                                                      global_values.TRANSDCT_MULTI_SOURCE_MIN_RATIO,
                                                                      global_values.TRANSDCT_MULTI_SOURCE_MIN_RATIO)

        b_disc_clip_pos_consist = self.is_disc_cluster_consist_with_clip_position(l_local_nrc_disc_pos, insertion_pos,
                                                                                  l_local_rc_disc_pos, insertion_pos)
        ####

        if b_lclstr == True and b_rclstr == False and b_disc_clip_pos_consist==True:
            return (chrm, insertion_pos, True, False, s_lmchrm, i_lpos, nlspt)
        elif b_lclstr == False and b_rclstr == True and b_disc_clip_pos_consist==True:
            return (chrm, insertion_pos, False, True, s_rmchrm, i_rpos, nrspt)
        return (chrm, insertion_pos, False, False, "", -1, 0)
        ####

    ####Here sf_raw_sites is gotten from "raw_disc" results which is generated at the "disc" step.
    ####The results here already filtered by clip-reads cutoff and disc-reads cutoff
    def call_novel_sibling_TD_from_raw_list(self, sf_raw_sites, sf_bam_list, extnd,
                                            n_clip_cutoff, n_disc_cutoff, sf_black_list, sf_rmsk, sf_sibling_TD):
        # load in the blacklist regions
        x_blklist = XBlackList()
        x_blklist.load_index_regions(sf_black_list)
        # for each site, parse the alignment
        m_merged_info = {}#
        with open(sf_bam_list) as fin_bam_list:
            icnt = 0
            for bam_line in fin_bam_list:  # for each bam file
                bam_fields = bam_line.split()
                sf_bam = bam_fields[0]

                m_chrms={}
                sf_tmp_file=sf_raw_sites+".tmp"
                with open(sf_raw_sites) as fin_list, open(sf_tmp_file, "w") as fout_tmp:
                    for line in fin_list:
                        sline = line.rstrip()
                        fields = sline.split()
                        if len(fields) <= 1:
                            continue
                        chrm = fields[0]
                        pos = int(fields[1])  # candidate insertion site
                        # filter out fall in black list ones
                        b_in_blacklist, tmp_pos2 = x_blklist.fall_in_region(chrm, int(pos))
                        if b_in_blacklist == True:
                            print("{0}:{1} fall in black list region, filtered out!".format(chrm, pos))
                            continue

                        m_chrms[chrm]=1
                        fout_tmp.write(str(chrm)+"\t"+str(pos)+"\n")

                l_chrm_records = []
                for chrm in m_chrms:
                    n_tmp_polyA_cutoff=n_clip_cutoff/2
                    n_half_disc_cutoff=n_disc_cutoff/2
                    one_record=((chrm, extnd, sf_tmp_file), sf_bam, self.working_folder, sf_rmsk,
                                n_tmp_polyA_cutoff, n_half_disc_cutoff)
                    l_chrm_records.append(one_record)
                    #self.parse_td_sibling_by_site_novel_sites(one_record) #for test only

                pool = Pool(self.n_jobs)
                rslts = pool.map(unwrap_parse_novel_td_sibling_from_bam,
                                 list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
                pool.close()
                pool.join()

                l_tmp_candidates=[]
                for chrm_rcds in rslts:
                    for rcd in chrm_rcds:
                        l_tmp_candidates.append((rcd, sf_bam))
                # #check the "source region" in parallel
                pool = Pool(self.n_jobs)
                l_tmp_candidates2 = pool.map(unwrap_check_candidate_source_region_from_bam,
                                 list(zip([self] * len(l_tmp_candidates), l_tmp_candidates)), 1)
                pool.close()
                pool.join()

                for rcd in l_tmp_candidates2:
                    if rcd is None:
                        continue
                    (tmp_chrm, tmp_pos, s_src_chrm, i_src_lpos, i_src_rpos, n_lclip, n_rclip,
                     n_lpolyA, n_rpolyA, nlspot, nrspot, n_l_rc, n_l_nrc, n_r_rc, n_r_nrc, f_lcov, f_rcov)=rcd
                    if tmp_chrm not in m_merged_info:
                        m_merged_info[tmp_chrm] = {}
                    if tmp_pos not in m_merged_info[tmp_chrm]:
                        m_merged_info[tmp_chrm][tmp_pos] = (s_src_chrm, i_src_lpos, i_src_rpos, n_lclip, n_rclip,
                                                            n_lpolyA, n_rpolyA, nlspot, nrspot,
                                                            n_l_rc, n_l_nrc, n_r_rc, n_r_nrc, f_lcov, f_rcov)
                    else:# already exist:
                        tmp_rcd = m_merged_info[tmp_chrm][tmp_pos]
                        # different bams must have same pattern! (same source, same-side-cluster)
                        if tmp_rcd[0]!=s_src_chrm:
                            continue#
                        if abs(i_src_lpos - tmp_rcd[1]) > global_values.MAX_NORMAL_INSERT_SIZE:
                            continue
                        if abs(i_src_rpos - tmp_rcd[2]) > global_values.MAX_NORMAL_INSERT_SIZE:
                            continue

                        new_rcd=(s_src_chrm, i_src_lpos, i_src_rpos, n_lclip+tmp_rcd[3], n_rclip+tmp_rcd[4],
                                 n_lpolyA+tmp_rcd[5], n_rpolyA+tmp_rcd[6], nlspot+tmp_rcd[7], nrspot+tmp_rcd[8],
                                 n_l_rc+tmp_rcd[9], n_l_nrc+tmp_rcd[10], n_r_rc+tmp_rcd[11], n_r_nrc+tmp_rcd[12],
                                 f_lcov+tmp_rcd[13], f_rcov+tmp_rcd[14])
                        m_merged_info[tmp_chrm][tmp_pos] = new_rcd
####

        m_site_info = {}
        sf_new_sites=sf_sibling_TD+".tmp"
        with open(sf_new_sites, "w") as fout_td:
            for tmp_chrm in m_merged_info:
                for tmp_pos in m_merged_info[tmp_chrm]:
                    tmp_rcd = m_merged_info[tmp_chrm][tmp_pos]
                    n_lclip = tmp_rcd[3]
                    n_rclip = tmp_rcd[4]
                    n_lpolyA=tmp_rcd[5]
                    n_rpolyA=tmp_rcd[6]
                    nlspot = tmp_rcd[7]
                    nrspot = tmp_rcd[8]
                    n_l_rc = tmp_rcd[9]
                    n_l_nrc = tmp_rcd[10]
                    n_r_rc = tmp_rcd[11]
                    n_r_nrc = tmp_rcd[12]
                    f_lcov=tmp_rcd[13]
                    f_rcov=tmp_rcd[14]

                    if n_lclip<n_clip_cutoff/2 and n_rclip< n_clip_cutoff/2:
                        print("{0}:{1} is filtered out, as no enough left or right clipped reads!".format(tmp_chrm, tmp_pos))
                        continue
                    if n_lpolyA < n_clip_cutoff/2 and n_rpolyA < n_clip_cutoff/2:#require one side polyA
                        print("{0}:{1} is filtered out, as no enough polyA(T) reads!".format(tmp_chrm, tmp_pos))
                        continue
                    if nlspot < n_disc_cutoff/2 or nrspot< n_disc_cutoff/2:#require both side discordant reads
                        print("{0}:{1} is filtered out, as no enough left ({2}) and right ({3}) disc reads!"\
                            .format(tmp_chrm, tmp_pos, nlspot, nrspot))
                        continue
                    src_chrm = tmp_rcd[0]
                    src_pos_start = tmp_rcd[1]#mid-position of left discordant pair
                    src_pos_end = tmp_rcd[2]#mid-position of right discordant pair
                    # if abs(src_pos_end-src_pos_start)<global_values.MIN_SIBLING_FLANK_LEN:
                    #
                    #     print "{0}:{1} is filtered out, as source segment {2}-{3} is too short!"\
                    #         .format(tmp_chrm, tmp_pos, src_pos_start, src_pos_end)
                    #     continue

                    i_start=src_pos_start
                    i_end=src_pos_end
                    if src_pos_start>src_pos_end:
                        i_start=src_pos_end
                        i_end=src_pos_start

                    sinfo = "{0}\t{1}\t{2}:{3}-{4}\t{5}\t{6}\t{7}\t{8}\t{9}\t{10}\t{11}\t{12}\t{13}\t{14}\n".format(
                        tmp_chrm, tmp_pos, src_chrm, i_start, i_end, n_lclip, n_rclip,
                        n_lpolyA, n_rpolyA, nlspot, nrspot, n_l_rc, n_l_nrc, n_r_rc, n_r_nrc)
                    fout_td.write(sinfo)
                    if tmp_chrm not in m_site_info:
                        m_site_info[tmp_chrm]={}
                    s_src="{0}:{1}-{2}".format(src_chrm,i_start, i_end)
                    m_site_info[tmp_chrm][int(tmp_pos)] = (nlspot, i_start, i_start, nrspot, i_end, i_end,
                                                           n_lclip+n_rclip, n_lpolyA+n_rpolyA, f_lcov, f_rcov, s_src)

        ####create new records
        i_max_cov=global_values.MAX_COV_TIMES * global_values.AVE_COVERAGE
        m_gntp = self._collect_gntp_features(sf_new_sites, sf_bam_list, i_max_cov)
        s_type=global_values.ORPHAN_TRANSDUCTION
        self.add_new_rcd_with_cutoff(m_site_info, m_gntp, global_values.AVE_COVERAGE, sf_sibling_TD, s_type)
####

    #this version consider: 1) the clip reads (already checked in early steps); Will only check polyA here!
    # 2) discordant reads from both sides, point to same region
    # 3) if discordant reads positions are within the range of clip reads positions,
    #   then it is the source duplicate region, view as FP
    def parse_td_sibling_by_site_novel_sites(self, record):
        chrm = record[0][0]  ##this is the chrm style in candidate list
        extnd = record[0][1]
        sf_sites=record[0][2]
        sf_bam = record[1]
        working_folder = record[2]
        sf_rmsk=record[3]
        n_polyA_cutoff = record[4]
        n_half_disc_cutoff = record[5]

        l_positions=[]
        with open(sf_sites) as fin_sites:
            for line in fin_sites:
                fields=line.split()
                tmp_chrm=fields[0]
                insertion_pos=int(fields[1])
                if tmp_chrm == chrm:
                    l_positions.append(insertion_pos)
####
        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        chrm_in_bam = self._process_chrm_name(b_with_chr, chrm)
        xchrm = XChromosome()

        i_min_copy_len = 225
        xannotation = self.prep_annotation_interval_tree(sf_rmsk, i_min_copy_len)
        l_rslts_rcd=[]
        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        m_chrm_id = self._get_chrm_id_name(samfile)
        for insertion_pos in l_positions:
            start_pos = insertion_pos - extnd
            if start_pos <= 0:
                start_pos = 1
            end_pos = insertion_pos + extnd
            i_max_ncov=global_values.MAX_COV_TIMES

            m_ldisc={}
            m_rdisc={}
            #m_lorientation={}
            #m_rorientation={}
            n_l_rc=0
            n_l_nrc=0
            n_r_rc=0
            n_r_nrc=0
            min_pair_dist=global_values.MIN_ORPHAN_DISC_PAIR_INSERT_SIZE
####
            n_lclip=0 #total nubmer of left-clipped reads
            n_rclip=0 #total number of right-clipped reads
            n_lpolyA=0 #total nubmer of left-polyA reads
            n_lpolyT=0
            n_rpolyA=0 #total number of right-polyA reads
            n_rpolyT=0
            xpolyA = PolyA()
            n_total_lreads=0
            n_total_rreads=0
            n_bkgrnd_low_mapq=0#number of background low mapping quality reads
            i_offset = global_values.READ_LENGTH / 4
            l_lclip_pos=[]#save the left-clip position
            l_rclip_pos=[]#save the right-clip position
            l_local_rc_disc_pos=[]#save the local
            l_local_nrc_disc_pos=[]
            #here save the read ids into a file (will collect the reads and realigned to long reads assembly)
            for algnmt in samfile.fetch(chrm_in_bam, start_pos, end_pos):  ##fetch reads mapped to "chrm:start_pos-end_pos"
                if algnmt.is_unmapped == True:  #unmapped
                    continue
                l_cigar = algnmt.cigar
                if len(l_cigar) < 1:  # wrong alignment
                    continue
####
                map_pos = algnmt.reference_start
                ##here need to skip the secondary and supplementary alignments?
                if abs(map_pos-insertion_pos)<global_values.LOCAL_COV_WIN:
                    if map_pos>=(insertion_pos-i_offset):
                        n_total_rreads+=1
                    else:
                        n_total_lreads+=1

                if algnmt.mapping_quality < global_values.MAX_BKGRND_LOW_MAPQ:
                    if abs(map_pos - insertion_pos) < global_values.LOCAL_COV_WIN:
                        n_bkgrnd_low_mapq+=1

                if algnmt.mapping_quality < global_values.MINIMUM_DISC_MAPQ:
                    continue
                if algnmt.is_secondary or algnmt.is_supplementary:
                    continue
                if algnmt.is_duplicate == True:  ##duplciate
                    continue
                b_first = True
                if algnmt.is_read2 == True:
                    b_first = False
                b_rc=False
                if algnmt.is_reverse == True:
                    b_rc=True
####
                query_name = algnmt.query_name
                query_seq = algnmt.query_sequence
                ##this is different from the one saved in the fastq/sam, no offset 33 to subtract
                query_quality = algnmt.query_qualities
                # anchor_map_pos=algnmt.reference_start##original mapping position ####

                if l_cigar[0][0] == 4:  # left clipped, here ignore the hard clip
                    if abs(map_pos-insertion_pos)<global_values.NEARBY_CLIP:
                        n_lclip+=1
                        clipped_seq = query_seq[:l_cigar[0][1]]
                        s_polyA_chk=clipped_seq
                        if len(clipped_seq)>global_values.CK_POLYA_SEQ_MAX:
                            s_polyA_chk=clipped_seq[-1*global_values.CK_POLYA_SEQ_MAX:]
                        #b_polya = xpolyA.contain_poly_A_T(s_polyA_chk, global_values.N_MIN_A_T)
                        b_polyAT, b_polya=xpolyA.is_consecutive_polyA_T_with_ori(s_polyA_chk)
                        if b_polyAT==True:
                            if b_polya==True:
                                n_lpolyA+=1
                            else:
                                n_lpolyT+=1
                        l_lclip_pos.append(map_pos)
####
                b_right_clip = 0  # whether is right clip
                clip_pos=map_pos
                if l_cigar[-1][0] == 4:  # right clipped
                    for (type, lenth) in l_cigar[:-1]:
                        if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                            continue
                        else:
                            clip_pos += lenth
                    if abs(clip_pos-insertion_pos)<global_values.NEARBY_CLIP:#by default 50bp
                        n_rclip+=1
                        clipped_seq = query_seq[-1*l_cigar[-1][1]:]
                        s_polyA_chk = clipped_seq
                        if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                            s_polyA_chk = clipped_seq[:global_values.CK_POLYA_SEQ_MAX]
                        b_polyAT, b_polya = xpolyA.is_consecutive_polyA_T_with_ori(s_polyA_chk)
                        if b_polyAT == True:
                            if b_polya == True:
                                n_rpolyA += 1
                            else:
                                n_rpolyT += 1
                        l_rclip_pos.append(clip_pos)
####
                if (algnmt.next_reference_id in m_chrm_id) and (algnmt.mate_is_unmapped == False) \
                        and (algnmt.next_reference_id >= 0):
                    mate_chrm = algnmt.next_reference_name
                    #skip the decoy sequence and contigs
                    if xchrm.is_decoy_contig_chrms(mate_chrm)==True:
                        continue

                    mate_pos = algnmt.next_reference_start
                    #first, discordant pair
                    #second, one side dominant
                    if (chrm != mate_chrm) or (chrm == mate_chrm and abs(mate_pos - insertion_pos) > min_pair_dist):
                        if (map_pos<(insertion_pos-i_offset)):
                            if mate_chrm not in m_ldisc:
                                m_ldisc[mate_chrm]=[]
                            m_ldisc[mate_chrm].append(mate_pos)

                            if abs(map_pos-insertion_pos)<global_values.DFT_IS:#here is mean insert size
                                if b_rc==True:
                                    n_l_rc+=1
                                    l_local_rc_disc_pos.append(map_pos)
                                else:
                                    n_l_nrc+=1
                                    l_local_nrc_disc_pos.append(map_pos)
                        else:
                            if mate_chrm not in m_rdisc:
                                m_rdisc[mate_chrm]=[]
                            m_rdisc[mate_chrm].append(mate_pos)
                            if abs(map_pos - insertion_pos) < global_values.DFT_IS:#
                                if b_rc==True:
                                    n_r_rc+=1
                                    l_local_rc_disc_pos.append(map_pos)
                                else:
                                    n_r_nrc+=1
                                    l_local_nrc_disc_pos.append(map_pos)
####

            #make sure, one of the side form unique cluster (come from dominant chromosome)
            b_lclstr, s_lmchrm, i_lpos, nlspt = self._form_unique_cluster(m_ldisc, n_half_disc_cutoff,
                                                                          global_values.TRANSDCT_MULTI_SOURCE_MIN_RATIO,
                                                                          global_values.TRANSDCT_REGION_CLUSTER_MIN_RATIO)
            b_rclstr, s_rmchrm, i_rpos, nrspt = self._form_unique_cluster(m_rdisc, n_half_disc_cutoff,
                                                                          global_values.TRANSDCT_MULTI_SOURCE_MIN_RATIO,
                                                                          global_values.TRANSDCT_REGION_CLUSTER_MIN_RATIO)

            b_valid_polyA = False
            #have enough left-polyA or right-polyT clipped reads
            if n_lpolyA>=n_polyA_cutoff or n_rpolyT>=n_polyA_cutoff:#
                # b_both_side_polyAT = False
                # if n_lpolyA>n_polyA_cutoff and n_rpolyA>n_polyA_cutoff:
                #     #left polyA is dominant
                #     if float(n_lpolyA)/float(n_lpolyA+n_lpolyT) > global_values.DOMINANT_POLYA_T_MIN_RATIO:
                #         #right polyA is dominant
                #         if float(n_rpolyA) / float(n_rpolyA+n_rpolyT) > global_values.DOMINANT_POLYA_T_MIN_RATIO:
                #             b_both_side_polyAT=True
                # if n_lpolyT>n_polyA_cutoff and n_rpolyT>n_polyA_cutoff:
                #     if float(n_lpolyT)/float(n_lpolyT+n_lpolyA) > global_values.DOMINANT_POLYA_T_MIN_RATIO:
                #         if float(n_rpolyT)/float(n_rpolyT+n_rpolyA) > global_values.DOMINANT_POLYA_T_MIN_RATIO:
                #             b_both_side_polyAT = True

                #also require the polyA/T is dominant in one side
                if (n_lclip>0 and (float(n_lpolyA)/float(n_lclip) > global_values.MIN_POLYA_CLIP_RATIO)) or \
                        (n_rclip>0 and (float(n_rpolyT)/float(n_rclip) > global_values.MIN_POLYA_CLIP_RATIO)):
                    b_valid_polyA=True
####
            # find left-clip-position and right-clip-position
            lclip_pos = -1
            if len(l_lclip_pos) > 0:
                l_lclip_pos.sort()
                lclip_pos = l_lclip_pos[len(l_lclip_pos) / 2]
            rclip_pos = -1
            if len(l_rclip_pos) > 0:
                l_rclip_pos.sort()
                rclip_pos = l_rclip_pos[len(l_rclip_pos) / 2]
            #Here check whether the cluster of reverse-complementary-anchor_disc (mean position),
            # non-reverse-complementary-anchor_disc (mean position), and insertion_pos are consistent or not
            #if both mean positions are at one side, then this is a false positive, more likely to be the "sibling source"
            b_disc_clip_pos_consist=self.is_disc_cluster_consist_with_clip_position(l_local_nrc_disc_pos, insertion_pos,
                                                                                    l_local_rc_disc_pos, insertion_pos)
####
            #two clusters are consistent:
            # 1. same chrm; 2. distance is within the range; 3. left/right cluster oridentaiton
            b_l_dominant_orientation=False
            n_total_focal_ldisc=n_l_rc + n_l_nrc
            if n_total_focal_ldisc>0 and ((float(n_l_nrc)/float(n_total_focal_ldisc)) > global_values.MIN_CLUSTER_RC_RATIO):
                b_l_dominant_orientation=True
            b_r_dominant_orientation=False
            n_total_focal_rdisc=n_r_rc + n_r_nrc
            if n_total_focal_rdisc>0 and ((float(n_r_rc) / float(n_total_focal_rdisc)) > global_values.MIN_CLUSTER_RC_RATIO):
                b_r_dominant_orientation=True

            b_consistent=False
            if b_lclstr == True and b_rclstr == True:#both side form clusters
                #source is from a focal region, and focal region is within the threshold
                if (s_lmchrm == s_rmchrm) and abs(i_lpos-i_rpos)<global_values.MAX_SIBLING_FLANK_LEN:
                    if b_l_dominant_orientation==True and b_r_dominant_orientation==True:
                        b_consistent=True
            elif b_lclstr == True and b_rclstr == False:
                #check right side cluster: 1. it's from a repeats region; or 2. have enough disc reads of the same left cluster
                if b_l_dominant_orientation == True and b_r_dominant_orientation == True:
                    b_rcluster, i_rpos=self._check_form_repeat_or_same_cluster(xannotation, s_lmchrm, i_lpos, m_rdisc,
                                                                               n_half_disc_cutoff,
                                                                               global_values.TRANSDCT_MULTI_SOURCE_MIN_RATIO,
                                                                               global_values.TRANSDCT_OTHER_SIDE_CLUSTER_MIN_RATIO)
                    if b_rcluster==True:
                        b_consistent = True
            elif b_lclstr == False and b_rclstr == True:
                if b_l_dominant_orientation == True and b_r_dominant_orientation == True:
                    b_lcluster, i_lpos = self._check_form_repeat_or_same_cluster(xannotation, s_rmchrm, i_rpos, m_ldisc,
                                                                                 n_half_disc_cutoff,
                                                                                 global_values.TRANSDCT_MULTI_SOURCE_MIN_RATIO,
                                                                                 global_values.TRANSDCT_OTHER_SIDE_CLUSTER_MIN_RATIO)
                    if b_lcluster==True:
                        b_consistent = True
####
            #the left and right focal coverage should be lower than cutoff
            b_cov_normal, f_lcov, f_rcov=self._is_focal_cov_normal(n_total_lreads, n_total_rreads,
                                                                   global_values.LOCAL_COV_WIN, i_max_ncov)

            #backgroup multi-mapped reads should take a very small portion
            b_pass_bkgrnd_chk=True
            if (n_total_lreads+n_total_rreads)<=0:
                b_pass_bkgrnd_chk=False
            elif float(n_bkgrnd_low_mapq)/float(n_total_lreads+n_total_rreads) > global_values.MAX_BKGRND_LOW_MAPQ_RATIO:
                b_pass_bkgrnd_chk=False

####for test only!!!!!!!!------------------
            # print ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            # basic_rcd = (
            #     chrm, insertion_pos, s_rmchrm, i_lpos, i_rpos, n_lclip, n_rclip, n_lpolyA, n_rpolyT,
            #     nlspt, nrspt, n_l_rc, n_l_nrc, n_r_rc, n_r_nrc, f_lcov, f_rcov)
            # print basic_rcd
            # print (b_consistent, b_valid_polyA, b_cov_normal, b_pass_bkgrnd_chk)
            #
            # print m_ldisc
            # print m_rdisc
            # print (n_bkgrnd_low_mapq, n_total_lreads, n_total_rreads)
            # print "----------------------------------------------------"
###########################

            #here require both form cluster and they point to the same region
            if b_consistent==True and b_valid_polyA==True and b_disc_clip_pos_consist==True and \
                            b_cov_normal==True and b_pass_bkgrnd_chk==True:#both form cluster

#print "Pass polyA, two-side consistent, background-checking and coverage-checking"
                basic_rcd = (chrm, insertion_pos, s_rmchrm, i_lpos, i_rpos, n_lclip, n_rclip, n_lpolyA, n_rpolyT,
                             nlspt, nrspt, n_l_rc, n_l_nrc, n_r_rc, n_r_nrc, f_lcov, f_rcov)
                l_rslts_rcd.append(basic_rcd)
        samfile.close()
        return l_rslts_rcd

####
    ####filter out those FP (acutally source region) candidates
    def distinguish_source_from_insertion_for_td(self, sf_ori_td_sites, sf_bam_list, extnd,
                                               n_clip_cutoff, n_disc_cutoff, sf_black_list, sf_rmsk):
        # load in the blacklist regions
        x_blklist = XBlackList()
        x_blklist.load_index_regions(sf_black_list)
        # for each site, parse the alignment
        m_failed_sites={}
        with open(sf_bam_list) as fin_bam_list:
            icnt = 0
            for bam_line in fin_bam_list:  # for each bam file
                bam_fields = bam_line.split()
                sf_bam = bam_fields[0]

                m_chrms = {}
                sf_tmp_file = sf_ori_td_sites + ".tmp"
                with open(sf_ori_td_sites) as fin_list, open(sf_tmp_file, "w") as fout_tmp:
                    for line in fin_list:
                        # if global_values.NOT_TRANSDUCTION in line:#only check transduction cases
                        #     continue
                        sline = line.rstrip()
                        fields = sline.split()
                        if len(fields) <= 1:
                            continue
                        chrm = fields[0]
                        pos = int(fields[1])  # candidate insertion site
                        # filter out fall in black list ones
                        b_in_blacklist, tmp_pos2 = x_blklist.fall_in_region(chrm, int(pos))
                        if b_in_blacklist == True:
                            print("{0}:{1} fall in black list region, filtered out!".format(chrm, pos))
                            continue

                        m_chrms[chrm] = 1
                        fout_tmp.write(str(chrm) + "\t" + str(pos) + "\n")

                l_chrm_records = []
                for chrm in m_chrms:
                    n_tmp_polyA_cutoff = n_clip_cutoff / 2
                    n_half_disc_cutoff = n_disc_cutoff / 2
                    one_record = ((chrm, extnd, sf_tmp_file), sf_bam, self.working_folder, sf_rmsk,
                                  n_tmp_polyA_cutoff, n_half_disc_cutoff)
                    l_chrm_records.append(one_record)
                    # self.parse_td_sibling_by_site_novel_sites(one_record) #for test only

                pool = Pool(self.n_jobs)
                failed_rcds = pool.map(unwrap_filter_ori_td_from_bam,
                                 list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
                pool.close()
                pool.join()
                for chrm_rcd in failed_rcds:
                    for rcd in chrm_rcd:
                        tmp_chrm=rcd[0]
                        tmp_pos=int(rcd[1])
                        if tmp_chrm  not in m_failed_sites:
                            m_failed_sites[tmp_chrm]={}
                        m_failed_sites[tmp_chrm][tmp_pos]=1
        return m_failed_sites

####
    def update_existing_list_only(self, sf_sites, m_failed_td):
        m_existing = {}
        with open(sf_sites) as fin_exist:
            for line in fin_exist:
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])

                if (chrm in m_failed_td) and (pos in m_failed_td[chrm]):
                    continue
                if chrm not in m_existing:
                    m_existing[chrm] = {}
                m_existing[chrm][pos] = line.rstrip()

        # re-generate the existing ones
        with open(sf_sites, "w") as fout_af_filter:
            for chrm in m_existing:
                for pos in m_existing[chrm]:
                    fout_af_filter.write(m_existing[chrm][pos] + "\n")


    #Here we check whether the discordant anchor reads is encompassed by clip positions
    # if yes, then filter out;
    def filter_ori_td_by_clip_disc_position(self, record):
        chrm = record[0][0]  ##this is the chrm style in candidate list
        extnd = record[0][1]
        sf_sites = record[0][2]
        sf_bam = record[1]
        working_folder = record[2]
        sf_rmsk = record[3]
        n_polyA_cutoff = record[4]
        n_half_disc_cutoff = record[5]

        l_positions = []
        with open(sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                tmp_chrm = fields[0]
                insertion_pos = int(fields[1])
                if tmp_chrm == chrm:
                    l_positions.append(insertion_pos)
                    ####
        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        chrm_in_bam = self._process_chrm_name(b_with_chr, chrm)
        xchrm = XChromosome()

        i_min_copy_len = 225
        xannotation = self.prep_annotation_interval_tree(sf_rmsk, i_min_copy_len)
        l_failed_rcd = []
        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        m_chrm_id = self._get_chrm_id_name(samfile)
        for insertion_pos in l_positions:
            start_pos = insertion_pos - extnd
            if start_pos <= 0:
                start_pos = 1
            end_pos = insertion_pos + extnd
            i_max_ncov = global_values.MAX_COV_TIMES

            m_ldisc = {}
            m_rdisc = {}
            # m_lorientation={}
            # m_rorientation={}
            n_l_rc = 0
            n_l_nrc = 0
            n_r_rc = 0
            n_r_nrc = 0
            min_pair_dist = global_values.MIN_ORPHAN_DISC_PAIR_INSERT_SIZE
            ####
            n_lclip = 0  # total nubmer of left-clipped reads
            n_rclip = 0  # total number of right-clipped reads
            n_lpolyA = 0  # total nubmer of left-polyA reads
            n_lpolyT = 0
            n_rpolyA = 0  # total number of right-polyA reads
            n_rpolyT = 0
            xpolyA = PolyA()
            n_total_lreads = 0
            n_total_rreads = 0
            n_bkgrnd_low_mapq = 0  # number of background low mapping quality reads
            i_offset = global_values.READ_LENGTH / 4
            l_lclip_pos = []  # save the left-clip position
            l_rclip_pos = []  # save the right-clip position
            l_local_rc_disc_pos = []  # save the local
            l_local_nrc_disc_pos = []
            # here save the read ids into a file (will collect the reads and realigned to long reads assembly)
            for algnmt in samfile.fetch(chrm_in_bam, start_pos,
                                        end_pos):  ##fetch reads mapped to "chrm:start_pos-end_pos"
                if algnmt.is_unmapped == True:  # unmapped
                    continue
                l_cigar = algnmt.cigar
                if len(l_cigar) < 1:  # wrong alignment
                    continue
                    ####
                map_pos = algnmt.reference_start
                ##here need to skip the secondary and supplementary alignments?
                if abs(map_pos - insertion_pos) < global_values.LOCAL_COV_WIN:
                    if map_pos >= (insertion_pos - i_offset):
                        n_total_rreads += 1
                    else:
                        n_total_lreads += 1

                if algnmt.mapping_quality < global_values.MAX_BKGRND_LOW_MAPQ:
                    if abs(map_pos - insertion_pos) < global_values.LOCAL_COV_WIN:
                        n_bkgrnd_low_mapq += 1

                if algnmt.mapping_quality < global_values.MINIMUM_DISC_MAPQ:
                    continue
                if algnmt.is_secondary or algnmt.is_supplementary:
                    continue
                if algnmt.is_duplicate == True:  ##duplciate
                    continue
                b_first = True
                if algnmt.is_read2 == True:
                    b_first = False
                b_rc = False
                if algnmt.is_reverse == True:
                    b_rc = True
                    ####
                query_name = algnmt.query_name
                query_seq = algnmt.query_sequence
                ##this is different from the one saved in the fastq/sam, no offset 33 to subtract
                query_quality = algnmt.query_qualities
                # anchor_map_pos=algnmt.reference_start##original mapping position ####

                if l_cigar[0][0] == 4:  # left clipped, here ignore the hard clip
                    if abs(map_pos - insertion_pos) < global_values.NEARBY_CLIP:
                        n_lclip += 1
                        clipped_seq = query_seq[:l_cigar[0][1]]
                        s_polyA_chk = clipped_seq
                        if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                            s_polyA_chk = clipped_seq[-1 * global_values.CK_POLYA_SEQ_MAX:]
                        # b_polya = xpolyA.contain_poly_A_T(s_polyA_chk, global_values.N_MIN_A_T)
                        b_polyAT, b_polya = xpolyA.is_consecutive_polyA_T_with_ori(s_polyA_chk)
                        if b_polyAT == True:
                            if b_polya == True:
                                n_lpolyA += 1
                            else:
                                n_lpolyT += 1
                        l_lclip_pos.append(map_pos)
                        ####
                b_right_clip = 0  # whether is right clip
                clip_pos = map_pos
                if l_cigar[-1][0] == 4:  # right clipped
                    for (type, lenth) in l_cigar[:-1]:
                        if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                            continue
                        else:
                            clip_pos += lenth
                    if abs(clip_pos - insertion_pos) < global_values.NEARBY_CLIP:  # by default 50bp
                        n_rclip += 1
                        clipped_seq = query_seq[-1 * l_cigar[-1][1]:]
                        s_polyA_chk = clipped_seq
                        if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                            s_polyA_chk = clipped_seq[:global_values.CK_POLYA_SEQ_MAX]
                        b_polyAT, b_polya = xpolyA.is_consecutive_polyA_T_with_ori(s_polyA_chk)
                        if b_polyAT == True:
                            if b_polya == True:
                                n_rpolyA += 1
                            else:
                                n_rpolyT += 1
                        l_rclip_pos.append(clip_pos)
                        ####
                if (algnmt.next_reference_id in m_chrm_id) and (algnmt.mate_is_unmapped == False) \
                        and (algnmt.next_reference_id >= 0):
                    mate_chrm = algnmt.next_reference_name
                    # skip the decoy sequence and contigs
                    if xchrm.is_decoy_contig_chrms(mate_chrm) == True:
                        continue

                    mate_pos = algnmt.next_reference_start
                    # first, discordant pair
                    # second, one side dominant
                    if (chrm != mate_chrm) or (chrm == mate_chrm and abs(mate_pos - insertion_pos) > min_pair_dist):
                        if (map_pos < (insertion_pos - i_offset)):
                            if mate_chrm not in m_ldisc:
                                m_ldisc[mate_chrm] = []
                            m_ldisc[mate_chrm].append(mate_pos)

                            if abs(map_pos - insertion_pos) < global_values.DFT_IS:  # here is mean insert size
                                if b_rc == True:
                                    n_l_rc += 1
                                    l_local_rc_disc_pos.append(map_pos)
                                else:
                                    n_l_nrc += 1
                                    l_local_nrc_disc_pos.append(map_pos)
                        else:
                            if mate_chrm not in m_rdisc:
                                m_rdisc[mate_chrm] = []
                            m_rdisc[mate_chrm].append(mate_pos)
                            if abs(map_pos - insertion_pos) < global_values.DFT_IS:  #
                                if b_rc == True:
                                    n_r_rc += 1
                                    l_local_rc_disc_pos.append(map_pos)
                                else:
                                    n_r_nrc += 1
                                    l_local_nrc_disc_pos.append(map_pos)

            b_disc_clip_pos_consist = self.is_disc_cluster_consist_with_clip_position(l_local_nrc_disc_pos,
                                                                                      insertion_pos,
                                                                                      l_local_rc_disc_pos,
                                                                                      insertion_pos)
            # here require both form cluster and they point to the same region
            if b_disc_clip_pos_consist == False:  # both form cluster
                # print "Pass polyA, two-side consistent, background-checking and coverage-checking"
                basic_rcd = (chrm, insertion_pos)
                l_failed_rcd.append(basic_rcd)
        samfile.close()
        return l_failed_rcd

####
    def append_to_existing_list(self, sf_new_sites, sf_existing, m_failed_td):
        #first load in existing ones
        m_existing={}
        with open(sf_existing) as fin_exist:
            for line in fin_exist:
                fields=line.split()
                chrm=fields[0]
                pos=int(fields[1])

                if (chrm in m_failed_td) and (pos in m_failed_td[chrm]):
                    continue
                if chrm not in m_existing:
                    m_existing[chrm]={}
                m_existing[chrm][pos]=line.rstrip()

        #re-generate the existing ones
        with open(sf_existing,"w") as fout_af_filter:
            for chrm in m_existing:
                for pos in m_existing[chrm]:
                    fout_af_filter.write(m_existing[chrm][pos]+"\n")

        with open(sf_existing,"a") as fapp, open(sf_new_sites) as fin_sites:
            for line in fin_sites:
                fields=line.split()
                chrm=fields[0]
                pos=int(fields[1])
                if (chrm in m_existing) and (pos in m_existing[chrm]):
                    continue
                fapp.write(line.rstrip()+"\n")

####
    # Here check whether the cluster of reverse-complementary-anchor_disc (mean position),
    # non-reverse-complementary-anchor_disc (mean position), and insertion_pos are consistent or not
    # if both mean positions are at one side, then this is a false positive, more likely to be the "sibling source"
    def is_disc_cluster_consist_with_clip_position(self, l_nrc_pos, i_lclip_pos, l_rc_pos, i_rclip_pos):
        #sort the positions
        l_nrc_pos.sort()
        i_mid_nrc_pos = -1
        if len(l_nrc_pos) > 0:
            i_mid_nrc_pos = l_nrc_pos[len(l_nrc_pos) / 4]

        l_rc_pos.sort()
        i_mid_rc_pos=-1
        if len(l_rc_pos)>0:
            i_mid_rc_pos=l_rc_pos[len(l_rc_pos)*3/4]

        #print i_mid_nrc_pos, i_mid_rc_pos, i_lclip_pos, i_rclip_pos, "test clip, disc position"
        if i_lclip_pos<i_mid_nrc_pos:
            return False
        if i_rclip_pos > i_mid_rc_pos and i_mid_rc_pos>0:
            return False
        return True
####
####
    #here check the candidate "source" region: 1) not in a low mapping quality region;
    def is_qualified_source_region(self, rcd):
        (chrm, insertion_pos, s_rmchrm, i_lpos, i_rpos, n_lclip, n_rclip, n_lpolyA, n_rpolyA, nlspt, nrspt,
         n_l_rc, n_l_nrc, n_r_rc, n_r_nrc, f_lcov, f_rcov)=rcd[0]
        sf_bam=rcd[1]
        start_pos=i_lpos
        end_pos=i_rpos
        if i_lpos>i_rpos:
            start_pos=i_rpos
            end_pos=i_lpos
        if start_pos<=0 and end_pos<=0:
            return None

        if start_pos<0:
            start_pos=end_pos-500

        n_total, n_background_low_mapq=self._cnt_low_mapq_reads(sf_bam, s_rmchrm, start_pos, end_pos)
        b_qualified=False
        #check the quality
        if n_total>0 and (float(n_background_low_mapq)/float(n_total) < global_values.MAX_BKGRND_LOW_MAPQ_RATIO):
            b_qualified=True
        if b_qualified==True:
            return rcd[0]
        else:
            return None
####
####
    def _cnt_low_mapq_reads(self, sf_bam, chrm, start_pos, end_pos):
        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        chrm_in_bam = self._process_chrm_name(b_with_chr, chrm)

        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        n_total = 0
        n_background_low_mapq = 0
        for algnmt in samfile.fetch(chrm_in_bam, start_pos, end_pos):  ##fetch reads mapped to "chrm:start_pos-end_pos"
            if algnmt.is_unmapped == True:  # unmapped
                continue
            l_cigar = algnmt.cigar
            if len(l_cigar) < 1:  # wrong alignment
                continue
            n_total += 1
            if algnmt.mapping_quality < global_values.MAX_BKGRND_LOW_MAPQ:
                n_background_low_mapq += 1
        samfile.close()
        return n_total, n_background_low_mapq
####
    def _is_focal_cov_normal(self, n_lread, n_rreads, i_window, i_times):
        if i_window<=0:
            return False, -1, -1
        b_normal=True
        n_ldepth=float(n_lread*global_values.READ_LENGTH)/float(i_window)
        n_rdepth=float(n_rreads*global_values.READ_LENGTH)/float(i_window)
        i_max_cov=i_times*global_values.AVE_COVERAGE
        if n_ldepth > i_max_cov or n_rdepth>i_max_cov:
            b_normal=False
        return b_normal, n_ldepth, n_rdepth

    ####
    def _is_sibling_within_candidates(self, m_one_side, src_chrm, src_pos, i_max_dist):
        for ins_chrm in m_one_side:
            if ins_chrm is not src_chrm:
                continue
            for ins_pos in m_one_side[ins_chrm]:
                f_cov_diff=m_one_side[ins_chrm][ins_pos]
                if abs(ins_pos-src_pos) < i_max_dist:
                    return ins_chrm, ins_pos, f_cov_diff
        return None, None, None

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

    def _get_chrm_id_name(self, samfile):
        m_chrm = {}
        references = samfile.references
        for schrm in references:
            chrm_id = samfile.get_tid(schrm)
            m_chrm[chrm_id] = schrm
        m_chrm[-1] = "*"
        return m_chrm

    ####Here require they form cluster:1) have a dominant chromosome; 2) within a range
    def _form_unique_cluster(self, m_disc, n_half_disc, chrm_ratio, pos_ration):
        n_pairs = 0
        n_max_chrm = 0
        s_max_chrm = ""
        mid_pos = -1
        for mate_chrm in m_disc:
            n_temp = len(m_disc[mate_chrm])
            if n_temp > n_max_chrm:
                n_max_chrm = n_temp
                s_max_chrm = mate_chrm
            n_pairs += n_temp
        if n_pairs < n_half_disc or n_pairs <= 0:
            return False, s_max_chrm, mid_pos, n_max_chrm

        b_dominant_chrm = False
        if (n_max_chrm >n_half_disc) and (float(n_max_chrm) / float(n_pairs) > chrm_ratio):
            # also check whether the region form a cluster
            b_region_cluster, mid_pos=self._position_of_same_chrm_form_cluster(m_disc[s_max_chrm], pos_ration)
            if b_region_cluster==False:
                return False, s_max_chrm, mid_pos, n_max_chrm
            else:
                return True, s_max_chrm, mid_pos, n_max_chrm
        return b_dominant_chrm, s_max_chrm, mid_pos, n_max_chrm
    ####

    #the positions form a cluster
    def _position_of_same_chrm_form_cluster(self, l_pos, ratio):
        l_tmp = sorted(l_pos)  # sor the list
        n_tmp = len(l_tmp)
        mid_pos = l_tmp[n_tmp / 2]
        n_in_range=0
        for pos in l_tmp:
            if abs(int(pos)-int(mid_pos))<global_values.MAX_NORMAL_INSERT_SIZE:
                n_in_range+=1
        if float(n_in_range)/float(n_tmp)>ratio:
            return True, mid_pos
        return False, mid_pos

    ####If one end doesn't form a unique cluster, then check whether:
    #1) It falls in repetitive region of one class
    #2) Have enough reads of the same cluster (formed by the other side)
    def _check_form_repeat_or_same_cluster(self, xannotation, src_chrm, src_cluster_pos, m_disc, n_half_disc,
                                           f_rep_ratio, f_cluster_ratio):
        n_in_rep=0
        n_of_same_cluster=0
        n_total_disc=0
        l_mate_cluster=[]
        for mate_chrm in m_disc:
            for mate_pos in m_disc[mate_chrm]:
                b_in_rep, rep_start = xannotation.is_within_repeat_region_interval_tree(mate_chrm, mate_pos)
                n_total_disc+=1
                if b_in_rep==True:
                    n_in_rep+=1
                elif (src_chrm==mate_chrm) and (abs(mate_pos-src_cluster_pos)<global_values.MAX_SIBLING_FLANK_LEN):
                    l_mate_cluster.append(mate_pos)
                    n_of_same_cluster+=1

        if n_in_rep>n_half_disc:
            if float(n_in_rep)/float(n_total_disc)>f_rep_ratio:
                return True, -1

        if n_of_same_cluster>n_half_disc:
            if float(n_of_same_cluster)/float(n_total_disc)>f_cluster_ratio:
                n_size=len(l_mate_cluster)
                l_mate_cluster.sort()
                return True, l_mate_cluster[n_size/2]
        return False, -1
####
####
    #check whether feature exists for given site
    #this function is called at the somatic calling step
    def check_features_for_given_sites(self, sf_raw_sites, sf_bam_list, n_clip_cutoff, n_disc_cutoff):
        m_need_filter_out={}
        ####
        with open(sf_bam_list) as fin_bam_list:
            icnt = 0
            for bam_line in fin_bam_list:  # for each bam file
                bam_fields = bam_line.split()
                sf_bam = bam_fields[0]
                l_chrm_records = []
                xtea_psr=XTEARsltParser()
                with open(sf_raw_sites) as fin_list:
                    for line in fin_list:
                        sline = line.rstrip()
                        fields = sline.split()
                        if len(fields) <= 1:
                            continue
                        chrm = fields[0]
                        pos = int(fields[1])  # candidate insertion site
                        s_src=xtea_psr.get_transduction_source(fields)
                        l_chrm_records.append((chrm, pos, sf_bam, n_clip_cutoff, n_disc_cutoff, s_src))

                pool = Pool(self.n_jobs)
                rslts = pool.map(unwrap_check_features_for_one_site,
                                 list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
                pool.close()
                pool.join()
                for rcd in rslts:
                    if rcd[2]==False:
                        if rcd[0] not in m_need_filter_out:
                            m_need_filter_out[rcd[0]]={}
                        m_need_filter_out[rcd[0]][rcd[1]]=1
        return m_need_filter_out

####
####
    def check_features_for_one_site(self, record):
        chrm=record[0]
        pos=int(record[1])
        sf_bam=record[2]
        n_clip_cutoff=int(record[3])
        n_disc_cutoff=int(record[4])
        s_src=record[5]

        #pay attention that, some src are in format: chr1:-1-23342 (with -1)
        src_fields=s_src.split(":")
        if len(src_fields)<2:
            return (chrm, pos, False)

        s_region_tmp=src_fields[1]
        if len(s_region_tmp)>0 and s_region_tmp[0]=="-":
            s_region_tmp=src_fields[1][1:]

        region_fields=s_region_tmp.split("-")
        if len(region_fields)<2:
            return (chrm, pos, False)
        region_chrm=src_fields[0]
        region_start=int(region_fields[0])
        region_end=int(region_fields[-1])
        if abs(region_start)==1:
            region_start=region_end-100
        if abs(region_end)==1:
            region_end=region_start+100

        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        chrm_in_bam = self._process_chrm_name(b_with_chr, chrm)

        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        m_chrm_id = self._get_chrm_id_name(samfile)
        start_pos=pos-global_values.MAX_NORMAL_INSERT_SIZE
        end_pos=pos+global_values.MAX_NORMAL_INSERT_SIZE
        xchrm = XChromosome()

        m_ldisc = {}
        m_rdisc = {}
        # m_lorientation={}
        # m_rorientation={}
        n_l_rc = 0
        n_l_nrc = 0
        n_r_rc = 0
        n_r_nrc = 0
        min_pair_dist = global_values.MIN_ORPHAN_DISC_PAIR_INSERT_SIZE
        ####
        n_lclip = 0  # total nubmer of left-clipped reads
        n_rclip = 0  # total number of right-clipped reads
        n_lpolyA = 0  # total nubmer of left-polyA reads
        n_lpolyT = 0
        n_rpolyA = 0  # total number of right-polyA reads
        n_rpolyT = 0
        xpolyA = PolyA()
        n_total_lreads = 0
        n_total_rreads = 0
        n_bkgrnd_low_mapq = 0  # number of background low mapping quality reads
        i_offset = global_values.READ_LENGTH / 4
        l_lclip_pos = []  # save the left-clip position
        l_rclip_pos = []  # save the right-clip position

        insertion_pos=pos
        for algnmt in samfile.fetch(chrm_in_bam, start_pos, end_pos):
            if algnmt.is_unmapped == True:  # unmapped
                continue
            l_cigar = algnmt.cigar
            if len(l_cigar) < 1:  # wrong alignment
                continue

            map_pos = algnmt.reference_start
            ##here need to skip the secondary and supplementary alignments?
            if abs(map_pos - insertion_pos) < global_values.LOCAL_COV_WIN:
                if map_pos >= (insertion_pos - i_offset):
                    n_total_rreads += 1
                else:
                    n_total_lreads += 1

            if algnmt.mapping_quality < global_values.MAX_BKGRND_LOW_MAPQ:
                if abs(map_pos - insertion_pos) < global_values.LOCAL_COV_WIN:
                    n_bkgrnd_low_mapq += 1

            if algnmt.mapping_quality < global_values.MINIMUM_DISC_MAPQ:
                continue
            if algnmt.is_secondary or algnmt.is_supplementary:
                continue
            if algnmt.is_duplicate == True:  ##duplciate
                continue
            b_first = True
            if algnmt.is_read2 == True:
                b_first = False
            b_rc = False
            if algnmt.is_reverse == True:
                b_rc = True
                ####
            query_name = algnmt.query_name
            query_seq = algnmt.query_sequence
            ##this is different from the one saved in the fastq/sam, no offset 33 to subtract
            query_quality = algnmt.query_qualities
            # anchor_map_pos=algnmt.reference_start##original mapping position ####

            if l_cigar[0][0] == 4:  # left clipped, here ignore the hard clip
                if abs(map_pos - insertion_pos) < global_values.NEARBY_CLIP:
                    n_lclip += 1
                    clipped_seq = query_seq[:l_cigar[0][1]]
                    s_polyA_chk = clipped_seq
                    if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                        s_polyA_chk = clipped_seq[-1 * global_values.CK_POLYA_SEQ_MAX:]
                    # b_polya = xpolyA.contain_poly_A_T(s_polyA_chk, global_values.N_MIN_A_T)
                    b_polyAT, b_polya = xpolyA.is_consecutive_polyA_T_with_ori(s_polyA_chk)
                    if b_polyAT == True:
                        if b_polya == True:
                            n_lpolyA += 1
                        else:
                            n_lpolyT += 1
                    l_lclip_pos.append(map_pos)
                    ####
            b_right_clip = 0  # whether is right clip
            clip_pos = map_pos
            if l_cigar[-1][0] == 4:  # right clipped
                for (type, lenth) in l_cigar[:-1]:
                    if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                        continue
                    else:
                        clip_pos += lenth
                if abs(clip_pos - insertion_pos) < global_values.NEARBY_CLIP:
                    n_rclip += 1
                    clipped_seq = query_seq[-1 * l_cigar[0][1]:]
                    s_polyA_chk = clipped_seq
                    if len(clipped_seq) > global_values.CK_POLYA_SEQ_MAX:
                        s_polyA_chk = clipped_seq[:global_values.CK_POLYA_SEQ_MAX]
                    b_polyAT, b_polya = xpolyA.is_consecutive_polyA_T_with_ori(s_polyA_chk)
                    if b_polyAT == True:
                        if b_polya == True:
                            n_rpolyA += 1
                        else:
                            n_rpolyT += 1
                    l_rclip_pos.append(clip_pos)
                    ####
            if (algnmt.next_reference_id in m_chrm_id) and (algnmt.mate_is_unmapped == False) \
                    and (algnmt.next_reference_id >= 0):
                mate_chrm = algnmt.next_reference_name
                # skip the decoy sequence and contigs
                if xchrm.is_decoy_contig_chrms(mate_chrm) == True:
                    continue

                mate_pos = algnmt.next_reference_start
                # first, discordant pair
                # second, one side dominant
                if (chrm != mate_chrm) or (chrm == mate_chrm and abs(mate_pos - insertion_pos) > min_pair_dist):
                    if (map_pos < (insertion_pos - i_offset)):
                        if mate_chrm not in m_ldisc:
                            m_ldisc[mate_chrm] = []
                        m_ldisc[mate_chrm].append(mate_pos)

                        if abs(map_pos - insertion_pos) < global_values.DFT_IS:  # here is mean insert size
                            if b_rc == True:
                                n_l_rc += 1
                            else:
                                n_l_nrc += 1
                    else:
                        if mate_chrm not in m_rdisc:
                            m_rdisc[mate_chrm] = []
                        m_rdisc[mate_chrm].append(mate_pos)
                        if abs(map_pos - insertion_pos) < global_values.DFT_IS:  #
                            if b_rc == True:
                                n_r_rc += 1
                            else:
                                n_r_nrc += 1
        #Here mainly check: (either will deny the case)
        # 1) find enough disc reads point to the source region
        region_start-=global_values.MAX_NORMAL_INSERT_SIZE
        region_end+=global_values.MAX_NORMAL_INSERT_SIZE
        n_lcnt=self.cnt_in_range_disc_reads(m_ldisc, region_chrm, region_start, region_end)
        if n_lcnt>=n_disc_cutoff/2:
            return (chrm, pos, False)
        n_rcnt = self.cnt_in_range_disc_reads(m_rdisc, region_chrm, region_start, region_end)
        if n_rcnt >= n_disc_cutoff / 2:
            return (chrm, pos, False)
        #2) enough polyA/T reads
        if n_lpolyA > n_clip_cutoff/2 or n_rpolyT > n_clip_cutoff/2:
            return (chrm, pos, False)
        samfile.close()
        return (chrm, pos, True)
####
####
    def cnt_in_range_disc_reads(self, m_disc, chrm, region_start, region_end):
        n_cnt=0
        if chrm not in m_disc:
            return n_cnt
        for pos in m_disc[chrm]:
            if pos>=region_start and pos<=region_end:
                n_cnt+=1
        return n_cnt
####