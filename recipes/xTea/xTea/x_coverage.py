##11/22/2017
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

####Revision on 01/10/2019: put basic functions to X_BasicInfo class, and then ReadDepth class inherits from it
####
import os
import pysam
import random
from x_alignments import *
from multiprocessing import Pool
from x_reference import *
from x_basic_info import *

def unwrap_self_calc_depth_for_site(arg, **kwarg):
    return ReadDepth._calc_depth_one_site(*arg, **kwarg)
def unwrap_self_calc_depth_for_site2(arg, **kwarg):
    return ReadDepth._calc_depth_one_site2(*arg, **kwarg)

class ReadDepth(X_BasicInfo):
    def __init__(self, working_folder, n_jobs, sf_ref):
        X_BasicInfo.__init__(self, working_folder, n_jobs, sf_ref)

    #calc the read depth for one site
    def _calc_depth_one_site(self, record):
        chrm=record[0][0]
        insertion_pos=record[0][1]
        search_win=record[0][2]
        focal_win=record[0][3]

        mlcov={}#save the coverage of left bases
        mrcov={}#save the coverage of right bases

        start_pos = insertion_pos - search_win
        if start_pos <= 0:
            start_pos = 1
        end_pos = insertion_pos + search_win

        sf_bam=record[1]
        working_folder = record[2]

        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        chrm_in_bam = self._process_chrm_name(b_with_chr, chrm)
        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        for algnmt in samfile.fetch(chrm_in_bam, start_pos, end_pos):  ##fetch reads mapped to "chrm:start_pos-end_pos"
            ##here need to skip the secondary and supplementary alignments
            # if algnmt.is_secondary or algnmt.is_supplementary:
            #     continue
            if algnmt.is_duplicate == True:  ##duplciate
                continue
            if algnmt.is_unmapped == True:  ##unmapped
                continue
            map_pos = algnmt.reference_start #mapping position
            l_cigar = algnmt.cigar
            tmp_end_pos=self._get_map_end_pos(l_cigar, map_pos)
            lfocal_start=insertion_pos-focal_win
            lfocal_end=insertion_pos
            rfocal_start=insertion_pos+1
            rfocal_end=insertion_pos+focal_win
            #print map_pos, tmp_end_pos, insertion_pos
            for i in range(map_pos, tmp_end_pos):
                if i>=lfocal_start and i<=lfocal_end:
                    if i not in mlcov:
                        mlcov[i]=1
                    else:
                        mlcov[i]+=1
                if i>=rfocal_start and i<=rfocal_end:
                    if i not in mrcov:
                        mrcov[i]=1
                    else:
                        mrcov[i]+=1
        samfile.close()

        #calc the coverage
        flcov=self.__calc_coverage(mlcov, focal_win)
        frcov=self.__calc_coverage(mrcov, focal_win)

        return (chrm, insertion_pos, flcov, frcov)

####
    #calculate the local read depth of given sites
    #sf_sites: the interested sites
    #search_win: collect reads in this range
    #focal_win: calc the depth in this range
    def calc_coverage_of_sites(self, sf_sites, sf_bam_list, search_win, focal_win):
        m_site_cov = {}
        with open(sf_bam_list) as fin_bams:
            for line in fin_bams:
                sf_bam=line.rstrip()

                l_records = []
                with open(sf_sites) as fin_list:
                    for line in fin_list:
                        fields = line.split()
                        chrm = fields[0]
                        pos = int(fields[1])#candidate insertion site
                        l_records.append(((chrm, pos, search_win, focal_win), sf_bam, self.working_folder))

                pool = Pool(self.n_jobs)
                l_sites_cov=pool.map(unwrap_self_calc_depth_for_site, list(zip([self] * len(l_records), l_records)), 1)
                pool.close()
                pool.join()

                for record in l_sites_cov:
                    ins_chrm=record[0]
                    ins_pos=record[1]
                    flcov=record[2]
                    frcov=record[3]

                    if ins_chrm not in m_site_cov:
                        m_site_cov[ins_chrm]={}
                    if ins_pos not in m_site_cov[ins_chrm]:
                        m_site_cov[ins_chrm][ins_pos] = []
                        m_site_cov[ins_chrm][ins_pos].append(0)
                        m_site_cov[ins_chrm][ins_pos].append(0)

                    m_site_cov[ins_chrm][ins_pos][0] += flcov
                    m_site_cov[ins_chrm][ins_pos][1] += frcov
        return m_site_cov
