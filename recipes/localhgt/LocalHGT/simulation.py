#!/usr/bin/env python3

import os
import numpy as np
import random
import time
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq
import re
import lzma

def DNA_complement2(sequence):
    sequence = sequence[::-1]
    trantab = str.maketrans('ACGTacgtRYMKrymkVBHDvbhd', 'TGCAtgcaYRKMyrkmBVDHbvdh')
    string = sequence.translate(trantab)
    return string

def get_pure_genome(genome):
    return "_".join(genome.split("_")[:-1])

def add_snp(sequence, rate):
    locus_set = {}
    allele = ['A', 'T', 'C', 'G']
    ref_len = len(sequence)
    num = int(ref_len* rate)
    i = 0
    #'''
    while i < num:
        random_locus = np.random.randint(ref_len - 1 )
        if random_locus not in locus_set.keys():
            ref = sequence[random_locus]
            while True:
                allele_index = np.random.randint(4)
                alt = allele[allele_index]
                if alt != ref:
                    break
            # print (random_locus, ref, alt)
            sequence = sequence[:random_locus] + alt + sequence[random_locus+1:]
            # locus_set.append(random_locus)
            locus_set[random_locus] = 1
            i += 1
    return sequence

def add_indel(sequence, rate):
    locus_set = {}
    allele = ['A', 'T', 'C', 'G']
    ref_len = len(sequence)
    num = int(ref_len* rate)
    i = 0
    #'''
    while i < num:
        random_locus = np.random.randint(ref_len - 1 )
        if random_locus not in locus_set.keys():
            if np.random.random() < 0.5:
                #50% for deletion
                sequence = sequence[:random_locus] + sequence[random_locus+1:]
            else:
                #50% for insertion
                allele_index = np.random.randint(4)
                insert_allele = allele[allele_index]
                sequence = sequence[:random_locus] + insert_allele + sequence[random_locus:]
            # locus_set.append(random_locus)
            locus_set[random_locus] = 1
            i += 1
    return sequence       

def extract_uniq_region(map_ref):
    remove_dict = {}
    all_scaffold = {}
    line_num = 0
    for line in lzma.open(map_ref, mode='rt', encoding='utf-8'):
        line_num += 1
        if line_num % 1000000 == 0:
            print (line_num)
        # if line_num > 1000000:
        #     break
        array = line.split()

        #record scaffold name
        if array[0] not in all_scaffold.keys():
            all_scaffold[array[0]] = 1
        #     continue
        
        if float(array[6]) < float(array[7]):
            fir_s = float(array[6])
            fir_e = float(array[7])
        else:
            fir_s = float(array[7])
            fir_e = float(array[6])     
        if float(array[8]) < float(array[9]):
            sec_s = float(array[8])
            sec_e = float(array[9])
        else:
            sec_s = float(array[9])
            sec_e = float(array[8])   

        if array[0] == array[1]:
            if fir_s >= sec_s and fir_s <= sec_e:
                continue
            elif fir_e >= sec_s and fir_e <= sec_e:
                continue

        if float(array[3]) < 50: # length
            continue
        if array[0] not in remove_dict.keys():
            remove_dict[array[0]] = []
        qstart = fir_s#float(array[6])
        qend = fir_e#float(array[7])
        overlap = False
        for loci in remove_dict[array[0]]:
            if qstart < loci[0] and qend > loci[0]:
                loci[0] = qstart
                overlap = True
            elif qstart < loci[1] and qend > loci[1]:
                loci[1] = qend
                overlap = True
            elif qstart >= loci[0] and qend <= loci[1]:
                overlap = True
        if overlap == False:
            remove_dict[array[0]].append([qstart, qend])
    print ("start sort segs...", len(all_scaffold.keys()))
    i = 0
    for scaffold in list(all_scaffold.keys()):
        #sometimes there is no repeat region in the scaffold, it not in remove_dict's keys.
        if scaffold in remove_dict.keys():
            remove_dict[scaffold] = sort_remove_loci(remove_dict[scaffold], scaffold)
        else:
            remove_dict[scaffold] = [[1,'end']]
        i += 1
        if i % 10000 == 0:
            print ("sort", i)
    uniq_segs_loci = remove_dict
    return uniq_segs_loci

def remove_overlap(sorted_remove_loci):
    flag = True
    while flag:
        flag = False
        new_sorted_remove_loci = []
        i = 0
        while i < len(sorted_remove_loci):
            if i + 1 < len(sorted_remove_loci) and sorted_remove_loci[i+1][0] >= sorted_remove_loci[i][0] and sorted_remove_loci[i+1][0] <= sorted_remove_loci[i][1]:
                flag = True
                if sorted_remove_loci[i][1] >= sorted_remove_loci[i+1][1]:
                    new_sorted_remove_loci.append(sorted_remove_loci[i])
                else:
                    new_sorted_remove_loci.append([sorted_remove_loci[i][0], sorted_remove_loci[i+1][1]])
                i += 2
            else:
                new_sorted_remove_loci.append(sorted_remove_loci[i])
                i += 1
        sorted_remove_loci = new_sorted_remove_loci[:]
    return new_sorted_remove_loci

