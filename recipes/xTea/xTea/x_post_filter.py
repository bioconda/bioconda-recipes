####
##04/16/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

####1. for tprt both (with polyA and TSD) events, we filter out those:
        ####1.1 polyA dominant cases, this module will mainly used on Alu
                # (as for L1 and SVA, some middle region or transduction will contain the polyA part)
####2. false positive ones comes from low reads quality part caused clip
####
#For SVA: if fall in a reference SVA copy and only one-side-clip feature,
# then it's more likely because of the VNTR expansion caused FP, or at the boundary of SVA copy

#One side purly polyA clip, but has the other side clipped reads, but none aligned
#Two-side, purely polyA ones are filtered out
#Collect the transduction events into the final output
####
####07/14/19, Add the black-list filtering step.
####

import global_values
from x_annotation import *
from x_black_list import *
from x_rep_type import *

class XPostFilter():
    def __init__(self, swfolder, n_jobs):
        self.swfolder = swfolder
        if self.swfolder[-1] != "/":
            self.swfolder += "/"
        self.n_jobs = n_jobs
        self.REP_TYPE_L1="LINE1"
        self.REP_TYPE_ALU="ALU"
        self.REP_TYPE_SVA="SVA"
        self.REP_TYPE_HERV="HERV"
        self.REP_TYPE_MIT="Mitochondria"
        self.REP_TYPE_MSTA="Msta"
        self.REP_ALU_MIN_LEN=200
        self.REP_ALU_POLYA_START = 255
        self.REP_LINE_MIN_LEN=300
        self.REP_LINE_POLYA_START = 5950
        self.REP_SVA_MIN_LEN = 300
        self.REP_SVA_CNS_HEAD=400
        self.REP_SVA_POLYA_START=1900
        self.REP_HERV_MIN_LEN = 300
        self.REP_MIT_MIN_LEN = 300
        self.REP_MSTA_MIN_LEN = 300
        self.b_rslt_with_chr=True #####if rslt has "chr" while rmsk doesn't (vice versa), then it will be a problem
        self._two_side="two_side"
        self._one_half_side = "one_half"
        self._one_side="one_side"
        self._other="other"
        self._boundary_extnd=100 #for rmsk copy extend length
########Hard code here!!!!!
        self.nclip_half_cutoff=5 #one-side is polyA, which the other side has more than cutoff unmapped clipped reads!
        self.sva_clip_cluster_diff_cutoff=200
        self.indel_reads_max_ratio=0.3
        self.abnormal_cov_times=2
        self.L1_boundary_extnd = 400
        self.L1_min_ref_copy_len=125

####
    def post_processing_SVA(self, l_old_rcd, xtea_parser, xtprt_filter, af_filter, xannotation, m_cutoff, f_cov,
                            x_blklist, b_tumor, sf_new_out):
        i_dft_cluster_diff_cutoff=global_values.TWO_CLIP_CLUSTER_DIFF_CUTOFF
        global_values.set_two_clip_cluster_diff_cutoff(self.sva_clip_cluster_diff_cutoff)
        with open(sf_new_out, "w") as fout_new:
            for old_rcd in l_old_rcd:
                rcd=xtea_parser.replace_ins_length(old_rcd, self.REP_SVA_POLYA_START+100)
                s_rep_supt_type=xtea_parser.get_ins_sub_type(rcd)
                ins_chrm = rcd[0]
                ins_pos = rcd[1]

                b_in_blacklist, tmp_pos = x_blklist.fall_in_region(ins_chrm, int(ins_pos))
                if b_in_blacklist == True:
                    continue

                b_in_rep, i_pos = xannotation.is_within_repeat_region_interval_tree(ins_chrm, int(ins_pos))
                div_rate, sub_family, family, pos_start, pos_end=xannotation.get_div_subfamily(ins_chrm, i_pos)
                b_with_polyA=xtprt_filter.has_polyA_signal(rcd)
                if s_rep_supt_type is self._two_side:####two sides
                    if xtprt_filter.is_polyA_dominant_two_side_sva(rcd, self.REP_SVA_CNS_HEAD)==True:####
                        continue
                    if af_filter.is_qualified_rcd(rcd[-1], m_cutoff) == False:
                        continue
                    if b_with_polyA==False:#require polyA
                        continue
                elif s_rep_supt_type is self._one_half_side:##one and half side
                    #check whether fall in repetitive region of the same type
                    if (b_in_rep is True) and (div_rate<global_values.REP_DIVERGENT_CUTOFF):
                        continue
                    if b_with_polyA==False:#require polyA
                        continue
                    if xtprt_filter.is_polyA_dominant_two_side_sva(rcd, self.REP_SVA_CNS_HEAD) is True:
                        continue
                elif s_rep_supt_type is self._one_side:###one side
                    if (b_in_rep is True) and (div_rate < global_values.REP_DIVERGENT_CUTOFF):
                        continue
                    if b_with_polyA == False:
                        continue
                    #filter out orphan transduction or transduction, if it is one-side information
                    if (xtea_parser.is_orphan_transduction(rcd) == True or xtea_parser.is_transduction(rcd) == True) \
                            and b_tumor==False:
                        continue
                    # if xtprt_filter.is_polyA_dominant_two_side_sva(rcd) is True:
                    #     continue
                else:#for other type, just skip
                    continue
####
                #if two-side-clip, and none-in-polyA side, then filter out
                if b_in_rep and xtprt_filter.is_two_side_clip_both_polyA_sva(rcd, self.REP_SVA_POLYA_START):
                    continue
                #if fall in rep region, and none of the clipped part hit polyA
                if b_in_rep and xtprt_filter.is_two_side_clip_both_non_polyA_sva(rcd, self.REP_SVA_POLYA_START):
                    continue

                #save the passed ones
                s_in_rep = "not_in_SVA_copy"
                if b_in_rep is True:
                    s_in_rep = "Fall_in_SVA_copy_"+str(div_rate)
                s_pass_info = rcd[-1].rstrip() + "\t" + s_in_rep + "\n"
                fout_new.write(s_pass_info)
        global_values.set_two_clip_cluster_diff_cutoff(i_dft_cluster_diff_cutoff)
