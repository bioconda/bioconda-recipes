##11/04/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

import os
from subprocess import *
from optparse import OptionParser


####
def gnrt_script_head(spartition, ncores, stime, smemory):
    s_head = "#!/bin/bash\n\n"
    s_head += "#SBATCH -n {0}\n".format(ncores)
    s_head += "#SBATCH -t {0}\n".format(stime)
    s_head += "#SBATCH --mem={0}G\n".format(smemory)
    s_head += "#SBATCH -p {0}\n".format(spartition)
    s_head += "#SBATCH -o hostname_%j.out\n"
    s_head += "#SBATCH --mail-type=END\n"
    s_head += "#SBATCH --mail-user=chong.simonchu@gmail.com\n"
    if spartition == "park" or spartition == "priopark":
        s_head += "#SBATCH --account=park_contrib\n\n"
    return s_head


# load in the parameter file or the configuration file
def load_par_config(sf_par_config):
    # by default, SF_FLANK is set to null, as Alu no need for SF_FLANK, as we don't check transduction for Alu
    l_pars = []
    with open(sf_par_config) as fin_par_config:
        for line in fin_par_config:
            if len(line) > 0 and line[0] == "#":
                continue
            fields = line.split()
            l_pars.append((fields[0], fields[1]))
    return l_pars


# gnrt pars
def gnrt_parameters(l_pars):
    s_pars = ""
    for rcd in l_pars:
        sid = rcd[0]
        svalue = str(rcd[1])
        sline = sid + "=" + svalue + "\n"
        s_pars += sline
    return s_pars


# grnt calling steps
def gnrt_calling_command(bmit, iclip_c, iclip_rp, idisc_c, iflt_clip, iflt_disc, ncores, iflk_len, min_tei_len, iflag):
    s_mit=""
    if bmit==True:
        s_mit="--mit"

    sclip_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -C -i ${{BAM_LIST}} --lc {0} --rc {1} --cr {2}  " \
                 "-r ${{L1_COPY_WITH_FLANK}}  -a ${{ANNOTATION}} --ref ${{REF}} --cns ${{L1_CNS}} -p ${{TMP}} " \
                 "-o ${{PREFIX}}\"candidate_list_from_clip.txt\" -n {3} {4}\n".format(iclip_c, iclip_c, iclip_rp, ncores, s_mit)
    sdisc_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\"  -D -i ${{PREFIX}}\"candidate_list_from_clip.txt\" --nd {0} " \
                 "--ref ${{REF}} -a ${{ANNOTATION}} -b ${{BAM_LIST}} -p ${{TMP}} " \
                 "-o ${{PREFIX}}\"candidate_list_from_disc.txt\" -n {1} {2}\n".format(idisc_c, ncores, s_mit)
    sbarcode_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -B -i ${{PREFIX}}\"candidate_list_from_disc.txt\" --nb 400 " \
                    "--ref ${{REF}} -a ${{ANNOTATION}} -b ${{BAM1}} -d ${{BARCODE_BAM}} -p ${{TMP}} " \
                    "-o ${{PREFIX}}\"candidate_list_barcode.txt\" -n {0} {1}\n".format(ncores, s_mit)
    sfilter_10x = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -N --cr {0} --nd {1} -b ${{BAM_LIST}} -p ${{TMP_CNS}} " \
                  "--fflank ${{SF_FLANK}} --flklen {2} -n {3} -i ${{PREFIX}}\"candidate_list_barcode.txt\" " \
                  "-r ${{L1_CNS}} --ref ${{REF}} -a ${{ANNOTATION}} " \
                  "-o ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" {4}\n".format(iflt_clip, iflt_disc, iflk_len, ncores, s_mit)
    s_filter = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -N --cr {0} --nd {1} -b ${{BAM_LIST}} -p ${{TMP_CNS}} " \
               "--fflank ${{SF_FLANK}} --flklen {2} -n {3} -i ${{PREFIX}}\"candidate_list_from_disc.txt\" " \
               "-r ${{L1_CNS}} --ref ${{REF}} -a ${{ANNOTATION}} " \
               "-o ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" {4}\n".format(iflt_clip, iflt_disc, iflk_len, ncores, s_mit)
    sf_collect = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -E --nb 500 -b ${{BAM1}} -d ${{BARCODE_BAM}} --ref ${{REF}} " \
                 "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" -p ${{TMP}} -a ${{ANNOTATION}} -n {0} " \
                 "--flklen {1} {2}\n".format(ncores, iflk_len, s_mit)
    sf_asm = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -A -L -p ${{TMP}} --ref ${{REF}} -n {0} " \
             "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" {1}\n".format(ncores, s_mit)
    sf_alg_ctg = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -M -i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" " \
                 "--ref ${{REF}} -n {0} -p ${{TMP}} -r ${{L1_CNS}} " \
                 "-o ${{PREFIX}}\"candidate_list_asm.txt\" {1}\n".format(ncores, s_mit)
    sf_mutation = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -I -p ${{TMP}} -n {0} " \
                  "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" -r ${{L1_CNS}} " \
                  "--teilen {1} -o ${{PREFIX}}\"internal_snp.vcf.gz\" {2}\n".format(ncores, min_tei_len, s_mit)
    sf_gene = "python ${{XTEA_PATH}}\"x_TEA_main.py\" --gene -a ${{GENE}} -i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" " \
              "-o ${{PREFIX}}\"candidate_disc_filtered_cns_with_gene.txt\"\n"
    ####
    s_cmd = ""
    if iflag & 1 == 1:
        s_cmd += sclip_step
    if iflag & 2 == 2:
        s_cmd += sdisc_step
    if iflag & 4 == 4:
        s_cmd += sbarcode_step
    if iflag & 8 == 8:
        s_cmd += sfilter_10x
    if iflag & 16 == 16:
        s_cmd += s_filter
    if iflag & 32 == 32:
        s_cmd += sf_collect
    if iflag & 64 == 64:
        s_cmd += sf_asm
    if iflag & 128 == 128:
        s_cmd += sf_alg_ctg
    if iflag & 256 == 256:
        s_cmd += sf_mutation
    if iflag & 512 == 512:
        s_cmd += sf_gene
    return s_cmd

