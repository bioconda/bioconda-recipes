import sys
import os
from optparse import OptionParser
import subprocess
EXTND = 200

_fp_suffix=".false_positive"
_tp_suffix=".true_positive"

class RsltCMP():
    def __init__(self, sf_input, sf_bcmk):
        self.sf_input = sf_input
        self.sf_bcmk = sf_bcmk
        self._fp_suffix=".false_positive"
        self._tp_suffix=".true_positive"

    #load the sites
    def load_sites(self, sf_input):
        m_sites = {}
        with open(sf_input) as fin_input:
            for line in fin_input:
                if len(line)>1 and line[0]=="#":#bypass head lines
                    continue
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])
                if chrm not in m_sites:
                    m_sites[chrm] = {}
                if pos not in m_sites[chrm]:
                    m_sites[chrm][pos] = []
                for svalue in fields[2:]:
                    m_sites[chrm][pos].append(svalue)
        return m_sites
####
####
    #process chrm name
    def process_chrm_name(self, chrm, b_with_chr):
        b_chrm_with_chr = False
        if len(chrm) > 3 and chrm[:3] == "chr":  ##Here remove the "chr"
            b_chrm_with_chr = True

        # print chrm, self.b_with_chr, b_chrm_with_chr ############################################################################
        if b_with_chr == True and b_chrm_with_chr == True:
            return chrm
        elif b_with_chr == True and b_chrm_with_chr == False:
            return "chr" + chrm
        elif b_with_chr == False and b_chrm_with_chr == True:
            return chrm[3:]
        else:
            return chrm

    #m_hit save the position of in m_dict1
    def cmp_dict(self, m_dict1, m_bcmk):
        n_overlap = 0
        m_unhit = {}
        m_hit={}
        m_hit_coordinate_bcmk={}

        # print m_dict1.keys(), "dict keys"
        # print m_bcmk.keys(), "bcmk keys"
        b_contain_chr = False
        if "chr1" in m_bcmk:
            b_contain_chr = True

        for chrm_1 in m_bcmk:
            chrm = self.process_chrm_name(chrm_1, b_contain_chr)
            if chrm not in m_dict1:
                #print "chromosome {0} is not included in database\n".format(chrm)
                if chrm not in m_unhit:
                    m_unhit[chrm]={}
                for tmp_pos in m_bcmk[chrm_1]:
                    m_unhit[chrm][tmp_pos]=1
                continue

            for pos in m_bcmk[chrm_1]:
                b_hit = False
                for i in range(-1 * EXTND, EXTND):
                    if (pos + i) in m_dict1[chrm]:#
                        n_overlap += 1
                        b_hit = True
                        if chrm not in m_hit:
                            m_hit[chrm]={}
                            m_hit_coordinate_bcmk[chrm]={}
                        m_hit[chrm][pos+i]=1
                        m_hit_coordinate_bcmk[chrm][pos]=1
                        break

                if b_hit == False:
                    if chrm not in m_unhit:
                        m_unhit[chrm] = {}
                    m_unhit[chrm][pos] = 1

        #Here also need to check those in m_dic1, but not in m_bcmk
        #and save them to m_unhit
        # for chrm_1 in m_dict1:
        #     chrm = self.process_chrm_name(chrm_1, b_contain_chr)
        #     if chrm not in m_hit_coordinate_bcmk:
        #         for pos in m_dict1[]

        return n_overlap, m_unhit, m_hit, m_hit_coordinate_bcmk

    #exclude the sites
    def exclude_sites(self, m_input, m_exclude, i_extnd):
        m_new_input={}
        for chrm in m_input:
            for pos in m_input[chrm]:
                if chrm not in m_exclude:
                    if chrm not in m_new_input:
                        m_new_input[chrm]={}
                    m_new_input[chrm][pos]=m_input[chrm][pos]
                else:
                    b_hit=False
                    for tmp_pos in range(pos-i_extnd, pos+i_extnd):
                        if tmp_pos in m_exclude[chrm]:
                            b_hit=True
                            break
                    if b_hit==True:
                        continue
                    if chrm not in m_new_input:
                        m_new_input[chrm]={}
                    m_new_input[chrm][pos]=m_input[chrm][pos]
        return m_new_input

