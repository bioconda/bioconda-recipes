#!/usr/bin/env python3

"""
compare the output hgt and ground truth,
to evaluate our tool.
"""

import os
import numpy as np
import re
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
import random
import sys
from collections import Counter, defaultdict
from datetime import datetime
from simulation import Parameters
from generate_run_scripts import Batch
from scipy.optimize import curve_fit

tolerate_dist = 50
ref_gap = 50

class Read_bed(object):
    def __init__(self):
        self.true_interval = {}
        self.gap = ref_gap
        self.ref_len = 0

    def read(self, interval_file):
        if os.path.isfile(interval_file):
            f = open(interval_file)
            for line in f:
                line = line.strip()
                if line == '':
                    continue
                chr_name = line.split(":")[0]
                start = int(line.split(":")[1].split("-")[0])
                end = int(line.split(":")[1].split("-")[1])   
                self.ref_len += (end - start)
                self.add(chr_name, start, end)  
            f.close()   
        else:
            print ("cannot find", interval_file)

    def add(self, chr_name, start, end):
        if chr_name in self.true_interval:
            self.true_interval[chr_name].append([start, end])
        else:
            self.true_interval[chr_name] = [[start, end]]

    def search(self, true_locus):
        if true_locus[0] not in self.true_interval:
            return False
        else:
            for true in self.true_interval[true_locus[0]]:
                start = true[0]
                end = true[1]
                if int(true_locus[1]) > start + self.gap and int(true_locus[1]) < end - self.gap:
                    return True
            return False

def check_if_bkp_in_extracted_ref(true, interval_file):
    bed_obj = Read_bed()
    bed_obj.read(interval_file)

    all_pos = read_all_frag(true)
    i = 0
    for single_locus in all_pos:
        if bed_obj.search(single_locus):
            i += 1
            # print ('Have ref:', true_locus)
        else:
            print ('Lack ref:', single_locus)
    return round(float(i)/len(all_pos),2), bed_obj.ref_len

def read_all_frag(true):
    all_pos = []
    for line in open(true):
            array = line.strip().split()
            all_pos.append([array[0], array[1]])
            all_pos.append([array[2], array[3]])
            all_pos.append([array[2], array[4]])

    return all_pos

def read_true(true):
    true_bkp, true_event = [], []
    for line in open(true):
            array = line.strip().split()
            true_bkp.append([array[0], array[1], array[2], array[3]])
            true_bkp.append([array[0], array[1], array[2], array[4]])
            true_event.append(array)
    return true_bkp, true_event

def read_lemon(lemon):
    lemon_bkp = []
    past = ['', '', '', '']
    for line in open(lemon):
        array = line.strip().split(',')
        if array[0] == "from_ref": #skip the annotation line
            continue
        if '_'.join(array[:4]) == '_'.join(past):
            continue
        lemon_bkp.append(array[:4])
        past = array[:4]
    return lemon_bkp

def read_localHGT(lemon, abun_cutoff, deep_flag=False):
    lemon_bkp = []
    past = ['', '', '', '']
    for line in open(lemon):
        if line[0] == "#":
            reads_num = int(line.split(";")[0].split(":")[1])
            continue
        array = line.strip().split(',')
        if array[0] == "from_ref": #skip the annotation line
            continue
        from_ref = array[0]
        from_pos = int(array[1])
        to_ref = array[4]
        to_pos = int(array[5])

        cross_split_reads = int(array[14]) # filter BKPs
        if cross_split_reads/reads_num < abun_cutoff:
            continue
        if deep_flag:
            if "_".join(from_ref.split("_")[:-1]) == "_".join(to_ref.split("_")[:-1]):
                continue

        lemon_bkp.append([from_ref, from_pos, to_ref, to_pos])
    return lemon_bkp

def get_pure_genome(genome):
    return "_".join(genome.split("_")[:-1])

def compare(true_bkp, our_bkp):
    right = 0
    error = 0
    correct_result_num = 0
    for true in true_bkp:
        identified = False
        for our in our_bkp:
            if true[0] == our[0] and true[2] == our[2] and abs(int(true[1])-int(our[1]))\
                < tolerate_dist and abs(int(true[3])-int(our[3])) < tolerate_dist:
                right += 1
                identified = True
                break
            elif true[0] == our[2] and true[2] == our[0] and abs(int(true[1])-int(our[3]))\
                < tolerate_dist and abs(int(true[3])-int(our[1])) < tolerate_dist:
                right += 1
                identified = True
                break
        if identified == False:
            print ("Missed bkp:", true) 
    accuracy = right/len(true_bkp)
    recall = accuracy

    #find false positive locus
    false_positive_locus = []
    for true in our_bkp:
        identified = False
        for our in true_bkp:
            if true[0] == our[0] and true[2] == our[2] and abs(int(true[1])-int(our[1]))\
                < tolerate_dist and abs(int(true[3])-int(our[3])) < tolerate_dist:
                    right += 1
                    identified = True
                    break
            elif true[0] == our[2] and true[2] == our[0] and abs(int(true[1])-int(our[3]))\
                < tolerate_dist and abs(int(true[3])-int(our[1])) < tolerate_dist:
                    right += 1
                    identified = True
                    break
        if not identified:
            false_positive_locus.append(true)
            # print ("False bkp:", true)
    if len(our_bkp) > 0:
        FDR = len(false_positive_locus)/len(our_bkp)
    else:
        FDR = 0
    precision = 1-FDR
    if precision > 0 and recall > 0:
        F1_score = 2/((1/precision) + (1/recall)) 
    else:
        F1_score = 0
    return round(accuracy,2), round(FDR,2), round(F1_score,2)#, false_positive_locus

class Performance():
    def __init__(self, accuracy, FDR, tool_time, tool_mem, F1_score, complexity):
        self.accuracy = accuracy
        self.FDR = FDR
        self.user_time = tool_time
        self.max_mem = tool_mem
        self.ref_accuracy = 0
        self.ref_len = 0
        self.F1_score = F1_score
        self.complexity = complexity
        self.filterd_bkp_num = 0

    def add_ref(self, ref_accuracy, ref_len):
        self.ref_accuracy = ref_accuracy
        self.ref_len = ref_len

def extract_time(time_file): #log file obtained by /usr/bin/time -v
        #if no time available
    if os.path.isfile(time_file):
        for line in open(time_file):
            time_re = re.search('User time \(seconds\):(.*?)$', line)
            if time_re:
                user_time =  time_re.group(1).strip()

            time_sys = re.search('System time \(seconds\):(.*?)$', line)
            if time_sys:
                sys_time = time_sys.group(1).strip()
        # print (user_time, sys_time)
        all_time = float(user_time) + float(sys_time)
        final_time = round(all_time/3600, 2)
        return final_time
    else:
        return None

def extract_wall_clock_time(time_file): #log file obtained by /usr/bin/time -v
        #if no time available
    for line in open(time_file):
        time_re = re.search('Elapsed \(wall clock\) time \(h:mm:ss or m:ss\):(.*?)$', line)
        if time_re:
            wall_block_time = time_re.group(1).strip()
    array = wall_block_time.split(":")
    hours = int(array[0].strip()) + float(array[1].strip())/60
    return hours

def extract_mem(time_file):
    used_mem = 0 #if no time available
    for line in open(time_file):
        time_re = re.search('Maximum resident set size \(kbytes\):(.*?)$', line)
        if time_re:
            used_mem =  time_re.group(1).strip()
    final_mem = round(float(used_mem)/1000000, 2)
    return final_mem

