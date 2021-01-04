##07/26/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

#Get target site duplication from the reference genome, or define targe-site-deletion
import pysam

class XTSD():
    #Each record within l_sites in format (chrm, left_clip_pos, right_clip_pos):
    #For target-site-duplication, left_clip_pos < right_clip_pos
    #But for target-site-deletion, left-clip-pos > right-clip-pos
    def get_TSD_seqs(self, sf_ref, l_sites):
        l_TSD=[]
        f_fa = pysam.FastaFile(sf_ref)
        m_ref_chrms = {}
        for tmp_chrm in f_fa.references:
            m_ref_chrms[tmp_chrm] = 1
        b_with_chr = False
        if "chr1" in m_ref_chrms:
            b_with_chr = True
        for rcd in l_sites:
            s_tsd="NULL"
            ins_chrm=rcd[0]
            lpos=int(rcd[1])
            rpos=int(rcd[2])
            if lpos<=0 or rpos<=0:
                l_TSD.append(s_tsd)
                continue
            ref_chrm = self.process_chrm_name(ins_chrm, b_with_chr)
            s_signal="+"#indicates target site duplication, while "-" means target site deletion
            #check whether the chromosome is consistent
            istart=lpos
            iend=rpos
            if lpos>rpos:
                istart=rpos
                iend=lpos
                s_signal="-"
            s_tsd = f_fa.fetch(ref_chrm, istart, iend)
            s_tsd2=s_signal+s_tsd
            l_TSD.append(s_tsd2)
        f_fa.close()
        return l_TSD

####
    ## "self.b_with_chr" is the format gotten from the alignment file
    ## all other format should be changed to consistent with the "b_with_chr"
    def process_chrm_name(self, chrm, b_with_chr):
        b_chrm_with_chr = False
        if len(chrm) > 3 and chrm[:3] == "chr":  ##Here remove the "chr"
            b_chrm_with_chr = True
        # print chrm, self.b_with_chr, b_chrm_with_chr ###############################################################
        if b_with_chr == True and b_chrm_with_chr == True:
            return chrm
        elif b_with_chr == True and b_chrm_with_chr == False:
            return "chr" + chrm
        elif b_with_chr == False and b_chrm_with_chr == True:
            return chrm[3:]
        else:
            return chrm

####