####
    #cmp results
    def cmp_rslts(self, i_extd, sf_unhit, s_sample, m_exclude=None):
        global EXTND
        EXTND=i_extd
        m_bcmk1 = self.load_sites(self.sf_bcmk)
        m_input1 = self.load_sites(self.sf_input)

        #here remove those sites in m_exclude
        m_bcmk=m_bcmk1
        m_input=m_input1
        if m_exclude is not None:
            m_bcmk =self.exclude_sites(m_bcmk1, m_exclude, i_extd)
            m_input = self.exclude_sites(m_input1, m_exclude, i_extd)

        n_bcmk, m_unhit1, m_hit1, m_hit_bcmk_pos1 = self.cmp_dict(m_bcmk, m_bcmk)
        n_hit, m_unhit2, m_hit2, m_hit_bcmk_pos2 = self.cmp_dict(m_input, m_bcmk)
        #n_hit_fp, m_unhit_fp, m_hit3 = self.cmp_dict(m_bcmk, m_input)

        print(("{0}/{1} hits/all".format(n_hit, n_bcmk))) 
        with open(sf_unhit, "w") as fout_unhit:
            for chrm in m_unhit2:
                for pos in m_unhit2[chrm]:
                    fout_unhit.write(chrm + "\t" + str(pos) + "\n")

        with open(sf_unhit+self._tp_suffix, "w") as fout_tp:
            for chrm in m_hit2:
                for pos in m_hit2[chrm]:
                    sinfo = "\t".join(m_input[chrm][pos])
                    fout_tp.write(chrm + "\t" + str(pos) + "\t" + sinfo + "\n")
        with open(sf_unhit+s_sample+"."+self._tp_suffix, "w") as fout_tp2:
            for chrm in m_hit_bcmk_pos2:
                for pos in m_hit_bcmk_pos2[chrm]:
                    sinfo = "\t".join(m_bcmk[chrm][pos])
                    fout_tp2.write(chrm + "\t" + str(pos) + "\t" + sinfo + "\n")

        # with open(sf_unhit+".false_positive", "w") as fout_fp:
        #     for chrm in m_unhit_fp:
        #         for pos in m_unhit_fp[chrm]:
        #             sinfo="\t".join(m_input[chrm][pos])
        #             fout_fp.write(chrm + "\t" + str(pos) + "\t" + sinfo+ "\n")
        return n_hit

    #cmp results
    def cmp_rslts2(self, i_extd, sf_unhit, m_exclude=None):
        global EXTND
        EXTND=i_extd
        m_bcmk1 = self.load_sites(self.sf_bcmk)
        m_input1 = self.load_sites(self.sf_input)
        # here remove those sites in m_exclude
        m_bcmk = m_bcmk1
        m_input = m_input1
        if m_exclude is not None:
            m_bcmk = self.exclude_sites(m_bcmk1, m_exclude, i_extd)
            m_input = self.exclude_sites(m_input1, m_exclude, i_extd)

        n_bcmk, m_unhit1, m_hit1, m_hit_bcmk_pos1 = self.cmp_dict(m_bcmk, m_bcmk)
        n_hit, m_unhit2, m_hit2, m_hit_bcmk_pos2 = self.cmp_dict(m_input, m_bcmk)
        n_hit_fp, m_unhit_fp, m_hit3, m_hit_bcmk_pos3 = self.cmp_dict(m_bcmk, m_input)

        print(("{0}/{1} hits/all".format(n_hit, n_bcmk))) 
        with open(sf_unhit, "w") as fout_unhit:
            for chrm in m_unhit2:
                for pos in m_unhit2[chrm]:
                    fout_unhit.write(chrm + "\t" + str(pos) + "\n")

        with open(sf_unhit+self._tp_suffix, "w") as fout_tp:
            for chrm in m_hit2:
                for pos in m_hit2[chrm]:
                    sinfo = "\t".join(m_input[chrm][pos])
                    fout_tp.write(chrm + "\t" + str(pos) + "\t" + sinfo + "\n")

        with open(sf_unhit+self._fp_suffix, "w") as fout_fp:
            for chrm in m_unhit_fp:
                for pos in m_unhit_fp[chrm]:
                    if (chrm not in m_input) or (pos not in m_input[chrm]):
                        continue
                    sinfo="\t".join(m_input[chrm][pos])
                    fout_fp.write(chrm + "\t" + str(pos) + "\t" + sinfo+ "\n")
        return n_hit

    #####get the insertions fall in the focal region
    def gnrt_ins_within_focal_region(self, sf_var, sf_hc_bed, sf_new_var):
        if sf_hc_bed is None:
            return
        cmd="bedtools intersect  -a {0} -b {1} > {2}".format(sf_hc_bed, sf_var, sf_new_var)
        print(cmd) 
        subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE).communicate()

    def set_input(self, sf_new):
        self.sf_input=sf_new

    ####
    def cnt_number_of_ins(self, sf_input):
        n_cnt=0
        with open(sf_input) as fin:
            for line in fin:
                n_cnt+=1
        return n_cnt

    ####load in the result list
    def load_in_rslt_list(self, sf_list):
        m_rslts={}
        with open(sf_list) as fin_list:
            for line in fin_list:
                fields=line.split()
                sf_rslt=fields[0]
                s_type=fields[1]
                s_sample=fields[2]

                if s_sample not in m_rslts:
                    m_rslts[s_sample]={}
                if s_type not in m_rslts[s_sample]:
                    m_rslts[s_sample][s_type]=sf_rslt
        return m_rslts
