##11/22/2017
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

import os
import sys
import pysam
from x_intermediate_sites import *
from x_reference import *
import global_values
from disc_cluster import *

#
def unwrap_self_extract_reads_for_region(arg, **kwarg):
    return BamInfo.extract_reads_for_region(*arg, **kwarg)

def unwrap_self_extract_mate_reads_for_region(arg, **kwarg):
    return BamInfo.extract_mate_reads_of_region(*arg, **kwarg)

####Function: Functions for processing alignment, like trim, change format, and etc.
class BamInfo():
    def __init__(self, sf_bam, sf_ref):
        self.sf_bam = sf_bam
        self.out_header = None
        self.chrm_id_name = {}
        self.sf_reference=sf_ref
        # if the chromosome name in format: chr1, then return true,

    def index_reference_name_id(self):
        bamfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        header = bamfile.header
        bamfile.close()

        l_chrms = header['SQ']
        chrm_id = 0
        for record in l_chrms:
            chrm_name = record['SN']
            self.chrm_id_name[chrm_id] = chrm_name
            chrm_id += 1

    def get_all_reference_names(self):
        bamfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        header = bamfile.header
        bamfile.close()

        l_chrms = header['SQ']
        m_chrms = {}
        for record in l_chrms:
            chrm_name = record['SN']
            m_chrms[chrm_name] = 1
        return m_chrms
####
    # get the chrom name and length in a dictionary
    def get_all_chrom_name_length(self):
        bamfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        header = bamfile.header
        bamfile.close()

        l_chrms = header['SQ']
        m_chrms = {}
        for record in l_chrms:
            chrm_name = record['SN']
            chrm_length = int(record['LN'])
            m_chrms[chrm_name] = chrm_length
        return m_chrms

    def get_reference_name_by_id(self, id):
        i_id = int(id)
        if i_id in self.chrm_id_name:
            return self.chrm_id_name[i_id]
        else:
            return "*"

####
    # else if in format: 1, then return false
    def is_chrm_contain_chr(self):
        samfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        self.out_header = samfile.header  # it's a dictionary
        samfile.close()

        l_chrms = self.out_header['SQ']
        m_chrms = {}
        for record in l_chrms:
            chrm_id = record['SN']
            m_chrms[chrm_id] = 1

        b_with_chr = False
        if "chr1" in m_chrms:
            b_with_chr = True

        self.b_with_chr = b_with_chr
        return b_with_chr