####

####
    # calc the read depth for one site
    def _calc_depth_one_site2(self, record):
        chrm = record[0][0]
        insertion_pos = record[0][1]
        search_win = record[0][2]
        focal_win = record[0][3]
        focal_win2=record[0][4]

        mlcov = {}  # save the coverage of left bases
        mrcov = {}  # save the coverage of right bases
        mlcov2 = {}  # save the coverage of left bases
        mrcov2 = {} # save the coverage of right bases
        start_pos = insertion_pos - search_win
        if start_pos <= 0:
            start_pos = 1
            return (chrm, insertion_pos, 0, 0, 0, 0)
        end_pos = insertion_pos + search_win

        sf_bam = record[1]
        working_folder = record[2]

        bam_info = BamInfo(sf_bam, self.sf_reference)
        b_with_chr = bam_info.is_chrm_contain_chr()
        chrm_in_bam = self._process_chrm_name(b_with_chr, chrm)
        samfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        for algnmt in samfile.fetch(chrm_in_bam, start_pos, end_pos):  ##fetch reads mapped to "chrm:start_pos-end_pos"
            ##here need to skip the secondary and supplementary alignments
            # if algnmt.is_secondary or algnmt.is_supplementary:
            #     continue
            if algnmt.is_duplicate == True:  ##duplciate
                continue
            if algnmt.is_unmapped == True:  ##unmapped
                continue
            map_pos = algnmt.reference_start  ##mapping position
            l_cigar = algnmt.cigar
            tmp_end_pos = self._get_map_end_pos(l_cigar, map_pos)
            lfocal_start = insertion_pos - focal_win
            lfocal_end = insertion_pos
            rfocal_start = insertion_pos + 1
            rfocal_end = insertion_pos + focal_win

            lfocal_start2 = insertion_pos - focal_win2
            lfocal_end2 = insertion_pos
            rfocal_start2 = insertion_pos + 1
            rfocal_end2 = insertion_pos + focal_win2
            # print map_pos, tmp_end_pos, insertion_pos
            for i in range(map_pos, tmp_end_pos):
                if i >= lfocal_start and i <= lfocal_end:
                    if i not in mlcov:
                        mlcov[i] = 1
                    else:
                        mlcov[i] += 1
                if i >= rfocal_start and i <= rfocal_end:
                    if i not in mrcov:
                        mrcov[i] = 1
                    else:
                        mrcov[i] += 1

                if i >= lfocal_start2 and i <= lfocal_end2:
                    if i not in mlcov2:
                        mlcov2[i] = 1
                    else:
                        mlcov2[i] += 1
                if i >= rfocal_start2 and i <= rfocal_end2:
                    if i not in mrcov2:
                        mrcov2[i] = 1
                    else:
                        mrcov2[i] += 1
        samfile.close()

        # calc the coverage
        flcov = self.__calc_coverage(mlcov, focal_win)
        frcov = self.__calc_coverage(mrcov, focal_win)

        flcov2 = self.__calc_coverage(mlcov2, focal_win2)
        frcov2 = self.__calc_coverage(mrcov2, focal_win2)

        return (chrm, insertion_pos, flcov, frcov, flcov2, frcov2)

    ####
    #calculate the local read depth of given sites
    #sf_sites: the interested sites
    #search_win: collect reads in this range
    #focal_win: calc the depth in this range
    #focal_win2: calc the depth in this range too!
    def calc_coverage_of_two_regions(self, m_sites, sf_bam_list, search_win, focal_win, focal_win2):
        m_site_cov = {}
        with open(sf_bam_list) as fin_bams:
            for line in fin_bams:
                fields=line.split()
                sf_bam=fields[0]

                l_records = []
                for chrm in m_sites:
                    for pos in m_sites[chrm]:
                        l_records.append(((chrm, pos, search_win, focal_win, focal_win2), sf_bam, self.working_folder))

                pool = Pool(self.n_jobs)
                l_sites_cov=pool.map(unwrap_self_calc_depth_for_site2, list(zip([self] * len(l_records), l_records)), 1)
                pool.close()
                pool.join()

                for record in l_sites_cov:
                    ins_chrm=record[0]
                    ins_pos=record[1]
                    flcov=record[2]
                    frcov=record[3]
                    flcov2 = record[4]
                    frcov2 = record[5]

                    if ins_chrm not in m_site_cov:
                        m_site_cov[ins_chrm]={}
                    if ins_pos not in m_site_cov[ins_chrm]:
                        m_site_cov[ins_chrm][ins_pos] = []
                        m_site_cov[ins_chrm][ins_pos].append(0)
                        m_site_cov[ins_chrm][ins_pos].append(0)
                        m_site_cov[ins_chrm][ins_pos].append(0)
                        m_site_cov[ins_chrm][ins_pos].append(0)

                    m_site_cov[ins_chrm][ins_pos][0] += flcov
                    m_site_cov[ins_chrm][ins_pos][1] += frcov
                    m_site_cov[ins_chrm][ins_pos][2] += flcov2
                    m_site_cov[ins_chrm][ins_pos][3] += frcov2
        return m_site_cov

