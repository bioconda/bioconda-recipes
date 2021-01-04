##08/27/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

#This is a stand alone module that has its own main entry

#Two major functions:
#1. Merge the Alu, L1, SVA insertions of a sample to a single VCF
#2. Merge the samples of different population to a single VCF

#TODO List:
# 1) Joint calling!
# 2) calculate the source activity by transduction;
# 3) rescue the potential somatic full length L1 (with lots of transdcutions point to, thus form coverage island)

import os
from x_rep_type import *
import global_values
from cmd_runner import *
from optparse import OptionParser

####
class VCFMerger():#
    def __init__(self):
        return

    def load_in_sample_info(self, sf_sample_info):
        m_sample_info={}
        m_pop_cnt={}#number of samples of each population

        with open(sf_sample_info) as fin_info:
            for line in fin_info:
                fields=line.split()
                sample_name=fields[0]
                sex=fields[1]
                biosample_id=fields[2]
                pop_code=fields[3]
                if len(pop_code)<=0:
                    print("population sample file parse error: {0}".format(line.rstrip()))
                    continue
                if pop_code not in m_pop_cnt:
                    m_pop_cnt[pop_code]=0
                m_pop_cnt[pop_code] += 1

                m_sample_info[sample_name]=(sex, biosample_id, pop_code)
        return m_sample_info, m_pop_cnt
####
    def load_rslts_folders(self, sf_rslt_folders):
        m_folders={}
        with open(sf_rslt_folders) as fin_folder:
            for line in fin_folder:
                fields = line.rstrip().split()
                s_sample = fields[0]
                sf_folder = fields[1]
                if s_sample not in m_folders:
                    m_folders[s_sample]=sf_folder
        return m_folders

####
    def load_rslts_list(self, sf_rslt_list):
        m_rslts={}
        with open(sf_rslt_list) as fin_list:
            for line in fin_list:
                fields=line.rstrip().split()
                s_sample=fields[0]
                sf_vcf=fields[1]
                if s_sample not in m_rslts:
                    m_rslts[s_sample]=[]
                m_rslts[s_sample].append(sf_vcf)
        return m_rslts

    def sort_raw_rslt(self, sf_raw_rslt, sf_sorted_rslt):
        cmd = "sort -k1,1V -k2,2n -o {0} {1}".format(sf_sorted_rslt, sf_raw_rslt)
        cmd_runner = CMD_RUNNER()
        cmd_runner.run_cmd_small_output(cmd)

    def dump_to_unsorted_file(self, m_sites, sf_tmp):
        with open(sf_tmp, "w") as fout_tmp:
            for chrm in m_sites:
                for pos in m_sites[chrm]:
                    sinfo=m_sites[chrm][pos]
                    if sinfo!="" and sinfo is not None:
                        fout_tmp.write(sinfo+"\n")
####
    ####
    def load_vcf_head(self, sf_vcf):
        l_head=[]
        if os.path.isfile(sf_vcf)==False:
            print("[Get VCF head]: File {0} doesn't exist!".format(sf_vcf))
            return l_head
        with open(sf_vcf) as fin_vcf:
            for line in fin_vcf:
                if len(line)>0 and line[0]=="#":
                    if "contig" in line:
                        if "HLA" in line:
                            continue
                        if "Un" in line:
                            continue
                        if "_" in line:
                            continue
                    l_head.append(line.rstrip())
        return l_head

####
class PopVCFMerger(VCFMerger):
    def __init__(self):
        VCFMerger.__init__(self)
        return

    def cnt_current_pop_cnt(self, m_sample_info, m_rslt_list):
        m_pop_cnt={}
        for sample_id in m_rslt_list:
            if sample_id not in m_sample_info:
                continue
            s_pop_code=m_sample_info[sample_id][2]
            if s_pop_code not in m_pop_cnt:
                m_pop_cnt[s_pop_code]=0
            m_pop_cnt[s_pop_code] += 1
        return m_pop_cnt