def sort_remove_loci(remove_loci, scaffold):
    sorted_remove_loci = []
    for loci in remove_loci:
        sorted_remove_loci.append(loci)
    flag = True
    while flag:
        flag = False
        for i in range(len(sorted_remove_loci) - 1):
            if sorted_remove_loci[i][0] > sorted_remove_loci[i+1][0]:
                flag = True
                m = sorted_remove_loci[i]
                sorted_remove_loci[i] = sorted_remove_loci[i+1]
                sorted_remove_loci[i+1] = m
    # print ('s',sorted_remove_loci)
    sorted_remove_loci = remove_overlap(sorted_remove_loci)
    start = 1
    uniq_segs_loci = []
    for loci in sorted_remove_loci:
        if int(loci[0]) - start > 1000:
            uniq_segs_loci.append([start, int(loci[0])])
        start = int(loci[1])
    uniq_segs_loci.append([start, 'end'])
    return uniq_segs_loci

def read_fasta(file):
    seq_dict = {}
    fasta_sequences = SeqIO.parse(open(file),'fasta')
    for record in fasta_sequences:
        seq_dict[str(record.id)] = str(str(record.seq))
    #     scaffold_name.append(str(record.id))
    return seq_dict

def blast_map2_self(file, map_ref):
    makedb = 'makeblastdb -in %s -dbtype nucl -out ref'%(file)
    blastn = 'blastn -query %s -outfmt 6 -out %s -db ref'%(file, map_ref)
    os.system(makedb)
    os.system(blastn)

def random_HGT(pa, skip_fq=False):
    truth_HGT = open(pa.outdir +'/%s.true.sv.txt'%(pa.sample), 'w')

    new_seq_dict = pa.seq_dict.copy()
    chrom_list = list(pa.seq_dict.keys())
    chrom_num = len(chrom_list)
    length_change_chroms = {}
    i = 0
    while i < pa.HGT_num:
        first_chrom = np.random.randint(chrom_num)
        second_chrom = np.random.randint(chrom_num)

        # print (first_chrom, second_chrom)
        while first_chrom == second_chrom or pa.species_dict[chrom_list[first_chrom]] == pa.species_dict[chrom_list[second_chrom]]:
            second_chrom = np.random.randint(chrom_num)
        first_chrom = chrom_list[first_chrom]
        second_chrom = chrom_list[second_chrom]

        if first_chrom in length_change_chroms.keys() or second_chrom in length_change_chroms.keys():  #one chrom only envolved in one HGT.
            continue

        first_seq = new_seq_dict[first_chrom]
        second_seq = new_seq_dict[second_chrom]
        if len(first_seq) < 100000 or len(second_seq) < 100000:
            continue

        #make sure no N near the four points.
        first_uniq_region_s, first_uniq_region_e =  uniq_seg(len(pa.seq_dict[first_chrom]), pa.uniq_segs_loci[first_chrom])
        second_uniq_region_s, second_uniq_region_e =  uniq_seg(len(pa.seq_dict[second_chrom]), pa.uniq_segs_loci[second_chrom])

        if first_uniq_region_s + first_uniq_region_e == 0 or second_uniq_region_s + second_uniq_region_e == 0: #one more time
            return 0

        length_change_chroms[first_chrom] = 1
        length_change_chroms[second_chrom] = 1
        if np.random.random() < 0.5: #reverse the seq
            reverse_flag = True
            new_seq_dict[first_chrom] = first_seq[:first_uniq_region_s] + DNA_complement2(second_seq[second_uniq_region_s:second_uniq_region_e])\
             + first_seq[first_uniq_region_s:]
        else:
            reverse_flag = False
            new_seq_dict[first_chrom] = first_seq[:first_uniq_region_s] + second_seq[second_uniq_region_s:second_uniq_region_e]\
             + first_seq[first_uniq_region_s:]  #insert seg from chrom2 to chrom1
        # new_seq_dict[second_chrom] = second_seq[:second_uniq_region_s] + second_seq[second_uniq_region_e:]
        if pa.donor_in_flag == False:
            del new_seq_dict[second_chrom]
        else:
            # if the donor genome is also in the sample
            new_seq_dict[second_chrom] = second_seq[:second_uniq_region_s] + second_seq[second_uniq_region_e:]

        print (i, first_chrom, first_uniq_region_s, second_chrom, second_uniq_region_s, \
        second_uniq_region_e, i, chrom_num)
        print (first_chrom, first_uniq_region_s, second_chrom, second_uniq_region_s,\
         second_uniq_region_e, reverse_flag, file = truth_HGT)

        i += 1

    #we should add mutations to each scaffold.
    t0 = time.time()
    for chrom in new_seq_dict.keys():
        new_seq_dict[chrom] = add_snp(new_seq_dict[chrom], pa.snp_rate)
        new_seq_dict[chrom] = add_indel(new_seq_dict[chrom], pa.indel_rate)
    t1 = time.time()
    if not skip_fq:
        generate_fastq(new_seq_dict, pa)
    else:
        generate_fasta(new_seq_dict, pa) # only generate edited fasta
    print (t1-t0, time.time()-t1)
    truth_HGT.close()
    return 1

def generate_fasta(new_seq_dict, pa):
    fasta_file = pa.outdir+'/%s.true.fasta'%(pa.sample)
    fasta = open(fasta_file, 'w')
    for chrom in new_seq_dict.keys():
        print ('>%s edited genome (contain hgt)'%(chrom), file = fasta)
        print (new_seq_dict[chrom], file = fasta)
    fasta.close()