####
####
####
def check_one_sample_agnst_bcmk(sf_input, sf_bcmk, m_exclude_sites, sf_hc_bed, i_extd, s_type, sf_unhit, s_sample):
    sf_hc_input = sf_input + ".focal_region.txt"
    if sf_hc_bed is None:
        sf_hc_input = sf_input
    rslt_cmp = RsltCMP(sf_hc_input, sf_bcmk)
    rslt_cmp.gnrt_ins_within_focal_region(sf_input, sf_hc_bed, sf_hc_input)

    #here filter out those fall in "exlucded list"

    n_ori_in = rslt_cmp.cnt_number_of_ins(sf_input)
    n_hc_in = rslt_cmp.cnt_number_of_ins(sf_hc_input)
    print(("##########{0}############".format(s_type)))
    print(("Original call set size: {0}\n".format(n_ori_in))) 
    print(("Fall in high confident regions: {0}\n".format(n_hc_in))) 
    print("#########################") 
    n_hit=rslt_cmp.cmp_rslts(i_extd, sf_unhit, s_sample, m_exclude_sites)
    return n_ori_in, n_hc_in, n_hit

####
####this one output the false positives to a separate file
def check_one_sample_agnst_bcmk2(sf_input, sf_bcmk, sf_exclude, sf_hc_bed, i_extd, s_type, sf_unhit):
    sf_hc_input = sf_input + ".focal_region.txt"
    if sf_hc_bed is None:
        sf_hc_input = sf_input

    rslt_cmp = RsltCMP(sf_hc_input, sf_bcmk)
    rslt_cmp.gnrt_ins_within_focal_region(sf_input, sf_hc_bed, sf_hc_input)
    m_exclude_sites = {}
    if sf_exclude is not None and os.path.isfile(sf_exclude) == True:
        m_exclude_sites = rslt_cmp.load_sites(sf_exclude)

    n_ori_in = rslt_cmp.cnt_number_of_ins(sf_input)
    n_hc_in = rslt_cmp.cnt_number_of_ins(sf_hc_input)
    print(("##########{0}############".format(s_type))) 
    print(("Original call set size: {0}\n".format(n_ori_in))) 
    print(("Fall in high confident regions: {0}\n".format(n_hc_in))) 
    print("#########################") 

    n_hit=rslt_cmp.cmp_rslts2(i_extd, sf_unhit, m_exclude_sites)#
    return n_ori_in, n_hc_in, n_hit

