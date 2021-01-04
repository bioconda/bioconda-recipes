##11/22/2017
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

import os
import sys
import pysam
from subprocess import *
from multiprocessing import Pool
from clip_read import ClipReadInfo
from x_annotation import *
from x_alignments import *
from x_intermediate_sites import *
from bwa_align import *
from global_values import *
from cmd_runner import *

class TE_Multi_Locator():
    def __init__(self, sf_list, s_working_folder, n_jobs, sf_ref):
        self.sf_list = sf_list
        self.working_folder = s_working_folder
        self.n_jobs = int(n_jobs)
        self.sf_ref=sf_ref ##reference genome

    def get_clip_part_realignment_for_list(self, sf_candidate_sites):
        m_sites={}
        with open(sf_candidate_sites) as fin_sites:
            for line in fin_sites:
                fields=line.split()
                chrm=fields[0]
                pos=int(fields[1])
                if chrm not in m_sites:
                    m_sites[chrm]={}
                m_sites[chrm][pos]=line ###here save the chrom and position, also the other informations

        #for each bam in the list
        with open(self.sf_list) as fin_bam_list:
            for line in fin_bam_list:  ###for each bam file
                fields=line.split()
                sf_ori_bam = fields[0]
                if len(sf_ori_bam) <= 1:
                    continue

    def collect_all_clipped_from_multiple_alignmts(self, sf_annotation, b_se, s_clip_wfolder, wfolder_pub_clip):
        with open(self.sf_list) as fin_bam_list:
            for line in fin_bam_list:  ###for each bam file
                fields = line.split()
                sf_ori_bam = fields[0]
                if len(sf_ori_bam) <= 1:
                    continue

                caller = TELocator(sf_ori_bam, sf_ori_bam, self.working_folder, self.n_jobs, self.sf_ref)
                caller.collect_all_clipped_reads_only(sf_annotation, b_se, s_clip_wfolder, wfolder_pub_clip)
####

    ####
    def call_TEI_candidate_sites_from_multiple_alignmts(self, sf_annotation, sf_rep_cns, sf_ref, b_se, cutoff_left_clip,
                                                        cutoff_right_clip, cutoff_clip_mate_in_rep, b_mosaic,
                                                        sf_clip_folder, b_force, max_cov, sf_out):
        cnt = 0
        s_sample_bam = ""
        b_set = False
        with open(self.sf_list) as fin_bam_list:
            i_idx_bam=0#indicates which bam this is
            for line in fin_bam_list:  ###for each bam file
                fields=line.split()
                if len(fields)<2:
                    print("Error input bam file {0}!!!".format(line.rstrip()))
                    continue
                sf_ori_bam = fields[0]
                s_read_type=fields[1].rstrip()
                print("Input bam {0} is sequenced from {1} platform!".format(sf_ori_bam, s_read_type))
                if global_values.X10 == s_read_type:###for 10X, we use a larger cutoff, as more clipped reads
                    print("10X bam! Set the initial cutoff as {0}".format(global_values.INITIAL_MIN_CLIP_CUTOFF_X10))
                    global_values.set_initial_min_clip_cutoff(global_values.INITIAL_MIN_CLIP_CUTOFF_X10)
                else:
                    if cutoff_left_clip<=2 and b_mosaic==True:#
                        print("Clip cutoff is small (<=2) , we are using 1 for initial cutoff")
                        global_values.set_initial_min_clip_cutoff(1)#for low coverage data, set this to 1
                    else:
                        global_values.set_initial_min_clip_cutoff(global_values.INITIAL_MIN_CLIP_CUTOFF_ILLUMINA)

                if len(sf_ori_bam) <= 1:
                    continue
                if b_set == False:
                    s_sample_bam = sf_ori_bam
                    b_set = True

                b_cutoff = True
                cutoff_hit_rep_copy=global_values.INITIAL_MIN_CLIP_CUTOFF

                # view the barcode bam as normal illumina bam
                # for each alignment, has one output
                sf_out_tmp = self.working_folder + global_values.CLIP_TMP + '{0}'.format(cnt)
                cnt += 1

                caller = TELocator(sf_ori_bam, sf_ori_bam, self.working_folder, self.n_jobs, self.sf_ref)
                # s_working_folder + global_values.CLIP_FOLDER + "/"+sf_bam_name + CLIP_FQ_SUFFIX
                sf_new_pub=""
                if len(sf_clip_folder)==0 or sf_clip_folder==None:
                    print("public folder is null!!!!")
                    continue
                if sf_clip_folder[-1]=="/":
                    sf_new_pub=sf_clip_folder+"{0}/".format(i_idx_bam)
                else:
                    sf_new_pub = sf_clip_folder + "/{0}/".format(i_idx_bam)
                caller.call_TEI_candidate_sites_from_clip_reads_v2(sf_annotation, sf_rep_cns, sf_ref, b_se,
                                                                   cutoff_hit_rep_copy, cutoff_hit_rep_copy, b_cutoff,
                                                                   sf_new_pub, i_idx_bam, b_force, max_cov, sf_out_tmp)
                i_idx_bam+=1
####
        # get all the chromsomes names
        bam_info = BamInfo(s_sample_bam, self.sf_ref)
        b_with_chr = bam_info.is_chrm_contain_chr()
        m_chrms = bam_info.get_all_reference_names()

        xfilter = XIntemediateSites()
        xchrom=XChromosome()
        sf_out_merged = sf_out + "_tmp"
        with open(sf_out_merged, "w") as fout_sites_merged, open(sf_out, "w") as fout_sites:
            for chrm in m_chrms:  # write out chrm by chrm to save memory
                if xchrom.is_decoy_contig_chrms(chrm) == True:  ###filter out decoy and other contigs
                    continue
                m_sites_chrm = {}
                for i in range(cnt):
                    sf_tmp = self.working_folder + global_values.CLIP_TMP + "{0}".format(i)
                    if os.path.isfile(sf_tmp) == False:
                        print("Errors happen, file {0} doens't exist!".format(sf_tmp))
                        continue
                    with open(sf_tmp) as fin_tmp:
                        for line in fin_tmp:
                            fields = line.split()
                            tmp_chrm = bam_info.process_chrm_name(fields[0], b_with_chr)
                            if tmp_chrm != chrm:
                                continue
                            pos = int(fields[1])

                            if pos not in m_sites_chrm:
                                m_sites_chrm[pos] = []
                                for value in fields[2:]:
                                    m_sites_chrm[pos].append(int(value))
                            else:
                                i_value = 0
                                for value in fields[2:]:
                                    ###sum (left-realign, right-realign, mate_in_rep)
                                    m_sites_chrm[pos][i_value] += int(value)
                                    i_value += 1

                for pos in m_sites_chrm:
                    lth = len(m_sites_chrm[pos])
                    fout_sites_merged.write(chrm + "\t" + str(pos) + "\t")
                    for i in range(lth):
                        s_feature = str(m_sites_chrm[pos][i])
                        fout_sites_merged.write(s_feature + "\t")
                    fout_sites_merged.write("\n")

                #this will use the number of clipped reads within the nearby region
                m_sites_chrm_filtered = xfilter.parse_sites_with_clip_cutoff_for_chrm(m_sites_chrm, cutoff_left_clip,
                                                                                      cutoff_right_clip,
                                                                                      cutoff_clip_mate_in_rep)
                for pos in m_sites_chrm_filtered:
                    lth = len(m_sites_chrm_filtered[pos])
                    fout_sites.write(chrm + "\t" + str(pos) + "\t")
                    for i in range(lth):
                        s_feature = str(m_sites_chrm_filtered[pos][i])
                        fout_sites.write(s_feature + "\t")
                    fout_sites.write("\n")

                    # # sort the list
                    # sf_out_merged_sorted = sf_out + "_tmp.sorted"
                    # cmd = "sort -k1,1 -k2,2n {0} > {1}".format(sf_out_merged, sf_out_merged_sorted)
                    # Popen(cmd, shell=True, stdout=PIPE).communicate()
                    #
                    # sf_peak_events = sf_out + ".peak_events.txt"
                    # self.chain_regions(sf_out_merged_sorted, global_values.NEARBY_REGION, cutoff_left_clip, cutoff_right_clip,
                    #                    cutoff_clip_mate_in_rep, sf_out, sf_peak_events)

