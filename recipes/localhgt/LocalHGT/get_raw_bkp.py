#!/usr/bin/env python3

from __future__ import division
import sys
import math
import pysam
import numpy as np
from sklearn.cluster import DBSCAN
import random
import re
import os
import multiprocessing
import argparse
import time
import logging

minSample = 1


def readFilter(read):
    return (read.is_proper_pair and
            read.is_paired and
            read.tlen > 0 and
            read.tlen < 1000 and
            not read.is_supplementary and
            not read.is_duplicate and
            not read.is_unmapped and
            not read.mate_is_unmapped)

def getInsertSize(unique_bamfile):
    read_length_list = []
    insert_size_list = []
    r_num = 0
    for read in unique_bamfile:
        if readFilter(read):
            insert_size_list.append(read.tlen)
            read_length_list.append(len(read.query_sequence))
            r_num += 1
        if r_num > 10000:
            print ("consider 10000 reads in estimating read length and insert size.")
            break
        
    read_length = int(sum(read_length_list) / len(read_length_list))
    mean = float(sum(insert_size_list)) / len(insert_size_list)
    sdev = math.sqrt(float(sum([(x - mean)**2 for x in insert_size_list])) / (len(insert_size_list) - 1))
    return mean, sdev, read_length, r_num

def calCrossReads(bamfile):
    dict_Interact_Big = {}
    del_xa_num = 0
    for read in bamfile:
        if read.mapping_quality < 20:
            continue
        if args['a'] == 0:
            if read.has_tag('XA'): 
                del_xa_num += 1
                continue   
        if read.is_unmapped == False and read.mate_is_unmapped == False and read.reference_name.split(':')[0] != read.next_reference_name.split(':')[0] and read.flag < 2048: 
            if args['n'] == 1:
                read.reference_start = int(read.reference_name.split(':')[1].split('-')[0]) + read.reference_start
                read.next_reference_start = int(read.next_reference_name.split(':')[1].split('-')[0]) + read.next_reference_start
            if read.qname not in dict_Interact_Big:
                ls = []
                ls.append(read)
                dict_tmp = {read.qname:ls}
                dict_Interact_Big.update(dict_tmp)
            else:
                if len(dict_Interact_Big.get(read.qname)) == 2:
                    continue 
                dict_Interact_Big.get(read.qname).append(read)
    if args['a'] == 0:
        print ("No. of deleted reads with XA tag is", del_xa_num)
    print ("No. of junction reads is", len(dict_Interact_Big))
    return dict_Interact_Big

def indexReadBasedOnRef(dict_Interact_Big):
    ref_dict_Interact_Big = {}
    for key in dict_Interact_Big:
        if len(dict_Interact_Big.get(key))  >   1:
            for i in range(0,len(dict_Interact_Big.get(key))):
                if dict_Interact_Big.get(key)[i].reference_name.split(':')[0] not in ref_dict_Interact_Big:
                    ls = []
                    ls.append(dict_Interact_Big.get(key)[i])
                    dict_tmp = {dict_Interact_Big.get(key)[i].reference_name.split(':')[0]:ls}
                    ref_dict_Interact_Big.update(dict_tmp)
                else:
                    ref_dict_Interact_Big.get(dict_Interact_Big.get(key)[i].reference_name.split(':')[0]).append(dict_Interact_Big.get(key)[i])
    return ref_dict_Interact_Big

def indexReadBasedOnPos(ref_dict_Interact_Big):          
    ref_list_Interact_Big = []  
    for key in ref_dict_Interact_Big:
        tmp_dict = {}
        for i in range(0,len(ref_dict_Interact_Big.get(key))):
            if ref_dict_Interact_Big.get(key)[i].reference_start not in tmp_dict:
                ls = []
                ls.append(ref_dict_Interact_Big.get(key)[i])
                buf_dict = {ref_dict_Interact_Big.get(key)[i].reference_start:ls}
                tmp_dict.update(buf_dict)
            else:
                tmp_dict.get(ref_dict_Interact_Big.get(key)[i].reference_start).append(ref_dict_Interact_Big.get(key)[i])
        tmp_items = tmp_dict.items()
        items = list(tmp_items)
        items.sort()
        ref_list_Interact_Big.append(items)
    return ref_list_Interact_Big