####
def gnrt_bed_from_input(sf_input, sf_new):
    with open(sf_input) as fin, open(sf_new,"w") as fout_new:
        for line in fin:
            if len(line)>0 and line[0]=="#":#skip the header
                continue
            fields=line.split()
            ins_chrm=fields[0]
            ins_pos=int(fields[1])
            s_line="{0}\t{1}\t{2}\n".format(ins_chrm, ins_pos, ins_pos+1)
            fout_new.write(s_line)

####sf_list in format: sf_rslt s_rep_type sample
def cmp_for_list_of_rslts(sf_list, sf_bcmk, sf_exclude, sf_hc_bed, i_extd, sf_unhit):
    m_cnt={}
    l_sample_id=[]
    m_tmp={}
    rslt_cmp = RsltCMP(sf_list, sf_bcmk)
    m_rslt_list = rslt_cmp.load_in_rslt_list(sf_list)
    print(m_rslt_list) 
    n_bcmk=rslt_cmp.cnt_number_of_ins(sf_bcmk)
    m_tp_fp_fn={}
    m_exclude_sites = {}
    if sf_exclude is not None and os.path.isfile(sf_exclude)==True:
        m_exclude_sites=rslt_cmp.load_sites(sf_exclude)

    for s_sample in m_rslt_list:
        for s_rep_type in m_rslt_list[s_sample]:
            if s_sample not in m_tmp:
                l_sample_id.append(s_sample)
                m_tmp[s_sample]=1
            sf_input = m_rslt_list[s_sample][s_rep_type]
            sf_new_input=sf_input+".tmp"
            gnrt_bed_from_input(sf_input, sf_new_input)
            n_ori_in, n_hc_in, n_hit=check_one_sample_agnst_bcmk(sf_new_input, sf_bcmk, m_exclude_sites, sf_hc_bed,
                                                                 i_extd, s_rep_type, sf_unhit, s_sample)
            if s_sample not in m_cnt:
                m_cnt[s_sample]={}
            m_cnt[s_sample][s_rep_type]=(n_ori_in, n_hc_in, n_hit)

            ####used for calc F1 score
            n_sample_cnt=rslt_cmp.cnt_number_of_ins(sf_input)
            n_tp=n_hit
            n_fp=n_sample_cnt-n_tp
            n_fn=n_bcmk-n_tp
            if s_sample not in m_tp_fp_fn:
                m_tp_fp_fn[s_sample]={}
            m_tp_fp_fn[s_sample][s_rep_type]=(n_tp, n_fp, n_fn)
    return m_cnt, l_sample_id, m_tp_fp_fn
####
####
def load_in_sample_id(sf_ids):
    l_ids = []
    with open(sf_ids) as fin_samples:
        for line in fin_samples:
            s_id = line.rstrip()
            l_fields = s_id.split("_")
            l_ids.append(l_fields[0])
    return l_ids

####
def export_cnt_to_csv_for_point_chart(l_sample_info, m_cnt, sf_cnt):
    sf_cnt1=sf_cnt+"_ori.csv"
    sf_cnt2 = sf_cnt + "_fall_in_hc.csv"
    sf_cnt3 = sf_cnt + "_hit.csv"
    with open(sf_cnt1, "w") as fout_csv1, open(sf_cnt2, "w") as fout_csv2, open(sf_cnt3, "w") as fout_csv3:
        s_head="Repeat\tMethod\tTP\tFP\n"
        fout_csv1.write(s_head)
        fout_csv2.write(s_head)
        fout_csv3.write(s_head)
        for s_sample in l_sample_info:
            for s_type in m_cnt[s_sample]:
                cnt1=m_cnt[s_sample][s_type][0]
                fout_csv1.write(s_type+"\t"+s_sample+"\t"+str(cnt1)+"\n")
                cnt2 = m_cnt[s_sample][s_type][1]
                fout_csv2.write(s_type + "\t" + s_sample + "\t" + str(cnt2) + "\n")
                cnt3 = m_cnt[s_sample][s_type][2]
                fout_csv3.write(s_type + "\t" + s_sample + "\t" + str(cnt3) + "\n")