####
    #this version is designed for mosaic calling only, which:
    #1. will count the polyA reads for each site
    #2. using polyA as a cutoff to filter out sites
    def call_TEI_candidate_sites_from_multiple_alignmts_mosaic(self, sf_annotation, sf_rep_cns, sf_ref, b_se,
                                                        cutoff_left_clip,
                                                        cutoff_right_clip, cutoff_clip_mate_in_rep, cutoff_polyA,
                                                        sf_clip_folder,
                                                        b_force, max_cov, sf_out):
        cnt = 0
        s_sample_bam = ""
        b_set = False
        with open(self.sf_list) as fin_bam_list:
            i_idx_bam = 0  # indicates which bam this is
            for line in fin_bam_list:  ###for each bam file
                fields = line.split()
                if len(fields) < 2:
                    print("Error input bam file {0}!!!".format(line.rstrip()))
                    continue
                sf_ori_bam = fields[0]
                s_read_type = fields[1].rstrip()
                print("Input bam {0} is sequenced from {1} platform!".format(sf_ori_bam, s_read_type))
                if global_values.X10 == s_read_type:  ###for 10X, we use a larger cutoff, as more clipped reads
                    print("10X bam! Set the initial cutoff as {0}".format(
                        global_values.INITIAL_MIN_CLIP_CUTOFF_X10))
                    global_values.set_initial_min_clip_cutoff(global_values.INITIAL_MIN_CLIP_CUTOFF_X10)
                else:
                    if cutoff_left_clip <= 3:#
                        print("Clip cutoff is small (<=3), keep all the clipped reads (initial cutoff set as 1)!!!")
                        global_values.set_initial_min_clip_cutoff(1)  # for low coverage data, set this to 1
                    else:
                        global_values.set_initial_min_clip_cutoff(
                            global_values.INITIAL_MIN_CLIP_CUTOFF_ILLUMINA)
                if len(sf_ori_bam) <= 1:
                    continue
                if b_set == False:
                    s_sample_bam = sf_ori_bam
                    b_set = True

                b_cutoff = True
                cutoff_hit_rep_copy = global_values.INITIAL_MIN_CLIP_CUTOFF

                # view the barcode bam as normal illumina bam
                # for each alignment, has one output
                sf_out_tmp = self.working_folder + global_values.CLIP_TMP + '{0}'.format(cnt)
                cnt += 1

                caller = TELocator(sf_ori_bam, sf_ori_bam, self.working_folder, self.n_jobs, self.sf_ref)
                # s_working_folder + global_values.CLIP_FOLDER + "/"+sf_bam_name + CLIP_FQ_SUFFIX
                sf_new_pub = ""
                if len(sf_clip_folder) == 0 or sf_clip_folder == None:
                    print("public folder is null!!!!")
                    continue
                if sf_clip_folder[-1] == "/":
                    sf_new_pub = sf_clip_folder + "{0}/".format(i_idx_bam)
                else:
                    sf_new_pub = sf_clip_folder + "/{0}/".format(i_idx_bam)
                caller.call_TEI_candidate_sites_from_clip_reads_v2_mosaic(sf_annotation, sf_rep_cns, sf_ref, b_se,
                                                                   cutoff_hit_rep_copy, cutoff_hit_rep_copy,
                                                                   b_cutoff, sf_new_pub, i_idx_bam, b_force, max_cov,
                                                                          sf_out_tmp)
                i_idx_bam += 1
                ####
        # get all the chromsomes names
        bam_info = BamInfo(s_sample_bam, self.sf_ref)
        b_with_chr = bam_info.is_chrm_contain_chr()
        m_chrms = bam_info.get_all_reference_names()

        xfilter = XIntemediateSites()
        xchrom = XChromosome()
        sf_out_merged = sf_out + "_tmp"
        with open(sf_out_merged, "w") as fout_sites_merged, open(sf_out, "w") as fout_sites:
            for chrm in m_chrms:  # write out chrm by chrm to save memory
                if xchrom.is_decoy_contig_chrms(chrm) == True:  ###filter out decoy and other contigs
                    continue
                m_sites_chrm = {}
                for i in range(cnt):
                    sf_tmp = self.working_folder + global_values.CLIP_TMP + "{0}".format(i)
                    if os.path.isfile(sf_tmp) == False:
                        print("Errors happen, file {0} doens't exist!".format(sf_tmp))
                        continue
                    with open(sf_tmp) as fin_tmp:
                        for line in fin_tmp:
                            fields = line.split()
                            tmp_chrm = bam_info.process_chrm_name(fields[0], b_with_chr)
                            if tmp_chrm != chrm:
                                continue
                            pos = int(fields[1])

                            if pos not in m_sites_chrm:
                                m_sites_chrm[pos] = []
                                for value in fields[2:]:
                                    m_sites_chrm[pos].append(int(value))
                            else:
                                i_value = 0
                                for value in fields[2:]:
                                    ###sum (left-realign, right-realign, mate_in_rep, lpolyA, rpolyA)
                                    m_sites_chrm[pos][i_value] += int(value)
                                    i_value += 1

                for pos in m_sites_chrm:
                    lth = len(m_sites_chrm[pos])
                    fout_sites_merged.write(chrm + "\t" + str(pos) + "\t")
                    for i in range(lth):
                        s_feature = str(m_sites_chrm[pos][i])
                        fout_sites_merged.write(s_feature + "\t")
                    fout_sites_merged.write("\n")

                # this will use the number of clipped reads within the nearby region
                m_sites_chrm_filtered = xfilter.parse_sites_with_clip_cutoff_for_chrm_with_polyA(m_sites_chrm,
                                                                                      cutoff_left_clip,
                                                                                      cutoff_right_clip,
                                                                                      cutoff_clip_mate_in_rep,
                                                                                                 cutoff_polyA)
                for pos in m_sites_chrm_filtered:
                    lth = len(m_sites_chrm_filtered[pos])
                    fout_sites.write(chrm + "\t" + str(pos) + "\t")
                    for i in range(lth):
                        s_feature = str(m_sites_chrm_filtered[pos][i])
                        fout_sites.write(s_feature + "\t")
                    fout_sites.write("\n")
####

    ####This function to check a give cluster, return whether this is a qualified candidate cluster
    ####Sum all the left-clip, all the right-clip, and all the (mate, realign-clip), and larger than cutoff
    def is_candidate_cluster(self, l_cluster, cutoff_left_clip, cutoff_right_clip, cutoff_clip_mate_in_rep):
        left_peak_pos = 0
        left_peak_info = ""
        max_left_clip = 0
        all_left_clip = 0

        right_peak_pos = 0
        right_peak_info = ""
        max_right_clip = 0
        all_right_clip = 0
        all_mate_realgn_clip_in_rep = 0

        all_representative_left = 0  ##left_clip + right_clip for the left peak position
        all_representative_right = 0  ##left_clip + right_clip for the right peak position

        for record in l_cluster:
            fields = record.split()
            tmp_pos = int(fields[1])
            tmp_left_clip = int(fields[2])
            tmp_right_clip = int(fields[3])
            tmp_mate_in_rep = int(fields[4])
            tmp_realign_left_clip = int(fields[5])
            tmp_realign_right_clip = int(fields[6])

            if max_left_clip < tmp_left_clip:
                max_left_clip = tmp_left_clip
                left_peak_pos = tmp_pos
                all_representative_left = tmp_left_clip + tmp_right_clip
                left_peak_info = record
            if max_right_clip < tmp_right_clip:
                max_right_clip = tmp_right_clip
                right_peak_pos = tmp_pos
                all_representative_right = tmp_left_clip + tmp_right_clip
                right_peak_info = record

            all_left_clip += tmp_left_clip
            all_right_clip += tmp_right_clip
            all_mate_realgn_clip_in_rep += tmp_mate_in_rep
            all_mate_realgn_clip_in_rep += tmp_realign_left_clip
            all_mate_realgn_clip_in_rep += tmp_realign_right_clip

        b_candidate_cluster = False
        representative_pos = left_peak_pos

        if (all_left_clip >= cutoff_left_clip or all_right_clip >= cutoff_right_clip) \
                and all_mate_realgn_clip_in_rep >= cutoff_clip_mate_in_rep:
            b_candidate_cluster = True
            if all_representative_left < all_representative_right:
                representative_pos = right_peak_pos

        return b_candidate_cluster, left_peak_pos, right_peak_pos, representative_pos, left_peak_info, right_peak_info

    ####

    ###output two files:
    ###1. each cluster has one representative position
    ###2. each cluster is one event, and has two (left and right) peak positions
    def chain_regions(self, sf_sorted_list, dist_cutoff, cutoff_left_clip, cutoff_right_clip, cutoff_clip_mate_in_rep,
                      sf_peak_pos, sf_peak_events):
        l_cluster = []
        pre_chrm = ""
        pre_pos = 0
        b_first = True
        with open(sf_peak_pos, "w") as fout_peak_pos, open(sf_peak_events, "w") as fout_peak_events:  ####write to file
            with open(sf_sorted_list) as fin_sorted_list:
                for line in fin_sorted_list:
                    fields = line.split()
                    cur_chrm = fields[0]
                    cur_pos = int(fields[1])

                    if b_first == True:
                        b_first = False
                    else:
                        # if form a cluster
                        if pre_chrm != cur_chrm or ((cur_pos - pre_pos) >= dist_cutoff):
                            b_qualify, lppos, rppos, repsnt_pos, lpinfo, rpinfo = self.is_candidate_cluster \
                                (l_cluster, cutoff_left_clip, cutoff_right_clip, cutoff_clip_mate_in_rep)
                            del l_cluster[:]
                            if b_qualify == True:
                                fout_peak_events.write(lpinfo + "\n")
                                fout_peak_events.write(rpinfo + "\n")
                                if repsnt_pos == lppos:
                                    fout_peak_pos.write(lpinfo + "\n")
                                else:
                                    fout_peak_pos.write(rpinfo + "\n")
                    l_cluster.append(line.rstrip())
                    pre_chrm = cur_chrm
                    pre_pos = cur_pos

                ####The last record
                b_qualify, lppos, rppos, repsnt_pos, lpinfo, rpinfo = self.is_candidate_cluster \
                    (l_cluster, cutoff_left_clip, cutoff_right_clip, cutoff_clip_mate_in_rep)
                if b_qualify == True:
                    fout_peak_events.write(lpinfo + "\n")
                    fout_peak_events.write(rpinfo + "\n")
                    if repsnt_pos == lppos:
                        fout_peak_pos.write(lpinfo + "\n")
                    else:
                        fout_peak_pos.write(rpinfo + "\n")

    # m_sites_chrm_filtered = xfilter.parse_sites_with_clip_cutoff_for_chrm(m_sites_chrm, cutoff_left_clip,
    #                                                                       cutoff_right_clip,
    #                                                                       cutoff_clip_mate_in_rep)
    #