####
    ###Note: hard code here, use mapping quality 20 as cutoff for anchor reads
    def cnt_discordant_pairs(self, bamfile, m_chrm_ids, chrm, start, end, i_is, f_dev, xannotation):
        n_cnt = 0
        n_raw_cnt=0 #this save the raw discordant PE pairs, including: abnormal insert size, abnormal direction
        iter_alignmts = bamfile.fetch(chrm, start, end)
        xchrom = XChromosome()
        i_max_is=2500
        if int(i_is+3*f_dev)>i_max_is:
            i_max_is=int(i_is+3*f_dev)

        m_mate_pos={}
        for algnmt in iter_alignmts:
            if algnmt.is_duplicate == True or algnmt.is_supplementary == True:  ##skip duplicate and supplementary ones
                continue
            if algnmt.is_unmapped == True or algnmt.mate_is_unmapped == True:  #### for now, just skip the unmapped reads
                continue
            if algnmt.is_secondary == True:  ##skip secondary alignment
                continue
            if algnmt.mapping_quality < global_values.MINIMUM_DISC_MAPQ:###############anchor mapping quality
                continue
            if algnmt.next_reference_id<0:
                continue

            map_pos=algnmt.reference_start
            if algnmt.next_reference_id not in m_chrm_ids:
                continue
            mate_chrm = algnmt.next_reference_name
            if xchrom.is_decoy_contig_chrms(mate_chrm) == True:
                continue
            mate_pos = algnmt.next_reference_start

            # ####This version consider the discordant event happen within the same chromosome
            # template_lth = abs(algnmt.template_length)
            # xalgnmt = XAlignment()
            # if xalgnmt.is_discordant_pair_no_unmap(chrm, mate_chrm, template_lth, i_is, f_dev):
            #     b_mate_within_rep, rep_start_mate = xannotation.is_within_repeat_region(mate_chrm, mate_pos)
            #     if b_mate_within_rep:
            #         n_cnt+=1

            #####This version only count the number of discordant pairs whose two reads aligned to different chroms

            #####Or on the same chromosome, but aligned quite far away (by default >1M)
            #Note, here we use "start" to represent the "map_pos" of each read.
            if (chrm != mate_chrm) or (chrm == mate_chrm and abs(mate_pos - start) > i_is):
                if (chrm != mate_chrm) or (chrm == mate_chrm and abs(mate_pos - start) > i_max_is):
                    if mate_chrm not in m_mate_pos:
                        m_mate_pos[mate_chrm]=[]
                    m_mate_pos[mate_chrm].append(mate_pos)
                    n_raw_cnt+=1
                #b_mate_within_rep, rep_start_mate = xannotation.is_within_repeat_region(mate_chrm, mate_pos)
                b_mate_within_rep, rep_start_mate = xannotation.is_within_repeat_region_interval_tree(mate_chrm, mate_pos)
                if b_mate_within_rep:
                    n_cnt += 1
        dc = DiscCluster()
        b_cluster, c_chrm, c_pos=dc.form_one_side_cluster(m_mate_pos, i_is, global_values.MIN_RAW_DISC_CLUSTER_RATIO)
        return n_cnt, n_raw_cnt, (b_cluster, c_chrm, c_pos)


    ## "self.b_with_chr" is the format gotten from the alignment file
    ## all other format should be changed to consistent with the "self.b_with_chr"
    def process_chrm_name(self, chrm, b_with_chr):
        b_chrm_with_chr = False
        if len(chrm) > 3 and chrm[:3] == "chr":  ##Here remove the "chr"
            b_chrm_with_chr = True

        # print chrm, self.b_with_chr, b_chrm_with_chr #######################################################################
        if b_with_chr == True and b_chrm_with_chr == True:
            return chrm
        elif b_with_chr == True and b_chrm_with_chr == False:
            return "chr" + chrm
        elif b_with_chr == False and b_chrm_with_chr == True:
            return chrm[3:]
        else:
            return chrm

    # calculate coverage
    def calc_coverage(self, fpath, read_length, genome_length):
        cnt_lines = 0
        cmd = ""
        if fpath.lower().endswith(('.fq', '.fastq')):
            cmd = "echo $(wc -l {0})".format(fpath)
        elif fpath.lower().endswith(('.fastq.gz', 'fq.gz', 'gz')):
            cmd = "echo $(zcat {0} | wc -l)".format(fpath)
        else:
            print("Something wrong with the raw reads files format:", fpath)

        tp = tuple(Popen(cmd, shell=True, stdout=PIPE).communicate())
        lcnt = str(tp[0]).split()

        cnt_lines = int(lcnt[0])
        cnt_reads = int(cnt_lines) / 4
        cov = float(cnt_reads * read_length) / float(genome_length)
        return cov

    ##read in the read names from file
    def load_read_names(self, sf_names):
        with open(sf_names, 'r') as infile:
            l_names = infile.read().splitlines()
        if '' in l_names:
            l_names.remove('')
        return l_names

    # extract the reads by read names
    def extract_reads_by_name_list(self, sf_names, sf_bam, sf_out_bam):
        l_names = self.load_read_names(sf_names)
        bamfile = pysam.AlignmentFile(sf_bam, 'rb', reference_filename=self.sf_reference)
        name_indexed = pysam.IndexedReads(bamfile)  # here use hashing to save the read names in the memory
        name_indexed.build()
        header = bamfile.header.copy()
        out = pysam.Samfile(sf_out_bam, 'wb', header=header)
        for name in l_names:
            try:
                name_indexed.find(name)
            except KeyError:
                pass
            else:
                iterator = name_indexed.find(name)
                for x in iterator:  # x is an alignment
                    ###here need to check whether this is the first or second read we wanted!!!!
                    out.write(x)
        out.close()

    def extract_reads_for_region(self, record):
        chrm=record[0]
        istart=record[1]
        iend=record[2]
        sf_read_names=record[3]
        s_working_folder=record[4]
        if s_working_folder[-1]!="/":
            s_working_folder+="/"

        #first write the bam to file, and then index it, and finally get the fastq reads
        bamfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        sf_tmp_bam=s_working_folder+"{0}_{1}_{2}.bam".format(chrm, istart, iend)
        out_tmp_bam = pysam.Samfile(sf_tmp_bam, 'wb', template=bamfile)
        for algnmt in bamfile.fetch(chrm, istart, iend):
            out_tmp_bam.write(algnmt)
        out_tmp_bam.close()
        bamfile.close()

        sf_parsed_bam=s_working_folder+"{0}_{1}_{2}.disc.bam".format(chrm, istart, iend)
        self.extract_reads_by_name_list(sf_read_names, sf_tmp_bam, sf_parsed_bam)

    #convert an alignmet to a fasta format seq
    def cvt_alignmt_to_fa(self, alignmt):
        read_name=alignmt.query_name
        query_seq = alignmt.query_sequence

