####
##04/23/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

#This module is designed for mosaic TE insertion calling from normal bulk tissue.
# Assume the insertions happen at low AF (say <1%).
# The data is sequenced at high coverage (say >200X), and low cutoff is set (say 2 disc and 2 clip)

####1. add blacklist, like gnomAD-SV
####2. filter with callset from other samples
####3. screenshot discordant and clipped reads only
####

from x_post_filter import *
from x_somatic_calling import *

####
####this is inherited from XPostFilter class
class MosaicCaller(XPostFilter):
    def __init__(self, swfolder, n_jobs):
        XPostFilter.__init__(self, swfolder, n_jobs)
        self.brkpnt_slack=100

    ####This is assume the input is generated from high coverage data (with low cutoff)
    # def call_mosaic_high_coverage_output(self, sf_in):
    #     xtea_rslt=XTEARsltParser()
    #     l_rcd=xtea_rslt.load_in_xTEA_rslt(sf_in)

    def run_call_mosaic(self, sf_xtea_rslt, sf_rmsk, i_min_copy_len, i_rep_type, sf_black_list, sf_new_out):
        xtea_parser = XTEARsltParser()
        xtea_parser.set_rep_support_type(self._two_side, self._one_half_side, self._one_side, self._other)
        l_old_rcd = xtea_parser.load_in_xTEA_rslt(sf_xtea_rslt)
        xannotation = self.construct_interval_tree(sf_rmsk, i_min_copy_len, self.b_rslt_with_chr)
        xtprt_filter = XTPRTFilter(self.swfolder, self.n_jobs)
        af_filter = AFConflictFilter(self.swfolder, self.n_jobs)
        l_types = af_filter.get_rep_type()
        m_cutoff = self.get_AF_cutoff(l_types)

        ####Hard code here !!!!!!!!
        sf_new_out_bf_black_list=sf_new_out+".before_blacklist.txt"
        if (i_rep_type & 1) is not 0:
            self.call_mosaic_L1_from_bulk(l_old_rcd, xtea_parser, xtprt_filter, af_filter, xannotation, m_cutoff,
                                          sf_new_out_bf_black_list)
        elif (i_rep_type & 2) is not 0:
            self.call_mosaic_Alu_from_bulk(l_old_rcd, xtea_parser, xtprt_filter, af_filter, xannotation, m_cutoff,
                                     sf_new_out_bf_black_list)
        elif (i_rep_type & 4) is not 0:
            self.call_mosaic_SVA_from_bulk(l_old_rcd, xtea_parser, xtprt_filter, af_filter, xannotation, m_cutoff,
                                     sf_new_out_bf_black_list)

        ##go through blacklist to filter out germline cases
        self.filter_by_blacklist(sf_new_out_bf_black_list, sf_black_list, self.brkpnt_slack, sf_new_out)
####
####
    def call_mosaic_L1_from_bulk(self, l_old_rcd, xtea_parser, xtprt_filter, af_filter, xannotation, m_cutoff, sf_new_out):
        with open(sf_new_out, "w") as fout_new:
            for rcd in l_old_rcd:
                s_rep_supt_type = xtea_parser.get_ins_sub_type(rcd)
                ins_chrm = rcd[0]
                ins_pos = rcd[1]
                b_in_rep, i_pos = xannotation.is_within_repeat_region_interval_tree(ins_chrm, int(ins_pos))
                b_with_polyA = xtprt_filter.has_polyA_signal(rcd)
                if b_with_polyA is False:
                    continue
                if af_filter.is_qualified_mosaic_rcd(rcd[-1], m_cutoff) == False:
                    continue
                if s_rep_supt_type is self._two_side:  ####two sides
                    if xtprt_filter.is_polyA_dominant_two_side(rcd) == True:
                        continue
                elif s_rep_supt_type is self._one_half_side:  ##one and half side
                    # check whether fall in repetitive region of the same type
                    if b_in_rep is True:
                        continue
                    if xtprt_filter.is_polyA_dominant_two_side(rcd) is True:
                        continue
                elif s_rep_supt_type is self._one_side:###one side
                    if b_in_rep is True:
                        continue
                        # if xtprt_filter.is_polyA_dominant_one_side(rcd, self.nclip_half_cutoff) is True:
                        #     continue
                else:  # for other type, just skip
                    continue
                # save the passed ones
                # l_slct.append(rcd)
                s_in_rep = "not_in_LINE1_copy"
                if b_in_rep is True:
                    s_in_rep = "Fall_in_LINE1_copy"
                s_pass_info = rcd[-1].rstrip() + "\t" + s_in_rep + "\n"
                fout_new.write(s_pass_info)
