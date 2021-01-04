###01/11/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

#collect the basic information of the bam:
#1. calc the average depth
#2. calc the insert-size information
#3. get the read length

import os
import pysam
import random
from x_alignments import *
from multiprocessing import Pool
from x_reference import *

def unwrap_self_collect_basic_info_for_site(arg, **kwarg):
    return X_BasicInfo._collect_basic_info_one_site(*arg, **kwarg)

class X_BasicInfo():
    def __init__(self, working_folder="./", n_jobs=1, sf_ref=""):
        if len(working_folder)<=0:
            working_folder="./"
        if working_folder[-1]!="/":
            working_folder+="/"
        self.working_folder = working_folder
        self.n_jobs = n_jobs
        self.sf_reference = sf_ref

###
    #for now, coverage is merged if there are several bams in the list
    def get_cov_is_rlth(self, sf_bam_list, sf_ref, search_win, b_force=False):
        f_cov=0
        rlth=0
        mean_is=0
        std_var=0
        n_sample=1
        sf_basic_info = self.working_folder + global_values.BASIC_INFO_FILE
        m_info={}
        b_gnrt=True
        if os.path.isfile(sf_basic_info) == True and b_force==False:#first already exist, and is not forced to re-calc
            m_tmp_info = self.load_basic_info_from_file(sf_basic_info)
            if len(m_tmp_info)>0:#load successfully
                m_info=m_tmp_info
                b_gnrt=False
        if b_gnrt==True:
            m_info=self.collect_dump_basic_info_samples(sf_bam_list, sf_ref, search_win)
        for s_bam in m_info:
            f_cov += m_info[s_bam][0]
            rlth += m_info[s_bam][1]
            mean_is += m_info[s_bam][2]
            std_var += m_info[s_bam][3]
        n_sample = len(m_info)
        if n_sample==0:
            return (0,0,0,0)
        return (f_cov, rlth / n_sample, mean_is / n_sample, std_var / n_sample)
        #return (f_ave_cov/n_sample, rlth/n_sample, mean_is/n_sample, std_var/n_sample)

    def collect_dump_basic_info_samples(self, sf_bam_list, sf_ref, search_win):
        m_sample_info=self.collect_basic_info_samples(sf_bam_list, sf_ref, search_win)
        sf_out=self.working_folder+global_values.BASIC_INFO_FILE
        self.dump_basic_info_to_file(m_sample_info, sf_out)
        return m_sample_info

    def load_basic_info_samples(self):
        sf_basic_info = self.working_folder + global_values.BASIC_INFO_FILE
        if os.path.isfile(sf_basic_info)==False:
            return None
        m_basic_info=self.load_basic_info_from_file(sf_basic_info)
        return m_basic_info

    def load_get_cov(self):
        f_cov=0
        m_info=self.load_basic_info_samples()
        if m_info is None:
            return 0,0

        for s_bam in m_info:
            f_cov += m_info[s_bam][0]
        n_sample = len(m_info)
        return f_cov, f_cov/float(n_sample)

####
    ####calc the coverage for given bam
    def calc_cov_from_bam(self, sf_bam, sf_ref, search_win):
        n_sites = global_values.N_RANDOM_SITES
        l_sites = self._random_slct_site(sf_bam, sf_ref, n_sites)
        l_tmp_info = self.collect_basic_info_of_sites2(l_sites, sf_bam, search_win, search_win)
        f_ave_cov = 0
        l_cov = []
        for record in l_tmp_info:
            flcov = record[2]
            frcov = record[3]
            f_cov = (flcov + frcov) / 2
            if f_cov >= global_values.MIN_COV_RANDOM_SITE:  # for WES, skip those intron regions
                l_cov.append(f_cov)
        l_cov.sort()
        n_slct_sites = len(l_cov)
        if n_slct_sites > 0:
            f_ave_cov = l_cov[n_slct_sites / 2]
        return f_ave_cov