class Sample():
    def __init__(self, ID, true_dir):
        self.ID = ID
        true_ID = self.get_true(ID)
        self.true_file = true_dir + '/' + true_ID + '.true.sv.txt'
        if os.path.isfile(self.true_file):
            self.true_bkp, self.true_event = read_true(self.true_file)
        else:
            print ("cannot find", self.true_file)
        self.complexity = ''

    def get_true(self, ID):
        array = ID.split('_')
        if len(array) == 6:
            return ID # pure ID
        else:
            return '_'.join(array[:6])

    def eva_tool(self, tool_dir, tool, abun_cutoff=0):
        acc_file = tool_dir + '/' + self.ID + '.acc.csv'
        if tool.upper() == "LEMON":
            bkp = read_lemon(acc_file)
        else:
            bkp = read_localHGT(acc_file, abun_cutoff)
        accuracy, FDR, F1_score = compare(self.true_bkp, bkp)
        time_file = tool_dir + '/' + self.ID + '.time'
        tool_time = extract_time(time_file)
        tool_mem = extract_mem(time_file)
        pe = Performance(accuracy, FDR, tool_time, tool_mem, F1_score, self.complexity)
        pe.filterd_bkp_num = len(bkp)
        return pe

    def eva_ref(self, tool_dir):
        interval_file = tool_dir + '/%s.interval.txt.bed'%(self.ID)
        # print (interval_file)
        ref_accuracy, ref_len = check_if_bkp_in_extracted_ref(self.true_file, interval_file)
        return ref_accuracy, round(ref_len/1000000, 2) #M

    def change_ID(self, new_id):
        self.ID = new_id

class Figure():
    def __init__(self):
        self.data = []
        self.df = []
        self.variation = "Depth"
    
    def add_local_sample(self, pe, va): # any performance Object
        self.data.append([pe.user_time, pe.accuracy, pe.FDR, \
        pe.max_mem, pe.ref_accuracy, pe.ref_len, "LocalHGT", va, pe.F1_score, pe.complexity, pe.filterd_bkp_num])

    def add_lemon_sample(self, pe, va): # any performance Object
        self.data.append([pe.user_time, pe.accuracy, pe.FDR, \
        pe.max_mem, pe.ref_accuracy, pe.ref_len, "LEMON", va, pe.F1_score, pe.complexity, pe.filterd_bkp_num])

    def convert_df(self):
        self.df=pd.DataFrame(self.data,columns=['CPU time', 'Recall','FDR', 'Peak RAM', \
        'Ref Accuracy',  'Extracted Ref (M)', 'Methods', self.variation, "F1", "Complexity","BKP_num"])

    def plot(self):
        self.convert_df()
        # fig, axes = plt.subplots(1, 2, figsize=(15, 5))
        # sns.boxplot(ax = axes[0], x=self.variation,y='Recall',hue= 'Methods',data=self.df)
        # sns.barplot(ax = axes[1], x=self.variation,y='FDR', hue= 'Methods',data=self.df) 
        # axes[1].set_ylim(0,0.05)   
        ax = sns.barplot(x=self.variation, y="F1 score",hue= 'Methods',data=self.df)   
            # plt.xticks(rotation=0)
        give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
        plt.savefig('/mnt/d/breakpoints/HGT/figures/HGT_comparison_%s.pdf'%(give_time))
        self.df.to_csv('analysis/depth_comparison.csv', sep=',')

    def plot_all(self):
        self.convert_df()
        fig, axes = plt.subplots(3, 2, figsize=(15,10))
        sns.barplot(ax = axes[0][0], x=self.variation,y='Recall',hue= 'Methods',data=self.df)
        sns.barplot(ax = axes[0][1], x=self.variation,y='FDR', hue= 'Methods',data=self.df) 
        axes[0,1].set_ylim(0,0.05)
        sns.barplot(ax = axes[1][0], x=self.variation,y='Peak RAM',hue= 'Methods',data=self.df)
        sns.barplot(ax = axes[1][1], x=self.variation,y='CPU time', hue= 'Methods',data=self.df) 
        sns.barplot(ax = axes[2][0], x=self.variation,y='Extracted Ref (M)',hue= 'Methods',data=self.df)
        sns.barplot(ax = axes[2][1], x=self.variation,y='Ref Accuracy', hue= 'Methods',data=self.df)        
        #     plt.xticks(rotation=0)
        give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
        plt.savefig('/mnt/d/breakpoints/HGT/figures/HGT_comparison_%s.pdf'%(give_time))
        
    def plot_cami(self):
        self.convert_df()
        print (self.df)
        fig, axes = plt.subplots(3, 3, figsize=(15,10))
        sns.barplot(ax = axes[0][0], x=self.variation, y='CPU time', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'low']).set_title('Low')  
        sns.barplot(ax = axes[0][1], x=self.variation, y='CPU time', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'medium']).set_title('Medium') 
        sns.barplot(ax = axes[0][2], x=self.variation, y='CPU time', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'high']).set_title('High')

        sns.barplot(ax = axes[1][0], x=self.variation, y='Peak RAM', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'low'])  
        sns.barplot(ax = axes[1][1], x=self.variation, y='Peak RAM', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'medium']) 
        sns.barplot(ax = axes[1][2], x=self.variation, y='Peak RAM', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'high']) 

        sns.barplot(ax = axes[2][0], x=self.variation, y='Recall', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'low'])  
        sns.barplot(ax = axes[2][1], x=self.variation, y='Recall', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'medium']) 
        sns.barplot(ax = axes[2][2], x=self.variation, y='Recall', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'high']) 

  
        # sns.lineplot(ax = axes[1], x=self.variation, y='CPU time', style="Complexity", \
        # hue= 'Methods',data=self.df, markers=True, dashes=False) 
        # sns.lineplot(ax = axes[2], x=self.variation, y='Peak RAM', style="Complexity", \
        # hue= 'Methods',data=self.df, markers=True, dashes=False) 
        
        give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
        plt.savefig('/mnt/d/breakpoints/HGT/figures/HGT_comparison_%s.pdf'%(give_time))
        self.df.to_csv('../analysis/cami_comparison.csv', sep=',')

    def plot_amount(self):
        self.convert_df()
        print (self.df)
        fig, axes = plt.subplots(1,4, figsize=(20,4))
        # sns.barplot(ax = axes[0][0], x=self.variation, y='CPU time', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'low']).set_title('Low')  
        # sns.barplot(ax = axes[0][1], x=self.variation, y='CPU time', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'medium']).set_title('Medium') 
        # sns.barplot(ax = axes[0][2], x=self.variation, y='CPU time', hue= 'Methods',data=self.df.loc[self.df['Complexity'] == 'high']).set_title('High')
        sns.lineplot(ax = axes[0], x=self.variation, y='CPU time', hue= 'Methods', style="Complexity", markers=True, data=self.df)
        sns.lineplot(ax = axes[1], x=self.variation, y='Peak RAM', hue= 'Methods', style="Complexity", markers=True, data=self.df)
        sns.lineplot(ax = axes[2], x=self.variation, y='Recall', hue= 'Methods', style="Complexity", markers=True, data=self.df)
        sns.lineplot(ax = axes[3], x=self.variation, y='BKP_num', style="Complexity", markers=True, data=self.df.loc[self.df['Methods'] == 'LocalHGT'])
        
        give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
        plt.savefig('/mnt/d/breakpoints/HGT/figures/HGT_amount_%s.pdf'%(give_time))
        self.df.to_csv('/mnt/d/R_script_files/For_methods/amount_comparison.csv', sep=',')