####

####gnrt the whole pipeline
def gnrt_pipelines(s_head, s_libs, s_calling_cmd, sf_id, sf_bams, sf_bams_10X, sf_working_folder, sf_sbatch_sh):
    if sf_working_folder[-1] != "/":
        sf_working_folder += "/"

    m_id = {}
    with open(sf_id) as fin_id:
        for line in fin_id:
            sid = line.rstrip()
            m_id[sid] = 1
            sf_folder = sf_working_folder + sid  # first creat folder
            if os.path.exists(sf_folder) == True:
                continue
            cmd = "mkdir {0}".format(sf_folder)
            Popen(cmd, shell=True, stdout=PIPE).communicate()
            # create the temporary folders
            cmd = "mkdir {0}".format(sf_folder + "/tmp")
            Popen(cmd, shell=True, stdout=PIPE).communicate()
            cmd = "mkdir {0}".format(sf_folder + "/tmp/clip")
            Popen(cmd, shell=True, stdout=PIPE).communicate()
            cmd = "mkdir {0}".format(sf_folder + "/tmp/cns")
            Popen(cmd, shell=True, stdout=PIPE).communicate()
    m_bams = {}
    if sf_bams != "null":
        with open(sf_bams) as fin_bams:
            for line in fin_bams:
                fields = line.split()
                sid = fields[0]
                s_bam = fields[1]
                m_bams[sid] = s_bam

    m_bams_10X = {}
    if sf_bams_10X != "null":
        with open(sf_bams_10X) as fin_bams_10X:
            for line in fin_bams_10X:
                fields = line.split()
                sid = fields[0]
                if sid not in m_id:
                    continue
                s_bam = fields[1]
                s_barcode_bam = fields[2]
                m_bams_10X[sid] = s_bam

                # soft-link the bams
                sf_10X_bam = sf_working_folder + sid + "/10X_phased_possorted_bam.bam"
                if os.path.isfile(sf_10X_bam) == True:
                    cmd="rm {0}".format(sf_10X_bam)
                    Popen(cmd, shell=True, stdout=PIPE).communicate()
                cmd = "ln -s {0} {1}".format(s_bam, sf_10X_bam)
                print("Run command: {0}\n".format(cmd))
                Popen(cmd, shell=True, stdout=PIPE).communicate()

                sf_10X_barcode_bam = sf_working_folder + sid + "/10X_barcode_indexed.sorted.bam"
                if os.path.isfile(sf_10X_barcode_bam) == True:
                    cmd = "rm {0}".format(sf_10X_barcode_bam)
                    Popen(cmd, shell=True, stdout=PIPE).communicate()
                cmd = "ln -s {0} {1}".format(s_barcode_bam, sf_10X_barcode_bam)
                print("Run command: {0}\n".format(cmd))
                Popen(cmd, shell=True, stdout=PIPE).communicate()
                # soft-link the bai
                sf_10X_bai = sf_working_folder + sid + "/10X_phased_possorted_bam.bam.bai"
                if os.path.isfile(sf_10X_bai) == True:
                    cmd = "rm {0}".format(sf_10X_bai)
                    Popen(cmd, shell=True, stdout=PIPE).communicate()
                cmd = "ln -s {0} {1}".format(s_bam + ".bai", sf_10X_bai)
                print("Run command: {0}\n".format(cmd))
                Popen(cmd, shell=True, stdout=PIPE).communicate()

                sf_10X_barcode_bai = sf_working_folder + sid + "/10X_barcode_indexed.sorted.bam.bai"
                if os.path.isfile(sf_10X_barcode_bai) == True:
                    cmd = "rm {0}".format(sf_10X_barcode_bai)
                    Popen(cmd, shell=True, stdout=PIPE).communicate()
                cmd = "ln -s {0} {1}".format(s_barcode_bam + ".bai", sf_10X_barcode_bai)
                print("Run command: {0}\n".format(cmd))
                Popen(cmd, shell=True, stdout=PIPE).communicate()
                ####
    with open(sf_sbatch_sh, "w") as fout_sbatch:
        fout_sbatch.write("#!/bin/bash\n\n")
        for sid in m_id:
            sf_folder = sf_working_folder + sid + "/"
            if os.path.exists(sf_folder) == False:
                continue

            ####gnrt the bam list file
            sf_bam_list = sf_folder + "bam_list.txt"
            with open(sf_bam_list, "w") as fout_bam_list:
                if sid in m_bams:
                    fout_bam_list.write(m_bams[sid] + "\n")
                if sid in m_bams_10X:
                    fout_bam_list.write(m_bams_10X[sid] + "\n")

            ####gnrt the pipeline file
            sf_out_sh = sf_folder + "run_xTEA_pipeline.sh"
            with open(sf_out_sh, "w") as fout_sh:  ###gnrt the pipeline file
                fout_sh.write(s_head)
                s_prefix = "PREFIX={0}\n".format(sf_folder)
                fout_sh.write(s_prefix)
                fout_sh.write("############\n")
                fout_sh.write("############\n")
                fout_sh.write(s_libs)
                fout_sh.write("############\n")
                fout_sh.write("############\n")
                fout_sh.write(s_calling_cmd)
            ####
            scmd = "sbatch < {0}\n".format(sf_out_sh)
            fout_sbatch.write(scmd)