def htgMATRIX(dict_Interact_Big, ref_list_Interact_Big):
    htg_dict={}
    for i in range(0,len(ref_list_Interact_Big)):
        # print (ref_list_Interact_Big[i][0][1][0].reference_name.split(':')[0], len(ref_list_Interact_Big[i]))
        if len(ref_list_Interact_Big[i]) < 1:  #lemon = 5
            continue
        ref_name = ref_list_Interact_Big[i][0][1][0].reference_name.split(':')[0]
        sub_dict = {}        
        for j in range(0, len(ref_list_Interact_Big[i])):
            for k in range(0, len(ref_list_Interact_Big[i][j][1])):
                read_name=ref_list_Interact_Big[i][j][1][k].qname
                if dict_Interact_Big.get(read_name)[0].reference_name.split(':')[0]!=ref_name:
                    cross_name=dict_Interact_Big.get(read_name)[0].reference_name.split(':')[0]
                else:
                    cross_name=dict_Interact_Big.get(read_name)[1].reference_name.split(':')[0]
                if cross_name not in sub_dict:
                    ls=[]
                    ls.append(ref_list_Interact_Big[i][j][1][k])
                    tmp_dict={cross_name : ls}
                    sub_dict.update(tmp_dict)
                else:
                    sub_dict.get(cross_name).append(ref_list_Interact_Big[i][j][1][k])
        ref_dict={ref_name : sub_dict}
        htg_dict.update(ref_dict)
    return htg_dict

def clasifyData(htg_dict,key,sub_key):
    dict_xy = {}
    for i in range(0,len(htg_dict.get(key).get(sub_key))):
        p = htg_dict.get(key).get(sub_key)[i]
        if p.is_read1 == True:
            if p.is_reverse == False:
                if p.mate_is_reverse == True:
                    if 'read1pos_pos' not in dict_xy:
                        xy_read1pos_pos = []
                        xy_read1pos_pos.append(p)
                        dict_tmp = {'read1pos_pos':xy_read1pos_pos}
                        dict_xy.update(dict_tmp)
                    else:
                        dict_xy.get('read1pos_pos').append(p)
                else:
                    if 'read1pos_neg' not in dict_xy:
                        xy_read1pos_neg = []
                        xy_read1pos_neg.append(p)
                        dict_tmp = {'read1pos_neg':xy_read1pos_neg}
                        dict_xy.update(dict_tmp)
                    else:
                        dict_xy.get('read1pos_neg').append(p)
            else:
                if p.mate_is_reverse == True:
                    if 'read1neg_pos' not in dict_xy:
                        xy_read1neg_pos = []
                        xy_read1neg_pos.append(p)
                        dict_tmp = {'read1neg_pos':xy_read1neg_pos}
                        dict_xy.update(dict_tmp)
                    else:
                        dict_xy.get('read1neg_pos').append(p)
                else:
                    if 'read1neg_neg' not in dict_xy:
                        xy_read1neg_neg = []
                        xy_read1neg_neg.append(p)
                        dict_tmp = {'read1neg_neg':xy_read1neg_neg}
                        dict_xy.update(dict_tmp)
                    else:
                        dict_xy.get('read1neg_neg').append(p)
        else:
            if p.is_reverse == False:
                if p.mate_is_reverse == True:
                    if 'read2neg_neg' not in dict_xy:
                        xy_read2neg_neg = []
                        xy_read2neg_neg.append(p)
                        dict_tmp = {'read2neg_neg':xy_read2neg_neg}
                        dict_xy.update(dict_tmp)
                    else:
                        dict_xy.get('read2neg_neg').append(p)
                else:
                    if 'read2neg_pos' not in dict_xy:
                        xy_read2neg_pos = []
                        xy_read2neg_pos.append(p)
                        dict_tmp = {'read2neg_pos':xy_read2neg_pos}
                        dict_xy.update(dict_tmp)
                    else:
                        dict_xy.get('read2neg_pos').append(p)
            else:
                if p.mate_is_reverse == True:
                    if 'read2pos_neg' not in dict_xy:
                        xy_read2pos_neg = []
                        xy_read2pos_neg.append(p)
                        dict_tmp = {'read2pos_neg':xy_read2pos_neg}
                        dict_xy.update(dict_tmp)
                    else:
                        dict_xy.get('read2pos_neg').append(p)
                else:
                    if 'read2pos_pos' not in dict_xy:
                        xy_read2pos_pos = []
                        xy_read2pos_pos.append(p)
                        dict_tmp = {'read2pos_pos':xy_read2pos_pos}
                        dict_xy.update(dict_tmp)
                    else:
                        dict_xy.get('read2pos_pos').append(p)
    return dict_xy

def prepareClusterData(htg_dict):
    preClusterData  =   {}
    for key in htg_dict:
        sub_dict    =   {}
        for sub_key in htg_dict.get(key):
            cross_name  =   sub_key
            dict_xy     =   clasifyData(htg_dict,key,sub_key)
            tmp_dict    =   {cross_name:dict_xy}
            sub_dict.update(tmp_dict)
        ref_dict    =   {key:sub_dict}
        preClusterData.update(ref_dict)
    return preClusterData