####
    # Sample name     Sex     Biosample ID    Population code Population name Superpopulation code    Superpopulation name    Population elastic ID   Data collections
    # HG00128 female  SAME122868      GBR     British,English EUR     European Ancestry,West Eurasia (SGDP)   GBR,EnglishSGDP 1000 Genomes on GRCh38,Simons Genome Diversity Project,1000 Genomes phase 3 release,1000 Genomes phase 1 release,Geuvadis
    ####HG00130 female  SAME123063      GBR     British EUR     European Ancestry       GBR     1000 Genomes on GRCh38,1000 Genomes phase 3 release,1000 Genomes phase 1 release,Geuvadis
    def gnrt_population_vcf(self, sf_sample_info, sf_rslt_list, peak_window, sf_wfolder, sf_out):
        m_sample_info, m_pop_cnt_total = self.load_in_sample_info(sf_sample_info)
        m_rslt_list = self.load_rslts_folders(sf_rslt_list)
        m_pop_cnt = self.cnt_current_pop_cnt(m_sample_info, m_rslt_list)
        if len(sf_wfolder) > 0:
            if sf_wfolder[-1] != "/":
                sf_wfolder += "/"
        else:
            return

        m_all_sites = {}
        sf_template_vcf=""
        b_set_template=False
        for s_sample in m_sample_info:#
            if s_sample in m_rslt_list:
                #sf_rslt_folder = m_rslt_list[s_sample]
                # if len(sf_rslt_folder) > 0 and sf_rslt_folder[-1] != "/":
                #     sf_rslt_folder += "/"
                #sf_sample_vcf = sf_rslt_folder + s_sample + ".vcf"
                sf_sample_vcf = m_rslt_list[s_sample]
                if b_set_template==False:
                    sf_template_vcf=sf_sample_vcf
                    b_set_template=True

                if os.path.isfile(sf_sample_vcf) == False:
                    print("{0} doesn't exist!".format(sf_sample_vcf))
                    continue
                # then, merge all the samples to one single VCF
                self.load_in_sample_vcf(s_sample, sf_sample_vcf, m_all_sites)

        m_peak_sites=self.call_peak_candidate_sites_vcf(m_all_sites, peak_window)
        l_samples = sorted(m_rslt_list.keys())

        s_column_name="#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT"
        for sample_name in l_samples:
            s_column_name+=("\t"+sample_name)
        s_column_name+="\n"

        sf_unsorted=sf_out+".tmp_unsorted"
        sf_td_src_unsort=sf_out+".td_src.tmp_unsorted"
        with open(sf_unsorted,"w") as fout, open(sf_td_src_unsort,"w") as fout_td_src:
            for chrm in m_peak_sites:
                for pos in m_peak_sites[chrm]:
                    l_sample_rcds=m_peak_sites[chrm][pos]
                    s_info, m_td_src_rcd, s_pos_info=self._cvt_one_rcd_to_pop_info(chrm, pos, m_sample_info, l_samples,
                                                                       m_pop_cnt, l_sample_rcds)
                    fout.write(s_info)
                    ####convert td_src to str, and write to file
                    s_td_src=self._cvt_td_src_rcd_to_str(m_td_src_rcd)
                    if "" is not s_td_src:
                        fout_td_src.write(s_pos_info+s_td_src+"\n")#

        sf_sorted=sf_out+".tmp_sorted"
        self.sort_raw_rslt(sf_unsorted, sf_sorted)
        sf_td_src_sort = sf_out + ".td_src.tmp_sorted"
        self.sort_raw_rslt(sf_td_src_unsort, sf_td_src_sort)

        self.dump_info_for_pca(m_sample_info, l_samples, m_peak_sites, sf_out+".pca")
        with open(sf_out, "w") as fout:#
            ####write the head here!!!!
            # save the reference info
            l_alt_head = self._take_chrm_head_from_template_vcf(sf_template_vcf)
            for tmp_head_line in l_alt_head:
                fout.write(tmp_head_line + "\n")
            s_head2 = self.prepare_head_other(m_pop_cnt)
            fout.write(s_head2)
            fout.write(s_column_name)
            with open(sf_sorted) as fin_sorted:
                for line in fin_sorted:
                    fout.write(line)
        os.remove(sf_unsorted)
        os.remove(sf_sorted)

####

####Todo: add sub-population information for each sample
    def dump_info_for_pca(self, m_sample_info, l_samples, m_sites, sf_out):
        l_sites=[]
        m_sample_sites = {}
        s_head = "sample,population"
        for chrm in m_sites:
            for pos in m_sites[chrm]:
                s_site="{0}_{1}".format(chrm, pos)
                l_sites.append(s_site)
                s_head+=(","+s_site)
                for (s_sample, site_info) in m_sites[chrm][pos]:
                    if s_sample not in m_sample_sites:
                        m_sample_sites[s_sample]={}
                    site_fields=site_info.rstrip().split()
                    sgntp=site_fields[-1]
                    m_sample_sites[s_sample][s_site]=sgntp
        s_head+="\n"

        with open(sf_out,"w") as fout:
            fout.write(s_head)
            for sample in l_samples:
                if sample not in m_sample_sites:
                    print("{0} not in sample list".format(sample))
                    continue
                s_pop=m_sample_info[sample][2]
                sinfo="{0},{1}".format(sample,s_pop)
                for s_site in l_sites:
                    if s_site in m_sample_sites[sample]:
                        if ("1/1" == m_sample_sites[sample][s_site]) or ("1|1" == m_sample_sites[sample][s_site]):
                            sinfo += ",2"
                        else:
                            sinfo+=",1"
                    else:
                        sinfo+=",0"
                sinfo+="\n"
                fout.write(sinfo)

####
    def _take_chrm_head_from_template_vcf(self, sf_vcf):
        l_heads=[]
        with open(sf_vcf) as fin_vcf:
            for line in fin_vcf:
                if line[0]=="#":
                    if "contig" in line:
                        if "HLA" in line:
                            continue
                        if "Un" in line:
                            continue
                        if "_" in line:
                            continue
                    fields=line.split("=")
                    if fields[0]=="##fileformat" or fields[0]=="##reference" or fields[0]=="##contig":
                        l_heads.append(line.rstrip())
        return l_heads

####
    #Note: here we only check the maximum frequency of exact position, not the hits of a range
    def _cvt_td_src_rcd_to_str(self, m_td_src_rcd):
        s_td_src_info=""
        for s_pop_code in m_td_src_rcd:
            i_max_cnt=0
            s_max_td_src=""
            for s_td_src in m_td_src_rcd[s_pop_code]:
                if m_td_src_rcd[s_pop_code][s_td_src]>i_max_cnt:
                    s_max_td_src=s_td_src
                    i_max_cnt=m_td_src_rcd[s_pop_code][s_td_src]
            if "" is not s_max_td_src:
                s_td_src_info+=("\t"+s_pop_code+":"+s_max_td_src)
        return s_td_src_info
