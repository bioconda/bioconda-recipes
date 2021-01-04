##09/05/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong.simon.chu@gmail.com

####To-do-list:
#parse_transduction_disc_algnmt, check left and right discordant reads alignment
####

import os
import sys
import pysam
from subprocess import *
from x_alignments import *
from bwa_align import *
from x_reference import *
from x_cluster_consistency import *
import global_values
from cmd_runner import *
from x_intermediate_sites import *
from x_post_filter import *
from x_annotation import *
from x_coverage import *
from x_genotype_feature import *

#
class XTransduction():
    def __init__(self, working_folder, n_jobs, sf_reference):
        self.working_folder = working_folder
        self.n_jobs = n_jobs
        self.sf_reference=sf_reference
        self.cmd_runner = CMD_RUNNER()
        self._abnormal_insert_size=3000
        self.b_rslt_with_chr = True  #####if rslt has "chr" while rmsk doesn't (vice versa), then it will be a problem
        self._boundary_extnd = 450  # for rmsk copy extend length
        self.same_sites_extnd=75  # if td-sites and original sites are close, then view as same
        self.max_indel_ratio=0.2 #max large indel disc reads
        self.f_min_uniq_ratio=0.5 #min unique ratio for disc reads aligned to the same source

    def set_boundary_extend(self, extnd):
        self._boundary_extnd=extnd

    def set_abnormal_insert_size(self, i_is):
        if i_is>self._abnormal_insert_size:
            self._abnormal_insert_size=i_is

    #re-select from the very beginning sites to check those:
    #1. transduction comes polymorphic full length L1s (rescue those filtered out at the original "disc" step)
    #2. orphan transductions (rescue those filtered out at the originial "disc" step
    ####Input: sf_raw_disc: same sites as the output of "clip" step, but with the number of raw disc pairs
    ####        sf_candidates: this is the output of the "cns filter" step, these ones will NOT be re-selected
    def re_slct_with_clip_raw_disc_sites(self, sf_raw_disc, sf_candidates, n_disc_cutoff, xannotation,
                                         i_rep_type, b_tumor, sf_out, b_with_candidate=True):
        xintmdt=XIntemediateSites()
        m_te_candidates=xintmdt.load_in_candidate_list_str_version(sf_candidates) #TE candidates
        with open(sf_raw_disc) as fin_raw, open(sf_out, "w") as fout_slct:
            if b_with_candidate==True:
                for ins_chrm in m_te_candidates:
                    for ins_pos in m_te_candidates[ins_chrm]:
                        fout_slct.write(ins_chrm+"\t"+str(ins_pos)+"\n")
            for line in fin_raw:
                fields=line.split()
                ins_chrm=fields[0]
                ins_pos=int(fields[1])
                if (ins_chrm in m_te_candidates):#check whether already saved
                    b_close=False
                    for tmp_pos in m_te_candidates[ins_chrm]:#here pos may be different, as "cns" step refine position
                        if xintmdt.are_sites_close(ins_pos, tmp_pos, global_values.TWO_SITES_CLOSE_DIST)==True:
                            b_close=True
                            break
                    if b_close==True:
                        continue
                n_ldisc=int(fields[2])
                n_rdisc=int(fields[3])
                n_half_cutoff=int(n_disc_cutoff/2)
                if b_tumor==False:#for non tumor, set a little bit higher cutoff
                    n_half_cutoff=int(n_disc_cutoff*3/4)

                if n_ldisc < n_half_cutoff and n_rdisc< n_half_cutoff:
                    continue

                b_in_rep, i_pos = xannotation.is_within_repeat_region_interval_tree(ins_chrm, int(ins_pos))
                div_rate, sub_family, family, pos_start, pos_end = xannotation.get_div_subfamily_with_min_div(ins_chrm,
                                                                                                              i_pos)
                # print "test1", b_in_rep, i_pos, ins_chrm, ins_pos, div_rate, sub_family, family, pos_start, pos_end
                b_match_rep = self.is_matched_rep_type(i_rep_type, sub_family)
                # if fall in same type of repetitive region, then skip
                if (b_in_rep is True) and (b_match_rep is True) and (div_rate < global_values.TD_REP_DIVERGENT_CUTOFF):
                    print("[re-select step]:Filtered out: {0}:{1} fall in repetitive region.".format(ins_chrm, ins_pos))
                    continue
                # if xintmdt.is_in_existing_list(ins_chrm, ins_pos, m_te_candidates, i_win_size)==True:
                #     continue
                #fout_slct.write(ins_chrm+"\t"+str(ins_pos)+"\n")
                fout_slct.write(line.rstrip() + "\n")
####
####
    #this function (duplicate with first part of call_candidate_transduction_v2 function)
    #  is used at case control mode to filter out germline events
    def collect_realign_reads(self, sf_raw_slct, sf_te_candidates, x_filter, sf_flank, i_flank_length, extnd,
                              bin_size, n_disc_cutoff, sf_cns, sf_out):
        # 1. prepare the flanking regions
        ##call out the full length L1 candidates (here use very flexible threshold to integrate all possible ones)
        ileftmost_cns = 500  # at lest hit the first 500bp
        if global_values.IS_CALL_SVA == True:
            ileftmost_cns = 5000  # then here, we will consider all the candidate SVAs
        l_fl_polymorpic = self.pick_full_length_insertion(sf_te_candidates, ileftmost_cns)
        ##generate the new flank regions with polymerphic full length insertion flanks
        sf_flank_with_poly = self.working_folder + "all_with_polymerphic_flanks.fa"
        ####Note, we add L1, Alu and SVA consensus to the flank regions to filter out those mapped to consensus
        self.construct_novel_flanks(l_fl_polymorpic, sf_flank, i_flank_length, sf_flank_with_poly)

        # align the picked disc and clip parts to the FL-L1 flank regions
        bwa_align = BWAlign(global_values.BWA_PATH, global_values.BWA_REALIGN_CUTOFF, self.n_jobs)
        if os.path.isfile(sf_flank_with_poly + ".sa") == False:
            cmd = "{0} index {1}".format(global_values.BWA_PATH, sf_flank_with_poly)
            self.cmd_runner.run_cmd_small_output(cmd)

        # 2. re-collect the reads for the sites
        sf_clip_fq = self.working_folder + "raw_candidate_sites_all_clip.fq"
        sf_disc_fa = self.working_folder + "raw_candidate_sites_all_disc.fa"
        #if os.path.isfile(sf_clip_fq) == False or os.path.isfile(sf_disc_fa) == False:  #
        x_filter.collect_clipped_disc_reads(sf_raw_slct, extnd, bin_size, sf_clip_fq, sf_disc_fa)  #

        # ##re-align the disc reads
        sf_disc_algnmt = self.working_folder + "temp_transduction_disc.sam"
        bwa_align.realign_disc_reads(sf_flank_with_poly, sf_disc_fa, sf_disc_algnmt)
        x_filter.clean_file_by_path(sf_disc_fa)
        #
        n_half_cutoff = n_disc_cutoff / 2
        if n_half_cutoff <= 1:
            n_half_cutoff = n_disc_cutoff
        # #3. parse alignment to get the candidates
        # #3.1 first parse the disc alignments, to get candidates. Here, we require uniquely map only.
        # m_disc_transd in format: [ins_chrm][ins_pos] = (s_source, [(hit_ref_pos, anchor_pos, dist_from_rep)])
        m_disc_transd, m_orphan = self.parse_transduction_disc_algnmt(sf_disc_algnmt, i_flank_length, n_half_cutoff)#
        m_all_td={}
        with open(sf_out + ".unique_trsdct_disc_only", "w") as fout:
            for ins_chrm in m_disc_transd:
                if ins_chrm not in m_all_td:
                    m_all_td[ins_chrm]={}
                for ins_pos in m_disc_transd[ins_chrm]:
                    rcd = m_disc_transd[ins_chrm][ins_pos]
                    s_src=rcd[0] #each record: (max_source, l_pos, max_cnt)
                    i_max_spt=rcd[2]
                    sinfo = "{0}\t{1}\t{2}\t{3}\n".format(ins_chrm, ins_pos, s_src, i_max_spt)
                    fout.write(sinfo)
                    m_all_td[ins_chrm][ins_pos]=(s_src, i_max_spt)

            for ins_chrm in m_orphan:
                if ins_chrm not in m_all_td:
                    m_all_td[ins_chrm]={}
                for ins_pos in m_orphan[ins_chrm]:
                    rcd = m_orphan[ins_chrm][ins_pos] #each in format: (tmp_source, n_left, n_right)
                    s_src=rcd[0]
                    i_max_spt=(int(rcd[1]) + int(rcd[2]))
                    sinfo = "{0}\t{1}\t{2}\t{3}\n".format(ins_chrm, ins_pos, s_src, i_max_spt)
                    fout.write(sinfo)
                    m_all_td[ins_chrm][ins_pos] = (s_src, i_max_spt)

        #algn the clip reads to cns, to count polyA reads
        sf_clip_algnmt = self.working_folder + "temp_transduction_clip.sam"
        bwa_align.realign_clipped_read_with_polyA(sf_cns, sf_clip_fq, sf_clip_algnmt)
        x_filter.clean_file_by_path(sf_clip_fq)
        ####
        m_lclip_trsd, m_rclip_trsd, m_clip_polyA = self.parse_transduction_clip_algnmt(sf_clip_algnmt, i_flank_length)
        return m_all_td, m_clip_polyA
####
####