def clusterBasedOnDensity(dict_xy,key):
    positons = []
    for i in range(0,len(dict_xy.get(key))):
        tmp = []
        tmp.append(dict_xy.get(key)[i].reference_start)
        tmp.append(dict_xy.get(key)[i].next_reference_start)
        positons.append(tmp)
    XY = np.array(positons)
    db = DBSCAN(eps = int(insert_size/2), min_samples = minSample).fit(XY)
    labels = db.labels_
    cluster_label_dict = {}
    lab = labels.tolist()
    for i in range(0,len(lab)):
        if(lab[i]!=-1):
            if lab[i] not in cluster_label_dict:
                ls = []
                ls.append(i)
                tmp_dict = {lab[i]:ls}
                cluster_label_dict.update(tmp_dict)
            else:
                cluster_label_dict.get(lab[i]).append(i)
    return cluster_label_dict

def calculateRefA(cluster_label_dict, dict_xy, key):
    ref_A = []
    bkp_region_dict = {}
    for key1 in cluster_label_dict:
        found = False
        start_A = dict_xy.get(key)[cluster_label_dict.get(key1)[0]].reference_start
        next_start_A = dict_xy.get(key)[cluster_label_dict.get(key1)[0]].next_reference_start
        end_A = dict_xy.get(key)[cluster_label_dict.get(key1)[0]].reference_end
        #tmp_bkp = [start_A, next_start_A]
        if start_A in bkp_region_dict:
            if next_start_A in bkp_region_dict[start_A]:
        #if tmp_bkp in bkp_region_list:
                found = True
        #next_end_A = dict_xy.get(key)[cluster_label_dict.get(key1)[0]].next_reference_end
        if found is False:
            for i in range(1, len(cluster_label_dict.get(key1))):
                if dict_xy.get(key)[cluster_label_dict.get(key1)[i]].reference_start < start_A:
                    start_A = dict_xy.get(key)[cluster_label_dict.get(key1)[i]].reference_start
                if dict_xy.get(key)[cluster_label_dict.get(key1)[i]].reference_end > end_A:
                    end_A = dict_xy.get(key)[cluster_label_dict.get(key1)[i]].reference_end
                if dict_xy.get(key)[cluster_label_dict.get(key1)[i]].next_reference_start < next_start_A:
                    next_start_A = dict_xy.get(key)[cluster_label_dict.get(key1)[i]].next_reference_start
                #tmp_bkp = [start_A, next_start_A]
                if start_A in bkp_region_dict:
                    if next_start_A in [min(bkp_region_dict[start_A]) - 10, max(bkp_region_dict[start_A]) + 10]:
                        found = True
                        break
        tmp = [start_A, end_A]
        if found is False:
            ref_A.append(tmp)
            if start_A not in bkp_region_dict:
                tmp_dict = {start_A : [next_start_A]}
                bkp_region_dict.update(tmp_dict)
            else:
                bkp_region_dict[start_A].append(next_start_A)
    bkp_region_dict = {}
    del bkp_region_dict
    return ref_A
    

def calculateClusterDictCross(cluster_label_dict,dict_xy,ref_dict_Interact_Big,cross_name,key):
    cluster_dict_cross = []
    for key1 in cluster_label_dict:
        ls = []
        for i in range(0,len(cluster_label_dict.get(key1))):
            tmp_ls = []
            tmp_ls.append(dict_xy.get(key)[cluster_label_dict.get(key1)[i]])
            for k in range(0,len(ref_dict_Interact_Big.get(cross_name))):
                if ref_dict_Interact_Big.get(cross_name)[k].qname == dict_xy.get(key)[cluster_label_dict.get(key1)[i]].qname:
                    tmp_ls.append(ref_dict_Interact_Big.get(cross_name)[k])
            ls.append(tmp_ls)
        cluster_dict_cross.append(ls)
    return cluster_dict_cross    


def calculateClusterCrossRegion(cluster_dict_cross):
    cluster_cross_region = []
    for cluster in cluster_dict_cross:
        starts1 =   []
        starts2 =   []
        for i in range(0,len(cluster)):
            starts1.append(cluster[i][0].reference_start)
            starts2.append(cluster[i][1].reference_start)
        if max(starts1) - min(starts1) < rlen:
            starts1[-1] = starts1[-1] + rlen
        if max(starts2) - min(starts2) < rlen:
            starts2[-1] = starts2[-1] + rlen
        tmp = [starts1, starts2]
        cluster_cross_region.append(tmp)
    return cluster_cross_region    