####
####
    def post_processing_Alu(self, l_old_rcd, xtea_parser, xtprt_filter, af_filter, xannotation, m_cutoff, f_cov,
                            x_blklist, sf_new_out):
        with open(sf_new_out, "w") as fout_new:
            for old_rcd in l_old_rcd:
                rcd = xtea_parser.replace_ins_length(old_rcd, self.REP_ALU_POLYA_START + 15)
                s_rep_supt_type = xtea_parser.get_ins_sub_type_alu(rcd) #here if both un-clip, then view as "two-side"
                ins_chrm = rcd[0]
                ins_pos = rcd[1]

                b_in_blacklist, tmp_pos = x_blklist.fall_in_region(ins_chrm, int(ins_pos))
                if b_in_blacklist == True:
                    continue

                b_in_rep, i_pos = xannotation.is_within_repeat_region_interval_tree(ins_chrm, int(ins_pos))
                div_rate, sub_family, family, pos_start, pos_end = xannotation.get_div_subfamily(ins_chrm, i_pos)
                b_with_polyA = xtprt_filter.has_polyA_signal(rcd)

                if s_rep_supt_type is self._two_side:  ####two sides
                    if (xtprt_filter.is_polyA_dominant_two_side(rcd) == True) \
                            and (xtprt_filter.is_two_side_polyA_same_orientation(rcd)==True):
                        continue
                    if af_filter.is_qualified_rcd(rcd[-1], m_cutoff) == False:
                        continue
                    if (b_with_polyA is False) and \
                                    xtprt_filter.is_two_side_tprt_and_with_polyA(rcd, self.REP_ALU_MIN_LEN)==False:
                        continue
                elif s_rep_supt_type is self._one_half_side:  ##one and half side
                    # check whether fall in repetitive region of the same type
                    #b_in_rep, i_pos = xannotation.is_within_repeat_region_interval_tree(ins_chrm, int(ins_pos))
                    if (b_in_rep is True) and (div_rate < global_values.REP_DIVERGENT_CUTOFF):
                        continue
                    if xtprt_filter.is_polyA_dominant_one_side(rcd, self.nclip_half_cutoff) is True:
                        continue
                    if (b_in_rep is True) and (b_with_polyA==False):
                        continue
                elif s_rep_supt_type is self._one_side:  ###one side
                    #b_in_rep, i_pos = xannotation.is_within_repeat_region_interval_tree(ins_chrm, int(ins_pos))
                    if (b_in_rep is True) and (div_rate < global_values.REP_DIVERGENT_CUTOFF):
                        continue
                    if xtprt_filter.is_polyA_dominant_one_side(rcd, self.nclip_half_cutoff) is True:
                        continue
                    if (b_in_rep is True) and (b_with_polyA==False):
                        continue
                else:  # for other type, just skip
                    continue

                # if have both side clipped reads, and fall in Alu copy,
                # and both side clip reads aligned to end of consensus, then skip
                if (b_in_rep is True) and \
                        (xtprt_filter.is_two_side_clip_and_both_hit_end(rcd, self.REP_ALU_POLYA_START)==True):
                    continue
####
                # if fall in Alu copy, but no clip cluster hit end of consensus, then skip
                if (b_in_rep is True) and (xtprt_filter.hit_consensus_tail(rcd, self.REP_ALU_POLYA_START)==False):
                    continue

                # if the nearby region has lots of indel reads, then skip
                b_cov_abnormal=xtprt_filter.cov_is_abnormal(rcd, f_cov*self.abnormal_cov_times)
                n_indel_cutoff=int(f_cov*self.indel_reads_max_ratio)
                if xtprt_filter.has_enough_indel_reads(rcd, n_indel_cutoff)==True \
                        and n_indel_cutoff>0 and b_cov_abnormal==True:
                    continue
####
                # save the passed ones
                # l_slct.append(rcd)
                s_in_rep="not_in_Alu_copy"
                if b_in_rep is True:
                    s_in_rep = "Fall_in_Alu_copy_"+str(div_rate)
                s_pass_info = rcd[-1].rstrip() + "\t" + s_in_rep +"\n"
                fout_new.write(s_pass_info)
####

####
    def post_processing_L1(self, l_old_rcd, xtea_parser, xtprt_filter, af_filter, xannotation, m_cutoff, f_cov,
                           x_blklist, b_tumor, sf_new_out, sf_td_new=None):#
        m_td_new={}#this is the transduction novel sites
        if sf_td_new!=None and os.path.isfile(sf_td_new)==True:####
            with open(sf_td_new) as fin_td_new:
                for line in fin_td_new:
                    fields=line.split()
                    ins_chrm=fields[0]
                    ins_pos=fields[1]
                    if ins_chrm not in m_td_new:
                        m_td_new[ins_chrm]={}
                    m_td_new[ins_chrm][ins_pos]=1

        #sf_new_out1=sf_new_out+".before_size_re_estimation"
        with open(sf_new_out, "w") as fout_new, open(sf_new_out+".post_filtering.log", "w") as fout_log:
            for old_rcd in l_old_rcd:#
                # note: the last field of each old_rcd is the whole record in string format
                rcd=xtea_parser.replace_ins_length(old_rcd, self.REP_LINE_POLYA_START+100)
                s_rep_supt_type = xtea_parser.get_ins_sub_type(rcd)
                ins_chrm = rcd[0]
                ins_pos = rcd[1]

                b_in_blacklist, tmp_pos=x_blklist.fall_in_region(ins_chrm, int(ins_pos))
                if b_in_blacklist==True:
                    print("{0}:{1} is filtered out, because fall in centromere region".format(ins_chrm, ins_pos))
                    fout_log.write("{0}:{1} is filtered out, because fall in centromere region\n".format(
                        ins_chrm, ins_pos))
                    continue

                #return value: if b_in_rep is False, and div_rate>0, then this is fall in rep region, but div>cutoff
                b_in_low_div_rep, div_rate, copy_start, copy_end = self.fall_in_low_div_same_type_rep(
                    xannotation, ins_chrm, ins_pos, global_values.REP_LOW_DIVERGENT_CUTOFF)

                ref_copy_start=copy_start+self.L1_boundary_extnd#change back to the original start position
                ref_copy_end=copy_end-self.L1_boundary_extnd#change back to the original end position
                b_in_rep=False
                s_in_rep = "not_in_LINE1_copy"
                b_within_copy=False #fall exactly in the reference copy
                b_left_copy=False #reference copy is at the left of the insertion
                b_right_copy=False #reference copy is at he right of the insertion
                if div_rate>=0:
                    b_in_rep=True
                    tmp_pos=int(ins_pos)
                    if tmp_pos>=ref_copy_start and tmp_pos<=ref_copy_end:
                        b_within_copy=True
                        s_in_rep = "Fall_in_LINE1_copy_" + str(div_rate)
                    elif ref_copy_end>0 and tmp_pos > ref_copy_end:
                        b_left_copy=True
                        s_in_rep = "Left_is_LINE1_copy_" + str(div_rate)
                    elif ref_copy_start>tmp_pos:
                        b_right_copy=True
                        s_in_rep = "Right_is_LINE1_copy_" + str(div_rate)
                    else:
                        s_in_rep = "Some_where_close_is_LINE1_copy_" + str(div_rate)