####
    # Extract the reads of the given list
    # First, cluster by mate_chrom:mate_pos, and extract the reads for each bin
    # sf_names: name list file, each name one line
    # sf_pos: position file in formate: "chrm pos mate_chrm mate_pos read_name is_mate_first insertion_pos"
    def extract_reads_by_name_in_parallel(self, sf_names, sf_pos, bin_size, sf_working_folder, n_jobs,  sf_out_fa):
        m_chrm_lenth = self.get_all_chrom_name_length()
        xref = XReference()
        m_bin_pos = xref.break_ref_to_bins(m_chrm_lenth, bin_size) #in format: m{chr:[bin_start, bin_end]}

        m_bin_cnt={}#count how many disocordant mate reads fall in each bin
        m_reads_names={} #save all the read names (and first or its mate) we are going to retrieve
        with open(sf_pos) as fin_pos:#retrieve the discordant read positions saved in "sf_pos"
            #each line in format: chrm, map_pos, mate_chrm, mate_pos, query_name, s_mate_first, insertion_pos
            for line in fin_pos:
                fields = line.split()
                mate_chrm = fields[2]
                mate_pos = int(fields[3])
                s_ins_chrm=fields[0]
                s_ins_pos=fields[6]
                if mate_chrm not in m_bin_cnt:
                    m_bin_cnt[mate_chrm]={}
                bin_idx=mate_pos/bin_size
                if bin_idx not in m_bin_cnt[mate_chrm]:
                    m_bin_cnt[mate_chrm][bin_idx]=1
                else:
                    m_bin_cnt[mate_chrm][bin_idx] += 1
                read_name=fields[4]
                is_mate_first=fields[5]

                s_read_id_info="{0}~{1}".format(read_name, is_mate_first)
                s_insertion_site="{0}~{1}".format(s_ins_chrm, s_ins_pos)
                if s_read_id_info not in m_reads_names:#one read can be assigned to multiple related insertion sites
                    m_reads_names[s_read_id_info]=[]
                m_reads_names[s_read_id_info].append(s_insertion_site)

        #tmp_cnt_all_bins=0################################################################################
        #tmp_cnt_hit_bins=0################################################################################
        xchrom = XChromosome()
        l_bin_info=[]
        for mate_chrm in m_bin_cnt:
            if xchrom.is_decoy_contig_chrms(mate_chrm)==True:
                continue
            for bin_idx in m_bin_cnt[mate_chrm]:
                #tmp_cnt_all_bins+=1 ################################################################################
                if m_bin_cnt[mate_chrm][bin_idx]>0:
                    #tmp_cnt_hit_bins+=1
                    bin_start,bin_end=m_bin_pos[mate_chrm][bin_idx]
                    l_bin_info.append((mate_chrm, bin_start, bin_end, sf_names, sf_working_folder))

        #with open(sf_working_folder+"tmp_output_info.txt", "w") as fout_tmp_info: #####################################
        #    fout_tmp_info.write(str(tmp_cnt_hit_bins)+" out of all "+str(tmp_cnt_all_bins)+" bins have hits!\n")

        pool = Pool(n_jobs)
        pool.map(unwrap_self_extract_reads_for_region, list(zip([self] * len(l_bin_info), l_bin_info)), 1)
        pool.close()
        pool.join()

        #then merge the parsed discordant reads
        with open(sf_out_fa, "w") as fout_fa:
            for record in l_bin_info:
                chrm = record[0]
                istart = record[1]
                iend = record[2]
                sf_parsed_bam = sf_working_folder + "{0}_{1}_{2}.disc.bam".format(chrm, istart, iend)
                if os.path.isfile(sf_parsed_bam)==False:
                    print("Error: file {0} doesn't exist!".format(sf_parsed_bam))
                    continue

                #open each bam, and get the read, need to export the read_name~is_first~insertion_site
                #in this way, we can split the reads back to each sites
                bamfile = pysam.AlignmentFile(sf_parsed_bam, "rb", reference_filename=self.sf_reference)
                iter_algnmts = bamfile.fetch(until_eof=True) #no need to be indexed
                for alignmt in iter_algnmts:
                    s_read_name=alignmt.query_name
                    read_seq = alignmt.query_sequence
                    is_first = 0
                    if alignmt.is_read1==True:
                        is_first=1

                    s_read_id="{0}~{1}".format(s_read_name, is_first)
                    if s_read_id not in m_reads_names:
                        continue

                    #s_insertion_site=m_reads_names[s_read_id]
                    for s_insertion_site in m_reads_names[s_read_id]:
                        #save read name in format: name~is_first~chrm~pos (here chrm:pos is the original insertion site)
                        s_read_info=">{0}~{1}\n".format(s_read_id, s_insertion_site)
                        fout_fa.write(s_read_info)
                        fout_fa.write(read_seq+"\n")
                bamfile.close()

    ####give the read name file, return the read fall in the given region
    def _parse_read_name_pos_of_region(self, sf_name_pos, chrm, start, end):
        m_reads={}
        with open(sf_name_pos) as fin_name_pos:
            #each line in format: chrm, map_pos, is_rc, is_mate_rc, mate_chrm, mate_pos, query_name, s_mate_rc, insertion_pos
            for line in fin_name_pos:
                fields=line.split()
                ins_chrm = fields[0]
                anchor_read_map_pos=int(fields[1]) ##this is the map_pos of the anchor read
                s_anchor_rc=fields[2] # "0" or "1"
                s_anchor_mate_rc=fields[3]  # "0" or "1"
                mate_chrm=fields[4]
                mate_pos=int(fields[5])

                if chrm != mate_chrm:
                    continue
                if mate_pos<(start-100) or mate_pos>(end+100):
                    continue

                rname=fields[6]
                s_first=fields[7]
                s_insertion_pos=fields[8]
                b_lclip=fields[9] # 0 or 1
                b_rclip=fields[10] # 0 or 1

                s_insertion_site = "{0}~{1}".format(ins_chrm, s_insertion_pos)
                s_info="{0}~{1}".format(rname, s_first)
                if s_info not in m_reads:
                    m_reads[s_info]={}
                m_reads[s_info][s_insertion_site]=(anchor_read_map_pos, s_anchor_rc, s_anchor_mate_rc, b_lclip, b_rclip)
        return m_reads


    def extract_mate_reads_of_region(self, record):
        chrm=record[0]
        bin_start=int(record[1])
        bin_end=int(record[2])
        sf_name_pos=record[3]
        s_working_folder=record[4]

        m_reads=self._parse_read_name_pos_of_region(sf_name_pos, chrm, bin_start, bin_end)

        #first write the bam to file, and then index it, and finally get the fastq reads
        bamfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        sf_tmp_disc_fa=s_working_folder+"{0}_{1}_{2}.tmp.disc.fa".format(chrm, bin_start, bin_end)
        with open(sf_tmp_disc_fa,"w") as fout_fa:
            for alignmt in bamfile.fetch(chrm, bin_start, bin_end):
                s_read_name = alignmt.query_name
                read_seq = alignmt.query_sequence
                is_first = 0
                if alignmt.is_read1 == True:
                    is_first = 1

                s_read_id = "{0}~{1}".format(s_read_name, is_first)
                if s_read_id not in m_reads:
                    continue
                for s_insertion in m_reads[s_read_id]:
                    (anchor_map_pos, s_anchor_rc, s_anchor_mate_rc, b_lclip, b_rclip)=m_reads[s_read_id][s_insertion]
                    s_read_info = ">{0}~{1}~{2}~{3}~{4}~{5}~{6}\n".format(s_read_id, b_lclip, b_rclip, s_anchor_rc,
                                                                          s_anchor_mate_rc, anchor_map_pos, s_insertion)
                    fout_fa.write(s_read_info)
                    fout_fa.write(read_seq + "\n")
        bamfile.close()
