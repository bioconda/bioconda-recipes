##11/04/2018
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

import os
from subprocess import *
from optparse import OptionParser
import ntpath

####
PUB_CLIP="pub_clip"
REP_TYPE_L1="L1"
REP_TYPE_ALU="Alu"
REP_TYPE_SVA="SVA"
REP_TYPE_HERV="HERV"
REP_TYPE_MIT="Mitochondrion"
REP_TYPE_MSTA="MSTA"

def gnrt_script_head():
    s_head = "#!/bin/bash\n\n"
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

#define a calling function
# grnt calling steps
def gnrt_calling_command(iclip_c, iclip_rp, idisc_c, iflt_clip, iflt_disc, ncores, iflk_len, min_tei_len, iflag,
                         s_cfolder, b_SVA=False):
    sclip_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -C -i ${{BAM_LIST}} --lc {0} --rc {1} --cr {2}  " \
                 "-r ${{L1_COPY_WITH_FLANK}}  -a ${{ANNOTATION}} --cns ${{L1_CNS}} --ref ${{REF}} -p ${{TMP}} " \
                 "-o ${{PREFIX}}\"candidate_list_from_clip.txt\"  -n {3} --cp {4}\n".format(iclip_c, iclip_c, iclip_rp,
                                                                                            ncores, s_cfolder)
    sdisc_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\"  -D -i ${{PREFIX}}\"candidate_list_from_clip.txt\" --nd {0} " \
                 "--ref ${{REF}} -a ${{ANNOTATION}} -b ${{BAM_LIST}} -p ${{TMP}} " \
                 "-o ${{PREFIX}}\"candidate_list_from_disc.txt\" -n {1}\n".format(idisc_c, ncores)
    sbarcode_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -B -i ${{PREFIX}}\"candidate_list_from_disc.txt\" --nb 400 " \
                    "--ref ${{REF}} -a ${{ANNOTATION}} -b ${{BAM1}} -d ${{BARCODE_BAM}} -p ${{TMP}} " \
                    "-o ${{PREFIX}}\"candidate_list_barcode.txt\" -n {0}\n".format(ncores)
    sfilter_10x = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -N --cr {0} --nd {1} -b ${{BAM_LIST}} -p ${{TMP_CNS}} " \
                  "--fflank ${{SF_FLANK}} --flklen {2} -n {3} -i ${{PREFIX}}\"candidate_list_barcode.txt\" " \
                  "-r ${{L1_CNS}} --ref ${{REF}} -a ${{ANNOTATION}} " \
                  "-o ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(iflt_clip, iflt_disc, iflk_len, ncores)
    if b_SVA==True:
        sfilter_10x = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -N --sva --cr {0} --nd {1} -b ${{BAM_LIST}} -p ${{TMP_CNS}} " \
                      "--fflank ${{SF_FLANK}} --flklen {2} -n {3} -i ${{PREFIX}}\"candidate_list_barcode.txt\" " \
                      "-r ${{L1_CNS}} --ref ${{REF}} -a ${{ANNOTATION}} " \
                      "-o ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(iflt_clip, iflt_disc, iflk_len,
                                                                                   ncores)
    s_filter = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -N --cr {0} --nd {1} -b ${{BAM_LIST}} -p ${{TMP_CNS}} " \
               "--fflank ${{SF_FLANK}} --flklen {2} -n {3} -i ${{PREFIX}}\"candidate_list_from_disc.txt\" " \
               "-r ${{L1_CNS}} --ref ${{REF}} -a ${{ANNOTATION}} " \
               "-o ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(iflt_clip, iflt_disc, iflk_len, ncores)
    if b_SVA == True:
        s_filter = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -N --sva --cr {0} --nd {1} -b ${{BAM_LIST}} -p ${{TMP_CNS}} " \
                   "--fflank ${{SF_FLANK}} --flklen {2} -n {3} -i ${{PREFIX}}\"candidate_list_from_disc.txt\" " \
                   "-r ${{L1_CNS}} --ref ${{REF}} -a ${{ANNOTATION}} " \
                   "-o ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(iflt_clip, iflt_disc, iflk_len, ncores)
    sf_collect = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -E --nb 500 -b ${{BAM1}} -d ${{BARCODE_BAM}} --ref ${{REF}} " \
                 "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" -p ${{TMP}} -a ${{ANNOTATION}} -n {0} " \
                 "--flklen {1}\n".format(ncores, iflk_len)
    sf_asm = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -A -L -p ${{TMP}} --ref ${{REF}} -n {0} " \
             "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(ncores)
    sf_alg_ctg = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -M -i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" " \
                 "--ref ${{REF}} -n {0} -p ${{TMP}} -r ${{L1_CNS}} " \
                 "-o ${{PREFIX}}\"candidate_list_asm.txt\"\n".format(ncores)
    sf_mutation = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -I -p ${{TMP}} -n {0} " \
                  "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" -r ${{L1_CNS}} " \
                  "--teilen {1} -o ${{PREFIX}}\"internal_snp.vcf.gz\"\n".format(ncores, min_tei_len)
    sf_gene = "python ${{XTEA_PATH}}\"x_TEA_main.py\" --gene -a ${{GENE}} -i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" " \
              " -n {0} -o ${{PREFIX}}\"candidate_disc_filtered_cns_with_gene.txt\"\n".format(ncores)
    #sf_clean_tmp = "find ${TMP} -type f -name \'*tmp*\' -delete\n"
    # sf_clean_sam="find ${TMP} -type f -name \'*.sam\' -delete\n"
    # sf_clean_fa="find ${TMP} -type f -name \'*.fa\' -delete\n"
    # sf_clean_fq = "find ${TMP} -type f -name \'*.fq\' -delete\n"

    ####
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
    # s_cmd+=sf_clean_tmp
    # s_cmd +=sf_clean_sam
    # s_cmd +=sf_clean_fa
    # s_cmd +=sf_clean_fq
    return s_cmd