####
    #convert one site record to one population information
    #l_samples: save all the sample ids
    #m_pop_cnt: save the number of individuals of each population {pop-code:num-of-samples}
    #l_sample_info: list of sample-info that has insertion at given site
    def _cvt_one_rcd_to_pop_info(self, chrm, pos, m_sample_info, l_samples, m_pop_cnt, l_sample_rcd):
        #for given site, count how many samples in each population
        m_pop_cnt_per_site={}
        m_sample_gntp={}
        m_het={}
        m_homo={}
        m_site_type={}#same site may be called as different type of insertions for different samples, select dominant
        m_end_pos={}
        m_genes={}
        m_ref_rep={}
        m_sv_len={}
        m_td_src={}#transduction source regions
        for (sample_id, s_gvcf_rcd) in l_sample_rcd:
            if sample_id not in m_sample_info:
                print("[Convert Error]: sample {0} not in dictionary".format(sample_id))
                continue
            l_tmp_fields=s_gvcf_rcd.split()
            s_rep_type=l_tmp_fields[4]
            if s_rep_type not in m_site_type:
                m_site_type[s_rep_type]=0
            m_site_type[s_rep_type]+=1#insertion type
            s_gntp=l_tmp_fields[-1]
            m_sample_gntp[sample_id]=s_gntp
            s_tmp_fields2=l_tmp_fields[7].split(";")
            s_sv_len = s_tmp_fields2[1] #note fixed index
            if s_sv_len not in m_sv_len:
                m_sv_len[s_sv_len]=0
            m_sv_len[s_sv_len]+=1

            s_end=s_tmp_fields2[2]
            if s_end not in m_end_pos:
                m_end_pos[s_end]=0
            m_end_pos[s_end] += 1

            s_pop_code = m_sample_info[sample_id][2]  # population code
            #save the transduction source
            s_td_src=s_tmp_fields2[6][7:]#note fixed index
            if s_pop_code not in m_td_src:
                m_td_src[s_pop_code]={}

            if global_values.NOT_TRANSDUCTION not in s_td_src:#make sure it is a transduction
                if s_td_src not in m_td_src[s_pop_code]:
                    m_td_src[s_pop_code][s_td_src]=1
                else:
                    m_td_src[s_pop_code][s_td_src] += 1

            s_ref_rep=s_tmp_fields2[-2]
            if s_ref_rep not in m_ref_rep:
                m_ref_rep[s_ref_rep]=0
            m_ref_rep[s_ref_rep]+=1
            s_gene=s_tmp_fields2[-1]
            if s_gene not in m_genes:
                m_genes[s_gene]=0
            m_genes[s_gene]+=1

            if s_pop_code not in m_pop_cnt_per_site:
                m_pop_cnt_per_site[s_pop_code]=0
            m_pop_cnt_per_site[s_pop_code]+=1
####
            if s_gntp == "0/1" or s_gntp == "1/0" or s_gntp == "0|1" or s_gntp == "1|0":
                if s_pop_code not in m_het:
                    m_het[s_pop_code] = 0
                m_het[s_pop_code]+=1
            elif s_gntp=="1|1" or s_gntp=="1/1":
                if s_pop_code not in m_homo:
                    m_homo[s_pop_code]=0
                m_homo[s_pop_code]+=1
####
        #merge the genotype information
        sinfo = ""
        n_max=0
        s_type=""
        for s_tmp_type in m_site_type:
            if n_max<m_site_type[s_tmp_type]:
                n_max=m_site_type[s_tmp_type]
                s_type=s_tmp_type
        s_position_info = "{0}\t{1}\t.\tN\t{2}\t.\tPASS\tSVTYPE={3};".format(chrm, pos, s_type, s_type[1:-1])
        sinfo+=s_position_info

        s_max_end=""
        n_max_cnt=0
        for s_tmp2 in m_end_pos:
            if n_max_cnt<m_end_pos[s_tmp2]:
                n_max_cnt=m_end_pos[s_tmp2]
                s_max_end=s_tmp2
        s_max_sv_len=""
        n_max_sv_len=0
####!!!!!!!!
########NOTE: here we only use the highest frequency one as the "max sv lenth", not the longest one!!!
        for s_tmp3 in m_sv_len:
            if n_max_sv_len<m_sv_len[s_tmp3]:
                n_max_sv_len=m_sv_len[s_tmp3]
                s_max_sv_len=s_tmp3
        sinfo+=(s_max_end+";"+s_max_sv_len+";")

        s_samples_gntp=""
        for sample_id in l_samples:
            if sample_id in m_sample_gntp:
                s_samples_gntp+=("\t"+m_sample_gntp[sample_id])
            else:
                s_samples_gntp += ("\t0/0")

        ####save the total number
        n_total_het=0
        n_total_homo=0
        #calculate the AF by population
        #for each population: AC, AF, AN, n_het, h_homo_alt, n_homo_ref, freq_het, freq_homo, freq_null
        s_allele_info=""
        n_total_sample=0

        s_tmp_allele_info=""
        for s_pop_code in m_pop_cnt:
            n_total_sample+=m_pop_cnt[s_pop_code]
            if s_pop_code not in m_pop_cnt_per_site:
                #print "[Convert Error]: Population {0} not in dictionary".format(s_pop_code)
                continue
            n_pop_samples=m_pop_cnt[s_pop_code]
            n_pop_AN=2*n_pop_samples
            n_het=0
            if s_pop_code in m_het:
                n_het=m_het[s_pop_code]
            n_homo=0
            if s_pop_code in m_homo:
                n_homo=m_homo[s_pop_code]
            n_pop_AC=n_het+2*n_homo
            n_pop_AF=float(n_pop_AC)/float(n_pop_AN)
            n_total_het+=n_het
            n_total_homo+=n_homo
            n_homo_ref=n_pop_samples-n_het-n_homo
            n_het_freq=float(n_het)/float(n_pop_samples)
            n_homo_freq=float(n_homo)/float(n_pop_samples)
            n_homoref_freq=float(n_homo_ref)/float(n_pop_samples)
            rcd=(n_pop_AN, n_pop_AC, n_pop_AF, n_het, n_homo, n_homo_ref,
                                           n_het_freq, n_homo_freq, n_homoref_freq, n_pop_samples)
            s_tmp_allele_info+=self._prepare_one_record(s_pop_code+"_", rcd)

        #n_total_sample = len(m_sample_info)  # total number of samples
        n_total_sample=len(l_samples)#total number of counted samples
        n_total_AN=2*n_total_sample
        n_total_AC=n_total_het+2*n_total_homo
        n_total_AF=float(n_total_AC)/float(n_total_AN)
        n_total_homoref=n_total_sample-n_total_het-n_total_homo
        n_total_het_freq=float(n_total_het)/float(n_total_sample)
        n_total_homo_freq=float(n_total_homo)/float(n_total_sample)
        n_total_homo_ref_freq = float(n_total_homoref) / float(n_total_sample)
        total_rcd=(n_total_AN, n_total_AC, n_total_AF, n_total_het, n_total_homo, n_total_homoref, n_total_het_freq,
                   n_total_homo_freq, n_total_homo_ref_freq, n_total_sample)
        s_allele_info += self._prepare_one_record("", total_rcd) #total AF
        s_allele_info += s_tmp_allele_info #sub-populaiton AF

        sinfo+=s_allele_info
        s_rep_info=""
        n_cnt=0
        for s_tmp_rep in m_ref_rep:
            if n_cnt< m_ref_rep[s_tmp_rep]:
                n_cnt=m_ref_rep[s_tmp_rep]
                s_rep_info=s_tmp_rep
        sinfo+=(s_rep_info+";")
        s_gene_info=""
        n_cnt=0
        for s_tmp_gene in m_genes:
            if n_cnt< m_genes[s_tmp_gene]:
                n_cnt= m_genes[s_tmp_gene]
                s_gene_info=s_tmp_gene
        sinfo+=(s_gene_info)

        sinfo+="\tGT"
        sinfo+=s_samples_gntp
        sinfo+="\n"
        return sinfo, m_td_src, s_position_info
