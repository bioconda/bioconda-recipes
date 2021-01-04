##07/15/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu
##
import os
from intervaltree import IntervalTree

class XBlackList():
    def __init__(self):
        self.m_regions={}
        self.b_with_chr = True #the bed file has "chr"
        self.m_interval_tree = {}  # by chrm

    # This indicates whether the chromosomes is in format "chr1" or "1"
    def set_with_chr(self, b_with_chr):
        self.b_with_chr = b_with_chr

    ## "self.b_with_chr" is the format gotten from the alignment file
    ## all other format should be changed to consistent with the "self.b_with_chr"
    def _process_chrm_name(self, chrm):
        b_chrm_with_chr = False
        if len(chrm) > 3 and chrm[:3] == "chr":  ##Here remove the "chr"
            b_chrm_with_chr = True

        if self.b_with_chr == True and b_chrm_with_chr == True:
            return chrm
        elif self.b_with_chr == True and b_chrm_with_chr == False:
            return "chr" + chrm
        elif self.b_with_chr == False and b_chrm_with_chr == True:
            return chrm[3:]
        else:
            return chrm

    ####load and index bed files with interval tree
    def load_index_regions(self, sf_bed):
        if os.path.isfile(sf_bed)==False:
            return
        with open(sf_bed) as fin_bed:
            for line in fin_bed:
                fields=line.split()
                chrm=fields[0]
                istart=int(fields[1])
                iend=int(fields[2])

                if chrm not in self.m_interval_tree:
                    interval_tree = IntervalTree()
                    self.m_interval_tree[chrm]=interval_tree
                self.m_interval_tree[chrm].addi(istart, iend)

####
    #here only check hit or not, doesn't matter how many records in all
    def fall_in_region(self, ins_chrm1, ins_pos):
        chrm = self._process_chrm_name(ins_chrm1)
        if chrm not in self.m_interval_tree:
            return False, -1
        tmp_tree = self.m_interval_tree[chrm]
        set_rslt = tmp_tree[ins_pos]
        if len(set_rslt) == 0:
            return False, -1
        for rcd in set_rslt:
            start_pos = rcd[0]
            return True, start_pos
        return False, -1
####