####
####
    def call_mosaic_Alu_from_bulk(self, l_old_rcd, xtea_parser, xtprt_filter,
                                  af_filter, xannotation, m_cutoff, sf_new_out):
        with open(sf_new_out, "w") as fout_new:
            for rcd in l_old_rcd:
                s_rep_supt_type = xtea_parser.get_ins_sub_type(rcd)
                ins_chrm = rcd[0]
                ins_pos = rcd[1]
                b_in_rep, i_pos = xannotation.is_within_repeat_region_interval_tree(ins_chrm, int(ins_pos))
                b_with_polyA = xtprt_filter.has_polyA_signal(rcd)
                if b_with_polyA is False:
                    continue
                if af_filter.is_qualified_mosaic_rcd(rcd[-1], m_cutoff) == False:
                    continue
                if s_rep_supt_type is self._two_side:  ####two sides
                    if xtprt_filter.is_polyA_dominant_two_side(rcd) == True:
                        continue
                elif s_rep_supt_type is self._one_half_side:  ##one and half side
                    # check whether fall in repetitive region of the same type
                    if b_in_rep is True:
                        continue
                    if xtprt_filter.is_polyA_dominant_two_side(rcd) is True:
                        continue
                elif s_rep_supt_type is self._one_side:  ###one side
                    if b_in_rep is True:
                        continue
                        # if xtprt_filter.is_polyA_dominant_one_side(rcd, self.nclip_half_cutoff) is True:
                        #     continue
                else:  # for other type, just skip
                    continue
                # save the passed ones
                # l_slct.append(rcd)
                s_in_rep = "not_in_Alu_copy"
                if b_in_rep is True:
                    s_in_rep = "Fall_in_Alu_copy"
                s_pass_info = rcd[-1].rstrip() + "\t" + s_in_rep + "\n"
                fout_new.write(s_pass_info)

####
    def call_mosaic_SVA_from_bulk(self, l_old_rcd, xtea_parser, xtprt_filter,
                                  af_filter, xannotation, m_cutoff, sf_new_out):
        with open(sf_new_out, "w") as fout_new:
            for rcd in l_old_rcd:
                s_rep_supt_type = xtea_parser.get_ins_sub_type(rcd)
                ins_chrm = rcd[0]
                ins_pos = rcd[1]
                b_in_rep, i_pos = xannotation.is_within_repeat_region_interval_tree(ins_chrm, int(ins_pos))
                b_with_polyA = xtprt_filter.has_polyA_signal(rcd)
                if b_with_polyA is False:
                    continue
                if af_filter.is_qualified_mosaic_rcd(rcd[-1], m_cutoff) == False:
                    continue
                if s_rep_supt_type is self._two_side:  ####two sides
                    if xtprt_filter.is_polyA_dominant_two_side(rcd) == True:
                        continue
                elif s_rep_supt_type is self._one_half_side:  ##one and half side
                    # check whether fall in repetitive region of the same type
                    if b_in_rep is True:
                        continue
                    # if xtprt_filter.is_polyA_dominant_two_side(rcd) is True:
                    #     continue
                elif s_rep_supt_type is self._one_side:  ###one side
                    if b_in_rep is True:
                        continue
                        # if xtprt_filter.is_polyA_dominant_one_side(rcd, self.nclip_half_cutoff) is True:
                        #     continue
                else:  # for other type, just skip
                    continue
                # save the passed ones
                # l_slct.append(rcd)
                s_in_rep = "not_in_SVA_copy"
                if b_in_rep is True:
                    s_in_rep = "Fall_in_SVA_copy"
                s_pass_info = rcd[-1].rstrip() + "\t" + s_in_rep + "\n"
                fout_new.write(s_pass_info)
####
####
    def get_AF_cutoff(self, l_types):
        m_cutoff = {}
        for s_type in l_types:
            if ("two_side" in s_type) or ("both-side" in s_type) or ("one_side_and_half_transduction" is s_type):
                m_cutoff[s_type] = (0.35,0.02)
            elif "one_side" in s_type:#
                m_cutoff[s_type] = (0.35,0.02)
            elif ("one_half" in s_type) or ("one-half" in s_type):
                m_cutoff[s_type] = (0.35,0.02)
            else:
                m_cutoff[s_type] = (0.35,0.02)
        return m_cutoff

####
    def filter_by_blacklist(self, sf_in, sf_black_list, i_slack, sf_out):
        sf_tmp=None
        somatic_caller=SomaticMEICaller(sf_tmp)
        m_MEIs=somatic_caller.load_sites(sf_in)
        m_pass=somatic_caller.filter_by_given_list(sf_black_list, m_MEIs, i_slack)
        somatic_caller.export_slcted_candidates(m_pass, sf_out)

####