####

####
    def _prepare_one_record(self, s_pop_code, t_rcd):
        sinfo=""
        sinfo+="{0}AN={1};".format(s_pop_code, t_rcd[0])
        sinfo += "{0}AC={1};".format(s_pop_code, t_rcd[1])
        sinfo += "{0}AF={1};".format(s_pop_code, t_rcd[2])
        sinfo += "{0}N_HET={1};".format(s_pop_code, t_rcd[3])
        sinfo += "{0}N_HOMALT={1};".format(s_pop_code, t_rcd[4])
        sinfo += "{0}N_HOMREF={1};".format(s_pop_code, t_rcd[5])

        sinfo += "{0}FREQ_HET={1};".format(s_pop_code, t_rcd[6])
        sinfo += "{0}FREQ_HOMALT={1};".format(s_pop_code, t_rcd[7])
        sinfo += "{0}FREQ_HOMREF={1};".format(s_pop_code, t_rcd[8])
        sinfo += "{0}N_BI_GENOS={1};".format(s_pop_code, t_rcd[9])
        return sinfo

    def _gnrt_population_head_info_one_pop(self, s_code1, s_code2, l_head_info):
        s_AC = "##INFO=<ID={0}AC,Number=A,Type=Integer,Description" \
               "=\"Number of non-reference {1} alleles observed.\">\n".format(s_code1, s_code2)
        s_AF = "##INFO=<ID={0}AF,Number=A,Type=Float,Description" \
               "=\"{1} allele frequency.\">\n".format(s_code1, s_code2)
        s_AN = "##INFO=<ID={0}AN,Number=1,Type=Integer,Description" \
               "=\"Total number of {1} alleles genotyped.\">\n".format(s_code1, s_code2)
        s_FREQ_HET = "##INFO=<ID={0}FREQ_HET,Number=1,Type=Float,Description" \
                     "=\"{1} heterozygous genotype frequency.\">\n".format(s_code1, s_code2)
        s_FREQ_HOMALT = "##INFO=<ID={0}FREQ_HOMALT,Number=1,Type=Float," \
                        "Description=\"{1} homozygous alternate genotype frequency.\">\n".format(s_code1, s_code2)
        s_FREQ_HOMREF = "##INFO=<ID={0}FREQ_HOMREF,Number=1,Type=Float,Description" \
                        "=\"{1} homozygous reference genotype frequency.\">\n".format(s_code1, s_code2)
        s_N_BI_GENOS = "##INFO=<ID={0}N_BI_GENOS,Number=1,Type=Integer,Description" \
                       "=\"Total number of {1} individuals with complete genotypes.\">\n".format(s_code1, s_code2)
        s_N_HET = "##INFO=<ID={0}N_HET,Number=1,Type=Integer,Description" \
                  "=\"Number of {1} individuals with heterozygous genotypes.\">\n".format(s_code1, s_code2)
        s_N_HOMALT = "##INFO=<ID={0}N_HOMALT,Number=1,Type=Integer,Description" \
                     "=\"Number of {1} individuals with homozygous alternate genotypes.\">\n".format(s_code1, s_code2)
        s_N_HOMREF = "##INFO=<ID={0}N_HOMREF,Number=1,Type=Integer,Description" \
                     "=\"Number of {1} individuals with homozygous reference genotypes.\">\n".format(s_code1, s_code2)
        l_head_info.append(s_AC)  # total number of non-reference alleles observed
        l_head_info.append(s_AF)  # Allel frequency
        l_head_info.append(s_AN)  # total number of alleles genotyped
        l_head_info.append(s_FREQ_HET)  # heterozygous genotype frequency
        l_head_info.append(s_FREQ_HOMALT)  # homozygous alternate genotype frequency
        l_head_info.append(s_FREQ_HOMREF)  # homozygous reference genotype frequency
        l_head_info.append(s_N_BI_GENOS)  # Number of individuals with complete genotypes
        l_head_info.append(s_N_HET)  # number of individuals with heterozygous genotypes
        l_head_info.append(s_N_HOMALT)  # number of individuals with homozygous alternate genotypes
        l_head_info.append(s_N_HOMREF)  # number of individuals with homozygous reference genotypes

    ####gnrt population head info
    def _gnrt_population_head_info(self, m_pop_cnt):
        l_head_info=[]
        self._gnrt_population_head_info_one_pop("","", l_head_info)#this is for the total
        for s_code in m_pop_cnt:#this is for each population
            self._gnrt_population_head_info_one_pop(s_code+"_", s_code, l_head_info)
        return l_head_info