def calculateSim_bw_cluster_cross(cluster_cross_region, ref_name, cross_name, ref_genome):
    sim_bw_cluster_cross = []
    for i in range(0, len(cluster_cross_region)):
        s1 = ref_genome.fetch(ref_name, min(cluster_cross_region[i][0]), max(cluster_cross_region[i][0]))
        if len(s1) < rlen:
            s1 = ref_genome.fetch(ref_name, min(cluster_cross_region[i][0]), min(cluster_cross_region[i][0]) + rlen)
            if len(s1) < rlen:
                continue
        s2 = ref_genome.fetch(cross_name,min(cluster_cross_region[i][1]),max(cluster_cross_region[i][1]))
        if len(s2) < rlen:
            s2 = ref_genome.fetch(cross_name,min(cluster_cross_region[i][1]),min(cluster_cross_region[i][1]) + rlen)
            if len(s2) < rlen:
                continue
        tmp = [s1, s2]
        sim_bw_cluster_cross.append(tmp)       
    return sim_bw_cluster_cross   

def uniqueCrossCluster(ref_A):
    unique_sim_cross_index = []
    unique_sim_cross_region = []
    for i in range(0,len(ref_A)):
        unique_sim_cross_index.append(i)
        unique_sim_cross_region.append(ref_A[i])
    return unique_sim_cross_index, unique_sim_cross_region


def calculateCandidateSolutionDict(x_pos,w,h,ii,cluster_dict_cross,reverse):
    candidate_solution_dict={}
    for k in range(-1, reverse, -1):
        tmp=[]
        tmp_right_edge = list(x_pos[k].values())
        right_edge = tmp_right_edge[0]
        for t in range(k,reverse,-1):
            tmp.append(x_pos[t])
        y_pos_tmp={}
        for t in range(0,len(tmp)):
            index=list(tmp[t].keys())[0]
            dict_tmp={index:cluster_dict_cross[ii][index][1].reference_start}
            y_pos_tmp.update(dict_tmp)
        y_pos_tmp_list=sorted(y_pos_tmp.items(), key=lambda d: d[1])
        for t in range(0,len(y_pos_tmp_list)):
            bottom_edge=y_pos_tmp_list[t][1]
            candidate_solution_tmp=[]
            for tt in range(t,len(y_pos_tmp_list)):
                index=y_pos_tmp_list[tt][0]
                candidate_solution_tmp.append(cluster_dict_cross[ii][index])
            if len(candidate_solution_tmp) not in candidate_solution_dict:
                lenth_candidate=len(candidate_solution_tmp)
                candidate_solution_tmp.append(bottom_edge)
                candidate_solution_tmp.append(right_edge)
                ls=[]
                ls.append(candidate_solution_tmp)
                tmp_dict={lenth_candidate:ls}
                candidate_solution_dict.update(tmp_dict)
            else:
                lenth_candidate=len(candidate_solution_tmp)
                candidate_solution_tmp.append(bottom_edge)
                candidate_solution_tmp.append(right_edge)
                candidate_solution_dict.get(lenth_candidate).append(candidate_solution_tmp)
    return candidate_solution_dict


def calDistributionReads(candidate_solution_dict):
    max_num_index = len(candidate_solution_dict)
    distribution_reads = []
    for j in range(0,len(candidate_solution_dict.get(max_num_index))):
        distribution_candidate = []
        for k in range(0,len(candidate_solution_dict.get(max_num_index)[j])-2):
            tmp = []
            x = candidate_solution_dict.get(max_num_index)[j][-1]-candidate_solution_dict.get(max_num_index)[j][k][0].reference_start
            y = candidate_solution_dict.get(max_num_index)[j][k][1].reference_start-candidate_solution_dict.get(max_num_index)[j][-2]
            tmp.append(x)
            tmp.append(y)
            tmp.append(candidate_solution_dict.get(max_num_index)[j][k])
            distribution_candidate.append(tmp)
        distribution_reads.append(distribution_candidate)
    return distribution_reads

