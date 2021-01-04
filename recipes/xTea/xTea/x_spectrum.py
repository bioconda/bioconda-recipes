####
##08/12/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

#spectrum analysis by tumor type
#input is a list of samples of the same tumor type

import os
import pysam
from optparse import OptionParser
from x_post_filter import *
from bwa_align import *
from global_values import *
from internal_mutation import *
from x_clip_disc_filter import *
from x_basic_info import *

class XSpectrum():
    def __init__(self, sf_reference, sf_wfolder, n_jobs):
        self.sf_reference=sf_reference
        self.REP_LINE_POLYA_START = 5950
        self.FULL_LEN_L1_MAX=7000
        self.basic_info_win=500
        self.disc_bin_size = 20000000  # block size for parallelization

        if len(sf_wfolder)<=0:
            print("Wrong working folder! Now set a ./")
            self.wfolder="./"
        else:
            self.wfolder=sf_wfolder
            if self.wfolder[-1]!="/":
                self.wfolder+="/"
        self.n_jobs=n_jobs
        self.tmp_folder_name="tmp"

    def collect_disc_reads_for_samples(self, sf_sample_ids, sf_bams, sf_rslt_folder, sf_disc_fa, b_force=False):
        if len(sf_rslt_folder)<=0:
            print("Wrong results folder!")
            return
        if sf_rslt_folder[-1] != "/":
            sf_rslt_folder += "/"
        m_bams=self.load_in_case_bams(sf_bams)
        with open(sf_disc_fa, "w") as fout_disc, open(sf_sample_ids) as fin_ids:
            for line in fin_ids:
                sample_id=line.rstrip()#sample id
                s_sample_folder=sf_rslt_folder+sample_id+"/L1/"
                sf_sites=s_sample_folder+"candidate_disc_filtered_cns_high_confident_post_filtering_somatic.txt"
                if os.path.isfile(sf_sites)==False:
                    continue

                if sample_id not in m_bams:
                    print("Sample:{0} doesn't exist!".format(sample_id))
                    continue
                sf_case_bam=m_bams[sample_id]
                sf_tmp_fa=self.collect_disc_reads_one_sample(sf_sites, sample_id, sf_case_bam, b_force)
                #print sf_sites, len(l_cns_fa)
                if os.path.isfile(sf_tmp_fa)==False:
                    print("File {0} doesn't exist!".format(sf_tmp_fa))
                    continue
                with open(sf_tmp_fa) as fin_tmp_disc:
                    for line in fin_tmp_disc:
                        if len(line)<=0:
                            continue
                        if line[0]==">":
                            s_new_line=line.rstrip()+global_values.SEPERATOR+sample_id+"\n"
                            fout_disc.write(s_new_line)
                        else:
                            fout_disc.write(line)