def gnrt_calling_command_non_RNA(iclip_c, iclip_rp, idisc_c, iflt_clip, iflt_disc, ncores, iflk_len, min_tei_len, iflag,
                         s_cfolder):
    sclip_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -C --dna -i ${{BAM_LIST}} --lc {0} --rc {1} --cr {2}  " \
                 "-r ${{L1_COPY_WITH_FLANK}}  -a ${{ANNOTATION}} --cns ${{L1_CNS}} --ref ${{REF}} -p ${{TMP}} " \
                 "-o ${{PREFIX}}\"candidate_list_from_clip.txt\"  -n {3} --cp {4}\n".format(iclip_c, iclip_c, iclip_rp,
                                                                                            ncores, s_cfolder)
    sdisc_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\"  -D --dna  -i ${{PREFIX}}\"candidate_list_from_clip.txt\" --nd {0} " \
                 "--ref ${{REF}} -a ${{ANNOTATION}} -b ${{BAM_LIST}} -p ${{TMP}} " \
                 "-o ${{PREFIX}}\"candidate_list_from_disc.txt\" -n {1}\n".format(idisc_c, ncores)
    sbarcode_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -B --dna  -i ${{PREFIX}}\"candidate_list_from_disc.txt\" --nb 400 " \
                    "--ref ${{REF}} -a ${{ANNOTATION}} -b ${{BAM1}} -d ${{BARCODE_BAM}} -p ${{TMP}} " \
                    "-o ${{PREFIX}}\"candidate_list_barcode.txt\" -n {0}\n".format(ncores)
    sfilter_10x = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -N --dna  --cr {0} --nd {1} -b ${{BAM_LIST}} -p ${{TMP_CNS}} " \
                  "--fflank ${{SF_FLANK}} --flklen {2} -n {3} -i ${{PREFIX}}\"candidate_list_barcode.txt\" " \
                  "-r ${{L1_CNS}} --ref ${{REF}} -a ${{ANNOTATION}} " \
                  "-o ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(iflt_clip, iflt_disc, iflk_len, ncores)
    s_filter = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -N --dna  --cr {0} --nd {1} -b ${{BAM_LIST}} -p ${{TMP_CNS}} " \
               "--fflank ${{SF_FLANK}} --flklen {2} -n {3} -i ${{PREFIX}}\"candidate_list_from_disc.txt\" " \
               "-r ${{L1_CNS}} --ref ${{REF}} -a ${{ANNOTATION}} " \
               "-o ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(iflt_clip, iflt_disc, iflk_len, ncores)
    sf_collect = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -E --dna  --nb 500 -b ${{BAM1}} -d ${{BARCODE_BAM}} --ref ${{REF}} " \
                 "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" -p ${{TMP}} -a ${{ANNOTATION}} -n {0} " \
                 "--flklen {1}\n".format(ncores, iflk_len)
    sf_asm = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -A -L --dna  -p ${{TMP}} --ref ${{REF}} -n {0} " \
             "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(ncores)
    sf_alg_ctg = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -M --dna -i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" " \
                 "--ref ${{REF}} -n {0} -p ${{TMP}} -r ${{L1_CNS}} " \
                 "-o ${{PREFIX}}\"candidate_list_asm.txt\"\n".format(ncores)
    sf_mutation = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -I --dna -p ${{TMP}} -n {0} " \
                  "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" -r ${{L1_CNS}} " \
                  "--teilen {1} -o ${{PREFIX}}\"internal_snp.vcf.gz\"\n".format(ncores, min_tei_len)
    sf_gene = "python ${{XTEA_PATH}}\"x_TEA_main.py\" --gene --dna -a ${{GENE}} -i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" " \
              " -n {0} -o ${{PREFIX}}\"candidate_disc_filtered_cns_with_gene.txt\"\n".format(ncores)
    #sf_clean_tmp = "find ${TMP} -type f -name \'*tmp*\' -delete\n"
    # sf_clean_sam="find ${TMP} -type f -name \'*.sam\' -delete\n"
    # sf_clean_fa="find ${TMP} -type f -name \'*.fa\' -delete\n"
    # sf_clean_fq = "find ${TMP} -type f -name \'*.fq\' -delete\n"

    ####
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
    # s_cmd+=sf_clean_tmp
    # s_cmd +=sf_clean_sam
    # s_cmd +=sf_clean_fa
    # s_cmd +=sf_clean_fq
    return s_cmd