#####
    # For given candidate sites from clip reads,
    # sum the num of the discordant pairs from different alignments
    def filter_candidate_sites_by_discordant_pairs_multi_alignmts(self, m_sites, iext, i_is, f_dev, cutoff,
                                                                  sf_annotation, sf_out, sf_raw_disc="", b_tumor=False):
        with open(self.sf_list) as fin_list:
            cnt = 0
            for line in fin_list:
                fields=line.split()
                sf_bam = fields[0]

                caller = TELocator(sf_bam, sf_bam, self.working_folder, self.n_jobs, self.sf_ref)
                tmp_cutoff = 1  # for here, not filtering #############################################################
                m_sites_discord, m_sites_raw_disc = caller.filter_candidate_sites_by_discordant_pairs_non_barcode(
                    m_sites, iext, i_is, f_dev, sf_annotation, tmp_cutoff)
                xfilter = XIntemediateSites()
                sf_out_tmp = self.working_folder + global_values.DISC_TMP + '{0}'.format(cnt)
                xfilter.output_candidate_sites(m_sites_discord, sf_out_tmp)

                sf_raw_tmp=self.working_folder+global_values.RAW_DISC_TMP+'{0}'.format(cnt)
                xfilter.output_candidate_sites(m_sites_raw_disc, sf_raw_tmp)
                cnt += 1

        # merge the output by summing up all the alignments,
        #  and output in a single file
        m_merged_sites = {}
        for i in range(cnt):
            sf_tmp = self.working_folder + global_values.DISC_TMP + '{0}'.format(i)
            with open(sf_tmp) as fin_tmp:
                for line in fin_tmp:
                    fields = line.split()
                    chrm = fields[0]
                    pos = int(fields[1])
                    n_left_disc = int(fields[2])
                    n_right_disc = int(fields[3])
                    if chrm not in m_merged_sites:
                        m_merged_sites[chrm] = {}
                    if pos not in m_merged_sites[chrm]:
                        m_merged_sites[chrm][pos] = []
                        m_merged_sites[chrm][pos].append(n_left_disc)
                        m_merged_sites[chrm][pos].append(n_right_disc)
                    else:
                        m_merged_sites[chrm][pos][0] += n_left_disc
                        m_merged_sites[chrm][pos][1] += n_right_disc
        with open(sf_out, "w") as fout_sites:
            n_half_cutoff=cutoff/2
            for chrm in m_merged_sites:
                for pos in m_merged_sites[chrm]:
                    n_left = m_merged_sites[chrm][pos][0]
                    n_right = m_merged_sites[chrm][pos][1]
                    #if n_left > cutoff or n_right > cutoff:
                    if b_tumor==True:#tumor
                        if (n_left + n_right) >= cutoff:
                            fout_sites.write(chrm + "\t" + str(pos) + "\t" + str(n_left) + "\t" + str(n_right) + "\n")
                    else:#non tumor cases
                        if ((n_left > n_half_cutoff) and (n_right> n_half_cutoff)) or (n_left > cutoff) \
                                or (n_right>cutoff):
                            fout_sites.write(chrm + "\t" + str(pos) + "\t" + str(n_left) + "\t" + str(n_right) + "\n")
####
        if sf_raw_disc=="":
            return
        #####
        # merge the output by summing up all the alignments,
        #  and output in a single file
        m_merged_raw_sites = {}
        for i in range(cnt):
            sf_tmp = self.working_folder + global_values.RAW_DISC_TMP + '{0}'.format(i)
            with open(sf_tmp) as fin_tmp:
                for line in fin_tmp:
                    fields = line.split()
                    chrm = fields[0]
                    pos = int(fields[1])
                    n_raw_left_disc = int(fields[2])
                    n_raw_right_disc = int(fields[3])
                    n_left_disc = int(fields[4])
                    n_right_disc = int(fields[5])
                    s_lcluster=fields[6]
                    s_lc_chrm=fields[7]
                    s_lc_pos=fields[8]
                    s_rcluster=fields[9]
                    s_rc_chrm=fields[10]
                    s_rc_pos=fields[11]

                    if chrm not in m_merged_raw_sites:
                        m_merged_raw_sites[chrm] = {}
                    if pos not in m_merged_raw_sites[chrm]:
                        m_merged_raw_sites[chrm][pos] = []
                        m_merged_raw_sites[chrm][pos].append(n_raw_left_disc)
                        m_merged_raw_sites[chrm][pos].append(n_raw_right_disc)
                        m_merged_raw_sites[chrm][pos].append(n_left_disc)
                        m_merged_raw_sites[chrm][pos].append(n_right_disc)
                        m_merged_raw_sites[chrm][pos].append([s_lcluster])
                        m_merged_raw_sites[chrm][pos].append([s_lc_chrm])
                        m_merged_raw_sites[chrm][pos].append([s_lc_pos])
                        m_merged_raw_sites[chrm][pos].append([s_rcluster])
                        m_merged_raw_sites[chrm][pos].append([s_rc_chrm])
                        m_merged_raw_sites[chrm][pos].append([s_rc_pos])
                    else:
                        m_merged_raw_sites[chrm][pos][0] += n_raw_left_disc
                        m_merged_raw_sites[chrm][pos][1] += n_raw_right_disc
                        m_merged_raw_sites[chrm][pos][2] += n_left_disc
                        m_merged_raw_sites[chrm][pos][3] += n_right_disc
                        m_merged_raw_sites[chrm][pos][4].append(s_lcluster)
                        m_merged_raw_sites[chrm][pos][5].append(s_lc_chrm)
                        m_merged_raw_sites[chrm][pos][6].append(s_lc_pos)
                        m_merged_raw_sites[chrm][pos][7].append(s_rcluster)
                        m_merged_raw_sites[chrm][pos][8].append(s_rc_chrm)
                        m_merged_raw_sites[chrm][pos][9].append(s_rc_pos)

        i_half_cutoff=cutoff/2
        if b_tumor==False:#for germline, set a little bit higer cutoff
            i_half_cutoff= int(cutoff*3/4) + 1
        if i_half_cutoff<1:
            i_half_cutoff=1

        with open(sf_raw_disc, "w") as fout_sites:
            for chrm in m_merged_raw_sites:
                for pos in m_merged_raw_sites[chrm]:
                    n_raw_left = m_merged_raw_sites[chrm][pos][0]
                    n_raw_right = m_merged_raw_sites[chrm][pos][1]
                    n_left = m_merged_raw_sites[chrm][pos][2]#fall in repetitive region
                    n_right = m_merged_raw_sites[chrm][pos][3]#fall in repetitive region

                    #left consistent
                    b_l_consistent=False
                    #here "1" indicates True, which means
                    if (n_raw_left>=i_half_cutoff) and ("1" in m_merged_raw_sites[chrm][pos][4]):
                        b_l_consistent=True
                    #right consistent
                    b_r_consistent=False
                    if (n_raw_right >= i_half_cutoff) and ("1" in m_merged_raw_sites[chrm][pos][7]):
                        b_r_consistent=True
                    if b_l_consistent or b_r_consistent:
                        fout_sites.write(
                            chrm + "\t" + str(pos) + "\t" + str(n_raw_left) + "\t" + str(n_raw_right) + "\t"
                            + str(n_left) + "\t" + str(n_right) + "\n")
