#!/usr/bin/env python3
import sys
import re
import itertools
import os
from subprocess import call

from Hotpep.hotpep_data import hotpep_data_path

protein_dir_name = hotpep_data_path("fungus_fungus")
peptide_dir_name = hotpep_data_path("CAZY_PPR_patterns/GH")
thread_no = 1
peptide_length = 6 #length of conserved peptides
hit_cut_off = 3 #number of conserved peptides necessary to classify a protein
freq_cut_off = 1.0 #minimum sum of frequencies necessary to classify a protein


argc = len(sys.argv)
if argc > 1:
	thread_no = int(sys.argv[1])
if argc > 2:
	protein_dir_name = sys.argv[2].replace("?", " ")
if argc > 3:
	peptide_dir_name = sys.argv[3].replace("?", " ")
if argc > 4:
	peptide_length = int(sys.argv[4])
if argc > 5:
	hit_cut_off = int(sys.argv[5])
if argc > 6:
	freq_cut_off = float(sys.argv[6])
outf_name = protein_dir_name+"/thread"+str(thread_no)+".txt"

class Protein:
	def __init__(self, sequ):
		self.seq = sequ.upper()
		self.name = None
		self.peptides = None
		self.hits = None
		self.freq = None
		self.group = None
		self.classified = None
	
	def make_nmer_peptides(self, n):
		self.peptides = []
		seq = self.seq
		for x in range(n):
			for y in range(x, len(seq), n):
				self.peptides.append(seq[y:y+n])
		set(self.peptides)
		
class Group:
	def __init__(self, fami, numb):
		self.fam = fami
		self.number = numb
		self.pep_hash = {}
		self.hits = None
		self.freq = None



prot_array = []
#####################
seq = ""
name = ""
p = ""
first = True
with open(protein_dir_name+"/orfs"+str(thread_no)+".txt") as f:
        
	for line in f:
		if line.startswith(">"):
			if not first:
				p = Protein(seq)
				p.name = name
				p.make_nmer_peptides(peptide_length)
				prot_array.append(p)
				seq = ""
			name = line.rstrip()
			first = False
		else:
			seq += line.rstrip()
p = Protein(seq)
p.name = name
p.make_nmer_peptides(peptide_length)
prot_array.append(p)
##########
#f = open(protein_dir_name+"/orfs"+str(thread_no)+".txt", 'r').readlines()
#for x in range(len(f)):
	#if f[x].startswith(">"):
		#p = Protein(f[x+1].rstrip())
		#p.name = f[x].rstrip()
		#p.make_nmer_peptides(peptide_length)
		#prot_array.append(p)
###################
pep_list_array = []
try:
	pep_list_array = open(peptide_dir_name+"/fam_list.txt", 'r').readlines()
except:
	pep_list_array = open(peptide_dir_name+"/large_fams.txt", 'r').readlines()
with open(outf_name, 'w') as out:
	for fam in pep_list_array:
		protein_hits = 0
		pep_group_array = []
		fam_all_peps_array = []
		fam = fam.rstrip()
		f = []
		try:
			f = open(peptide_dir_name+"/"+fam+"/"+fam+"_conserved_peptides.txt").readlines()
		except:	
			f = open(peptide_dir_name+"/"+fam+"/"+fam+"_peptides_scores.txt").readlines()
		for x in range(len(f)):
			line = f[x].rstrip()
			if "group" in line:
				g = Group(fam, line.split("group ")[-1])
				pep_array = f[x+1].split(";")
				pep_array.pop()
				for pep in pep_array:
					arr = pep.split(",")
					g.pep_hash[arr[0]] = float(arr[-1])
					fam_all_peps_array.append(arr[0])
				pep_group_array.append(g)
		set(fam_all_peps_array)
		prot_hit_array = []
		for p in prot_array:
			prot_fam_peps = set.intersection(set(p.peptides), set(fam_all_peps_array))
			no_peps = len(prot_fam_peps)
			group_score_array = []
			if no_peps == hit_cut_off:
				index_arr = []
				for pep in prot_fam_peps:
					index_arr.append(p.seq.find(pep))
				index_arr.sort()
				if index_arr[-1]-index_arr[0] > 3:
					no_peps += 1
			if no_peps > hit_cut_off and len(set(list("".join(prot_fam_peps)))) > 4:
				for g in pep_group_array:
					pep_array = set.intersection(set(prot_fam_peps), set(g.pep_hash.keys()))
					hits = len(pep_array)
					freq = 0.0
					for pep in pep_array:
						if hits >= hit_cut_off:
							freq += g.pep_hash[pep]
						if freq >= freq_cut_off:
							group_score_array.append([freq, hits, g.number, pep_array])
			if len(group_score_array) > 0:
				group_score_array.sort(key= lambda x: (int(x[0]), int(x[1]), -int(x[2])))
				if group_score_array[-1][1] >= hit_cut_off and group_score_array[-1][0] >= freq_cut_off:
					if protein_hits == 0:
						out.write("Family "+fam+"\n")
					out.write(p.name+'\n')
					out.write(p.seq+'\n')
					out.write(",".join(group_score_array[-1][3])+'\n')
					out.write(str(group_score_array[-1][1])+'\n')
					out.write(str(float(str(group_score_array[-1][0])[0:4]))+'\n')
					out.write(group_score_array[-1][2]+'\n')
					protein_hits += 1
					
call(['cp', outf_name, 'temp'])
			