def calCandidateSolution(w,h,unique_sim_cross_index,cluster_cross_region,cluster_dict_cross):
    candidate_solution  =   []
    for i in range(0,len(unique_sim_cross_index)):
        ii = unique_sim_cross_index[i]
        num = len(cluster_cross_region[ii][0])
        x_pos = []
        for j in range(0,num):
            dict_tmp = {j:cluster_dict_cross[ii][j][0].reference_start}
            x_pos.append(dict_tmp)
        reverse = (-1)*num-1
        candidate_solution_dict = calculateCandidateSolutionDict(x_pos,w,h,ii,cluster_dict_cross,reverse)
        distribution_reads = calDistributionReads(candidate_solution_dict)
        sum_pos = []
        for j in range(0,len(distribution_reads)):
            tmp = 0
            for k in range(0,len(distribution_reads[j])):
                tmp = tmp + distribution_reads[j][k][0] + distribution_reads[j][k][1]
            sum_pos.append(tmp)
        min_val = sum_pos[0]
        min_index = 0
        for j in range(0,len(sum_pos)):
            if sum_pos[j] < min_val:
                min_index = j
        if len(distribution_reads[min_index]) >= minSample:
            candidate_solution.append(distribution_reads[min_index])
        distribution_reads = []
        candidate_solution_dict = {}
        del candidate_solution_dict
        del distribution_reads
    return candidate_solution

def calImprovedCrossCluster(candidate_solution):
    improved_cross_cluster  =   []
    for i in range(0, len(candidate_solution)):
        tmp     =   []
        cross_x =   []
        cross_y =   []
        for j in range(0, len(candidate_solution[i])):
            cross_x.append(candidate_solution[i][j][2][0].reference_start)
            cross_y.append(candidate_solution[i][j][2][1].reference_start)
        cross_x.sort()
        cross_y.sort()
        tmp.append(cross_x)
        tmp.append(cross_y)
        improved_cross_cluster.append(tmp)
    return improved_cross_cluster

def addSub(htgCluster,key,sub_key):
    add_sub_dict={}
    for sub_sub_key in htgCluster.get(key).get(sub_key):
        ls=addSS(htgCluster,key,sub_key,sub_sub_key)
        if sub_sub_key=='read1pos_pos':
            tmp_dict={'read2pos_pos':ls}
        if sub_sub_key=='read1pos_neg':
            tmp_dict={'read2neg_pos':ls}
        if sub_sub_key=='read1neg_pos':
            tmp_dict={'read2pos_neg':ls}
        if sub_sub_key=='read1neg_neg':
            tmp_dict={'read2neg_neg':ls}
        if sub_sub_key=='read2pos_pos':
            tmp_dict={'read1pos_pos':ls}
        if sub_sub_key=='read2pos_neg':
            tmp_dict={'read1neg_pos':ls}
        if sub_sub_key=='read2neg_pos':
            tmp_dict={'read1pos_neg':ls}
        if sub_sub_key=='read2neg_neg':
            tmp_dict={'read1neg_neg':ls}
        add_sub_dict.update(tmp_dict)
    return add_sub_dict

def modifySS(s1,s2):
    ls=[]
    if len(s1)>len(s2):
        for i in range(0,len(s1)):
            tmp=[s1[i][1],s1[i][0]]
            ls.append(tmp)
        return s1,ls
    else:
        for i in range(0,len(s2)):
            tmp=[s2[i][1],s2[i][0]]
            ls.append(tmp)
        return ls,s2

def addSS(htgCluster,key,sub_key,sub_sub_key):
    ls=[]
    for i in range(0,len(htgCluster.get(key).get(sub_key).get(sub_sub_key))):
        val=[htgCluster.get(key).get(sub_key).get(sub_sub_key)[i][1],htgCluster.get(key).get(sub_key).get(sub_sub_key)[i][0]]
        ls.append(val)
    return ls

def makeSame(dict1,dict2,sub_sub_key,tkey):  
    t1,t2=modifySS(dict1.get(sub_sub_key),dict2.get(tkey))
    tmp1={sub_sub_key:t1}
    tmp2={tkey:t2}
    dict1.update(tmp1)
    dict2.update(tmp2)

def modify(htgCluster,key,sub_key,sub_sub_key,tkey,extra_dict):
    if tkey not in htgCluster.get(sub_key).get(key):
        ls=addSS(htgCluster,key,sub_key,sub_sub_key)
        tmp_dict={tkey:ls}
        up_dict={key:tmp_dict}
        up_up_dict={sub_key:up_dict}
        extra_dict.update(up_up_dict)
    else:
        makeSame(htgCluster.get(key).get(sub_key),htgCluster.get(sub_key).get(key),sub_sub_key,tkey)