####
####
    # This function is not used here
    # merge two dictionary
    def merge_sites(self, m_tmp, m_final):
        for chrm in m_tmp:
            if chrm not in m_final:
                m_final[chrm] = {}
            for pos in m_tmp[chrm]:
                if pos not in m_final[chrm]:
                    m_final[chrm][pos] = m_tmp[chrm][pos]
                else:
                    lth = len(m_tmp[chrm][pos])
                    for i in range(lth):
                        m_final[chrm][pos][i] += m_tmp[chrm][pos][i]

def unwrap_self_filter_by_discordant(arg, **kwarg):
    return TELocator.run_filter_by_discordant_pair_by_chrom(*arg, **kwarg)


def unwrap_self_filter_by_discordant_non_barcode(arg, **kwarg):
    return TELocator.run_filter_by_discordant_pair_by_chrom_non_barcode(*arg, **kwarg)


def unwrap_self_filter_by_barcode_coverage(arg, **kwarg):
    return TELocator.run_filter_by_barcode_coverage(*arg, **kwarg)


class TELocator():
    def __init__(self, sf_bam, sf_barcode_bam, s_working_folder, n_jobs, sf_ref):
        self.sf_bam = sf_bam
        self.sf_barcode_bam = sf_barcode_bam
        self.working_folder = s_working_folder
        self.n_jobs = int(n_jobs)
        self.sf_reference = sf_ref  ##reference genome
        self.cmd_runner = CMD_RUNNER()

    ###First, Use (left, right) clipped read as threshold. Also, require some of the mate read are within repeat region
    ###Then: check the nearby small region, whether the merged number saftisfy the threshold
    ###Then, from the candidate list, pick the peak in each window.

    ###First, Use (left, right) clipped read as threshold. Also, require some of the mate read are within repeat region
    ##Note, this version consider the insertion with deletion cases, that is common in many cases
    ##So, for TEI with deletion, there will be two breakpoints, and at each breakpoint, only one type of clipped reads
    def call_TEI_candidate_sites_from_clip_reads_v2(self, sf_annotation, sf_rep_cns, sf_ref, b_se, cutoff_left_clip,
                                                    cutoff_right_clip, b_cutoff, sf_pub_folder, idx_bam,
                                                    b_force, max_cov_cutoff, sf_out):
        # this is a public folder for different type of repeats to share the clipped reads
        if sf_pub_folder[-1]!="/":
            sf_pub_folder+="/"
        if os.path.exists(sf_pub_folder) == False:
            cmd = "mkdir -p {0}".format(sf_pub_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)

        #this is the local folder for the current read type to save the tmp files
        sf_clip_working_folder = self.working_folder + global_values.CLIP_FOLDER + "/{0}/".format(idx_bam)
        if os.path.exists(sf_clip_working_folder) == False:
            cmd = "mkdir -p {0}".format(sf_clip_working_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)

        clip_info = ClipReadInfo(self.sf_bam, self.n_jobs, self.sf_reference)
        ######1. so first, re-align the clipped parts, and count the number of supported clipped reads
        ####gnrt the clipped parts file
        sf_bam_name = os.path.basename(self.sf_bam)
        sf_all_clip_fq = sf_pub_folder + sf_bam_name + CLIP_FQ_SUFFIX
        clip_info.set_working_folder(sf_clip_working_folder)
        if os.path.islink(sf_all_clip_fq)==False or b_force==True:
            print("Collected clipped reads file {0} doesn't exist. Generate it now!".format(sf_all_clip_fq))
            ##collect the clip positions
            initial_clip_pos_freq_cutoff = global_values.INITIAL_MIN_CLIP_CUTOFF ##########################################################################
            print("Initial minimum clip cutoff is {0}".format(initial_clip_pos_freq_cutoff))
            clip_info.collect_clip_positions(sf_annotation, initial_clip_pos_freq_cutoff, b_se, sf_pub_folder) ##save clip pos by chrm
            print("Output info: Collect clipped parts for file ", self.sf_bam)
            sf_all_clip_fq_ori=sf_clip_working_folder+sf_bam_name + CLIP_FQ_SUFFIX
            clip_info.collect_clipped_parts(sf_all_clip_fq_ori)
####
            if os.path.isfile(sf_all_clip_fq)==True or os.path.islink(sf_all_clip_fq)==True:
                os.remove(sf_all_clip_fq)
            cmd="ln -s {0} {1}".format(sf_all_clip_fq_ori, sf_all_clip_fq)
            self.cmd_runner.run_cmd_small_output(cmd)
        else:
            print("Collected clipped reads file {0} already exist!".format(sf_all_clip_fq))
####
        ####align the clipped parts to repeat copies
        sf_algnmt = self.working_folder + sf_bam_name + CLIP_BAM_SUFFIX
        print("Output info: Re-align clipped parts for file ", self.sf_bam)

        bwa_align=BWAlign(global_values.BWA_PATH, global_values.BWA_REALIGN_CUTOFF, self.n_jobs)
        bwa_align.two_stage_realign(sf_rep_cns, sf_ref, sf_all_clip_fq, sf_algnmt)

        ####cnt number of clipped reads aligned to repeat copies from the re-alignment
        clip_info.cnt_clip_part_aligned_to_rep(sf_algnmt)  ##require at least half of the seq is mapped !!!!

        # if b_cutoff is set, then directly return the dict
        if b_cutoff == False:
            clip_info.merge_clip_positions(sf_pub_folder, sf_out)
        else:
            clip_info.merge_clip_positions_with_cutoff(cutoff_left_clip, cutoff_right_clip, max_cov_cutoff,
                                                       sf_pub_folder, sf_out)
        if os.path.isfile(sf_algnmt)==True:####remove the file
            os.remove(sf_algnmt)
####
    ###First, Use (left, right) clipped read as threshold. Also, require some of the mate read are within repeat region
    ###Then: check the nearby small region, whether the merged number saftisfy the threshold
    ###Then, from the candidate list, pick the peak in each window.

    ###First, Use (left, right) clipped read as threshold. Also, require some of the mate read are within repeat region
    ##Note, this version consider the insertion with deletion cases, that is common in many cases
    ##So, for TEI with deletion, there will be two breakpoints, and at each breakpoint, only one type of clipped reads
    def call_TEI_candidate_sites_from_clip_reads_v2_mosaic(self, sf_annotation, sf_rep_cns, sf_ref, b_se,
                                                    cutoff_left_clip,
                                                    cutoff_right_clip, b_cutoff, sf_pub_folder, idx_bam,
                                                    b_force, max_cov_cutoff, sf_out):
        # this is a public folder for different type of repeats to share the clipped reads
        if sf_pub_folder[-1] != "/":
            sf_pub_folder += "/"
        if os.path.exists(sf_pub_folder) == False:
            cmd = "mkdir -p {0}".format(sf_pub_folder)
            # Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)

        # this is the local folder for the current read type to save the tmp files
        sf_clip_working_folder = self.working_folder + global_values.CLIP_FOLDER + "/{0}/".format(idx_bam)
        if os.path.exists(sf_clip_working_folder) == False:
            cmd = "mkdir -p {0}".format(sf_clip_working_folder)
            # Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)

        clip_info = ClipReadInfo(self.sf_bam, self.n_jobs, self.sf_reference)
        ######1. so first, re-align the clipped parts, and count the number of supported clipped reads
        ####gnrt the clipped parts file
        sf_bam_name = os.path.basename(self.sf_bam)
        sf_all_clip_fq = sf_pub_folder + sf_bam_name + CLIP_FQ_SUFFIX
        clip_info.set_working_folder(sf_clip_working_folder)

        ##collect the clip positions
        initial_clip_pos_freq_cutoff = global_values.INITIAL_MIN_CLIP_CUTOFF  ##########################################################################
        print("Initial minimum clip cutoff is {0}".format(initial_clip_pos_freq_cutoff))
        clip_info.collect_clip_positions(sf_annotation, initial_clip_pos_freq_cutoff, b_se,
                                         sf_pub_folder)  ##save clip pos by chrm
        print("Output info: Collect clipped parts for file ", self.sf_bam)
        sf_all_clip_fq_ori = sf_clip_working_folder + sf_bam_name + CLIP_FQ_SUFFIX
        clip_info.collect_clipped_parts(sf_all_clip_fq_ori)

        if os.path.isfile(sf_all_clip_fq) == True:
            os.remove(sf_all_clip_fq)
        cmd = "ln -s {0} {1}".format(sf_all_clip_fq_ori, sf_all_clip_fq)
        # Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_small_output(cmd)