####

    # #extract all the mate reads of a given list
    def extract_mate_reads_by_name(self, sf_name_pos, bin_size, sf_working_folder, n_jobs,  sf_out_fa):
        if sf_working_folder[-1]!="/":
            sf_working_folder+="/"
        m_chrm_lenth = self.get_all_chrom_name_length()
        xref = XReference()
        m_bin_pos = xref.break_ref_to_bins(m_chrm_lenth, bin_size) #in format: m{chr:[bin_start, bin_end]}

        xchrom = XChromosome()
        l_bin_info = []
        for chrm in m_bin_pos:
            if xchrom.is_decoy_contig_chrms(chrm)==True:
                continue
            for (bin_start, bin_end) in m_bin_pos[chrm]:
                l_bin_info.append((chrm, bin_start, bin_end, sf_name_pos, sf_working_folder))
        pool = Pool(n_jobs)
        pool.map(unwrap_self_extract_mate_reads_for_region, list(zip([self] * len(l_bin_info), l_bin_info)), 1)
        pool.close()
        pool.join()

        #merge the fa files
        with open(sf_out_fa, "w") as fout_disc_fa:
            for record in l_bin_info:
                chrm = record[0]
                istart = record[1]
                iend = record[2]
                sf_tmp_disc_fa = sf_working_folder + "{0}_{1}_{2}.tmp.disc.fa".format(chrm, istart, iend)
                with open(sf_tmp_disc_fa) as fin_tmp:
                    for line in fin_tmp:
                        fout_disc_fa.write(line)
                if os.path.isfile(sf_tmp_disc_fa):#clean the temporary file
                    os.remove(sf_tmp_disc_fa)
####
####
#this is for long reads alignment file
class LBamInfo(BamInfo):
    def __init__(self, sf_bam, sf_ref):
        BamInfo.__init__(self, sf_bam, sf_ref)

    def extract_clipped_part_for_sites(self, sf_sites, iextnd, s_working_folder, sf_out):
        bamfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        with open(sf_sites) as fin_sites:
            for line in fin_sites:
                fields=line.split()

                chrm = fields[0]
                pos=int(fields[1])
                istart = pos-iextnd
                iend = pos+iextnd

                if s_working_folder[-1] != "/":
                    s_working_folder += "/"

                #for algnmt in bamfile.fetch(chrm, istart, iend):
                    #check whether it is clipped near by the break point
        bamfile.close()