####
def parse_option():
    parser = OptionParser()
    parser.add_option("-M",
                      action="store_true", dest="mit", default=False,
                      help="Indicate call mitochondrion insertion")
    parser.add_option("-i", "--id", dest="id",
                      help="sample id list file ", metavar="FILE")
    parser.add_option("-a", "--par", dest="parameters",
                      help="parameter file ", metavar="FILE")
    parser.add_option("-l", "--lib", dest="lib",
                      help="TE lib config file ", metavar="FILE")
    parser.add_option("-b", "--bam", dest="bam",
                      help="Input bam file", metavar="FILE")
    parser.add_option("-x", "--x10", dest="x10",
                      help="Input 10X bam file", metavar="FILE")

    parser.add_option("-p", "--path", dest="wfolder", type="string",
                      help="Working folder")
    parser.add_option("-n", "--cores", dest="cores", type="int",
                      help="number of cores")
    parser.add_option("-m", "--memory", dest="memory", type="int",
                      help="Memory limit in GB")
    parser.add_option("-q", "--partition", dest="partition", type="string",
                      help="Which queue to run the job")
    parser.add_option("-t", "--time", dest="time", type="string",
                      help="Time limit")

    parser.add_option("-f", "--flag", dest="flag", type="int",
                      help="Flag indicates which step to run (1-clip, 2-disc, 4-barcode, 8-xfilter, 16-filter, 32-asm)")

    parser.add_option("--flklen", dest="flklen", type="int",
                      help="flank region file")
    parser.add_option("--nclip", dest="nclip", type="int",
                      help="cutoff of minimum # of clipped reads")
    parser.add_option("--cr", dest="cliprep", type="int",
                      help="cutoff of minimum # of clipped reads whose mates map in repetitive regions")
    parser.add_option("--nd", dest="ndisc", type="int",
                      help="cutoff of minimum # of discordant pair")
    parser.add_option("--nfclip", dest="nfilterclip", type="int",
                      help="cutoff of minimum # of clipped reads in filtering step")
    parser.add_option("--nfdisc", dest="nfilterdisc", type="int",
                      help="cutoff of minimum # of discordant pair of each sample in filtering step")
    parser.add_option("--teilen", dest="teilen", type="int",
                      help="minimum length of the insertion for future analysis")

    parser.add_option("-o", "--output", dest="output",
                      help="The output file", metavar="FILE")
    (options, args) = parser.parse_args()
    return (options, args)
