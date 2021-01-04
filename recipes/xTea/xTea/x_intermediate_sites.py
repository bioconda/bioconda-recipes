##11/27/2017
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

import os
from subprocess import *
import global_values
import numpy as np

class XIntemediateSites():
    def parse_sites_with_clip_cutoff(self, m_clip_pos_freq, cutoff_left_clip, cutoff_right_clip):
        i_clip_mate_in_rep = 2  ########################################################################################
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

                # if nearby_left_freq >= cutoff_left_clip and nearby_right_freq >= cutoff_right_clip \
                #         and nearby_mate_in_rep >= i_clip_mate_in_rep:

                # for this version, doesn't check whether the clipped part is mapped to a repeat region
                if nearby_left_freq >= cutoff_left_clip and nearby_right_freq >= cutoff_right_clip:
                    if chrm not in m_candidate_sites:
                        m_candidate_sites[chrm] = {}
                    i_left_cnt = m_clip_pos_freq[chrm][pos][0]
                    i_right_cnt = m_clip_pos_freq[chrm][pos][1]
                    i_mate_in_rep_cnt = m_clip_pos_freq[chrm][pos][2]
                    m_candidate_sites[chrm][pos] = (i_left_cnt, i_right_cnt, i_mate_in_rep_cnt)
        return m_candidate_sites

####
    def parse_sites_with_clip_cutoff_for_chrm(self, m_clip_pos_freq, cutoff_left_clip, cutoff_right_clip,
                                              cutoff_clip_mate_in_rep):
        m_candidate_sites = {}
        for pos in m_clip_pos_freq:
            ####here need to check the nearby region
            nearby_left_freq = 0
            nearby_right_freq = 0
            nearby_mate_in_rep = 0
            for i in range(-1 * global_values.NEARBY_REGION, global_values.NEARBY_REGION):
                i_tmp_pos = pos + i
                if i_tmp_pos in m_clip_pos_freq:
                    nearby_left_freq += m_clip_pos_freq[i_tmp_pos][0]
                    nearby_right_freq += m_clip_pos_freq[i_tmp_pos][1]
                    nearby_mate_in_rep += (
                    m_clip_pos_freq[i_tmp_pos][2] + m_clip_pos_freq[i_tmp_pos][3] + m_clip_pos_freq[i_tmp_pos][4])

            b_candidate=False
            # if nearby_left_freq >= cutoff_left_clip and nearby_right_freq >= cutoff_right_clip \
            #         and nearby_mate_in_rep >= cutoff_clip_mate_in_rep:
            #     b_candidate=True
            if (nearby_left_freq >= cutoff_left_clip or nearby_right_freq >= cutoff_right_clip) \
                    and nearby_mate_in_rep >= cutoff_clip_mate_in_rep:
                b_candidate=True

            if b_candidate==True:
                # if nearby_left_freq >= cutoff_left_clip and nearby_right_freq >= cutoff_right_clip:
                i_left_cnt = m_clip_pos_freq[pos][0]
                i_right_cnt = m_clip_pos_freq[pos][1]
                i_mate_in_rep_cnt = m_clip_pos_freq[pos][2]
                m_candidate_sites[pos] = (i_left_cnt, i_right_cnt, i_mate_in_rep_cnt)
        return m_candidate_sites