def generate_fastq(new_seq_dict, pa):
    fasta_file = pa.outdir+'/%s.true.fasta'%(pa.sample)
    fasta = open(fasta_file, 'w')
    i = 0
    sequencing_method = {75:'NS50', 100:'HS20', 150:'HS25', 125:'HS25'}
    for chrom in new_seq_dict.keys():
        print ('>%s'%(chrom), file = fasta)
        print (new_seq_dict[chrom], file = fasta)

        tmp_file = pa.outdir + '/%s.HGT.tmp.fasta'%(pa.sample) 
        tmp_f = open(tmp_file, 'w')
        print ('>%s'%(chrom), file = tmp_f)
        print (new_seq_dict[chrom], file = tmp_f)   
        tmp_f.close()
        ######### random depth ###########
        # dp = np.random.randint(10, 50)

        fq = 'art_illumina -ss %s -nf 0 --noALN -p -i %s -l %s -m %s -s 10 --fcov %s -o %s/%s_HGT_%s_tmp.'\
        %(sequencing_method[pa.reads_len], tmp_file, pa.reads_len, pa.mean_frag, pa.depth, pa.outdir, pa.sample, i)
        # fq = 'wgsim -e 0 -N %s -r 0.00 -S 1 -1 150 -2 150 %s /mnt/d/breakpoints/meta_simu/03.samples//%s_HGT_%s_tmp.1.fq /mnt/d/breakpoints/meta_simu/03.samples//%s_HGT_%s_tmp.2.fq'%(int(len(new_seq_dict[chrom])/6), tmp_file, ID, i, ID, i)
        os.system(fq)
        i += 1
    fasta.close()
    os.system('cat %s/%s_HGT_*_tmp.1.fq >%s/%s.1.fq'%(pa.outdir, pa.sample, pa.outdir, pa.sample))
    os.system('cat %s/%s_HGT_*_tmp.2.fq >%s/%s.2.fq'%(pa.outdir, pa.sample, pa.outdir, pa.sample))
    os.system('rm %s/%s_HGT_*_tmp.*.fq'%(pa.outdir, pa.sample))
    os.system('rm %s'%(tmp_file))

def uniq_seg(chrom_len, chrom_uniq_segs):
    flag = True
    i = 0
    max_HGT_len = 55000
    while flag:
        # print (chrom_len)
        HGT_len = np.random.randint(500,max_HGT_len)
        if HGT_len >= chrom_len:
            print ('HGT_len >= chrom_len')
        locus = np.random.randint(500, chrom_len - HGT_len)
        
        left_flag = False
        right_flag = False
        for segs in chrom_uniq_segs:
            #print (locus, segs)
            if segs[1] == 'end':
                segs[1] = chrom_len 

            if locus > segs[0] + 200 and locus < segs[1] - 200:
                left_flag = True
            if locus + HGT_len > segs[0] + 200 and locus + HGT_len < segs[1] - 200:
                right_flag = True

            if left_flag and right_flag:
                return locus, locus + HGT_len    
        i += 1
        if i > 1000000:
            print ('iterate too many times!')
            # break
            return 0, 0

def UHGG_snp(uniq_segs_loci): 
    species_dict = {} 
    pa = Parameters()
    pa.get_dir("/mnt/d/breakpoints/HGT/uhgg_snp/")
    pa.add_segs(uniq_segs_loci)
    pa.get_uniq_len()

    for snp_rate in pa.snp_level:
    # for snp_rate in [0.06, 0.07, 0.08, 0.09]:
        pa.change_snp_rate(snp_rate)
        for index in range(pa.iteration_times):
            pa.get_ID(index)
            if_success = 0
            while if_success == 0:
                ############random select scaffold###########
                all_ref = pa.outdir + '/%s.fa'%(pa.sample)
                fasta_sequences = SeqIO.parse(open(pa.origin_ref),'fasta')       
                f = open(all_ref, 'w')
                select_num = 0
                for record in fasta_sequences:
                    if len(record.seq) < pa.min_genome:
                        continue
                    if pa.uniq_len[str(record.id)] < pa.min_uniq_len:
                        continue
                    if np.random.random() < pa.random_rate:
                        rec1 = SeqRecord(record.seq, id=str(record.id), description="simulation")
                        SeqIO.write(rec1, f, "fasta") 
                        # uniq_segs_loci[str(record.id)] = [[1, len(record.seq)]]
                        species_dict[str(record.id)] = str(record.id)
                        select_num += 1
                    if select_num == pa.scaffold_num + pa.HGT_num:
                        break

                f.close()
                print ('%s scaffolds were extracted.'%(select_num))
                if select_num ==pa.scaffold_num + pa.HGT_num:
                    seq_dict = read_fasta(all_ref)  
                    pa.add_species(species_dict, seq_dict)                  
                    if_success = random_HGT(pa)

