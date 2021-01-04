##07/15/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

##This module is to call out the structural variations promoted by insertion
##For now, only call out the deletions:
'''
1. In the called out sites, call out the matched pairs
'''

####TE promoted deletion
class TEDeletion():
    # def __init__(self, working_folder):
    #     self.working_folder=working_folder

    # Each line in format:
    # #chrm    refined-pos   lclip-pos    rclip-pos TSD nalclip    narclip    naldisc
    # nardisc    nalpolyA   narpolyA  lcov  rcov  nlclip  nrclip  nldisc  nrdisc  nlpolyA nrpolyA
    # lclip-cns-start:end rclip_cns-start:end    ldisc-cns-start:end   rdisc-cns-start:end
    # Transduction-info  ntsd-clip  ntsd-disc ntsd-polyA
    # (3'-inversion-info) ldisc-same ldisc-diff rdisc-same rdisc-diff
    # (extra-info) "high-confident"/""
    def call_del_matched_brkpnts(self, sf_candidates):
        m_chrm_pos={}
        m_chrm_pos_info={}
        m_del={}
        with open(sf_candidates) as fin_candidates:
            for line in fin_candidates:
                fields=line.split()
                chrm=fields[0]
                refined_pos=int(fields[1])
                lclip_pos=int(fields[2])
                rclip_pos=int(fields[3])

                if lclip_pos!=-1 and rclip_pos!=-1:
                    continue

                lcov=float(fields[11])
                rcov=float(fields[12])

                lclip_cns_cluster=fields[19]
                rclip_cns_cluster=fields[20]
                ldisc_cns_cluster=fields[21]
                rdisc_cns_cluster=fields[22]

                if chrm not in m_chrm_pos:
                    m_chrm_pos[chrm]=[]
                if chrm not in m_chrm_pos_info:
                    m_chrm_pos_info[chrm]={}
                if lclip_pos==-1:
                    m_chrm_pos[chrm].append(refined_pos)
                    m_chrm_pos_info[chrm][refined_pos]=("rdel", lcov, rcov, rclip_cns_cluster, ldisc_cns_cluster)#right is deletion
                elif rclip_pos==-1:
                    m_chrm_pos[chrm].append(refined_pos)
                    m_chrm_pos_info[chrm][refined_pos] = ("ldel", lcov, rcov, lclip_cns_cluster, rdisc_cns_cluster) #left is deletion

        #print m_chrm_pos
        #print m_chrm_pos_info
####
        #each chrm sort according to coordinates
        for chrm in m_chrm_pos:
            l_pos=m_chrm_pos[chrm]
            l_pos.sort()

            bclose=True
            istart=-1
            for pos in l_pos:
                rcd=m_chrm_pos_info[chrm][pos]
                if chrm not in m_del:
                    m_del[chrm] = []
                if rcd[0] is "rdel": ##end of a candidate pair
                    if istart!=-1:#this is a pair
                        m_del[chrm].append((istart, pos))
                    else:#output as seperate pairs
                        m_del[chrm].append((-1, pos))
                    bclose=True

                else:
                    if bclose==False:#previous is a single start
                        m_del[chrm].append((istart, -1))
                    bclose=False
                    istart = pos
            if bclose == False:#check the last one
                m_del[chrm].append((istart, -1))
        return m_del

    def output_del(self, m_del, sf_del):
        with open(sf_del,"w") as fout_del:
            for chrm in m_del:
                for (istart, iend) in m_del[chrm]:
                    fout_del.write(chrm+"\t"+str(istart)+"\t"+str(iend)+"\n")

####

####Need to check the coverage:
#1. if too large, then split to two
#2. if coverage doesn't consistent, then split to two
#3. Also, need to check whether the two "breakpoints" are for the same events

####