####
    ####
    def parse_sites_with_clip_cutoff_for_chrm_with_polyA(self, m_clip_pos_freq, cutoff_left_clip, cutoff_right_clip,
                                              cutoff_clip_mate_in_rep, cutoff_polyA):
        m_candidate_sites = {}
        for pos in m_clip_pos_freq:
            ####here need to check the nearby region
            nearby_left_freq = 0
            nearby_right_freq = 0
            nearby_mate_in_rep = 0
            i_start=-1 * global_values.NEARBY_REGION
            i_end=global_values.NEARBY_REGION
            for i in range(i_start, i_end):
                i_tmp_pos = pos + i
                if i_tmp_pos in m_clip_pos_freq:
                    nearby_left_freq += m_clip_pos_freq[i_tmp_pos][0]
                    nearby_right_freq += m_clip_pos_freq[i_tmp_pos][1]
                    nearby_mate_in_rep += (#this is sum up: mate-in-rep + left-to-consensus + right-to-consensus
                    m_clip_pos_freq[i_tmp_pos][2] + m_clip_pos_freq[i_tmp_pos][3] + m_clip_pos_freq[i_tmp_pos][4])

            b_candidate=False
            # if nearby_left_freq >= cutoff_left_clip and nearby_right_freq >= cutoff_right_clip \
            #         and nearby_mate_in_rep >= cutoff_clip_mate_in_rep:
            #     b_candidate=True
            if (nearby_left_freq >= cutoff_left_clip or nearby_right_freq >= cutoff_right_clip) \
                    and nearby_mate_in_rep >= cutoff_clip_mate_in_rep:
                b_candidate=True

            if b_candidate==True:
                # if nearby_left_freq >= cutoff_left_clip and nearby_right_freq >= cutoff_right_clip:
                i_left_cnt = m_clip_pos_freq[pos][0]
                i_right_cnt = m_clip_pos_freq[pos][1]
                i_mate_in_rep_cnt = m_clip_pos_freq[pos][2]
                l_polyA=m_clip_pos_freq[pos][5]
                r_polyA=m_clip_pos_freq[pos][6]
                if (l_polyA+r_polyA)<cutoff_polyA:
                    continue
                m_candidate_sites[pos] = (i_left_cnt, i_right_cnt, i_mate_in_rep_cnt, l_polyA, r_polyA)
        return m_candidate_sites

    ###output the candidate list in a file
    def output_candidate_sites(self, m_candidate_list, sf_out):
        with open(sf_out, "w") as fout_candidate_sites:
            for chrm in m_candidate_list:
                if self.is_decoy_contig_chrms(chrm):  ####decoy and other contigs are not interested!!!!
                    continue
                for pos in m_candidate_list[chrm]:
                    lth = len(m_candidate_list[chrm][pos])
                    fout_candidate_sites.write(chrm + "\t" + str(pos) + "\t")
                    for i in range(lth):
                        s_feature = str(m_candidate_list[chrm][pos][i])
                        fout_candidate_sites.write(s_feature + "\t")
                    fout_candidate_sites.write("\n")

####
    def is_decoy_contig_chrms(self, chrm):
        fields = chrm.split("_")
        if len(fields) > 1:
            return True
        elif chrm == "hs37d5":
            return True

        # if this is not to call mitochondrial insertion, then filter out chrm related reads
        if global_values.GLOBAL_MITCHONDRION_SWITCH=="OFF":
            if chrm=="MT" or chrm=="chrMT" or chrm=="chrM":#doesn't consider the mitchrondrial DNA
                #print "[TEST]: global value is off"
                return True

        dot_fields = chrm.split(".")
        if len(dot_fields) > 1:
            return True
        else:
            return False