####
                # save the novel transduction cases, as they have been selected
                if xtea_parser.is_orphan_transduction(rcd) == True:#if orphan transduction, directly save it
                    s_pass_info = rcd[-1].rstrip() + "\t" + s_in_rep + "\n"
                    # filter out one side cases if it is not tumor samples
                    if (s_rep_supt_type is not self._one_side) or (b_tumor==True):
                        fout_new.write(s_pass_info)
                    continue
                elif xtea_parser.is_transduction(rcd) == True:
                    #if this is fall in low diverged copy, then skip
                    if b_in_low_div_rep == True and b_within_copy==True:#
                        if xtprt_filter.is_two_side_tprt_both_and_both_consistent(rcd) == False:
                            continue
                    if xtprt_filter.is_polyA_dominant_td(rcd) == True or af_filter.is_qualified_td(rcd)==False:
                        continue
                    if ((ins_chrm in m_td_new ) and (ins_pos in m_td_new[ins_chrm])):
                        if (s_rep_supt_type is not self._one_side) or (b_tumor == True):
                            s_pass_info = rcd[-1].rstrip() + "\t" + s_in_rep + "\n"
                            fout_new.write(s_pass_info)
                        continue

                #this is put after the transduction checking module
                # if b_in_low_div_rep == True:#this is fall in low diverged repeats (by default div_rate<5)
                #     print "{0}:{1} is filtered out, because fall in low div L1 region".format(ins_chrm, ins_pos)
                #     continue

                b_with_polyA = xtprt_filter.has_polyA_signal(rcd)
                min_ins_len=200 #minimum insertion length
                if (b_with_polyA is False) and (xtprt_filter.hit_end_of_cns(rcd)==False): #no polyA, and didn't hit end
                    print("{0}:{1} is filtered out, because no any polyA signal detected!".format(ins_chrm, ins_pos))
                    fout_log.write("{0}:{1} is filtered out, because no any polyA signal detected!\n".format(
                        ins_chrm, ins_pos))
                    continue
                if s_rep_supt_type is self._two_side:####two sides
                    if xtprt_filter.is_polyA_dominant_two_side(rcd) == True \
                            and (xtprt_filter.is_two_side_polyA_same_orientation(rcd) == True) \
                            and xtprt_filter.is_two_side_consist_with_enough_ins_size(rcd, min_ins_len)==False:
                        print("{0}:{1} is filtered out, because two side polyA dominant!".format(ins_chrm, ins_pos))
                        fout_log.write("{0}:{1} is filtered out, because two side polyA dominant!\n".format(
                            ins_chrm, ins_pos))
                        continue
                    if xtprt_filter.hit_end_of_cns(rcd)==False:
                        print("{0}:{1} is filtered out, because doesn't hit the end of consensus!".format(ins_chrm, ins_pos))
                        fout_log.write("{0}:{1} is filtered out, because doesn't hit the end of consensus!\n".format(
                            ins_chrm, ins_pos))
                        continue
                    if af_filter.is_qualified_rcd(rcd[-1], m_cutoff) == False:
                        print("{0}:{1} is filtered out, because AF is not qualified!".format(ins_chrm, ins_pos))
                        fout_log.write("{0}:{1} is filtered out, because AF is not qualified!\n".format(
                            ins_chrm, ins_pos))
                        continue
                    #if b_in_low_div_rep == True:#fall in low diverged copy
                    if (div_rate >= 0) and (div_rate < global_values.REP_DIVERGENT_CUTOFF):
                        #unless "two-side-tprt-both" and "two-side-consistent", then filter out
                        if xtprt_filter.is_two_side_tprt_both_and_both_consistent(rcd, 6000, 200)==False:
                            print("{0}:{1} is filtered out, because fall in low div L1 region".format(ins_chrm, ins_pos))
                            fout_log.write("{0}:{1} is filtered out, because fall in low div L1 region\n".format(
                                ins_chrm, ins_pos))
                            continue
                elif s_rep_supt_type is self._one_half_side:  ##one and half side
                    # check whether fall in repetitive region of the same type
                    if (div_rate >=0) and (div_rate < global_values.REP_DIVERGENT_CUTOFF):
                        print("{0}:{1} is filtered out, because fall in repeat region whose divergent rate is low!".format(
                            ins_chrm, ins_pos))
                        fout_log.write("{0}:{1} is filtered out, because fall in repeat region whose divergent rate is low!\n".format(
                            ins_chrm, ins_pos))
                        continue#self.nclip_half_cutoff
                    if (xtprt_filter.is_polyA_dominant_two_side(rcd) == True) \
                            and (xtprt_filter.is_two_side_polyA_same_orientation(rcd)==True):#both polyA or polyT
                        print("{0}:{1} is filtered out, because two side polyA dominant!".format(ins_chrm, ins_pos))#
                        fout_log.write("{0}:{1} is filtered out, because two side polyA dominant!\n".format(
                            ins_chrm, ins_pos))
                        continue
                elif s_rep_supt_type is self._one_side:  ###one side
                    if (div_rate >=0) and (div_rate < global_values.REP_DIVERGENT_CUTOFF):
                        print("{0}:{1} is filtered out, because fall in repeat region whose divergent rate is low!".format(
                            ins_chrm, ins_pos))
                        fout_log.write("{0}:{1} is filtered out, because fall in repeat region whose divergent rate is low!\n".format(
                            ins_chrm, ins_pos))
                        continue
                        # if xtprt_filter.is_polyA_dominant_one_side(rcd, self.nclip_half_cutoff) is True:
                        #     continue
                else:# for other type, just skip
                    continue

                #if coverage is abnormal (>2 times coverage) or within rep region, but two sides clipped are from polyA
                b_cov_abnormal = xtprt_filter.cov_is_abnormal(rcd, f_cov * self.abnormal_cov_times)
                if ((b_in_rep is True) or (b_cov_abnormal is True)) and \
                                xtprt_filter.is_two_side_clip_and_both_hit_end(rcd, self.REP_LINE_POLYA_START)==True \
                    and (xtprt_filter.is_two_side_polyA_same_orientation(rcd) == True):  #both polyA or polyT:
                    print("{0}:{1} is filtered out, because coverage is abnormal and also two side clip both hit end of consensus!".format(
                        ins_chrm, ins_pos))
                    fout_log.write("{0}:{1} is filtered out, because coverage is abnormal and also two side clip both hit end of consensus!\n".format(
                        ins_chrm, ins_pos))
                    continue

                #if within L1 repeat, but also neither clip side hit the end, then skip
                #this is initially added for 10X
                if (b_in_rep is True) and (xtprt_filter.hit_consensus_tail(rcd, self.REP_LINE_POLYA_START)==False):
                    print("{0}:{1} is filtered out, because fall in repeat region, and none of clip side fall in repeat!".format(
                        ins_chrm, ins_pos))
                    fout_log.write("{0}:{1} is filtered out, because fall in repeat region, and none of clip side fall in repeat!\n".format(
                        ins_chrm, ins_pos))
                    continue

                # n_indel_cutoff = int(f_cov * self.indel_reads_max_ratio)
                # if xtprt_filter.has_enough_indel_reads(rcd, n_indel_cutoff) == True \
                #         and n_indel_cutoff > 0 and b_cov_abnormal == True:
                #     continue
                # save the passed ones
                # l_slct.append(rcd)

                s_pass_info = rcd[-1].rstrip() + "\t" + s_in_rep + "\n"
                fout_new.write(s_pass_info)
####
####
    ####
    # def load_basic_info_samples(self, working_folder):
    #     sf_basic_info = working_folder + global_values.BASIC_INFO_FILE
    #     if os.path.isfile(sf_basic_info)==False:
    #         return None
    #     m_basic_info=self.load_basic_info_from_file(sf_basic_info)
    #     return m_basic_info
    ####

    ####
    def fall_in_low_div_same_type_rep(self, xannotation, ins_chrm, ins_pos, i_cutoff):
        # check all the possible hits, not only the first one
        l_hits = xannotation.is_within_repeat_region_interval_tree2(ins_chrm, int(ins_pos))
        if len(l_hits) <= 0:
            #print ins_chrm, str(ins_pos), "not in repetitive region!"
            return False, -1, -1, -1

        f_lowest_div=-1
        b_hit=False
        copy_start=-1 #this is the position in the reference genome (with the extension)
        copy_end=-1 #this is the position in the reference genome (with the extension)
        cns_start=-1 #start position on the consensus
        cns_end=-1 #end position on the consensus
        for (b_in_rep, i_pos) in l_hits:  # for each hit
            l_family_hits = xannotation.get_div_subfamily_with_min_div2(ins_chrm, i_pos)
            for (div_rate, sub_family, family, pos_start, pos_end) in l_family_hits:
                # print "test1", b_in_rep, i_pos, ins_chrm, ins_pos, div_rate, sub_family, family, pos_start, pos_end
                b_match_rep = True
                # if fall in same type of repetitive region
                if (b_in_rep is True) and (f_lowest_div==-1 or f_lowest_div>div_rate):
####test only!!!!!!!!!!!!
                    #print ins_chrm, str(ins_pos), str(div_rate), sub_family, family, pos_start, pos_end, "debug output"
                    f_lowest_div=div_rate
                    b_hit=True
                    copy_start=pos_start
                    copy_end=pos_end
        if b_hit==True and f_lowest_div<=i_cutoff and f_lowest_div!=-1:
            return True, f_lowest_div, copy_start, copy_end
        return False, f_lowest_div, copy_start, copy_end