def pro_snp(uniq_segs_loci): 
    species_dict = {} 
    pa = Parameters(progenomes)
    # print (pa.seq_len['1105367.SAMN02673274.JFZB01000004'])
    print (len(pa.seq_len))
    pa.get_dir("/mnt/d/breakpoints/HGT/pro_snp/")
    pa.add_segs(uniq_segs_loci)
    pa.get_uniq_len()
    pa.iteration_times = 1

    for snp_rate in pa.snp_level:
        pa.change_snp_rate(snp_rate)
        for index in range(pa.iteration_times):
            pa.get_ID(index)
            if_success = 0
            while if_success == 0:
                ############random select scaffold###########
                all_ref = pa.outdir + '/%s.fa'%(pa.sample)
                fasta_sequences = SeqIO.parse(open(pa.origin_ref),'fasta')       
                f = open(all_ref, 'w')
                select_num = 0
                for record in fasta_sequences:
                    if len(record.seq) < pa.min_genome:
                        continue
                    if pa.uniq_len[str(record.id)] < pa.min_uniq_len:
                        continue
                    if np.random.random() < pa.random_rate:
                        rec1 = SeqRecord(record.seq, id=str(record.id), description="simulation")
                        SeqIO.write(rec1, f, "fasta") 
                        # uniq_segs_loci[str(record.id)] = [[1, len(record.seq)]]
                        species_dict[str(record.id)] = str(record.id)
                        select_num += 1
                    if select_num == pa.scaffold_num + pa.HGT_num:
                        break

                f.close()
                print ('%s scaffolds were extracted.'%(select_num))
                if select_num ==pa.scaffold_num + pa.HGT_num:
                    seq_dict = read_fasta(all_ref)  
                    pa.add_species(species_dict, seq_dict)                  
                    if_success = random_HGT(pa)

def pro_cami(): 
    pa = Parameters(progenomes)
    pa.get_dir("/mnt/d/breakpoints/HGT/pro_snp/")

    for snp_rate in pa.snp_level: #[0.02, 0.04]:
        pa.change_snp_rate(snp_rate)
        index = 0
        pa.get_ID(index)
        for level in pa.complexity_level:
            cami_ID = pa.sample + '_' + level
            for j in range(1, 3):
                combine = "cat %s/%s.%s.fq %s/%s.fq/%s.%s.fq >%s/%s.%s.fq"%(pa.outdir, pa.sample, j, \
                pa.cami_dir, pa.cami_data[level], pa.cami_data[level], j, pa.outdir, cami_ID, j)
                print (combine)
                os.system(combine)

def UHGG_length(uniq_segs_loci): 
    # different read length
    species_dict = {} 
    pa = Parameters()
    pa.get_dir("/mnt/d/breakpoints/HGT/uhgg_length/")
    pa.add_segs(uniq_segs_loci)
    pa.get_uniq_len()

    for read_length in [100, 125]:
        pa.reads_len = read_length
        for index in range(pa.iteration_times):
            pa.get_ID(index)
            if_success = 0
            while if_success == 0:
                ############random select scaffold###########
                all_ref = pa.outdir + '/%s.fa'%(pa.sample)
                fasta_sequences = SeqIO.parse(open(pa.origin_ref),'fasta')       
                f = open(all_ref, 'w')
                select_num = 0
                for record in fasta_sequences:
                    if len(record.seq) < pa.min_genome:
                        continue
                    if pa.uniq_len[str(record.id)] < pa.min_uniq_len:
                        continue
                    if np.random.random() < pa.random_rate:
                        rec1 = SeqRecord(record.seq, id=str(record.id), description="simulation")
                        SeqIO.write(rec1, f, "fasta") 
                        # uniq_segs_loci[str(record.id)] = [[1, len(record.seq)]]
                        species_dict[str(record.id)] = str(record.id)
                        select_num += 1
                    if select_num == pa.scaffold_num + pa.HGT_num:
                        break

                f.close()
                print ('%s scaffolds were extracted.'%(select_num))
                if select_num ==pa.scaffold_num + pa.HGT_num:
                    seq_dict = read_fasta(all_ref)  
                    pa.add_species(species_dict, seq_dict)                  
                    if_success = random_HGT(pa)

def UHGG_depth(uniq_segs_loci): 
    species_dict = {} 
    pa = Parameters()
    pa.get_dir("/mnt/d/breakpoints/HGT/uhgg_depth/")
    pa.add_segs(uniq_segs_loci)
    pa.get_uniq_len()

    # for depth in [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]:
    #     pa.change_depth(depth)
    #     for index in range(10):
    for depth in [10]:
        pa.change_depth(depth)
        for index in range(9, 10):
            pa.get_ID(index)
            if_success = 0
            while if_success == 0:
                ############random select scaffold###########
                all_ref = pa.outdir + '/%s.fa'%(pa.sample)
                fasta_sequences = SeqIO.parse(open(pa.origin_ref),'fasta')       
                f = open(all_ref, 'w')
                select_num = 0
                for record in fasta_sequences:
                    if len(record.seq) < pa.min_genome:
                        continue
                    if pa.uniq_len[str(record.id)] < pa.min_uniq_len:
                        continue
                    if np.random.random() < pa.random_rate:
                        rec1 = SeqRecord(record.seq, id=str(record.id), description="simulation")
                        SeqIO.write(rec1, f, "fasta") 
                        # uniq_segs_loci[str(record.id)] = [[1, len(record.seq)]]
                        species_dict[str(record.id)] = str(record.id)
                        select_num += 1
                    if select_num == pa.scaffold_num + pa.HGT_num:
                        break

                f.close()
                print ('%s scaffolds were extracted.'%(select_num))
                if select_num ==pa.scaffold_num + pa.HGT_num:
                    seq_dict = read_fasta(all_ref)  
                    pa.add_species(species_dict, seq_dict)                  
                    if_success = random_HGT(pa)