####

    def load_in_candidate_list(self, sf_candidate_list):
        m_list = {}
        with open(sf_candidate_list) as fin_candidate_sites:
            for line in fin_candidate_sites:
                fields = line.split()
                if len(fields)<3:
                    print(fields, "does not have enough fields")
                    continue
                chrm = fields[0]
                pos = int(fields[1])
                if chrm not in m_list:
                    m_list[chrm] = {}
                if pos not in m_list[chrm]:
                    m_list[chrm][pos] = []
                for ivalue in fields[2:]:
                    m_list[chrm][pos].append(int(ivalue))
        return m_list

    ####
    def load_in_candidate_list_one_line(self, sf_candidate_list):
        m_list = {}
        with open(sf_candidate_list) as fin_candidate_sites:
            for line in fin_candidate_sites:
                fields = line.split()
                if len(fields)<3:
                    print(fields, "does not have enough fields")
                    continue
                chrm = fields[0]
                pos = int(fields[1])
                if chrm not in m_list:
                    m_list[chrm] = {}
                m_list[chrm][pos]=line.rstrip()
        return m_list

    ####
    def load_in_candidate_list_str_version(self, sf_candidate_list):
        m_list = {}
        with open(sf_candidate_list) as fin_candidate_sites:
            for line in fin_candidate_sites:
                fields = line.split()
                if len(fields)<3:
                    print(fields, "does not have enough fields")
                    continue
                chrm = fields[0]
                pos = int(fields[1])
                if chrm not in m_list:
                    m_list[chrm] = {}
                if pos not in m_list[chrm]:
                    m_list[chrm][pos] = []
                for s_value in fields[2:]:
                    m_list[chrm][pos].append(s_value)
        return m_list

    def load_in_candidate_list2(self, sf_candidate_list):
        m_list = {}
        with open(sf_candidate_list) as fin_candidate_sites:
            for line in fin_candidate_sites:
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])
                if chrm not in m_list:
                    m_list[chrm] = {}
                if pos not in m_list[chrm]:
                    m_list[chrm][pos] = []
                for ivalue in fields[2:]:
                    m_list[chrm][pos].append(ivalue) #here save str
        return m_list

    def is_in_existing_list(self, ins_chrm, ins_pos, m_sites, i_win):
        if ins_chrm not in m_sites:
            return False
        for i in range(ins_pos-i_win, ins_pos+i_win):
            if (i+ins_pos) in m_sites[ins_chrm]:
                return True
        return False

    # In the previous step (call_TEI_candidate_sites), some sites close to each other may be introduced together
    # If there are more than 1 site close to each other, than use the peak site as a representative
    def call_peak_candidate_sites(self, m_candidate_sites, peak_window):#
        m_peak_candidate_sites = {}
        for chrm in m_candidate_sites:
            l_pos = list(m_candidate_sites[chrm].keys())
            l_pos.sort()  ###sort the candidate sites
            pre_pos = -1
            set_cluster = set()
            for pos in l_pos:
                if pre_pos == -1:
                    pre_pos = pos
                    set_cluster.add(pre_pos)
                    continue

                if pos - pre_pos > peak_window:  # find the peak in the cluster
                    max_clip = 0
                    tmp_candidate_pos = 0
                    for tmp_pos in set_cluster:
                        tmp_left_clip = int(m_candidate_sites[chrm][tmp_pos][0]) #left clip
                        tmp_right_clip = int(m_candidate_sites[chrm][tmp_pos][1]) #right clip
                        tmp_all_clip = tmp_left_clip + tmp_right_clip #all the clip
                        if max_clip < tmp_all_clip:
                            tmp_candidate_pos = tmp_pos
                            max_clip = tmp_all_clip
                    set_cluster.clear()
                    if chrm not in m_peak_candidate_sites:
                        m_peak_candidate_sites[chrm] = {}
                    if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                        m_peak_candidate_sites[chrm][tmp_candidate_pos] = [max_clip]
                pre_pos = pos
                set_cluster.add(pre_pos)

            # push out the last group 
            max_clip = 0
            tmp_candidate_pos = 0
            ####check the standard derivation
            for tmp_pos in set_cluster:
                tmp_left_clip = int(m_candidate_sites[chrm][tmp_pos][0])
                tmp_right_clip = int(m_candidate_sites[chrm][tmp_pos][1])
                tmp_all_clip = tmp_left_clip + tmp_right_clip
                if max_clip < tmp_all_clip:
                    tmp_candidate_pos = tmp_pos
                    max_clip = tmp_all_clip
            if chrm not in m_peak_candidate_sites:
                m_peak_candidate_sites[chrm] = {}
            if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                ##Here, use list in order to output the list (by call the output_candidate_sites function)
                m_peak_candidate_sites[chrm][tmp_candidate_pos] = [max_clip]
        return m_peak_candidate_sites
####
    ####In this version, we will calculate the standard derivation of the left and right clip cluster
    # In the previous step (call_TEI_candidate_sites), some sites close to each other may be introduced together
    # If there are more than 1 site close to each other, than use the peak site as a representative
    def call_peak_candidate_sites_with_std_derivation(self, m_candidate_sites, peak_window):
        m_peak_candidate_sites = {}
        for chrm in m_candidate_sites:
            l_pos = list(m_candidate_sites[chrm].keys())
            l_pos.sort()  ###sort the candidate sites
            pre_pos = -1
            set_cluster = set()
            for pos in l_pos:
                if pre_pos == -1:
                    pre_pos = pos
                    set_cluster.add(pre_pos)
                    continue

                if pos - pre_pos > peak_window:  # find the peak in the cluster
                    # find the representative position of this cluster
                    # also calc the standard derivation of the left and right cluster
                    max_clip = 0
                    tmp_candidate_pos = 0
                    l_lclip_pos=[]
                    l_rclip_pos=[]
                    for tmp_pos in set_cluster:
                        tmp_left_clip = int(m_candidate_sites[chrm][tmp_pos][0])  # left clip
                        tmp_right_clip = int(m_candidate_sites[chrm][tmp_pos][1])  # right clip
                        tmp_all_clip = tmp_left_clip + tmp_right_clip  # all the clip
                        if max_clip < tmp_all_clip:
                            tmp_candidate_pos = tmp_pos
                            max_clip = tmp_all_clip
                        l_tmp_lclip = [tmp_pos] * tmp_left_clip
                        l_tmp_rclip = [tmp_pos] * tmp_right_clip
                        l_lclip_pos.extend(l_tmp_lclip)
                        l_rclip_pos.extend(l_tmp_rclip)
                    ####
                    set_cluster.clear()

                    ####calculate the left and right cluster standard derivation
                    f_lclip_std=self.calc_std_derivation(l_lclip_pos)
                    f_rclip_std=self.calc_std_derivation(l_rclip_pos)
                    l_rclip_pos.extend(l_lclip_pos)
                    f_clip_std=self.calc_std_derivation(l_rclip_pos)

                    if chrm not in m_peak_candidate_sites:
                        m_peak_candidate_sites[chrm] = {}
                    if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                        m_peak_candidate_sites[chrm][tmp_candidate_pos] = [max_clip, f_lclip_std, f_rclip_std, f_clip_std]
                pre_pos = pos
                set_cluster.add(pre_pos)