#

###for 10X bam
class XBamInfo(BamInfo):
    def __init__(self, sf_bam, sf_barcode_bam, sf_ref):
        BamInfo.__init__(self, sf_bam, sf_ref)
        self.sf_barcode_bam = sf_barcode_bam

    # def set_barcode_bam(self, sf_barcode_bam):#

    # for given barcode, get all the related alignments
    # filter out those unreleated to L1 repeats
    def _get_alignments_for_given_barcode(self, s_barcode):
        bamfile = pysam.AlignmentFile(self.sf_barcode_bam, "rb", reference_filename=self.sf_reference)
        iter_algnmts = bamfile.fetch(s_barcode)
        l_selected_algnmts = []
        for alnmt in iter_algnmts:  # each in "pysam.AlignedSegment" format
            if alnmt.is_duplicate == True or alnmt.is_supplementary == True:  ##skip duplicate and supplementary ones
                continue
            if alnmt.is_unmapped == True:  #### for now, just skip the unmapped reads ???????????????????????????????
                continue
            if alnmt.is_secondary == True:  ##skip secondary alignment
                continue
            l_selected_algnmts.append(alnmt)
        bamfile.close()
        return l_selected_algnmts

    def get_alignments_for_all_barcodes(self, set_barcode):
        m_site_alignments = {}
        bamfile = pysam.AlignmentFile(self.sf_barcode_bam, "rb", reference_filename=self.sf_reference)
        for s_barcode in set_barcode:
            iter_algnmts = bamfile.fetch(s_barcode)
            l_selected_algnmts = []
            for alnmt in iter_algnmts:  # each in "pysam.AlignedSegment" format
                if alnmt.is_duplicate == True or alnmt.is_supplementary == True:  ##skip duplicate and supplementary ones
                    continue
                # if alnmt.is_unmapped == True:  #### for now, just skip the unmapped reads ???????????????????????????????
                #     continue
                if alnmt.is_secondary == True:  ##skip secondary alignment
                    continue
                l_selected_algnmts.append(alnmt)
            m_site_alignments[s_barcode] = l_selected_algnmts
        bamfile.close()
        return m_site_alignments

    # change the barcode format from "xxx-1" to "xxx_1"
    def _change_barcode_format(self, sbarcode):
        fields = sbarcode.split("-")
        return "_".join(fields)

    def parse_alignments_for_one_site(self, chrm, pos, i_extend):
        bamfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        # 1. get all the barcodes for the sites
        set_barcodes = set()
        for alignment in bamfile.fetch(chrm, pos - i_extend, pos + i_extend):
            if alignment.is_duplicate == True or alignment.is_supplementary == True:  ##skip duplicate and supplementary ones
                continue
            if alignment.is_unmapped == True:  #### for now, just skip the unmapped reads ??????????????????????????????
                continue
            if alignment.is_secondary == True:  ##skip secondary alignment
                continue

            if alignment.has_tag('BX') == True:
                s_barcode = alignment.get_tag('BX')
                # change the barcode format from "xxx-1" to "xxx_1"
                set_barcodes.add(self._change_barcode_format(s_barcode))
        bamfile.close()

        # 2. given all the barcode, get all the alignments
        m_site_alignments = self.get_alignments_for_all_barcodes(set_barcodes)
        return m_site_alignments

    ###for this version, pass in the opened file, to avoid too frequency I/O operation
    def get_alignments_for_all_barcodes_v2(self, bamfile, set_barcode):
        m_site_alignments = {}
        # bamfile = pysam.AlignmentFile(self.sf_barcode_bam, "rb")
        for s_barcode in set_barcode:
            iter_algnmts = bamfile.fetch(s_barcode)
            l_selected_algnmts = []
            for alnmt in iter_algnmts:  # each in "pysam.AlignedSegment" format
                if alnmt.is_duplicate == True or alnmt.is_supplementary == True:  ##skip duplicate and supplementary ones
                    continue
                # if alnmt.is_unmapped == True:  #### for now, just skip the unmapped reads ???????????????????????????????
                #     continue
                if alnmt.is_secondary == True:  ##skip secondary alignment
                    continue
                l_selected_algnmts.append(alnmt)
            m_site_alignments[s_barcode] = l_selected_algnmts
        # bamfile.close()
        return m_site_alignments

    ##return a list of alignments of the given barcode
    def get_alignments_for_one_barcode(self, bamfile, sbarcode):
        iter_algnmts = bamfile.fetch(sbarcode)
        l_selected_algnmts = []
        for alnmt in iter_algnmts:  # each in "pysam.AlignedSegment" format
            if alnmt.is_duplicate == True or alnmt.is_supplementary == True:  ##skip duplicate and supplementary ones
                continue
            if alnmt.is_secondary == True:  ##skip secondary alignment
                continue
            l_selected_algnmts.append(alnmt)
        return l_selected_algnmts

    ##
    def open_bam_file(self, sf_bam):
        bamfile = pysam.AlignmentFile(sf_bam, "rb", reference_filename=self.sf_reference)
        return bamfile

    def close_bam_file(self, bamfile):
        bamfile.close()

    # get all the barcodes for the sites
    def parse_barcodes_for_one_site(self, bamfile, chrm, pos, i_extend):
        set_barcodes = set()
        for alignment in bamfile.fetch(chrm, pos - i_extend, pos + i_extend):
            if alignment.is_duplicate == True or alignment.is_supplementary == True:  ##skip duplicate and supplemty ones
                continue
            if alignment.is_unmapped == True:  #### for now, just skip the unmapped reads ????????????????????????????
                continue
            if alignment.is_secondary == True:  ##skip secondary alignment
                continue

            if alignment.has_tag('BX') == True:
                s_barcode = alignment.get_tag('BX')
                # change the barcode format from "xxx-1" to "xxx_1"
                set_barcodes.add(self._change_barcode_format(s_barcode))
        return set_barcodes

    ###for this version, pass in the opened file, to avoid too frequency I/O operation
    def parse_alignments_for_one_site_v2(self, bamfile, barcode_bamfile, chrm, pos, i_extend):
        # 1. get all the barcodes for the sites
        set_barcodes = self.parse_barcodes_for_one_site(bamfile, chrm, pos, i_extend)
        ###here skip the region with extremely lots of barcodes cover
        if len(set_barcodes) > global_values.BARCODE_COV_CUTOFF:
            return None

        # 2. given all the barcode, get all the alignments
        m_site_alignments = self.get_alignments_for_all_barcodes_v2(barcode_bamfile, set_barcodes)
        return m_site_alignments

    def _get_chrm_id_name(self, samfile):
        m_chrm = {}
        references = samfile.references
        for schrm in references:
            chrm_id = samfile.get_tid(schrm)
            m_chrm[chrm_id] = schrm
        m_chrm[-1] = "*"
        return m_chrm

    ###for this version, pass in the opened file, to avoid too frequency I/O operation
    ##Also, for "Haplotype1", "Haplotype2", and "unknown", return different sets of barcode
    def parse_phased_barcodes_for_one_site(self, bamfile, chrm, pos, i_extend, i_cov_cutoff):
        # 1. get all the barcodes for the sites
        set_barcodes_hap1 = set()
        set_barcodes_hap2 = set()
        set_barcode_unknown = set()
        set_barcode_discordant = set()  ####save the barcode of discordant read pairs
        m_chrm_ids=self._get_chrm_id_name(bamfile)
        for alignment in bamfile.fetch(chrm, pos - i_extend, pos + i_extend):
            if alignment.is_duplicate == True or alignment.is_supplementary == True:  ##skip duplicate and supplementary ones
                continue
            if alignment.is_unmapped == True:  #### for now, just skip the unmapped reads ??????????????????????????????
                continue
            if alignment.is_secondary == True:  ##skip secondary alignment
                continue

            s_barcode_ori = ""
            if alignment.has_tag('BX') == True:
                s_barcode_ori = alignment.get_tag('BX')

            s_barcode = ""
            if s_barcode_ori != "":
                s_barcode = self._change_barcode_format(s_barcode_ori)
            if alignment.has_tag("HP") == False:
                # unphased read
                if s_barcode != "":
                    set_barcode_unknown.add(s_barcode)
            else:
                hp = str(alignment.get_tag('HP'))
                if hp == "1" and s_barcode != "":  # change the barcode format from "xxx-1" to "xxx_1"
                    set_barcodes_hap1.add(s_barcode)
                elif hp == "2" and s_barcode != "":
                    set_barcodes_hap2.add(s_barcode)

            ####
            # if mate read is unmapped, then skip
            if alignment.mate_is_unmapped == True:
                continue

            if (alignment.next_reference_id<0) or (alignment.next_reference_id not in m_chrm_ids):##
                print("[x_alignments:parse_phased_barcodes_for_one_site]abnormal mate reference id of read: {0}"\
                    .format(alignment.query_name), alignment.reference_name, alignment.reference_start)
                continue

            mate_chrm = alignment.next_reference_name
            mate_pos = alignment.next_reference_start
            xchrom = XChromosome()
            if xchrom.is_decoy_contig_chrms(mate_chrm) == False and chrm != mate_chrm:
                if alignment.mapping_quality >= 20 and s_barcode != "":  ############################################################
                    set_barcode_discordant.add(s_barcode)

        ###here skip the region with extremely lots of barcodes cover
        if len(set_barcodes_hap1) > i_cov_cutoff:
            set_barcodes_hap1 = None
        if len(set_barcodes_hap2) > i_cov_cutoff:
            set_barcodes_hap2 = None
        if len(set_barcode_unknown) > i_cov_cutoff:
            set_barcode_unknown = None
        if len(set_barcode_discordant) > i_cov_cutoff:
            set_barcode_discordant = None
        return set_barcodes_hap1, set_barcodes_hap2, set_barcode_unknown, set_barcode_discordant

    ####
    # 2. given all the barcode, get all the alignments
    # m_site_alignments=self.get_alignments_for_all_barcodes_v2(barcode_bamfile, set_barcodes)
    # return m_site_alignments

    ##this version, we open the file once, and get all the related alignments
    # def parse_alignments_for_sites_by_chrom(self, chrm, l_pos, i_extend):
    def get_barcodes_for_region(self, chrm, start, end):
        bamfile = pysam.AlignmentFile(self.sf_bam, "rb", reference_filename=self.sf_reference)
        set_barcodes = set()
        for alignment in bamfile.fetch(chrm, start, end):
            if alignment.is_duplicate == True or alignment.is_supplementary == True:  ##skip duplicate and supplementary ones
                continue
            if alignment.is_unmapped == True:  #### for now, just skip the unmapped reads ??????????????????????????????
                continue
            if alignment.is_secondary == True:  ##skip secondary alignment
                continue

            if alignment.has_tag('BX') == True:
                s_barcode = alignment.get_tag('BX')
                # change the barcode format from "xxx-1" to "xxx_1"
                set_barcodes.add(self._change_barcode_format(s_barcode))
        bamfile.close()
        return set_barcodes

    # check the barcode difference between the two sides of the insertion site
    def check_barcode_diff(self, site_chrm, site_pos, iextend_small):
        left_barcode_set = self.get_barcodes_for_region(site_chrm, site_pos - iextend_small, site_pos)
        right_barcode_set = self.get_barcodes_for_region(site_chrm, site_pos, site_pos + iextend_small)
        both_set = left_barcode_set & right_barcode_set
        n_share = len(both_set)
        cnt1 = len(left_barcode_set) - n_share
        cnt2 = len(right_barcode_set) - n_share
        return cnt1 + cnt2, n_share

    ###for this version, pass in the opened file, to avoid too frequency I/O operation
    def get_barcodes_for_region_v2(self, bamfile, chrm, start, end):
        # bamfile = pysam.AlignmentFile(self.sf_bam, "rb")
        set_barcodes = set()
        for alignment in bamfile.fetch(chrm, start, end):
            if alignment.is_duplicate == True or alignment.is_supplementary == True:  ##skip duplicate and supplementary ones
                continue
            if alignment.is_unmapped == True:  #### for now, just skip the unmapped reads ??????????????????????????????
                continue
            if alignment.is_secondary == True:  ##skip secondary alignment
                continue

            if alignment.has_tag('BX') == True:
                s_barcode = alignment.get_tag('BX')
                # change the barcode format from "xxx-1" to "xxx_1"
                set_barcodes.add(self._change_barcode_format(s_barcode))
        # bamfile.close()
        return set_barcodes

    ###for this version, pass in the opened file, to avoid too frequency I/O operation
    # check the barcode difference between the two sides of the insertion site
    def check_barcode_diff_v2(self, bam_file, site_chrm, site_pos, iextend_small):
        left_barcode_set = self.get_barcodes_for_region_v2(bam_file, site_chrm, site_pos - iextend_small, site_pos)
        right_barcode_set = self.get_barcodes_for_region_v2(bam_file, site_chrm, site_pos, site_pos + iextend_small)
        both_set = left_barcode_set & right_barcode_set
        n_share = len(both_set)
        cnt1 = len(left_barcode_set) - n_share
        cnt2 = len(right_barcode_set) - n_share
        return cnt1 + cnt2, n_share

    ###dump the alignmts to a file
    # m_algnmts in format: {barcode: [alignments]}
    def dump_alignments_to_file(self, m_algnmts, sf_out):
        with open(sf_out, 'w') as fout_algnmt:
            for barcode in m_algnmts:
                l_algnmts = m_algnmts[barcode]
                for algnmt in l_algnmts:
                    xalgnmt = XAlignment()
                    s_read = xalgnmt._cvt_algnmt_to_fa(algnmt)
                    fout_algnmt.write(s_read)

    def append_alignments_to_file(self, l_algnmts, fout_algnmt):
        for algnmt in l_algnmts:
            xalgnmt = XAlignment()
            s_read = xalgnmt._cvt_algnmt_to_fa(algnmt)
            fout_algnmt.write(s_read)