def clearDuplicate(htgCluster):
    extra_dict={} 
    for key in htgCluster:
        for sub_key in htgCluster.get(key):
            if sub_key not in htgCluster:
                add_sub_dict=addSub(htgCluster,key,sub_key)
                add_dict={key:add_sub_dict}
                tmp={sub_key:add_dict}
                extra_dict.update(tmp)
            else:
                if key not in htgCluster.get(sub_key):
                    add_sub_dict=addSub(htgCluster,key,sub_key)
                    add_dict={key:add_sub_dict}
                    tmp={sub_key:add_dict}
                    extra_dict.update(tmp)
                else:
                    for sub_sub_key in htgCluster.get(key).get(sub_key):
                        if sub_sub_key=='read1pos_pos':
                            tkey='read2pos_pos'
                        if sub_sub_key=='read1pos_neg':
                            tkey='read2neg_pos'
                        if sub_sub_key=='read1neg_pos':
                            tkey='read2pos_neg'
                        if sub_sub_key=='read1neg_neg':
                            tkey='read2neg_neg'
                        if sub_sub_key=='read2pos_pos':
                            tkey='read1pos_pos'
                        if sub_sub_key=='read2pos_neg':
                            tkey='read1neg_pos'
                        if sub_sub_key=='read2neg_pos':
                            tkey='read1pos_neg'
                        if sub_sub_key=='read2neg_neg':
                            tkey='read1neg_neg'
                        modify(htgCluster,key,sub_key,sub_sub_key,tkey,extra_dict)
    return extra_dict

def judgeDuplicate(htgCluster):
    for key in htgCluster:
        for sub_key in htgCluster.get(key):
            if sub_key not in htgCluster:
                return False
            else:
                if key not in htgCluster.get(sub_key):
                    return False
                else:
                    for sub_sub_key in htgCluster.get(key).get(sub_key):
                        if sub_sub_key  ==  'read1pos_pos':
                            tkey    =   'read2pos_pos'
                        if sub_sub_key  ==  'read1pos_neg':
                            tkey    =   'read2neg_pos'
                        if sub_sub_key  ==  'read1neg_pos':
                            tkey    =   'read2pos_neg'
                        if sub_sub_key  ==  'read1neg_neg':
                            tkey    =   'read2neg_neg'
                        if sub_sub_key  ==  'read2pos_pos':
                            tkey    =   'read1pos_pos'
                        if sub_sub_key  ==  'read2pos_neg':
                            tkey    =   'read1neg_pos'
                        if sub_sub_key  ==  'read2neg_pos':
                            tkey    =   'read1pos_neg'
                        if sub_sub_key  ==  'read2neg_neg':
                            tkey    =   'read1neg_neg'
                        if tkey not in htgCluster.get(sub_key).get(key):
                            return False
    return True    

def print_junction(f, key, sub_key, sub_sub_key, pos1, pos2, pos1_left, pos1_right, pos2_left, pos2_right, num_sup):
    if sub_sub_key  ==  'read1pos_pos' or sub_sub_key  ==  'read2pos_pos' or sub_sub_key  ==  'read2neg_neg' or sub_sub_key  ==  'read1neg_neg':
        f.write( key + ", " + str(pos1) + ", " + str(pos1_left) + ", "+str(pos1_right) + ", "+ sub_key + ", " 
            + str(pos2) + ", " + str(pos2_left) + ", "+str(pos2_right) + ", "+ str(num_sup)+ ", "+"False" +'\n' )
    if sub_sub_key  ==  'read1pos_neg' or sub_sub_key  ==  'read2neg_pos' or sub_sub_key  ==  'read1neg_pos' or sub_sub_key  ==  'read2pos_neg':
        f.write( key + ", " + str(pos1) + ", " + str(pos1_left) + ", "+str(pos1_right) + ", "+ sub_key + ", " 
            + str(pos2) + ", " + str(pos2_left) + ", "+str(pos2_right) + ", "+ str(num_sup)+ ", "+"True" +'\n' )

def calculateCandidateBkpList(cluster_label_dict, dict_xy, sub_sub_key):
    candidate_bkp_list = []
    for key1 in cluster_label_dict:
        candidate_bkp = []
        bkp_A = []
        bkp_B = []
        for i in range(len(cluster_label_dict.get(key1))):
            bkp_A.append(dict_xy.get(sub_sub_key)[cluster_label_dict.get(key1)[i]].reference_start)
            bkp_B.append(dict_xy.get(sub_sub_key)[cluster_label_dict.get(key1)[i]].next_reference_start)
        bkp_A.sort()
        bkp_B.sort()
        candidate_bkp = [bkp_A, bkp_B]
        candidate_bkp_list.append(candidate_bkp)
    return candidate_bkp_list