####
            # push out the last group
            max_clip = 0
            tmp_candidate_pos = 0
            l_lclip_pos = []
            l_rclip_pos = []
            for tmp_pos in set_cluster:
                tmp_left_clip = int(m_candidate_sites[chrm][tmp_pos][0])
                tmp_right_clip = int(m_candidate_sites[chrm][tmp_pos][1])
                tmp_all_clip = tmp_left_clip + tmp_right_clip
                if max_clip < tmp_all_clip:
                    tmp_candidate_pos = tmp_pos
                    max_clip = tmp_all_clip
                l_tmp_lclip = [tmp_pos] * tmp_left_clip
                l_tmp_rclip = [tmp_pos] * tmp_right_clip
                l_lclip_pos.extend(l_tmp_lclip)
                l_rclip_pos.extend(l_tmp_rclip)
            ####calculate the left and right cluster standard derivation
            f_lclip_std = self.calc_std_derivation(l_lclip_pos)
            f_rclip_std = self.calc_std_derivation(l_rclip_pos)
            l_rclip_pos.extend(l_lclip_pos)
            f_clip_std = self.calc_std_derivation(l_rclip_pos)
            if chrm not in m_peak_candidate_sites:
                m_peak_candidate_sites[chrm] = {}
            if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                ##Here, use list in order to output the list (by call the output_candidate_sites function)
                m_peak_candidate_sites[chrm][tmp_candidate_pos] = [max_clip, f_lclip_std, f_rclip_std, f_clip_std]
        return m_peak_candidate_sites
####

    # This version is designed for long reads which doesn't have exact accurate breakpoints.
    # For each cluster, we use the "medium" position as the representative position
    # If there are more than 1 site close to each other, than use the peak site as a representative
    ####m_candidate_sites in format: where m_candidate_sites[chrm][pos][0][0/1/2] is num of left/right/contained
    #### reads happen at site chrm:pos
    def call_peak_candidate_sites_lrd(self, m_candidate_sites, peak_window, b_save=False):
        m_peak_candidate_sites = {}
        m_brkpnts_sites={}
        for chrm in m_candidate_sites:
            l_pos = list(m_candidate_sites[chrm].keys())
            l_pos.sort()  ###sort the candidate sites
            pre_pos = -1
            l_clip_pos=[]
            for pos in l_pos:
                if pre_pos == -1:
                    pre_pos = pos
                    l_clip_pos.append(pre_pos)
                    continue

                #if end of a cluster, then check this cluster
                if pos - pre_pos > peak_window:  # find the peak in the cluster
                    total_clip=0
                    total_lclip=0
                    total_rclip=0
                    total_contained=0
                    total_focal_all=0
                    l_tmp_medium=[]
                    for tmp_pos in l_clip_pos:
                        tmp_left_clip = int(m_candidate_sites[chrm][tmp_pos][0][0]) #left clip
                        total_lclip+=tmp_left_clip
                        tmp_right_clip = int(m_candidate_sites[chrm][tmp_pos][0][1]) #right clip
                        total_rclip+=tmp_right_clip
                        tmp_contained = int(m_candidate_sites[chrm][tmp_pos][0][2])  # contained case
                        total_contained+=tmp_contained
                        tmp_all_clip = tmp_left_clip + tmp_right_clip + tmp_contained #all the clip
                        l_tmp_medium.append(tmp_all_clip)
                        total_clip+=tmp_all_clip
                    n_elements=len(l_clip_pos)
                    if n_elements>0:#
                        #find the medium position
                        i_cnt_half=total_clip/2
                        i_tmp_medium=0
                        i_tmp_idx=0
                        for tmp_value in l_tmp_medium:
                            i_tmp_medium+=tmp_value
                            if i_tmp_medium>=i_cnt_half:
                                break
                            i_tmp_idx+=1
                        tmp_candidate_pos=l_clip_pos[i_tmp_idx] ####this is the medium position
                        tmp_focal_start=tmp_candidate_pos-global_values.LRD_BRKPNT_FOCAL_REGIN
                        tmp_focal_end=tmp_candidate_pos+global_values.LRD_BRKPNT_FOCAL_REGIN
                        #tmp_candidate_pos = l_clip_pos[n_elements/2]#select the medium pos
                        ####before delete the sites, save the breakpoints for each cluster
                        if b_save==True:
                            if chrm not in m_brkpnts_sites:
                                m_brkpnts_sites[chrm] = {}
                            if tmp_candidate_pos not in m_brkpnts_sites[chrm]:
                                m_brkpnts_sites[chrm][tmp_candidate_pos]=[]
                            for tmp_pos2 in l_clip_pos:
                                #here we need to extend
                                tmp_left_clip2 = int(m_candidate_sites[chrm][tmp_pos2][0][0])  # left clip
                                tmp_right_clip2 = int(m_candidate_sites[chrm][tmp_pos2][0][1])  # right clip
                                tmp_contained2 = int(m_candidate_sites[chrm][tmp_pos2][0][2])  # contained case
                                l_tmp_lclip=[tmp_pos2]* tmp_left_clip2
                                l_tmp_rclip=[tmp_pos2]* tmp_right_clip2
                                l_tmp_contain=[tmp_pos2]* tmp_contained2
                                m_brkpnts_sites[chrm][tmp_candidate_pos].extend(l_tmp_lclip)
                                m_brkpnts_sites[chrm][tmp_candidate_pos].extend(l_tmp_rclip)
                                m_brkpnts_sites[chrm][tmp_candidate_pos].extend(l_tmp_contain)

                                if tmp_pos2>=tmp_focal_start and tmp_pos2<=tmp_focal_end:
                                    #total_focal_all+=(tmp_left_clip2+tmp_right_clip2+tmp_contained2)
                                    total_focal_all += tmp_contained2

                                #m_brkpnts_sites[chrm][tmp_candidate_pos].append(tmp_pos2)#save the position
                            #in a [-50,50] region, count the number of number of supported reads