####
    def run_post_filtering(self, sf_xtea_rslt, sf_rmsk, i_min_copy_len, i_rep_type, f_cov, sf_black_list,
                           sf_new_out, b_tumor=False):
        #1. for two side cases, filter out the polyA dominant ones
        #2. for single-end cases, filter out those fall in same type of reference copies
        xtea_parser=XTEARsltParser()
        xtea_parser.set_rep_support_type(self._two_side, self._one_half_side, self._one_side, self._other)
        l_old_rcd=xtea_parser.load_in_xTEA_rslt(sf_xtea_rslt)

        xtprt_filter=XTPRTFilter(self.swfolder, self.n_jobs)
        af_filter = AFConflictFilter(self.swfolder, self.n_jobs)
        l_types = af_filter.get_rep_type()
        m_cutoff = af_filter.get_cutoff_by_type(l_types, b_tumor)

        #load in the blacklist regions
        x_blklist=XBlackList()
        x_blklist.load_index_regions(sf_black_list)

####Hard code here !!!!!!!!!!!
        if i_rep_type & 1 is not 0:
            i_min_copy_len=self.L1_min_ref_copy_len #set a smaller value
            sf_td_new_sites=sf_xtea_rslt+global_values.TD_NON_SIBLING_SUFFIX+ global_values.TD_NEW_SITES_SUFFIX
            xannotation = self.construct_interval_tree(sf_rmsk, i_min_copy_len, self.b_rslt_with_chr,
                                                       self.L1_boundary_extnd)
            self.post_processing_L1(l_old_rcd, xtea_parser, xtprt_filter, af_filter, xannotation,
                                    m_cutoff, f_cov, x_blklist, b_tumor, sf_new_out, sf_td_new_sites)
        elif i_rep_type & 4 is not 0:
            xannotation = self.construct_interval_tree(sf_rmsk, i_min_copy_len, self.b_rslt_with_chr)
            self.post_processing_SVA(l_old_rcd, xtea_parser, xtprt_filter, af_filter, xannotation,
                                     m_cutoff, f_cov, x_blklist, b_tumor, sf_new_out)
        else:
            xannotation = self.construct_interval_tree(sf_rmsk, i_min_copy_len, self.b_rslt_with_chr)
            self.post_processing_Alu(l_old_rcd, xtea_parser, xtprt_filter, af_filter, xannotation,
                                     m_cutoff, f_cov, x_blklist, sf_new_out)
####
####

    def construct_interval_tree(self, sf_rmsk, i_min_copy_len, b_with_chr, boundary_extnd=-1):
        if boundary_extnd==-1:
            boundary_extnd=self._boundary_extnd
        xannotation = XAnnotation(sf_rmsk)
        #b_with_chr = True
        xannotation.set_with_chr(b_with_chr)
        xannotation.load_rmsk_annotation_with_extnd_div_with_lenth_cutoff(boundary_extnd, i_min_copy_len)
        xannotation.index_rmsk_annotation_interval_tree()
        return xannotation

    #iflag: type of repeats will work on
    # def run_pos_filter(self, sf_xtea_rslt, i_rep_type, sf_new_out):#run post filtering for each type
    #     l_rep_type=self.parse_rep_type(i_rep_type)
    #     return
    def get_min_copy_len_by_type(self, i_rep_type):
        xrep_type=RepType()
        l_rep_type=xrep_type.parse_out_all_rep_type(i_rep_type)
        l_min_copy_len=[]
        for s_type in l_rep_type:
            if s_type is self.REP_TYPE_ALU:
                l_min_copy_len.append(self.REP_ALU_MIN_LEN)
            elif s_type is self.REP_TYPE_L1:
                l_min_copy_len.append(self.REP_LINE_MIN_LEN)
            elif s_type is self.REP_TYPE_SVA:
                l_min_copy_len.append(self.REP_SVA_MIN_LEN)
            elif s_type is self.REP_TYPE_HERV:
                l_min_copy_len.append(self.REP_HERV_MIN_LEN)
            elif s_type is self.REP_TYPE_MIT:
                l_min_copy_len.append(self.REP_MIT_MIN_LEN)
            elif s_type is self.REP_TYPE_MSTA:
                l_min_copy_len.append(self.REP_MSTA_MIN_LEN)
        return l_min_copy_len

####
class XTEARsltParser():
    def __init__(self):
        self._two_side = "two_side"
        self._one_side = "one_side"
        self._one_half_side = "one_half"
        self._other="other"

    def set_rep_support_type(self, s_two, s_one_half, s_one, s_other):
        self._two_side = s_two
        self._one_side = s_one
        self._one_half_side = s_one_half
        self._other=s_other

    def load_in_xTEA_rslt(self, sf_rslt):
        l_rcd=[]
        with open(sf_rslt) as fin_in:
            for line in fin_in:
                sline=line.rstrip()
                fields = sline.split()
                tmp_rcd=[]
                for s_tmp in fields:
                    tmp_rcd.append(s_tmp)
                tmp_rcd.append(line)#add the last line into list
                l_rcd.append(tmp_rcd)
        return l_rcd

    def dump_xTEA_rslt_to_file(self, l_rcd, sf_rslt):
        with open(sf_rslt, "w") as fout_rslt:
            for rcd in l_rcd:
                if len(rcd)<=0:
                    continue
                fout_rslt.write(rcd[-1])

    def load_in_xTEA_rslt_ori(self, sf_rslt):
        l_rcd=[]
        with open(sf_rslt) as fin_in:
            for line in fin_in:
                sline=line.rstrip()
                fields = sline.split()
                tmp_rcd=[]
                for s_tmp in fields:
                    tmp_rcd.append(s_tmp)
                #tmp_rcd.append(line)#add the last line into list
                l_rcd.append(tmp_rcd)
        return l_rcd
####
    def get_ins_sub_type(self, rcd):
        s_type = rcd[32]
        if ("two_side" in s_type) or ("both-side" in s_type) or ("one_side_and_half_transduction" is s_type):
            return self._two_side
        elif "one_side" in s_type:#
            return self._one_side
        elif ("one_half" in s_type) or ("one-half" in s_type):
            return self._one_half_side
        else:
            return self._other

####
    def replace_ins_length(self, old_rcd, icns_lth):
        # note: the last field of each old_rcd is the whole record in string format
        rcd=[]
        for field in old_rcd[:-2]:
            rcd.append(field)
        new_ins_len=self.estimate_insertion_length(rcd, icns_lth)
        rcd.append(new_ins_len)
        #add the new string line to the end
        s_rcd=str(rcd[0])
        for tmp_field in rcd[1:]:
            s_rcd+=("\t"+str(tmp_field))
        rcd.append(s_rcd)
        return rcd