def UHGG_donor(uniq_segs_loci): 
    species_dict = {} 
    pa = Parameters()
    # pa.get_dir("/mnt/d/breakpoints/HGT/donor/")
    pa.add_segs(uniq_segs_loci)
    pa.get_uniq_len()
    pa.HGT_num = 5
    pa.scaffold_num = 5

    flag = [True, False]
    folders = ["in", "not_in"]
    for i in range(2):
        pa.donor_in_flag =  flag[i]
        pa.get_dir("/mnt/d/breakpoints/HGT/donor/" + folders[i] + "/" )
        for index in range(pa.iteration_times):
            pa.get_ID(index)
            if_success = 0
            while if_success == 0:
                ############random select scaffold###########
                all_ref = pa.outdir + '/%s.fa'%(pa.sample)
                fasta_sequences = SeqIO.parse(open(pa.origin_ref),'fasta')       
                f = open(all_ref, 'w')
                select_num = 0
                for record in fasta_sequences:
                    if len(record.seq) < pa.min_genome:
                        continue
                    if pa.uniq_len[str(record.id)] < pa.min_uniq_len:
                        continue
                    if np.random.random() < pa.random_rate:
                        rec1 = SeqRecord(record.seq, id=str(record.id), description="simulation")
                        SeqIO.write(rec1, f, "fasta") 
                        # uniq_segs_loci[str(record.id)] = [[1, len(record.seq)]]
                        species_dict[str(record.id)] = str(record.id)
                        select_num += 1
                    if select_num == pa.scaffold_num + pa.HGT_num:
                        break

                f.close()
                print ('%s scaffolds were extracted.'%(select_num))
                if select_num ==pa.scaffold_num + pa.HGT_num:
                    seq_dict = read_fasta(all_ref)  
                    pa.add_species(species_dict, seq_dict)                  
                    if_success = random_HGT(pa)

def UHGG_frag(uniq_segs_loci): 
    species_dict = {} 
    pa = Parameters()
    # pa.get_dir("/mnt/d/breakpoints/HGT/donor/")
    pa.add_segs(uniq_segs_loci)
    pa.get_uniq_len()

    for frag in [200, 350, 500, 650, 800, 950]:
        pa.mean_frag = frag
        os.system("mkdir /mnt/d/breakpoints/HGT/frag_size/f%s/"%(frag))
        pa.get_dir("/mnt/d/breakpoints/HGT/frag_size/f%s/"%(frag) )
        for index in range(pa.iteration_times):
            pa.get_ID(index)
            if_success = 0
            while if_success == 0:
                ############random select scaffold###########
                all_ref = pa.outdir + '/%s.fa'%(pa.sample)
                # os.system("rm %s.*"%(all_ref))
                fasta_sequences = SeqIO.parse(open(pa.origin_ref),'fasta')       
                f = open(all_ref, 'w')
                select_num = 0
                for record in fasta_sequences:
                    if len(record.seq) < pa.min_genome:
                        continue
                    if pa.uniq_len[str(record.id)] < pa.min_uniq_len:
                        continue
                    if np.random.random() < pa.random_rate:
                        rec1 = SeqRecord(record.seq, id=str(record.id), description="simulation")
                        SeqIO.write(rec1, f, "fasta") 
                        # uniq_segs_loci[str(record.id)] = [[1, len(record.seq)]]
                        species_dict[str(record.id)] = str(record.id)
                        select_num += 1
                    if select_num == pa.scaffold_num + pa.HGT_num:
                        break

                f.close()
                print ('%s scaffolds were extracted.'%(select_num))
                if select_num ==pa.scaffold_num + pa.HGT_num:
                    seq_dict = read_fasta(all_ref)  
                    pa.add_species(species_dict, seq_dict)                  
                    if_success = random_HGT(pa)

def UHGG_cami(): 
    pa = Parameters(uhgg_ref)
    pa.get_dir("/mnt/d/breakpoints/HGT/uhgg_snp/")

    for snp_rate in pa.snp_level: #[0.02, 0.04]:
        pa.change_snp_rate(snp_rate)
        index = 0
        pa.get_ID(index)
        for level in pa.complexity_level:
            cami_ID = pa.sample + '_' + level
            for j in range(1, 3):
                combine = "cat %s/%s.%s.fq %s/%s.%s.fq >%s/%s.%s.fq"%(pa.outdir, pa.sample, j, \
                pa.cami_dir, pa.cami_data[level], j, pa.outdir, cami_ID, j)
                print (combine)
                os.system(combine)

def UHGG_cami2():  # discarded function
    pa = Parameters()
    pa.get_dir("/mnt/d/breakpoints/HGT/uhgg_snp/")
    com = Complexity(uhgg_ref)
    for snp_rate in [0.02, 0.04]:
        pa.change_snp_rate(snp_rate)
        index = 0
        pa.get_ID(index)
        for level in pa.complexity_level:
            for j in range(1, 3):
                combine = f"cat {pa.outdir}/{pa.sample}.{j}.fq {com.complexity_dir}/{level}.{j}.fq >{pa.outdir}/{pa.sample}_{level}.{j}.fq"
                print (combine)
                os.system(combine)