def gnrt_calling_command_MT(iclip_c, iclip_rp, idisc_c, iflt_clip, iflt_disc, ncores, iflk_len, min_tei_len, iflag,
                         s_cfolder):
    sclip_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -C --mit --dna -i ${{BAM_LIST}} --lc {0} --rc {1} --cr {2}  " \
                 "-r ${{L1_COPY_WITH_FLANK}}  -a ${{ANNOTATION}} --cns ${{L1_CNS}} --ref ${{REF}} -p ${{TMP}} " \
                 "-o ${{PREFIX}}\"candidate_list_from_clip.txt\"  -n {3} --cp {4}\n".format(iclip_c, iclip_c, iclip_rp,
                                                                                            ncores, s_cfolder)
    sdisc_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\"  -D --mit --dna  -i ${{PREFIX}}\"candidate_list_from_clip.txt\" --nd {0} " \
                 "--ref ${{REF}} -a ${{ANNOTATION}} -b ${{BAM_LIST}} -p ${{TMP}} " \
                 "-o ${{PREFIX}}\"candidate_list_from_disc.txt\" -n {1}\n".format(idisc_c, ncores)
    sbarcode_step = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -B --mit --dna -i ${{PREFIX}}\"candidate_list_from_disc.txt\" --nb 400 " \
                    "--ref ${{REF}} -a ${{ANNOTATION}} -b ${{BAM1}} -d ${{BARCODE_BAM}} -p ${{TMP}} " \
                    "-o ${{PREFIX}}\"candidate_list_barcode.txt\" -n {0}\n".format(ncores)
    sfilter_10x = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -N --mit --dna --cr {0} --nd {1} -b ${{BAM_LIST}} -p ${{TMP_CNS}} " \
                  "--fflank ${{SF_FLANK}} --flklen {2} -n {3} -i ${{PREFIX}}\"candidate_list_barcode.txt\" " \
                  "-r ${{L1_CNS}} --ref ${{REF}} -a ${{ANNOTATION}} " \
                  "-o ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(iflt_clip, iflt_disc, iflk_len, ncores)
    s_filter = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -N --mit --dna --cr {0} --nd {1} -b ${{BAM_LIST}} -p ${{TMP_CNS}} " \
               "--fflank ${{SF_FLANK}} --flklen {2} -n {3} -i ${{PREFIX}}\"candidate_list_from_disc.txt\" " \
               "-r ${{L1_CNS}} --ref ${{REF}} -a ${{ANNOTATION}} " \
               "-o ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(iflt_clip, iflt_disc, iflk_len, ncores)
    sf_collect = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -E --mit --dna --nb 500 -b ${{BAM1}} -d ${{BARCODE_BAM}} --ref ${{REF}} " \
                 "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" -p ${{TMP}} -a ${{ANNOTATION}} -n {0} " \
                 "--flklen {1}\n".format(ncores, iflk_len)
    sf_asm = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -A -L --mit --dna -p ${{TMP}} --ref ${{REF}} -n {0} " \
             "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\"\n".format(ncores)
    sf_alg_ctg = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -M --mit --dna -i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" " \
                 "--ref ${{REF}} -n {0} -p ${{TMP}} -r ${{L1_CNS}} " \
                 "-o ${{PREFIX}}\"candidate_list_asm.txt\"\n".format(ncores)
    sf_mutation = "python ${{XTEA_PATH}}\"x_TEA_main.py\" -I --mit --dna -p ${{TMP}} -n {0} " \
                  "-i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" -r ${{L1_CNS}} " \
                  "--teilen {1} -o ${{PREFIX}}\"internal_snp.vcf.gz\"\n".format(ncores, min_tei_len)
    sf_gene = "python ${{XTEA_PATH}}\"x_TEA_main.py\" --gene --mit --dna -a ${{GENE}} -i ${{PREFIX}}\"candidate_disc_filtered_cns.txt\" " \
              " -n {0} -o ${{PREFIX}}\"candidate_disc_filtered_cns_with_gene.txt\"\n".format(ncores)

    #sf_clean_tmp = "find ${TMP} -type f -name \'*tmp*\' -delete\n"
    # sf_clean_sam="find ${TMP} -type f -name \'*.sam\' -delete\n"
    # sf_clean_fa="find ${TMP} -type f -name \'*.fa\' -delete\n"
    # sf_clean_fq = "find ${TMP} -type f -name \'*.fq\' -delete\n"

    ####
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
    # s_cmd+=sf_clean_tmp
    # s_cmd +=sf_clean_sam
    # s_cmd +=sf_clean_fa
    # s_cmd +=sf_clean_fq
    return s_cmd