####
    def prepare_head_other(self, m_pop_cnt):
        sinfo=""
        sinfo += "##ALT=<ID=INS:ME:SVA,Description=\"Insertion of SVA element\">\n"
        sinfo += "##ALT=<ID=INS:ME:LINE1,Description=\"Insertion of LINE1 element\">\n"
        sinfo += "##ALT=<ID=INS:ME:ALU,Description=\"Insertion of ALU element\">\n"
        sinfo += "##ALT=<ID=INS:ME:HERV-K,Description=\"Insertion of HERV-K element\">\n"
        sinfo += "##ALT=<ID=INS:MT,Description=\"Mitochondrial insertion\">\n"
        sinfo += "##ALT=<ID=INS:PSDGN,Description=\"Pseudogene insertion\">\n"
        sinfo += "##FILTER=<ID=PASS,Description=\"All filters passed\">\n"
        sinfo += "##FILTER=<ID=LowConfident,Description=\"All filters passed\">\n"
        l_pop_head_info=self._gnrt_population_head_info(m_pop_cnt)
        for s_pop_info in l_pop_head_info:
            sinfo+=s_pop_info
        sinfo += "##INFO=<ID=SVTYPE,Number=1,Type=String,Description=\"Type of structural variant\">\n"
        sinfo += "##INFO=<ID=SVLEN,Number=1,Type=Integer,Description=\"Insertion length\">\n"
        sinfo += "##INFO=<ID=END,Number=1,Type=Integer,Description=\"End coordinate of this variant\">\n"
        #sinfo += "##INFO=<ID=TD_SRC,Number=1,Type=String,Description=\"Transduction source\">\n"
        sinfo += "##INFO=<ID=STRAND,Number=1,Type=String,Description=\"Insertion orientation (+/- for sense/antisense)\">\n"
        #sinfo += "##INFO=<ID=INS_INV,Number=1,Type=String,Description=\"5 prime inversion\">\n"
        sinfo += "##INFO=<ID=REF_REP,Number=1,Type=String,Description=\"Fall in reference repeat copy or not\">\n"
        sinfo += "##INFO=<ID=GENE_INFO,Number=1,Type=String,Description=\"Fall in gene region\">\n"
        sinfo += "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">\n"
        return sinfo

####
    def load_in_sample_vcf(self, sample_id, sf_vcf, m_all_sites):
        if os.path.isfile(sf_vcf)==False:
            print("File {0} doesn't exist!".format(sf_vcf))
            return
        with open(sf_vcf) as fin_vcf:
            for line in fin_vcf:
                fields=line.rstrip().split('\t')
                if len(fields)<3:
                    continue
                if line[0]=="#":
                    continue

                ins_chrm=fields[0]
                ins_pos=int(fields[1])
                if ins_chrm not in m_all_sites:
                    m_all_sites[ins_chrm]={}
                if ins_pos not in m_all_sites[ins_chrm]:
                    m_all_sites[ins_chrm][ins_pos] = []
                m_all_sites[ins_chrm][ins_pos].append((sample_id, line.rstrip()))
####

####
    # For each cluster, use the peak one as the representative one
    def call_peak_candidate_sites_vcf(self, m_candidate_sites, peak_window):
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
                    max_cnt = 0
                    tmp_candidate_pos = 0
                    l_tmp_rcds = []
                    for tmp_pos in set_cluster:
                        tmp_cnt = len(m_candidate_sites[chrm][tmp_pos])  # num of supported samples
                        for tmp_rcd in m_candidate_sites[chrm][tmp_pos]:
                            l_tmp_rcds.append(tmp_rcd)
                        if max_cnt < tmp_cnt:
                            tmp_candidate_pos = tmp_pos
                            max_cnt = tmp_cnt
                    set_cluster.clear()
                    if chrm not in m_peak_candidate_sites:
                        m_peak_candidate_sites[chrm] = {}
                    if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                        m_peak_candidate_sites[chrm][tmp_candidate_pos] = []
                    for tmp_rcd2 in l_tmp_rcds:
                        m_peak_candidate_sites[chrm][tmp_candidate_pos].append(tmp_rcd2)
                pre_pos = pos
                set_cluster.add(pre_pos)
####
            # push out the last group
            max_cnt = 0
            tmp_candidate_pos = 0
            l_tmp_rcds = []
            for tmp_pos in set_cluster:
                tmp_cnt = len(m_candidate_sites[chrm][tmp_pos])  # num of supported samples
                for tmp_rcd in m_candidate_sites[chrm][tmp_pos]:
                    l_tmp_rcds.append(tmp_rcd)
                if max_cnt < tmp_cnt:
                    tmp_candidate_pos = tmp_pos
                    max_cnt = tmp_cnt
            set_cluster.clear()
            if chrm not in m_peak_candidate_sites:
                m_peak_candidate_sites[chrm] = {}
            if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                m_peak_candidate_sites[chrm][tmp_candidate_pos] = []
            for tmp_rcd2 in l_tmp_rcds:
                m_peak_candidate_sites[chrm][tmp_candidate_pos].append(tmp_rcd2)
        return m_peak_candidate_sites

