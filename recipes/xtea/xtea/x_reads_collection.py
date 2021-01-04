##09/05/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

import os, errno
import sys
import pysam
from subprocess import *
from multiprocessing import Pool
from x_alignments import *
from x_annotation import *
from x_sites import *
import global_values


def unwrap_self_collect_phased_reads(arg, **kwarg):
    return XReadsCollection.run_collect_phased_reads_for_one_chrm_v2(*arg, **kwarg)


class XReadsCollection():
    def __init__(self, s_working_folder, sf_ref):
        self.working_folder = s_working_folder
        if "/" != self.working_folder[-1]:
            self.working_folder[-1] += "/"
        self.reference = sf_ref

    ###main function, including two steps:
    # 1. collect phased reads for each site
    # Note: "i_extend" is the range to extend for collecting barcode
    ###### "i_cov_cutoff" is the barcode coverage cutoff
    ###### "sf_annotation" is the annotation file for the specific TE
    ###### "iflank_extd": extend each copy when we decide whether a read falls in the TE region or not
    def collect_phased_reads_all_TEIs(self, sf_bam, sf_barcode_bam, sf_sites, i_extend, i_cov_cutoff,
                                      sf_annotation, iflank_extd, n_jobs):
        reads_folder = self.working_folder + global_values.READS_FOLDER + "/"
        self._create_folder(reads_folder)
        self.collect_phased_reads(sf_bam, sf_barcode_bam, sf_sites, i_extend, i_cov_cutoff,
                                  sf_annotation, iflank_extd, n_jobs, reads_folder)

    def collect_phased_reads(self, sf_bam, sf_barcode_bam, sf_sites, i_extend, i_cov_cutoff,
                             sf_annotation, iflank_extd, n_jobs, working_folder):
        xsites = XSites(sf_sites)
        m_sites = xsites.load_in_sites()
        l_chrm_records = []
        for chrm in m_sites:
            record = (chrm, sf_bam, sf_barcode_bam, sf_sites, i_extend, i_cov_cutoff,
                      sf_annotation, iflank_extd, working_folder)
            l_chrm_records.append(record)
            #self.run_collect_phased_reads_for_one_chrm_v2(record)
        pool = Pool(n_jobs)
        pool.map(unwrap_self_collect_phased_reads, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()
####
    # This version will seperate the reads by "Haplotype1", "Haplotype2" and "unknown"
    ###this version, do not save all the alignments in the memory,
    # but only alignments of each barcode, and save to file on the fly
    def run_collect_phased_reads_for_one_chrm_v2(self, record):
        site_chrm = record[0]
        sf_bam = record[1]
        sf_barcode_bam = record[2]
        sf_sites = record[3]
        i_extend = int(record[4])
        i_cov = int(record[5])
        sf_annotation = record[6]
        iflank_extd = int(record[7])
        working_folder = record[8]
        if working_folder[-1] != "/":
            working_folder += "/"

        xbam = XBamInfo(sf_bam, sf_barcode_bam, self.reference)
        bamfile = xbam.open_bam_file(sf_bam)  ##open bam file
        barcode_bamfile = xbam.open_bam_file(sf_barcode_bam)  ##open barcode bam file
        xsites = XSites(sf_sites)
        m_sites = xsites.load_in_sites()
        b_with_chr = xbam.is_chrm_contain_chr()
        m_chrms = xbam.get_all_reference_names()
        chrm = xbam.process_chrm_name(site_chrm, b_with_chr)  ###convert to make sure chrm is consistent
        if chrm not in m_chrms:
            return

        # load in the annotation file
        xannotation = XAnnotation(sf_annotation)
        xannotation.set_with_chr(b_with_chr)
        xannotation.load_rmsk_annotation_with_divgnt_extnd(iflank_extd)
        xannotation.index_rmsk_annotation()

        for pos in m_sites[site_chrm]:
            if pos < i_extend:
                continue
            ##note, each alignment in the converted format
            set_hap1, set_hap2, set_unknown, set_discord = xbam.parse_phased_barcodes_for_one_site(bamfile, chrm, pos,
                                                                                                   i_extend, i_cov)
            set_all = set()
            if set_hap1 is not None:
                set_all = (set_all | set_hap1)
            if set_hap2 is not None:
                set_all = (set_all | set_hap2)
            if set_unknown is not None:
                set_all = (set_all | set_unknown)
            if set_all is None:
                continue

            # then creat the new files
            sf_out_file = working_folder + "{0}_{1}.fa".format(site_chrm, pos)
            sf_out_file_hap1 = working_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.HAP1)
            sf_out_file_hap2 = working_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.HAP2)
            sf_out_file_hap_unknown = working_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.HAP_UNKNOWN)
            sf_out_file_discord = working_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.HAP_DISCORD)
            ####for calling internal mutations

            sf_out_hap1_slct = working_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.HAP1_SLCT)
            sf_out_hap2_slct = working_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.HAP2_SLCT)
            sf_out_hap_unknown_slct = working_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.HAP_UNKNOWN_SLCT)
            sf_out_hap_all_slct = working_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.ALL_HAP_SLCT)
            sf_out_hap_disc_slct= working_folder + "{0}_{1}_{2}.fa".format(site_chrm, pos, global_values.DISC_HAP_SLCT)
            # first clean the old files, this is required, because need to append to files in the following steps
            self.silentremove(sf_out_file)
            self.silentremove(sf_out_file_hap1)
            self.silentremove(sf_out_file_hap2)
            self.silentremove(sf_out_file_hap_unknown)
            self.silentremove(sf_out_file_discord)
            self.silentremove(sf_out_hap1_slct)
            self.silentremove(sf_out_hap2_slct)
            self.silentremove(sf_out_hap_unknown_slct)
            self.silentremove(sf_out_hap_all_slct)
            self.silentremove(sf_out_hap_disc_slct)

            f_out_all = open(sf_out_file, "a")
            f_out_hap1 = open(sf_out_file_hap1, "a")
            f_out_hap2 = open(sf_out_file_hap2, "a")
            f_out_unknown = open(sf_out_file_hap_unknown, "a")
            f_out_disc = open(sf_out_file_discord, "a")
            f_out_hap1_slct = open(sf_out_hap1_slct, "a")
            f_out_hap2_slct = open(sf_out_hap2_slct, "a")
            f_out_hap_unknown_slct = open(sf_out_hap_unknown_slct, "a")
            f_out_all_slct = open(sf_out_hap_all_slct, "a")
            f_out_disc_slct=open(sf_out_hap_disc_slct, "a")

            for sbarcode in set_all:
                l_alignmts = xbam.get_alignments_for_one_barcode(barcode_bamfile, sbarcode)
                xbam.append_alignments_to_file(l_alignmts, f_out_all)

                # here select the ones possibly originated from the L1 insertion
                ####
                # print chrm #############################################################################################
                iflank=i_extend
                l_picked_algnmts = self.filter_out_unique_non_related_algnmts(l_alignmts, global_values.UNIQUE_MAP_CUTOFF,
                                                                              chrm, pos, xannotation, iflank)
                xbam.append_alignments_to_file(l_picked_algnmts, f_out_all_slct)
                if set_hap1 is not None and sbarcode in set_hap1:
                    xbam.append_alignments_to_file(l_alignmts, f_out_hap1)
                    xbam.append_alignments_to_file(l_picked_algnmts, f_out_hap1_slct)
                if set_hap2 is not None and sbarcode in set_hap2:
                    xbam.append_alignments_to_file(l_alignmts, f_out_hap2)
                    xbam.append_alignments_to_file(l_picked_algnmts, f_out_hap2_slct)
                if set_unknown is not None and sbarcode in set_unknown:
                    xbam.append_alignments_to_file(l_alignmts, f_out_unknown)
                    xbam.append_alignments_to_file(l_picked_algnmts, f_out_hap_unknown_slct)
                if set_discord is not None and sbarcode in set_discord:
                    xbam.append_alignments_to_file(l_alignmts, f_out_disc)
                    xbam.append_alignments_to_file(l_picked_algnmts, f_out_disc_slct)

            f_out_all.close()
            f_out_hap1.close()
            f_out_hap2.close()
            f_out_unknown.close()
            f_out_disc.close()
            f_out_hap1_slct.close()
            f_out_hap2_slct.close()
            f_out_hap_unknown_slct.close()
            f_out_all_slct.close()
            f_out_disc_slct.close()

    # this function will filter out those unique (>cutoff_mapq) mapped reads
    # also filter out those fall in regions outside of the annotation
    def filter_out_unique_non_related_algnmts(self, l_algnmts, cutoff_mapq, chrm, ins_pos, x_annotation, iflank):
        l_after_filtering = []
        for alignment in l_algnmts:
            if alignment.is_duplicate == True or alignment.is_supplementary == True:  ##skip duplicate and supplemty ones
                continue
            if alignment.is_unmapped == True:  #### for now, just skip the unmapped reads ????????????????????????????
                continue
            if alignment.is_secondary == True:  ##skip secondary alignment
                continue

            b_filter_out = False
            # here check the map-position, if fall in the repeat regions, if not then filter out
            # Note, this is barcode-indexed bam, the original map position is at "" field
            bcd_algnmt = BarcodeAlignment(alignment)
            map_pos = bcd_algnmt.get_map_pos()
            # # filter out not mapped to repetitive region reads
            # b_hit, i_idx = x_annotation.is_within_repeat_region(chrm, map_pos)
            # if b_hit == False:
            #     b_filter_out = True

            # filter out unique mapped reads
            mapq = alignment.mapping_quality
            if mapq >= cutoff_mapq:
                b_filter_out = True

            # Keep those map to flank regions
            if (map_pos >= (ins_pos - iflank) and map_pos <= ins_pos) or \
                    (map_pos >= ins_pos and map_pos <= (ins_pos + iflank)):
                b_filter_out = False

            if b_filter_out == False:
                l_after_filtering.append(alignment)
        return l_after_filtering


    #
    def silentremove(self, filename):
        try:
            os.remove(filename)
        except OSError as e:  # this would be "except OSError, e:" before Python 2.6
            if e.errno != errno.ENOENT:  # errno.ENOENT = no such file or directory
                raise  # re-raise exception if a different error occurred

    def _create_folder(self, s_folder):
        if os.path.exists(s_folder) == False:
            cmd = "mkdir {0}".format(s_folder)
            Popen(cmd, shell=True, stdout=PIPE).communicate()