####

####gnrt the whole pipeline
def gnrt_pipelines(s_head, s_libs, s_calling_cmd, sf_id, sf_bams, sf_bams_10X, sf_root_folder, rep_type, sf_sbatch_sh):
    sf_working_folder=sf_root_folder+rep_type
    if sf_working_folder[-1] != "/":
        sf_working_folder += "/"

    m_id = {}
    with open(sf_id) as fin_id:
        for line in fin_id:
            sid = line.rstrip()
            m_id[sid] = 1

            sf_folder = sf_working_folder
            if os.path.exists(sf_folder)==False:
                cmd = "mkdir {0}".format(sf_folder)
                run_cmd(cmd)
            # create the temporary folders
            sf_tmp=sf_folder + "/tmp"
            if os.path.exists(sf_tmp)==False:
                cmd = "mkdir {0}".format(sf_tmp)
                run_cmd(cmd)
            sf_tmp_clip=sf_folder + "/tmp/clip"
            if os.path.exists(sf_tmp_clip)==False:
                cmd = "mkdir {0}".format(sf_tmp_clip)
                run_cmd(cmd)
            sf_tmp_cns=sf_folder + "/tmp/cns"
            if os.path.exists(sf_tmp_cns)==False:
                cmd = "mkdir {0}".format(sf_tmp_cns)
                run_cmd(cmd)
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
                sf_10X_bam = sf_working_folder + "10X_phased_possorted_bam.bam"
                if os.path.isfile(sf_10X_bam) == False:
                    cmd = "ln -s {0} {1}".format(s_bam, sf_10X_bam)
                    run_cmd(cmd)

                sf_10X_barcode_bam = sf_working_folder + "10X_barcode_indexed.sorted.bam"
                if os.path.isfile(sf_10X_barcode_bam) == False:
                    cmd = "ln -s {0} {1}".format(s_barcode_bam, sf_10X_barcode_bam)  #
                    run_cmd(cmd)
                # soft-link the bai
                sf_10X_bai = sf_working_folder + "10X_phased_possorted_bam.bam.bai"
                if os.path.isfile(sf_10X_bai) == False:
                    cmd = "ln -s {0} {1}".format(s_bam + ".bai", sf_10X_bai)
                    run_cmd(cmd)

                sf_10X_barcode_bai = sf_working_folder + "10X_barcode_indexed.sorted.bam.bai"
                if os.path.isfile(sf_10X_barcode_bai) == False:
                    cmd = "ln -s {0} {1}".format(s_barcode_bam + ".bai", sf_10X_barcode_bai)
                    run_cmd(cmd)
                    ####
    with open(sf_sbatch_sh, "w") as fout_sbatch:
        fout_sbatch.write("#!/bin/bash\n\n")
        for sid in m_id:
            sf_folder = sf_working_folder
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
            scmd = "sh {0}\n".format(sf_out_sh)
            fout_sbatch.write(scmd)


def write_to_config(sf_anno, sf_ref, sf_gene, sf_copy_with_flank, sf_flank, sf_cns, sf_xtea, s_bl, s_bam1, s_bc_bam,
                    s_tmp, s_tmp_clip, s_tmp_cns, sf_config):
    with open(sf_config, "w") as fout_L1:
        fout_L1.write(sf_anno)
        fout_L1.write(sf_ref)
        fout_L1.write(sf_gene)
        fout_L1.write(sf_copy_with_flank)
        fout_L1.write(sf_flank)
        fout_L1.write(sf_cns)
        fout_L1.write(sf_xtea)
        fout_L1.write(s_bl)
        fout_L1.write(s_bam1)
        fout_L1.write(s_bc_bam)
        fout_L1.write(s_tmp)
        fout_L1.write(s_tmp_clip)
        fout_L1.write(s_tmp_cns)

