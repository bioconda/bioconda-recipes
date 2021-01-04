##09/05/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

####Given gff3 annotation file, check whether a given site fall into some specific gene or not.
###By default, for GRCh37, use gencode.v28lift37.annotation.gff3, and for V38, use gencode.v28.GRCh38.annotation.gff3
###Note, different genes may start from the same location, thus when retrieve, it will return a list of hits.

####update on 01/27/2019: replace the query module from binary tree (with bug) to interval tree

import global_values
from intervaltree import IntervalTree

class GFF3():
    def __init__(self, sf_gff3):
        self.sf_gff3=sf_gff3
        self.m_gene_annotation = {}
        #self.m_gene_chrm_regions = {}
        self.m_region_info={}#key: gene_name. Value:
        self.b_with_chr = True
        self.m_interval_tree={}#by chrm

    # This indicates whether the chromosomes is in format "chr1" or "1"
    def set_with_chr(self, b_with_chr):
        self.b_with_chr = b_with_chr
####
    ## "self.b_with_chr" is the format gotten from the alignment file
    ## all other format should be changed to consistent with the "self.b_with_chr"
    def _process_chrm_name(self, chrm):
        b_chrm_with_chr = False
        if len(chrm) > 3 and chrm[:3] == "chr":  ##Here remove the "chr"
            b_chrm_with_chr = True

        # print chrm, self.b_with_chr, b_chrm_with_chr #################################################################

        if self.b_with_chr == True and b_chrm_with_chr == True:
            return chrm
        elif self.b_with_chr == True and b_chrm_with_chr == False:
            return "chr" + chrm
        elif self.b_with_chr == False and b_chrm_with_chr == True:
            return chrm[3:]
        else:
            return chrm

####
    def _process_chrm_name2(self, chrm):
        if len(chrm) > 3 and chrm[:3] == "chr":
            return chrm[3:]
        else:
            return chrm

    ####this version allow the start and end position extend some distance
    #each record in format:
    #chr17 HAVANA gene 7661779 7687550 . - . ID=ENSG00000141510.16;gene_id=ENSG00000141510.16;
    # gene_type=protein_coding;gene_name=TP53;
    # level=2;tag=overlapping_locus;havana_gene=OTTHUMG00000162125.10
    def load_gene_annotation_with_extnd(self, iextnd):
        with open(self.sf_gff3) as fin_gene:
            for line in fin_gene:
                if len(line.rstrip())<1:
                    continue
                fields = line.split()

                if len(fields)<9:
                    continue
                if fields[0][0]=="#":
                    continue

                tmp_chrm = fields[0]
                chrm = self._process_chrm_name2(tmp_chrm)
                ori_start_pos=int(fields[3])
                ori_end_pos=int(fields[4])
                start_pos = ori_start_pos - iextnd
                end_pos = ori_end_pos + iextnd

                region_type=fields[2]#gene, transcript, exon, UTR5, UTR3, downstream, upstream ...
                if region_type=="transcript":#skip transcript
                    continue
                b_rc = False
                if fields[6] == "-":
                    b_rc = True

                sinfo=fields[8]
                sinfo_fields=sinfo.split(";")
                gene_id=""
                gene_type=""
                region_id=""
                gene_name=""
                for tmp_field in sinfo_fields:
                    tt_fields=tmp_field.split("=")
                    if tt_fields[0] == "ID":
                        region_id=tt_fields[1]
                    if tt_fields[0]=="gene_id":
                        gene_id=tt_fields[1]
                    if tt_fields[0]=="gene_type":
                        gene_type=tt_fields[1]
                    if tt_fields[0] == "gene_name":
                        gene_name=tt_fields[1]

                if region_type=="gene":
                    ####save the gene information
                    if chrm not in self.m_gene_annotation:
                        self.m_gene_annotation[chrm] = {}
                    if start_pos in self.m_gene_annotation[chrm]:
                        ##Here change the start position a little bit, as sometimes some genes have same start position
                        start_pos=start_pos-1
                        while start_pos in self.m_gene_annotation[chrm]:
                            start_pos = start_pos - 1
                        #print "Position {0}:{1} has more than  1 annotation, change a little bit!".format(chrm, start_pos)

                    extd_start_pos = start_pos  ###here extend the left boundary a little bit
                    if extd_start_pos not in self.m_gene_annotation[chrm]:
                        self.m_gene_annotation[chrm][extd_start_pos] = []
                    self.m_gene_annotation[chrm][extd_start_pos].append((end_pos, b_rc, gene_id, gene_type, gene_name)) #
                    ####Also save to the region dictionary
                    self.m_region_info[gene_id]={}#here we create two types of region: upstream_1k, downstream_1k
                    s_up_id=global_values.UP_STREAM_REGION+":"+gene_id
                    self.m_region_info[gene_id][s_up_id]=(start_pos, ori_start_pos)
                    s_down_id=global_values.DOWN_STREAM_REGION+":"+gene_id
                    self.m_region_info[gene_id][s_down_id] = (ori_end_pos, end_pos)
                else:
                    if gene_id not in self.m_region_info:
                        self.m_region_info[gene_id]={}
                    self.m_region_info[gene_id][region_id]=(ori_start_pos, ori_end_pos)


    # ##For each chrom, sort according to the start position of each region
    # def index_gene_annotation(self):
    #     for chrm in self.m_gene_annotation:
    #         l_tmp = []
    #         for pos in self.m_gene_annotation[chrm]:
    #             l_tmp.append(pos)
    #         l_tmp.sort()
    #         self.m_gene_chrm_regions[chrm] = l_tmp
