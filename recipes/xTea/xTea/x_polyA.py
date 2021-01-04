##11/01/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

####canonical signals: AATAAA / TTTATT, ATTAAA/TTTAAT
####variations: AGTAAA, TATAAA, CATAAA, GATAAA, AATATA, AATACA, AATAGA, AAAAAG, ACTAAA, AAGAAA, AATGAA, TTTAAA, AAAACA,
# GGGGCT
import re

class PolyA():
    ####
    def is_poly_A_T(self, seq):  ###for a temp version here
        cnt_A = 0
        cnt_T = 0
        for ch in seq:
            if ch == 'A' or ch == 'a':
                cnt_A += 1
            elif ch == 'T' or ch == 't':
                cnt_T += 1
        cnt_cutoff = (len(seq) * 0.75)
        if (cnt_A > cnt_cutoff) or (cnt_T > cnt_cutoff):
            return True
        return False

    def contain_poly_A_T(self, seq, n_min_cnt):
        max_A = 0
        max_T = 0
        cum_A = 0
        cum_T = 0
        for ch in seq:
            if ch == 'A' or ch == 'a':
                cum_A += 1
            else:
                if cum_A > max_A:
                    max_A = cum_A
                cum_A = 0

            if ch == 'T' or ch == 't':
                cum_T += 1
            else:
                if cum_T > max_T:
                    max_T = cum_T
                cum_T = 0
        if cum_A > max_A:
            max_A = cum_A
        if cum_T > max_T:
            max_T = cum_T

        if max_A >= n_min_cnt or max_T >= n_min_cnt:
            return True
        else:
            return False

    def is_consecutive_polyA_T(self, seq):
        if ("AAAAA" in seq) or ("TTTTT" in seq) or ("AATAA" in seq) or ("TTATT" in seq):
            return True
        else:
            return False
            ####
    def is_consecutive_polyA_T2(self, seq):
        if ("AAAAAA" in seq) or ("TTTTTT" in seq) or ("AAATAA" in seq) or ("TTTATT" in seq):
            return True
        else:
            return False

    def is_consecutive_polyA(self, seq):
        if ("AAAAA" in seq) or ("AATAA" in seq):
            return True
        else:
            return False

    def is_consecutive_polyA_T_with_ori(self, seq):
        b_polyA=True
        if ("AAAAA" in seq) or  ("AATAA" in seq) :#polyA
            return True, b_polyA
        elif ("TTTTT" in seq) or ("TTATT" in seq):#polyT
            b_polyA=False
            return True, b_polyA
        else:
            return False, False

    #this is not used for now, but should be used to replace "is_consecutive_polyA_T"
    #Right clipped reads should be polyT only, while left clipped reads should be polyA only.
    def is_consecutive_polyA_T_with_oritation(self, seq, b_left):
        if b_left==True:#left clip
            if ("AAAAA" in seq) or ("AATAA" in seq):
                return True
        else:
            if ("TTTTT" in seq) or ("TTATT" in seq):
                return True
        # if ("AAAAA" in seq) or ("TTTTT" in seq) or ("AATAA" in seq) or ("TTATT" in seq):
        #     return True
        # else:
        return False

    #check whether contain enough A or T
    def contain_enough_A_T(self, seq, n_min_A_T):
        n_A=0
        n_T=0
        for ch in seq:
            if ch == 'A' or ch == 'a':
                n_A+=1
            if ch == 'T' or ch == 't':
                n_T+=1

        if n_A>=n_min_A_T or n_T>=n_min_A_T:
            return True
        return False
####
    ####
    def contain_polyA_T(self, s_seq, b_rc):
        b_contain=False
        if b_rc==False:
            if ("AATAAA" in s_seq) or ("AAAAAA" in s_seq) or ("ATTAAA" in s_seq):
                b_contain=True
        else:
            if ("TTTATT" in s_seq) or ("TTTTTT" in s_seq) or ("TTTAAT" in s_seq):
                b_contain=True
        return b_contain