####
    # In this version, the clip and disc reads collection module are run separately
    # Given the re-selected sites:
    # 1) prepare the flanking regions for both reference and polymorphic full-length ins;
    # 2) collect the clipped and disc reads for the re-selected sites
    # 3) align to the flanking regions
    # 4) parse out the transductions
    def call_candidate_transduction_v3(self, sf_raw_slct, sf_te_candidates, x_filter, sf_flank, sf_cns,
                                       i_flank_length, extnd, bin_size, n_clip_cutoff, n_disc_cutoff,
                                       i_concord_dist, f_concord_ratio, xannotation, sf_bam_list, i_rep_type,
                                       i_max_cov, ave_cov, sf_out):
        # 1. prepare the flanking regions
        ##call out the full length L1 candidates (here use very flexible threshold to integrate all possible ones)
        ileftmost_cns = 500  # at lest hit the first 500bp
        if global_values.IS_CALL_SVA == True:  #
            ileftmost_cns = 5000  # then here, we will consider all the candidate SVAs
        l_fl_polymorpic = self.pick_full_length_insertion(sf_te_candidates, ileftmost_cns)
        ##generate the new flank regions with polymerphic full length insertion flanks
        sf_flank_with_poly = self.working_folder + "all_with_polymerphic_flanks.fa"
        ####Note, we add L1, Alu and SVA consensus to the flank regions to filter out those mapped to consensus
        self.construct_novel_flanks(l_fl_polymorpic, sf_flank, i_flank_length, sf_flank_with_poly)
####
        # align the picked disc and clip parts to the FL-L1 flank regions
        bwa_align = BWAlign(global_values.BWA_PATH, global_values.BWA_REALIGN_CUTOFF, self.n_jobs)
        cmd = "{0} index {1}".format(global_values.BWA_PATH, sf_flank_with_poly)
        self.cmd_runner.run_cmd_small_output(cmd)####

        # 2. re-collect the reads for the sites
        sf_clip_fq = self.working_folder + "raw_candidate_sites_all_clip.fq"
        # first, collect the clipped reads, do one round of filtering;
        x_filter.collect_clipped_reads(sf_raw_slct, extnd, sf_clip_fq)

        sf_clip_algnmt = self.working_folder + "temp_transduction_clip.sam"
        bwa_align.realign_clipped_read_with_polyA(sf_flank_with_poly, sf_clip_fq, sf_clip_algnmt)
        # clean temp files
        x_filter.clean_file_by_path(sf_clip_fq)#

        # here realign the clipped reads to the flanking regions, and count fully mapped clipped reads
        # Note, we didn't check whether they form cluster or not
        # We count the number of polyA reads
        # This is a seperate function of the transduction part
        m_lclip_trsd, m_rclip_trsd, m_clip_polyA = self.parse_transduction_clip_algnmt(sf_clip_algnmt, i_flank_length)
        n_polyA_cutoff = n_clip_cutoff / 2 - 1
        if n_polyA_cutoff < 0:
            n_polyA_cutoff = 0
        m_clip_slct = self.filter_by_clip_algnmt(m_lclip_trsd, m_rclip_trsd, m_clip_polyA, n_clip_cutoff, n_polyA_cutoff)
        sf_clip_tmp_out=sf_out + ".unique_trsdct_half_clip"
        with open(sf_clip_tmp_out, "w") as fout:
            for ins_chrm in m_clip_slct:
                for ins_pos in m_clip_slct[ins_chrm]:
                    sinfo = "{0}\t{1}\n".format(ins_chrm, ins_pos)
                    fout.write(sinfo)
        ####
        # then, collect the disc reads
        sf_disc_fa = self.working_folder + "raw_candidate_sites_all_disc.fa"
        x_filter.collect_disc_reads(sf_clip_tmp_out, extnd, bin_size, sf_disc_fa)
        # ##re-align the disc reads
        sf_disc_algnmt = self.working_folder + "temp_transduction_disc.sam"
        bwa_align.realign_disc_reads(sf_flank_with_poly, sf_disc_fa, sf_disc_algnmt)
        x_filter.clean_file_by_path(sf_disc_fa)

        n_half_cutoff = n_disc_cutoff / 2
        if n_half_cutoff <= 1:
            n_half_cutoff = n_disc_cutoff
        # #3. parse alignment to get the candidates
        # #3.1 first parse the disc alignments, to get candidates. Here, we require uniquely map only.
        # m_disc_transd in format: [ins_chrm][ins_pos] = (s_source, [(hit_ref_pos, anchor_pos, dist_from_rep)])
        m_disc_transd, m_orphan = self.parse_transduction_disc_algnmt(sf_disc_algnmt, i_flank_length, n_half_cutoff,
                                                                      i_rep_type)
        with open(sf_out + ".unique_trsdct_disc_only", "w") as fout:
            for ins_chrm in m_disc_transd:
                for ins_pos in m_disc_transd[ins_chrm]:
                    rcd = m_disc_transd[ins_chrm][ins_pos]
                    sinfo = "{0}\t{1}\t{2}\n".format(ins_chrm, ins_pos, rcd[0])
                    fout.write(sinfo)

        with open(sf_out + ".unique_trsdct_disc_orphan", "w") as fout:
            for ins_chrm in m_orphan:
                for ins_pos in m_orphan[ins_chrm]:
                    rcd = m_orphan[ins_chrm][ins_pos]
                    sinfo = "{0}\t{1}\t{2}\t{3}\t{4}\n".format(ins_chrm, ins_pos, rcd[0], rcd[1], rcd[2])
                    fout.write(sinfo)

        # 3.2 #re-select the discordant reads for those focusing sites
        sf_disc_fa2 = self.working_folder + "raw_candidate_sites_all_disc_focal_sites.fa"
        self.re_select_disc_reads(sf_disc_algnmt, m_disc_transd, sf_disc_fa2)
        ##3.3.1 re-align the selected disc reads to consensus
        sf_disc_algnmt_cns = self.working_folder + "temp_transduction_disc_cns.sam"
        bwa_align.realign_disc_reads(sf_cns, sf_disc_fa2, sf_disc_algnmt_cns)
        ##3.3.2 align the clipped reads to flanking regions
        # first only select those related clipped reads
        #sf_clip_fa2 = self.working_folder + "raw_candidate_sites_all_clip_focal_sites.fa"
        #self.re_selct_clip_reads(sf_clip_fq, m_disc_transd, sf_clip_fa2)
        m_rep_pos_disc, m_disc_sample, m_disc_polyA = \
            x_filter.parse_disc_algnmt_consensus(sf_disc_algnmt_cns, global_values.MIN_DISC_MAPPED_RATIO)

        ##get the representative clip position
        # m_disc_consist_list = dict(m_clip_checked_list)
        # m_represent_pos = x_filter._refine_represent_clip_pos(m_disc_consist_list)
        m_represent_pos = self.prep_representative_pos(m_disc_transd)
        m_disc_filtered = x_filter.check_seprt_disc_consistency(m_represent_pos, m_rep_pos_disc,
                                                                i_concord_dist, f_concord_ratio,
                                                                n_half_cutoff, False)
        with open(sf_out + ".unique_trsdct_disc_only_half_clip_half_disc", "w") as fout:
            for ins_chrm in m_disc_filtered:
                for ins_pos in m_disc_filtered[ins_chrm]:
                    rcd = m_disc_filtered[ins_chrm][ins_pos]
                    sinfo = "{0}\t{1}\n".format(ins_chrm, ins_pos)
                    fout.write(sinfo)

        # m_represent_clip_pos=self._load_in_representative_sites(sf_raw_slct)
        # f_concord_ratio=0.1 #set a small value here
        m_represent_pos2 = self.prep_representative_pos(m_disc_filtered)
        m_transduct_candidates = self.call_out_candidate_transduct(m_represent_pos2, m_disc_transd, extnd,
                                                                   f_concord_ratio, m_clip_slct,
                                                                   m_disc_polyA, m_orphan)
        with open(sf_out + ".unique_trsdct_disc_only_half_clip_half_disc_polyA", "w") as fout:
            for ins_chrm in m_transduct_candidates:
                for ins_pos in m_transduct_candidates[ins_chrm]:
                    sinfo = "{0}\t{1}\n".format(ins_chrm, ins_pos)
                    fout.write(sinfo)
####
        # 1. transduction disc reads
        # number of unique disc reads aligned to transduction region is saved in m_disc_transd[ins_chrm][ins_pos][2]
        # for orphan transduction insertion: saved in m_orphan[ins_chrm][ins_pos]: each record (tmp_source, n_left, n_right)
        # 2. disc aligned to cns
        # m_disc_filtered: each record in format:
        ###(n_l_disc, lcns_start, lcns_end, n_r_disc, rcns_start, rcns_end,
        # (n_l_rc, n_l_not_rc, n_r_rc, n_r_not_rc), (n_l_rc, n_l_non_rc, n_r_rc, n_r_non_rc))
        # 3. clip aligned to cns
        ##m_clip_slct[ins_chrm][ins_pos] save: (n_cnt, n_polyA)
        m_new_ins, m_depth = self.filter_transduction(m_transduct_candidates, xannotation, i_rep_type,
                                                      sf_bam_list, i_max_cov, m_clip_polyA, n_clip_cutoff / 2)
        m_site_info = self.collect_ins_info(m_new_ins, m_transduct_candidates, m_disc_filtered, m_orphan,
                                            m_clip_slct, m_depth)
        with open(sf_out + ".unique_trsdct_disc_only_half_clip_half_disc_polyA_after_filter", "w") as fout:
            for ins_chrm in m_site_info:
                for ins_pos in m_site_info[ins_chrm]:
                    sinfo = "{0}\t{1}\n".format(ins_chrm, ins_pos)
                    fout.write(sinfo)

        # 4. update existing records
        # i_extnd=self.same_sites_extnd #if td-sites and original sites are close, then view as same
        sf_new_ins = sf_out + ".tmp_new_sites_position_only"
        sf_updated = sf_out
        self._update_existing_results(sf_te_candidates, m_site_info, self.same_sites_extnd, sf_updated, sf_new_ins)
        # 5. add new records in same format
        #   5.1. collect genotype information
        # each record: (n_af_clip, n_full_map, n_l_raw_clip, n_r_raw_clip, n_disc_pairs, n_concd_pairs,
        # n_disc_large_indel, s_clip_lens, n_polyA, n_disc_chrms)

        m_gntp = self._collect_gntp_features(sf_new_ins, sf_bam_list, i_max_cov)
        sf_new_rcds = sf_out + global_values.TD_NEW_SITES_SUFFIX
        self.add_new_rcd_with_cutoff(m_site_info, m_gntp, ave_cov, sf_new_rcds)
        with open(sf_out, "a") as fout_all:
            with open(sf_new_rcds) as fin_new:
                for line in fin_new:
                    fout_all.write(line)

