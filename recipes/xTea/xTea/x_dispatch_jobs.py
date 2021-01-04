import os
import sys
from subprocess import *

#This is designed for 10X assembly step only, where genome assembly takes time.
#This module will speed up the assembly steps

IDBA_UD = "idba_ud"
MINIMAP2 = 'minimap2'
READS_FOLDER = "reads_fa"
CMD_FOLDER = "command"
ASM_FOLDER = "asm_contig"
CMD_ASM_SUFFIX = "asm"
HAP1='hap1'
HAP2='hap2'
HAP_UNKNOWN='hap_unknown'
ALL_HAP='all_hap'
HAP_DISCORD='hap_discord'

####
class Job_Scheduler():
    def __init__(self, s_working_folder):
        self.working_folder = s_working_folder
        if self.working_folder[-1] != "/":
            self.working_folder += "/"
        self.cmd_folder = self.working_folder + CMD_FOLDER + "/"
        self.read_folder = self.working_folder + READS_FOLDER + "/"
        self.asm_folder = self.working_folder + ASM_FOLDER + "/"
        if os.path.exists(self.cmd_folder) == False:
            self._create_folder(self.cmd_folder)
        if os.path.exists(self.read_folder) == False:
            self._create_folder(self.read_folder)
        if os.path.exists(self.asm_folder) == False:
            self._create_folder(self.asm_folder)

    def _create_folder(self, s_folder):
        if os.path.exists(s_folder) == False:
            cmd = "mkdir {0}".format(s_folder)
            Popen(cmd, shell=True, stdout=PIPE).communicate()

    def _load_sites(self, sf_sites):
        m_sites = {}
        with open(sf_sites) as fin_sites:  # load in sites
            for line in fin_sites:
                fields = line.split()
                chrm = fields[0]
                pos = int(fields[1])
                if chrm not in m_sites:
                    m_sites[chrm] = {}
                if pos not in m_sites[chrm]:
                    m_sites[chrm][pos] = 1
        return m_sites

    def gnrt_assembly_script(self, chrm, pos):
        """
        Generate a single sh script for the "IDBA_UD" command for one position
        """
        sf_reads = self.read_folder + "{0}_{1}.fa".format(chrm, pos)
        #sf_reads = self.read_folder + "chr{0}_{1}.fa".format(chrm, pos)  ####for temporary usage!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if os.path.exists(sf_reads) == False:  # make sure the reads file exists
            return

        ##also make sure output folder exist
        output_folder = self.asm_folder + "{0}_{1}".format(chrm, pos)
        self._create_folder(output_folder)

        write_list = ['#!/bin/bash']
        cmd = "{0} -r {1} -o {2}".format(IDBA_UD, sf_reads, output_folder)
        write_list.append(cmd)

        sf_cmd = "{0}{1}_{2}_{3}.sh".format(self.cmd_folder, chrm, pos, CMD_ASM_SUFFIX)
        self.write_out(sf_cmd, write_list)

    def gnrt_assembly_script_phased(self, chrm, pos):
        """
        Generate a single sh script for the "IDBA_UD" command for one position
        """
        sf_reads_all=self.read_folder + "{0}_{1}.fa".format(chrm, pos)
        sf_reads_hap1 = self.read_folder + "{0}_{1}_{2}.fa".format(chrm, pos, HAP1)
        sf_reads_hap2 = self.read_folder + "{0}_{1}_{2}.fa".format(chrm, pos, HAP2)
        sf_reads_hap_unknown = self.read_folder + "{0}_{1}_{2}.fa".format(chrm, pos, HAP_UNKNOWN)
        sf_reads_hap_discord = self.read_folder + "{0}_{1}_{2}.fa".format(chrm, pos, HAP_DISCORD)

        ##also make sure output folder exist
        output_folder=self.asm_folder + "{0}_{1}/".format(chrm, pos)
        self._create_folder(output_folder)
        output_folder_all = self.asm_folder + "{0}_{1}/{2}/".format(chrm, pos, ALL_HAP)
        self._create_folder(output_folder_all)
        output_folder_hap1 = self.asm_folder + "{0}_{1}/{2}/".format(chrm, pos, HAP1)
        self._create_folder(output_folder_hap1)
        output_folder_hap2 = self.asm_folder + "{0}_{1}/{2}/".format(chrm, pos, HAP2)
        self._create_folder(output_folder_hap2)
        output_folder_hap_unknown = self.asm_folder + "{0}_{1}/{2}/".format(chrm, pos, HAP_UNKNOWN)
        self._create_folder(output_folder_hap_unknown)
        output_folder_hap_discord=self.asm_folder + "{0}_{1}/{2}/".format(chrm, pos, HAP_DISCORD)

        write_list = ['#!/bin/bash']
        if os.path.isfile(sf_reads_all)==True:
            cmd = "{0} -r {1} -o {2}".format(IDBA_UD, sf_reads_all, output_folder_all)
            write_list.append(cmd)
        if os.path.isfile(sf_reads_hap1)==True:
            cmd = "{0} -r {1} -o {2}".format(IDBA_UD, sf_reads_hap1, output_folder_hap1)
            write_list.append(cmd)
        if os.path.isfile(sf_reads_hap2)==True:
            cmd = "{0} -r {1} -o {2}".format(IDBA_UD, sf_reads_hap2, output_folder_hap2)
            write_list.append(cmd)
        if os.path.isfile(sf_reads_hap_unknown)==True:
            cmd = "{0} -r {1} -o {2}".format(IDBA_UD, sf_reads_hap_unknown, output_folder_hap_unknown)
            write_list.append(cmd)
        if os.path.isfile(sf_reads_hap_discord)==True:
            cmd = "{0} -r {1} -o {2}".format(IDBA_UD, sf_reads_hap_discord, output_folder_hap_discord)
            write_list.append(cmd)

        sf_cmd = "{0}{1}_{2}_{3}.sh".format(self.cmd_folder, chrm, pos, CMD_ASM_SUFFIX)
        self.write_out(sf_cmd, write_list)


    def write_out(self, filename, w_list):
        with open(filename, 'w') as f:
            for line in w_list:
                f.write(line + '\n')

    def write_jobs_to_scripts(self, sf_sites):
        m_sites = self._load_sites(sf_sites)

        # 1. for each site, first generate a single shell scripts
        for chrm in m_sites:
            for pos in m_sites[chrm]:
                self.gnrt_assembly_script(chrm, pos)

    def write_jobs_to_scripts_phased(self, sf_sites):
        m_sites = self._load_sites(sf_sites)
        # 1. for each site, first generate a single shell scripts
        for chrm in m_sites:
            for pos in m_sites[chrm]:
                self.gnrt_assembly_script_phased(chrm, pos)


    def build_sbatch_script(self, sf_sites, sf_script):
        m_sites = self._load_sites(sf_sites)
        l_jobs = ['#!/bin/bash']
        for chrm in m_sites:
            for pos in m_sites[chrm]:
                sf_cmd = "{0}{1}_{2}_{3}.sh".format(self.cmd_folder, chrm, pos, CMD_ASM_SUFFIX)
                sbatch_cmd = "sbatch --mem=5G --partition=short --time=0-00:30:00 -o hostname_%j.out {0}".format(sf_cmd)
                l_jobs.append(sbatch_cmd)
        self.write_out(sf_script, l_jobs)

    def build_bsub_script(self, sf_sites, sf_script):
        m_sites = self._load_sites(sf_sites)
        l_jobs = ['#!/bin/bash']
        for chrm in m_sites:
            for pos in m_sites[chrm]:
                sf_cmd = "{0}{1}_{2}_{3}.sh".format(self.cmd_folder, chrm, pos, CMD_ASM_SUFFIX)
                s_mem='"rusage[mem=3000]"'
                sbatch_cmd = "bsub -q park_short -n 1 -W 00:45  -o %j.out -R {0} {1}".format(s_mem, sf_cmd)
                l_jobs.append(sbatch_cmd)
        self.write_out(sf_script, l_jobs)

#
# 2.for each site, sbatch each command chrm by chrm
#