#generate library configuration files
def gnrt_lib_config(l_rep_type, sf_folder_rep, sf_ref, sf_gene, sf_folder_xtea, sf_config_prefix):
    if sf_folder_rep[-1] != "/":
        sf_folder_rep += "/"
    if sf_folder_xtea[-1] != "/":
        sf_folder_xtea += "/"
    if sf_config_prefix[-1] != "/":
        sf_config_prefix += "/"

    s_bl = "BAM_LIST ${PREFIX}\"bam_list.txt\"\n"
    s_bam1 = "BAM1 ${PREFIX}\"10X_phased_possorted_bam.bam\"\n"
    s_bc_bam = "BARCODE_BAM ${PREFIX}\"10X_barcode_indexed.sorted.bam\"\n"
    s_tmp = "TMP ${PREFIX}\"tmp/\"\n"
    s_tmp_clip = "TMP_CLIP ${PREFIX}\"tmp/clip/\"\n"
    s_tmp_cns = "TMP_CNS ${PREFIX}\"tmp/cns/\"\n"
    sf_ref = "REF " + sf_ref + "\n"
    sf_xtea = "XTEA_PATH " + sf_folder_xtea + "\n"
    sf_gene_anno = "GENE " + sf_gene + "\n"

    for s_rep_type in l_rep_type:
        if s_rep_type=="L1":# for L1
            sf_config_L1 = sf_config_prefix + "L1.config"
            sf_anno = "ANNOTATION " + sf_folder_rep + "LINE/hg19/hg19_L1_larger500_with_all_L1HS.out\n"
            sf_copy_with_flank = "L1_COPY_WITH_FLANK " + sf_folder_rep + "LINE/hg19/hg19_L1HS_copies_larger_5K_with_flank.fa\n"
            sf_flank = "SF_FLANK " + sf_folder_rep + "LINE/hg19/hg19_FL_L1_flanks_3k.fa\n"
            sf_cns = "L1_CNS " + sf_folder_rep + "consensus/LINE1.fa\n"
            write_to_config(sf_anno, sf_ref, sf_gene_anno, sf_copy_with_flank, sf_flank, sf_cns, sf_xtea, s_bl, s_bam1, s_bc_bam,
                            s_tmp, s_tmp_clip, s_tmp_cns, sf_config_L1)
        elif s_rep_type=="Alu":#### for Alu
            sf_config_Alu = sf_config_prefix + "Alu.config"
            sf_anno = "ANNOTATION " + sf_folder_rep + "Alu/hg19/hg19_Alu.out\n"
            sf_copy_with_flank = "L1_COPY_WITH_FLANK " + sf_folder_rep + "Alu/hg19/hg19_AluJabc_copies_with_flank.fa\n"
            sf_flank = "SF_FLANK null\n"
            sf_cns = "L1_CNS " + sf_folder_rep + "consensus/ALU.fa\n"
            write_to_config(sf_anno, sf_ref, sf_gene_anno, sf_copy_with_flank, sf_flank, sf_cns, sf_xtea, s_bl, s_bam1, s_bc_bam,
                            s_tmp, s_tmp_clip, s_tmp_cns, sf_config_Alu)
        elif s_rep_type=="SVA":####for SVA
            sf_config_SVA = sf_config_prefix + "SVA.config"
            sf_anno = "ANNOTATION " + sf_folder_rep + "SVA/hg19/hg19_SVA.out\n"
            sf_copy_with_flank = "L1_COPY_WITH_FLANK " + sf_folder_rep + "SVA/hg19/hg19_SVA_copies_with_flank.fa\n"
            sf_flank = "SF_FLANK " + sf_folder_rep + "SVA/hg19/hg19_FL_SVA_flanks_3k.fa\n"
            sf_cns = "L1_CNS " + sf_folder_rep + "consensus/SVA.fa\n"
            write_to_config(sf_anno, sf_ref, sf_gene_anno, sf_copy_with_flank, sf_flank, sf_cns, sf_xtea, s_bl, s_bam1, s_bc_bam,
                            s_tmp, s_tmp_clip, s_tmp_cns, sf_config_SVA)
        elif s_rep_type=="HERV":####HERV
            sf_config_HERV = sf_config_prefix + "HERV.config"
            sf_anno = "ANNOTATION " + sf_folder_rep + "HERV/hg19/hg19_HERV.out\n"
            sf_copy_with_flank = "L1_COPY_WITH_FLANK " + sf_folder_rep + "HERV/hg19/hg19_HERV_copies_with_flank.fa\n"
            sf_flank = "SF_FLANK null\n"
            sf_cns = "L1_CNS " + sf_folder_rep + "consensus/HERV.fa\n"
            write_to_config(sf_anno, sf_ref, sf_copy_with_flank, sf_flank, sf_cns, sf_xtea, s_bl, s_bam1, s_bc_bam,
                            s_tmp, s_tmp_clip, sf_gene_anno, s_tmp_cns, sf_config_HERV)
        elif s_rep_type=="MSTA":####MSTA
            sf_config_HERV = sf_config_prefix + "MSTA.config"
            sf_anno = "ANNOTATION " + sf_folder_rep + "MSTA/hg19/hg19_MSTA.out\n"
            sf_copy_with_flank = "L1_COPY_WITH_FLANK " + sf_folder_rep + "MSTA/hg19/hg19_MSTA_copies_with_flank.fa\n"
            sf_flank = "SF_FLANK null\n"
            sf_cns = "L1_CNS " + sf_folder_rep + "consensus/MSTA.fa\n"
            write_to_config(sf_anno, sf_ref, sf_copy_with_flank, sf_flank, sf_cns, sf_xtea, s_bl, s_bam1, s_bc_bam,
                            s_tmp, s_tmp_clip, sf_gene_anno, s_tmp_cns, sf_config_HERV)
        elif s_rep_type=="Mitochondrion":####for Mitochondrion
            sf_config_Mitochondrion = sf_config_prefix + "Mitochondrion.config"
            sf_anno = "ANNOTATION " + sf_folder_rep + "Mitochondrion/hg19/hg19_numtS.out\n"
            sf_copy_with_flank = "L1_COPY_WITH_FLANK " + sf_folder_rep +\
                                 "Mitochondrion/hg19/hg19_mitochondrion_copies_with_flank.fa\n"
            sf_flank = "SF_FLANK null\n"
            sf_cns = "L1_CNS " + sf_folder_rep + "consensus/mitochondrion.fa\n"
            write_to_config(sf_anno, sf_ref, sf_copy_with_flank, sf_flank, sf_cns, sf_xtea, s_bl, s_bam1, s_bc_bam,
                            s_tmp, s_tmp_clip, sf_gene_anno, s_tmp_cns, sf_config_Mitochondrion)