####
#####This is to call out the sites with clear tprt signal, but the source is unknown, thus not aligned to flanking
    def call_transduction_with_unknown_source(self, sf_raw_slct, m_slcted):
        return
####
    ####update the existing results if there is an overlap
    ####add new records (absent from existing results)
    def _update_existing_results(self, sf_xtea_rslts, m_td_site_info, i_extnd, sf_xtea_updt_rslts, sf_new_ins):
        #1. first load in the old results
        xtea_psr=XTEARsltParser()
        l_xtea_rslts=xtea_psr.load_in_xTEA_rslt_ori(sf_xtea_rslts)
        #2. check for overlapped ones, and update them
        m_overlap_ins={}
        for rcd in l_xtea_rslts:
            ins_chrm=rcd[0]
            ins_pos=int(rcd[1])
            if ins_chrm in m_td_site_info:
                for i_tmp in range(ins_pos-i_extnd, ins_pos+i_extnd):
                    if i_tmp in m_td_site_info[ins_chrm]:#find a hit
                        if ins_chrm not in m_overlap_ins:
                            m_overlap_ins[ins_chrm]={}
                        m_overlap_ins[ins_chrm][i_tmp]=1
                        #update the record
                        self._update_one_td_rcd(xtea_psr, rcd, m_td_site_info[ins_chrm][i_tmp])
                        break
####
        #dump the updated existing sites
        with open(sf_xtea_updt_rslts, "w") as fout_updt:
            for rcd in l_xtea_rslts:
                sinfo=""
                for field in rcd:
                    sinfo+=(str(field)+"\t")
                fout_updt.write(sinfo+"\n")

        if sf_new_ins is not None:#
            with open(sf_new_ins, "w") as fout_new:
                for ins_chrm in m_td_site_info:
                    for ins_pos in m_td_site_info[ins_chrm]:
                        if (ins_chrm not in m_overlap_ins) or (ins_pos not in m_overlap_ins[ins_chrm]):
                            fout_new.write(ins_chrm+"\t"+str(ins_pos)+"\n")

    #xtea_rcd is the same format as
    #rcd_td_info in format: (n_l_disc, lcns_start, lcns_end, n_r_disc, rcns_start, rcns_end, n_cns_clip, n_polyA_clip,
                            # i_lcov2, i_rcov2, s_src)
    def _update_one_td_rcd(self, xtea_psr, xtea_rcd, rcd_td_info):
        #here update the number of disc reads, and transduction source info
        #print rcd_td_info
        #(False, True, '3', 121086622, 1)
        if len(rcd_td_info)>6:
            s_td_info=rcd_td_info[-1]
            n_clip=rcd_td_info[6]
            n_polyA=rcd_td_info[7]
            n_disc=rcd_td_info[0]+rcd_td_info[3]
            xtea_psr.update_td_info(xtea_rcd, s_td_info, n_clip, n_disc, n_polyA)
        else:#sibling transduction
            s_td_info="{0}_{1}_sibling".format(rcd_td_info[2], rcd_td_info[3])
            xtea_psr.update_td_source_only(xtea_rcd, s_td_info)
####
####
    ####add new record
    def add_new_rcd_with_cutoff(self, m_site_info, m_gntp, ave_cov, sf_out, s_type=global_values.ONE_SIDE_TRSDCT):
        xtea_psr = XTEARsltParser()
        with open(sf_out, "w") as fout_new:
            for ins_chrm in m_gntp:
                for ins_pos in m_gntp[ins_chrm]:
                    #each record: (n_af_clip, n_full_map, n_l_raw_clip, n_r_raw_clip, n_disc_pairs, n_concd_pairs,
                    # n_disc_large_indel, s_clip_lens, n_polyA, n_disc_chrms)
                    rcd_gntp=m_gntp[ins_chrm][ins_pos]
                    n_disc_large_indel=rcd_gntp[6]
                    if n_disc_large_indel > (ave_cov*self.max_indel_ratio):
                        continue
                    #each record in format: (n_l_disc, lcns_start, lcns_end, n_r_disc, rcns_start, rcns_end,
                    # n_cns_clip, n_polyA_clip, i_lcov2, i_rcov2, s_src)
                    rcd_td_info=m_site_info[ins_chrm][ins_pos]
                    #ins_chrm, ins_pos, rcd_td_info, gntp_rcd, f_out
                    xtea_psr.add_new_rcd(ins_chrm, ins_pos, rcd_td_info, rcd_gntp, s_type, fout_new)
####

####collect genotype features
    def _collect_gntp_features(self, sf_sites, sf_bam_list, i_max_cov):
        x_gntper = XGenotyper(self.sf_reference, self.working_folder, self.n_jobs)
        is_extnd = global_values.DFT_IS

        sf_gntp_feature = sf_sites + ".gntp.features"
        x_gntper.call_genotype(sf_bam_list, sf_sites, is_extnd, sf_gntp_feature)
        # load in features, also filter out sites with very large clipped reads at the breakpoints
        m_gntp_info = x_gntper.load_in_features_from_file_with_cov_cutoff(sf_gntp_feature, i_max_cov)
        return m_gntp_info

####
####
    #filter out candidates:
    #1. fall in same type of TE insertions
    #2. high coverage island
    #3. two side polyA, and close to an existing insertion
    #4. close to a full length reference insertion ???? && point to an insertion
    def filter_transduction(self, m_ori_ins, xannotation, i_rep_type, sf_bam_list, i_max_cov, m_clip_polyA, n_half_clip):
        m_new_ins={}
        # calc the left and right local depth for the sites
        search_win = global_values.COV_SEARCH_WINDOW  # this region is to collect the reads, by default 1000
        focal_win = global_values.LOCAL_COV_WIN  # this region is used to search for coverage island, by default 900
        focal_win2 = global_values.COV_ISD_CHK_WIN  # this region is to calculate the local coverage, by default 200
        # m_read_depth in format: {ins_chrm: {ins_pos: [lfcov, rfcov]}}
        rd = ReadDepth(self.working_folder, self.n_jobs, self.sf_reference)
        m_read_depth = rd.calc_coverage_of_two_regions(m_ori_ins, sf_bam_list, search_win, focal_win, focal_win2)

        for ins_chrm in m_ori_ins:
            for ins_pos in m_ori_ins[ins_chrm]:
                if self.fall_in_low_div_same_type_rep(xannotation, ins_chrm, ins_pos, i_rep_type)==True:
                    print("[Transduction filter]:Filtered out: {0}:{1} fall in repetitive region.".format(ins_chrm, ins_pos))
                    continue

                i_lcov1=m_read_depth[ins_chrm][ins_pos][0]
                i_rcov1=m_read_depth[ins_chrm][ins_pos][1]
                i_lcov2 = m_read_depth[ins_chrm][ins_pos][2]
                i_rcov2 = m_read_depth[ins_chrm][ins_pos][3]
                if i_lcov1>i_max_cov or i_rcov1>i_max_cov or i_lcov2>i_max_cov or i_rcov2>i_max_cov:
                    print("[Transduction filter]:Filtered out: {0}:{1} fall in alignment island.".format(ins_chrm, ins_pos))
                    print("{0}:{1}, Details {2} {3} {4} {5} {6}".format(ins_chrm, ins_pos, i_lcov1, i_rcov1, i_lcov2, i_rcov2, i_max_cov))
                    continue
                #check polyA and polyT seperately
                if (ins_chrm in m_clip_polyA) and (ins_pos in m_clip_polyA[ins_chrm]):
                    n_lpolyA=m_clip_polyA[ins_chrm][ins_pos][0]
                    n_rpolyA=m_clip_polyA[ins_chrm][ins_pos][1]
                    if n_lpolyA>n_half_clip and n_rpolyA>n_half_clip:
                        print("[Transduction filter]:Filtered out: {0}:{1} has two sides polyA reads.".format(ins_chrm, ins_pos))
                        continue
                    n_lpolyT = m_clip_polyA[ins_chrm][ins_pos][2]
                    n_rpolyT = m_clip_polyA[ins_chrm][ins_pos][3]
                    if n_lpolyT > n_half_clip and n_rpolyT > n_half_clip:
                        print("[Transduction filter]:Filtered out: {0}:{1} has two sides polyT reads.".format(ins_chrm, ins_pos))
                        continue

                if ins_chrm not in m_new_ins:
                    m_new_ins[ins_chrm]={}
                m_new_ins[ins_chrm][ins_pos]=m_ori_ins[ins_chrm][ins_pos]
        return m_new_ins, m_read_depth