####
    #given a sequence, find out all the potential polyA signal within the sequence
    def search_multi_polyA_locations(self, s_seq, b_rc):
        l_pos1=[]
        if b_rc==True:
            l_pos1=[m.start() for m in re.finditer('TTTATT', s_seq)]
        else:
            l_pos1 = [m.start() for m in re.finditer('AATAAA', s_seq)]

        if b_rc==True:
            l_pos1.extend([m.start() for m in re.finditer('TTTTTT', s_seq)])
        else:
            l_pos1.extend([m.start() for m in re.finditer('AAAAAA', s_seq)])

        if b_rc==True:
            l_pos1.extend([m.start() for m in re.finditer('TTTAAT', s_seq)])
        else:
            l_pos1.extend([m.start() for m in re.finditer('ATTAAA', s_seq)])
        return l_pos1

    ####
    def is_dominant_polyA(self, seq, f_ratio):
        n_A=0
        n_T=0
        for ch in seq:
            if ch=="A" or ch =="a":
                n_A+=1
            if ch == "T" or ch == "t":
                n_T+=1
        n_len=len(seq)
        if n_len==0:
            return False
        if float(n_A)/float(n_len) > f_ratio:
            return True
        if float(n_T)/float(n_len) > f_ratio:
            return True
        return False

    def is_dominant_A(self, seq, f_ratio):
        n_A=0
        for ch in seq:
            if ch=="A" or ch =="a":
                n_A+=1
        n_len=len(seq)
        if n_len==0:
            return False
        if float(n_A)/float(n_len) > f_ratio:
            return True
        return False

    def get_pre_defined_polyA_in_rmsk(self):#
        #or "AAA" within the Simple_repeat
        m_polyA={}
        m_polyA['(AAAAAC)n']=1
        m_polyA['(AAAAC)n'] = 1
        m_polyA['(AAAATAA)n'] = 1
        m_polyA['(AAAAT)n'] = 1
        m_polyA['(AAATA)n'] = 1
        m_polyA['(AAAT)n'] = 1
        m_polyA['(AACAAA)n'] = 1
        m_polyA['(AAC)n'] = 1
        m_polyA['(AATAAAA)n'] = 1
        m_polyA['(AATAAA)n'] = 1
        m_polyA['(AATAA)n'] = 1
        m_polyA['(AATA)n'] = 1
        m_polyA['(AAT)n'] = 1
        m_polyA['(ACA)n'] = 1
        m_polyA['(A)n'] = 1
        m_new_polyA2={}
        for s_tmp in m_polyA:
            m_new_polyA2[s_tmp]=1
            m_rotate=self._rotate_seq(s_tmp[1:-2])
            for s_tmp2 in m_rotate:
                m_new_polyA2["("+s_tmp2+")n"] = 1
        return m_new_polyA2

    def get_pre_defined_polyT_in_rmsk(self):
        m_polyT = {}
        m_polyT['(GTTTTT)n'] = 1
        m_polyT['(GTTTT)n'] = 1
        m_polyT['(TTATTTT)n'] = 1
        m_polyT['(ATTTT)n'] = 1
        m_polyT['(TATTT)n'] = 1
        m_polyT['(ATTT)n'] = 1
        m_polyT['(TTTGTT)n'] = 1
        m_polyT['(GTT)n'] = 1
        m_polyT['(TTTTGTT)n'] = 1
        m_polyT['(TTTATT)n'] = 1
        m_polyT['(TTATT)n'] = 1
        m_polyT['(TATT)n'] = 1
        m_polyT['(ATT)n'] = 1
        m_polyT['(TGT)n'] = 1
        m_polyT['(T)n'] = 1
        m_new_polyT2 = {}
        for s_tmp in m_polyT:
            m_new_polyT2[s_tmp] = 1
            m_rotate = self._rotate_seq(s_tmp[1:-2])
            for s_tmp2 in m_rotate:
                m_new_polyT2["(" + s_tmp2 + ")n"] = 1
        return m_new_polyT2

####
    def _rotate_seq(self, s_seq):
        m_new={}
        i_len=len(s_seq)
        s_template=s_seq+s_seq
        for i in range(i_len):
            s_tmp=s_template[i:i+i_len]
            m_new[s_tmp]=1
        return m_new