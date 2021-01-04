##04/16/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

####
####
import os

class XJointCalling():
    def __init__(self, s_working_folder, n_jobs):
        self.swfolder = s_working_folder
        if self.swfolder[-1] != "/":
            self.swfolder += "/"
        self.n_jobs = n_jobs
####

####for mosaic calling, only keep those singleton ones
class MosaicJointCalling(XJointCalling):
    def __init__(self, s_working_folder, n_jobs):
        XJointCalling.__init__(self, s_working_folder, n_jobs)

    def call_mosaic_from_multi_samples(self, sf_rslt_list, islack, sf_out):
        l_rslts=[]
        with open(sf_rslt_list) as fin_rslt_list:
            #each line in format: sample_id selected_rslts.txt all_rslts.txt
            for line in fin_rslt_list:
                fields=line.split()
                sid=fields[0]
                sf_rslt=fields[1]
                sf_rslt_all=fields[2]
                if (os.path.isfile(sf_rslt) is False) or (os.path.isfile(sf_rslt_all) is False):
                    continue
                l_rslts.append((sid, sf_rslt, sf_rslt_all))

        ####
        m_candidates={}
        m_not_slcted={}
        for (sid, sf_rslt, sf_rslt_all) in l_rslts:
            self._get_diff_set(sf_rslt_all, sf_rslt, islack, m_not_slcted)
            with open(sf_rslt) as fin_rslt:
                for line in fin_rslt:
                    fields=line.split()
                    if len(fields)<2:
                        continue
                    chrm=fields[0]
                    pos=int(fields[1])

                    if chrm not in m_candidates:
                        m_candidates[chrm]={}
                        m_candidates[chrm][pos]=[]
                        m_candidates[chrm][pos].append((sid, line))
                    else:
                        #check whether within nearby region
                        b_hit, i_hit_pos=self._is_within_nearby_region(m_candidates, chrm, pos, islack)
                        if b_hit==True:
                            m_candidates[chrm][i_hit_pos].append((sid, line))
                        else:
                            m_candidates[chrm][pos] = []
                            m_candidates[chrm][pos].append((sid, line))

        sf_singleton = sf_out + ".singleton_for_screenshot"
        sf_non_singleton = sf_out + ".non_singleton_for_screenshot"
        with open(sf_singleton, "w") as fout_singleton, open(sf_non_singleton, "w") as fout_non:
            for chrm in m_candidates:
                for pos in m_candidates[chrm]:
                    if len(m_candidates[chrm][pos]) == 1:
                        # check the not selected (which contains germline cases of all the samples)
                        if (chrm in m_not_slcted) and (self._is_within_nearby_region(m_not_slcted, chrm, pos, islack)):
                            # print "test", chrm, pos
                            continue
                        s_tmp_line = m_candidates[chrm][pos][0][1].rstrip()
                        fout_singleton.write(m_candidates[chrm][pos][0][0] + "\t" + s_tmp_line + "\n")
                    else:
                        ####different sample have different feature or position, and this
                        s_tmp_line = m_candidates[chrm][pos][0][1].rstrip()
                        for rcd in m_candidates[chrm][pos]:
                            #s_tmp_line += ("\t" + rcd[0])
                            fout_non.write(rcd[0]+"\t"+s_tmp_line + "\n")

        sf_singleton2=sf_out+".singleton2"
        sf_non_singleton2 = sf_out + ".non_singleton2"
        with open(sf_singleton2, "w") as fout_singleton2, open(sf_non_singleton2,"w") as fout_non2:
            for chrm in m_candidates:
                for pos in m_candidates[chrm]:
                    if len(m_candidates[chrm][pos])==1:
                        #check the not selected (which contains germline cases of all the samples)
                        if (chrm in m_not_slcted) and (self._is_within_nearby_region(m_not_slcted, chrm, pos, islack)):
                            #print "test", chrm, pos
                            continue
                        s_tmp_line=m_candidates[chrm][pos][0][1].rstrip()
                        fout_singleton2.write(s_tmp_line + "\t" + m_candidates[chrm][pos][0][0]+"\n")
                    else:
                        ####different sample have different feature or position, and this
                        s_tmp_line = m_candidates[chrm][pos][0][1].rstrip()
                        for rcd in m_candidates[chrm][pos]:
                            s_tmp_line+=("\t"+rcd[0])
                        fout_non2.write(s_tmp_line+"\n")

####
####
    def _is_within_nearby_region(self, m_candidates, chrm, i_pos, i_slack):
        if chrm not in m_candidates:
            return False, -1
        for i in range(i_pos-i_slack, i_pos+i_slack):
            if i in m_candidates[chrm]:
                return True, i
        return False, -1
####
    def _get_diff_set(self, sf_all, sf_slct, islack, m_diff):
        m_all=self._load_rslts(sf_all)
        m_slct=self._load_rslts(sf_slct)
        for chrm in m_all:
            for pos in m_all[chrm]:
                if (chrm not in m_slct) or (self._is_within_nearby_region(m_slct, chrm, pos, islack)==False):
                    if chrm not in m_diff:
                        m_diff[chrm]={}
                    m_diff[chrm][pos]=1
        return m_diff
####
    def _load_rslts(self, sf_rslt):
        m_rslts={}
        with open(sf_rslt) as fin_rslt:
            for line in fin_rslt:
                fields=line.split()
                chrm=fields[0]
                pos=int(fields[1])
                if chrm not in m_rslts:
                    m_rslts[chrm]={}
                m_rslts[chrm][pos]=line
        return m_rslts
####
    def _export_rslt(self, m_not_slcted):
        for test_chrm in m_not_slcted:
            for test_pos in m_not_slcted[test_chrm]:
                print(test_chrm, test_pos, m_not_slcted[test_chrm][test_pos])

####