####
    ####estimate the insertion size
    def estimate_insertion_length(self, rcd, icns_lth):
        i_tei_len = 0
        s_lclip_cluster=rcd[19]
        s_rclip_cluster=rcd[20]
        s_ldisc_cluster=rcd[21]
        s_rdisc_cluster=rcd[22]
        ####
        l_tmp=s_lclip_cluster.split(":")
        i_lclip_start=int(l_tmp[0])
        i_lclip_end=int(l_tmp[1])
        l_tmp2=s_rclip_cluster.split(":")
        i_rclip_start=int(l_tmp2[0])
        i_rclip_end=int(l_tmp2[1])
        l_tmp3=s_ldisc_cluster.split(":")
        i_ldisc_start=int(l_tmp3[0])
        i_ldisc_end=int(l_tmp3[1])
        l_tmp4=s_rdisc_cluster.split(":")
        i_rdisc_start=int(l_tmp4[0])
        i_rdisc_end=int(l_tmp4[1])

        if self.is_transduction(rcd)==False:#not transduction
            if i_lclip_start>0 and i_rclip_start>0:#both clip exist
                i_tei_len=i_rclip_end-i_lclip_start
                if i_tei_len<0:
                    i_tei_len=i_lclip_end-i_rclip_start
            elif i_ldisc_start>0 and i_rdisc_start>0:#both disc exist
                i_tei_len=i_rdisc_end-i_ldisc_start
                if i_tei_len<0:
                    i_tei_len=i_ldisc_end-i_rdisc_start
            elif i_lclip_start>0 and i_ldisc_start>0:#left-clip and left-disc
                i_tei_len=i_ldisc_end-i_lclip_start
                if i_tei_len<0:
                    i_tei_len=i_lclip_end-i_ldisc_start
            elif i_rclip_start>0 and i_rdisc_start>0:#right-clip and right_disc
                i_tei_len=i_rdisc_end-i_rclip_start
                if i_tei_len<0:
                    i_tei_len=i_rclip_end-i_rdisc_start
        else:#transduction
            if i_rdisc_start>0 and i_ldisc_start>0:
                if i_rdisc_start<i_ldisc_start:
                    i_tei_len = icns_lth - i_rdisc_start
                else:
                    i_tei_len = icns_lth - i_ldisc_start
            elif i_rdisc_start<0 and i_ldisc_start>0:
                i_tei_len=icns_lth-i_ldisc_start
            elif i_rdisc_start>0 and i_ldisc_start<0:
                i_tei_len = icns_lth - i_rdisc_start
            else:
                i_tei_len=0

        return abs(i_tei_len)

    ####return both-end/both-side or return one-side
    def get_ins_sub_type_alu(self, rcd):
        n_ef_lclip = int(rcd[5])
        n_ef_rclip = int(rcd[6])
        s_type = rcd[32]
        if ("two_side" in s_type) or ("both-side" in s_type) or ("one_side_and_half_transduction" is s_type):
            return self._two_side
        elif "one_side" in s_type:
            return self._one_side
        elif ("one_half" in s_type) or ("one-half" in s_type):
            if n_ef_lclip>0 and n_ef_rclip>0:
                return self._two_side
            return self._one_half_side
        else:
            return self._other

####
    def get_ins_sub_type_sva(self, rcd):
        s_type = rcd[32]
        if ("two_side" in s_type) or ("both-side" in s_type) or ("one_side_and_half_transduction" is s_type):
            return self._two_side
        elif "one_side" in s_type:#
            return self._one_side
        elif ("one_half" in s_type) or ("one-half" in s_type):
            return self._one_half_side
        else:
            return self._other

    #check all the one side events for sibling TD related events
    def is_sibling_transduction_related_ins(self, rcd):
        s_type = rcd[32]
        if "one_side" in s_type:
            return True
        if "one_half" in s_type:
            return True
        return False

    def get_two_side_coverage_diff(self, rcd):
        return abs(float(rcd[11])-float(rcd[12]))

    def is_transduction(self, rcd):
        s_src=rcd[23]
        if (s_src == "not_transduction") or ("may" in s_src):
            return False
        return True
    ####orphan transduction
    def is_orphan_transduction(self, rcd):
        s_src=rcd[32]
        if "orphan" in s_src:
            return True
        return False

    def get_transduction_source(self, rcd):
        s_src=rcd[23]
        return s_src

    def update_td_info(self, rcd, s_td_info, n_clip, n_disc, n_polyA):
        rcd[23]=s_td_info
        rcd[24]=n_clip
        rcd[25]=n_disc
        rcd[26]=n_polyA

    def update_td_source_only(self, rcd, s_td_info):
        rcd[23]=s_td_info

    # create a new record
    def add_new_rcd(self, ins_chrm, ins_pos, rcd_td_info, gntp_rcd, s_type, f_out):
        # rcd_td_info in format: (n_l_disc, lcns_start, lcns_end, n_r_disc, rcns_start, rcns_end,
        # n_cns_clip, n_polyA_clip, i_lcov2, i_rcov2, s_src)
        sinfo = "{0}\t{1}\t{2}\t-1\t-1\t".format(ins_chrm, ins_pos, ins_pos)
        sinfo1 = "{0}\t{1}\t{2}\t{3}\t{4}\t0\t".format(rcd_td_info[6], 0, rcd_td_info[0], rcd_td_info[3], rcd_td_info[7])
        sinfo2 = "{0}\t{1}\t".format(rcd_td_info[8], rcd_td_info[9])  #
        sinfo3 = "0\t0\t0\t0\t0\t0\t"
        sinfo4 = "-1:-1\t-1:-1\t"+"{0}:{1}\t".format(rcd_td_info[1], rcd_td_info[2])+\
                 "{0}:{1}\t".format(rcd_td_info[4], rcd_td_info[5])
        #print rcd_td_info
        sinfo5 = "{0}\t{1}\t{2}\t{3}\t".format(rcd_td_info[-1], rcd_td_info[6], int(rcd_td_info[0])+int(rcd_td_info[3]),
                                               rcd_td_info[7])
        sinfo6="0\t0\t0\t0\t"+global_values.NOT_FIVE_PRIME_INV\
               +"\t"+s_type+"\t"+global_values.ONE_END_CONSISTNT+"\t"\
               +global_values.HIT_END_OF_CNS+"\t"
        # gntp_rcd in format: (n_af_clip, n_full_map, n_l_raw_clip, n_r_raw_clip, n_disc_pairs, n_concd_pairs,
        # n_disc_large_indel, s_clip_lens, n_polyA, n_disc_chrms)#
        s_tmp=""
        for field in gntp_rcd[:7]:
            s_tmp+=(str(field)+"\t")
        #sinfo7=s_tmp + gntp_rcd[7] + "\t" +"{0}\t{1}\t".format(gntp_rcd[8], gntp_rcd[9])
        sinfo7 = s_tmp + gntp_rcd[7] + "\t"
        sinfo8="0\t0\t0\t0\t0\n"
        f_out.write(sinfo + sinfo1 + sinfo2 + sinfo3 + sinfo4 + sinfo5 + sinfo6 + sinfo7 + sinfo8)

####
####
class XTPRTFilter():
    def __init__(self, swfolder, n_jobs):
        self.swfolder = swfolder
        if self.swfolder[-1] != "/":
            self.swfolder += "/"
        self.n_jobs = n_jobs
########Hard code here!!!!!!!!!!!!!!!!!!!
        self.f_side_polyA_cutoff=global_values.ONE_SIDE_POLYA_CUTOFF
        ####