####sample vcf merger
class SampleVCFMerger(VCFMerger):
    def __init__(self):
        VCFMerger.__init__(self)
        return
####
    def merge_vcf_for_all_rep_types(self, sf_sample_info, sf_rslt_list, i_rep_type, i_single_win, sf_wfolder):
        m_sample_info, m_pop_cnt = self.load_in_sample_info(sf_sample_info)
        m_rslt_folders = self.load_rslts_folders(sf_rslt_list)
        # first merge vcf of different repeat type of each sample
        if len(sf_wfolder) > 0:
            if sf_wfolder[-1] != "/":
                sf_wfolder += "/"
        else:
            return

        for s_sample in m_sample_info:
            if s_sample in m_rslt_folders:
                sf_rslt_folder = m_rslt_folders[s_sample]
                if len(sf_rslt_folder) > 0 and sf_rslt_folder[-1] != "/":
                    sf_rslt_folder += "/"  #
                sf_merged = sf_wfolder + s_sample + ".vcf"
                self.merge_single_sample_ins(i_rep_type, sf_rslt_folder, s_sample, i_single_win, sf_merged)

    ####
    def merge_single_sample_ins(self, i_rep_type, sf_rslt_folder, s_sample_id, i_win, sf_merged):
        print("Merging sub-type vcf of sample {0}".format(s_sample_id))
        reptype = RepType()
        m_rep_types=reptype.get_all_rep_types(i_rep_type)
        m_all_sites={}
        #first load in L1, then SVA, then Alu, HERV
        #when conflicts happen, first check the quality, if quality equal, then follow this order
        b_head=False
        l_head=[]
        #for L1
        s_L1=reptype.get_L1_str()
        if s_L1 in m_rep_types:
            s_L1_folder="L1"
            sf_vcf = sf_rslt_folder + s_L1_folder +"/"+ s_sample_id + "_" + s_L1 + ".vcf"
            l_head=self.load_vcf_head(sf_vcf)
            b_head=True
            self.load_in_sites_from_vcf(sf_vcf, m_all_sites)
        #For SVA
        s_SVA=reptype.get_SVA_str()
        if s_SVA in m_rep_types:
            sf_vcf = sf_rslt_folder + s_SVA +"/"+ s_sample_id + "_" + s_SVA + ".vcf"
            if b_head==False:
                l_head = self.load_vcf_head(sf_vcf)
                b_head = True
            self.append_sites_from_vcf(sf_vcf, i_win, m_all_sites)
        #For Alu
        s_Alu=reptype.get_Alu_str()
        if s_Alu in m_rep_types:
            s_Alu_folder="Alu"
            sf_vcf = sf_rslt_folder + s_Alu_folder +"/"+ s_sample_id + "_" + s_Alu + ".vcf"
            if b_head == False:
                l_head = self.load_vcf_head(sf_vcf)
                b_head = True
            self.append_sites_from_vcf(sf_vcf, i_win, m_all_sites)
        #for HERV
        s_HERV=reptype.get_HERV_str()
        if s_HERV in m_rep_types:
            sf_vcf = sf_rslt_folder + s_HERV +"/"+ s_sample_id + "_" + s_HERV + ".vcf"
            if b_head == False:
                l_head = self.load_vcf_head(sf_vcf)
                b_head = True
            self.append_sites_from_vcf(sf_vcf, i_win, m_all_sites)
        #write the merged to file
        #first dump the dict to a file
        sf_unsorted=sf_merged+".unsorted"
        self.dump_to_unsorted_file(m_all_sites, sf_unsorted)
        #sor the file to a new file
        sf_sorted=sf_merged+".sorted"
        self.sort_raw_rslt(sf_unsorted, sf_sorted)
        #then write to vcf
        with open(sf_merged,"w") as fout_merged:
            for sline in l_head:
                fout_merged.write(sline.rstrip()+"\n")
            with open(sf_sorted) as fin_sorted:
                for line in fin_sorted:
                    fout_merged.write(line.rstrip()+"\n")
        #remove the tmp file
        os.remove(sf_unsorted)
        os.remove(sf_sorted)
###

    def load_in_sites_from_vcf(self, sf_vcf, m_sites):
        if os.path.isfile(sf_vcf)==False:
            print("File {0} doesn't exist!".format(sf_vcf))
            return
        with open(sf_vcf) as fin_vcf:
            for line in fin_vcf:
                fields=line.split('\t')
                if len(fields)<3:
                    continue
                if line[0]=="#":
                    continue
                ins_chrm=fields[0]
                ins_pos=int(fields[1])
                if ins_chrm not in m_sites:
                    m_sites[ins_chrm]={}
                m_sites[ins_chrm][ins_pos]=line.rstrip()

    def append_sites_from_vcf(self, sf_vcf, i_win, m_sites):
        if os.path.isfile(sf_vcf)==False:
            print("File {0} doesn't exist!!".format(sf_vcf))
            return
        with open(sf_vcf) as fin_vcf:
            for line in fin_vcf:
                fields=line.split('\t')
                if len(fields)<3:
                    continue
                if line[0]=="#":
                    continue
                ins_chrm=fields[0]
                ins_pos=int(fields[1])
                if ins_chrm not in m_sites:
                    m_sites[ins_chrm]={}
                #here check whether have a conflict
                i_start=-1*i_win+ins_pos
                i_end=i_win+ins_pos
                b_hit=False
                s_hit_rcd=""
                i_hit_pos=-1
                for i_tmp_pos in range(i_start, i_end):
                    if i_tmp_pos in m_sites[ins_chrm]:
                        b_hit=True
                        s_hit_rcd=m_sites[ins_chrm][i_tmp_pos]
                        i_hit_pos=i_tmp_pos
                        break

                #check the quality of the two ins, if current one has higher quality, then replace it
                if b_hit==True:#conflict happen
                    b_keep_first=self.cmp_quality_of_two_ins(s_hit_rcd, line.rstrip())
                    if b_keep_first==False:
                        m_sites[ins_chrm][i_hit_pos]=""#will be deleted when dump to file
                        m_sites[ins_chrm][ins_pos]=line.rstrip()#replace to the new record
                        continue
                ####
                m_sites[ins_chrm][ins_pos]=line.rstrip()