def UHGG_amount():   # generate complex sample to evaluate the relationship between data amount and speed
    h = open("/mnt/d/breakpoints/HGT/run_localHGT_amount.sh", 'w')
    f = open("/mnt/d/breakpoints/HGT/run_lemon_amount.sh", 'w')
    print ("export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/wangshuai/miniconda3/envs/lemon/lib", file = f)
    pa = Parameters(uhgg_ref)
    pa.get_dir("/mnt/d/breakpoints/HGT/uhgg_snp/")
    amount_dir = "/mnt/d/breakpoints/HGT/uhgg_amount"
    amount_result_dir = "/mnt/d/breakpoints/HGT/uhgg_amount_result/"
    amount_result_lemon = "/mnt/d/breakpoints/HGT/uhgg_amount_lemon/"
    com = Complexity()
    for snp_rate in [0.01]:
        pa.change_snp_rate(snp_rate)
        index = 0
        pa.get_ID(index)
        # for level in pa.complexity_level:
        for level in ["high"]:
            cami_ID = pa.sample + '_' + level
            """
            for j in range(1, 3):
                combine = "cat %s/%s.%s.fq %s/%s.%s.fq >%s/%s.%s.fq"%(pa.outdir, pa.sample, j, \
                pa.cami_dir, pa.cami_data[level], j, amount_dir, cami_ID, j)
                # print (combine)
                # os.system(combine)
                full_fq = "%s/%s.%s.fq"%(amount_dir, cami_ID, j)
                for z in range(1,10):
                    prop = round(z * 0.1, 2)
                    command = f"seqkit sample -s 123 -j 10 -p {prop} {full_fq} > {amount_dir}/{cami_ID}_{prop}_{j}.fq"
                    print (command)
                    # os.system(command)
            """
            for z in range(1,11):
                prop = round(z * 0.1, 2)
                # if prop != 0.1:
                #     continue
                
                for rep in range(5, 6):
                    run = f"""/usr/bin/time -v -o {amount_result_dir}/{cami_ID}_{prop}_{rep}.time python /mnt/d/breakpoints/script/scripts/main.py --seed 8 -r /mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna\
                    --fq1 {amount_dir}/{cami_ID}_{prop}_1.fq --fq2 {amount_dir}/{cami_ID}_{prop}_2.fq -s {cami_ID}_{prop}_{rep} -o {amount_result_dir}
                    """
                    myfile = f"{amount_result_dir}/{cami_ID}_{prop}_{rep}.acc.csv"
                    if not os.path.isfile(myfile):
                        print (run, file = h)

                    run = f"""/usr/bin/time -v -o {amount_result_lemon}/{cami_ID}_{prop}_{rep}.time bash /mnt/d/breakpoints/lemon/pipeline.sh /mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna\
                    {amount_dir}/{cami_ID}_{prop}_1.fq  {amount_dir}/{cami_ID}_{prop}_2.fq {cami_ID}_{prop}_{rep} {amount_result_lemon}
                    """
                    myfile = f"{amount_result_lemon}/{cami_ID}_{prop}_{rep}.acc.csv"
                    # print (myfile)
                    if not os.path.isfile(myfile):
                        print (run, file = f)               

    h.close()
    f.close()

def get_base_number(fasta_file):
    total_bases = 0

    for record in SeqIO.parse(fasta_file, "fasta"):
        total_bases += len(record.seq)


    return total_bases