####
    ####this is for population
    def merge_disc_reads_for_population(self, sf_sample_id, sf_xTEA_folder, i_max_dist_from_ins, bmapped_cutoff, sf_disc_fa):
        if len(sf_xTEA_folder)<=0:
            print("Wrong results folder!")
            return
        if sf_xTEA_folder[-1]!="/":
            sf_xTEA_folder+="/"

        with open(sf_disc_fa, "w") as fout_disc, open(sf_sample_id) as fin_ids:
            for line in fin_ids:
                sample_id=line.rstrip()#sample id
                sf_rslt=sf_xTEA_folder+sample_id+"/L1/candidate_disc_filtered_cns.txt.high_confident.post_filtering.txt"
                if os.path.isfile(sf_rslt)==False:
                    print("File {0} does not exist!".format(sf_rslt))
                    continue
                m_sites=self.load_rslt_to_dict(sf_rslt)
                sf_tmp_disc_sam=sf_xTEA_folder+sample_id+"/L1/tmp/cns/temp_disc.sam"
                l_tmp_fa=self._collect_disc_from_germline_bam(sample_id, sf_tmp_disc_sam, m_sites,
                                                              i_max_dist_from_ins, bmapped_cutoff)
                for s_rcd in l_tmp_fa:
                    fout_disc.write(s_rcd)

    def load_rslt_to_dict(self, sf_rslt):
        m_sites={}
        if os.path.isfile(sf_rslt)==False:
            return None
        with open(sf_rslt) as fin_rslt:
            for line in fin_rslt:
                fields=line.split()
                ins_chrm=fields[0]
                ins_pos=int(fields[1])
                if ins_chrm not in m_sites:
                    m_sites[ins_chrm]={}
                m_sites[ins_chrm][ins_pos]=1
        return m_sites


    def align_read_to_cns(self, sf_cns, sf_disc_fa, sf_disc_algnmt):
        bwa_align = BWAlign(global_values.BWA_PATH, global_values.BWA_REALIGN_CUTOFF, self.n_jobs)
        sf_disc_algnmt_tmp=sf_disc_algnmt+".before_calmd"
        bwa_align.realign_disc_reads(sf_cns, sf_disc_fa, sf_disc_algnmt_tmp)
        #process the alignment with "samtools calmd -e "
        bwa_align.calmd_from_algnmt(sf_disc_algnmt_tmp, sf_cns, sf_disc_algnmt)

    def parse_mutation(self, sf_sam, sf_ref, f_mapped_cutoff, sf_mutation):
        im=InternalMutation()
        im.call_snp_indel_from_algnmt(sf_sam, sf_ref, f_mapped_cutoff, sf_mutation)

    def calc_mutation_frequency(self, sf_mut, n_freq_cutoff, sf_slct):
        m_spectrum={}
        m_mut_sample_freq={}
        m_samples={}
        with open(sf_mut) as fin_mut:
            for line in fin_mut:
                fields=line.split()
                pos=int(fields[1])
                if pos not in m_spectrum:
                    m_spectrum[pos]={}
                c_r = fields[2]
                c_q = fields[3]
                if c_q not in {"A","a","C","c","G","g","T","t"}:
                    continue
                s_change=c_r+"_"+c_q
                if s_change not in m_spectrum[pos]:
                    m_spectrum[pos][s_change]=1
                else:
                    m_spectrum[pos][s_change] += 1

                read_info = fields[0]
                read_info_fields = read_info.split(global_values.SEPERATOR)
                ins_chrm = read_info_fields[-3]
                ins_pos = int(read_info_fields[-2])
                sample_id = read_info_fields[-1]
                s_unq_ins_id = "{0}_{1}_{2}".format(ins_chrm, ins_pos, sample_id)
                #for each insertion
                if pos not in m_mut_sample_freq:
                    m_mut_sample_freq[pos]={}
                if s_change not in m_mut_sample_freq[pos]:
                    m_mut_sample_freq[pos][s_change]={}
                m_mut_sample_freq[pos][s_change][s_unq_ins_id]=1
                #for each sample
                if pos not in m_samples:
                    m_samples[pos]={}
                if s_change not in m_samples[pos]:
                    m_samples[pos][s_change]={}
                m_samples[pos][s_change][sample_id]=1

        with open(sf_slct,"w") as fout_slcted:
            for tmp_pos in range(self.FULL_LEN_L1_MAX):#to make sure it is in sorted order
                if tmp_pos in m_spectrum:
                    b_save=False
                    s_save=""
                    for s_change in m_spectrum[tmp_pos]:
                        n_read_cov=m_spectrum[tmp_pos][s_change]
                        n_ins_freq=len(m_mut_sample_freq[tmp_pos][s_change])
                        n_samples=len(m_samples[tmp_pos][s_change])
                        if n_read_cov>n_freq_cutoff:
                            s_type_freq=s_change+":"+str(n_ins_freq)+":"+str(n_samples)+":"+str(n_read_cov)
                            b_save=True
                            s_save+=("\t"+s_type_freq)
                    if b_save==True:
                        fout_slcted.write(str(tmp_pos))
                        fout_slcted.write(s_save+"\n")