####
    def cmp_quality_of_two_ins(self, s_rcd1, s_rcd2):
        b_keep_first=True
        s_tprt_both=global_values.TWO_SIDE_TPRT_BOTH
        if (s_tprt_both not in s_rcd1) and (s_tprt_both in s_rcd2):
            return False
        return b_keep_first

#this class is not used
#XVCF: convert and merge gVCFs to a single VCF
class XVCF():
    # for output: each insertion is one record
    def cvt_raw_to_vcf(self, sf_rslt_list, i_peak_win, sf_vcf, min_ins_len=0):
        # first load in all the results from file
        m_samples, m_all_sites = self._load_in_raw_rslts(sf_rslt_list, min_ins_len)
        # each record in format: [chrm][pos]: [list of records]
        m_merged_sites = self.call_peak_candidate_sites_vcf(m_all_sites, i_peak_win)
        self.export_to_vcf(m_samples, m_merged_sites, sf_vcf)

    ####This is used to draw the pca by population
    def cvt_raw_rslt_for_pca_by_sample(self, sf_rslt_list, i_peak_win, sf_sample_info, sf_csv, min_ins_len=0):
        # first load in all the results from file
        m_samples, m_all_sites = self._load_in_raw_rslts(sf_rslt_list, min_ins_len)
        # each record in format: [chrm][pos]: [list of records]
        m_merged_sites = self.call_peak_candidate_sites_vcf(m_all_sites, i_peak_win)
        self.export_to_pca_input(sf_sample_info, m_merged_sites, sf_csv)

    ####
    def export_to_vcf(self, m_samples, m_merged_sites, sf_vcf):
        l_samples = list(m_samples.keys())
        with open(sf_vcf, "w") as fout_vcf:
            l_chrms = list(m_merged_sites.keys())
            l_chrms.sort()
            for chrm in l_chrms:  #
                l_pos = list(m_merged_sites[chrm].keys())
                l_pos.sort()  ###sort the candidate sites
                for pos in l_pos:
                    sinfo = "%s\t%d" % (chrm, pos)
                    m_hit_sample = {}
                    for rcd in m_merged_sites[chrm][pos]:
                        s_sample = rcd[0]
                        i_ins_len = int(rcd[1])
                        m_hit_sample[s_sample] = i_ins_len
                    for s_tmp_sample in l_samples:
                        if s_tmp_sample in m_hit_sample:
                            sinfo += "\t1"
                        else:
                            sinfo += "\t0"
                    sinfo += "\n"
                    fout_vcf.write(sinfo)
####
    ####
    def export_to_pca_input(self, sf_sample_info, m_merged_sites, sf_output):
        m_sample_info = self._load_in_sample_info(sf_sample_info)
        # print m_sample_info
        m_sample_sites = {}
        l_sites = []

        l_chrms = list(m_merged_sites.keys())
        l_chrms.sort()
        for chrm in l_chrms:  #
            l_pos = list(m_merged_sites[chrm].keys())
            l_pos.sort()  ###sort the candidate sites
            for pos in l_pos:
                l_rcd = m_merged_sites[chrm][pos]
                for (s_sample, ilen) in l_rcd:
                    if s_sample not in m_sample_sites:
                        m_sample_sites[s_sample] = {}
                    s_site = "%s_%d" % (chrm, pos)
                    l_sites.append(s_site)
                    m_sample_sites[s_sample][s_site] = 1

        with open(sf_output, "w") as fout_rslt:
            s_head = "sample"
            for s_site in l_sites:
                s_head += ("," + s_site)
            s_head += "\n"
            fout_rslt.write(s_head)
            for s_sample in m_sample_sites:
                if s_sample not in m_sample_info:
                    print(s_sample, "not found in dict")
                    continue
                sample_info_rcd = m_sample_info[s_sample]
                s_region = sample_info_rcd[2]
                sinfo = s_sample + "," + s_region
                for s_tmp_site in l_sites:
                    if s_tmp_site in m_sample_sites[s_sample]:
                        sinfo += (",1")
                    else:
                        sinfo += (",0")
                sinfo += "\n"
                fout_rslt.write(sinfo)

    # If breakpoints are close each other, then should be merged or grouped
    # For each cluster, use the peak one as the representative one
    def call_peak_candidate_sites_vcf(self, m_candidate_sites, peak_window):
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
                    max_cnt = 0
                    tmp_candidate_pos = 0
                    l_tmp_rcds = []
                    for tmp_pos in set_cluster:
                        tmp_cnt = len(m_candidate_sites[chrm][tmp_pos])  # num of supported samples
                        for tmp_rcd in m_candidate_sites[chrm][tmp_pos]:
                            l_tmp_rcds.append(tmp_rcd)
                        if max_cnt < tmp_cnt:
                            tmp_candidate_pos = tmp_pos  #
                            max_cnt = tmp_cnt
                    set_cluster.clear()##
                    if chrm not in m_peak_candidate_sites:
                        m_peak_candidate_sites[chrm] = {}
                    if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                        m_peak_candidate_sites[chrm][tmp_candidate_pos] = []
                    for tmp_rcd in l_tmp_rcds:
                        m_peak_candidate_sites[chrm][tmp_candidate_pos].append(tmp_rcd)
                pre_pos = pos
                set_cluster.add(pre_pos)

            # push out the last group
            max_cnt = 0
            tmp_candidate_pos = 0
            l_tmp_rcds = []
            for tmp_pos in set_cluster:
                tmp_cnt = len(m_candidate_sites[chrm][tmp_pos])  # num of supported samples
                for tmp_rcd in m_candidate_sites[chrm][tmp_pos]:
                    l_tmp_rcds.append(tmp_rcd)
                if max_cnt < tmp_cnt:
                    tmp_candidate_pos = tmp_pos  #
                    max_cnt = tmp_cnt
            set_cluster.clear()
            if chrm not in m_peak_candidate_sites:
                m_peak_candidate_sites[chrm] = {}
            if tmp_candidate_pos not in m_peak_candidate_sites[chrm]:
                m_peak_candidate_sites[chrm][tmp_candidate_pos] = []
            for tmp_rcd in l_tmp_rcds:
                m_peak_candidate_sites[chrm][tmp_candidate_pos].append(tmp_rcd)
        return m_peak_candidate_sites