def UHGG_abundance(uniq_segs_loci):  # not using
    species_dict = {} 
    pa = Parameters(uhgg_ref)
    pa.HGT_num = 20
    pa.get_dir(workdir)
    pa.add_segs(uniq_segs_loci)
    pa.get_uniq_len()
    pa.donor_in_flag = True
    # pa.random_rate = 0.01

    # for depth in [10]:
    #     pa.change_depth(depth)
    np.random.seed(0)
    for index in range(1):
        pa.get_ID(index)
        if_success = 0
        pure_genome_dict = {}
        while if_success == 0:
            ############random select scaffold###########
            all_ref = pa.outdir + '/%s.fa'%(pa.sample)
            fasta_sequences = SeqIO.parse(open(pa.origin_ref),'fasta')       
            f = open(all_ref, 'w')
            select_num = 0
            for record in fasta_sequences:
                if len(record.seq) < pa.min_genome:
                    continue
                if pa.uniq_len[str(record.id)] < pa.min_uniq_len:
                    continue
                if get_pure_genome(str(record.id)) in pure_genome_dict: ## one species only have one HGT event
                    continue
                if np.random.random() < pa.random_rate:
                    rec1 = SeqRecord(record.seq, id=str(record.id), description="simulation")
                    SeqIO.write(rec1, f, "fasta") 
                    # uniq_segs_loci[str(record.id)] = [[1, len(record.seq)]]
                    species_dict[str(record.id)] = str(record.id)
                    select_num += 1
                    pure_genome_dict[get_pure_genome(str(record.id))] = str(record.id)
                if select_num == pa.scaffold_num + pa.HGT_num:
                    break
            f.close()
            print ('%s scaffolds were extracted.'%(select_num))
            # print (pure_genome_dict)
            print ("len(pure_genome_dict)", len(pure_genome_dict))
            if select_num ==pa.scaffold_num + pa.HGT_num:
                seq_dict = read_fasta(all_ref)  
                pa.add_species(species_dict, seq_dict)                  
                if_success = random_HGT(pa, True)

                ### select 60 other genome
                # other_num = 0
                # fasta_sequences = SeqIO.parse(open(pa.origin_ref),'fasta')       
                # for record in fasta_sequences:
                #     if other_num == 160:  ## 60: 1%,  160: 0.5%,  960: 0.1%
                #         break
                #     if np.random.random() < pa.random_rate:
                #         if get_pure_genome(str(record.id)) not in pure_genome_dict:
                #             pure_genome_dict[get_pure_genome(str(record.id))] = ''
                #             other_num += 1

                print ("len(pure_genome_dict)", len(pure_genome_dict))
                ### select genomes for each species
                fasta_file = pa.outdir+'/%s.true.fasta'%(pa.sample)
                os.system(f"cp {fasta_file} {pa.outdir}/{pa.sample}.pure.fasta")
                print (fasta_file)

                fasta = open(fasta_file, 'a')
                fasta_sequences = SeqIO.parse(open(pa.origin_ref),'fasta')    
                for record in fasta_sequences:
                    if get_pure_genome(str(record.id)) in pure_genome_dict and  str(record.id) != pure_genome_dict[get_pure_genome(str(record.id))]:
                        # print (str(record.id))
                        print ('>%s'%(str(record.id)), file = fasta)
                        print (str(record.seq), file = fasta)
                fasta.close()

                fasta = open(fasta_file, 'a')
                fasta_sequences = SeqIO.parse(open("/mnt/d/breakpoints/HGT/abundance/GCF_000005845.2_ASM584v2_genomic.fna"),'fasta')
    
                for record in fasta_sequences:
                    ecoli_record = record
                    for j in range(160):
                        # print (str(record.id))
                        print ('>%s_%s'%(str(ecoli_record.id), j), file = fasta)
                        print (str(ecoli_record.seq), file = fasta)
                fasta.close()
  
def abundance_fq():  # not using
    fasta_file = workdir + "/species20_snp0.01_depth30_reads150_sample_0.true.fasta"
    # fasta_file = workdir + "/species20_snp0.01_depth30_reads150_sample_0.pure.fasta"
    small_ref = workdir + "/species20_snp0.01_depth30_reads150_sample_0.fa"
    pa = Parameters(uhgg_ref)
    pa.get_dir(workdir)
    abundance_result_dir = "/mnt/d/breakpoints/HGT/uhgg_abundance_result/"

    h = open("/mnt/d/breakpoints/HGT/run_localHGT_abundance.sh", 'w')

    total_bases = get_base_number(fasta_file)
    print ("total_bases", total_bases)
    # for amount in range(2, 17, 2):
    for amount in [20]:
        # read_count = amount * 3333334
        sample = f"abun_{abun}_amount_{amount}"
        depth = round(amount * 1000000000.0 /total_bases, 2)
        print (amount, "depth", depth)
        cmd = f"art_illumina -ss HS25 -nf 0 --noALN -p -i {fasta_file} -l {pa.reads_len} -m {pa.mean_frag} -s 10 --fcov {depth} -o {pa.outdir}/{sample}_ "  #-c read count
        # cmd = f"art_illumina -ss HS25 -nf 0 --noALN -p -i {fasta_file} -l {pa.reads_len} -m {pa.mean_frag} -s 10 --rcount {read_count} -o {pa.outdir}/{sample}_ "
        os.system(cmd)

        run = f"""/usr/bin/time -v -o {abundance_result_dir}/{sample}.time python /mnt/d/breakpoints/script/scripts/main.py -r /mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna\
        --fq1 {pa.outdir}/{sample}_1.fq --fq2 {pa.outdir}/{sample}_2.fq -s {sample} -o {abundance_result_dir}
        """
        run = f"""/usr/bin/time -v -o {abundance_result_dir}/{sample}.time python /mnt/d/breakpoints/script/scripts/main.py -r {small_ref}\
        --fq1 {pa.outdir}/{sample}_1.fq --fq2 {pa.outdir}/{sample}_2.fq -s {sample} -o {abundance_result_dir}
        """
        # myfile = f"{abundance_result_dir}/{sample}.acc.csv"
        # if not os.path.isfile(myfile):
        print (run, file = h)
    h.close()