####
        ####align the clipped parts to repeat copies
        sf_algnmt = self.working_folder + sf_bam_name + CLIP_BAM_SUFFIX
        print("Output info: Re-align clipped parts for file ", self.sf_bam)

        bwa_align = BWAlign(global_values.BWA_PATH, global_values.BWA_REALIGN_CUTOFF, self.n_jobs)
        bwa_align.two_stage_realign(sf_rep_cns, sf_ref, sf_all_clip_fq, sf_algnmt)

        ####cnt number of clipped reads aligned to repeat copies from the re-alignment
        clip_info.cnt_clip_part_aligned_to_rep_mosaic(sf_algnmt)  ##require at least half of the seq is mapped !!!!

        # if b_cutoff is set, then directly return the dict
        if b_cutoff == False:
            clip_info.merge_clip_positions(sf_pub_folder, sf_out)
        else:
            clip_info.merge_clip_positions_with_cutoff_polyA(cutoff_left_clip, cutoff_right_clip, max_cov_cutoff,
                                                       sf_pub_folder, sf_out)
        if os.path.isfile(sf_algnmt) == True:  ####remove the file
            os.remove(sf_algnmt)
####
    def collect_all_clipped_reads_only(self, sf_annotation, b_se, s_working_folder, wfolder_pub_clip):
        sf_clip_working_folder = s_working_folder + global_values.CLIP_FOLDER + "/"
        if len(sf_clip_working_folder)>1 and sf_clip_working_folder[-1]!="/":
            sf_clip_working_folder+="/"
        if os.path.exists(sf_clip_working_folder) == False:
            cmd = "mkdir {0}".format(sf_clip_working_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)

        clip_info = ClipReadInfo(self.sf_bam, self.n_jobs, self.sf_reference)
        clip_info.set_working_folder(sf_clip_working_folder)

        ##collect the clip positions
        ##in format {chrm: {map_pos: [left_cnt, right_cnt, mate_within_rep_cnt]}}
        print("Output info: Collect clip positions for file ", self.sf_bam)
        initial_clip_pos_freq_cutoff = 2  ##############################################################################
        ##save clip pos by chrm
        clip_info.collect_clip_positions(sf_annotation, initial_clip_pos_freq_cutoff, b_se, wfolder_pub_clip)

        ######1. so first, re-align the clipped parts, and count the number of supported clipped reads
        ####gnrt the clipped parts file
        sf_bam_name = os.path.basename(self.sf_bam)
        sf_all_clip_fq = sf_clip_working_folder + sf_bam_name + CLIP_FQ_SUFFIX
        print("Output info: Collect clipped parts for file ", self.sf_bam)
        # if os.path.isfile(sf_all_clip_fq)==False:
        clip_info.collect_clipped_parts(sf_all_clip_fq)