####
    # this is for this SGD data
    def _load_in_sample_info(self, sf_info):
        m_info = {}
        with open(sf_info) as fin_info:
            for line in fin_info:
                fields = line.split(",")
                s_sample = fields[2]
                s_sex = fields[7]
                s_population = fields[8]
                s_region = fields[9]
                s_latitude = fields[12]
                s_longitude = fields[13]
                m_info[s_sample] = (s_sex, s_population, s_region, s_latitude, s_longitude)
        return m_info
####
    # given raw result list in format: sample-id, results-file-location (each line)
    # this is for exact breakpoints, no merg for nearby sites
    def _load_in_raw_rslts(self, sf_raw_list, min_ins_len=0):
        m_samples = {}
        m_merged_sites = {}
        with open(sf_raw_list) as fin_raw:
            for line in fin_raw:
                fields = line.split()
                s_sample = fields[0]
                sf_rslt = fields[1]
                m_samples[s_sample] = 1

                m_tmp = self._load_one_xtea_rslt(s_sample, sf_rslt, min_ins_len)
                self._combine_dict(m_tmp, m_merged_sites)
        return m_samples, m_merged_sites

    def _combine_dict(self, m_tmp, m_merged):
        for chrm in m_tmp:
            for pos in m_tmp[chrm]:
                for rcd in m_tmp[chrm][pos]:
                    if chrm not in m_merged:
                        m_merged[chrm] = {}
                    if pos not in m_merged[chrm]:
                        m_merged[chrm][pos] = []
                    m_merged[chrm][pos].append(rcd)

    # here only load the sample-id and ins-length for now
    def _load_one_xtea_rslt(self, s_sample, sf_rslt, min_ins_len=0):
        m_rslt = {}
        with open(sf_rslt) as fin_rslt:
            for line in fin_rslt:
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])
                ins_lenth = int(fields[-2])
                if ins_lenth < min_ins_len:
                    continue

                if chrm not in m_rslt:
                    m_rslt[chrm] = {}
                if pos not in m_rslt[chrm]:
                    m_rslt[chrm][pos] = []

                m_rslt[chrm][pos].append((s_sample, ins_lenth))
        return m_rslt
####

####
def parse_option():
    parser = OptionParser()
    parser.add_option("-S", "--sample",
                      action="store_true", dest="sample_merge", default=False,
                      help="Merge VCFs (different repeats) of each sample")
    parser.add_option("-P", "--population",
                      action="store_true", dest="population", default=False,
                      help="Merge VCFs (different repeats) of each sample")
    parser.add_option("-i", dest="sample_info",
                      help="sample id list file ", metavar="FILE")
    parser.add_option("-x", dest="xrslts",
                      help="xTEA result folder list", metavar="FILE")#
    parser.add_option("-p", "--path", dest="wfolder", type="string",
                      help="Working folder")
    parser.add_option("-n", "--cores", dest="cores", type="int",
                      help="number of cores")
    parser.add_option("-w", "--window", dest="window", type="int", default=50,
                      help="Maximum window size to merge two sites close to each other")
    parser.add_option("-r", "--ref", dest="ref", type="string",
                      help="reference genome")
    parser.add_option("-y", "--reptype", dest="rep_type", type="int",
                      help="Type of repeats working on: 1-L1, 2-Alu, 4-SVA, 8-HERV, 16-Mitochondrial")
    parser.add_option("-o", "--output", dest="output",
                      help="The output file", metavar="FILE")
    (options, args) = parser.parse_args()
    return (options, args)


####
if __name__ == '__main__':
    (options, args) = parse_option()
    sf_sample_info=options.sample_info
    sf_rslt_list=options.xrslts #this is the xTEA results list
    sf_wfolder = options.wfolder

    b_single=options.sample_merge
    b_population = options.population
    if b_single==True:#for one individual, merge all the vcf of different rep types
        i_rep_type=options.rep_type
        i_single_win=options.window
        vcf_merger=SampleVCFMerger()
        vcf_merger.merge_vcf_for_all_rep_types(sf_sample_info, sf_rslt_list, i_rep_type, i_single_win, sf_wfolder)
    elif b_population==True:
        i_peak_window = options.window
        sf_out = options.output
        pop_vcf_merger = PopVCFMerger()
        pop_vcf_merger.gnrt_population_vcf(sf_sample_info, sf_rslt_list, i_peak_window, sf_wfolder, sf_out)
####
####