####
    #Here n_freq_cutoff is the minimum coverage for each insertion on one site
    def calc_mutation_frequency_by_population(self, sf_mut, n_freq_cutoff, m_pop_info, sf_slct):
        m_mut_sample_freq={}
        with open(sf_mut) as fin_mut:
            for line in fin_mut:
                fields = line.split()
                read_info = fields[0]
                read_info_fields = read_info.split(global_values.SEPERATOR)
                ins_chrm = read_info_fields[-3]
                ins_pos = int(read_info_fields[-2])
                sample_id = read_info_fields[-1]
                s_population = m_pop_info[sample_id]  # population code

                pos = int(fields[1])
                c_r = fields[2]
                c_q = fields[3]
                if c_q not in {"A","a","C","c","G","g","T","t"}:
                    continue
                s_change = c_r + "_" + c_q
                s_unq_ins_id = "{0}_{1}_{2}".format(ins_chrm, ins_pos, sample_id)

                if pos not in m_mut_sample_freq:
                    m_mut_sample_freq[pos] = {}
                if s_population not in m_mut_sample_freq[pos]:
                    m_mut_sample_freq[pos][s_population] = {}
                if s_change not in m_mut_sample_freq[pos][s_population]:
                    m_mut_sample_freq[pos][s_population][s_change] = {}
                if sample_id not in m_mut_sample_freq[pos][s_population][s_change]:
                    m_mut_sample_freq[pos][s_population][s_change][sample_id]={}
                if s_unq_ins_id not in  m_mut_sample_freq[pos][s_population][s_change][sample_id]:
                    m_mut_sample_freq[pos][s_population][s_change][sample_id][s_unq_ins_id] = 0
                m_mut_sample_freq[pos][s_population][s_change][sample_id][s_unq_ins_id] += 1

        with open(sf_slct,"w") as fout_slcted:
            fout_slcted.write("Position,subPopulation,Population,Mutation,nSample,nInsertion\n")
            for tmp_pos in range(self.FULL_LEN_L1_MAX):  # to make sure it is in sorted order
                if tmp_pos in m_mut_sample_freq:
                    for s_tmp_population in m_mut_sample_freq[tmp_pos]:
                        for s_change in m_mut_sample_freq[tmp_pos][s_tmp_population]:
                            n_ins_freq=0
                            m_tmp_sample={}
                            for tmp_sample in m_mut_sample_freq[tmp_pos][s_tmp_population][s_change]:#
                                for s_uniq_ins in m_mut_sample_freq[tmp_pos][s_tmp_population][s_change][tmp_sample]:
                                    n_tmp_freq=m_mut_sample_freq[tmp_pos][s_tmp_population][s_change][tmp_sample][s_uniq_ins]
                                    if n_tmp_freq >= n_freq_cutoff:
                                        n_ins_freq+=1
                                        m_tmp_sample[tmp_sample]=1
                            n_samples = len(m_tmp_sample)
                            if n_samples<=0:
                                continue
                            sinfo=str(tmp_pos)+","+s_tmp_population+","+s_change+","+str(n_samples)\
                                  +","+str(n_ins_freq)
                            fout_slcted.write(sinfo+"\n")


    #Given sites select the high confident ones, and parse out the aligned disc reads to a single file
    def collect_disc_reads_one_sample(self, sf_sites, sample_id, sf_case_bam, b_force=False):####
        xtea_parser = XTEARsltParser()
        l_rcd=xtea_parser.load_in_xTEA_rslt(sf_sites)
        xtprt=XTPRTFilter("tmp", 1)
        #first select the "two_side_tprt_both" sites
        #m_tprt_both={}
        l_slcted=[]
        for rcd in l_rcd:
            #here we only select the insertions not fall in or close to reference copies of the same type
            if xtprt.fall_in_or_close_repetitive_region(rcd)==True:
                continue
            #####
            if xtprt.is_two_side_tprt_and_with_polyA(rcd, self.REP_LINE_POLYA_START)==True:
                #ins_chrm=rcd[0]
                #ins_pos=int(rcd[1])
                # if ins_chrm not in m_tprt_both:
                #     m_tprt_both[ins_chrm]={}
                # m_tprt_both[ins_chrm][ins_pos]=1
                l_slcted.append(rcd)

        sf_slcted=sf_sites+".slcted_spectrum"
        xtea_parser.dump_xTEA_rslt_to_file(l_slcted, sf_slcted)
        sf_disc_fa=self._collect_disc_from_case_bam(sf_slcted, sample_id, sf_case_bam, b_force)
        return sf_disc_fa

    #load in case bams into dict
    def load_in_case_bams(self, sf_bams):
        m_bams={}
        with open(sf_bams) as fin_bams:
            for line in fin_bams:
                fields=line.split()
                sid=fields[0]
                sf_case_bam=fields[1]
                m_bams[sid]=sf_case_bam
        return m_bams

    ####
    def _collect_disc_from_case_bam(self, sf_slcted, sample_id, sf_case_bam, b_force=False):
        #sf_cns_disc_sam=sf_cns_folder+"temp_disc.sam"
        s_wfolder=self.wfolder+self.tmp_folder_name+"/"
        if not os.path.exists(s_wfolder):
            os.makedirs(s_wfolder)
        s_sammple_wfolder=s_wfolder+sample_id+"/"
        if not os.path.exists(s_sammple_wfolder):
            os.makedirs(s_sammple_wfolder)

        xclipdisc=XClipDisc(sf_case_bam, s_sammple_wfolder, self.n_jobs, self.sf_reference)
        sf_clip_fa_tmp=s_sammple_wfolder+"tmp_case_clip.fa"
        sf_disc_fa_tmp=s_sammple_wfolder+"tmp_case_disc.fa"
        if os.path.isfile(sf_disc_fa_tmp)==True and b_force==False:
            return sf_disc_fa_tmp
        x_basic_info = X_BasicInfo(self.wfolder, self.n_jobs, self.sf_reference)
        f_ave_cov, rlth, mean_is, std_var = x_basic_info.collect_basic_info_one_sample(sf_case_bam, self.sf_reference,
                                                                                       self.basic_info_win)
        extnd=int(mean_is)+3*int(std_var)
        xclipdisc.collect_clipped_disc_reads_of_given_list(sf_slcted, extnd, self.disc_bin_size, sf_clip_fa_tmp, sf_disc_fa_tmp)
        return sf_disc_fa_tmp

    ####
    def _collect_disc_from_germline_bam(self, s_sample, sf_cns_disc_sam, m_sites, i_max_dist_from_ins, bmapped_cutoff):
        samfile = pysam.AlignmentFile(sf_cns_disc_sam, "r", reference_filename=self.sf_reference)
        l_fasta=[]
        for algnmt in samfile.fetch():
            if algnmt.is_unmapped == True:####skip the unmapped reads
                continue
            # first check whether read is qualified mapped
            l_cigar = algnmt.cigar
            b_clip_qualified_algned, n_map_bases = self._is_clipped_part_qualified_algnmt(l_cigar, bmapped_cutoff)
            if b_clip_qualified_algned == False:  # skip the unqualified re-aligned parts
                continue

            read_info = algnmt.query_name
            read_info_fields = read_info.split(global_values.SEPERATOR)
            s_anchor_lclip = read_info_fields[-8]  # anchor read is left clip or not: 1 indicates clip
            s_anchor_rclip = read_info_fields[-7]  # anchor read is right clip or not: 1 indicates clip
            s_anchor_rc = read_info_fields[-6]
            s_anchor_mate_rc = read_info_fields[-5]
            anchor_map_pos = int(read_info_fields[-4])  # this is the position of the left-most mapped base
            ins_chrm = read_info_fields[-3]
            ins_pos = int(read_info_fields[-2])
            sample_id = read_info_fields[-1]
            read_seq = algnmt.query_sequence
            s_new_id=global_values.SEPERATOR.join(read_info_fields[:-1])