#
def calc_export_F1_score_sensitivity_FDR_csv(m_tp_fp_fn, sf_out):
    with open(sf_out, "w") as fout_f1:
        s_head="Method\tCoverage\tF1\tSensitivity\tFDR\tTP\tFP\tFN\n"
        fout_f1.write(s_head)
        for s_sample in m_tp_fp_fn:#for each sample
            for s_type in m_tp_fp_fn[s_sample]:#for each repeat type
                tp=m_tp_fp_fn[s_sample][s_type][0]
                fp=m_tp_fp_fn[s_sample][s_type][1]
                fn=m_tp_fp_fn[s_sample][s_type][2]
                f1_score=(2.0*float(tp))/(2.0*float(tp)+float(fp)+float(fn))
                tmp_fields=s_sample.split("_")
                s_method=tmp_fields[0]
                s_cov=tmp_fields[1]

                f_sensitivity=float(tp)/(float(tp)+float(fn))
                f_fdr=float(fp)/(float(fp)+float(tp))
                fout_f1.write(s_method + "\t" + s_cov + "\t" + str(f1_score) + "\t" +
                              str(f_sensitivity) + "\t" + str(f_fdr) + "\t" + str(tp) +
                              "\t" + str(fp) + "\t" + str(fn) + "\n")

def calc_export_F1_score_sensitivity_FDR_csv2(m_tp_fp_fn, sf_out):
    sf_out2=sf_out+".2"
    with open(sf_out, "w") as fout_f1, open(sf_out2, "w") as fout_f2:
        s_head = "Method\tCoverage\tF1\tSensitivity\tFDR\tCategory\tNumber of TE-Insertion\n"
        fout_f1.write(s_head)
        s_head2 = "Platform\tRatio\tCategory\n"
        fout_f2.write(s_head2)
        for s_sample in m_tp_fp_fn:  # for each sample
            for s_type in m_tp_fp_fn[s_sample]:  # for each repeat type
                tp = m_tp_fp_fn[s_sample][s_type][0]
                fp = m_tp_fp_fn[s_sample][s_type][1]
                fn = m_tp_fp_fn[s_sample][s_type][2]
                f1_score = (2.0 * float(tp)) / (2.0 * float(tp) + float(fp) + float(fn))
                tmp_fields = s_sample.split("_")
                s_method = tmp_fields[0]
                s_cov = tmp_fields[1]

                f_sensitivity = float(tp) / (float(tp) + float(fn))
                f_fdr = float(fp) / (float(fp) + float(tp))
                fout_f1.write(s_method + "\t" + s_cov + "\t" + str(f1_score) + "\t" +
                              str(f_sensitivity) + "\t" + str(f_fdr) + "\tTP\t" + str(tp)  +  "\n")
                fout_f1.write(s_method + "\t" + s_cov + "\t" + str(f1_score) + "\t" +
                              str(f_sensitivity) + "\t" + str(f_fdr) + "\tFP\t" + str(fp)  + "\n")


                fout_f2.write(s_method+"\t"+str(f_sensitivity)+"\tRecall\n")
                fout_f2.write(s_method + "\t" + str(1-f_fdr) + "\t1-FDR\n")

                # fout_f2.write(s_method + "\t" + s_cov + "\t" + str(f1_score) + "\t" +
                #               str(f_sensitivity) + "\t" + str(f_fdr) + "\tFN" + str(tp) +
                #               "\t" + str(fp) + "\t" + str(fn) + "\n")
####
####
def get_joint_info(sf_ori, sf_slct_sites, sf_joint):
    m_slct={}
    with open(sf_slct_sites) as fin_slct:
        for line in fin_slct:
            fields=line.split()
            chrm=fields[0]
            pos=fields[1]
            if chrm not in m_slct:
                m_slct[chrm]={}
            m_slct[chrm][pos]=1
    with open(sf_ori) as fin_ori, open(sf_joint,"w") as fout:
        for line in fin_ori:
            fields=line.split()
            chrm=fields[0]
            pos=fields[1]
            if (chrm in m_slct) and (pos in m_slct[chrm]):
                fout.write(line)