def cami():
    time_list, mem_list = [], []
    fi = Figure()
    ba = Parameters()
    ba.depth = 100
    ba.get_dir(true_dir)
    fi.variation = "Mutation Rate"
    for snp_rate in [0.01, 0.02, 0.03, 0.04, 0.05]:
    # for snp_rate in [0.05]:
        ba.change_snp_rate(snp_rate)
        index = 0
        ba.get_ID(index)
        sa = Sample(ba.sample, true_dir)
        for level in ba.complexity_level:
            cami_ID = ba.sample + '_' + level
            sa.change_ID(cami_ID)
            sa.complexity = level
            ref_accuracy, ref_len = sa.eva_ref(local_dir)
            local_pe = sa.eva_tool(local_dir, "LocalHGT") 
            local_pe.add_ref(ref_accuracy, ref_len)
            
            fi.add_local_sample(local_pe, snp_rate)
            lemon_pe = sa.eva_tool(lemon_dir, "LEMON")
            fi.add_lemon_sample(lemon_pe, snp_rate)
            print ("#",cami_ID, ref_accuracy, ref_len, "Mb", local_pe.accuracy, local_pe.F1_score, local_pe.complexity)
            print ("############ref" ,ba.sample, ref_accuracy, ref_len, "Mb", local_pe.accuracy ,lemon_pe.accuracy)
            time_list.append(local_pe.user_time)
            mem_list.append(local_pe.max_mem)
    fi.plot_cami()

    print ("CPU time", np.mean(time_list), np.median(time_list))
    print ("PEAK mem", np.mean(mem_list), np.median(mem_list))

def amount_rep(): # run time with increasing of sequencing data amount, with 3 replications, not using
    local_dir = "/mnt/d/breakpoints/HGT/uhgg_amount_result/"
    lemon_dir = "/mnt/d/breakpoints/HGT/uhgg_amount_lemon/"

    
    fi = Figure()
    ba = Parameters(uhgg_ref)
    ba.depth = 30
    ba.get_dir(true_dir)
    fi.variation = "fraction"
    ba.change_snp_rate(0.01)
    index = 0
    ba.get_ID(index)
    default_abun_cutoff = 0
    data = []
    for z in range(1,8):
        prop = round(z * 0.1, 2)

        sa = Sample(ba.sample, true_dir)
        for level in ba.complexity_level:
            time_list, mem_list = [], []
            time_list2, mem_list2 = [], []
            for rep in ['', '_1', '_2']:

                cami_ID = ba.sample + '_' + level + '_' + str(prop) + rep
                sa.change_ID(cami_ID)
                sa.complexity = level
                ref_accuracy, ref_len = sa.eva_ref(local_dir)
                local_pe = sa.eva_tool(local_dir, "LocalHGT", default_abun_cutoff) 
                local_pe.add_ref(ref_accuracy, ref_len)
                fi.add_local_sample(local_pe, prop)

                lemon_pe = sa.eva_tool(lemon_dir, "LEMON", default_abun_cutoff)
                fi.add_lemon_sample(lemon_pe, prop)
                time_list.append(local_pe.user_time)
                mem_list.append(local_pe.max_mem)
                time_list2.append(lemon_pe.user_time)
                mem_list2.append(lemon_pe.max_mem)

            # data.append([level, np.median(time_list), np.median(mem_list), prop, "LocalHGT"])
            # data.append([level, np.median(time_list2), np.median(mem_list2), prop, "LEMON"])
            data.append([level, max(time_list), max(mem_list), prop, "LocalHGT"])
            data.append([level, max(time_list2),max(mem_list2), prop, "LEMON"])
    df=pd.DataFrame(data,columns=["Complexity", 'CPU time', 'Peak RAM', 'Fraction', 'Methods'])
    # print (df)
    fig, axes = plt.subplots(2, figsize=(4,10))
    sns.lineplot(ax = axes[0], x='Fraction', y='CPU time', hue= 'Methods', style="Complexity", markers=True, data=df)
    sns.lineplot(ax = axes[1], x='Fraction', y='Peak RAM', hue= 'Methods', style="Complexity", markers=True, data=df)

    give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
    plt.savefig('/mnt/d/breakpoints/HGT/figures/HGT_amount_%s.pdf'%(give_time))
    df.to_csv('/mnt/d/R_script_files/For_methods/amount_comparison_rep.csv', sep=',')

def amount(): # run time with increasing of sequencing data amount
    local_dir = "/mnt/d/breakpoints/HGT/uhgg_amount_result/"
    lemon_dir = "/mnt/d/breakpoints/HGT/uhgg_amount_lemon/"

    time_list, mem_list = [], []
    fi = Figure()
    ba = Parameters(uhgg_ref)
    ba.depth = 30
    ba.get_dir(true_dir)
    fi.variation = "fraction"
    ba.change_snp_rate(0.01)
    index = 0
    ba.get_ID(index)
    default_abun_cutoff = 0
    for z in range(1,11):
        prop = round(z * 0.1, 2)

        sa = Sample(ba.sample, true_dir)
        for level in ba.complexity_level:
        # for level in ['high', 'low']:
            cami_ID = ba.sample + '_' + level + '_' + str(prop)
            sa.change_ID(cami_ID)
            sa.complexity = level
            ref_accuracy, ref_len = sa.eva_ref(local_dir)
            local_pe = sa.eva_tool(local_dir, "LocalHGT", default_abun_cutoff) 
            local_pe.add_ref(ref_accuracy, ref_len)
            fi.add_local_sample(local_pe, prop)

            lemon_pe = sa.eva_tool(lemon_dir, "LEMON", default_abun_cutoff)
            fi.add_lemon_sample(lemon_pe, prop)
            # print ("#",cami_ID, ref_accuracy, ref_len, "Mb", local_pe.accuracy, local_pe.F1_score, local_pe.complexity)
            # print ("############ref" ,ba.sample, ref_accuracy, ref_len, "Mb", local_pe.accuracy ,lemon_pe.accuracy)
            time_list.append(local_pe.user_time)
            mem_list.append(local_pe.max_mem)
    fi.plot_amount()

    print ("CPU time", np.mean(time_list), np.median(time_list))
    print ("PEAK mem", np.mean(mem_list), np.median(mem_list))

