##07/11/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu chong.simon.chu@gmail.com

#This module is added for calling transduction (orphan and non-orphan) events. Also will be extended for SV calling.

class DiscCluster():
    # def __init__(self):
    #     self._min_ratio=0.6

    #given the mate reads mapping positions (from one side), check whether they form clusters
    #Input: m_pos in format: {chrm:[pos]}; i_is: insert size
    #Output: True/False, cluster_chrm, cluster_pos
    def form_one_side_cluster(self, m_pos, i_is, f_ratio):
        m_cluster = {}
        max_cnt=0
        max_pos=-1
        max_chrm=""
        all_cnt=0
        if len(m_pos)==0:
            return False, None, None
        for chrm in m_pos:
            l_pos = m_pos[chrm]
            l_pos.sort()  ###sort the candidate sites
            pre_pos = -1
            set_cluster = []
            for pos in l_pos:
                if pre_pos == -1:
                    pre_pos = pos
                    set_cluster.append(pre_pos)
                    continue

                if pos - pre_pos > i_is:  # find the peak in the cluster
                    # find the representative position of this cluster
                    # also calc the standard derivation of the left and right cluster
                    set_size=len(set_cluster)
                    mid_pos=set_cluster[set_size/2]
                    if chrm not in m_cluster:
                        m_cluster[chrm]={}
                    m_cluster[chrm][mid_pos]=(set_cluster[0], set_cluster[-1], set_size)
                    if max_cnt<set_size:
                        max_cnt=set_size
                        max_pos=mid_pos
                        max_chrm=chrm
                    all_cnt += set_size
                    del set_cluster[:]
                pre_pos = pos
                set_cluster.append(pre_pos)
                ####
            # push out the last group
            set_size = len(set_cluster)
            mid_pos = set_cluster[set_size / 2]
            if chrm not in m_cluster:
                m_cluster[chrm] = {}
            m_cluster[chrm][mid_pos] = (set_cluster[0], set_cluster[-1], set_size)
            if max_cnt < set_size:
                max_cnt = set_size
                max_pos = mid_pos
                max_chrm = chrm
            all_cnt += set_size
        #### calc the ratio
        if float(max_cnt)/float(all_cnt) > f_ratio:
            return True, max_chrm, max_pos
        return False, None, None
####