####

    #only consider SVA and Alu transduction
    def is_matched_rep_type(self, i_rep_type, s_sub_family):
        if (i_rep_type & 1==1) and (("L1" in s_sub_family) or ("LINE/L1" in s_sub_family) or "LINE1" in s_sub_family):
            return True
        elif (i_rep_type & 4==4) and ("SVA" in s_sub_family):
            return True
        return False

    ####
    def fall_in_low_div_same_type_rep(self, xannotation, ins_chrm, ins_pos, i_rep_type):
        #check all the possible hits, not only the first one
        l_hits = xannotation.is_within_repeat_region_interval_tree2(ins_chrm, int(ins_pos))
        if len(l_hits)<=0:
            return False
        for (b_in_rep, i_pos) in l_hits:#for each hit
            l_family_hits=xannotation.get_div_subfamily_with_min_div2(ins_chrm, i_pos)
            for (div_rate, sub_family, family, pos_start, pos_end) in l_family_hits:
                # print "test1", b_in_rep, i_pos, ins_chrm, ins_pos, div_rate, sub_family, family, pos_start, pos_end
                b_match_rep = self.is_matched_rep_type(i_rep_type, sub_family)
                # if fall in same type of repetitive region, then skip
                if (b_in_rep is True) and (b_match_rep is True) and (div_rate < global_values.TD_REP_DIVERGENT_CUTOFF):
                    return True
        return False

    ####
    def prep_annotation_interval_tree(self, sf_rmsk, i_min_copy_len):
        xannotation = XAnnotation(sf_rmsk)
        xannotation.set_with_chr(self.b_rslt_with_chr)
        xannotation.load_rmsk_annotation_with_extnd_div_with_lenth_cutoff(self._boundary_extnd, i_min_copy_len)
        xannotation.index_rmsk_annotation_interval_tree()
        return xannotation

    ####
    def collect_ins_info(self, m_td_ins, m_slct_td, m_disc_cns, m_orphan, m_clip_cns, m_read_depth):
        m_site_info={}
        for ins_chrm in m_td_ins:
            if ins_chrm not in m_site_info:
                m_site_info[ins_chrm]={}
            for ins_pos in m_td_ins[ins_chrm]:
                n_l_disc = 0
                lcns_start = -1
                lcns_end = -1
                n_r_disc = 0
                rcns_start = -1
                rcns_end = -1
                if (ins_chrm in m_disc_cns) and (ins_pos in m_disc_cns[ins_chrm]):
                    n_l_disc=m_disc_cns[ins_chrm][ins_pos][0]
                    lcns_start=m_disc_cns[ins_chrm][ins_pos][1]
                    lcns_end=m_disc_cns[ins_chrm][ins_pos][2]
                    n_r_disc=m_disc_cns[ins_chrm][ins_pos][3]
                    rcns_start=m_disc_cns[ins_chrm][ins_pos][4]
                    rcns_end=m_disc_cns[ins_chrm][ins_pos][5]
                else:#orphan transduction
                    n_l_disc = m_orphan[ins_chrm][ins_pos][1]
                    n_r_disc = m_orphan[ins_chrm][ins_pos][2]

                # (b_l_trsdct, b_r_trsdct, n_disc_trsdct, trsdct_info)
                b_l_trsdct = m_slct_td[ins_chrm][ins_pos][0]
                b_r_trsdct = m_slct_td[ins_chrm][ins_pos][1]
                n_td_disc = m_slct_td[ins_chrm][ins_pos][2]
                s_src = m_slct_td[ins_chrm][ins_pos][3]
                if b_l_trsdct==True and b_r_trsdct==False:
                    n_l_disc=n_td_disc
                    lcns_start=-1
                    lcns_end=-1
                elif b_l_trsdct==False and b_r_trsdct==True:
                    n_r_disc=n_td_disc
                    rcns_start=-1
                    rcns_end=-1

                n_cns_clip=m_clip_cns[ins_chrm][ins_pos][0]
                n_polyA_clip=m_clip_cns[ins_chrm][ins_pos][1]
                i_lcov2 = m_read_depth[ins_chrm][ins_pos][2]#left local coverage
                i_rcov2 = m_read_depth[ins_chrm][ins_pos][3]#right local coverage
                m_site_info[ins_chrm][ins_pos]=(n_l_disc, lcns_start, lcns_end, n_r_disc, rcns_start, rcns_end,
                                                n_cns_clip, n_polyA_clip, i_lcov2, i_rcov2, s_src)
        return m_site_info

####
    def update_high_confident_callset(self, sf_ori_hc, sf_all_cns, sf_new_hc):#
        m_cns={}
        m_all_td={}
        xpsr=XTEARsltParser()
        with open(sf_all_cns) as fin_cns:
            for line in fin_cns:
                fields=line.split()
                if len(fields)<2:
                    continue
                ins_chrm=fields[0]
                ins_pos=int(fields[1])
                if ins_chrm not in m_cns:
                    m_cns[ins_chrm]={}
                m_cns[ins_chrm][ins_pos]=line.rstrip()
                if xpsr.is_transduction(fields)==True:
                    if ins_chrm not in m_all_td:
                        m_all_td[ins_chrm]={}
                    m_all_td[ins_chrm][ins_pos]=line.rstrip()
####
        with open(sf_new_hc, "w") as fout_new, open(sf_ori_hc) as fin_ori:
            m_saved={}
            for line in fin_ori:
                fields=line.split()
                if len(fields) < 2:
                    continue
                ins_chrm = fields[0]
                ins_pos = int(fields[1])
                fout_new.write(m_cns[ins_chrm][ins_pos]+"\n")
                if ins_chrm not in m_saved:
                    m_saved[ins_chrm]={}
                m_saved[ins_chrm][ins_pos]=1

            for ins_chrm in m_all_td:
                for ins_pos in m_all_td[ins_chrm]:
                    if (ins_chrm in m_saved) and (ins_pos in m_saved[ins_chrm]):
                        continue
                    fout_new.write(m_all_td[ins_chrm][ins_pos]+"\n")

####
    def _cnt_support_pairs(self, m_disc):
        n_pairs = 0
        n_max_chrm = 0
        s_max_chrm = ""
        for mate_chrm in m_disc:
            n_temp = len(m_disc[mate_chrm])
            if n_temp > n_max_chrm:
                n_max_chrm = n_temp
                s_max_chrm = mate_chrm
            n_pairs += n_temp
        l_tmp = m_disc[s_max_chrm].sort()  # sort the list
        n_tmp = len(l_tmp)
        mid_pos = -1
        if n_tmp>0:
            mid_pos = l_tmp[n_tmp / 2]
        return s_max_chrm, n_max_chrm, mid_pos

####
    #1. check whether has two-side discordant reads (filter out those only has one side)
    #2. check whether has two-side clipped reads, and whether all are polyA-reads
    #3. check whether in repetitive region of the same type
    #4. check whether fall in coverage islands
    def call_high_confident_transduction(self):

        return

    #check the "cns" candidate list with the "transduction" list, if overlap, then update the source and clip/disc num
    #Note that, the insertion breakpoint may not exactly the same, so here we use "iextnd" to allow some distance diff
    def update_existing_candidate_sites(self, sf_cns_sites, m_transdct, iextnd, sf_new_sites):

        return

    def prep_representative_pos(self, m_disc):
        m_represent={}
        for ins_chrm in m_disc:
            m_represent[ins_chrm]={}
            for ins_pos in m_disc[ins_chrm]:
                m_represent[ins_chrm][ins_pos]=ins_pos
        return m_represent

    ####select full length insertions
    def pick_full_length_insertion(self, sf_candidates, ileftmost_cns):
        xintmdt = XIntemediateSites()
        m_te_candidates = xintmdt.load_in_candidate_list_str_version(sf_candidates)  #TE candidates
        l_picked = []
        for ins_chrm in m_te_candidates:
            for ins_pos in m_te_candidates[ins_chrm]:
                rcd=m_te_candidates[ins_chrm][ins_pos]
                s_lclip_cluster = rcd[17]
                s_rclip_cluster = rcd[18]
                if self._reach_5_prime_end(s_lclip_cluster, s_rclip_cluster, ileftmost_cns)==True:
                    l_picked.append((ins_chrm, ins_pos))
                    continue
                s_ldisc_cluster = rcd[19]
                s_rdisc_cluster = rcd[20]
                if self._reach_5_prime_end(s_ldisc_cluster, s_rdisc_cluster, ileftmost_cns)==True:
                    l_picked.append((ins_chrm, ins_pos))
        return l_picked

    def _reach_5_prime_end(self, s_lcluster, s_rcluster, i_leftmost):
        ll_fields = s_lcluster.split(":")
        i_lstart = int(ll_fields[0])
        i_lend = int(ll_fields[1])
        lr_fields = s_rcluster.split(":")
        i_rstart = int(lr_fields[0])
        i_rend = int(lr_fields[1])
        if i_lstart>0 and i_lstart<i_leftmost:
            return True
        if i_rstart>0 and i_rstart<i_leftmost:
            return True
        return False


####
    def construct_novel_flanks(self, l_fl_polymorphic, sf_flank, i_flank_lenth, sf_new_flank):
        xref=XReference()
        sf_polymerphic_flanks=sf_new_flank+".polymerphic_only.fa"
        xref.gnrt_flank_regions_of_polymerphic_insertions(l_fl_polymorphic, i_flank_lenth, self.sf_reference,
                                                          sf_polymerphic_flanks)
        #merge the two flanks files, and index(bwa) the new file
        cmd="cat {0} {1}".format(sf_flank, sf_polymerphic_flanks)
        self.cmd_runner.run_cmd_to_file(cmd, sf_new_flank)

    # if clipped, and the clipped part is larger than "min_clip_lth", then return True
    def _is_large_clipped(self, l_cigar, min_clip_lth):
        if len(l_cigar) < 1:  # wrong alignment
            return False
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

            ####
            if (b_left_clip == True and i_left_clip_len > min_clip_lth) or (
                            b_right_clip == True and i_right_clip_len > min_clip_lth):
                return True
        return False

####
    # for each site, collect the disc and clip reads not aligned to consensus
    def collect_transduction_clip_disc_reads(self, sf_clip_algnmt, sf_disc_algnmt, m_picked_sites, m_ins_category, 
                                             min_clip_lth, sf_clip_fa, sf_disc_fa):
        m_sites = {}
        for ins_chrm in m_picked_sites:
            for ins_pos in m_picked_sites[ins_chrm]:
                s_site = "{0}{1}{2}".format(ins_chrm, global_values.SEPERATOR, ins_pos)
                if s_site in m_ins_category[global_values.TWO_SIDE]:#skip those insertions with two side information
                    continue
                m_sites[s_site] = 1
        # collect the clipped reads
        # For clip reads, e.g.:4~11019868~R~0~11019545~98~0 [chrm, map-pos, clip_dir, rev-comp, ins_pos, cnt, sample]
        with open(sf_clip_fa, "w") as fout_clip:
            samfile = pysam.AlignmentFile(sf_clip_algnmt, "r", reference_filename=self.sf_reference)
            for algnmt in samfile.fetch():
                read_info = algnmt.query_name
                read_fields = read_info.split(global_values.SEPERATOR)
                rid_tmp = "{0}{1}{2}".format(read_fields[0], global_values.SEPERATOR, read_fields[-3])
                if rid_tmp not in m_sites:
                    continue
                read_seq = algnmt.query_sequence
                # if unmapped, then save the unmapped clipped reads
                b_save = False
                if algnmt.is_unmapped == True:
                    b_save = True
                else:
                    l_cigar = algnmt.cigar
                    b_save = self._is_large_clipped(l_cigar, min_clip_lth)

                if b_save == True:
                    fout_clip.write(">" + read_info + "\n")
                    fout_clip.write(read_seq + "\n")
            samfile.close()
        ####
        # collect the discordant reads
        # For disc reads, e.g.: read-id~0~181192671~3~181192845~0 [rid, is-first, pos, ins-chrm, ins-pos, sample]
        with open(sf_disc_fa, "w") as fout_disc:
            samfile = pysam.AlignmentFile(sf_disc_algnmt, "r", reference_filename=self.sf_reference)
            for algnmt in samfile.fetch():
                read_info = algnmt.query_name
                read_fields = read_info.split(global_values.SEPERATOR)
                rid_tmp = "{0}{1}{2}".format(read_fields[-3], global_values.SEPERATOR, read_fields[-2])
                if rid_tmp not in m_sites:
                    continue
                read_seq = algnmt.query_sequence
                # if unmapped, then save the unmapped clipped reads
                b_save = False
                if algnmt.is_unmapped == True:
                    b_save = True
                else:
                    l_cigar = algnmt.cigar
                    b_save = self._is_large_clipped(l_cigar, min_clip_lth)

                if b_save == True:
                    fout_disc.write(">" + read_info + "\n")
                    fout_disc.write(read_seq + "\n")
            samfile.close()
####
####
    # sf_clip_alignmt: the alignment on flank regions (reads not mapped (or clipped) to consensus)
    def parse_transduction_clip_algnmt(self, sf_clip_alignmt, flank_lth):
        samfile = pysam.AlignmentFile(sf_clip_alignmt, "r", reference_filename=self.sf_reference)
        # m_transduction = {}  # save the candidate transduction positions
        m_ltransduct = {}
        m_rtransduct = {}
        m_polyA = {}
        for algnmt in samfile.fetch():
            read_info = algnmt.query_name
            read_info_fields = read_info.split(global_values.SEPERATOR)

            ori_chrm = read_info_fields[0]
            ref_mpos = int(read_info_fields[1])  ##clip position on the reference
            ori_clip_flag = read_info_fields[2]
            ori_insertion_pos = int(read_info_fields[4])

            if abs(ref_mpos - ori_insertion_pos) > global_values.NEARBY_CLIP:  # only focus on the clipped reads nearby
                continue
            if algnmt.is_unmapped == True:  ####skip the unmapped reads
                continue
            # if algnmt.mapping_quality <= global_values.TRANSDCT_UNIQ_MAPQ:#this is only for transduction only
            #     continue
            hit_flank_id = algnmt.reference_name  # e.g. chrY~3443451~3449565~L1HS~0L

            ####Skip those aligned to transduction decoy sequence
            # if hit_flank_id == global_values.TD_DECOY_LINE or hit_flank_id == global_values.TD_DECOY_SVA or \
            #                 hit_flank_id == global_values.TD_DECOY_ALU:
            #     continue

            b_left = True  # left clip
            if ori_clip_flag == global_values.FLAG_RIGHT_CLIP:
                b_left = False  # right clip

            bmapped_cutoff = global_values.TD_CLIP_QLFD_RATIO
            l_cigar = algnmt.cigar
            b_clip_qualified_algned, n_map_bases = self.is_clipped_part_qualified_algnmt(l_cigar, bmapped_cutoff)
            if b_clip_qualified_algned == False:  # skip the unqualified re-aligned parts
                continue

            source_start=-1
            source_end=-1
            sourc_rc="0"
            chrm_fl_L1 =""
            flank_id_fields = hit_flank_id.split(global_values.SEPERATOR) #because here we are considering "decoy" seqs
            if len(flank_id_fields)>1:
                chrm_fl_L1 = flank_id_fields[0]
                source_start = int(flank_id_fields[1])
                source_end = int(flank_id_fields[2])
                sourc_rc = flank_id_fields[-1][0]
                if (ori_chrm==chrm_fl_L1) and (abs(ref_mpos-source_start)<global_values.MIN_POLYMORPHIC_SOURCE_DIST
                                               or abs(ref_mpos-source_end)<global_values.MIN_POLYMORPHIC_SOURCE_DIST):
                    continue
####
            clipped_seq = algnmt.query_sequence
            b_clip_part_rc = algnmt.is_reverse  # whether the aligned clip part is reverse complementary
            s_clip_seq_ck = ""
            if b_clip_part_rc == False:  # not reverse complementary
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
            else:  # clip part is reverse complementary
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
                #convert to reverse complementary seq, to make sure it's both polyA or both polyT, but not one polyA and polyT
                s_clip_seq_ck=self._gnrt_reverse_complementary(s_clip_seq_ck)

            ##if it is mapped to the left flank regions
            # here make sure it is not poly-A
            # b_polya = self.contain_poly_A_T(clipped_seq, N_MIN_A_T)  # by default, at least 5A or 5T
            b_polya = self.is_consecutive_polyA(s_clip_seq_ck)
            b_polyt = self.is_consecutive_polyT(s_clip_seq_ck)
            if b_polya == True and b_polyt==False:
                if ori_chrm not in m_polyA:
                    m_polyA[ori_chrm] = {}
                if ori_insertion_pos not in m_polyA[ori_chrm]:
                    m_polyA[ori_chrm][ori_insertion_pos] = []
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                if b_left == True:#left polyA
                    m_polyA[ori_chrm][ori_insertion_pos][0] += 1
                else:#right polyA
                    m_polyA[ori_chrm][ori_insertion_pos][1] += 1
            elif b_polyt == True and b_polya==False:
                if ori_chrm not in m_polyA:
                    m_polyA[ori_chrm] = {}
                if ori_insertion_pos not in m_polyA[ori_chrm]:
                    m_polyA[ori_chrm][ori_insertion_pos] = []
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                if b_left == True:  # left polyT
                    m_polyA[ori_chrm][ori_insertion_pos][2] += 1
                else:  # right polyT
                    m_polyA[ori_chrm][ori_insertion_pos][3] += 1
            elif b_polyt == True and b_polya==True:
                if ori_chrm not in m_polyA:
                    m_polyA[ori_chrm] = {}
                if ori_insertion_pos not in m_polyA[ori_chrm]:
                    m_polyA[ori_chrm][ori_insertion_pos] = []
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                    m_polyA[ori_chrm][ori_insertion_pos].append(0)
                if b_left == True:  # left polyT/A
                    m_polyA[ori_chrm][ori_insertion_pos][4] += 1
                else:  # right polyT/A
                    m_polyA[ori_chrm][ori_insertion_pos][5] += 1
####
            # here need to process the chrom, and keep it consistent with the final list
            if len(chrm_fl_L1) > 3 and chrm_fl_L1[:3] == "chr":  # contain
                if len(ori_chrm) <= 3 or ori_chrm[:3] != "chr":
                    chrm_fl_L1 = chrm_fl_L1[3:]  # trim the "chr"

            # calc the map position on the flank [convert to the reference genome]
            map_pos = algnmt.reference_start
            hit_ref_pos = ori_insertion_pos
            if len(flank_id_fields)>1:
                hit_ref_pos = int(flank_id_fields[2]) + map_pos
                if flank_id_fields[-1][-1] == "L":  # left-flank region
                    hit_ref_pos = int(flank_id_fields[1]) - flank_lth + map_pos

            if b_left == True:  # for left-clipped reads
                if ori_chrm not in m_ltransduct:
                    m_ltransduct[ori_chrm] = {}
                if ori_insertion_pos not in m_ltransduct[ori_chrm]:
                    m_ltransduct[ori_chrm][ori_insertion_pos] = {}
                if ref_mpos not in m_ltransduct[ori_chrm][ori_insertion_pos]:
                    m_ltransduct[ori_chrm][ori_insertion_pos][ref_mpos] = []
                s_transduct = "{0}:{1}-{2}~{3}~{4}".format(chrm_fl_L1, source_start, source_end, sourc_rc, hit_ref_pos)
                m_ltransduct[ori_chrm][ori_insertion_pos][ref_mpos].append(s_transduct)
            else:
                if ori_chrm not in m_rtransduct:
                    m_rtransduct[ori_chrm] = {}
                if ori_insertion_pos not in m_rtransduct[ori_chrm]:
                    m_rtransduct[ori_chrm][ori_insertion_pos] = {}
                if ref_mpos not in m_rtransduct[ori_chrm][ori_insertion_pos]:
                    m_rtransduct[ori_chrm][ori_insertion_pos][ref_mpos] = []
                s_transduct = "{0}:{1}-{2}~{3}~{4}".format(chrm_fl_L1, source_start, source_end, sourc_rc, hit_ref_pos)
                m_rtransduct[ori_chrm][ori_insertion_pos][ref_mpos].append(s_transduct)

        samfile.close()
        return m_ltransduct, m_rtransduct, m_polyA

    def _set_chr_map(self, chr_map):
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
    def _gnrt_reverse_complementary(self, s_seq):
        chr_map = {}
        self._set_chr_map(chr_map)
        s_rc = ""
        for s in s_seq[::-1]:
            if s not in chr_map:
                s_rc += "N"
            else:
                s_rc += chr_map[s]
        return s_rc