def ultra_deep():
    ### 	SAMEA5669781    753.73 G
    abun_cutoff = 0
    data = [[0,0]]
    acc_dir = "/mnt/d/breakpoints/HGT/deep_result/acc_result/"
    acc_dir = "/mnt/d/HGT/amount_deep/backup_1_15/"
    result_dict = {}

    for z in range(1, 13):

        prop = round(z * 0.08, 3)
        bases = round(prop*786)
        new_x = "%s(%sG)"%(prop, bases)
        acc_file = acc_dir + "/SAMEA5669781_prop%s.acc.csv"%(prop)
        bkp = read_localHGT(acc_file, abun_cutoff, True)
        # print (prop, len(bkp))
        data.append([prop, len(bkp)])
        result_dict[prop] = bkp
    
    # #### count bkp num of each genome
    # genome_count_dict = defaultdict(int)
    # for each_bkp in result_dict[0.96] + result_dict[0.88]:
    #     genome_count_dict[each_bkp[0]] += 1
    #     genome_count_dict[each_bkp[2]] += 1
    # # print (len(genome_count_dict))
    # sort_genome_count_dict = sorted(genome_count_dict.items(), key=lambda x: x[1], reverse = True)
    # print (sort_genome_count_dict[:10])

    prop_dict = {}
    for prop in result_dict:
        genome_count_dict = defaultdict(int)
        for each_bkp in result_dict[prop]:
            genome_count_dict[each_bkp[0]] += 1
            genome_count_dict[each_bkp[2]] += 1
        prop_dict[prop] = genome_count_dict
    genome_count_dict = defaultdict(int)
    for prop in prop_dict:
        for genome in prop_dict[prop]:
            if genome not in genome_count_dict:
                genome_count_dict[genome] = prop_dict[prop][genome]
            if prop_dict[prop][genome] > genome_count_dict[genome]:
                genome_count_dict[genome] = prop_dict[prop][genome]

    ### method 1
    # consider_genome = defaultdict(int)
    # cut = 40
    # for each_bkp in result_dict[0.24]:
    #     if each_bkp[0] in genome_count_dict:
    #         if genome_count_dict[each_bkp[0]] < cut:
    #             consider_genome[each_bkp[0]] += 1
    #     else:
    #         consider_genome[each_bkp[0]] += 1

    #     if each_bkp[2] in genome_count_dict:
    #         if genome_count_dict[each_bkp[2]] < cut:
    #             consider_genome[each_bkp[2]] += 1
    #     else:
    #         consider_genome[each_bkp[2]] += 1
    

    ### method 2
    cut = 8 #15
    count_prop_num = defaultdict(set)
    for prop in result_dict:
        for each_bkp in result_dict[prop]:
            count_prop_num[each_bkp[0]].add(prop)
            count_prop_num[each_bkp[2]].add(prop)
    count_prop_count = {}
    for genome in count_prop_num:
        count_prop_count[genome] = len(count_prop_num[genome])
    sort_count_prop_count = sorted(count_prop_count.items(), key=lambda x: x[1], reverse = True)
    # print (sort_count_prop_count[10000])
    consider_genome = {}
    for sor in sort_count_prop_count:
        if sor[1] >=7 and genome_count_dict[sor[0]] < cut:
            consider_genome[sor[0]] = 1

    print ("len(consider_genome)", len(consider_genome))
    
    data = [[0,0]]
    for prop in result_dict:
        bkp = []
        for each_bkp in result_dict[prop]:
            if each_bkp[0] in consider_genome and each_bkp[2] in consider_genome:
                bkp.append(each_bkp)
        result_dict[prop] = bkp
        data.append([prop, len(bkp), round(prop*670)])
        print ([prop, len(bkp), round(prop*670)])
    sns.set_style("whitegrid")
    df=pd.DataFrame(data,columns=['fraction', 'No. of HGT breakpoint pair', "Base Number (Gbp)"])
    # ax = sns.barplot(x=self.variation, y="F1 score",hue= 'Methods',data=self.df)   
    ax = sns.lineplot(data=df, x="Base Number (Gbp)", y='No. of HGT breakpoint pair', marker="o").set_title('Sample: SAMEA5669780')  
    give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
    plt.savefig('/mnt/d/breakpoints/HGT/figures/HGT_deep_%s.pdf'%(give_time))

def get_genome_len(UHGG_fai):
    genome_len_dict = defaultdict(int)
    for line in open(UHGG_fai, 'r'):
        field = line.strip().split()
        genome = get_pure_genome(field[0])
        contig_len = int(field[1]) 
        genome_len_dict[genome] += contig_len
    return genome_len_dict

def read_kraken(kraken_result, UHGG_meta, UHGG_fai, cutoff=0.01, read_pair_len=300):
    ## estimate the genome depth from Kraken results

    genome_len_dict = get_genome_len(UHGG_fai)
    # print (genome_len_dict)
    taxonomy_dict = {}
    df = pd.read_table(UHGG_meta) 
    for index, row in df.iterrows():
        # self.read_UHGG[row["Genome"]] = row["Species_rep"]
        genome = row["Genome"]
        if genome not in genome_len_dict: # only focus on representative genome
            continue
        species = row["Lineage"].split(";")[-1]
        if species != "s__":
            taxonomy_dict[species] = genome
        else:
            taxonomy_dict["s__"+row["MGnify_accession"]] = genome

    consider_genome = {}  # abundance
    genome_depth_dict = {}  # depth 
    f = open(kraken_result, 'r')
    for line in f:
        array = line.strip().split("\t")
        abundance = float(array[0])
        taxa = array[-1].strip()
        # print (array)
        if taxa[:3] != "s__":
            continue
        # if abundance < cutoff:
        #     continue
        
        if taxa in taxonomy_dict:
            genome = taxonomy_dict[taxa]
        else:
            genome = taxa[3:]
        if genome not in genome_len_dict:
            print ("WARNING", taxa, genome)
            continue
        depth = round(float(int(array[1]) * read_pair_len) / genome_len_dict[genome], 2)
        # print (taxa, genome, abundance, depth)
        consider_genome[genome] = abundance
        genome_depth_dict[genome] = depth

    return consider_genome, genome_depth_dict

def check_absence(genome, abudance_dict):
    absence = False
    if genome not in abudance_dict:
        absence = True
        return absence
    if abudance_dict[genome] == 0:
        return absence

def ultra_deep_depth():
    ### 	SAMEA5669781    753.73 G
    sample_base = 786
    abun_cutoff = 0
    data = []
    acc_dir = "/mnt/d/breakpoints/HGT/deep_result/backup_1_25/"
    # kraken_result = "/mnt/d/breakpoints/HGT/UHGG/kraken/SAMEA5669780_kraken.txt"
    kraken_dir = "/mnt/d/breakpoints/HGT/deep_result/kraken/"
    UHGG_folder = "/mnt/d/breakpoints/HGT/UHGG/"

    ###  hpc location
    # acc_dir = "/home/lijiache2/hgt/hgt_result/fastp_result_v4/"
    # # kraken_result = acc_dir + "/SAMEA5669780_kraken.txt"
    # UHGG_folder = "/home/lijiache2/hgt/hgt_result/ref/"

    UHGG_meta = UHGG_folder + "/genomes-all_metadata.tsv"
    UHGG_fai = UHGG_folder + "/UHGG_reference.formate.fna.fai"

    for z in range(1, 8):

        prop = round(z * 0.08, 3)
        bases = round(prop*sample_base)
        new_x = "%s(%sG)"%(prop, bases)
        acc_file = acc_dir + "/SAMEA5669781_prop%s.acc.csv"%(prop)
        kraken_result = kraken_dir + "/SAMEA5669781_prop%s.kraken.txt"%(prop)
        kraken_result = kraken_result

        consider_genome, genome_depth_dict = read_kraken(kraken_result, UHGG_meta, UHGG_fai, 0.01)
        print ("present genome number", len(consider_genome), len(genome_depth_dict))
        bkp = read_localHGT(acc_file, abun_cutoff, True)
        genome_bkp_dict = defaultdict(int)
        select_genome = {}
        for each_bkp in bkp:
            g1, g2 = get_pure_genome(each_bkp[0]), get_pure_genome(each_bkp[2])
            genome_bkp_dict[g1] += 1
            genome_bkp_dict[g2] += 1

        for genome in genome_bkp_dict:
            if genome not in genome_depth_dict:
                continue

            # if genome_bkp_dict[genome] > 10:
            # if genome == "GUT_GENOME140264":
            if genome_bkp_dict[genome] < 50 and genome_depth_dict[genome] < 100 and genome_bkp_dict[genome] > 2 and genome_depth_dict[genome] > 1:
                data.append([prop, round(prop*sample_base), genome_depth_dict[genome], genome_bkp_dict[genome], consider_genome[genome], genome])
                print (prop, round(prop*sample_base), genome_depth_dict[genome], genome_bkp_dict[genome], consider_genome[genome], genome)
            if prop == 0.56:
                # if genome_bkp_dict[genome] > 10 and genome_bkp_dict[genome] < 30 and genome_depth_dict[genome] > 50 and genome_depth_dict[genome] < 70:
                # if genome_bkp_dict[genome] > 50 and genome_bkp_dict[genome] < 70 and genome_depth_dict[genome] > 50 and genome_depth_dict[genome] < 70:
                if genome_bkp_dict[genome] > 30 and genome_bkp_dict[genome] < 50 and genome_depth_dict[genome] > 50 and genome_depth_dict[genome] < 70:
                    select_genome[genome] = 1
    
    new_data = []
    for ele in data:
        if ele[-1] in select_genome:
            new_data.append(ele)
    data = new_data
    print ("genome number", len(data))


    sns.set_style("whitegrid")
    df=pd.DataFrame(data,columns=['fraction', "Base Number (Gbp)", "depth", 'No. of HGT breakpoint pair', "abundance", 'genome'])
    # ax = sns.barplot(x=self.variation, y="F1 score",hue= 'Methods',data=self.df)   
    ax = sns.lineplot(data=df, x="depth", y='No. of HGT breakpoint pair',hue ='genome',  marker="o", legend=False).set_title('breakpoint pair num: 30-50')
    give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
    plt.savefig(acc_dir + '/HGT_deep_%s.pdf'%(give_time))