def worker(preClusterData, ref_name, file_name, ref_dict_Interact_Big):
    scanned_pair_ref = {}
    key = ref_name
    # print (len(preClusterData))
    for sub_key in preClusterData.get(key):
        cross_name = sub_key
        if cross_name in scanned_pair_ref:
            if ref_name in scanned_pair_ref[cross_name]:
                continue
        if ref_name not in scanned_pair_ref:
            tmp_dict = {ref_name : [cross_name]}
            scanned_pair_ref.update(tmp_dict)
        else:
            scanned_pair_ref[ref_name].append(cross_name)
        if cross_name not in scanned_pair_ref:
            tmp_dict = {cross_name : [ref_name]}
            scanned_pair_ref.update(tmp_dict)
        else:
            scanned_pair_ref[cross_name].append(ref_name)
        dict_xy = preClusterData.get(key).get(sub_key)
        # if len(dict_xy) < minSample:
        #     continue
        # print (key, sub_key, len(dict_xy))
        for sub_sub_key in dict_xy:
            cluster_label_dict = clusterBasedOnDensity(dict_xy,sub_sub_key)
            improved_cross_cluster = calculateCandidateBkpList(cluster_label_dict, dict_xy, sub_sub_key)
            if len(improved_cross_cluster) == 0:
                continue
            f = open(file_name,  "a")
            if sub_sub_key  ==  'read1pos_pos' or sub_sub_key  ==  'read2neg_neg':
                i = 0
                while i < len(improved_cross_cluster):
                    pos1_left = min(improved_cross_cluster[i][0])
                    pos1_right = max(improved_cross_cluster[i][0])
                    pos2_left = min(improved_cross_cluster[i][1])
                    pos2_right = max(improved_cross_cluster[i][1])
                    pos1 = improved_cross_cluster[i][0][-1]
                    pos2 = improved_cross_cluster[i][1][0]
                    num_sup = len(improved_cross_cluster[i][0])
                    print_junction( f,    key,     sub_key,    sub_sub_key,    pos1,   pos2,   pos1_left, pos1_right, pos2_left, pos2_right, num_sup)
                    i = i + 1             
            if sub_sub_key  ==  'read1pos_neg' or sub_sub_key  ==  'read2neg_pos':
                i = 0
                while i < len(improved_cross_cluster):
                    pos1_left = min(improved_cross_cluster[i][0])
                    pos1_right = max(improved_cross_cluster[i][0])
                    pos2_left = min(improved_cross_cluster[i][1])
                    pos2_right = max(improved_cross_cluster[i][1])
                    pos1    =   improved_cross_cluster[i][0][-1]
                    pos2    =   improved_cross_cluster[i][1][-1]
                    num_sup =   len(improved_cross_cluster[i][0])
                    print_junction( f,    key,     sub_key,    sub_sub_key,    pos1,   pos2,   pos1_left, pos1_right, pos2_left, pos2_right, num_sup)
                    i = i + 1
            if sub_sub_key  ==  'read1neg_pos' or sub_sub_key  ==  'read2pos_neg':
                i = 0
                while i < len(improved_cross_cluster):
                    pos1_left = min(improved_cross_cluster[i][0])
                    pos1_right = max(improved_cross_cluster[i][0])
                    pos2_left = min(improved_cross_cluster[i][1])
                    pos2_right = max(improved_cross_cluster[i][1])
                    pos1    =   improved_cross_cluster[i][0][0]
                    pos2    =   improved_cross_cluster[i][1][0]
                    num_sup =   len(improved_cross_cluster[i][0])
                    print_junction( f,    key,     sub_key,    sub_sub_key,    pos1,   pos2,   pos1_left, pos1_right, pos2_left, pos2_right, num_sup)
                    i = i + 1
            if sub_sub_key  ==  'read1neg_neg' or sub_sub_key  ==  'read2pos_pos':
                i = 0
                while i < len(improved_cross_cluster):
                    pos1_left = min(improved_cross_cluster[i][0])
                    pos1_right = max(improved_cross_cluster[i][0])
                    pos2_left = min(improved_cross_cluster[i][1])
                    pos2_right = max(improved_cross_cluster[i][1])
                    pos1    =   improved_cross_cluster[i][0][0]
                    pos2    =   improved_cross_cluster[i][1][-1]
                    num_sup =   len(improved_cross_cluster[i][0])
                    print_junction(f, key, sub_key, sub_sub_key, pos1, pos2, pos1_left, pos1_right, pos2_left, pos2_right, num_sup)
                    i = i + 1
            f.close()
            improved_cross_cluster = []
    # print(ref_name+'_processed.')

def get_processed_ref(output_filename):
    fi = open(output_filename, "r")
    processed_ref_list = []
    while 1:
        buf = fi.readline()
        buf = buf.strip('\n')
        if not buf:
            break
        buf = re.split(r'[:;,\s]\s*', buf)
        if buf[0] not in processed_ref_list:
            processed_ref_list.append(buf[0])
    return processed_ref_list