def get_joint_info2(sf_ori, sf_slct_sites, i_slack, sf_joint):
    m_slct = {}
    with open(sf_slct_sites) as fin_slct:
        for line in fin_slct:
            fields = line.split()
            chrm = fields[0]
            pos = int(fields[1])
            if chrm not in m_slct:
                m_slct[chrm] = {}
            m_slct[chrm][pos] = 1
    with open(sf_ori) as fin_ori, open(sf_joint, "w") as fout:
        for line in fin_ori:
            fields = line.split()
            chrm = fields[0]
            pos = int(fields[1])
            for tmp_pos in range(pos-i_slack, pos+i_slack):
                if (chrm in m_slct) and (tmp_pos in m_slct[chrm]):
                    fout.write(line)
                    break

####
####
def parse_option():
    parser = OptionParser()
    parser.add_option("-L",
                      action="store_true", dest="bgroup", default=False,
                      help="Input is a list of results")
    parser.add_option("-i", "--input", dest="input",
                      help="Input file", metavar="FILE")
    parser.add_option("--list", dest="list",
                      help="List of results", metavar="FILE")
    parser.add_option("--bcmk", dest="bcmk",
                      help="Benchmark file", metavar="FILE")
    parser.add_option("--bed", dest="focal_region", default=None,
                      help="Compare within the given region", metavar="FILE")
    parser.add_option("--extnd", dest="extnd", type="int", default=200,
                      help="Slack value")
    parser.add_option("--exclude", dest="exclude", default=None,
                      help="Sites need to be excluded", metavar="FILE")
    parser.add_option("-o", "--output", dest="output",
                      help="The output file", metavar="FILE")
    (options, args) = parser.parse_args()
    return (options, args)


####
if __name__ == '__main__':
    (options, args) = parse_option()#
    b_group=options.bgroup
    sf_list = options.list ####list of results of different repeat types in format: sf_rslt rep_type sample(each line)

    sf_input = options.input
    sf_bcmk = options.bcmk
    sf_hc_bed = options.focal_region #the focal region
    i_extd=options.extnd
    sf_unhit = options.output
    sf_exclude=options.exclude #pay attention that not check whether contain "chr" in chrm !!!!!!!!

    if b_group is True:
        m_cnt, l_sample_info, m_tp_fp_fn=cmp_for_list_of_rslts(sf_list, sf_bcmk, sf_exclude, sf_hc_bed, i_extd, sf_unhit)
        #print m_cnt
        sf_csv=sf_unhit
        #l_sample_info=load_in_sample_id(sf_ids)
        export_cnt_to_csv_for_point_chart(l_sample_info, m_cnt, sf_csv)
        #calc and export F1 score
        sf_f1_csv=sf_csv+".f1_score"
        calc_export_F1_score_sensitivity_FDR_csv(m_tp_fp_fn, sf_f1_csv)
        sf_f1_csv2=sf_csv+".tp_fp_barchart"
        calc_export_F1_score_sensitivity_FDR_csv2(m_tp_fp_fn, sf_f1_csv2)
    else:#single sample
        s_type="None"
        sf_new_input = sf_input + ".tmp"
        gnrt_bed_from_input(sf_input, sf_new_input)
        check_one_sample_agnst_bcmk2(sf_new_input, sf_bcmk, sf_exclude, sf_hc_bed, i_extd, s_type, sf_unhit)

        #generate the false positive list (with info)
        sf_slct_sites=sf_unhit+_fp_suffix
        sf_joint=sf_slct_sites+"._with_info"
        get_joint_info(sf_input, sf_slct_sites, sf_joint)

        #generate the true positive list (with info), from the benchmark
        sf_tp_sites=sf_unhit+_tp_suffix
        sf_joint_tp=sf_tp_sites+"._with_info"
        i_slack=i_extd
        get_joint_info2(sf_bcmk, sf_tp_sites, i_slack, sf_joint_tp)

####