####n_clip is clip reads cutoff
    ####both side are polyA, even though are two-side-tprt-both
    ####Will NOT filter out those left and right clipped reads form different cluster
    def is_polyA_dominant_two_side(self, rcd):
        f_cutoff = self.f_side_polyA_cutoff
        n_lpolyA = int(rcd[9])
        n_rpolyA = int(rcd[10])
        n_ef_lclip=int(rcd[5])
        n_ef_rclip=int(rcd[6])
        s_type = rcd[32]
        #n_ef_clip = n_ef_lclip + n_ef_rclip
        if n_ef_lclip <= 0 or n_ef_rclip<=0:
            return False

        if self._is_two_clip_form_different_cluster(rcd)==True:
            return False

        if (global_values.TWO_SIDE_TPRT_BOTH in s_type) and (self._is_two_disc_form_different_cluster(rcd)==True):
            return False

        b_lpolyA= ((float(n_lpolyA) / float(n_ef_lclip)) > f_cutoff)
        b_rpolyA = ((float(n_rpolyA) / float(n_ef_rclip)) > f_cutoff)
        if b_lpolyA and b_rpolyA:
            return True
        return False

    #if both sides of the clipped reads are of the same direction (both polyA, or both polyT), then return True
    def is_two_side_polyA_same_orientation(self, rcd):
        b_same_ori=True
        n_lpolyA_seqa=int(rcd[17])
        n_rpolyA_seqa = int(rcd[18])
        if (n_lpolyA_seqa*n_rpolyA_seqa)>0:#same orientation
            return b_same_ori
        return False

    #for trandsduction filtering
    def is_polyA_dominant_td(self, rcd):
        f_cutoff = global_values.MAX_POLYA_RATIO
        n_lpolyA = int(rcd[9])
        n_rpolyA = int(rcd[10])
        n_ef_lclip=int(rcd[5])
        n_ef_rclip=int(rcd[6])
        s_type = rcd[32]
        if (global_values.TWO_SIDE_TPRT_BOTH in s_type):
            return False

        b_lpolyA=True
        if n_ef_lclip!=0:
            b_lpolyA= ((float(n_lpolyA) / float(n_ef_lclip)) > f_cutoff)
        b_rpolyA=True
        if n_ef_rclip!=0:
            b_rpolyA = ((float(n_rpolyA) / float(n_ef_rclip)) > f_cutoff)
        if b_lpolyA and b_rpolyA:
            return True
        return False

    ###add this filtering, because within L1, there are polyA like regions. It has two-side-polyA signal from algnmt.
    # We need to exclude these insertions
    def is_two_side_consist_with_enough_ins_size(self, rcd, min_ins_len):
        s_consist=rcd[33]
        s_lclip_cluster = rcd[19]
        s_rclip_cluster = rcd[20]
        ll_fields = s_lclip_cluster.split(":")
        i_lstart = int(ll_fields[0])
        i_lend = int(ll_fields[1])
        lr_fields = s_rclip_cluster.split(":")
        i_rstart = int(lr_fields[0])
        i_rend = int(lr_fields[1])
        if s_consist==global_values.BOTH_END_CONSISTNT \
                and (abs(i_lstart-i_rend)>min_ins_len or abs(i_rstart-i_lend)>min_ins_len):
            return True
        return False

    def is_two_side_tprt_both_and_both_consistent(self, rcd, i_cns_tail=5950, min_ins_len=100):
        s_type = rcd[32]
        s_consist = rcd[33]

        #left, right clip cluster
        s_lclip_cluster = rcd[19]
        s_rclip_cluster = rcd[20]
        ll_fields = s_lclip_cluster.split(":")
        i_lstart = int(ll_fields[0])
        i_lend = int(ll_fields[1])
        lr_fields = s_rclip_cluster.split(":")
        i_rstart = int(lr_fields[0])
        i_rend = int(lr_fields[1])

        #left, right discordant cluster
        s_ldisc_cluster = rcd[21]
        s_rdisc_cluster = rcd[22]
        lld_fields = s_ldisc_cluster.split(":")
        i_ldstart = int(lld_fields[0])
        i_ldend = int(lld_fields[1])
        lrd_fields = s_rdisc_cluster.split(":")
        i_rdstart = int(lrd_fields[0])
        i_rdend = int(lrd_fields[1])

        #both should hit the end, otherwise return False
        if (i_lend<i_cns_tail and i_rend<i_cns_tail) or (i_ldend<i_cns_tail and i_rdend<i_cns_tail):
            return False
        if(abs(i_lstart - i_rend) < min_ins_len and abs(i_rstart - i_lend) < min_ins_len):
            return False

        if (global_values.TWO_SIDE_TPRT_BOTH in s_type) and (s_consist==global_values.BOTH_END_CONSISTNT):
            return True
        return False

    ####n_clip is clip reads cutoff
    ####both side are polyA, even though are two-side-tprt-both
    def is_polyA_dominant_two_side_sva(self, rcd, i_pos_head):
        f_cutoff = self.f_side_polyA_cutoff
        n_lpolyA = int(rcd[9])
        n_rpolyA = int(rcd[10])
        n_ef_lclip = int(rcd[5])
        n_ef_rclip = int(rcd[6])
        s_type = rcd[32]
        # n_ef_clip = n_ef_lclip + n_ef_rclip
        if n_ef_lclip <= 0 or n_ef_rclip <= 0:
            return False

        if (global_values.TWO_SIDE_TPRT_BOTH in s_type) and (self._disc_cluster_hit_cns_head(rcd, i_pos_head)==True):
            return False

        b_lpolyA = ((float(n_lpolyA) / float(n_ef_lclip)) > f_cutoff)
        b_rpolyA = ((float(n_rpolyA) / float(n_ef_rclip)) > f_cutoff)
        if b_lpolyA and b_rpolyA:
            return True
        return False


    ####two side clip, and both hit the end of the tail (polyA started region)
    def is_two_side_clip_both_polyA_sva(self, rcd, i_cns_tail):
        s_lclip_cluster = rcd[19]
        s_rclip_cluster = rcd[20]
        if ("-1" in s_lclip_cluster) or ("-1" in s_rclip_cluster):
            return False
        ll_fields = s_lclip_cluster.split(":")
        i_lstart = int(ll_fields[0])
        i_lend = int(ll_fields[1])
        lr_fields = s_rclip_cluster.split(":")
        i_rstart = int(lr_fields[0])
        i_rend = int(lr_fields[1])
        if i_lstart>=i_cns_tail and i_rstart>=i_cns_tail:
            return True
        return False

    ####
    def is_two_side_clip_both_non_polyA_sva(self, rcd, i_cns_tail):
        s_lclip_cluster = rcd[19]
        s_rclip_cluster = rcd[20]
        if ("-1" in s_lclip_cluster) or ("-1" in s_rclip_cluster):
            return False
        ll_fields = s_lclip_cluster.split(":")
        i_lstart = int(ll_fields[0])
        i_lend = int(ll_fields[1])
        lr_fields = s_rclip_cluster.split(":")
        i_rstart = int(lr_fields[0])
        i_rend = int(lr_fields[1])
        if i_lstart<i_cns_tail and i_rstart<i_cns_tail:
            return True
        return False

    ####if both left and right clipped reads form effective clusters
    ####two clusters are quite far from each other, then return True
    ####If one side is -1:-1, also return True
    def _is_two_clip_form_different_cluster(self, rcd):
        s_lclip_cluster=rcd[19]
        s_rclip_cluster=rcd[20]
        if ("-1" in s_lclip_cluster) or ("-1" in s_rclip_cluster):
            return True
        ll_fields=s_lclip_cluster.split(":")
        i_lstart=int(ll_fields[0])
        i_lend=int(ll_fields[1])
        lr_fields=s_rclip_cluster.split(":")
        i_rstart=int(lr_fields[0])
        i_rend=int(lr_fields[1])
        if abs(i_lend-i_rstart)<global_values.TWO_CLIP_CLUSTER_DIFF_CUTOFF \
                or abs(i_rend-i_lstart)<global_values.TWO_CLIP_CLUSTER_DIFF_CUTOFF:
            return False
        return True

    def _is_two_disc_form_different_cluster(self, rcd):
        s_ldisc_cluster = rcd[21]
        s_rdisc_cluster = rcd[22]
        if ("-1" in s_ldisc_cluster) or ("-1" in s_rdisc_cluster):
            return True
        ll_fields = s_ldisc_cluster.split(":")
        i_lstart = int(ll_fields[0])
        i_lend = int(ll_fields[1])
        lr_fields = s_rdisc_cluster.split(":")
        i_rstart = int(lr_fields[0])
        i_rend = int(lr_fields[1])
        if abs(i_lend - i_rstart) < global_values.TWO_CLIP_CLUSTER_DIFF_CUTOFF \
                or abs(i_rend - i_lstart) < global_values.TWO_CLIP_CLUSTER_DIFF_CUTOFF:
            return False
        return True

    def _disc_cluster_hit_cns_head(self, rcd, i_pos_head):
        s_ldisc_cluster = rcd[21]
        s_rdisc_cluster = rcd[22]
        if ("-1" in s_ldisc_cluster) or ("-1" in s_rdisc_cluster):
            return False
        ll_fields = s_ldisc_cluster.split(":")
        i_lstart = int(ll_fields[0])
        i_lend = int(ll_fields[1])
        lr_fields = s_rdisc_cluster.split(":")
        i_rstart = int(lr_fields[0])
        i_rend = int(lr_fields[1])
        if i_lstart<i_pos_head or i_rstart<i_pos_head:
            return True
        return False

    def has_polyA_signal(self, rcd):
        n_lpolyA = int(rcd[9])
        n_rpolyA = int(rcd[10])
        if n_lpolyA<=0 and n_rpolyA<=0:
            return False
        return True