def get_processed_junction_refs(output_filename):
    fi = open(output_filename, "r")
    processed_junction_refs_list = []
    while 1:
        buf = fi.readline()
        buf = buf.strip('\n')
        if not buf:
            break
        buf = re.split(r'[:;,\s]\s*', buf)
        if [buf[0],buf[4]] not in processed_junction_refs_list:
            processed_junction_refs_list.append([buf[0],buf[4]])
    return processed_junction_refs_list

def cal_RAM():
    # Getting all memory using os.popen()
    total_memory, used_memory, free_memory = map(
        int, os.popen('free -t -m').readlines()[-1].split()[1:])
    
    # Memory usage
    logging.info('RAM Used (GB): %s'%(used_memory/1000000000) )

def main():
    split_num = args["t"]
    output_filename = args["o"]
    if not os.path.exists(output_filename):
        os.mknod(output_filename)
    bam_name = args["u"]
    # processed_ref_list = [] #get_processed_ref(output_filename)
    bamfile = pysam.AlignmentFile(filename = bam_name, mode = 'rb')
    dict_Interact_Big = calCrossReads(bamfile) # get junction reads
    ref_dict_Interact_Big = indexReadBasedOnRef(dict_Interact_Big)
    ref_list_Interact_Big = indexReadBasedOnPos(ref_dict_Interact_Big)
    htg_dict = htgMATRIX(dict_Interact_Big,ref_list_Interact_Big)
    preClusterData = prepareClusterData(htg_dict)
    logging.info ("successfully load reads into memory.")
    # cal_RAM()

    del ref_list_Interact_Big
    del htg_dict
    del dict_Interact_Big

    tmp_ref_name_list = list(preClusterData.keys())
    ref_name_list = []
    for ref_name in tmp_ref_name_list:
        # if ref_name not in processed_ref_list:
        ref_name_list.append(ref_name)
    logging.info ("No. of genomes: %s"%( len(ref_name_list)))
    i = 0
    while i < len(ref_name_list):
        # print (i)
        if i % 500 == 0:
            logging.info ("call raw bkp for %s genomes."%(i + 1))
            # cal_RAM()
            
        start_pos = i
        end_pos = min(i + split_num, len(ref_name_list))
        procs = []
        for j in range(start_pos, end_pos):
            p = multiprocessing.Process(target = worker, args = (preClusterData, ref_name_list[j], output_filename, ref_dict_Interact_Big))
            # if ref_name_list[j] == 'GUT_GENOME014555_10':
            #     print('ref %s is processing, NO.%s of %s.'%(ref_name_list[j], j, len(ref_name_list)), len(preClusterData.get(ref_name_list[j])))
            procs.append(p)
            p.start()
        for proc in procs:
            proc.join()
        i = i + split_num
    logging.info ("Raw HGT breakpoint detection is finished.\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Get raw hgt breakpoints", add_help=False, \
    usage="%(prog)s -h", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    required = parser.add_argument_group("required arguments")
    optional = parser.add_argument_group("optional arguments")
    # required.add_argument("-r", type=str, help="<str> Extracted Metagenomic reference", metavar="\b")
    required.add_argument("-o", type=str, help="<str> output file of raw breakpoints.", metavar="\b")
    required.add_argument("-u", type=str, help="<str> unique reads bam file.", metavar="\b")
    optional.add_argument("-t", type=int, default=5, help="<int> number of threads", metavar="\b")
    optional.add_argument("-n", type=int, default=1, help="<0/1> 1 indicates the aligned-ref is extracted.", metavar="\b")
    optional.add_argument("-a", type=int, default=1, help="<0/1> 1 indicates retain reads with XA tag.", metavar="\b")
    optional.add_argument("-h", "--help", action="help")
    args = vars(parser.parse_args())

    logging.basicConfig(filename=args["o"][:-7] + "log",
                        filemode='a',
                        format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                        datefmt='%H:%M:%S',
                        level=logging.DEBUG)

    unique_bam_name = args["u"]
    logging.info ("start calling raw bkp...")
    unique_bamfile = pysam.AlignmentFile(filename = unique_bam_name, mode = 'rb')
    mean, sdev, rlen, rnum = getInsertSize(unique_bamfile)
    unique_bamfile.close()
    insert_size = int(mean + 2*sdev)
    rlen = int(rlen)
    logging.info ("read length is %s, insert size is %s, after counting %s reads."%(rlen, insert_size, rnum))
    sys.exit(main())
    # sys.exit(main_split())  # try to split bam into small blocks, not work