####
def parse_option():
    parser = OptionParser()
    parser.add_option("-D", "--decompress",
                      action="store_true", dest="decompress", default=False,
                      help="Decompress the rep lib and reference file")
    parser.add_option("-i", "--id", dest="id",
                      help="sample id list file ", metavar="FILE")
    parser.add_option("-a", "--par", dest="parameters",
                      help="parameter file ", metavar="FILE")
    parser.add_option("-l", "--lib", dest="lib",
                      help="TE lib config file ", metavar="FILE")
    parser.add_option("-b", "--bam", dest="bam",
                      help="Input bam file", metavar="FILE")

    parser.add_option("-p", "--path", dest="wfolder", type="string",
                      help="Working folder")
    parser.add_option("-n", "--cores", dest="cores", type="int",
                      help="number of cores")
    parser.add_option("-r", "--ref", dest="ref", type="string",
                      help="reference genome")
    parser.add_option("-g", "--gene", dest="gene", type="string",
                      help="Gene annotation file")
    parser.add_option("-x", "--xtea", dest="xtea", type="string",
                      help="xTEA folder")

    parser.add_option("-f", "--flag", dest="flag", type="int",
                      help="Flag indicates which step to run (1-clip, 2-disc, 4-barcode, 8-xfilter, 16-filter, 32-asm)")

    parser.add_option("-y", "--reptype", dest="rep_type", type="int",
                      help="Type of repeats working on: 1-L1, 2-Alu, 4-SVA, 8-HERV, 16-Mitochondrial")

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

def cp_file(sf_from, sf_to):
    cmd = "cp {0} {1}".format(sf_from, sf_to)
    if os.path.isfile(sf_from)==False:
        return
    run_cmd(cmd)

def run_cmd(cmd):
    print(cmd)
    Popen(cmd, shell=True, stdout=PIPE).communicate()

def get_sample_id(sf_bam):
    fname = ntpath.basename(sf_bam)
    fname_fields = fname.split(".")
    if fname_fields[-1] != "bam" and fname_fields[-1] != "cram":
        print("Alignment is not end with .bam")
        return None
    sample_id = ".".join(fname_fields[:-1])
    return sample_id