def ultra_deep_depth_small():
    ### 	SAMEA5669781    753.73 G
    sample_base = 786
    abun_cutoff = 0
    data = []
    acc_dir = "/mnt/d/breakpoints/HGT/deep_result/small_1_29/"
    kraken_dir = acc_dir
    UHGG_folder = "/mnt/d/breakpoints/HGT/UHGG/"

    ###  hpc location
    # acc_dir = "/home/lijiache2/hgt/hgt_result/fastp_result_v4/"
    # # kraken_result = acc_dir + "/SAMEA5669780_kraken.txt"
    # UHGG_folder = "/home/lijiache2/hgt/hgt_result/ref/"

    UHGG_meta = UHGG_folder + "/genomes-all_metadata.tsv"
    UHGG_fai = UHGG_folder + "/UHGG_reference.formate.fna.fai"
    genome_len_dict = get_genome_len(UHGG_fai)
    for z in range(1, 11):

        # prop = round(z * 0.08, 3)
        prop = z * 5
        bases = round(prop*sample_base)
        new_x = "%s(%sG)"%(prop, bases)
        acc_file = acc_dir + "/SAMEA5669781_prop%s.acc.csv"%(prop)
        kraken_result = kraken_dir + "/SAMEA5669781_prop%s.kraken.txt"%(prop)
        kraken_result = kraken_result

        consider_genome, genome_depth_dict = read_kraken(kraken_result, UHGG_meta, UHGG_fai, 0.01)
        print ("present genome number", len(consider_genome), len(genome_depth_dict), z)
        bkp = read_localHGT(acc_file, abun_cutoff, True)
        genome_bkp_dict = defaultdict(int)
        
        for each_bkp in bkp:
            g1, g2 = get_pure_genome(each_bkp[0]), get_pure_genome(each_bkp[2])
            genome_bkp_dict[g1] += 1
            genome_bkp_dict[g2] += 1

        for genome in genome_bkp_dict:
            if genome not in genome_depth_dict:
                continue

            data.append([prop, round(prop*sample_base), genome_depth_dict[genome], genome_bkp_dict[genome], consider_genome[genome], genome, genome_len_dict[genome]])

    print ("genome number", len(data))
    df=pd.DataFrame(data,columns=['fraction', "Base Number (Gbp)", "depth", 'No. of HGT breakpoint pair', "abundance", 'genome', 'length'])
    df.to_csv(acc_dir + '/depth_comparison.csv', sep=',')
    # ax = sns.barplot(x=self.variation, y="F1 score",hue= 'Methods',data=self.df)  

def plot_abundance(df, acc_dir):
    df = df.loc[(df['abundance'] > 0)]

    data = []
    for z in range(1, 11):
        prop = z * 5
        df2 = df.loc[df['fraction'] == prop]
        bkp_num = sum(df2['No. of HGT breakpoint pair'].tolist())
        print (prop*2, len(df2), bkp_num)
        data.append([prop*2, len(df2), bkp_num])

    df3=pd.DataFrame(data,columns=[ 'Base number (G)', "No. of detected species", 'No. of HGT breakpoint pair'])
    sns.set_style("whitegrid")
    ax = sns.lineplot(data=df3, x='Base number (G)', y="No. of detected species", marker="o", legend=False)#.set_title('breakpoint pair num: 50-100')
    give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
    plt.savefig(acc_dir + '/HGT_abun_%s.pdf'%(give_time))

    plt.clf()
    sns.set_style("whitegrid")
    df4 = df.loc[(df['fraction'] == 50) & (df['depth'] < 100)]
    df5=df4.loc[(df4['abundance'] < 0.1)]
    print ("%s genomes abundance <0.1"%(len(df5)))
    ax = sns.displot(df4, x="abundance", bins=25)#.set_title('breakpoint pair num: 50-100')
    ax.set(xlabel='abundance (%)')
    give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
    plt.savefig(acc_dir + '/HGT_distr_%s.pdf'%(give_time))

    plt.clf()
    sns.set_style("whitegrid")
    df4 = df.loc[(df['fraction'] == 50) & (df['depth'] < 100)]
    df5=df4.loc[(df4['depth'] < 5)]
    print ("%s genomes abundance <5"%(len(df5)))
    ax = sns.displot(df4, x="depth")#.set_title('breakpoint pair num: 50-100')
    give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
    plt.savefig(acc_dir + '/HGT_distr2_%s.pdf'%(give_time))

def is_converged(x, y, max_depth = 50, num_iterations=3, slope_threshold=0.2):

    new_x, new_y = [], []
    for i in range(len(x)):
        if x[i] <= max_depth:
            new_x.append(x[i])
            new_y.append(y[i])
    x, y = new_x, new_y
    if len(x) < num_iterations + 1:
        return False
    x = np.array(x[-num_iterations:])
    y = np.array(y[-num_iterations:])
    slope, _ = np.polyfit(x, y, 1)
    
    if abs(slope) <= slope_threshold:
        return True
    else:
        return False

def plot_deep():
    acc_dir = "/mnt/d/breakpoints/HGT/deep_result/small_1_29/"
    df = pd.read_csv(acc_dir + '/depth_comparison.csv')  
    plot_abundance(df, acc_dir)
    """
    select_genome = defaultdict(int)
    select_genome_depth = defaultdict(int)
    select_genome_num = defaultdict(int)

    for index, row in df.iterrows():
        genome = row['genome']
        select_genome[genome] += 1
        select_genome_depth[genome] = row['depth']
        select_genome_num[genome] = row['No. of HGT breakpoint pair']
    
    delete_index = []
    genome_dict = {}
    for index, row in df.iterrows():
        genome = row['genome']
        if select_genome[genome] > 4 and select_genome_depth[genome] > 30 and select_genome_num[genome] > 5 and select_genome_num[genome] <= 200:
            pass
            genome_dict[genome] = False
        else:
            delete_index.append(index)
    df = df.drop(delete_index)
    print ("genome n.o.", len(genome_dict))
    converged_genome_num = 0
    for genome in genome_dict:
        df2 = df.loc[df['genome'] == genome]
        x = df2['depth'].tolist()
        y = df2['No. of HGT breakpoint pair'].tolist()

        converge = is_converged(x, y)
        if converge:
            genome_dict[genome] = True
            converged_genome_num += 1
        # print (genome, converge, x, y)
    # print (genome_dict)

    delete_index = []
    for index, row in df.iterrows():
        if genome_dict[row['genome']] == False:
            delete_index.append(index)
    df = df.drop(delete_index)
    print ("converged genome n.o.", converged_genome_num)
    
    df = df.loc[(df['depth'] < 50)]
    give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")

    # sns.set_style("whitegrid")
    # # ax = sns.lineplot(data=df, x="depth", y='No. of HGT breakpoint pair',hue ='length', style="length", marker="o", legend=False).set_title('breakpoint pair num: 50-100')
    # ax = sns.lineplot(data=df, x="depth", y='No. of HGT breakpoint pair',hue ='genome', color = "length", style="length", marker="o", legend=False).set_title('breakpoint pair num: 50-100')
    # plt.savefig(acc_dir + '/HGT_deep_%s.pdf'%(give_time))


    plt.clf()
    df2 = df.loc[(df['length'] <= 3000000)]
    x = df2['depth'].tolist()
    y = df2['No. of HGT breakpoint pair'].tolist()
    x = np.asarray(x)
    y = np.asarray(y)
    # x = [round(a) for a in x]

    plt.plot(x, y, 'o', color='red', label='<=3M')
    popt1, _ = curve_fit(saturation_curve, x, y)
    a, b = popt1
    print (a, b)
    x= np.array(sorted(x))
    plt.plot(x, saturation_curve(x, a, b), '-', color='red')



    df2 = df.loc[(df['length'] > 3000000)]
    x = df2['depth'].tolist()
    y = df2['No. of HGT breakpoint pair'].tolist()
    x = np.asarray(x)
    y = np.asarray(y)
    plt.plot(x, y, 'v', color='blue', label='>3M')
    popt1, _ = curve_fit(saturation_curve, x, y)
    a, b = popt1
    print (a, b)
    x= np.array(sorted(x))
    plt.plot(x, saturation_curve(x, a, b), '-', color='blue')


    plt.xlabel('depth')
    plt.ylabel('No. of HGT breakpoint pair')
    plt.title('')
    plt.legend(numpoints=1)
    plt.grid(True)
    plt.savefig(acc_dir + '/HGT_curve_%s.pdf'%(give_time))
    """