####
    def filter_by_clip_algnmt(self, m_ltsdct, m_rtsdct, m_polyA, n_clip_cutoff, n_polyA_cutoff):
        m_clip_cnt={}
        for ins_chrm in m_ltsdct:
            if ins_chrm not in m_clip_cnt:
                m_clip_cnt[ins_chrm] = {}
            for ins_pos in m_ltsdct[ins_chrm]:
                n_left=0
                for ref_mpos in m_ltsdct[ins_chrm][ins_pos]:
                    n_left+=len(m_ltsdct[ins_chrm][ins_pos][ref_mpos])
                if ins_pos not in m_clip_cnt[ins_chrm]:
                    m_clip_cnt[ins_chrm][ins_pos]=0
                m_clip_cnt[ins_chrm][ins_pos]+=n_left

        for ins_chrm in m_rtsdct:
            if ins_chrm not in m_clip_cnt:
                m_clip_cnt[ins_chrm] = {}
            for ins_pos in m_rtsdct[ins_chrm]:
                n_right=0
                for ref_mpos in m_rtsdct[ins_chrm][ins_pos]:
                    n_right+=len(m_rtsdct[ins_chrm][ins_pos][ref_mpos])
                if ins_pos not in m_clip_cnt[ins_chrm]:
                    m_clip_cnt[ins_chrm][ins_pos]=0
                m_clip_cnt[ins_chrm][ins_pos]+=n_right
        m_slct={}
        for ins_chrm in m_clip_cnt:
            for ins_pos in m_clip_cnt[ins_chrm]:
                n_cnt=m_clip_cnt[ins_chrm][ins_pos]
                if n_cnt<n_clip_cutoff:
                    continue
                if (ins_chrm not in m_polyA) or (ins_pos not in m_polyA[ins_chrm]):
                    continue
                n_polyA=m_polyA[ins_chrm][ins_pos][0]+m_polyA[ins_chrm][ins_pos][1]+\
                        m_polyA[ins_chrm][ins_pos][2] + m_polyA[ins_chrm][ins_pos][3] +\
                        m_polyA[ins_chrm][ins_pos][4] + m_polyA[ins_chrm][ins_pos][5]
                if n_polyA < n_polyA_cutoff:
                    continue
                if ins_chrm not in m_slct:
                    m_slct[ins_chrm]={}
                m_slct[ins_chrm][ins_pos]=(n_cnt, n_polyA)
        return m_slct
####
####
    # sf_clip_alignmt: the alignment on flank regions (reads not mapped (or clipped) to consensus)
    def parse_clip_algnmt_rescued(self, sf_clip_alignmt, flank_lth):
        samfile = pysam.AlignmentFile(sf_clip_alignmt, "r", reference_filename=self.sf_reference)
        m_l_n_source_cand = {}  # candidate whose clipped parts well aligned to several flanking regions
        m_r_n_source_cand = {}
        for algnmt in samfile.fetch():
            read_info = algnmt.query_name
            read_info_fields = read_info.split(global_values.SEPERATOR)

            ori_chrm = read_info_fields[0]
            ref_mpos = int(read_info_fields[1])  ##clip position on the reference
            ori_clip_flag = read_info_fields[2]
            ori_insertion_pos = int(read_info_fields[4])

            if abs(ref_mpos - ori_insertion_pos) > global_values.NEARBY_CLIP:  # only focus on the clipped reads nearby
                continue
            if algnmt.is_unmapped == True:  ####skip the unmapped reads
                continue
            if algnmt.mapping_quality >= global_values.MINIMAL_TRANSDUCT_MAPQ:#should be multiple mapped
                continue

            hit_flank_id = algnmt.reference_name  # e.g. chrY~3443451~3449565~L1HS~0L

            hit_flank_fields=hit_flank_id.split(global_values.SEPERATOR)
            if len(hit_flank_fields)<2 or hit_flank_fields[-2]==global_values.S_POLYMORPHIC:
                continue

            ####Skip those aligned to transduction decoy sequence
            if hit_flank_id == global_values.TD_DECOY_LINE or hit_flank_id == global_values.TD_DECOY_SVA or \
                            hit_flank_id == global_values.TD_DECOY_ALU:
                continue

            b_left = True  # left clip
            if ori_clip_flag == global_values.FLAG_RIGHT_CLIP:
                b_left = False  # right clip

            bmapped_cutoff = global_values.TD_CLIP_QLFD_RATIO #by default 0.85
            l_cigar = algnmt.cigar
            b_clip_qualified_algned, n_map_bases = self.is_clipped_part_qualified_algnmt(l_cigar, bmapped_cutoff)
            if b_clip_qualified_algned == False:  # skip the unqualified re-aligned parts
                continue

            flank_id_fields = hit_flank_id.split(global_values.SEPERATOR)
            chrm_fl_L1 = flank_id_fields[0]
            source_start = int(flank_id_fields[1])
            source_end = int(flank_id_fields[2])
            sourc_rc = flank_id_fields[-1][0]

            if (ori_chrm == chrm_fl_L1) and (
                    abs(ref_mpos - source_start) < global_values.MIN_POLYMORPHIC_SOURCE_DIST
            or abs(ref_mpos - source_end) < global_values.MIN_POLYMORPHIC_SOURCE_DIST):
                continue

            # here need to process the chrom, and keep it consistent with the final list
            if len(chrm_fl_L1) > 3 and chrm_fl_L1[:3] == "chr":  # contain
                if len(ori_chrm) <= 3 or ori_chrm[:3] != "chr":
                    chrm_fl_L1 = chrm_fl_L1[3:]  # trim the "chr"

            # calc the map position on the flank [convert to the reference genome]
            map_pos = algnmt.reference_start
            dist_from_rep = map_pos
            if flank_id_fields[-1][-1] == "L":  # left-flank region
                dist_from_rep = flank_lth - map_pos

            if b_left == True:  # for left-clipped reads
                if ori_chrm not in m_l_n_source_cand:
                    m_l_n_source_cand[ori_chrm] = {}
                if ori_insertion_pos not in m_l_n_source_cand[ori_chrm]:
                    m_l_n_source_cand[ori_chrm][ori_insertion_pos] = []
                m_l_n_source_cand[ori_chrm][ori_insertion_pos].append(dist_from_rep)
            else:
                if ori_chrm not in m_r_n_source_cand:
                    m_r_n_source_cand[ori_chrm] = {}
                if ori_insertion_pos not in m_r_n_source_cand[ori_chrm]:
                    m_r_n_source_cand[ori_chrm][ori_insertion_pos] = []
                m_r_n_source_cand[ori_chrm][ori_insertion_pos].append(dist_from_rep)
        samfile.close()
        return m_l_n_source_cand, m_r_n_source_cand

####
    def re_selct_clip_reads(self, sf_fq, m_transdct, sf_out):
        with pysam.FastxFile(sf_fq) as fin, open(sf_out, "w") as fout:
            for entry in fin:
                sid=entry.name
                s_seq=entry.sequence
                read_info_fields = sid.split(global_values.SEPERATOR)

                ori_chrm = read_info_fields[0]
                ori_insertion_pos = int(read_info_fields[4])
                if (ori_chrm not in m_transdct) or (ori_insertion_pos not in m_transdct[ori_chrm]):
                    continue
                fout.write(">"+sid+"\n")
                fout.write(s_seq+"\n")

####
    def re_select_disc_reads(self, sf_disc_sam, m_transdct, sf_out):
        with open(sf_out, "w") as fout:
            samfile = pysam.AlignmentFile(sf_disc_sam, "r", reference_filename=self.sf_reference)
            for algnmt in samfile.fetch():
                read_info = algnmt.query_name
                read_info_fields = read_info.split(global_values.SEPERATOR)
                anchor_map_pos = int(read_info_fields[-4])
                ins_chrm = read_info_fields[-3]
                ins_pos = int(read_info_fields[-2])
                sample_id = read_info_fields[-1]
                s_seq=algnmt.query_sequence
                if (ins_chrm in m_transdct) and (ins_pos in m_transdct[ins_chrm]):
                    fout.write(">"+read_info+"\n")
                    fout.write(s_seq + "\n")


    ####Parse the alignment to the FL-L1 flank regions, and call out the transductions.
    def parse_transduction_disc_algnmt(self, sf_disc_alignmt, flank_lth, n_half_cutoff, i_rep_type=-1):
        samfile = pysam.AlignmentFile(sf_disc_alignmt, "r", reference_filename=self.sf_reference)
        m_transduction = {}  # save the candidate transduction positions
        m_raw_td_src={} #save all the source and mapq for each aligned reads
####To-do-list:
        #if this is an orphan transduction, then should have left and right discordant form two cluster on same source
        m_l_disc_transdct={} #for left discordant
        m_r_disc_transdct={} #for right discordant
        m_Alu={}
        m_L1={}
        m_SVA={}
        for algnmt in samfile.fetch():
            read_info = algnmt.query_name
            read_info_fields = read_info.split(global_values.SEPERATOR)
            anchor_map_pos = int(read_info_fields[-4])
            ins_chrm = read_info_fields[-3]
            ins_pos = int(read_info_fields[-2])
            sample_id = read_info_fields[-1]

            if algnmt.is_unmapped == True:####skip the unmapped reads
                continue