####
    #collect the basic information of samples
    #randomely select some sites, and calc the coverage, insert size, and read length
    def collect_basic_info_samples(self, sf_bam_list, sf_ref, search_win):
        m_sample_info={}
        m_site_cov = {}####this is to save the merged coverage
        l_rlth = []  # read length for each bam
        l_is = []  # insert size and std derivation for each bam
        #first randomly select some points for check the coverage
        n_sites=global_values.N_RANDOM_SITES
        with open(sf_bam_list) as fin_bams:
            for line in fin_bams:
                fields=line.split()
                sf_bam=fields[0]

                l_sites=self._random_slct_site(sf_bam, sf_ref, n_sites)
                l_tmp_info=self.collect_basic_info_of_sites2(l_sites, sf_bam, search_win, search_win)

                ####
                acm_is = 0
                acm_is_squre = 0
                n_pairs = 0
                m_rlth = {}
                f_ave_cov=0
                l_cov=[]
                for record in l_tmp_info:
                    ins_chrm = record[0]
                    ins_pos = record[1]
                    flcov = record[2]
                    frcov = record[3]
                    dom_rlth = record[4]
                    acm_is += record[5]
                    acm_is_squre += record[6]
                    n_pairs += record[7]

                    if ins_chrm not in m_site_cov:
                        m_site_cov[ins_chrm] = {}
                    if ins_pos not in m_site_cov[ins_chrm]:
                        m_site_cov[ins_chrm][ins_pos] = []
                        m_site_cov[ins_chrm][ins_pos].append(0)
                        m_site_cov[ins_chrm][ins_pos].append(0)

                    m_site_cov[ins_chrm][ins_pos][0] += flcov
                    m_site_cov[ins_chrm][ins_pos][1] += frcov

                    f_cov=(flcov+frcov)/2
                    if f_cov >= global_values.MIN_COV_RANDOM_SITE:# for WES, skip those intron regions
                        l_cov.append(f_cov)

                    if dom_rlth not in m_rlth:
                        m_rlth[dom_rlth] = 1
                    else:
                        m_rlth[dom_rlth] += 1

                #for coverage
                l_cov.sort()
                n_slct_sites = len(l_cov)
                if n_slct_sites>0:
                    f_ave_cov=l_cov[n_slct_sites/2]

                # for read length
                rlth = self._calc_read_length(m_rlth)
                l_rlth.append(rlth)
                # for insert size
                mean_is, std_var = self._calc_insert_size(acm_is, acm_is_squre, n_pairs)
                l_is.append((mean_is, std_var))

                m_sample_info[sf_bam]=(f_ave_cov, rlth, mean_is, std_var)
        return m_sample_info

    # collect the basic information of samples
    # randomely select some sites, and calc the coverage, insert size, and read length
    def collect_basic_info_one_sample(self, sf_bam, sf_ref, search_win):
        # first randomly select some points for check the coverage
        n_sites = global_values.N_RANDOM_SITES
        l_sites = self._random_slct_site(sf_bam, sf_ref, n_sites)
        l_tmp_info = self.collect_basic_info_of_sites2(l_sites, sf_bam, search_win, search_win)

        acm_is = 0
        acm_is_squre = 0
        n_pairs = 0
        m_rlth = {}
        f_ave_cov = 0
        l_cov = []
        for record in l_tmp_info:
            ins_chrm = record[0]
            ins_pos = record[1]
            flcov = record[2]
            frcov = record[3]
            dom_rlth = record[4]
            acm_is += record[5]
            acm_is_squre += record[6]
            n_pairs += record[7]

            f_cov = (flcov + frcov) / 2
            if f_cov >= global_values.MIN_COV_RANDOM_SITE:  # for WES, skip those intron regions
                l_cov.append(f_cov)

            if dom_rlth not in m_rlth:
                m_rlth[dom_rlth] = 1
            else:
                m_rlth[dom_rlth] += 1

        # for coverage
        l_cov.sort()
        n_slct_sites = len(l_cov)
        if n_slct_sites > 0:
            f_ave_cov = l_cov[n_slct_sites / 2]

        # for read length
        rlth = self._calc_read_length(m_rlth)
        # for insert size
        mean_is, std_var = self._calc_insert_size(acm_is, acm_is_squre, n_pairs)
        return f_ave_cov, rlth, mean_is, std_var


    ####save the basic information to file
    #each line in format: bam_name, f_ave_cov, rlth, mean_is, std_var
    def dump_basic_info_to_file(self, m_sample_info, sf_out):
        with open(sf_out, "w") as fout_info:
            for sbam in m_sample_info:
                rcd=m_sample_info[sbam]
                fout_info.write(sbam)
                for s_fld in rcd:
                    fout_info.write("\t"+str(s_fld))
                fout_info.write("\n")

    #load the basic information from file
    def load_basic_info_from_file(self, sf_basic_info):
        m_basic_info={}
        with open(sf_basic_info) as fin_info:
            for line in fin_info:
                fields=line.split()
                if len(fields)<5:
                    continue
                sf_bam=fields[0]
                f_ave_cov=float(fields[1])
                rlth=int(fields[2])
                mean_is=float(fields[3])
                std_var=float(fields[4])
                m_basic_info[sf_bam]=(f_ave_cov, rlth, mean_is, std_var)
        return m_basic_info


    #l_sites: the interested sites in format [(chrm, pos)] Method paper
    #search_win: collect reads in this range
    #focal_win: calc the depth in this range
    def collect_basic_info_of_sites2(self, l_sites, sf_bam, search_win, focal_win):
        l_site_cov = []

        l_records = []
        for (chrm, pos) in l_sites:
            l_records.append(((chrm, pos, search_win, focal_win), sf_bam, self.working_folder))

        pool = Pool(self.n_jobs)
        l_tmp_info=pool.map(unwrap_self_collect_basic_info_for_site, list(zip([self] * len(l_records), l_records)), 1)
        pool.close()
        pool.join()

        return l_tmp_info

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

    def __calc_insert_size(self, chrm, pos, mate_chrm, mate_pos):
        if chrm!=mate_chrm or mate_chrm=="*":#they are of the different chroms
            return 0
        else:#aligned on the same chrom
            dist=abs(pos-mate_pos)
            if dist>global_values.MAX_NORMAL_INSERT_SIZE:
                return 0
            return dist

    def _get_chrm_id_name(self, samfile):
        m_chrm = {}
        references = samfile.references
        for schrm in references:
            chrm_id = samfile.get_tid(schrm)
            m_chrm[chrm_id] = schrm
        m_chrm[-1] = "*"
        return m_chrm

    #calc the read depth for one site
    def _collect_basic_info_one_site(self, record):
        chrm=record[0][0]
        insertion_pos=record[0][1]
        search_win=record[0][2]
        focal_win=record[0][3]

        mlcov={}#save the coverage of left bases
        mrcov={}#save the coverage of right bases
        l_read_lenth=[] #save the read length
        m_read_lenth={}
        l_insert_size=[]#save the insert size

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
        m_chrm_id_name=self._get_chrm_id_name(samfile)
        for algnmt in samfile.fetch(chrm_in_bam, start_pos, end_pos):  ##fetch reads mapped to "chrm:start_pos-end_pos"
            ##here need to skip the secondary and supplementary alignments
            if algnmt.is_secondary or algnmt.is_supplementary:
                continue
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
####
            #for insert size
            if algnmt.is_read1==True:#for a pair, only calc once
                mate_chrm = '*'
                mate_pos = 0
                if algnmt.next_reference_id not in m_chrm_id_name:
                    continue
                if algnmt.next_reference_id >= 0:
                    mate_chrm = algnmt.next_reference_name
                    mate_pos = algnmt.next_reference_start
                i_is_tmp=self.__calc_insert_size(chrm, map_pos, mate_chrm, mate_pos)
                if i_is_tmp!=0:
                    l_insert_size.append(i_is_tmp)

            #for read length
            if len(l_cigar)>1 and (l_cigar[0][0]==5 or l_cigar[-1][0]==5):#skip hard clip
                continue
            i_rlen=algnmt.query_length
            if i_rlen!=0:
                if i_rlen not in m_read_lenth:
                    m_read_lenth[i_rlen]=1
                else:
                    m_read_lenth[i_rlen]+=1

        samfile.close()

        #calc the coverage
        flcov=self.__calc_coverage(mlcov, focal_win)
        frcov=self.__calc_coverage(mrcov, focal_win)

        # first get the middle read length
        domint_rlth = 0
        cnt_tmp = 0
        for irlen in m_read_lenth:
            if m_read_lenth[irlen] > cnt_tmp:
                domint_rlth = irlen
                cnt_tmp = m_read_lenth[irlen]

        i_acm_is_squr = 0  # sum all (x^2), here x is insert size
        i_acm_is=0 #sum all x

        for is_tmp in l_insert_size:# sum the (x^2), x seperately
            adjust_is=is_tmp + domint_rlth
            i_acm_is_squr += ( adjust_is ** 2)
            i_acm_is+=adjust_is
        n_pairs=len(l_insert_size)
        return (chrm, insertion_pos, flcov, frcov, domint_rlth, i_acm_is, i_acm_is_squr, n_pairs)

