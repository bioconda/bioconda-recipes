
####This version calculates the insert size and read length for each read group
####Originally designed for TEA (c++ version) on 2018.07
####For now, this version is not used in the pipeline

import os
import pysam
import time
from multiprocessing import Pool
import global_values

def unwrap_self_calc_insert_size(arg, **kwarg):
    return XInsertSize.calc_insert_size_for_read_group_by_chrm(*arg, **kwarg)

class XInsertSize():
    def __init__(self, sf_bam, sf_ref):
        self.sf_bam = sf_bam
        self.sf_reference=sf_ref

    # get the chrom name and length in a dictionary
    def get_all_chrom_name_length_in_list(self):
        bamfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        header = bamfile.header
        bamfile.close()

        l_chrms = header['SQ']
        l_chrm_names = []
        for record in l_chrms:
            chrm_name = record['SN']
            chrm_length = int(record['LN'])
            l_chrm_names.append((chrm_name, chrm_length))
        return l_chrm_names

    def calc_insert_size_for_read_group_by_chrm(self, record):
        print(("[XInsertSize::calc_insert_size_for_read_group_by_chrm] start: ${0}".format(time.time())))

        sf_algnmt = record[0]
        chrm = record[1]
        pos_start = record[2]
        pos_end = record[3]
        sf_mean_is_chrm = record[4]

        m_sum = {}  # save the sum value for each read group
        m_sum_2 = {}  # save the square of each value for each reads group
        m_cnt = {}
        m_rl = {}

        bamfile = pysam.AlignmentFile(sf_algnmt, "rb", reference_filename=self.sf_reference)
        for al in bamfile.fetch(chrm, pos_start, pos_end):
            if al.is_duplicate == True or al.is_supplementary == True:  ##skip duplicate and supplementary ones
                continue
            if al.is_unmapped == True:  #### for now, just skip the unmapped reads ??????????????????????????????
                continue
            if al.is_secondary == True:  ##skip secondary alignment
                continue
            if al.is_read2 == True:  # for a pair, only count once
                continue

            map_pos = al.reference_start
            if map_pos < pos_start or map_pos >= pos_end:  ####fetch() will get [pstart-read_len, qend) region reads
                continue

            s_read_group = "None"
            if al.has_tag('RG') == True:
                s_read_group = al.get_tag('RG')
            template_lth = abs(al.template_length)
            # print "template length: ", template_lth ################################################
            if template_lth == 0 or template_lth > global_values.MAX_NORMAL_INSERT_SIZE:  # template length information is not available
                continue

            if s_read_group not in m_sum:  # sum up the insert-size value
                m_sum[s_read_group] = 0
            m_sum[s_read_group] += float(template_lth)

            if s_read_group not in m_sum_2:
                m_sum_2[s_read_group] = 0
            m_sum_2[s_read_group] += float(template_lth ** 2)

            if s_read_group not in m_cnt:  # cnt the number of pairs
                m_cnt[s_read_group] = 0
            m_cnt[s_read_group] += 1

            if s_read_group not in m_rl:
                m_rl[s_read_group] = 0
            if m_rl[s_read_group] < len(al.seq):
                m_rl[s_read_group] = len(al.seq)
        bamfile.close()

        with open(sf_mean_is_chrm, "w") as fout_mean:
            for rg in m_sum:
                s_mean = "{0}\t{1}\t{2}\t{3}\t{4}\n".format(rg, m_sum[rg], m_cnt[rg], m_sum_2[rg], m_rl[rg])
                fout_mean.write(s_mean)

        print(("[XInsertSize::calc_insert_size_for_read_group_by_chrm] end: ${0}".format(time.time())))

    ###use small bin size (like 10M) will be more efficient
    def calc_insert_size_by_read_group(self, working_folder, n_jobs, bin_size, sf_out):
        print(("[XInsertSize::calc_insert_size_by_read_group] start: ${0}".format(time.time())))

        l_chrm_name_length = self.get_all_chrom_name_length_in_list()

        m_rgs = self.get_read_groups()#save all the read groups
        # read in the pre-saved mean insert size for each read group
        m_sum_is = {}
        m_sum2_is = {}
        m_cnt_is = {}
        m_rl = {}
        m_already_checked={}

        ###first each chrm take 2 blocks
        ###and check whether have covered all the read groups
        #if so, then output
        #else, then chrm by chrm
        l_chrm_records0 = []
        for cur_chrm, cur_length in l_chrm_name_length:
            m_temp = {}
            m_temp[cur_chrm] = cur_length
            m_bins = self.break_ref_to_bins(m_temp, bin_size)
            for chrm in m_bins:
                ncnt = 0
                for record in m_bins[chrm]:
                    if ncnt>1: ###################################only check two regions!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        break
                    ncnt+=1
                    pos_start = record[0]
                    pos_end = record[1]
                    sf_mean_is_chrm = working_folder + "{0}~{1}~{2}{3}".format(chrm, pos_start, pos_end,
                                                                               global_values.ISIZE_MEAN_SUFFIX)
                    m_already_checked[sf_mean_is_chrm]=1
                    l_chrm_records0.append((self.sf_bam, chrm, pos_start, pos_end, sf_mean_is_chrm))
        pool = Pool(n_jobs)
        pool.map(unwrap_self_calc_insert_size, list(zip([self] * len(l_chrm_records0), l_chrm_records0)), 1)
        pool.close()
        pool.join()

        for record in l_chrm_records0:
            sf_mean_is_chrm = record[-1]
            if os.path.isfile(sf_mean_is_chrm) == False:
                continue
            with open(sf_mean_is_chrm) as fin_mean_is_chrm:
                for line in fin_mean_is_chrm:
                    fields = line.split()
                    rg = fields[0]
                    f_sum = float(fields[1])
                    i_cnt = int(fields[2])
                    f_sum2 = float(fields[3])
                    f_rl = int(fields[4])

                    if rg not in m_sum_is:
                        m_sum_is[rg] = 0
                    m_sum_is[rg] += f_sum

                    if rg not in m_sum2_is:
                        m_sum2_is[rg] = 0
                    m_sum2_is[rg] += f_sum2

                    if rg not in m_cnt_is:
                        m_cnt_is[rg] = 0
                    m_cnt_is[rg] += i_cnt

                    if rg not in m_rl:
                        m_rl[rg] = 0
                    if f_rl > m_rl[rg]:
                        m_rl[rg] = f_rl

        m_mean = {}
        tmp_sum_is=0.0
        tmp_cnt_is=0
        for rg in m_sum_is:
            if rg not in m_cnt_is:
                print(("Error: No match count number for read group {0}".format(rg)))
                continue
            f_mean = float(m_sum_is[rg]) / float(m_cnt_is[rg])
            m_mean[rg] = f_mean
            tmp_sum_is+=f_mean
            tmp_cnt_is+=1
        ave_is=float(tmp_sum_is)/float(tmp_cnt_is)

        # calc the standard derivation
        # E(x^2)-[E(x)]^2
        m_std = {}
        tmp_sum_std=0.0
        tmp_cnt_std=0
        for rg in m_sum2_is:
            if rg not in m_mean or rg not in m_cnt_is:
                print(("Error: No match count number or mean for read group {0}".format(rg)))
                continue
            f2_mean = float(m_sum2_is[rg]) / float(m_cnt_is[rg])
            variance = f2_mean - m_mean[rg] ** 2
            std_var = variance ** 0.5
            m_std[rg] = std_var
            tmp_sum_std+=std_var
            tmp_cnt_std+=1
        ave_std=float(tmp_sum_std)/float(tmp_cnt_std)

        with open(sf_out, "w") as fout_rg_is:
            for rg in m_rgs:
                rlth=100
                if rg in m_rl:
                    rlth = m_rl[rg]
                if rg in m_mean:
                    i_m_is=int(m_mean[rg])
                    f_std=m_std[rg]
                    s_info="{0}\t{1}\t{2}\t{3}\n".format(rg, i_m_is, f_std, rlth)
                    fout_rg_is.write(s_info)
                else:
                    s_info = "{0}\t{1}\t{2}\t{3}\n".format(rg, int(ave_is), ave_std, rlth)
                    fout_rg_is.write(s_info)


    # given chromosome lengths, break to bins
    def break_ref_to_bins(self, m_chrm_length, bin_size):
        m_bins = {}
        if bin_size>0:
            for chrm in m_chrm_length:
                if chrm not in m_bins:
                    m_bins[chrm] = []
                chrm_lenth = m_chrm_length[chrm]
                tmp_pos = 0
                while tmp_pos < chrm_lenth:
                    block_end = tmp_pos + bin_size
                    if block_end > chrm_lenth:
                        block_end = chrm_lenth
                    m_bins[chrm].append((tmp_pos, block_end))
                    tmp_pos = block_end
        else:
            for chrm in m_chrm_length:
                if chrm not in m_bins:
                    m_bins[chrm] = []
                chrm_lenth = m_chrm_length[chrm]
                m_bins[chrm].append((0, chrm_lenth))
        return m_bins

    ###get all the read groups
    def get_read_groups(self):
        m_rgs = {}
        bamfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        header = bamfile.header
        bamfile.close()

        if 'RG' not in header:
            m_rgs['None']=1
            return m_rgs

        l_rgs = header['RG']
        for record in l_rgs:
            rg_name = record['ID']
            m_rgs[rg_name] = 1
        return m_rgs

    #load insert size from file
    def load_in_from_file(self, sf_is):
        m_is={}
        with open(sf_is) as fin_is:
            for line in fin_is:
                fields=line.split()
                rg=fields[0]
                i_is=int(fields[1])
                f_std=float(fields[2])
                rlth=int(fields[3])
                m_is[rg]=(i_is, f_std, rlth)
        return m_is