####
            if self._is_within_range(ins_chrm, ins_pos, m_sites, i_max_dist_from_ins)==True:
                sinfo=">"+s_new_id+global_values.SEPERATOR+s_sample+"\n"+read_seq+"\n"
                l_fasta.append(sinfo)
        samfile.close()
        return l_fasta
####
####
    def _is_within_range(self, ins_chrm, ins_pos, m_sites, iextnd):
        if ins_chrm not in m_sites:
            return False
        i_start=ins_pos-iextnd
        i_end=ins_pos+iextnd
        for tmp_pos in range(i_start, i_end):
            if tmp_pos in m_sites[ins_chrm]:
                return True
        return False

#####same function copied from x_clip_disc_filter.py
    def _is_clipped_part_qualified_algnmt(self, l_cigar, ratio_cutoff):
        if len(l_cigar) < 1:  # wrong alignment
            return False, 0
        if len(l_cigar) > 2:
            ####check the cigar
            ###if both clipped, and the clipped part is large, then skip
            b_left_clip = False
            i_left_clip_len = 0
            if l_cigar[0][0] == 4 or l_cigar[0][0] == 5:  # left clipped
                b_left_clip = True
                i_left_clip_len = l_cigar[0][1]
            b_right_clip = False
            i_right_clip_len = 0
            if l_cigar[-1][0] == 4 or l_cigar[-1][0] == 5:  # right clipped
                b_right_clip = True
                i_right_clip_len = l_cigar[-1][1]

            if b_left_clip == True and b_right_clip == True:
                if (i_left_clip_len > global_values.MAX_CLIP_CLIP_LEN) and (i_right_clip_len > global_values.MAX_CLIP_CLIP_LEN):
                    return False, 0

        ####for the alignment (of the clipped read), if the mapped part is smaller than the clipped part,
        ####then skip
        n_total = 0
        n_map = 0
        for (type, lenth) in l_cigar:
            if type == 0:
                n_map += lenth
            if type != 2:  # deletion is not added to the total length
                n_total += lenth

        if n_map < (n_total * ratio_cutoff):  ########################require at least 3/4 of the seq is mapped !!!!!!!!
            return False, 0
        return True, n_map

    ####
    def load_sample_population_info(self, sf_pop_sample, b_with_head=True):
        m_sample_pop={}
        with open(sf_pop_sample) as fin_pop:
        #Sample name     Sex     Biosample ID    Population code Population name Superpopulation code
            # Superpopulation name    Population elastic ID   Data collections
            for line in fin_pop:
                if b_with_head==True:
                    b_with_head=False
                    continue
                fields=line.rstrip().split("\t")
                s_sample_id=fields[0]
                s_pop_id=fields[3]#Population code
                s_pos=fields[4]
                s_tmp_fields=s_pop_id.split(',')
                s_tmp_fields2=s_pos.split(",")
                m_sample_pop[s_sample_id]=(s_tmp_fields[-1]+","+s_tmp_fields2[-1])
        return m_sample_pop