####

####
    #get the dominant read length
    def _calc_read_length(self, m_rlth):
        dom_lth=0
        cnt=0
        for ilth in m_rlth:
            if m_rlth[ilth]>cnt:
                cnt=m_rlth[ilth]
                dom_lth=ilth
        return dom_lth

    #calc the mean, std derivation of the insert size
    def _calc_insert_size(self, acm_is, acm_is_squre, n_pairs):
        if n_pairs<=0:
            return 0,0
        mean_is=float(acm_is)/float(n_pairs)
        e_is_squre=float(acm_is_squre)/float(n_pairs)
        e_mean_squre=mean_is**2
        std_var=(e_is_squre-e_mean_squre)**0.5

        return mean_is, std_var

####
####
    def _random_slct_site(self, sf_bam, sf_ref, n_sites):
        l_sites=[]

        bam_info=BamInfo(sf_bam, sf_ref)
        m_chrm_info=bam_info.get_all_chrom_name_length()
        xchrom=XChromosome()
        l_chrm=[]
        l_lenth=[]
        for chrm in m_chrm_info:
            if xchrom.is_decoy_contig_chrms(chrm)==True:
                continue
            l_chrm.append(chrm)
            l_lenth.append(m_chrm_info[chrm])

        n_chrm=len(l_chrm)
        for i in range(n_sites):
            i_tmp=random.randint(0, n_chrm-1)
            i_tmp_chrm=l_chrm[i_tmp]
            i_tmp_len=l_lenth[i_tmp]
            if i_tmp_len<2000000:
                #print "Chrm length smaller than 2M!"
                continue
            i_tmp_pos=random.randint(1000000, i_tmp_len-1000000)#skip the first and last 1M region
            l_sites.append((i_tmp_chrm, i_tmp_pos))
        return l_sites


####
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

####