####
    ####if one side is purly polyA, and the other side has raw clipped reads, but none aligned
    ####then this is viewed as a polyA dominant one
    def is_polyA_dominant_one_side(self, rcd, nclip_half_cutoff):
        f_cutoff = self.f_side_polyA_cutoff
        n_lpolyA = int(rcd[9])
        n_rpolyA = int(rcd[10])
        n_ef_lclip = int(rcd[5])
        n_ef_rclip = int(rcd[6])
        n_lr_clip = int(rcd[35])  # all qualified clipped reads

        if n_ef_lclip<=0 and n_ef_rclip<=0:#no effective clipped reads on both sides, then skip
            return True

        b_l_no_signal=False
        if n_ef_lclip<=0:#
            b_l_no_signal=True
        b_r_no_signal = False
        if n_ef_rclip <= 0:#
            b_r_no_signal = True
####Potential bug here: if one side has large number of clipped reads, but small number ef clipped reads,
####then, it's still possible the other side have no or little clipped reads

        if b_l_no_signal is True:#left no signal
            b_rpolyA = ((float(n_rpolyA) / float(n_ef_rclip)) > f_cutoff)
            if (b_rpolyA is True) and ((n_lr_clip-n_ef_rclip)>=nclip_half_cutoff):
                return True
        if b_r_no_signal is True:
            b_lpolyA = ((float(n_lpolyA) / float(n_ef_lclip)) > f_cutoff)
            if (b_lpolyA is True) and ((n_lr_clip-n_ef_lclip)>=nclip_half_cutoff):
                return True
        return False
####

    def is_two_side_tprt_and_with_polyA(self, rcd, i_cns_end):####
        s_type = rcd[32]
        if global_values.TWO_SIDE_TPRT in s_type:
            s_lclip_cluster = rcd[19]
            s_rclip_cluster = rcd[20]
            if ("-1" in s_lclip_cluster) or ("-1" in s_rclip_cluster):
                return False
            ll_fields = s_lclip_cluster.split(":")
            i_lstart = int(ll_fields[0])
            i_lend = int(ll_fields[1])
            lr_fields = s_rclip_cluster.split(":")
            i_rstart = int(lr_fields[0])
            i_rend = int(lr_fields[1])
            if i_lend>i_cns_end or i_rend>i_cns_end:
                return True
        return False

    ####
    def is_two_side_clip_and_both_hit_end(self, rcd, i_cns_end):
        s_lclip_cluster = rcd[19]
        s_rclip_cluster = rcd[20]
        if ("-1" in s_lclip_cluster) or ("-1" in s_rclip_cluster):
            return False
        ll_fields = s_lclip_cluster.split(":")
        i_lstart = int(ll_fields[0])
        i_lend = int(ll_fields[1])
        lr_fields = s_rclip_cluster.split(":")
        i_rstart = int(lr_fields[0])
        i_rend = int(lr_fields[1])
        if i_lstart>i_cns_end and i_rstart>i_cns_end:
            return True
        return False

    def hit_consensus_tail(self, rcd, i_cns_end):
        s_lclip_cluster = rcd[19]
        s_rclip_cluster = rcd[20]
        if ("-1" in s_lclip_cluster) or ("-1" in s_rclip_cluster):
            return True
        ll_fields = s_lclip_cluster.split(":")
        i_lstart = int(ll_fields[0])
        i_lend = int(ll_fields[1])
        lr_fields = s_rclip_cluster.split(":")
        i_rstart = int(lr_fields[0])
        i_rend = int(lr_fields[1])
        if i_lend>=i_cns_end or i_rend>=i_cns_end:
            return True
        return False
####
    def hit_end_of_cns(self, rcd):
        s_hit_end=rcd[34]
        if global_values.HIT_END_OF_CNS == s_hit_end:
            return True
        else:
            return False
####
    def has_enough_indel_reads(self, rcd, ncutoff):
        n_indel_reads=int(rcd[41])
        if n_indel_reads > ncutoff:
            return True
        else:
            return False

    #coverage is abnormal
    def cov_is_abnormal(self, rcd, f_cutoff):
        f_lcov=float(rcd[11])
        f_rcov=float(rcd[12])
        if f_lcov>f_cutoff or f_rcov>f_cutoff:
            return True
        return False

    def fall_in_or_close_repetitive_region(self, rcd):
        s_rep=rcd[48]
        if "not" in s_rep:
            return False
        return True

####
class AFConflictFilter():
    def __init__(self, swfolder, n_jobs):
        self.swfolder = swfolder
        if self.swfolder[-1] != "/":
            self.swfolder += "/"
        self.n_jobs = n_jobs

    ####
    def get_rep_type(self):
        l_types = []
        l_types.append(global_values.ONE_SIDE_FLANKING)
        l_types.append(global_values.TWO_SIDE)
        l_types.append(global_values.TWO_SIDE_TPRT_BOTH)
        l_types.append(global_values.TWO_SIDE_TPRT)
        l_types.append(global_values.ONE_HALF_SIDE)
        l_types.append(global_values.ONE_HALF_SIDE_TRPT_BOTH)
        l_types.append(global_values.ONE_HALF_SIDE_TRPT)
        l_types.append(global_values.ONE_HALF_SIDE_POLYA_DOMINANT)
        l_types.append(global_values.ONE_SIDE)
        l_types.append(global_values.ONE_SIDE_COVERAGE_CONFLICT)
        l_types.append(global_values.ONE_SIDE_TRSDCT)
        l_types.append(global_values.ONE_SIDE_WEAK)
        l_types.append(global_values.ONE_SIDE_OTHER)
        l_types.append(global_values.ONE_SIDE_SV)
        l_types.append(global_values.ONE_SIDE_POLYA_DOMINANT)
        l_types.append(global_values.TWO_SIDE_POLYA_DOMINANT)
        l_types.append(global_values.HIGH_COV_ISD)
        l_types.append(global_values.OTHER_TYPE)
        return l_types