####Note: for given alignment, cannot directly use the "alignment.reference_name" field,
####As the reference name can only be accessed when the file is opened.
class XAlignment():
    def _cvt_to_Ascii_quality(self, l_score):
        new_score = [x + 33 for x in l_score]
        return ''.join(map(chr, new_score))

    ###convert an alignment to a fastq record
    ###add the barcode information as comments
    def _cvt_algnmt_to_fq(self, alignmt):
        s_query_name = alignmt.query_name
        if alignmt.is_read1:
            s_query_name += "_1"
        else:
            s_query_name += "_2"
        s_barcode = ""
        if alignmt.has_tag("BX") == True:
            s_barcode = alignmt.get_tag("BX")
        if s_barcode != "":
            s_comments = " BX:{0}".format(s_barcode)
            s_query_name += s_comments

        s_seq = alignmt.query_sequence
        s_quality = self._cvt_to_Ascii_quality(alignmt.query_qualities)

        s_read = "@{0}\n{1}\n+\n{2}\n".format(s_query_name, s_seq, s_quality)
        return s_read

    ###convert an alignment to a fastq record
    ###add the barcode information as comments
    def _cvt_algnmt_to_fa(self, alignmt):
        s_query_name = alignmt.query_name
        if alignmt.is_read1:
            s_query_name += "_1"
        else:
            s_query_name += "_2"
        s_barcode = ""
        if alignmt.has_tag("BX") == True:
            s_barcode = alignmt.get_tag("BX")
        if s_barcode != "":
            s_comments = " BX:{0}".format(s_barcode)
            s_query_name += s_comments

        s_seq = alignmt.query_sequence
        # s_quality = alignmt.query_qualities
        s_read = ">{0}\n{1}\n".format(s_query_name, s_seq)
        return s_read

    # change the barcode format from "xxx-1" to "xxx_1"
    def _change_barcode_format(self, sbarcode):
        fields = sbarcode.split("-")
        return "_".join(fields)

    ####this version doesn't count unmapped readsx
    ##Note: for a pair of reads, both will be counted !!!!!!!!!!!!
    def is_discordant_pair_no_unmap(self, chrm, mate_chrm, template_lth, i_is, f_dev):
        if chrm=="*" or mate_chrm=="*":#doesn't consider unmapped reads
            return False
        if mate_chrm != chrm:  ##map to different chromosomes
            return True
        else:  # map to same chrom, then check the distance
            i_dist = abs(template_lth)
            i_is1 = i_is + 3 * f_dev
            # i_is2 = i_is - 3 * f_dev
            # if i_dist > i_is1 or i_dist < i_is2:
            if i_dist > i_is1:  #############here only consider very far from each other cases (on same chrm)
                return True
        return False

    ##Input: the "algnmt" is "mapped", "non-duplicate" and "non_supplementary"
    ##Return True, if the pair is discordant and cause by TEs
    ##Note: for a pair of reads, both will be counted !!!!!!!!!!!
    def is_TE_caused_discordant_pair(self, chrm, map_pos, mate_chrm, mate_map_pos, xannotation):
        b_within_rep, rep_start = xannotation.is_within_repeat_region(chrm, map_pos)
        b_mate_within_rep, rep_start_mate = xannotation.is_within_repeat_region(mate_chrm, mate_map_pos)

        b_one_read_within_repeat = b_within_rep or b_mate_within_rep  ###one of the read is within repeat region
        b_both_within_repeat = b_within_rep and b_mate_within_rep  ###both two reads are within the repeat region
        return b_one_read_within_repeat, b_both_within_repeat

        ####compare to the current position, how many are mapped to other repeat regions????????