####

def parse_option():
    parser = OptionParser()
    parser.add_option("-C", "--collect",
                      action="store_true", dest="collect", default=False,
                      help="Collect the discordant reads only")
    parser.add_option("-M", "--merge",
                      action="store_true", dest="merge", default=False,
                      help="Merge reads from xTEA outputs")
    parser.add_option("-S", "--spectrum",
                      action="store_true", dest="spectrum", default=False,
                      help="Construct the spectrum from the alignment")
    parser.add_option("-s", "--spectrum2",
                      action="store_true", dest="spectrum_only", default=False,
                      help="Parse the spectrum only (Assume alignment is done)")
    parser.add_option("-J", "--joint",
                      action="store_true", dest="joint", default=False,
                      help="Joint analysis with different tumor types")

    parser.add_option("-i", "--input", dest="input",
                      help="sample id list file ", metavar="FILE")
    parser.add_option("-b", "--bam", dest="bam",
                      help="Input bam file list", metavar="FILE")
    parser.add_option("-p", "--path", dest="wfolder", type="string",
                      help="Working folder")
    parser.add_option("--rfolder", dest="rfolder", type="string", default="./",
                      help="xTEA output folder")
    parser.add_option("-r", "--ref", dest="reference", type="string",
                      help="reference genome")
    parser.add_option("--type", dest="type", type="string",
                      help="tumor type")
    parser.add_option("--cns", dest="cns", type="string",
                      help="consensus sequence")
    parser.add_option("-n", "--cores", dest="cores", type="int",
                      help="number of cores")
    parser.add_option("-c", "--cutoff", dest="cutoff", type="int",
                      help="minimum mutation frequency cutoff")
    parser.add_option("-o", "--output", dest="output",
                      help="The output file", metavar="FILE")
    parser.add_option("-e", "--extra", dest="extra",
                      help="Extra info file", metavar="FILE")
    parser.add_option("--force", action="store_true", dest="force", default=False,
                      help="Force to start from the very beginning")
    (options, args) = parser.parse_args()
    return (options, args)