####gnrt the running shell
def gnrt_running_shell(l_rep_type, sf_bam, s_wfolder, ncores, sf_folder_rep, sf_ref, sf_gene, sf_folder_xtea):
    if s_wfolder[-1] != "/":
        s_wfolder += "/"
    if os.path.exists(s_wfolder) == False:
        scmd = "mkdir {0}".format(s_wfolder)
        Popen(scmd, shell=True, stdout=PIPE).communicate()

    fname=ntpath.basename(sf_bam)
    fname_fields=fname.split(".")
    if fname_fields[-1]!="bam" and fname_fields[-1]!="cram":
        print("Alignment is not end with .bam")
        return

    #get the sample_id
    sample_id=".".join(fname_fields[:-1])
    #first create the sample-id folder
    sf_sample_folder=s_wfolder+sample_id+"/"
    sf_pub_clip = sf_sample_folder + PUB_CLIP + "/"
    if os.path.exists(sf_sample_folder)==False:
        cmd = "mkdir {0}".format(sf_sample_folder)
        run_cmd(cmd)
        #also create the public clip folder
        cmd = "mkdir {0}".format(sf_pub_clip)
        run_cmd(cmd)

    #gnrt the sample id list
    sf_id=sf_sample_folder+"sample_id.txt"
    with open(sf_id, "w") as fout_id:
        fout_id.write(sample_id)
    # gnrt the bam file list
    sf_bam_list=sf_sample_folder+"bam_list.txt"
    with open(sf_bam_list,"w") as fout_bamlist:
        fout_bamlist.write(sample_id+"\t"+sf_bam)

    gnrt_lib_config(l_rep_type, sf_folder_rep, sf_ref, sf_gene, sf_folder_xtea, sf_sample_folder)

    for rep_type in l_rep_type:
        sf_config = sf_sample_folder+rep_type+".config"

        #s_wfolder_rep=s_wfolder+rep_type
        s_wfolder_rep = sf_sample_folder + rep_type
        if os.path.exists(s_wfolder_rep)==False:
            cmd="mkdir {0}".format(s_wfolder_rep)
            run_cmd(cmd)

        s_head = gnrt_script_head()
        l_libs = load_par_config(sf_config)
        s_libs = gnrt_parameters(l_libs)
        ##
        iclip_c = options.nclip
        iclip_rp = options.cliprep
        idisc_c = options.ndisc
        iflt_clip = options.nfilterclip
        iflt_disc = options.nfilterdisc
        iflk_len = options.flklen
        itei_len = options.teilen
        iflag = options.flag

        s_calling_cmd = gnrt_calling_command(iclip_c, iclip_rp, idisc_c, iflt_clip, iflt_disc, ncores, iflk_len,
                                             itei_len, iflag, sf_pub_clip)
        if rep_type is REP_TYPE_SVA:
            s_calling_cmd = gnrt_calling_command(iclip_c, iclip_rp, idisc_c, iflt_clip, iflt_disc, ncores, iflk_len,
                                                 itei_len, iflag, sf_pub_clip, True)
        if rep_type is REP_TYPE_MSTA or rep_type is REP_TYPE_HERV:
            s_calling_cmd=gnrt_calling_command_non_RNA(iclip_c, iclip_rp, idisc_c, iflt_clip, iflt_disc, ncores, iflk_len,
                                             itei_len, iflag, sf_pub_clip)
        elif rep_type is REP_TYPE_MIT:
            s_calling_cmd = gnrt_calling_command_MT(iclip_c, iclip_rp, idisc_c, iflt_clip, iflt_disc, ncores, iflk_len,
                                             itei_len, iflag, sf_pub_clip)

        sf_sbatch_sh_rep=sf_sample_folder + "run_{0}.sh".format(rep_type)
        gnrt_pipelines(s_head, s_libs, s_calling_cmd, sf_id, sf_bam_list, sf_bams_10X, sf_sample_folder, rep_type,
                       sf_sbatch_sh_rep)

####run the pipelines
def run_pipeline(l_rep_type, sample_id, s_wfolder):
    for rep_type in l_rep_type:
        sf_sbatch_sh_rep = s_wfolder + sample_id + "/run_{0}.sh".format(rep_type)
        cmd="sh {0}".format(sf_sbatch_sh_rep)
        run_cmd(cmd)

def decompress(sf_in_tar, sf_out):
    cmd="tar -zxvf {0} -C {1}".format(sf_in_tar, sf_out)
    run_cmd(cmd)