#
####


##This class used to get the chrom, mate_chrm, map_pos from the barcode alignment
# Note, the barcode alignment is coverted from normal 10X alignment by x_coverter.py
class BarcodeAlignment():
    def __init__(self, barcode_alignmt):
        self.barcode_alignmt = barcode_alignmt

    def get_chrm(self):
        if self.barcode_alignmt.has_tag('ch') == False:
            return "*"
        chrm = self.barcode_alignmt.get_tag('ch')
        return str(chrm)

    def get_mate_chrm(self):
        if self.barcode_alignmt.has_tag('nh') == False:
            return "*"
        chrm = self.barcode_alignmt.get_tag('nh')
        return str(chrm)

    def get_map_pos(self):
        if self.barcode_alignmt.has_tag('cp') == False:
            return 0
        map_pos = self.barcode_alignmt.get_tag('cp')
        return int(map_pos)

        # class ContigAlignment():
        #     def __init__(self, sf_alignmt):
        #         self.sf_alignmt=sf_alignmt
        #
####
class OneAlignment():
    def __init__(self, algnmt):
        self.algnmt=algnmt

    def is_full_map(self, min_clip_len):
        l_cigar = self.algnmt.cigar
        if len(l_cigar) < 1:  # wrong alignment
            return False
        if len(l_cigar) == 1 and l_cigar[0][0] == 0:  ##fully mapped
            return True
        if (l_cigar[0][0] == 4 or l_cigar[0][0] == 5) and (l_cigar[0][1]<=min_clip_len):  # left clipped
            return True
        if (l_cigar[-1][0] == 4 or l_cigar[-1][0] == 5) and (l_cigar[-1][1]<=min_clip_len):  # right clipped
            return True
        return False