####
def cp_file(sf_from, sf_to):
    cmd = "cp {0} {1}".format(sf_from, sf_to)
    if os.path.isfile(sf_from)==False:
        return
    Popen(cmd, shell=True, stdout=PIPE).communicate()

def cp_compress_results(s_wfolder, l_rep_type, sample_id):
    # create a "results" folder
    sf_rslts = s_wfolder + "results/"
    if os.path.exists(sf_rslts)==False:
        cmd = "mkdir {0}".format(sf_rslts)
        Popen(cmd, shell=True, stdout=PIPE).communicate()

    for rep_type in l_rep_type:
        sf_rslts_rep_folder=sf_rslts+rep_type+"/"
        if os.path.exists(sf_rslts_rep_folder)==False:
            cmd = "mkdir {0}".format(sf_rslts_rep_folder)
            Popen(cmd, shell=True, stdout=PIPE).communicate()
        sf_samp_folder=sf_rslts_rep_folder+sample_id+"/"
        if os.path.exists(sf_samp_folder)==False:
            cmd="mkdir {0}".format(sf_samp_folder)
            Popen(cmd, shell=True, stdout=PIPE).communicate()

        sf_source_folder=s_wfolder+rep_type+"/"+sample_id+"/"
        sf_rslt1=sf_source_folder+"candidate_disc_filtered_cns.txt"
        cp_file(sf_rslt1, sf_samp_folder)
        sf_rslt2 = sf_source_folder + "candidate_list_from_clip.txt"
        cp_file(sf_rslt2, sf_samp_folder)
        sf_rslt3 = sf_source_folder + "candidate_list_from_disc.txt"
        cp_file(sf_rslt3, sf_samp_folder)

        s_tmp1=sf_source_folder+"tmp/cns/candidate_sites_all_disc.fa"
        cp_file(s_tmp1, sf_samp_folder)
        s_tmp2 = sf_source_folder + "tmp/cns/candidate_sites_all_clip.fq"
        cp_file(s_tmp2, sf_samp_folder)
        s_tmp3 = sf_source_folder + "tmp/cns/all_with_polymerphic_flanks.fa"
        cp_file(s_tmp3, sf_samp_folder)
    #compress the results folder to one file
    sf_compressed=sf_rslts+"results.tar.gz"
    cmd="tar -cvzf {0} -C {1} .".format(sf_compressed, sf_rslts)
    Popen(cmd, shell=True, stdout=PIPE).communicate()


####
if __name__ == '__main__':
    (options, args) = parse_option()
    b_mit=options.mit #to call mitochondrion insertion
    sf_id = options.id
    sf_bams = options.bam
    sf_bams_10X = options.x10
    s_wfolder = options.wfolder
    sf_sbatch_sh = options.output
    if s_wfolder[-1] != "/":
        s_wfolder += "/"
    if os.path.exists(s_wfolder) == False:
        scmd = "mkdir {0}".format(s_wfolder)
        Popen(scmd, shell=True, stdout=PIPE).communicate()

    if os.path.isfile(sf_bams) == False:
        sf_bams = "null"
    if os.path.isfile(sf_bams_10X) == False:
        sf_bams_10X = "null"

    spartition = options.partition
    ncores = options.cores
    stime = options.time
    smemory = options.memory
    sf_rep_lib = options.lib

    s_head = gnrt_script_head(spartition, ncores, stime, smemory)
    l_libs = load_par_config(sf_rep_lib)
    s_libs = gnrt_parameters(l_libs)

    iclip_c = options.nclip
    iclip_rp = options.cliprep
    idisc_c = options.ndisc
    iflt_clip = options.nfilterclip
    iflt_disc = options.nfilterdisc
    iflk_len = options.flklen
    itei_len = options.teilen
    iflag = options.flag

    s_calling_cmd = gnrt_calling_command(b_mit, iclip_c, iclip_rp, idisc_c, iflt_clip, iflt_disc, ncores, iflk_len,
                                         itei_len, iflag)
    gnrt_pipelines(s_head, s_libs, s_calling_cmd, sf_id, sf_bams, sf_bams_10X, s_wfolder, sf_sbatch_sh)


    # l_rep_type = []
    # l_rep_type.append("L1")
    # l_rep_type.append("Alu")
    # l_rep_type.append("SVA")
    # sample_id="SRR6071681"
    # cp_compress_results(s_wfolder, l_rep_type, sample_id)
    #
####