if __name__ == '__main__':
    (options, args) = parse_option()
    sf_sample_ids = options.input#

    sf_bams = options.bam  ###bam file list
    s_xTEA_rslt_folder=options.rfolder
    s_wfolder = options.wfolder #current working folder
    if s_wfolder[-1]!="/":
        s_wfolder+="/"
    sf_ref = options.reference #reference genome
    sf_cns=options.cns#consensus sequence
    s_prefix=options.type
    n_cores=options.cores
    n_freq_cutoff=options.cutoff
    b_force = options.force

    xspectrum=XSpectrum(sf_ref, s_wfolder, n_cores)
    f_mapped_cutoff=0.85

    b_merge_population=options.merge
    b_collect=options.collect
    b_spectrum=options.spectrum
    b_spectrum_only=options.spectrum_only
    b_joint=options.joint
    sf_extra_info=options.extra #file for extra info, like the sample-population relationship

    if b_merge_population==True:
        sf_disc_fa = s_wfolder + s_prefix + ".fa"
        sf_disc_algnmt = s_wfolder + s_prefix + ".sam"
        if b_spectrum_only==False:
            i_max_dist_from_ins=50
            xspectrum.merge_disc_reads_for_population(sf_sample_ids, s_xTEA_rslt_folder, i_max_dist_from_ins,
                                                      f_mapped_cutoff, sf_disc_fa)
            xspectrum.align_read_to_cns(sf_cns, sf_disc_fa, sf_disc_algnmt)
        sf_mutation = s_wfolder + s_prefix + ".mutation"
        xspectrum.parse_mutation(sf_disc_algnmt, sf_ref, f_mapped_cutoff, sf_mutation)
        sf_mut_spectrum = s_wfolder + s_prefix + ".spectrum"
        m_pop_info=xspectrum.load_sample_population_info(sf_extra_info)
        xspectrum.calc_mutation_frequency_by_population(sf_mutation, n_freq_cutoff, m_pop_info, sf_mut_spectrum)

    elif b_collect==True:#this is for one sample
        i=1
    elif b_spectrum==True:#without the reads collection step
        sf_disc_fa=s_wfolder+s_prefix+".fa"
        xspectrum.collect_disc_reads_for_samples(sf_sample_ids, sf_bams, s_xTEA_rslt_folder, sf_disc_fa)
        sf_disc_algnmt=s_wfolder+s_prefix+".sam"
        xspectrum.align_read_to_cns(sf_cns, sf_disc_fa, sf_disc_algnmt)
        sf_mutation=s_wfolder+s_prefix+".mutation"
        xspectrum.parse_mutation(sf_disc_algnmt, sf_ref, f_mapped_cutoff, sf_mutation)
        sf_mut_spectrum=s_wfolder+s_prefix+".spectrum"
        xspectrum.calc_mutation_frequency(sf_mutation, n_freq_cutoff, sf_mut_spectrum)
    elif b_joint==True:
        i=1
        sf_list=options.input
        n_sample_cutoff=options.cutoff
    else:
        sf_disc_fa = s_wfolder + s_prefix + ".fa"
        xspectrum.collect_disc_reads_for_samples(sf_sample_ids, sf_bams, s_xTEA_rslt_folder, sf_disc_fa)
        sf_disc_algnmt = s_wfolder + s_prefix + ".sam"
        xspectrum.align_read_to_cns(sf_cns, sf_disc_fa, sf_disc_algnmt)
        sf_mutation = s_wfolder + s_prefix + ".mutation"
        xspectrum.parse_mutation(sf_disc_algnmt, sf_ref, f_mapped_cutoff, sf_mutation)
        sf_mut_spectrum = s_wfolder + s_prefix + ".spectrum"
        xspectrum.calc_mutation_frequency(sf_mutation, n_freq_cutoff, sf_mut_spectrum)
####