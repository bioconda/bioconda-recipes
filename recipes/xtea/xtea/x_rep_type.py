##11/04/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

#To-do-list: 1. same module in x_post_filter.py, need to merge them!!!!

class RepType():
    def __init__(self):
        self.REP_TYPE_L1 = "LINE1"
        self.REP_TYPE_ALU = "ALU"
        self.REP_TYPE_SVA = "SVA"
        self.REP_TYPE_HERV = "HERV"
        self.REP_TYPE_MIT = "Mitochondria"
        self.REP_TYPE_MSTA = "Msta"
        self.PSUDOGENE="Pseudogene"

        ###this is specific string within the VCF file
        self.REP_TYPE_L1_vcf = "INS:ME:LINE1"
        self.REP_TYPE_ALU_vcf = "INS:ME:ALU"
        self.REP_TYPE_SVA_vcf = "INS:ME:SVA"
        self.REP_TYPE_HERV_vcf = "INS:ME:HERV-K"
        self.REP_TYPE_MIT_vcf = "INS:MT"
        self.REP_TYPE_MSTA_vcf = "INS:Msta"
        self.PSUDOGENE_vcf = "INS:PSDGN"


    #get repeat type
    def get_rep_type(self, i_rep_type):
        if i_rep_type & 1 != 0:
            return self.REP_TYPE_L1
        if i_rep_type & 2 != 0:
            return self.REP_TYPE_ALU
        if i_rep_type & 4 != 0:
            return self.REP_TYPE_SVA
        if i_rep_type & 8 != 0:
            return self.REP_TYPE_HERV
        if i_rep_type & 16 != 0:  #mitochondrial
            return self.REP_TYPE_MIT
        if i_rep_type & 32 != 0:
            return self.REP_TYPE_MSTA
        if i_rep_type & 64 != 0:
            return self.PSUDOGENE
        return "unkown"

    def get_all_rep_types(self, i_rep_type):
        m_types={}
        if i_rep_type & 1 != 0:
            m_types[self.REP_TYPE_L1]=1
        if i_rep_type & 2 != 0:
            m_types[self.REP_TYPE_ALU] = 1
        if i_rep_type & 4 != 0:
            m_types[self.REP_TYPE_SVA] = 1
        if i_rep_type & 8 != 0:
            m_types[self.REP_TYPE_HERV] = 1
        if i_rep_type & 16 != 0:  #mitochondrial
            m_types[self.REP_TYPE_MIT] = 1
        if i_rep_type & 32 != 0:
            m_types[self.REP_TYPE_MSTA] = 1
        if i_rep_type & 64 != 0:
            m_types[self.PSUDOGENE] = 1
        return m_types
####
    def get_rep_vcf_alt_type(self, i_rep_type):
        if i_rep_type & 1 != 0:
            return self.REP_TYPE_L1_vcf
        if i_rep_type & 2 != 0:
            return self.REP_TYPE_ALU_vcf
        if i_rep_type & 4 != 0:
            return self.REP_TYPE_SVA_vcf
        if i_rep_type & 8 != 0:
            return self.REP_TYPE_HERV_vcf
        if i_rep_type & 16 != 0:  # mitochondrial
            return self.REP_TYPE_MIT_vcf
        if i_rep_type & 32 != 0:
            return self.REP_TYPE_MSTA_vcf
        if i_rep_type & 64 != 0:
            return self.PSUDOGENE_vcf
        return "unkown"

####parse out the specific repeat type
    def parse_out_all_rep_type(self, i_rep_type):
        l_rep_type = []
        if i_rep_type & 1 != 0:
            l_rep_type.append(self.REP_TYPE_L1)
        if i_rep_type & 2 != 0:
            l_rep_type.append(self.REP_TYPE_ALU)
        if i_rep_type & 4 != 0:
            l_rep_type.append(self.REP_TYPE_SVA)
        if i_rep_type & 8 != 0:
            l_rep_type.append(self.REP_TYPE_HERV)
        if i_rep_type & 16 != 0:#mitochondrial
            l_rep_type.append(self.REP_TYPE_MIT)
        if i_rep_type & 32 != 0:
            l_rep_type.append(self.REP_TYPE_MSTA)
        if i_rep_type & 64 != 0:
            l_rep_type.append(self.PSUDOGENE)
        return l_rep_type
####
####
    def get_L1_str(self):
        return self.REP_TYPE_L1

    def get_Alu_str(self):
        return self.REP_TYPE_ALU

    def get_SVA_str(self):
        return self.REP_TYPE_SVA
    def get_HERV_str(self):
        return self.REP_TYPE_HERV