####
            hit_flank_id = algnmt.reference_name  # e.g. chrY~3443451~3449565~L1HSL
            ####Hard code here !!!!
            l_cigar = algnmt.cigar
            f_mapped_cutoff = global_values.F_MIN_TRSDCT_DISC_MAP_RATION
            b_clip_qualified_algned, n_map_bases = self.is_clipped_part_qualified_algnmt(l_cigar, f_mapped_cutoff)
            if b_clip_qualified_algned == False:  # skip the unqualified re-aligned parts
                continue
            ####Skip those aligned to transduction decoy sequence
            if (global_values.TD_DECOY_LINE in hit_flank_id) or \
                    (global_values.TD_DECOY_SVA in hit_flank_id) or (global_values.TD_DECOY_ALU in hit_flank_id)\
                    or (global_values.TD_DECOY_HERV in hit_flank_id):
                if global_values.TD_DECOY_ALU in hit_flank_id:
                    if ins_chrm not in m_Alu:
                        m_Alu[ins_chrm]={}
                    if ins_pos not in m_Alu[ins_chrm]:
                        m_Alu[ins_chrm][ins_pos]=0
                    m_Alu[ins_chrm][ins_pos] += 1
                if global_values.TD_DECOY_SVA in hit_flank_id:
                    if ins_chrm not in m_SVA:
                        m_SVA[ins_chrm]={}
                    if ins_pos not in m_SVA[ins_chrm]:
                        m_SVA[ins_chrm][ins_pos]=0
                    m_SVA[ins_chrm][ins_pos] += 1
                if global_values.TD_DECOY_LINE in hit_flank_id:
                    if ins_chrm not in m_L1:
                        m_L1[ins_chrm]={}
                    if ins_pos not in m_L1[ins_chrm]:
                        m_L1[ins_chrm][ins_pos]=0
                    m_L1[ins_chrm][ins_pos] += 1
                continue

            #check the alternative hits
            b_xa_hit, n_tmp_Alu, n_tmp_L1, n_tmp_SVA = self.check_algnmt_tag_decoy(algnmt, f_mapped_cutoff)
            if b_xa_hit==True:
                if n_tmp_Alu>0:
                    if ins_chrm not in m_Alu:
                        m_Alu[ins_chrm]={}
                    if ins_pos not in m_Alu[ins_chrm]:
                        m_Alu[ins_chrm][ins_pos]=0
                    m_Alu[ins_chrm][ins_pos] += 1
                if n_tmp_L1 > 0:
                    if ins_chrm not in m_L1:
                        m_L1[ins_chrm]={}
                    if ins_pos not in m_L1[ins_chrm]:
                        m_L1[ins_chrm][ins_pos]=0
                    m_L1[ins_chrm][ins_pos] += 1
                if n_tmp_SVA > 0:
                    if ins_chrm not in m_SVA:
                        m_SVA[ins_chrm]={}
                    if ins_pos not in m_SVA[ins_chrm]:
                        m_SVA[ins_chrm][ins_pos]=0
                    m_SVA[ins_chrm][ins_pos] += 1

            map_pos = algnmt.reference_start
            flank_id_fields = hit_flank_id.split(global_values.SEPERATOR) #e.g. 20~32719617~32721485~SVA_D~0R
            if len(flank_id_fields)<3:
                print("[Error]: Wrong flanking/decoy id: {0}".format(hit_flank_id))
                continue
            chrm_fl_L1 = flank_id_fields[0]
            source_start = int(flank_id_fields[1])
            source_end = int(flank_id_fields[2])
            sourc_rc = flank_id_fields[-1][0]#0 or 1
            # here need to process the chrom, and keep it consistent with the final list
            if len(chrm_fl_L1) > 3 and chrm_fl_L1[:3] == "chr":  # contain
                if len(ins_chrm) <= 3 or ins_chrm[:3] != "chr":  # keep it same as the ins_chrm
                    chrm_fl_L1 = chrm_fl_L1[3:]  # trim the "chr"

            hit_ref_pos = int(flank_id_fields[2]) + map_pos
            dist_from_rep=map_pos
            if flank_id_fields[-1][-1] == "L":  # left-flank region
                hit_ref_pos = int(flank_id_fields[1]) - flank_lth + map_pos
                dist_from_rep=flank_lth-map_pos

            ####this is to rule out those polymerphic Fl-L1 cases, which aligned to themselves' flank regions
            if (ins_chrm==chrm_fl_L1) and (abs(ins_pos-source_start)<global_values.MIN_POLYMORPHIC_SOURCE_DIST
                                           or abs(ins_pos-source_end)<global_values.MIN_POLYMORPHIC_SOURCE_DIST):
                print("[DISC-TD-STEP:] Filter out {0}:{1}, aligned to itself flanking regions".format(ins_chrm, ins_pos))
                continue
            s_source = "{0}:{1}-{2}~{3}".format(chrm_fl_L1, source_start, source_end, sourc_rc)

            if algnmt.mapping_quality <= global_values.TRANSDCT_UNIQ_MAPQ:#this is only for transduction only
                if ins_chrm not in m_raw_td_src: #save the non unique disc counts
                    m_raw_td_src[ins_chrm] = {}
                if ins_pos not in m_raw_td_src[ins_chrm]:
                    m_raw_td_src[ins_chrm][ins_pos] = {}
                if s_source not in m_raw_td_src[ins_chrm][ins_pos]:
                    m_raw_td_src[ins_chrm][ins_pos][s_source] = 0
                m_raw_td_src[ins_chrm][ins_pos][s_source]+=1
                continue

            if ins_chrm not in m_transduction:
                m_transduction[ins_chrm] = {}
            if ins_pos not in m_transduction[ins_chrm]:
                m_transduction[ins_chrm][ins_pos] = {}
            if s_source not in m_transduction[ins_chrm][ins_pos]:
                m_transduction[ins_chrm][ins_pos][s_source] = []
            m_transduction[ins_chrm][ins_pos][s_source].append((hit_ref_pos, anchor_map_pos, dist_from_rep))
        samfile.close()

        m_decoy_slct=self._chk_decoy_cns_cnt(m_transduction, m_Alu, m_L1, m_SVA, n_half_cutoff*2, i_rep_type)
        m_trsd_picked, m_rscued_no_use=self._pick_trsdct_rescued(m_decoy_slct, n_half_cutoff, m_raw_td_src,
                                                                 self.f_min_uniq_ratio)
        m_orphan = self._slct_orphan_transduction(m_decoy_slct, m_trsd_picked, n_half_cutoff)
        return m_trsd_picked, m_orphan
####

####
    ####check algnmt tag whether contain decoy seq
    def check_algnmt_tag_decoy(self, alignment, f_mapped_cutoff):
        n_Alu=0
        n_L1=0
        n_SVA=0
        b_hit=False
        if alignment.has_tag('XA') == True:
            #in format: 1~81404889~81410942~L1HS~1R,+1220,101M,2;5~77881127~77881127~polymerphic~0L,-1960,101M,3;
            s_alt_algn = alignment.get_tag('XA')
            s_alt_fields=s_alt_algn.split(";")
            #check each field
            for s_rcd in s_alt_fields:
                rcd_fields = s_rcd.split(",")
                if len(rcd_fields) <= 1:
                    continue
                s_cigar = rcd_fields[2]
                if global_values.TD_DECOY_SVA in rcd_fields[0]:
                    n_map, n_all = self.parse_s_cigar(s_cigar)
                    if float(n_map)/float(n_all)>=f_mapped_cutoff:
                        b_hit=True
                        n_SVA+=1
                elif global_values.TD_DECOY_LINE in rcd_fields[0]:
                    n_map, n_all = self.parse_s_cigar(s_cigar)
                    if float(n_map)/float(n_all)>=f_mapped_cutoff:
                        b_hit=True
                        n_L1+=1
                elif global_values.TD_DECOY_ALU in rcd_fields[0]:
                    n_map, n_all = self.parse_s_cigar(s_cigar)
                    if float(n_map)/float(n_all)>=f_mapped_cutoff:
                        b_hit=True
                        n_Alu+=1
        return b_hit, n_Alu, n_L1, n_SVA

    def parse_s_cigar(self, s_cigar):
        s_len=""
        n_map=0
        n_all=0
        for ch in s_cigar:
            if ch>="0" and ch<="9":
                s_len+=ch
            else:
                tmp_len=int(s_len)
                if ch=="M":
                    n_map+=tmp_len
                n_all+=tmp_len
                s_len=""
        return n_map, n_all

    ###
    def _chk_decoy_cns_cnt(self, m_trsdct, m_Alu, m_L1, m_SVA, n_cutoff, i_rep_type):
        if i_rep_type<0:
            return m_trsdct
        m_slct={}
        for ins_chrm in m_trsdct:
            for ins_pos in m_trsdct[ins_chrm]:
                b_slct=True
                n_Alu=0
                if (ins_chrm in m_Alu) and (ins_pos in m_Alu[ins_chrm]):
                    n_Alu=m_Alu[ins_chrm][ins_pos]
                n_L1=0
                if (ins_chrm in m_L1) and (ins_pos in m_L1[ins_chrm]):
                    n_L1=m_L1[ins_chrm][ins_pos]
                n_SVA=0
                if (ins_chrm in m_SVA) and (ins_pos in m_SVA[ins_chrm]):
                    n_SVA=m_SVA[ins_chrm][ins_pos]
                if i_rep_type & 1 != 0:#for L1
                    if n_Alu>=n_cutoff:
                        b_slct=False
                    if n_SVA>=n_cutoff:
                        b_slct=False
                elif i_rep_type & 4 !=0:#for SVA
                    if n_Alu>=n_cutoff:
                        b_slct=False
                    if n_L1>=n_cutoff:
                        b_slct=False
                if b_slct==True:
                    if ins_chrm not in m_slct:
                        m_slct[ins_chrm]={}
                    m_slct[ins_chrm][ins_pos]=m_trsdct[ins_chrm][ins_pos]
        return m_slct