####

    def _is_decoy_contig_chrms(self, chrm):
        fields = chrm.split("_")
        if len(fields) > 1:
            return True
        elif chrm == "hs37d5":
            return True
        else:
            return False

    ###Input in format {chrm: {map_pos: [left_cnt, right_cnt, mate_within_rep_cnt]}}
    def filter_out_decoy_contig_chrms(self, m_candidate_list):
        m_new_list = {}
        for chrm in m_candidate_list:
            if self._is_decoy_contig_chrms(chrm) == True:
                continue

            if chrm not in m_new_list:
                m_new_list[chrm] = {}
            for pos in m_candidate_list[chrm]:
                if pos not in m_new_list[chrm]:
                    m_new_list[chrm][pos] = []
                for value in m_candidate_list[chrm][pos]:
                    m_new_list[chrm][pos].append(value)
        return m_new_list


    #####First, Use (left, right) clipped read as threshold. Also, require some of the mate read are within repeat region
    ##Note: this version will miss some cases, like insertion with deletion ones
    def call_TEI_candidate_sites_from_clip_reads(self, sf_ref, sf_annotation, cutoff_left_clip, cutoff_right_clip):
        clip_info = ClipReadInfo(self.sf_bam, self.n_jobs, self.sf_reference)
        clip_info.set_working_folder(self.working_folder)
        sf_all_clip_fq = self.working_folder + CLIP_FQ_SUFFIX
        m_clip_pos_freq = clip_info.collect_clipped_reads_with_position(sf_all_clip_fq, sf_annotation)

        # xself.output_candidate_sites(m_clip_pos_freq, "initial_clip_pos.txt")
        ####Here need to use the cutoff to remove most of the unnecessary sites first !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        clip_info.correct_num_of_clip_by_realignment(sf_ref, sf_annotation, sf_all_clip_fq, m_clip_pos_freq)
        mate_in_rep_cutoff = (cutoff_right_clip + cutoff_left_clip) / 2
        m_candidate_sites = {}
        for chrm in m_clip_pos_freq:
            for pos in m_clip_pos_freq[chrm]:
                ####here need to check the nearby region
                nearby_left_freq = 0
                nearby_right_freq = 0
                nearby_mate_in_rep = 0
                for i in range(-1 * global_values.NEARBY_REGION, global_values.NEARBY_REGION):
                    i_tmp_pos = pos + i
                    if i_tmp_pos in m_clip_pos_freq[chrm]:
                        nearby_left_freq += m_clip_pos_freq[chrm][i_tmp_pos][0]
                        nearby_right_freq += m_clip_pos_freq[chrm][i_tmp_pos][1]
                        nearby_mate_in_rep += m_clip_pos_freq[chrm][i_tmp_pos][2]

                if nearby_left_freq >= cutoff_left_clip and nearby_right_freq >= cutoff_right_clip \
                        and nearby_mate_in_rep >= mate_in_rep_cutoff:
                    if chrm not in m_candidate_sites:
                        m_candidate_sites[chrm] = {}
                    # if pos not in m_candidate_sites[chrm]:
                    #    m_candidate_sites[chrm] = {}
                    i_left_cnt = m_clip_pos_freq[chrm][pos][0]
                    i_right_cnt = m_clip_pos_freq[chrm][pos][1]
                    i_mate_in_rep_cnt = m_clip_pos_freq[chrm][pos][2]
                    m_candidate_sites[chrm][pos] = (i_left_cnt, i_right_cnt, i_mate_in_rep_cnt)
        return m_candidate_sites

    # #align the reads to the repeat copies to collect the repeat related reads only
    # #note, we also include two flank regions of the repeats to help find the transductions
    # def collect_reads_fall_in_repeats(self, m_site_algnmts, m_selected_algnmts, sf_out):
    #     #first, dump all the alignmnts to a file
    #     #then,

    def run_filter_by_discordant_pair_by_chrom(self, record):
        site_chrm1 = record[0]
        sf_bam = record[1]
        sf_barcode_bam = record[2]
        iextend = int(record[3])  ###extend some region on both sides in order to collect all barcodes
        i_is = int(record[4])
        f_dev = int(record[5])
        sf_annotation = record[6]
        sf_disc_working_folder = record[7]
        s_suffix = record[8]
        # iextend_small=record[9] ##extend a small region to compare the barcode difference
        # iextend_small = 300  ##extend a small region to compare the barcode difference ###############################

        sf_candidate_list = sf_disc_working_folder + site_chrm1 + s_suffix
        if os.path.exists(sf_candidate_list) == False:
            return
        m_candidate_pos = {}
        with open(sf_candidate_list) as fin_list:
            for line in fin_list:
                fields = line.split()
                pos = int(fields[1])
                m_candidate_pos[pos] = "\t".join(fields[2:])

        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        m_chrms = bam_info.get_all_reference_names()
        site_chrm = bam_info.process_chrm_name(site_chrm1, b_with_chr)
        if site_chrm not in m_chrms:
            return
        xannotation = XAnnotation(sf_annotation)
        xannotation.set_with_chr(b_with_chr)
        xannotation.load_rmsk_annotation()
        xannotation.index_rmsk_annotation()

        m_new_candidate_sites = {}
        xbam = XBamInfo(sf_bam, sf_barcode_bam, self.sf_reference)
        xbam.index_reference_name_id()
        bamfile = xbam.open_bam_file(sf_bam)  ##open bam file
        barcode_bamfile = xbam.open_bam_file(sf_barcode_bam)  ##open barcode bam file
        for site_pos in m_candidate_pos:  ####candidate site position # structure: {barcode:[alignmts]}
            if site_pos < iextend:
                continue
            # n_barcode_diff, n_barcode_share = xbam.check_barcode_diff_v2(bamfile, site_chrm, site_pos, iextend)
            # print site_chrm1, site_pos, " test1!!!!!!!!!"#############################################################
            m_site_algnmts = xbam.parse_alignments_for_one_site_v2(bamfile, barcode_bamfile, site_chrm, site_pos,
                                                                   iextend)
            if m_site_algnmts == None:  ####!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                continue
            n_barcode = len(m_site_algnmts)
            n_discordant_pair = 0
            n_one_in_rep_region_pair = 0
            n_both_in_rep_region_pair = 0
            for barcode in m_site_algnmts:
                l_algnmts = m_site_algnmts[barcode]
                for algnmt in l_algnmts:  ####Note, alignment here is in converted format: barcode as chromosome
                    barcode_algnmt = BarcodeAlignment(algnmt)
                    chrm = barcode_algnmt.get_chrm()
                    map_pos = barcode_algnmt.get_map_pos()
                    mate_chrm = barcode_algnmt.get_mate_chrm()
                    mate_map_pos = int(algnmt.next_reference_start)
                    template_lth = algnmt.template_length

                    xalgnmt = XAlignment()
                    b_discordant = xalgnmt.is_discordant_pair_no_unmap(chrm, mate_chrm, template_lth, i_is, f_dev)
                    if b_discordant == True:
                        n_discordant_pair += 1
                    if algnmt.is_unmapped or algnmt.mate_is_unmapped:
                        continue

                    ###1. consider first/mate reads only once?
                    ###2. consider different chrom with the 'site_chrm' and 'site_pos'???
                    if algnmt.is_read1 == True:
                        b_one_in_rep, b_both_in_rep = xalgnmt.is_TE_caused_discordant_pair(chrm, map_pos, mate_chrm,
                                                                                           mate_map_pos, xannotation)
                        if b_one_in_rep:
                            n_one_in_rep_region_pair += 1
                        if b_both_in_rep:
                            n_both_in_rep_region_pair += 1

            # m_new_candidate_sites[site_pos] = (
            #     str(n_barcode), str(n_discordant_pair), str(n_one_in_rep_region_pair), str(n_both_in_rep_region_pair),
            #     str(n_barcode_diff), str(n_barcode_share))
            m_new_candidate_sites[site_pos] = (
                str(n_barcode), str(n_discordant_pair), str(n_one_in_rep_region_pair), str(n_both_in_rep_region_pair))
        xbam.close_bam_file(barcode_bamfile)  ##close barcode bam file
        xbam.close_bam_file(bamfile)  ##close bam file

        ##write out the combined results
        sf_candidate_list_disc = sf_candidate_list + global_values.DISC_SUFFIX_FILTER
        with open(sf_candidate_list_disc, "w") as fout_disc:
            for pos in m_new_candidate_sites:
                fout_disc.write(str(pos) + "\t")
                fout_disc.write(str(m_candidate_pos[pos]) + "\t")
                lth = len(m_new_candidate_sites[pos])
                for i in range(lth):
                    fout_disc.write(str(m_new_candidate_sites[pos][i]) + "\t")
                fout_disc.write("\n")

    ##filter out some false positive ones using the discordant reads
    def filter_candidate_sites_by_discordant_pairs(self, m_candidate_sites, iextend, i_is, f_dev, sf_annotation,
                                                   n_one_in_rep_cutoff, n_both_in_rep_cutoff):
        sf_disc_working_folder = self.working_folder + global_values.DISC_FOLDER
        if os.path.exists(sf_disc_working_folder) == False:
            cmd = "mkdir {0}".format(sf_disc_working_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)
        sf_disc_working_folder += '/'
        self.output_candidate_sites_by_chrm(m_candidate_sites, sf_disc_working_folder, global_values.DISC_SUFFIX)

        l_chrm_records = []
        for chrm in m_candidate_sites:
            if len(chrm) > 5:  ###filter out those contigs!!!!!!! It's better to have a blacklist!!!!!!!!!!!!!!!!!!!!!!
                continue
            record = (
            chrm, self.sf_bam, self.sf_barcode_bam, iextend, i_is, f_dev, sf_annotation, sf_disc_working_folder,
            global_values.DISC_SUFFIX)
            l_chrm_records.append(record)
            # self.run_filter_by_discordant_pair_by_chrom(record) ##########################################################
        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_filter_by_discordant, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

        m_new_candidate_sites = {}
        for chrm in m_candidate_sites:  ####candidate site chromosome # read in by chrm
            sf_candidate_list_disc = sf_disc_working_folder + chrm + global_values.DISC_SUFFIX + global_values.DISC_SUFFIX_FILTER
            if os.path.exists(sf_candidate_list_disc) == False:
                continue
            with open(sf_candidate_list_disc) as fin_disc:
                for line in fin_disc:
                    fields = line.split()
                    pos = int(fields[0])
                    n_barcode = int(fields[-6])
                    n_discordant_pair = int(fields[-5])
                    n_one_in_rep_region_pair = int(fields[-4])
                    n_both_in_rep_region_pair = int(fields[-3])
                    n_barcode_diff = int(fields[-2])
                    n_barcode_share = int(fields[-1])

                    if n_one_in_rep_region_pair < n_one_in_rep_cutoff:
                        continue
                    if n_both_in_rep_region_pair < n_both_in_rep_cutoff:
                        continue

                    if chrm not in m_new_candidate_sites:
                        m_new_candidate_sites[chrm] = {}
                    if pos not in m_new_candidate_sites[chrm]:
                        if (chrm not in m_candidate_sites) or (pos not in m_candidate_sites[chrm]):
                            continue
                        n_clip = m_candidate_sites[chrm][pos][0]
                        m_new_candidate_sites[chrm][pos] = (
                            n_clip, n_barcode, n_discordant_pair, n_both_in_rep_region_pair, n_barcode_diff,
                            n_barcode_share)
        return m_new_candidate_sites

    def run_filter_by_barcode_coverage(self, record):
        site_chrm1 = record[0]
        sf_bam = record[1]
        sf_barcode_bam = record[2]
        iextend = int(record[3])  ###extend some region on both sides in order to collect all barcodes
        i_cov_cutoff = int(record[4])
        sf_disc_working_folder = record[5]
        s_suffix = record[6]

        sf_candidate_list = sf_disc_working_folder + site_chrm1 + s_suffix
        if os.path.exists(sf_candidate_list) == False:
            return
        m_candidate_pos = {}
        with open(sf_candidate_list) as fin_list:
            for line in fin_list:
                fields = line.split()
                pos = int(fields[1])
                m_candidate_pos[pos] = "\t".join(fields[2:])

        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        m_chrms = bam_info.get_all_reference_names()
        site_chrm = bam_info.process_chrm_name(site_chrm1, b_with_chr)
        if site_chrm not in m_chrms:
            return

        m_new_candidate_sites = {}
        xbam = XBamInfo(sf_bam, sf_barcode_bam, self.sf_reference)
        xbam.index_reference_name_id()
        bamfile = xbam.open_bam_file(sf_bam)  ##open bam file
        for site_pos in m_candidate_pos:  ####candidate site position # structure: {barcode:[alignmts]}
            if site_pos < iextend:
                continue
            set_barcodes = xbam.parse_barcodes_for_one_site(bamfile, site_chrm, site_pos, iextend)
            n_barcode = len(set_barcodes)
            if n_barcode > i_cov_cutoff: #if the barcode coverage is too high, then filter out the sites
                continue
            m_new_candidate_sites[site_pos] = n_barcode
        xbam.close_bam_file(bamfile)  ##close bam file

        ##write out the combined results
        sf_candidate_list_disc = sf_candidate_list + global_values.DISC_SUFFIX_FILTER
        with open(sf_candidate_list_disc, "w") as fout_disc:
            for pos in m_new_candidate_sites:
                fout_disc.write(str(pos) + "\t")
                fout_disc.write(str(m_new_candidate_sites[pos]) + "\n")


    def filter_candidate_sites_by_barcode_coverage(self, m_candidate_sites, iextend, i_cov_cutoff):
        sf_disc_working_folder = self.working_folder + global_values.DISC_FOLDER
        if os.path.exists(sf_disc_working_folder) == False:
            cmd = "mkdir {0}".format(sf_disc_working_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)
        sf_disc_working_folder += '/'
        self.output_candidate_sites_by_chrm(m_candidate_sites, sf_disc_working_folder, global_values.DISC_SUFFIX)

        l_chrm_records = []
        for chrm in m_candidate_sites:
            if len(chrm) > 5:  ###filter out those contigs!!!!!!! It's better to have a blacklist!!!!!!!!!!!!!!!!!!!!!!
                continue
            record = (
                chrm, self.sf_bam, self.sf_barcode_bam, iextend, i_cov_cutoff, sf_disc_working_folder, global_values.DISC_SUFFIX)
            l_chrm_records.append(record)

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_filter_by_barcode_coverage, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

        m_new_candidate_sites = {}
        for chrm in m_candidate_sites:  ####candidate site chromosome # read in by chrm
            sf_candidate_list_disc = sf_disc_working_folder + chrm + global_values.DISC_SUFFIX + global_values.DISC_SUFFIX_FILTER
            if os.path.exists(sf_candidate_list_disc) == False:
                continue
            with open(sf_candidate_list_disc) as fin_disc:
                for line in fin_disc:
                    fields = line.split()
                    pos = int(fields[0])
                    n_barcode = int(fields[-1])

                    if chrm not in m_new_candidate_sites:
                        m_new_candidate_sites[chrm] = {}
                    if pos not in m_new_candidate_sites[chrm]:
                        if (chrm not in m_candidate_sites) or (pos not in m_candidate_sites[chrm]):
                            continue
                        n_clip = m_candidate_sites[chrm][pos][0]
                        m_new_candidate_sites[chrm][pos] = (n_clip, n_barcode)
        return m_new_candidate_sites