# Define the saturation curve function
def saturation_curve(x, a, b):
    return a * (1 - np.exp(-b * x))
    # return (a * x) + b 

def ultra_deep_depth_pair():
    ### 	SAMEA5669781    753.73 G
    sample_base = 786
    abun_cutoff = 0
    data = []
    acc_dir = "/mnt/d/breakpoints/HGT/deep_result/backup_1_25/"
    # kraken_result = "/mnt/d/breakpoints/HGT/UHGG/kraken/SAMEA5669780_kraken.txt"
    kraken_dir = "/mnt/d/breakpoints/HGT/deep_result/kraken/"
    UHGG_folder = "/mnt/d/breakpoints/HGT/UHGG/"

    ###  hpc location
    # acc_dir = "/home/lijiache2/hgt/hgt_result/fastp_result_v4/"
    # # kraken_result = acc_dir + "/SAMEA5669780_kraken.txt"
    # UHGG_folder = "/home/lijiache2/hgt/hgt_result/ref/"

    UHGG_meta = UHGG_folder + "/genomes-all_metadata.tsv"
    UHGG_fai = UHGG_folder + "/UHGG_reference.formate.fna.fai"

    for z in range(1, 8):

        prop = round(z * 0.08, 3)
        bases = round(prop*sample_base)
        new_x = "%s(%sG)"%(prop, bases)
        acc_file = acc_dir + "/SAMEA5669781_prop%s.acc.csv"%(prop)
        kraken_result = kraken_dir + "/SAMEA5669781_prop%s.kraken.txt"%(prop)
        kraken_result = kraken_result

        consider_genome, genome_depth_dict = read_kraken(kraken_result, UHGG_meta, UHGG_fai, 0.01)
        print ("present genome number", len(consider_genome), len(genome_depth_dict))
        bkp = read_localHGT(acc_file, abun_cutoff, True)
        genome_bkp_dict = defaultdict(int)
        depth_pair = defaultdict(int)
        for each_bkp in bkp:
            g1, g2 = get_pure_genome(each_bkp[0]), get_pure_genome(each_bkp[2])
            pair_id = "&".join(sorted([g1, g2]))
            if g1 not in genome_depth_dict or g2 not in genome_depth_dict:
                continue
            depth_pair[pair_id] = genome_depth_dict[g1] + genome_depth_dict[g2]
            genome_bkp_dict[pair_id] += 1
        print ("pair number", len(genome_bkp_dict))
        for pair_id in genome_bkp_dict:
            # if genome not in genome_depth_dict:
            #     continue
            if pair_id == "GUT_GENOME244777&GUT_GENOME257123":
                print (prop, round(prop*sample_base), depth_pair[pair_id], genome_bkp_dict[pair_id], pair_id)
            # data.append([prop, round(prop*sample_base), depth_pair[pair_id], genome_bkp_dict[pair_id], pair_id])
            # if prop == 0.56 and genome_bkp_dict[pair_id] > 20:
            #     print (prop, round(prop*sample_base), depth_pair[pair_id], genome_bkp_dict[pair_id], pair_id)


    sns.set_style("whitegrid")
    df=pd.DataFrame(data,columns=['fraction', "Base Number (Gbp)", "depth", 'No. of HGT breakpoint pair', 'genome_pair'])
    # ax = sns.barplot(x=self.variation, y="F1 score",hue= 'Methods',data=self.df)   
    ax = sns.lineplot(data=df, x="depth", y='No. of HGT breakpoint pair', marker="o").set_title('Sample: SAMEA5669780')  
    give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
    plt.savefig(acc_dir + '/HGT_deep_%s.pdf'%(give_time))

def ultra_deep_depth_population():
    ### 	SAMEA5669781    753.73 G
    sample_base = 786
    abun_cutoff = 0
    depth_cutoff = 0

    data = []
    acc_dir = "/mnt/d/breakpoints/HGT/deep_result/backup_1_25/"
    kraken_dir = "/mnt/d/breakpoints/HGT/deep_result/kraken/"
    UHGG_folder = "/mnt/d/breakpoints/HGT/UHGG/"

    ###  hpc location
    # acc_dir = "/home/lijiache2/hgt/hgt_result/fastp_result_v4/"
    # # kraken_result = acc_dir + "/SAMEA5669780_kraken.txt"
    # UHGG_folder = "/home/lijiache2/hgt/hgt_result/ref/"

    UHGG_meta = UHGG_folder + "/genomes-all_metadata.tsv"
    UHGG_fai = UHGG_folder + "/UHGG_reference.formate.fna.fai"

    for z in range(1, 13):

        prop = round(z * 0.08, 3)
        # prop = z
        bases = round(prop*sample_base)
        new_x = "%s(%sG)"%(prop, bases)
        acc_file = acc_dir + "/SAMEA5669781_prop%s.acc.csv"%(prop)
        kraken_result = kraken_dir + "/SAMEA5669781_prop%s.kraken.txt"%(prop)

        consider_genome, genome_depth_dict = read_kraken(kraken_result, UHGG_meta, UHGG_fai, 0.01)
        genome_depth_dict = {key: value for key, value in genome_depth_dict.items() if value > depth_cutoff}
        print ("present genome number", len(consider_genome), len(genome_depth_dict))
        bkp = read_localHGT(acc_file, abun_cutoff, True)
        genome_bkp_dict = defaultdict(int)
        filter_bkp = []
        genome_dict = defaultdict(int)
        genome_pair_dict = defaultdict(int)
        for each_bkp in bkp:
            
            g1, g2 = get_pure_genome(each_bkp[0]), get_pure_genome(each_bkp[2])
            if g1 in genome_depth_dict and g2 in genome_depth_dict:
                filter_bkp.append(each_bkp)
                genome_dict[g1] += 1
                genome_dict[g2] += 1
                pair_id = "&".join(sorted([g1, g2]))
                if prop != 0.08:
                    if pair_id not in focus_genome_pair:
                        continue
                genome_pair_dict[pair_id] += 1
        if prop == 0.08:
            genome_pair_dict = {key: value for key, value in genome_pair_dict.items() if value > 1}
            focus_genome_pair = genome_pair_dict
        median_value = np.median(list(genome_dict.values()))
        pair_median_value = np.mean(list(genome_pair_dict.values()))
        print (prop, len(filter_bkp), median_value, len(genome_pair_dict), pair_median_value)