def cp_compress_results(s_wfolder, l_rep_type, sample_id):
    # create a "results" folder
    sf_rslts = s_wfolder + "results/"
    if os.path.exists(sf_rslts)==False:
        cmd = "mkdir {0}".format(sf_rslts)
        run_cmd(cmd)

    for rep_type in l_rep_type:
        sf_rslts_rep_folder=sf_rslts+rep_type+"/"
        if os.path.exists(sf_rslts_rep_folder)==False:
            cmd = "mkdir {0}".format(sf_rslts_rep_folder)
            run_cmd(cmd)
        sf_samp_folder = sf_rslts_rep_folder + sample_id + "/"
        if os.path.exists(sf_samp_folder)==False:
            cmd="mkdir {0}".format(sf_samp_folder)
            run_cmd(cmd)

        sf_source_folder=s_wfolder+sample_id+"/"+rep_type+"/"
        # sf_rslt0 = sf_source_folder + "candidate_disc_filtered_cns_with_gene.txt"
        # cp_file(sf_rslt0, sf_samp_folder)
        sf_rslt1=sf_source_folder+"candidate_disc_filtered_cns.txt"
        cp_file(sf_rslt1, sf_samp_folder)
        sf_rslt2 = sf_source_folder + "candidate_list_from_clip.txt"
        cp_file(sf_rslt2, sf_samp_folder)
        sf_rslt2_1 = sf_source_folder + "candidate_list_from_clip.txt_tmp"
        cp_file(sf_rslt2_1, sf_samp_folder)
        sf_rslt3 = sf_source_folder + "candidate_list_from_disc.txt"
        cp_file(sf_rslt3, sf_samp_folder)
        sf_rslt4 = sf_source_folder + "candidate_disc_filtered_cns.txt.before_filtering"
        cp_file(sf_rslt4, sf_samp_folder)
        sf_rslt5 = sf_source_folder + "candidate_disc_filtered_cns.txt.gntp.features"
        cp_file(sf_rslt5, sf_samp_folder)
        sf_rslt6 = sf_source_folder + "candidate_disc_filtered_cns.txt.high_confident"
        cp_file(sf_rslt6, sf_samp_folder)
        sf_rslt7 = sf_source_folder + "candidate_disc_filtered_cns.txt.before_calling_transduction.sites_cov"
        cp_file(sf_rslt7, sf_samp_folder)

        # s_tmp1=sf_source_folder+"tmp/cns/candidate_sites_all_disc.fa"
        # cp_file(s_tmp1, sf_samp_folder)
        # s_tmp2 = sf_source_folder + "tmp/cns/candidate_sites_all_clip.fq"
        # cp_file(s_tmp2, sf_samp_folder)

        s_tmp_info = sf_source_folder + "tmp/basic_cov_is_rlth_info.txt"
        cp_file(s_tmp_info, sf_samp_folder)
        s_tmp_log = sf_source_folder + "tmp/cns/filtering_log.txt"
        cp_file(s_tmp_log, sf_samp_folder)

        s_tmp1=sf_source_folder+"tmp/cns/temp_disc.sam"
        cp_file(s_tmp1, sf_samp_folder)
        s_tmp2 = sf_source_folder + "tmp/cns/temp_clip.sam"
        cp_file(s_tmp2, sf_samp_folder)
        s_tmp3 = sf_source_folder + "tmp/cns/all_with_polymerphic_flanks.fa"
        cp_file(s_tmp3, sf_samp_folder)
        s_tmp4 = sf_source_folder + "tmp/clip_reads_tmp0"
        cp_file(s_tmp4, sf_samp_folder)
        s_tmp5 = sf_source_folder + "tmp/discordant_reads_tmp0"
        cp_file(s_tmp5, sf_samp_folder)

    #compress the results folder to one file
    sf_compressed=s_wfolder+"results.tar.gz"
    cmd="tar -cvzf {0} -C {1} .".format(sf_compressed, sf_rslts)
    run_cmd(cmd)
####
####
if __name__ == '__main__':
    (options, args) = parse_option()
    sf_bam = options.bam ###input is a bam file
    sf_bams_10X = "null"
    s_wfolder = options.wfolder

    wf_fields=s_wfolder.split("/")
    if len(wf_fields)>=1 and wf_fields[0]==".":
        s_wfolder=os.getcwd()+"/"+"/".join(wf_fields[1:])
    if s_wfolder[-1]!="/":
        s_wfolder+="/"

    ncores = options.cores
    sf_folder_rep1 = options.lib  ##this is the lib folder path
    sf_ref1=options.ref ####reference genome
    sf_folder_xtea=options.xtea

    sf_folder_rep=sf_folder_rep1
    sf_ref=sf_ref1
    if options.decompress==True:
        decompress(sf_folder_rep1, s_wfolder)
        decompress(sf_ref1, s_wfolder)
        sf_folder_rep = s_wfolder+"rep_lib_annotation/" #trim tar.gz
        sf_ref=s_wfolder+"genome.fa"
    sf_gene = "null"

    i_rep_type=options.rep_type
    l_rep_type = []
    if i_rep_type & 1 != 0:
        l_rep_type.append(REP_TYPE_L1)
    if i_rep_type & 2 != 0:
        l_rep_type.append(REP_TYPE_ALU)
    if i_rep_type & 4 != 0:
        l_rep_type.append(REP_TYPE_SVA)
    if i_rep_type & 8 != 0:
        l_rep_type.append(REP_TYPE_HERV)
    if i_rep_type & 16 != 0:
        l_rep_type.append(REP_TYPE_MIT)
    if i_rep_type & 32 != 0:
        l_rep_type.append(REP_TYPE_MSTA)

    sample_id=get_sample_id(sf_bam)
    gnrt_running_shell(l_rep_type, sf_bam, s_wfolder, ncores, sf_folder_rep, sf_ref, sf_gene, sf_folder_xtea)
    run_pipeline(l_rep_type, sample_id, s_wfolder)

    cp_compress_results(s_wfolder, l_rep_type, sample_id)

####