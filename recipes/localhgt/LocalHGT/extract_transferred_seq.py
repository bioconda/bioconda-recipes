#!/usr/bin/env python3

import csv
import os
import pickle

class Acc_Bkp(object):
    def __init__(self, list):
        self.from_ref = list[0]
        self.to_ref = list[2]
        self.from_bkp = int(list[1])
        self.to_bkp = int(list[3])
        self.if_reverse = list[6]
        self.from_side = list[4]
        self.to_side = list[5]
        self.from_ref_genome = "_".join(self.from_ref.split("_")[:-1])
        # self.from_ref_lineage = taxonomy.taxonomy_dict[self.from_ref_genome]
        self.to_ref_genome = "_".join(self.to_ref.split("_")[:-1])
        # self.to_ref_lineage = taxonomy.taxonomy_dict[self.to_ref_genome]
        self.score = float(list[9])

class Find_trans_gene():

    def __init__(self, bkp_file):
        self.bkp_file = bkp_file
        self.sample = bkp_file.split("/")[-1][:-8]
        self.bkps = []
        self.read_bkp()
         
    def read_bkp(self):
        f = open(self.bkp_file)
        all_rows = csv.reader(f)
        for row in all_rows:
            if row[0] == "from_ref":
                continue
            eb = Acc_Bkp(row)
            if eb.from_ref_genome != eb.to_ref_genome:
                self.bkps.append(eb)
        f.close()

    def inferred_transfer_gene(self):
        transferred_record[self.sample] = []
        genome_pair = {}
        for bkp in self.bkps:
            refs = [bkp.from_ref, bkp.to_ref]
            sorted_refs = sorted(refs)
            pair_name = "&".join(sorted_refs)
            if sorted_refs[0] == refs[0]:
                position = [bkp.from_bkp, bkp.to_bkp]
            else:
                position = [bkp.to_bkp, bkp.from_bkp]
            if pair_name not in genome_pair:
                genome_pair[pair_name] = []
            genome_pair[pair_name].append(position)
        
        bed_file = output_dir + self.sample + ".transfer.bed"
        transfer_gene_file = output_dir + self.sample + ".transfer.fasta"
        prefix = output_dir + self.sample
        f = open(bed_file, "w")
        for pair_name in genome_pair:
            if len(genome_pair[pair_name]) == 2:
                from_ref, to_ref = '', ''
                for i in range(2):
                    if abs(genome_pair[pair_name][0][i] - genome_pair[pair_name][1][i]) < bound:
                        to_pos = round((genome_pair[pair_name][0][i] + genome_pair[pair_name][1][i])/2)
                        to_ref = pair_name.split("&")[i]
                    else:
                        from_pos = sorted([genome_pair[pair_name][0][i], genome_pair[pair_name][1][i]])
                        from_ref = pair_name.split("&")[i]
                if from_ref != '' and to_ref != '' and abs(from_pos[0] - from_pos[1]) < 50000:
                    # print (pair_name, genome_pair[pair_name], from_ref, from_pos, to_ref, to_pos)
                    transferred_record[self.sample].append([from_ref, from_pos, to_ref, to_pos])
                    print ("%s:%s-%s" %(from_ref, from_pos[0], from_pos[1]), file = f)
        f.close()
        os.system("samtools faidx -r %s %s > %s"%(bed_file, database, transfer_gene_file))
        os.system("rgi main -n 10 -i %s --clean -o %s.ASG "%(transfer_gene_file, prefix))

    def seg_around_bkp(self):
        self.sample += "_around"
        bed_file = output_dir + self.sample + ".transfer.bed"
        transfer_gene_file = output_dir + self.sample + ".transfer.fasta"
        prefix = output_dir + self.sample
        f = open(bed_file, "w")
        near = 5000

        for bkp in self.bkps:
            print ("%s:%s-%s" %(bkp.from_ref, bkp.from_bkp-near, bkp.from_bkp+near), file = f)
            print ("%s:%s-%s" %(bkp.to_ref, bkp.to_bkp-near, bkp.to_bkp+near), file = f)
        f.close()
        os.system("samtools faidx -r %s %s > %s"%(bed_file, database, transfer_gene_file))
        os.system("rgi main -n 10 -i %s --clean -o %s.ASG "%(transfer_gene_file, prefix))


class Annotation():

    def __init__(self):
        self.gff = gff
        self.near = 100
        self.gene_annotation = {}

    def read_gff(self):
        f = open(self.gff)
        for line in f:
            array = line.split("\t")
            genome = array[0]
            g_type = array[2]
            detail = array[8]
            start = int(array[3])
            end = int(array[4])
            if genome not in self.gene_annotation:
                self.gene_annotation[genome] = {}
                self.gene_annotation[genome]["intervals"] = []
            self.gene_annotation[genome]["intervals"].append([start, end])
            self.gene_annotation[genome][str(start)+ "_"+str(end)] = detail 
        f.close() 

    def given_point(self, genome, locus):
        if genome not in self.gene_annotation:
            return "NA"
        intervals = self.gene_annotation[genome]["intervals"]
        for inter in intervals:
            # print (inter)
            if locus >= inter[0] - self.near and locus <= inter[1] + self.near:
                return self.gene_annotation[genome][str(inter[0])+ "_"+str(inter[1])]
        return "NA"

    def read_dict(self):
        with open("gene_annotation", "rb") as fp:
            self.gene_annotation = pickle.load(fp)
        with open("gene_function", "rb") as fp:
            self.gene_function = pickle.load(fp)



output_dir = "/mnt/d/breakpoints/HGT/transferred_genes/"
database = "/mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna"
bound = 100


transferred_record = {}
all_acc_file = "analysis/acc.list"

for line in open(all_acc_file):
    bkp_file = "analysis/" + line.strip()
    # bkp_file = "/mnt/d/breakpoints/script/analysis/new_result/ERR2726421.acc.csv"
    fts = Find_trans_gene(bkp_file)
    fts.inferred_transfer_gene()
    # break

# with open("analysis/transferred_record", "wb") as fp:
#     pickle.dump(transferred_record, fp)

# gff = "/mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna.gff"
# ann = Annotation()
# ann.read_gff()
# detail = ann.given_point("GUT_GENOME096132_1", 50)
# print (detail)