####
    def run_filter_by_discordant_pair_by_chrom_non_barcode(self, record):
        site_chrm1 = record[0]
        sf_bam = record[1]
        iextend = int(record[2])###extend some region on both sides in order to collect all barcodes
        i_is = int(record[3])
        f_dev = int(record[4])
        sf_annotation = record[5]
        sf_disc_working_folder = record[6]
        s_suffix = record[7]

        sf_candidate_list = sf_disc_working_folder + site_chrm1 + s_suffix
        if os.path.exists(sf_candidate_list) == False:
            return
        m_candidate_pos = {}
        with open(sf_candidate_list) as fin_list:
            for line in fin_list:
                fields = line.split()
                pos = int(fields[1])
                m_candidate_pos[pos] = "\t".join(fields[2:])

        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()  # indicate whether the bam chrom has "chr" or not
        m_chrms = bam_info.get_all_reference_names()
        site_chrm = bam_info.process_chrm_name(site_chrm1, b_with_chr)
        if site_chrm not in m_chrms:
            return
        # print site_chrm ##########################################################################################

        xannotation = XAnnotation(sf_annotation)
        xannotation.set_with_chr(b_with_chr)
        # xannotation.load_rmsk_annotation()
        # xannotation.index_rmsk_annotation()
        i_min_copy_len=0
        boundary_extnd=0
        ####For SVA, because the rmsk annotation is bad, so we extend a little bit
        if global_values.IS_CALL_SVA is True:
            boundary_extnd=global_values.SVA_ANNOTATION_EXTND
        xannotation.load_rmsk_annotation_with_extnd_with_lenth_cutoff(boundary_extnd, i_min_copy_len)
        xannotation.index_rmsk_annotation_interval_tree()

        bamfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        m_new_candidate_sites = {}
        m_raw_disc_sites={}
        m_chrm_ids=self._get_chrm_id_name(bamfile)
        for site_pos in m_candidate_pos:  ####candidate site position # structure: {barcode:[alignmts]}
            if site_pos < iextend:
                continue

            n_left_discdt, n_lraw_disc, l_cluster = bam_info.cnt_discordant_pairs(bamfile, m_chrm_ids, site_chrm, site_pos - iextend,
                                                          site_pos, i_is, f_dev, xannotation)
            n_right_discdt, n_rraw_disc, r_cluster = bam_info.cnt_discordant_pairs(bamfile, m_chrm_ids, site_chrm, site_pos + 1,
                                                           site_pos + iextend, i_is, f_dev, xannotation)
            m_new_candidate_sites[site_pos] = [str(n_left_discdt), str(n_right_discdt)]
            #if l_cluster[0]==True or r_cluster[0]==True:#for transductions, require at least one side form cluster
            s_lcluster="0"
            s_lc_chrm="-1"
            s_lc_pos="-1"
            if l_cluster[0]==True:
                s_lcluster="1"
                s_lc_chrm=l_cluster[1]
                s_lc_pos=str(l_cluster[2])
            s_rcluster = "0"
            s_rc_chrm = "-1"
            s_rc_pos = "-1"
            if r_cluster[0] == True:
                s_rcluster = "1"
                s_rc_chrm = r_cluster[1]
                s_rc_pos = str(r_cluster[2])

            m_raw_disc_sites[site_pos]=[str(n_lraw_disc), str(n_rraw_disc), str(n_left_discdt), str(n_right_discdt),
                                        s_lcluster, s_lc_chrm, s_lc_pos, s_rcluster, s_rc_chrm, s_rc_pos]
        bamfile.close()
####
        ##write out the combined results
        sf_candidate_list_disc = sf_candidate_list + global_values.DISC_SUFFIX_FILTER
        with open(sf_candidate_list_disc, "w") as fout_disc:
            for pos in m_new_candidate_sites:
                fout_disc.write(str(pos) + "\t")
                # fout_disc.write(str(m_candidate_pos[pos]) + "\t")
                lth = len(m_new_candidate_sites[pos])
                for i in range(lth):
                    fout_disc.write(str(m_new_candidate_sites[pos][i]) + "\t")
                fout_disc.write("\n")
        #save the raw disc results
        sf_candidate_list_raw_disc=sf_candidate_list + global_values.RAW_DISC_SUFFIX_FILTER
        with open(sf_candidate_list_raw_disc, "w") as fout_disc_raw:
            for pos in m_raw_disc_sites:
                fout_disc_raw.write(str(pos) + "\t")
                # fout_disc.write(str(m_candidate_pos[pos]) + "\t")
                lth = len(m_raw_disc_sites[pos])
                for i in range(lth):
                    fout_disc_raw.write(str(m_raw_disc_sites[pos][i]) + "\t")
                fout_disc_raw.write("\n")