def ultra_deep_SAMEA5669780():
    ### 	SAMEA5669781    753.73 G
    abun_cutoff = 0
    data = [[0,0]]
    acc_dir = "/mnt/d/breakpoints/HGT/deep_result/acc_result/"
    kraken_result = "/mnt/d/breakpoints/HGT/UHGG/kraken/test.txt"
    UHGG_folder = "/mnt/d/breakpoints/HGT/UHGG/"
    UHGG_meta = UHGG_folder + "/genomes-all_metadata.tsv"
    UHGG_fai = UHGG_folder + "/UHGG_reference.formate.fna.fai"
    result_dict = {}

    for z in range(1, 8):

        prop = round(z * 0.01, 3)
        bases = round(prop*786)
        new_x = "%s(%sG)"%(prop, bases)
        acc_file = acc_dir + "/SAMEA5669780_%s.acc.csv"%(prop)
        bkp = read_localHGT(acc_file, abun_cutoff, True)
        # print (prop, len(bkp))
        data.append([prop, len(bkp)])
        result_dict[prop] = bkp

    consider_genome, genome_depth_dict = read_kraken(kraken_result, UHGG_meta, UHGG_fai, 0.01)
    # print ("len(consider_genome)", len(consider_genome))
    
    # data = [[0,0]]
    # for prop in result_dict:
    #     bkp = []
    #     for each_bkp in result_dict[prop]:
    #         if get_pure_genome(each_bkp[0]) in consider_genome and get_pure_genome(each_bkp[2]) in consider_genome:
    #             bkp.append(each_bkp)
    #     result_dict[prop] = bkp
    #     data.append([prop, len(bkp), round(prop*670)])
    #     print ([prop, len(bkp), round(prop*670)])
    # sns.set_style("whitegrid")
    # df=pd.DataFrame(data,columns=['fraction', 'No. of HGT breakpoint pair', "Base Number (Gbp)"])
    # # ax = sns.barplot(x=self.variation, y="F1 score",hue= 'Methods',data=self.df)   
    # ax = sns.lineplot(data=df, x="Base Number (Gbp)", y='No. of HGT breakpoint pair', marker="o").set_title('Sample: SAMEA5669780')  
    # give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
    # plt.savefig('/mnt/d/breakpoints/HGT/figures/HGT_deep_%s.pdf'%(give_time))

def cal_cami_time_MEM(): # cal avergae Run time and Peak MEM with CAMI data
    time_list, mem_list, cpu_list = [], [], []

    ba = Parameters()
    ba.depth = 100
    ba.get_dir(true_dir)
    for snp_rate in [0.01, 0.02, 0.03, 0.04, 0.05]:
    # for snp_rate in [0.05]:
        ba.change_snp_rate(snp_rate)
        index = 0
        ba.get_ID(index)

        for level in ba.complexity_level:
            cami_ID = ba.sample + '_' + level
            time_file = lemon_dir + '/' + cami_ID + '.time'

            tool_time = extract_wall_clock_time(time_file)
            cpu_time = extract_time(time_file)
            tool_mem = extract_mem(time_file)

            time_list.append(tool_time)
            mem_list.append(tool_mem)
            cpu_list.append(cpu_time)


    print ("wall-clock time", np.mean(time_list), np.median(time_list))
    print ("CPU time", np.mean(cpu_list), np.median(cpu_list))
    print ("PEAK mem", np.mean(mem_list), np.median(mem_list))

def snp():
    fi = Figure()
    ba = Parameters()

    for snp_rate in ba.snp_level: # 0.01-0.09
        # if snp_rate == 0.07:
        #     continue
    # for snp_rate in [0.05]:
        ba.change_snp_rate(snp_rate)
        for index in range(ba.iteration_times):
            ba.get_ID(index)    
            sa = Sample(ba.sample, true_dir)
            ref_accuracy, ref_len = sa.eva_ref(local_dir)
            
            local_pe = sa.eva_tool(local_dir)
            print ("############ref" ,ba.sample, ref_accuracy, ref_len, "Mb", local_pe.accuracy, local_pe.FDR)
            # print ("############ref" ,ba.sample, ref_accuracy, ref_len, "Mb", local_pe.accuracy)

def depth():
    fi = Figure()
    ba = Parameters()
    true_dir = "/mnt/d/breakpoints/HGT/uhgg_depth/"
    lemon_dir = "/mnt/d/breakpoints/HGT/lemon_depth/"
    local_dir = "/mnt/d/breakpoints/HGT/uhgg_depth_results/"

    for depth in [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]:
        ba.change_depth(depth)
        for index in range(10):
            ba.get_ID(index)    
            sa = Sample(ba.sample, true_dir)
            ref_accuracy, ref_len = sa.eva_ref(local_dir)
            
            # print ("############ref" ,ba.sample, ref_accuracy, ref_len, "Mb")
            local_pe = sa.eva_tool(local_dir)
            local_pe.add_ref(ref_accuracy, ref_len)
            print ("--------next lemon-------")
            lemon_pe = sa.eva_tool(lemon_dir)
            print ("############ref" ,ba.sample, ref_accuracy, ref_len, "Mb", local_pe.accuracy,\
             local_pe.FDR, local_pe.F1_score ,lemon_pe.accuracy, lemon_pe.FDR, lemon_pe.F1_score)
            fi.add_local_sample(local_pe, depth)
            fi.add_lemon_sample(lemon_pe, depth)
    fi.plot()

def pure_snp():
    fi = Figure()
    ba = Parameters()
    true_dir = "/mnt/d/breakpoints/HGT/uhgg_snp/"
    lemon_dir = "/mnt/d/breakpoints/HGT/lemon_snp_pure/"
    local_dir = "/mnt/d/breakpoints/HGT/uhgg_snp_pure/"

    for snp_rate in ba.snp_level:
        ba.change_snp_rate(snp_rate)
        for index in range(10):
            ba.get_ID(index)    
            sa = Sample(ba.sample, true_dir)
            ref_accuracy, ref_len = sa.eva_ref(local_dir)
        
            local_pe = sa.eva_tool(local_dir, 'localHGT')
            local_pe.add_ref(ref_accuracy, ref_len)
            lemon_pe = sa.eva_tool(lemon_dir, "lemon")
            fi.add_local_sample(local_pe, snp_rate)
            fi.add_lemon_sample(lemon_pe, snp_rate)
    fi.variation = "snp"
    fi.convert_df()
    fi.df.to_csv('/mnt/c/Users/swang66/Documents/For_methods/pure_snp_comparison.csv', sep=',')

def pure_length():
    fi = Figure()
    ba = Parameters()
    true_dir = "/mnt/d/breakpoints/HGT/uhgg_length/"
    lemon_dir = "/mnt/d/breakpoints/HGT/lemon_length_results/"
    local_dir = "/mnt/d/breakpoints/HGT/uhgg_length_results/"

    # for snp_rate in ba.snp_level:
    #     ba.change_snp_rate(snp_rate)
    for read_length in [75]:
        ba.reads_len = read_length
        for index in range(10):
            ba.get_ID(index)    
            sa = Sample(ba.sample, true_dir)
            ref_accuracy, ref_len = sa.eva_ref(local_dir)
        
            local_pe = sa.eva_tool(local_dir, 'localHGT')
            local_pe.add_ref(ref_accuracy, ref_len)
            lemon_pe = sa.eva_tool(lemon_dir, "lemon")
            fi.add_local_sample(local_pe, read_length)
            fi.add_lemon_sample(lemon_pe, read_length)
            print ("#ref" ,ba.sample, ref_accuracy, ref_len, "Mb", local_pe.accuracy, local_pe.FDR)
    fi.variation = "length"
    fi.convert_df()
    fi.df.to_csv('/mnt/c/Users/swang66/Documents/For_methods/pure_length_comparison.csv', sep=',')