####
                        f_tmp_std = self.calc_std_derivation(m_brkpnts_sites[chrm][tmp_candidate_pos])
                        del l_clip_pos[:]
                        if chrm not in m_peak_candidate_sites:
                            m_peak_candidate_sites[chrm] = {}
                        if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                            m_peak_candidate_sites[chrm][tmp_candidate_pos] = [total_clip, total_lclip, total_rclip,
                                                                               total_contained, total_focal_all, f_tmp_std]
                pre_pos = pos
                l_clip_pos.append(pre_pos)

            # push out the last group
            n_elements = len(l_clip_pos)
            if n_elements>0:
                total_clip = 0
                total_lclip = 0
                total_rclip = 0
                total_contained = 0
                total_focal_all = 0
                l_tmp_medium=[]
                for tmp_pos in l_clip_pos:
                    tmp_left_clip = int(m_candidate_sites[chrm][tmp_pos][0][0])  # left clip
                    total_lclip += tmp_left_clip
                    tmp_right_clip = int(m_candidate_sites[chrm][tmp_pos][0][1])  # right clip
                    total_rclip += tmp_right_clip
                    tmp_contained = int(m_candidate_sites[chrm][tmp_pos][0][2])  # contained case
                    total_contained += tmp_contained
                    tmp_all_clip = tmp_left_clip + tmp_right_clip + tmp_contained  # all the clip
                    l_tmp_medium.append(tmp_all_clip)
                    total_clip += tmp_all_clip

                i_cnt_half = total_clip / 2
                i_tmp_medium = 0
                i_tmp_idx = 0
                for tmp_value in l_tmp_medium:
                    i_tmp_medium += tmp_value
                    if i_tmp_medium >= i_cnt_half:
                        break
                    i_tmp_idx += 1
                tmp_candidate_pos = l_clip_pos[i_tmp_idx]
                tmp_focal_start = tmp_candidate_pos - global_values.LRD_BRKPNT_FOCAL_REGIN
                tmp_focal_end = tmp_candidate_pos + global_values.LRD_BRKPNT_FOCAL_REGIN
                #tmp_candidate_pos = l_clip_pos[n_elements / 2]  #select the medium pos
                ####before delete the sites, save the breakpoints for each cluster
                if b_save == True:
                    if chrm not in m_brkpnts_sites:
                        m_brkpnts_sites[chrm] = {}
                    if tmp_candidate_pos not in m_brkpnts_sites[chrm]:
                        m_brkpnts_sites[chrm][tmp_candidate_pos] = []
                    for tmp_pos2 in l_clip_pos:
                        # here we need to extend
                        tmp_left_clip2 = int(m_candidate_sites[chrm][tmp_pos2][0][0])  # left clip
                        tmp_right_clip2 = int(m_candidate_sites[chrm][tmp_pos2][0][1])  # right clip
                        tmp_contained2 = int(m_candidate_sites[chrm][tmp_pos2][0][2])  # contained case
                        l_tmp_lclip = [tmp_pos2] * tmp_left_clip2
                        l_tmp_rclip = [tmp_pos2] * tmp_right_clip2
                        l_tmp_contain = [tmp_pos2] * tmp_contained2
                        m_brkpnts_sites[chrm][tmp_candidate_pos].extend(l_tmp_lclip)
                        m_brkpnts_sites[chrm][tmp_candidate_pos].extend(l_tmp_rclip)
                        m_brkpnts_sites[chrm][tmp_candidate_pos].extend(l_tmp_contain)

                        if tmp_pos2 >= tmp_focal_start and tmp_pos2 <= tmp_focal_end:
                            total_focal_all += tmp_contained2

                f_tmp_std = self.calc_std_derivation(m_brkpnts_sites[chrm][tmp_candidate_pos])
                del l_clip_pos[:]
                if chrm not in m_peak_candidate_sites:
                    m_peak_candidate_sites[chrm] = {}
                if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                    m_peak_candidate_sites[chrm][tmp_candidate_pos] = [total_clip, total_lclip, total_rclip,
                                                                       total_contained, total_focal_all, f_tmp_std]
        return m_peak_candidate_sites, m_brkpnts_sites