#
    def dump_coverage_info(self, m_site_cov, sf_out):
        with open(sf_out, "w") as fout_cov:
            for ins_chrm in m_site_cov:
                for ins_pos in m_site_cov[ins_chrm]:
                    f_lcov_large_region=m_site_cov[ins_chrm][ins_pos][0]
                    f_rcov_large_region = m_site_cov[ins_chrm][ins_pos][1]
                    f_lcov_focal = m_site_cov[ins_chrm][ins_pos][2]
                    f_rcov_focal = m_site_cov[ins_chrm][ins_pos][3]
                    sinfo="{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n".format(ins_chrm, ins_pos, f_lcov_large_region,
                                                                  f_rcov_large_region, f_lcov_focal, f_rcov_focal)
                    fout_cov.write(sinfo)

    #l_sites: the interested sites in format [(chrm, pos)] Method paper
    #search_win: collect reads in this range
    #focal_win: calc the depth in this range
    def calc_coverage_of_sites2(self, l_sites, sf_bam, search_win, focal_win):
        l_site_cov = []
        l_records = []
        for (chrm, pos) in l_sites:
            l_records.append(((chrm, pos, search_win, focal_win), sf_bam, self.working_folder))

        pool = Pool(self.n_jobs)
        l_tmp_cov=pool.map(unwrap_self_calc_depth_for_site, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()

        for record in l_tmp_cov:
            flcov=record[2]
            frcov=record[3]
            f_cov=(flcov+frcov)/2
            if f_cov<global_values.MIN_COV_RANDOM_SITE:#for WES, skip those intron regions
                continue
            l_site_cov.append(f_cov)
        return l_site_cov
####

    def calc_coverage_samples(self, sf_bam_list, sf_ref, search_win):
        m_sample_cov={}
        #first randomly select some points for check the coverage
        n_sites=global_values.N_RANDOM_SITES
        with open(sf_bam_list) as fin_bams:
            for line in fin_bams:
                sf_bam=line.rstrip()

                l_sites=self._random_slct_site(sf_bam, sf_ref, n_sites)
                l_sites_cov=self.calc_coverage_of_sites2(l_sites, sf_bam, search_win, search_win)
                l_sites_cov.sort()
                n_slct_sites=len(l_sites_cov)
                m_sample_cov[sf_bam]=l_sites_cov[n_slct_sites/2]
        return m_sample_cov

    def get_total_cov(self, m_sample_cov):
        i_total=0
        for sample in m_sample_cov:
            i_total+=m_sample_cov[sample]
        return i_total
####
####
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

    def _get_map_end_pos(self, l_cigar, start_pos):
        end_pos=start_pos
        for (type, lenth) in l_cigar:
            if type == 4 or type == 5 or type == 1:  # (1 for insertion)
                continue
            else:
                end_pos += lenth
        return end_pos

    def __calc_coverage(self, mcov, win_size):
        isum=0
        for tmp_pos in mcov:
            isum+=mcov[tmp_pos]
        fcov=float(isum)/float(win_size)
        return fcov