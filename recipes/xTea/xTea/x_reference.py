##09/05/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

#Two classes are defined in this script:
#XReference and XChromosome

import os
import sys
import pysam
from subprocess import *
from multiprocessing import Pool
from x_sites import *
import global_values
from cmd_runner import *

####
class XChromosome():
    def is_decoy_contig_chrms(self, chrm):
        fields = chrm.split("_")
        if len(fields) > 1:
            return True
        elif chrm == "hs37d5":
            return True

        if len(chrm)>3 and ((chrm[:3] is "HLA") or (chrm[:3] is "HPV") or (chrm[:3] is "HIV") or (chrm[:3] is "CMV")
                            or (chrm[:3] is "CMV") or (chrm[:3] is "MCV") or (chrm[:2] is "SV") or (chrm[:4] is "KSHV")
                            or (chrm[:5] is "decoy") or (chrm[:6] is "random")):#this is some special fields in the bam file
            return True
        fields=chrm.split("-")
        if len(fields)>1:
            return True

        if ("hs38" in chrm) or ("hs37" in chrm):
            return True
####
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

def unwrap_gnrt_flank_regions(arg, **kwarg):
    return XReference.run_gnrt_flank_region_for_chrm(*arg, **kwarg)
def unwrap_gnrt_flank_regions_for_regions(arg, **kwarg):
    return XReference.run_gnrt_flank_region_for_regions_by_chrm(*arg, **kwarg)

def unwrap_gnrt_target_regions(arg, **kwarg):
    return XReference.run_gnrt_target_region_for_chrm(*arg, **kwarg)


class XReference():
    def __init__(self):
        self.cmd_runner = CMD_RUNNER()

    ## "self.b_with_chr" is the format gotten from the alignment file
    ## all other format should be changed to consistent with the "b_with_chr"
    def process_chrm_name(self, chrm, b_with_chr):
        b_chrm_with_chr = False
        if len(chrm) > 3 and chrm[:3] == "chr":  ##Here remove the "chr"
            b_chrm_with_chr = True

        # print chrm, self.b_with_chr, b_chrm_with_chr ###############################################################
        if b_with_chr == True and b_chrm_with_chr == True:
            return chrm
        elif b_with_chr == True and b_chrm_with_chr == False:
            return "chr" + chrm
        elif b_with_chr == False and b_chrm_with_chr == True:
            return chrm[3:]
        else:
            return chrm

