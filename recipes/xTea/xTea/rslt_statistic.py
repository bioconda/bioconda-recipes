import os
import sys

class IntersectionCaller():
    def __init__(self, sf_sample_list, s_working_folder):
        self.sf_sample_list=sf_sample_list #this save the list of rslts of different samples
        self.s_working_folder=s_working_folder
        if self.s_working_folder[-1]!="/":
            self.s_working_folder+="/"
    #
    def load_one_sample(self, sf_rslt, i_sample_id):
        m_rslt={}
        with open(sf_rslt) as fin_rslt:
            for line in fin_rslt:
                fields=line.split()
                chrm=fields[0]
                pos=int(fields[1])
                if chrm not in m_rslt:
                    m_rslt[chrm]={}
                s_label="{0}~{1}~{2}".format(i_sample_id, chrm, pos)#the new label
                m_rslt[chrm][pos]=s_label

        m_rslt1 = {}#here we remove all the "chr" for each chrm if it exists
        for chrm_tmp in m_rslt:
            chrm=chrm_tmp
            if len(chrm_tmp)>3 and chrm_tmp[:3]=="chr":
                chrm=chrm_tmp[3:]
            if chrm not in m_rslt1:
                m_rslt1[chrm]={}
            for pos in m_rslt[chrm_tmp]:
                m_rslt1[chrm][pos]=m_rslt[chrm_tmp][pos]
        return m_rslt1

    #return the results: [{chrm:{pos{}}}]
    def load_all_rslt(self):
        l_rslts=[]
        i_sample=1
        with open(self.sf_sample_list) as fin_sample_list:
            for line in fin_sample_list:
                fields=line.split()
                sf_sample=fields[0]
                if os.path.isfile(sf_sample)==False:
                    continue
                m_rslt=self.load_one_sample(sf_sample, i_sample)
                l_rslts.append(m_rslt)
                i_sample+=1
        return l_rslts

    #B will copy the label of A, if value are "equal"
    def intersect_A_B(self, m_A, m_B, i_slack):
        for chrm in m_B:
            if chrm not in m_A:
                continue
            for pos in m_B[chrm]:
                for i in range(-1*i_slack, i_slack):
                    if (pos+i) in m_A[chrm]:
                        m_B[chrm][pos]=m_A[chrm][pos+i]
                        break

    #check intersection
    def check_intersection(self, i_slack, n_sample_cutoff, sf_intersect_csv, sf_out_picked_sites):
        l_rslts=self.load_all_rslt()
        n_sample=len(l_rslts)
        if n_sample<2:#require at least two set of results
            return None
        for i in range(n_sample):
            for j in range(0,i):
                if j==i:
                    continue
                self.intersect_A_B(l_rslts[j], l_rslts[i], i_slack)

        l_labled_list=[]
        for m_tmp in l_rslts:
            l_tmp=[]
            for chrm in m_tmp:
                for pos in m_tmp[chrm]:
                    l_tmp.append(m_tmp[chrm][pos])
            l_labled_list.append(l_tmp)

        #output the list for each sample
        with open(self.sf_sample_list) as fin_samples:
            i_cnt = 0
            for line in fin_samples:
                fields=line.split()
                s_labled_sample=self.s_working_folder+os.path.basename(fields[0])+".new_labled.list"
                with open(s_labled_sample, "w") as fout_new_label:
                    m_rlst=l_rslts[i_cnt]
                    for chrm in m_rlst:
                        for pos in m_rlst[chrm]:
                            fout_new_label.write(m_rlst[chrm][pos]+"\n")
                    i_cnt+=1

        m_candidates_sites = self.get_intersection_by_cutoff(l_labled_list, n_sample_cutoff)
        with open(sf_out_picked_sites, "w") as fout_picked:
            for s_sites in m_candidates_sites:
                site_fields=s_sites.split("~")
                fout_picked.write("\t".join(site_fields[1:]))

        # with open(sf_out_csv, "w") as fout_csv:

    #load in the sample info
    def load_sample_info(self):
        l_sample_list=[]
        with open(self.sf_sample_list) as fin_sample:
            for line in fin_sample:
                fields=line.split()
                l_sample_list.append(fields[1])
        return l_sample_list

    # export the upset csv for visualization
    def export_upset_csv(self, l_rslts, sf_out_csv):
        with open(sf_out_csv, "w") as fout_csv:
            l_sample_info = self.load_sample_info()
            s_head = "Data"
            for data_source in l_sample_info:
                s_head += ("," + data_source)
            s_head += "\n"
            fout_csv.write(s_head)

            m_sites = {}
            n_sample = len(l_sample_info)

            for i in range(n_sample):
                l_tmp = l_rslts[i]
                for s_info in l_tmp:
                    if s_info not in m_sites:
                        m_sites[s_info] = {}
                    m_sites[s_info][i] = 1
            # print len(m_sites)
            ####
            for s_info in m_sites:
                s_row = s_info
                for i in range(n_sample):
                    if i in m_sites[s_info]:
                        s_row += ",1"
                    else:
                        s_row += ",0"
                fout_csv.write(s_row + "\n")

####
    def get_intersection_by_cutoff(self, l_rslts, n_cutoff):
        m_sites={}
        for l_tmp in l_rslts:
            for s_info in l_tmp:
                if s_info not in m_sites:
                    m_sites[s_info]=0
                m_sites[s_info]+=1
        m_candidates={}
        for s_info in m_sites:
            if m_sites[s_info]>=n_cutoff:
                m_candidates[s_info]=m_sites[s_info]
        return m_candidates #in format: {site:shared-by-how-many-samples}


if __name__ == '__main__':
    sf_rlst_list=sys.argv[1]
    i_slack=int(sys.argv[2])
    s_working_folder=sys.argv[3]
    isec_caller=IntersectionCaller(sf_rlst_list, s_working_folder)

#1. run the assembly
#2. include:14:37769600
#3. cases:
