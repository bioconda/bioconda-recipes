##11/22/2017
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu
##This is the class for doing local assembly
##Given a set of reads, generate the assembled contig

import os
import sys
import pysam
from subprocess import *
from multiprocessing import Pool
from x_alignments import *
from x_dispatch_jobs import *
from x_contig import *
from x_annotation import *
from x_sites import *
import global_values
from cmd_runner import *

##Function: pool.map doesnt' accept function in the class
##So, use this wrapper to solve this
def unwrap_self_assembly(arg, **kwarg):
    return XLocalAssembly.run_local_assembly(*arg, **kwarg)


class XLocalAssembly():
    def __init__(self, s_working_folder, sf_ref):
        # self.sf_in_vcf=sf_in_vcf
        # self.sf_contig=sf_contig
        self.working_folder = s_working_folder
        if "/" != self.working_folder[-1]:
            self.working_folder[-1] += "/"
        self.reference=sf_ref
        self.cmd_runner = CMD_RUNNER()

    #################################################################################################
    ###main function, including two steps:
    def run_cmd(self, cmd):
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.cmd_runner.run_cmd_small_output(cmd)

    def run_cmd_with_out(self, cmd, sf_out):
        self.cmd_runner.run_cmd_to_file(cmd, sf_out)

    # 2. run local assembly for all candidate sites locally
    ####for hap1, hap2, and unknown, we have 3 different assembly
    def assemble_all_phased_TEIs_locally(self, sf_sites, n_jobs):
        reads_folder = self.working_folder + global_values.READS_FOLDER + "/"
        if os.path.exists(reads_folder) == False:
            return
        asm_folder = self.working_folder + global_values.ASM_FOLDER + "/"
        self._create_folder(asm_folder)
        #self.assemble_collected_phased_reads(reads_folder, sf_sites, n_jobs, asm_folder)
        #in v2 version, only collect reads potentially come from the insertion
        self.assemble_collected_phased_reads_v2(reads_folder, sf_sites, n_jobs, asm_folder)

    # dispatch the assembly jobs on the cluster
    def dispatch_assembly_tasks_on_cluster_phased(self, sf_sites, sf_script):
        # 1. write the code to the script
        scheduler = Job_Scheduler(self.working_folder)
        scheduler.write_jobs_to_scripts_phased(sf_sites)
        scheduler.build_bsub_script(sf_sites, sf_script)

    # (2). run local assembly for all candidate sites on a cluster
    ####for hap1, hap2, and unknown, we have 3 different assembly
    def assemble_all_phased_TEIs_slurm_cluster(self, sf_sites):
        reads_folder = self.working_folder + global_values.READS_FOLDER + "/"
        if os.path.exists(reads_folder) == False:
            return
        asm_folder = self.working_folder + global_values.ASM_FOLDER + "/"
        self._create_folder(asm_folder)
        sf_script = self.working_folder + "run_cluster_asm_phased.sh"
        self.dispatch_assembly_tasks_on_cluster_phased(sf_sites, sf_script)



    def check_process_asm_contig(self, sf_contig):
        b_valid = True
        b_empty_line=False
        if os.path.isfile(sf_contig) == True and os.stat(sf_contig).st_size > 0:
            with open(sf_contig, "rb") as f:
                f.seek(-2, os.SEEK_END)  # Jump to the second last byte.
                while f.read(1) != b"\n":  # Until EOL is found...
                    f.seek(-2, os.SEEK_CUR)  # ...jump back the read byte plus one more.
                last = f.readline()  # Read last line.
                if len(last) > 0 and last[0] == ">":
                    b_valid = False
                if len(last)==0:
                    b_empty_line=True
        if b_valid == False:
            lines = []
            with open(sf_contig) as fin_contig:
                lines = fin_contig.readlines()
            with open(sf_contig, "w") as fout_contig:
                fout_contig.writelines([item for item in lines[:-1]])
        if b_empty_line==True:
            lines = []
            with open(sf_contig) as fin_contig:
                lines = fin_contig.readlines()
            if len(lines)>2:
                with open(sf_contig, "w") as fout_contig:
                    fout_contig.writelines([item for item in lines[:-2]])


    # run the local assembly part
    def run_local_assembly(self, record):
        sf_reads = record[0]
        working_folder = record[1]
        if os.path.exists(sf_reads) == False or os.path.exists(working_folder) == False:
            return
        cmd = "{0} -r {1} -o {2}".format(global_values.IDBA_UD, sf_reads, working_folder)
        #Popen(cmd, shell=True, stdout=PIPE).communicate()
        self.run_cmd(cmd)
        ####Here, need to check the contig.fa, whether it is ended properly, in some cases, the assembler failed,
        # and generate an in-completede contig.fa, which need to be trimmed
        if working_folder[-1] != "/":
            working_folder += "/"
        self.check_process_asm_contig(working_folder + "contig.fa")

    def assemble_collected_reads(self, sf_reads_folder, sf_sites, n_jobs, s_working_folder):
        xsites=XSites(sf_sites)
        m_sites = xsites.load_in_sites()
        l_chrm_records = []
        for chrm in m_sites:
            for pos in m_sites[chrm]:
                sf_reads = sf_reads_folder + "{0}_{1}.fa".format(chrm, pos)
                if os.path.exists(sf_reads) == False:
                    continue
                sf_asm_folder = s_working_folder + "{0}_{1}/".format(chrm, pos)
                self._create_folder(sf_asm_folder)
                l_chrm_records.append((sf_reads, sf_asm_folder))
        pool = Pool(n_jobs)
        pool.map(unwrap_self_assembly, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

    ##assemble the phased reads
    def assemble_collected_phased_reads(self, sf_reads_folder, sf_sites, n_jobs, s_working_folder):
        xsites = XSites(sf_sites)
        m_sites = xsites.load_in_sites()
        l_chrm_records = []
        for chrm in m_sites:
            for pos in m_sites[chrm]:
                sf_asm_folder = s_working_folder + "{0}_{1}/".format(chrm, pos)
                self._create_folder(sf_asm_folder)

                sf_reads_all = sf_reads_folder + "{0}_{1}.fa".format(chrm, pos)
                if os.path.exists(sf_reads_all) == True:
                    sf_asm_folder_all = sf_asm_folder + "{0}/".format(global_values.ALL_HAP)
                    self._create_folder(sf_asm_folder_all)
                    l_chrm_records.append((sf_reads_all, sf_asm_folder_all))

                sf_reads_hap1 = sf_reads_folder + "{0}_{1}_{2}.fa".format(chrm, pos, global_values.HAP1)
                if os.path.exists(sf_reads_hap1) == True:
                    sf_asm_folder_hap1 = sf_asm_folder + "{0}/".format(global_values.HAP1)
                    self._create_folder(sf_asm_folder_hap1)
                    l_chrm_records.append((sf_reads_hap1, sf_asm_folder_hap1))

                sf_reads_hap2 = sf_reads_folder + "{0}_{1}_{2}.fa".format(chrm, pos, global_values.HAP2)
                if os.path.exists(sf_reads_hap2) == True:
                    sf_asm_folder_hap2 = sf_asm_folder + "{0}/".format(global_values.HAP2)
                    self._create_folder(sf_asm_folder_hap2)
                    l_chrm_records.append((sf_reads_hap2, sf_asm_folder_hap2))

                sf_reads_hap_unkown = sf_reads_folder + "{0}_{1}_{2}.fa".format(chrm, pos, global_values.HAP_UNKNOWN)
                if os.path.exists(sf_reads_hap_unkown) == True:
                    sf_asm_folder_hap_unknown = sf_asm_folder + "{0}/".format(global_values.HAP_UNKNOWN)
                    self._create_folder(sf_asm_folder_hap_unknown)
                    l_chrm_records.append((sf_reads_hap_unkown, sf_asm_folder_hap_unknown))

                sf_reads_hap_discord = sf_reads_folder + "{0}_{1}_{2}.fa".format(chrm, pos, global_values.HAP_DISCORD)
                if os.path.exists(sf_reads_hap_discord) == True:
                    sf_asm_folder_hap_disc = sf_asm_folder + "{0}/".format(global_values.HAP_DISCORD)
                    self._create_folder(sf_asm_folder_hap_disc)
                    l_chrm_records.append((sf_reads_hap_discord, sf_asm_folder_hap_disc))

        pool = Pool(n_jobs)
        pool.map(unwrap_self_assembly, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()

    ##assemble the phased reads
    def assemble_collected_phased_reads_v2(self, sf_reads_folder, sf_sites, n_jobs, s_working_folder):
        xsites = XSites(sf_sites)
        m_sites = xsites.load_in_sites()
        l_chrm_records = []
        for chrm in m_sites:
            for pos in m_sites[chrm]:
                sf_asm_folder = s_working_folder + "{0}_{1}/".format(chrm, pos)
                self._create_folder(sf_asm_folder)

                sf_reads_all = sf_reads_folder + "{0}_{1}_{2}.fa".format(chrm, pos, global_values.ALL_HAP_SLCT)
                if os.path.exists(sf_reads_all) == True:
                    sf_asm_folder_all = sf_asm_folder + "{0}/".format(global_values.ALL_HAP)
                    self._create_folder(sf_asm_folder_all)
                    l_chrm_records.append((sf_reads_all, sf_asm_folder_all))

                sf_reads_hap1 = sf_reads_folder + "{0}_{1}_{2}.fa".format(chrm, pos, global_values.HAP1_SLCT)
                if os.path.exists(sf_reads_hap1) == True:
                    sf_asm_folder_hap1 = sf_asm_folder + "{0}/".format(global_values.HAP1)
                    self._create_folder(sf_asm_folder_hap1)
                    l_chrm_records.append((sf_reads_hap1, sf_asm_folder_hap1))

                sf_reads_hap2 = sf_reads_folder + "{0}_{1}_{2}.fa".format(chrm, pos, global_values.HAP2_SLCT)
                if os.path.exists(sf_reads_hap2) == True:
                    sf_asm_folder_hap2 = sf_asm_folder + "{0}/".format(global_values.HAP2)
                    self._create_folder(sf_asm_folder_hap2)
                    l_chrm_records.append((sf_reads_hap2, sf_asm_folder_hap2))

                sf_reads_hap_unkown = sf_reads_folder + "{0}_{1}_{2}.fa".format(chrm, pos, global_values.HAP_UNKNOWN_SLCT)
                if os.path.exists(sf_reads_hap_unkown) == True:
                    sf_asm_folder_hap_unknown = sf_asm_folder + "{0}/".format(global_values.HAP_UNKNOWN)
                    self._create_folder(sf_asm_folder_hap_unknown)
                    l_chrm_records.append((sf_reads_hap_unkown, sf_asm_folder_hap_unknown))

                sf_reads_hap_discord = sf_reads_folder + "{0}_{1}_{2}.fa".format(chrm, pos, global_values.DISC_HAP_SLCT)
                if os.path.exists(sf_reads_hap_discord) == True:
                    sf_asm_folder_hap_disc = sf_asm_folder + "{0}/".format(global_values.HAP_DISCORD)
                    self._create_folder(sf_asm_folder_hap_disc)
                    l_chrm_records.append((sf_reads_hap_discord, sf_asm_folder_hap_disc))

        pool = Pool(n_jobs)
        pool.map(unwrap_self_assembly, list(zip([self] * len(l_chrm_records), l_chrm_records)), 1)
        pool.close()
        pool.join()
    ####
    ####
    def _create_folder(self, s_folder):
        if os.path.exists(s_folder) == False:
            cmd = "mkdir {0}".format(s_folder)
            #Popen(cmd, shell=True, stdout=PIPE).communicate()
            self.run_cmd(cmd)

    # dispatch the assembly jobs on the cluster
    def dispatch_assembly_tasks_on_cluster(self, sf_sites, sf_script):
        # 1. write the code to the script
        scheduler = Job_Scheduler(self.working_folder)
        scheduler.write_jobs_to_scripts(sf_sites)
        scheduler.build_bsub_script(sf_sites, sf_script)
        return


    # 2. run local assembly for all candidate sites locally
    def assemble_all_TEIs_locally(self, sf_sites, n_jobs):
        reads_folder = self.working_folder + global_values.READS_FOLDER + "/"
        if os.path.exists(reads_folder) == False:
            return
        asm_folder = self.working_folder + global_values.ASM_FOLDER + "/"
        self._create_folder(asm_folder)
        self.assemble_collected_reads(reads_folder, sf_sites, n_jobs, asm_folder)

    # (2). run local assembly for all candidate sites on a cluster
    def assemble_all_TEIs_slurm_cluster(self, sf_sites):
        reads_folder = self.working_folder + global_values.READS_FOLDER + "/"
        if os.path.exists(reads_folder) == False:
            return
        asm_folder = self.working_folder + global_values.ASM_FOLDER + "/"
        self._create_folder(asm_folder)
        sf_script = self.working_folder + "run_cluster_asm.sh"
        self.dispatch_assembly_tasks_on_cluster(sf_sites, sf_script)