####
    # gnrt the left and right flank regions for each candidate site
    def run_gnrt_flank_region_for_chrm(self, record):
        chrm = record[0]
        sf_sites = record[1]
        sf_ref = record[2]
        i_extend = abs(int(record[3]))
        working_folder = record[4]
        if working_folder[-1] != "/":
            working_folder += "/"
        b_left=record[5]
        b_right=record[6]

        xsites = XSites(sf_sites)
        m_sites = xsites.load_in_sites()
        f_fa = pysam.FastaFile(sf_ref)
        m_ref_chrms = {}
        for tmp_chrm in f_fa.references:
            m_ref_chrms[tmp_chrm] = 1
        b_with_chr = False
        if "chr1" in m_ref_chrms:
            b_with_chr = True

        for pos in m_sites[chrm]:
            if pos - i_extend < 0:
                continue
            istart = pos - i_extend
            iend = pos + i_extend

            ref_chrm = self.process_chrm_name(chrm, b_with_chr)
            s_left_region = f_fa.fetch(ref_chrm, istart, pos)
            s_right_region = f_fa.fetch(ref_chrm, pos + 1, iend)

            sf_flank_fa = working_folder + "{0}{1}{2}_flanks.fa".format(chrm, global_values.SEPERATOR, pos)
            with open(sf_flank_fa, "w") as fout_flank:
                if b_left==True:
                    fout_flank.write(">{0}\n".format(global_values.LEFT_FLANK))
                    fout_flank.write(s_left_region + "\n")
                if b_right==True:
                    fout_flank.write(">{0}\n".format(global_values.RIGHT_FLANK))
                    fout_flank.write(s_right_region + "\n")
        f_fa.close()

    # gnrt the left and right flank regions for each candidate site
    def run_gnrt_flank_region_for_regions_by_chrm(self, record):
        chrm = record[0]
        sf_sites = record[1]
        sf_ref = record[2]
        i_extend = abs(int(record[3]))
        working_folder = record[4]
        if working_folder[-1] != "/":
            working_folder += "/"
        b_left = record[5]
        b_right = record[6]

        xsites = XSites(sf_sites)
        m_sites = xsites.load_in_sites_of_regions()
        f_fa = pysam.FastaFile(sf_ref)
        m_ref_chrms = {}
        for tmp_chrm in f_fa.references:
            m_ref_chrms[tmp_chrm] = 1
        b_with_chr = False
        if "chr1" in m_ref_chrms:
            b_with_chr = True

        for i_rg_start in m_sites[chrm]:
            if i_rg_start - i_extend < 0:
                continue
            i_rg_end=m_sites[chrm][i_rg_start]

            ref_chrm = self.process_chrm_name(chrm, b_with_chr)
            s_left_region = f_fa.fetch(ref_chrm, i_rg_start - i_extend, i_rg_start)
            s_right_region = f_fa.fetch(ref_chrm, i_rg_end, i_rg_end + i_extend)#

            sf_flank_fa = working_folder + "{0}{1}{2}_flanks.fa".format(chrm, global_values.SEPERATOR, i_rg_start)
            with open(sf_flank_fa, "w") as fout_flank:
                if b_left == True:
                    fout_flank.write(">{0}\n".format(global_values.LEFT_FLANK))
                    fout_flank.write(s_left_region + "\n")
                if b_right == True:
                    fout_flank.write(">{0}\n".format(global_values.RIGHT_FLANK))
                    fout_flank.write(s_right_region + "\n")
        f_fa.close()

    #this function is used to get flanks of candidate site, then align to the assembled contigs
    #to call out TE insertion or other SVs
    def gnrt_flank_region_for_sites(self, sf_sites, i_extend, n_jobs, sf_ref, s_working_folder, b_left=True, b_right=True):
        xsites = XSites(sf_sites)
        m_sites = xsites.load_in_sites()

        if s_working_folder[-1] != "/":
            s_working_folder += "/"
        flank_folder = s_working_folder + global_values.FLANK_FOLDER
        if os.path.exists(flank_folder) == False:
            cmd = "mkdir {0}".format(flank_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)

        l_records = []
        for chrm in m_sites:
            tmp_rcd=(chrm, sf_sites, sf_ref, i_extend, flank_folder, b_left, b_right)
            l_records.append(tmp_rcd)
            #self.run_gnrt_flank_region_for_chrm(tmp_rcd) ################
        pool = Pool(n_jobs)
        pool.map(unwrap_gnrt_flank_regions, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()

    ####
    ####generate flank regions for given regions
    def gnrt_flank_region_for_regions(self, sf_sites, i_extend, n_jobs, sf_ref, s_working_folder,
                                      b_left=True, b_right=True):
        xsites = XSites(sf_sites)
        m_sites = xsites.load_in_sites_of_regions()

        if s_working_folder[-1] != "/":
            s_working_folder += "/"
        flank_folder = s_working_folder + global_values.FLANK_FOLDER
        if os.path.exists(flank_folder) == False:
            cmd = "mkdir {0}".format(flank_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)

        l_records = []
        for chrm in m_sites:
            tmp_rcd=(chrm, sf_sites, sf_ref, i_extend, flank_folder, b_left, b_right)
            l_records.append(tmp_rcd)
            #self.run_gnrt_flank_region_for_chrm(tmp_rcd) ################
        pool = Pool(n_jobs)
        pool.map(unwrap_gnrt_flank_regions_for_regions, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()

####

####
    # #this function is used to get flanks of candidate site, then align to the assembled contigs
    # #to call out TE insertion or other SVs
    # def gnrt_flank_region_for_sites_in_list(self, l_sites, i_extend, n_jobs, sf_ref, s_working_folder):
    #     # xsites = XSites(sf_sites)
    #     # m_sites = xsites.load_in_sites()
    #     m_sites={}
    #     for site_rcd in l_sites:
    #         # each in format: (sf_bam, ins_chrm, ins_pos, sf_tmp)
    #         ins_chrm = site_rcd[1]
    #         ins_pos = int(site_rcd[2])
    #         if ins_chrm not in m_sites:
    #             m_sites[ins_chrm]={}
    #         m_sites[ins_chrm][ins_pos]=1
    #
    #     if s_working_folder[-1] != "/":
    #         s_working_folder += "/"
    #     flank_folder = s_working_folder + global_values.FLANK_FOLDER
    #     if os.path.exists(flank_folder) == False:
    #         cmd = "mkdir {0}".format(flank_folder)
    #         #Popen(cmd, shell=True, stdout=PIPE).communicate()
    #         self.cmd_runner.run_cmd_small_output(cmd)
    #
    #     l_records = []
    #     for chrm in m_sites:
    #         tmp_rcd=(chrm, sf_sites, sf_ref, i_extend, flank_folder)
    #         l_records.append(tmp_rcd)
    #         #self.run_gnrt_flank_region_for_chrm(tmp_rcd) ################
    #
    #     pool = Pool(n_jobs)
    #     pool.map(unwrap_gnrt_flank_regions, zip([self] * len(l_records), l_records), 1)
    #     pool.close()
    #     pool.join()
#####

    ####
    def gnrt_flank_regions_of_polymerphic_insertions(self, l_sites, i_extend1, sf_ref, sf_out):
        i_extend=abs(i_extend1)
        f_fa = pysam.FastaFile(sf_ref)
        m_ref_chrms = {}
        for tmp_chrm in f_fa.references:
            m_ref_chrms[tmp_chrm] = 1
        b_with_chr = False
        if "chr1" in m_ref_chrms:
            b_with_chr = True
        bi_rc=0 ########################################################################################################
        m_polym_fl_l1_flank={}
        with open(sf_out, "w") as fout_flanks:
            for (ins_chrm, ins_pos) in l_sites:
                if ins_pos - i_extend < 0:
                    continue
                istart = ins_pos - i_extend
                iend = ins_pos + i_extend

                sub_family=global_values.S_POLYMORPHIC
                ref_chrm = self.process_chrm_name(ins_chrm, b_with_chr)
                if ref_chrm not in m_ref_chrms:#special cases like chrM, will be skipped
                    continue
                s_left_region = f_fa.fetch(ref_chrm, istart, ins_pos)
                s_left_head=">{0}{1}{2}{3}{4}{5}{6}{7}{8}L".format(ins_chrm, global_values.S_DELIM, ins_pos,
                                                                   global_values.S_DELIM, ins_pos, global_values.S_DELIM,
                                                                   sub_family, global_values.S_DELIM, bi_rc)
                fout_flanks.write(s_left_head+"\n")
                fout_flanks.write(s_left_region + "\n")
                s_right_region = f_fa.fetch(ref_chrm, ins_pos, iend)
                s_right_head = ">{0}{1}{2}{3}{4}{5}{6}{7}{8}R".format(ins_chrm, global_values.S_DELIM, ins_pos,
                                                                      global_values.S_DELIM, ins_pos, global_values.S_DELIM,
                                                                      sub_family, global_values.S_DELIM, bi_rc)
                fout_flanks.write(s_right_head + "\n")
                fout_flanks.write(s_right_region + "\n")
                s_id="{0}{1}{2}".format(ins_chrm, global_values.SEPERATOR, ins_pos)
                m_polym_fl_l1_flank[s_id]=(s_left_head, s_left_region, s_right_head, s_right_region)
        f_fa.close()
        return m_polym_fl_l1_flank
####
####
    #generate the target sequence for given sites
    def gnrt_target_flank_seq_for_sites(self, sf_sites, i_extend1, n_jobs, sf_ref, s_working_folder):
        i_extend=abs(i_extend1)
        xsites = XSites(sf_sites)
        m_sites = xsites.load_in_sites()

        if s_working_folder[-1] != "/":
            s_working_folder += "/"
        flank_folder = s_working_folder + global_values.FLANK_FOLDER
        if os.path.exists(flank_folder) == False:
            cmd = "mkdir {0}".format(flank_folder)
            # Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.cmd_runner.run_cmd_small_output(cmd)

        l_records = []
        for chrm in m_sites:
            tmp_rcd = (chrm, sf_sites, sf_ref, i_extend, flank_folder)
            l_records.append(tmp_rcd)
            # self.run_gnrt_flank_region_for_chrm(tmp_rcd) ################

        pool = Pool(n_jobs)
        pool.map(unwrap_gnrt_target_regions, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()

####
    # gnrt the left and right flank regions for each candidate site
    def run_gnrt_target_region_for_chrm(self, record):
        chrm = record[0]
        sf_sites = record[1]
        sf_ref = record[2]
        i_extend = abs(int(record[3]))
        working_folder = record[4]
        if working_folder[-1] != "/":
            working_folder += "/"

        xsites = XSites(sf_sites)
        m_sites = xsites.load_in_sites()
        f_fa = pysam.FastaFile(sf_ref)
        m_ref_chrms = {}
        for tmp_chrm in f_fa.references:
            m_ref_chrms[tmp_chrm] = 1
        b_with_chr = False
        if "chr1" in m_ref_chrms:
            b_with_chr = True

        for pos in m_sites[chrm]:
            if pos - i_extend < 0:
                continue
            istart = pos - i_extend
            iend = pos + i_extend

            ref_chrm = self.process_chrm_name(chrm, b_with_chr)
            s_target_region = f_fa.fetch(ref_chrm, istart, iend)

            sf_flank_fa = working_folder + "{0}{1}{2}_flanks.fa".format(chrm, global_values.SEPERATOR, pos)
            with open(sf_flank_fa, "w") as fout_flank:
                fout_flank.write(">target_ref_seq\n")
                fout_flank.write(s_target_region + "\n")
        f_fa.close()

    #given chromosome lengths, break to bins
    def break_ref_to_bins(self, m_chrm_length, bin_size):
        m_bins={}
        for chrm in m_chrm_length:
            if chrm not in m_bins:
                m_bins[chrm]=[]
            chrm_lenth=m_chrm_length[chrm]
            tmp_pos=0
            while tmp_pos<chrm_lenth:
                block_end=tmp_pos+bin_size
                if block_end>chrm_lenth:
                    block_end=chrm_lenth
                m_bins[chrm].append((tmp_pos, block_end))
                tmp_pos=block_end
        return m_bins

    ##get index by chrm position
    def get_bin_by_pos(self, chrm, pos, bin_size, m_bins):
        bin_index=-1
        if chrm not in m_bins:
            return bin_index
        bin_index = pos/bin_size
        return m_bins[chrm][bin_index] #return [start, end) of the bin

    #Given sites, get the seqs in ref of those sites
    #record within l_sites in format: (chrm, istart, iend)
    def get_ref_seqs_of_sites(self, sf_ref, l_sites):
        l_seqs=[]
        f_fa = pysam.FastaFile(sf_ref)
        m_ref_chrms = {}
        for tmp_chrm in f_fa.references:
            m_ref_chrms[tmp_chrm] = 1
        b_with_chr = False
        if "chr1" in m_ref_chrms:
            b_with_chr = True
        for rcd in l_sites:
            s_seq="."
            ins_chrm=rcd[0]
            lpos=int(rcd[1])
            rpos=int(rcd[2])
            if lpos<=0 or rpos<=0:
                l_seqs.append(s_seq)
                continue
            ref_chrm = self.process_chrm_name(ins_chrm, b_with_chr)

            #check whether the chromosome is consistent
            istart=lpos
            iend=rpos
            if lpos>rpos:
                istart=rpos
                iend=lpos
            if ref_chrm not in m_ref_chrms:
                print(("%s doesn't exist in reference!" % ref_chrm))
                l_seqs.append(s_seq)
                continue
            s_seq = f_fa.fetch(ref_chrm, istart, iend)
            l_seqs.append(s_seq)
        f_fa.close()
        return l_seqs

####