class Parameters():
    def __init__(self, reference):
        self.HGT_num = 20
        self.scaffold_num = self.HGT_num
        self.snp_rate = 0.01
        self.indel_rate = self.snp_rate * 0.1  
        self.depth = 30
        self.reads_len = 150
        self.iteration_times = 10
        self.donor_in_flag = False
        self.min_genome = 100000
        self.min_uniq_len = 20000
        self.random_rate = 0.01
        self.mean_frag = 350
        # self.cami_data = {'low':'RL_S001__insert_270', 'medium':'RM2_S001__insert_270',\
        #  'high':'RH_S001__insert_270'}
        self.cami_data = {'low':'low', 'medium':'medium','high':'high'}
        self.complexity_level = ['high', 'low', 'medium']
        self.snp_level = [round(x*0.01,2) for x in range(1,6)]
        
        self.uniq_segs_loci = {}
        self.species_dict = {}
        self.sample = ''
        self.outdir = ''
        self.origin_ref = reference  #'/mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna'
        self.cami_dir = '/mnt/d/breakpoints/HGT/CAMI/'
        self.seq_dict = {}
        self.seq_len = {}
        self.cal_genome_len()
        self.uniq_len = {}

    def add_segs(self, uniq_segs_loci):
        self.uniq_segs_loci = uniq_segs_loci
        
    def add_species(self, species_dict, seq_dict):
        self.species_dict = species_dict
        self.seq_dict = seq_dict

    def change_snp_rate(self, snp_rate):
        self.snp_rate = snp_rate
        self.indel_rate = snp_rate * 0.1

    def change_depth(self, depth):
        self.depth = depth

    def get_ID(self, index):
        self.sample = 'species%s_snp%s_depth%s_reads%s_sample_%s'%(self.scaffold_num, \
        self.snp_rate, self.depth, self.reads_len, index)

    def get_dir(self, outdir):
        self.outdir = outdir

    def cal_genome_len(self):
        f = open(self.origin_ref+'.fai')
        for line in f:
            array = line.strip().split()
            self.seq_len[array[0].strip()] = int(array[1].strip())
        f.close()
        # print (self.seq_len['1105367.SAMN02673274.JFZB01000004'])

    def get_uniq_len(self):
        print (len(self.seq_len))
        for sca in self.uniq_segs_loci.keys():
            if sca not in self.seq_len:
                continue
            sca_len = 0
            for interval in self.uniq_segs_loci[sca]:
                start = interval[0]
                end = interval[1]
                if end == 'end':
                    end = self.seq_len[sca]
                sca_len += (end- start) 
            self.uniq_len[sca] = sca_len

class Complexity():## discarded function 
    
    def __init__(self):
        self.levels = ['low', 'medium', 'high']
        self.size = {'high':1000000000, 'medium':500000000, 'low':100000000}
        self.depths = {'high':10, 'medium':20, 'low':100}
        self.origin_ref = '/mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna'
        self.complexity_dir = '/mnt/d/breakpoints/HGT/complexity/'
        self.random_rate = 0.1
        self.read_pair_num = int(10000000000/300)

    def select_genome(self, level):
        all_ref = self.complexity_dir + '/%s.fa'%(level)
              
        f = open(all_ref, 'w')
        select_size = 0
        max_size = self.size[level]
        while select_size < max_size:
            fasta_sequences = SeqIO.parse(open(self.origin_ref),'fasta') 
            for record in fasta_sequences:
                if np.random.random() < self.random_rate:
                    rec1 = SeqRecord(record.seq, id=str(record.id), description="simulation")
                    SeqIO.write(rec1, f, "fasta") 
                    select_size += len(record.seq)
                    if select_size >  max_size:
                        break
        print ("genomes selecting done.")
        self.fastq(all_ref, level)

    def fastq(self, genome, level):
        order = f"wgsim -1 150 -2 150 -r 0.001 -N {self.read_pair_num} {genome} \
        {self.complexity_dir}/{level}.1.fq {self.complexity_dir}/{level}.2.fq"
        print (order)
        os.system(order)

    def run(self):
        # for level in self.levels:
        for level in ['high']:    
            print (level)
            self.select_genome(level)

def generate_complexity():
    ## discarded function 
    ## because data is too larger
    com = Complexity()
    com.run()

if __name__ == "__main__":

    t0 = time.time()
    # pa = Parameters()

    uniq_segs_file = "/mnt/d/breakpoints/HGT/UHGG/uniq_region_uhgg.npy"
    blast_file = '/mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna.blast.out'
    uhgg_ref = '/mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna'

    # uniq_segs_file = "/mnt/d/breakpoints/HGT/proGenomes/uniq_region_proGenomes.npy"
    # blast_file = '/mnt/d/breakpoints/HGT/proGenomes/freeze12.contigs.representatives.fasta.blast.out.xz'
    # progenomes = '/mnt/d/breakpoints/HGT/proGenomes/proGenomes_v2.1.fasta'


    # uniq_segs_loci = extract_uniq_region(blast_file)  
    # np.save(uniq_segs_file, uniq_segs_loci)

    # generate_complexity()
    

    # """
    if os.path.isfile(uniq_segs_file):
        uniq_segs_loci = np.load(uniq_segs_file, allow_pickle='TRUE').item()
    else:
        uniq_segs_loci = extract_uniq_region(blast_file)  
        np.save(uniq_segs_file, uniq_segs_loci) 
    t1 = time.time()
    print ('Uniq extraction is done.', t1 - t0)
    print ("genome num:", len(uniq_segs_loci))
    # pro_snp(uniq_segs_loci)
    # pro_cami()
    # UHGG_donor(uniq_segs_loci)
    # UHGG_frag(uniq_segs_loci)
    # UHGG_length(uniq_segs_loci)
    # UHGG_depth(uniq_segs_loci)
    # """
    UHGG_amount()

    # abun = 0.5
    # workdir = "/mnt/d/HGT/abundance/abun_%s/"%(abun)
    # # UHGG_abundance(uniq_segs_loci)
    # abundance_fq()