####
    def _pick_trsdct_rescued(self, m_transduction, n_disc_cutoff, m_raw_td_src, f_min_ratio):
        m_trsd_picked = {}
        m_n_source_picked = {}  # save those total number pass, but have several sources
        # for each candidate, it may link to several sources, here select the one with largest # of disc reads support
        for ins_chrm in m_transduction:
            for ins_pos in m_transduction[ins_chrm]:
                max_cnt = 0
                max_source = ""
                n_tmp_all_cnt = 0
                for tmp_source in m_transduction[ins_chrm][ins_pos]:
                    tmp_cnt = len(m_transduction[ins_chrm][ins_pos][tmp_source]) #from the same source
                    n_tmp_all_cnt += tmp_cnt
                    if tmp_cnt > max_cnt:
                        max_cnt = tmp_cnt
                        max_source = tmp_source
                # first, the total number of discordant should pass the threshold (here require half the discordant)
                if n_tmp_all_cnt < n_disc_cutoff:
                    print("[DISC-TD-STEP:] Filter out {0}:{1}, no enough disc support!".format(ins_chrm, ins_pos))
                    continue

                b_trsdct = False
                b_normal = False
                f_tmp_ratio = float(max_cnt) / float(n_tmp_all_cnt)
                # dominant by max source, thus view as candidate transduction
                n_non_unique=0
                if ((ins_chrm in m_raw_td_src) and (ins_pos in m_raw_td_src[ins_chrm])
                    and (max_source in m_raw_td_src[ins_chrm][ins_pos])):
                    n_non_unique = m_raw_td_src[ins_chrm][ins_pos][max_source]
                if (max_cnt >= n_disc_cutoff) and (f_tmp_ratio >= global_values.TRANSDCT_MULTI_SOURCE_MIN_RATIO) \
                        and (float(max_cnt)/float(max_cnt+n_non_unique) > f_min_ratio):
                        b_trsdct = True
                else:  # have seveal sources, then view as normal (in some cases like SVA, the annotation is not perfect, will cause this)
                    print("[DISC-TD-STEP:] Filter out {0}:{1}, ratio is low!".format(ins_chrm, ins_pos))
                    b_normal = True

                if b_trsdct == True:
                    if ins_chrm not in m_trsd_picked:
                        m_trsd_picked[ins_chrm] = {}
                    l_pos = []
                    for tmp_record in m_transduction[ins_chrm][ins_pos][max_source]:
                        l_pos.append(tmp_record)  # each record is (hit_ref_pos, anchor_pos, dist_from_rep)
                    m_trsd_picked[ins_chrm][ins_pos] = (max_source, l_pos, max_cnt)
                elif b_normal == True:
                    if ins_chrm not in m_n_source_picked:
                        m_n_source_picked[ins_chrm] = {}
                        l_pos = []
                        for tmp_src in m_transduction[ins_chrm][ins_pos]:
                            for tmp_record in m_transduction[ins_chrm][ins_pos][tmp_src]:
                                l_pos.append(tmp_record[-1])  # save dist_from_rep only
                        m_n_source_picked[ins_chrm][ins_pos] = l_pos
        return m_trsd_picked, m_n_source_picked
####
    ####
    def _slct_orphan_transduction(self, m_transduction, m_slcted, n_half_cutoff):
        m_orphan_transduct={}
        for ins_chrm in m_transduction:
            for ins_pos in m_transduction[ins_chrm]:
                if (ins_chrm not in m_slcted) or (ins_pos not in m_slcted[ins_chrm]):
                    continue
                n_left=0
                n_right=0
                tmp_source=m_slcted[ins_chrm][ins_pos][0]
                for rcd in m_transduction[ins_chrm][ins_pos][tmp_source]:
                    #(hit_ref_pos, anchor_map_pos, dist_from_rep)
                    anchor_pos=int(rcd[1])
                    if (anchor_pos+5) < ins_pos:
                        n_left+=1
                    else:
                        n_right+=1
                if (n_left >= n_half_cutoff) and (n_right >= n_half_cutoff):#here miss those orphan promoted SV case!!!
                    if ins_chrm not in m_orphan_transduct:
                        m_orphan_transduct[ins_chrm]={}
                    m_orphan_transduct[ins_chrm][ins_pos]=(tmp_source, n_left, n_right)
        return m_orphan_transduct

####
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
                if (i_left_clip_len > global_values.MAX_CLIP_CLIP_LEN) and (i_right_clip_len >
                                                                                global_values.MAX_CLIP_CLIP_LEN):
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

    def is_consecutive_polyA_T(self, seq):
        if ("AAAAA" in seq) or ("TTTTT" in seq) or ("AATAA" in seq) or ("TTATT" in seq):
            return True
        else:
            return False

    def is_consecutive_polyA(self, seq):
        if (("AAAAA" in seq) or ("AATAA" in seq)):
            return True
        else:
            return False

    def is_consecutive_polyT(self, seq):
        if (("TTTTT" in seq) or ("TTATT" in seq)):
            return True
        else:
            return False
####
    # call out the candidate transductions only use the disc info (m_disc_transdct)
    # here still consdier the left/right anchor, so count seperately for left and right disc reads
    def call_out_candidate_transduct(self, m_repsnt_pos, m_disc_transdct, icorcord, ratio, m_clip_slct,
                                     m_disc_polyA, m_orphan):####
        m_transduction = {}
        ck_cluster=ClusterChecker()
        for ins_chrm in m_repsnt_pos:
            for ins_pos in m_repsnt_pos[ins_chrm]:
                b_clip_polyA=False
                b_disc_polyA=False

                if (ins_chrm not in m_clip_slct) or (ins_pos not in m_clip_slct[ins_chrm]):
                    continue
                if (ins_chrm in m_disc_polyA) and (ins_pos in m_disc_polyA[ins_chrm]):
                    b_disc_polyA=True
                if b_disc_polyA==False:
                    continue

                clip_pos = m_repsnt_pos[ins_chrm][ins_pos]
                b_l_trsdct = False
                b_r_trsdct = False
                trsdct_l = -1
                trsdct_r = -1
                n_disc_trsdct = 0
                if (ins_chrm in m_disc_transdct) and (ins_pos in m_disc_transdct[ins_chrm]):
                    trsdct_source, l_trsdct_pos, n_unique = m_disc_transdct[ins_chrm][ins_pos]
                    l_l_trsdct_pos = []
                    l_r_trsdct_pos = []
                    for (hit_ref_pos, anchor_pos, dist_from_rep) in l_trsdct_pos:
                        if anchor_pos < clip_pos:
                            l_l_trsdct_pos.append(hit_ref_pos)
                        else:
                            l_r_trsdct_pos.append(hit_ref_pos)
                        if len(l_l_trsdct_pos) > len(l_r_trsdct_pos):
                            b_l_trsdct, trsdct_l, trsdct_r = ck_cluster._is_disc_cluster(l_l_trsdct_pos, icorcord, ratio)
                            n_disc_trsdct = len(l_l_trsdct_pos)
                        else:
                            b_r_trsdct, trsdct_l, trsdct_r = ck_cluster._is_disc_cluster(l_r_trsdct_pos, icorcord, ratio)
                            n_disc_trsdct = len(l_r_trsdct_pos)
                    if b_l_trsdct == True or b_r_trsdct == True:
                        if ins_chrm not in m_transduction:
                            m_transduction[ins_chrm] = {}
                        trsdct_info = "{0}~{1}-{2}".format(trsdct_source, trsdct_l, trsdct_r)
                        m_transduction[ins_chrm][ins_pos] = (b_l_trsdct, b_r_trsdct, n_disc_trsdct, trsdct_info)

        #check orphan transduction
        for ins_chrm in m_clip_slct:
            for ins_pos in m_clip_slct[ins_chrm]:
                if (ins_chrm in m_orphan) and (ins_pos in m_orphan[ins_chrm]):
                    if ins_chrm not in m_transduction:
                        m_transduction[ins_chrm] = {}
                    s_source=m_orphan[ins_chrm][ins_pos][0]
                    trsdct_info = "{0}~orphan".format(s_source)
                    n_disc_trsdct=m_orphan[ins_chrm][ins_pos][1]+m_orphan[ins_chrm][ins_pos][2]
                    m_transduction[ins_chrm][ins_pos] = (False, True, n_disc_trsdct, trsdct_info)
        return m_transduction
####
####
    # In this version, the transduction candidates are called out only by discordant reads
    # then, in this function, for each candidate, extract the related information
    def _extract_transduct_info(self, m_list, m_transduct, m_lclip_transduct, m_rclip_transduct, m_td_polyA, BIN_SIZE):
        m_info = {}
        ckcluster = ClusterChecker()
        for ins_chrm in m_list:
            for ins_pos in m_list[ins_chrm]:
                if (ins_chrm not in m_transduct) or (ins_pos not in m_transduct[ins_chrm]):
                    continue

                record = m_transduct[ins_chrm][ins_pos]
                b_l_trsdct = record[0]
                n_disc_trsdct = record[2]
                trsdct_info = record[3]

                # for the clip information
                n_clip_trsdct = 0
                peak_ref_clip_pos = -1
                if b_l_trsdct == True:  # left-transduction
                    if (ins_chrm in m_lclip_transduct) and (ins_pos in m_lclip_transduct[ins_chrm]):
                        # m_lclip_pos = m_lclip_transduct[ins_chrm][ins_pos]
                        l1_pos, l1_nbr, l1_acm, l2p, l2n, l2a = ckcluster.find_first_second_peak(m_lclip_transduct,
                                                                                            ins_chrm,
                                                                                            ins_pos, BIN_SIZE)
                        n_clip_trsdct = l1_acm
                        peak_ref_clip_pos = l1_pos
                else:
                    if (ins_chrm in m_rclip_transduct) and (ins_pos in m_rclip_transduct[ins_chrm]):
                        # m_rclip_pos = m_rclip_transduct[ins_chrm][ins_pos]
                        l1_pos, l1_nbr, l1_acm, l2p, l2n, l2a = ckcluster.find_first_second_peak(m_rclip_transduct,
                                                                                            ins_chrm,
                                                                                            ins_pos, BIN_SIZE)
                        n_clip_trsdct = l1_acm
                        peak_ref_clip_pos = l1_pos

                # for the poly-A
                # number of polyA reads
                n_polyA = 0
                if (ins_chrm in m_td_polyA) and (ins_pos in m_td_polyA[ins_chrm]):
                    if b_l_trsdct == True:
                        n_polyA = m_td_polyA[ins_chrm][ins_pos][0]
                    else:
                        n_polyA = m_td_polyA[ins_chrm][ins_pos][1]

                # save the information
                if ins_chrm not in m_info:
                    m_info[ins_chrm] = {}
                rcd_info = (b_l_trsdct, n_clip_trsdct, peak_ref_clip_pos, n_disc_trsdct, n_polyA)
                m_info[ins_chrm][ins_pos] = (trsdct_info, rcd_info)
        return m_info
####
    ####
    def _load_in_representative_sites(self, sf_candidate_list):
        m_list = {}
        with open(sf_candidate_list) as fin_candidate_sites:
            for line in fin_candidate_sites:
                fields = line.split()
                if len(fields) < 2:
                    print(fields, "does not have enough fields")
                    continue
                chrm = fields[0]
                pos = int(fields[1])
                if chrm not in m_list:
                    m_list[chrm] = {}
                m_list[chrm][pos]=pos
        return m_list
    ####