####
    ###This one feed in the normal illumina data, and count the discordant pairs of the left and right regions
    def filter_candidate_sites_by_discordant_pairs_non_barcode(self, m_candidate_sites, iextend, i_is, f_dev,
                                                               sf_annotation, n_discordant_cutoff):
        sf_disc_working_folder = self.working_folder + global_values.DISC_FOLDER
        if os.path.exists(sf_disc_working_folder) == False:
            cmd = "mkdir {0}".format(sf_disc_working_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)
        sf_disc_working_folder += '/'
        self.output_candidate_sites_by_chrm(m_candidate_sites, sf_disc_working_folder, global_values.DISC_SUFFIX)
        xchrm=XChromosome()
        l_chrm_records = []
        for chrm in m_candidate_sites:
            ###filter out those contigs!!!!!!!
            if xchrm.is_decoy_contig_chrms(chrm)==True:
                continue

            l_chrm_records.append(
                (chrm, self.sf_bam, iextend, i_is, f_dev, sf_annotation, sf_disc_working_folder, global_values.DISC_SUFFIX))

        pool = Pool(self.n_jobs)
        pool.map(unwrap_self_filter_by_discordant_non_barcode, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

        m_new_candidate_sites = {}
        for chrm in m_candidate_sites:  ####candidate site chromosome # read in by chrm
            sf_candidate_list_disc = sf_disc_working_folder + chrm + global_values.DISC_SUFFIX + global_values.DISC_SUFFIX_FILTER
            if os.path.exists(sf_candidate_list_disc) == False:
                continue
            with open(sf_candidate_list_disc) as fin_disc:
                for line in fin_disc:
                    fields = line.split()
                    pos = int(fields[0])
                    n_disc_left = int(fields[1])
                    n_disc_right = int(fields[2])

                    ###Here require both left and right discordant pairs
                    # if n_disc_left < n_discordant_cutoff and n_disc_right < n_discordant_cutoff:
                    #     continue
                    if (n_disc_left + n_disc_right) < n_discordant_cutoff:
                        continue

                    if chrm not in m_new_candidate_sites:
                        m_new_candidate_sites[chrm] = {}
                    if pos not in m_new_candidate_sites[chrm]:
                        # n_clip = m_candidate_sites[chrm][pos][0]
                        # m_new_candidate_sites[chrm][pos] = (n_clip, n_disc_left, n_disc_right)
                        m_new_candidate_sites[chrm][pos] = [n_disc_left, n_disc_right]

        #RAW_DISC_SUFFIX_FILTER
        m_raw_disc_sites = {}  # for each site, save the raw discordant reads
        for chrm in m_candidate_sites:  ####candidate site chromosome # read in by chrm
            sf_candidate_list_raw_disc = sf_disc_working_folder + chrm + global_values.DISC_SUFFIX + global_values.RAW_DISC_SUFFIX_FILTER
            if os.path.exists(sf_candidate_list_raw_disc) == False:
                continue
            with open(sf_candidate_list_raw_disc) as fin_disc:
                for line in fin_disc:
                    fields = line.split()
                    pos = int(fields[0])
                    n_raw_disc_left = int(fields[1])
                    n_raw_disc_right = int(fields[2])
                    n_disc_left = int(fields[3])
                    n_disc_right = int(fields[4])
                    s_lcluster=fields[5]
                    s_lc_chrm=fields[6]
                    s_lc_pos=fields[7]
                    s_rcluster=fields[8]
                    s_rc_chrm=fields[9]
                    s_rc_pos=fields[10]

                    if chrm not in m_raw_disc_sites:
                        m_raw_disc_sites[chrm] = {}
                    if pos not in m_raw_disc_sites[chrm]:
                        # n_clip = m_candidate_sites[chrm][pos][0]
                        # m_new_candidate_sites[chrm][pos] = (n_clip, n_disc_left, n_disc_right)
                        m_raw_disc_sites[chrm][pos] = [n_raw_disc_left, n_raw_disc_right, n_disc_left, n_disc_right,
                                                       s_lcluster, s_lc_chrm, s_lc_pos, s_rcluster, s_rc_chrm, s_rc_pos]
        return m_new_candidate_sites, m_raw_disc_sites


    def output_candidate_sites_by_chrm(self, m_candidate_list, sf_folder, s_suffix):
        for chrm in m_candidate_list:
            with open(sf_folder + chrm + s_suffix, "w") as fout_chrm:
                for pos in m_candidate_list[chrm]:
                    lth = len(m_candidate_list[chrm][pos])
                    fout_chrm.write(chrm + "\t" + str(pos) + "\t")
                    for i in range(lth):
                        fout_chrm.write(str(m_candidate_list[chrm][pos][i]) + "\t")
                    fout_chrm.write("\n")

    ###output the candidate list in a file
    def output_candidate_sites(self, m_candidate_list, sf_out):
        with open(sf_out, "w") as fout_candidate_sites:
            for chrm in m_candidate_list:
                for pos in m_candidate_list[chrm]:
                    lth = len(m_candidate_list[chrm][pos])
                    fout_candidate_sites.write(chrm + "\t" + str(pos) + "\t")
                    for i in range(lth):
                        s_feature = str(m_candidate_list[chrm][pos][i])
                        fout_candidate_sites.write(s_feature + "\t")
                    fout_candidate_sites.write("\n")

    ####Two situations will be kept:
    # 1. the site have both left and right clipped reads, and mate reads fall in repeat region
    # 2. The site has nearby sites, that form a cluster and the cluster have both left and right clpped reads
    # def is_candidate_clip_position(self, pos, m_clip_pos, iextend, n_left_cutoff, n_right_cutoff, n_mate_cutoff):
    #     if

    ####according to the clipped reads (left, right) clip:
    # 1. the clip position either has left_clipped and right_clipped reads, or
    # 2. the clip position has left (right) clipped reads, and nearby clipped position has right (left) clip reads
    ####According to barcode:
    # 1. at least 20 barcodes are shared between the left and right regions
    # 2.
    def first_stage_filter(self, sf_working_folder):
        bam_info = BamInfo(self.sf_bam, self.sf_reference)
        m_chrm_names = bam_info.get_all_reference_names()
        m_all_sites = {}

        for chrm in m_chrm_names:
            m_clip_pos = {}
            sf_clip_sites = sf_working_folder + "{0}{1}".format(chrm, CLIP_POS_SUFFIX)
            if os.path.exists(sf_clip_sites) == False:
                continue
            sf_disc_sites = sf_working_folder + global_values.DISC_FOLDER + "/" + "{0}{1}{2}".format(chrm, global_values.DISC_SUFFIX,
                                                                                       global_values.DISC_SUFFIX_FILTER)
            if os.path.exists(sf_disc_sites) == False:
                continue
            with open(sf_clip_sites) as fin_clip:  # read in the sites from file
                for line in fin_clip:
                    fields = line.split()
                    pos = int(fields[0])
                    n_left_clip = int(fields[1])
                    n_right_clip = int(fields[2])
                    n_mate_in_rep = int(fields[3])
                    m_clip_pos[pos] = (n_left_clip, n_right_clip, n_mate_in_rep)

                    ##TDList: Need to process the clipped reads
                    # need to collect the clipped part, and re-align to the reference

                    # 1. find all the clipped position, and then re-align the clipped part ###count the number of clipped reads
                    # 1.1 number of left clipped, and number of right clipped reads
                    # 1.2 number of (discordant, clipped) reads
                    # 2. for each clip position, find all the discordant pairs             ###count the number of discordant pairs
                    # 3.

                    # 4. Align the assembled contigs to the reference (align the repeat copies to the assembled contigs????)
                    # 5. call out the events
                    # 6.

                    # 7.
                    ####

    # def merge_sites_features(self, s_working_folder, m_sites_barcode, sf_out):
    def _get_chrm_id_name(self, samfile):
        m_chrm = {}
        references = samfile.references
        for schrm in references:
            chrm_id = samfile.get_tid(schrm)
            m_chrm[chrm_id] = schrm
        m_chrm[-1] = "*"
        return m_chrm

####
    #import os, tempfile
    # def symlink(self, target, link_name, overwrite=False):
    #     '''
    #     Create a symbolic link named link_name pointing to target.
    #     If link_name exists then FileExistsError is raised, unless overwrite=True.
    #     When trying to overwrite a directory, IsADirectoryError is raised.
    #     '''
    #
    #     if not overwrite:
    #         os.symlink(target, linkname)
    #         return
    #
    #     # os.replace() may fail if files are on different filesystems
    #     link_dir = os.path.dirname(link_name)
    #
    #     # Create link to target with temporary filename
    #     while True:
    #         temp_link_name = tempfile.mktemp(dir=link_dir)
    #
    #         # os.* functions mimic as closely as possible system functions
    #         # The POSIX symlink() returns EEXIST if link_name already exists
    #         # https://pubs.opengroup.org/onlinepubs/9699919799/functions/symlink.html
    #         try:
    #             os.symlink(target, temp_link_name)
    #             break
    #         except FileExistsError:
    #             pass
    #
    #     # Replace link_name with temp_link_name
    #     try:
    #         # Pre-empt os.replace on a directory with a nicer message
    #         if os.path.isdir(link_name):
    #             raise IsADirectoryError(f"Cannot symlink over existing directory: '{link_name}'")
    #         os.replace(temp_link_name, link_name)
    #     except:
    #         if os.path.islink(temp_link_name):
    #             os.remove(temp_link_name)
    #         raise