def pure_donor():
    fi = Figure()
    ba = Parameters()
    # true_dir = "/mnt/d/breakpoints/HGT/uhgg_length/"
    # lemon_dir = "/mnt/d/breakpoints/HGT/lemon_length_results/"
    # local_dir = "/mnt/d/breakpoints/HGT/uhgg_length_results/"
    # ba = Batch()
    ba.HGT_num = 5
    ba.scaffold_num = 5
    for donor_f in ["in", "not_in"]:
        # ba.snp_rate = snp_rate 
        true_dir = "/mnt/d/breakpoints/HGT/donor/%s/"%(donor_f)
        lemon_dir = "/mnt/e/HGT/donor_result/lemon/%s/"%(donor_f)
        local_dir = "/mnt/d/breakpoints/HGT/donor_result/localhgt/%s/"%(donor_f)
        # ba.get_fq_dir()
        # ba.get_result_dir()
        # ba.change_lemon_dir()
        for index in range(10):
            ba.get_ID(index)    
            sa = Sample(ba.sample, true_dir)
            ref_accuracy, ref_len = sa.eva_ref(local_dir)
        
            local_pe = sa.eva_tool(local_dir, 'localHGT')
            local_pe.add_ref(ref_accuracy, ref_len)
            lemon_pe = sa.eva_tool(lemon_dir, "lemon")
            fi.add_local_sample(local_pe, donor_f)
            fi.add_lemon_sample(lemon_pe, donor_f)
            # print ("#ref" ,ba.sample, ref_accuracy, ref_len, "Mb", local_pe.accuracy, local_pe.FDR)
    fi.variation = "donor"
    fi.convert_df()
    fi.df.to_csv('/mnt/c/Users/swang66/Documents/For_methods/pure_donor_comparison.csv', sep=',')

def pure_frag():
    fi = Figure()
    ba = Parameters()
    # true_dir = "/mnt/d/breakpoints/HGT/uhgg_length/"
    # lemon_dir = "/mnt/d/breakpoints/HGT/lemon_length_results/"
    # local_dir = "/mnt/d/breakpoints/HGT/uhgg_length_results/"
    # ba = Batch()
    for frag in [200, 350, 500, 650, 800, 950]:
        print (frag)
        ba.mean_frag = frag
        true_dir = "/mnt/d/breakpoints/HGT/frag_size/f%s/"%(frag) 
        local_dir = "/mnt/d/breakpoints/HGT/frag_result/localhgt/f%s/"%(frag)
        lemon_dir = "/mnt/e/HGT/frag_result/lemon/f%s/"%(frag)

        for index in range(10):
            ba.get_ID(index)    
            sa = Sample(ba.sample, true_dir)
            ref_accuracy, ref_len = sa.eva_ref(local_dir)
        
            local_pe = sa.eva_tool(local_dir, 'localHGT')
            local_pe.add_ref(ref_accuracy, ref_len)
            lemon_pe = sa.eva_tool(lemon_dir, "lemon")
            fi.add_local_sample(local_pe, frag)
            fi.add_lemon_sample(lemon_pe, frag)
            # print ("#ref" ,ba.sample, ref_accuracy, ref_len, "Mb", local_pe.accuracy, local_pe.FDR)
    fi.variation = "frag"
    fi.convert_df()
    fi.df.to_csv('/mnt/c/Users/swang66/Documents/For_methods/pure_frag_comparison.csv', sep=',')

def read_all_event(inferred_event):
    inferred_event_dict = defaultdict(list)
    for line in open(inferred_event):
        array = line.strip().split(',')   
        if array[0] == "sample":
            continue
        sample = array[0]
        inferred_event_dict[sample].append(array[1:])
    return inferred_event_dict

def depth_event():
    ba = Parameters(uhgg_ref)
    true_dir = "/mnt/d/breakpoints/HGT/uhgg_depth/"
    local_dir = "/mnt/d/breakpoints/HGT/depth_for_event/"
    inferred_event = "/mnt/d/HGT/event_evaluation/uhgg_depth_event.csv"
    inferred_event_dict = read_all_event(inferred_event)
    print (len(inferred_event_dict))
    data = []
    for depth in [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]:
        ba.change_depth(depth)
        for index in range(10):
            ba.get_ID(index)    
            sa = Sample(ba.sample, true_dir)
            sample_true_events = sa.true_event
            sample_infer_events = []
            if sa.ID in inferred_event_dict:
                sample_infer_events = inferred_event_dict[sa.ID]
            else:
                print ("no event", sa.ID)
                continue
            # print (sample_infer_events)
            F1_score = compare_event(sample_true_events, sample_infer_events)
            data.append([sa.ID, F1_score, depth])

    df = pd.DataFrame(data, columns = ["sample", "F1 score", "depth"])
    df.to_csv("/mnt/d/R_script_files/event_depth.csv", sep=',', index=False)
    ax = sns.barplot(x="depth", y="F1 score",data=df)   
        # plt.xticks(rotation=0)
    give_time = datetime.now().strftime("%Y_%m_%d_%H_%M")
    plt.savefig('/mnt/d/breakpoints/HGT/figures/HGT_depth_event_%s.pdf'%(give_time))

def compare_event(true_list, infer_list):
    tolerate_diff = 50
    interact = 0
    for t_event in true_list:
        for i_event in infer_list:
            # print (t_event, i_event )
            if t_event[0] == i_event[0] and abs(int(t_event[1])-int(i_event[1]))<tolerate_diff and t_event[2] == i_event[2] and abs(int(t_event[3])-int(i_event[3]))<tolerate_diff\
                and abs(int(t_event[4])-int(i_event[4]))<tolerate_diff and t_event[5] == i_event[5]:

                interact += 1
    recall = interact/(len(true_list))
    precision = interact/(len(infer_list))

    if precision > 0 and recall > 0:
        F1_score = 2/((1/precision) + (1/recall)) 
    else:
        F1_score = 0
    return F1_score

def abundance():
    fi = Figure()
    ba = Parameters(uhgg_ref)
    true_dir = "/mnt/d/HGT/abundance/abun_0.5"
    local_dir = "/mnt/d/breakpoints/HGT/uhgg_abundance_result//"
    true_file = true_dir + "/species20_snp0.01_depth30_reads150_sample_0.true.sv.txt"
    abun = 0.5
    for amount in [20]:
    # for amount in range(2, 17, 2):
        sample = f"abun_{abun}_amount_{amount}"

        if amount == 8:
            continue
        ba.sample = sample
        sa = Sample(ba.sample, true_dir)
        sa.true_bkp, sa.true_event = read_true(true_file)
        local_pe = sa.eva_tool(local_dir, "localhgt")

        print (ba.sample, local_pe.accuracy, local_pe.FDR, local_pe.F1_score)
            # fi.add_local_sample(local_pe, depth)
        # break
    # fi.plot()

if __name__ == "__main__":
    default_abun_cutoff = 1e-7

    true_dir = "/mnt/d/breakpoints/HGT/uhgg_snp/"
    lemon_dir = "/mnt/d/breakpoints/HGT/lemon_snp/"
    local_dir = "/mnt/d/breakpoints/HGT/uhgg_snp_results_paper/"

    uhgg_ref = '/mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna'
    progenomes = '/mnt/d/breakpoints/HGT/proGenomes/proGenomes_v2.1.fasta'

    print ("evaluation")
    # cami()
    # snp()
    # pure_snp()
    # depth()
    # pure_length()
    # pure_donor()
    # pure_frag()
    # cal_cami_time_MEM()
    # depth_event()
    amount()
    # ultra_deep()
    # ultra_deep_SAMEA5669780()
    # ultra_deep_depth()
    # ultra_deep_depth_small()
    # plot_deep()
    # ultra_deep_depth_pair()
    # ultra_deep_depth_population()
    # read_kraken()
    # abundance()
    # amount_rep()