####
    ####
    def get_cutoff_by_type(self, l_types, b_tumor=False):
        m_cutoff = {}
        for s_type in l_types:
            if b_tumor==True:
                m_cutoff[s_type] = (0.001, 0.001, 0.001, 0.001)
                continue
            if ("two_side" in s_type) or ("both-side" in s_type) or (global_values.ONE_SIDE_TRSDCT is s_type):
                m_cutoff[s_type] = (0.075, 0.075, 0.075, 0.075)
            elif "one_side" in s_type:  #
                m_cutoff[s_type] = (0.075, 0.075, 0.075, 0.075)
            elif ("one_half" in s_type) or ("one-half" in s_type):
                m_cutoff[s_type] = (0.075, 0.075, 0.075, 0.075)
            else:
                m_cutoff[s_type] = (0.075, 0.075, 0.075, 0.075)
        return m_cutoff

    def is_qualified_td(self, rcd):
        n_disc = int(rcd[39])
        n_concod = int(rcd[40])
        f_disc_concod = 0.0
        if (n_disc + n_concod) != 0:
            f_disc_concod = float(n_disc) / float(n_disc + n_concod)
        if f_disc_concod<0.08:
            return False
        return True

    def is_qualified_rcd(self, s_line, m_cutoff):
        fields = s_line.split()
        n_lpolyA = int(fields[9])
        n_rpolyA = int(fields[10])

        n_ef_clip = int(fields[5]) + int(fields[6])
        n_ef_disc = int(fields[7]) + int(fields[8])
        n_clip = int(fields[35])
        n_full_map = int(fields[36])
        n_disc = int(fields[39])
        n_concod = int(fields[40])

        f_ef_clip = 0.0
        if n_clip != 0:
            f_ef_clip = float(n_ef_clip) / float(n_clip)
        f_ef_disc = 0.0
        if n_disc != 0:
            f_ef_disc = float(n_ef_disc) / float(n_disc)
        f_clip_full_map = 0.0
        if (n_clip + n_full_map) != 0:
            f_clip_full_map = float(n_clip) / float(n_clip + n_full_map)
        f_disc_concod = 0.0
        if (n_disc + n_concod) != 0:
            f_disc_concod = float(n_disc) / float(n_disc + n_concod)

        s_type_ins = fields[32]
        b_pass = self.is_ins_pass_cutoff(m_cutoff, s_type_ins, f_ef_clip, f_ef_disc, f_clip_full_map, f_disc_concod)
        return b_pass
####

    ####
    def is_ins_pass_cutoff(self, m_cutoff, s_type, f_ef_clip, f_ef_disc, f_clip_full_map, f_disc_concod):
        (f_ef_clip_cutoff, f_ef_disc_cutoff, f_clip_full_cutoff, f_disc_concod_cutoff) = m_cutoff[s_type]
        b_ef_clip = (f_ef_clip > f_ef_clip_cutoff)
        b_ef_disc = f_ef_disc > f_ef_disc_cutoff
        b_clip_full = f_clip_full_map > f_clip_full_cutoff
        b_disc_concd = f_disc_concod > f_disc_concod_cutoff
        b_pass = b_ef_clip and b_ef_disc and b_clip_full and b_disc_concd
        return b_pass

    ####
    def is_qualified_mosaic_rcd(self, s_line, m_cutoff):
        fields = s_line.split()
        n_lpolyA = int(fields[9])
        n_rpolyA = int(fields[10])

        n_ef_clip = int(fields[5]) + int(fields[6])
        n_ef_disc = int(fields[7]) + int(fields[8])
        n_clip = int(fields[35])
        n_full_map = int(fields[36])
        n_disc = int(fields[39])
        n_concod = int(fields[40])

        f_ef_clip = 0.0
        if n_clip != 0:
            f_ef_clip = float(n_ef_clip) / float(n_clip)
        f_ef_disc = 0.0
        if n_disc != 0:
            f_ef_disc = float(n_ef_disc) / float(n_disc)
        f_clip_full_map = 0.0
        if (n_clip + n_full_map) != 0:
            f_clip_full_map = float(n_clip) / float(n_clip + n_full_map)
        f_disc_concod = 0.0
        if (n_disc + n_concod) != 0:
            f_disc_concod = float(n_disc) / float(n_disc + n_concod)

        s_type_ins = fields[32]
        b_pass = self.is_ins_pass_mosaic_cutoff(m_cutoff, s_type_ins, f_ef_clip, f_ef_disc, f_clip_full_map, f_disc_concod)
        #print n_ef_clip, n_ef_disc, n_clip, n_full_map, n_disc, n_concod, f_ef_clip, f_ef_disc, f_clip_full_map, f_disc_concod, b_pass
        return b_pass
####
    ####
    def is_ins_pass_mosaic_cutoff(self, m_cutoff, s_type, f_ef_clip, f_ef_disc, f_clip_full_map, f_disc_concod):
        # (f_ef_clip_cutoff, f_ef_disc_cutoff, f_clip_full_cutoff, f_disc_concod_cutoff) = m_cutoff[s_type]
        # b_ef_clip = (f_ef_clip > f_ef_clip_cutoff)
        # b_ef_disc = f_ef_disc > f_ef_disc_cutoff
        # b_clip_full = f_clip_full_map > f_clip_full_cutoff
        # b_disc_concd = f_disc_concod > f_disc_concod_cutoff
        #b_pass = b_ef_clip and b_ef_disc and b_clip_full and b_disc_concd
        (f_upper_af, f_lower_af) = m_cutoff[s_type]
        b_clip_af_qualified=False
        if f_clip_full_map>=f_lower_af and f_clip_full_map<=f_upper_af:
            b_clip_af_qualified = True
        b_disc_concd = True
        if f_disc_concod>f_upper_af:
            b_disc_concd=False
        b_pass=(b_clip_af_qualified and b_disc_concd)
        return b_pass

    ####
    def filter_by_af_conflict(self, sf_hc, n_clip_cutoff, n_disc_cutoff):
        l_types = self.get_rep_type()
        m_cutoff = self.get_cutoff_by_type(l_types)
        self.calc_ratio(m_cutoff, n_clip_cutoff, n_disc_cutoff, sf_hc)
    ####
    def calc_ratio(self, m_cutoff, n_clip_cutoff, n_disc_cutoff, sf_in):
        sf_out = sf_in + ".after_filter"
        with open(sf_in) as fin_in, open(sf_out, "w") as fout_af_filter:
            n_total = 0
            n_hard_pass = 0
            n_pass = 0
            for line in fin_in:
                fields = line.split()
                n_lpolyA = int(fields[9])
                n_rpolyA = int(fields[10])

                n_ef_clip = int(fields[5]) + int(fields[6])
                n_ef_disc = int(fields[7]) + int(fields[8])
                n_clip = int(fields[35])
                n_full_map = int(fields[36])
                n_disc = int(fields[39])
                n_concod = int(fields[40])
                n_total += 1

                if n_ef_clip < n_clip_cutoff:
                    print("ef_clip", line)
                    continue
                if n_ef_disc < n_disc_cutoff:
                    print("ef_disc", line)
                    continue
                if n_lpolyA + n_rpolyA < 1:
                    print("no polyA", line)
                    continue

                n_hard_pass += 1

                f_ef_clip = 0.0
                if n_clip != 0:
                    f_ef_clip = float(n_ef_clip) / float(n_clip)
                f_ef_disc = 0.0
                if n_disc != 0:
                    f_ef_disc = float(n_ef_disc) / float(n_disc)
                f_clip_full_map = 0.0
                if (n_clip + n_full_map) != 0:
                    f_clip_full_map = float(n_clip) / float(n_clip + n_full_map)
                f_disc_concod = 0.0
                if (n_disc + n_concod) != 0:
                    f_disc_concod = float(n_disc) / float(n_disc + n_concod)

                s_type_ins = fields[32]
                b_pass = self.is_ins_pass_cutoff(m_cutoff, s_type_ins, f_ef_clip, f_ef_disc, f_clip_full_map, f_disc_concod)

                if b_pass is True:
                    n_pass += 1
                    fout_af_filter.write(line)
                else:
                    s = 1
                    print(line.rstrip())
            print(n_hard_pass, n_pass, n_total)
####