####
####
    def merge_clip_disc(self, sf_disc_tmp, sf_clip, sf_out):
        with open(sf_out, "w") as fout_list:
            m_disc={}
            with open(sf_disc_tmp) as fin_disc:
                for line in fin_disc:
                    fields=line.split()
                    chrm=fields[0]
                    pos=fields[1]
                    s_left_disc=fields[2]
                    s_right_disc=fields[3]
                    if chrm not in m_disc:
                        m_disc[chrm]={}
                    m_disc[chrm][pos]=(s_left_disc, s_right_disc)
            with open(sf_clip) as fin_clip:
                for line in fin_clip:
                    fields=line.split()
                    chrm=fields[0]
                    pos=fields[1]
                    if chrm not in m_disc:
                        print("Error happen at merge clip and disc feature step: {0} not exist".format(chrm))
                        continue
                    if pos not in m_disc[chrm]:
                        continue
                    s_left_disc=m_disc[chrm][pos][0]
                    s_right_disc=m_disc[chrm][pos][1]
                    fields.append(s_left_disc)
                    fields.append(s_right_disc)
                    fout_list.write("\t".join(fields) + "\n")

    ####This is to output all the candidates with all the clip, discord, barcode information in one single file
    def merge_clip_disc_barcode(self, sf_barcode_tmp, sf_disc, sf_out):
        with open(sf_out, "w") as fout_list:
            m_barcode={}
            with open(sf_barcode_tmp) as fin_barcode:
                for line in fin_barcode:
                    fields=line.split()
                    chrm=fields[0]
                    pos=fields[1]
                    s_nbarcode=fields[-1]
                    if chrm not in m_barcode:
                        m_barcode[chrm]={}
                    m_barcode[chrm][pos]=s_nbarcode
            with open(sf_disc) as fin_disc:
                for line in fin_disc:
                    fields=line.split()
                    chrm=fields[0]
                    pos=fields[1]
                    if chrm not in m_barcode:
                        print("Error happen at merge clip, disc and barcode step: {0} not exist".format(chrm))
                        continue
                    if pos not in m_barcode[chrm]:
                        continue
                    s_barcode=m_barcode[chrm][pos]
                    fields.append(s_barcode)
                    fout_list.write("\t".join(fields) + "\n")

    # In the previous step (call_TEI_candidate_sites), some sites close to each other may be introduced together
    # If there are more than 1 site close to each other, than use the peak site as a representative
    def call_peak_candidate_sites_all_features(self, m_candidate_sites, peak_window):
        m_peak_candidate_sites = {}
        for chrm in m_candidate_sites:
            l_pos = list(m_candidate_sites[chrm].keys())
            l_pos.sort()  ###sort the candidate sites
            pre_pos = -1
            set_cluster = set()
            for pos in l_pos:
                if pre_pos == -1:
                    pre_pos = pos
                    set_cluster.add(pre_pos)
                    continue

                if pos - pre_pos > peak_window:  # find the peak in the cluster
                    max_clip = 0
                    max_all=0
                    tmp_candidate_pos = 0
                    for tmp_pos in set_cluster:
                        tmp_clip = int(m_candidate_sites[chrm][tmp_pos][0])  # # ofclip related features
                        tmp_all = int(m_candidate_sites[chrm][tmp_pos][1])  # # of all features
                        if (max_clip < tmp_clip) or (max_clip==tmp_clip and max_all < tmp_all):
                            tmp_candidate_pos = tmp_pos
                            max_clip = tmp_clip
                            max_all=tmp_all
                    set_cluster.clear()
                    if chrm not in m_peak_candidate_sites:
                        m_peak_candidate_sites[chrm] = {}
                    if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                        m_peak_candidate_sites[chrm][tmp_candidate_pos] = [max_clip]
                pre_pos = pos
                set_cluster.add(pre_pos)
            # push out the last group
            max_clip = 0
            max_all = 0
            tmp_candidate_pos = 0
            for tmp_pos in set_cluster:
                tmp_clip = int(m_candidate_sites[chrm][tmp_pos][0])  # # ofclip related features
                tmp_all = int(m_candidate_sites[chrm][tmp_pos][1])  # # of all features
                if (max_clip < tmp_clip) or (max_clip == tmp_clip and max_all < tmp_all):
                    tmp_candidate_pos = tmp_pos
                    max_clip = tmp_clip
                    max_all = tmp_all
            set_cluster.clear()
            if chrm not in m_peak_candidate_sites:
                m_peak_candidate_sites[chrm] = {}
            if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                m_peak_candidate_sites[chrm][tmp_candidate_pos] = [max_clip]
        return m_peak_candidate_sites

    ###this function is used to combine some sites are close to each other
    def combine_closing_sites(self, sf_input, iwindow, sf_out):
        m_original_sites={}
        with open(sf_input) as fin_sites:
            for line in fin_sites:
                fields=line.split()
                chrm=fields[0]
                pos=int(fields[1])
                cur_sum_clip=int(fields[2]) + int(fields[3]) + int(fields[4])
                cur_sum_all = cur_sum_clip + int(fields[5]) + int(fields[6])

                if chrm not in m_original_sites:
                    m_original_sites[chrm]={}
                m_original_sites[chrm][pos]=(cur_sum_clip, cur_sum_all)

        m_peak_candidate_sites=self.call_peak_candidate_sites_all_features(m_original_sites, iwindow)
        with open(sf_input) as fin_sites, open(sf_out, "w") as fout_sites:
            for line in fin_sites:
                fields=line.split()
                chrm=fields[0]
                pos=int(fields[1])
                if (chrm in m_peak_candidate_sites) and (pos in m_peak_candidate_sites[chrm]):
                    fout_sites.write(line)

    def are_sites_close(self, pos1, pos2, iwin):
        i_start=pos1-iwin
        i_end=pos1+iwin
        for i in range(i_start, i_end):
            if i==pos2:
                return True
        return False

    ####calculate the std derivation of a list of positions
    def calc_std_derivation(self, l_pos):
        if len(l_pos)<=0:
            return -1
        b = np.array([l_pos])
        f_std = round(np.std(b), 2)
        return f_std
####