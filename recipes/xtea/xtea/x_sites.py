
class XSites():
    def __init__(self, sf_sites):
        self.sf_sites=sf_sites

    def load_in_sites(self):
        m_sites = {}
        with open(self.sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])
                if chrm not in m_sites:
                    m_sites[chrm] = {}
                m_sites[chrm][pos] = 1
        return m_sites

    ####
    def load_in_sites_of_regions(self):
        m_sites = {}
        with open(self.sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                chrm = fields[0]
                istart = int(fields[1])
                iend=int(fields[2])
                if chrm not in m_sites:
                    m_sites[chrm] = {}
                m_sites[chrm][istart] = iend
        return m_sites

    ####load in the qualified sites from xTEA output
    ####1. length should be larger than imin_len
    ####2. should consider the transductions
    #each line in format:
    ## #chrm	refined-pos	lclip-pos	rclip-pos	TSD	nalclip	narclip	naldisc	nardisc	nalpolyA
    # narpolyA	lcov	rcov	nlclip	nrclip	nldisc	nrdisc	nlpolyA	nrpolyA
    # lclip-cns-start:end	rclip_cns-start:end	ldisc-cns-start:end	rdisc-cns-start:end	Transduction-info
    # ntsd-clip	ntsd-disc	ntsd-polyA	ldisc-same	ldisc-diff	rdisc-same	rdisc-diff
    # 3mer-inversion	confidential	estimated-insertion-length
    def load_in_qualified_sites_from_xTEA_output(self, imin_len):
        m_sites = {}
        with open(self.sf_sites) as fin_sites:
            for line in fin_sites:
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])
                hcfdt=fields[-2]
                is_lth=int(fields[-1])
                if is_lth < imin_len:
                    continue
                transdct = fields[-11]

                # if hcfdt == "Confident" and transdct=="not_transduction":
                #     continue

                if chrm not in m_sites:
                    m_sites[chrm] = {}
                m_sites[chrm][pos] = 1
        return m_sites

####