###########################
        #print self.m_gene_chrm_regions
#
    def index_gene_annotation_interval_tree(self):
        for chrm in self.m_gene_annotation:
            interval_tree=IntervalTree()
            for start_pos in self.m_gene_annotation[chrm]:
                end_pos=self.m_gene_annotation[chrm][start_pos][0][0]
                interval_tree.addi(start_pos, end_pos)
            self.m_interval_tree[chrm] = interval_tree

    # For a given position, check whether it falls in a region
    # If hit, then return "True, chrm, start_pos_of_region "
    ##This is implemented by binary search
    #this version has a bug when try to check up and down
    #will not bu used anymore
    ##Search gene annotation
    # def find_hit_genes(self, chrm1, pos):
    #     l_hits = []  # find all the hits nearby
    #
    #     chrm=self._process_chrm_name2(chrm1)
    #     if chrm not in self.m_gene_chrm_regions:
    #         return l_hits
    #     lo, hi = 0, len(self.m_gene_chrm_regions[chrm]) - 1
    #
    #     idx_hit=-1
    #     while lo <= hi:
    #         mid = (lo + hi) / 2
    #         mid_start_pos = self.m_gene_chrm_regions[chrm][mid]
    #         mid_end_pos = self.m_gene_annotation[chrm][mid_start_pos][0][0]
    #         if pos >= mid_start_pos and pos <= mid_end_pos:
    #             #find one hit
    #             idx_hit=mid
    #             break
    #         elif pos > mid_start_pos:
    #             lo = mid + 1
    #         else:
    #             hi = mid - 1
    #
    #     if idx_hit==-1:
    #         return l_hits
    #     else:
    #         ori_idx_hit=idx_hit
    #         while idx_hit>=0:#check those up the idx
    #             mid_start_pos = self.m_gene_chrm_regions[chrm][idx_hit]
    #             mid_end_pos = self.m_gene_annotation[chrm][mid_start_pos][0][0]
    #             if pos >= mid_start_pos and pos <= mid_end_pos:
    #                 l_hits.append(mid_start_pos)
    #             else:
    #                 break
    #             idx_hit -= 1
    #
    #         n_all=len(self.m_gene_chrm_regions[chrm])
    #         idx_hit=ori_idx_hit+1 #check those down the idx
    #         while idx_hit<n_all:
    #             mid_start_pos = self.m_gene_chrm_regions[chrm][idx_hit]
    #             mid_end_pos = self.m_gene_annotation[chrm][mid_start_pos][0][0]
    #             if pos >= mid_start_pos and pos <= mid_end_pos:
    #                 l_hits.append(mid_start_pos)
    #             else:
    #                 break
    #             idx_hit += 1
    #     return l_hits


    def query_by_position(self, chrm1, pos):
        l_hits=[]
        chrm = self._process_chrm_name2(chrm1)
        if chrm not in self.m_interval_tree:
            return l_hits
        tmp_tree=self.m_interval_tree[chrm]
        set_rslt=tmp_tree[pos]
        for rcd in set_rslt:
            start_pos=rcd[0]
            l_hits.append(start_pos)
        return l_hits

    #find the gene-id and gene-type if the given position hit a gene
    def get_gene_id_type(self, chrm1, pos):
        chrm = self._process_chrm_name2(chrm1)

        l_rslt=[]
        l_hits=self.query_by_position(chrm, pos)
        if len(l_hits)>0:
            for gene_istart in l_hits:
                s_region_type = "intron"
                s_id=self.m_gene_annotation[chrm][gene_istart][0][2]
                s_type=self.m_gene_annotation[chrm][gene_istart][0][3]
                s_name=self.m_gene_annotation[chrm][gene_istart][0][4]
                for region_type in self.m_region_info[s_id]:
                    istart=self.m_region_info[s_id][region_type][0]
                    iend=self.m_region_info[s_id][region_type][1]
                    if pos>=istart and pos<=iend:
                        s_region_type=region_type+":"+s_name
                if s_region_type=="intron":
                    s_region_type="intron:"+s_id+":"+s_name
                l_rslt.append((s_id, s_type, s_region_type))

        return l_rslt
####
####
    #suppose the input in format: chrm pos ....
    def annotate_results(self, sf_ori_rslt, sf_out):
        with open(sf_ori_rslt) as fin_rslt, open(sf_out, "w") as fout_rslt:
            for line in fin_rslt:
                if line[0]=="#":
                    s_info=line.rstrip()
                    s_info+="\tgene_info\n"
                    fout_rslt.write(s_info)
                    continue
                fields=line.split()
                chrm=fields[0]
                pos=int(fields[1])

                l_hits=self.get_gene_id_type(chrm, pos)
                s_hit_genes=""
                for rcd in l_hits:
                    if s_hit_genes != "":
                        s_hit_genes += "/"
                    s_rcd=rcd[2]
                    s_hit_genes+=s_rcd
                if s_hit_genes=="":
                    s_hit_genes=global_values.NON_GENE

                s_info=line.rstrip()
                s_info+=("\t"+s_hit_genes+"\n")
                fout_rslt.write(s_info)
####