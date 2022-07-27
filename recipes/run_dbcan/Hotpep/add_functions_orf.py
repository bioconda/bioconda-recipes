#!/usr/bin/env python3
import sys
import os
import os.path
from subprocess import call
import natsort

from Hotpep.hotpep_data import hotpep_data_path

protein_dir_name = hotpep_data_path("fungus_fungus")
if len(sys.argv) > 1:
	protein_dir_name = sys.argv[1].replace("?", " ")
function_significance_limit = 2 #Normally 2 for new patterns (no proteins with this function in group) and 10 for old patterns (sum freq conserved peptides for function in group ) 
score_file = "_group_ec"

peptide_dir_name = hotpep_data_path("CAZY_PPR_patterns/GH")
if len(sys.argv) > 2:
	peptide_dir_name = sys.argv[2].replace("?", " ")
	

fam_group_score_hash = {}
with open(peptide_dir_name+"/fam_list.txt", 'r') as f: ####
	for line in f:
		fam = line.rstrip()
		try:
			with open(peptide_dir_name+"/"+fam+"/"+fam+score_file+".txt", 'r') as f2:
				group_func_hash = {}
				for row in f2:
					row = row.rstrip()
					arr = row.split('\t')
					if len(arr) > 1:
						group_func_hash[arr[0]] = arr[1].replace("*", "x")
			fam_group_score_hash[fam] = group_func_hash
		except:
			pass
			
output_dir_name = protein_dir_name+"/"+peptide_dir_name.split("/")[-1]+"/functions"
if not os.path.exists(output_dir_name):
	call(["mkdir", output_dir_name])

class Protein():
	def __init__(self, sequ):
		self.seq = sequ.upper()
		self.dna = None
		self.name = None
		self.peptides = None
		self.hits = None
		self.freq = None
		self.group = None
		self.fam = None
		self.accession = None
		self.neighbor_seqs = None
		self.orf_hits = None
		self.orf_freq = None
		self.function = None
		self.functions_array = None
	def __repr__(self):
		return '{}: {} {} {}'.format(self.name, self.freq, self.hits, self.function)
		
function_summary_hash = {}
protein_array = []
with open(protein_dir_name+"/"+peptide_dir_name.split("/")[-1]+"/summary.txt", 'r') as f:
	next(f)
	for line in f:
		line = line.rstrip()
		if int(line.split("\t")[1]) > 0:
			with open(protein_dir_name+"/"+peptide_dir_name.split("/")[-1]+"/"+line.split("\t")[0]+".txt", 'r') as f2:
				next(f2)
				p_old = Protein("load")
				p_old.neighbor_seqs = []
				for row in f2:
					row = row.rstrip()
					arr = row.split("\t")
					p = Protein(arr[4])
					p.fam = line.split("\t")[0]
					p.group = arr[0]
					p.name = arr[1]
					p.freq = float(arr[2].replace(",", "."))
					p.hits = int(arr[3])
					p.peptides = arr[6]
					p.neighbor_seqs = []
					p.functions_array = fam_group_score_hash[p.fam][p.group].split(", ")
					function_score = int(p.functions_array[0].split(":")[1].replace(",",""))
					if function_score >= function_significance_limit:
						p.function = p.functions_array[0].split(":")[0]
						if "*" in p.name:
							p_old.neighbor_seqs.append(p)
						else:
							if p_old.seq != "LOAD":
								protein_array.append(p_old)
							p.neighbor_seqs = []
							p_old = p
		if p_old.seq != "LOAD":
			protein_array.append(p_old)

for protein in protein_array:
	if protein.function == None:
		protein_array.delete(protein)
def sort_order(protein):
	func = int(protein.function.replace(".", "").replace("x", "0"))
	return (func, -protein.freq, -protein.hits)
	

if len(protein_array) > 0:
	protein_array.sort(key=sort_order)
	function = protein_array[0].function
	out = open(protein_dir_name+"/"+peptide_dir_name.split("/")[-1]+"/functions/"+function.replace(".","_")+".txt", 'w')
	out.write("fam\tgroup\tFunctions\tseq_no\tORF freq\tORF hits\tsequence\tlength\tpeptides\tFrequency\thits\tDNA\n")
	for p in protein_array:
		if p.function != function:
			function = p.function
			out.close()
			out = open(protein_dir_name+"/"+peptide_dir_name.split("/")[-1]+"/functions/"+function.replace(".","_")+".txt", 'w')
			out.write("fam\tgroup\tFunctions\tseq_no\tORF freq\tORF hits\tsequence\tlength\tpeptides\tFrequency\thits\tDNA\n")
		out.write(p.fam+'\t'+str(p.group)+'\t'+",".join(p.functions_array)+'\t'+p.name.split("|")[0]+'\t'+str(p.orf_freq).replace(".",",")+'\t'+str(p.orf_hits)+'\t'+p.seq+'\t'+str(len(p.seq))+'\t'+p.peptides+'\t'+str(p.freq).replace(".",",")+'\t'+str(p.hits)+'\t'+str(p.dna)+'\n')
		if len(p.neighbor_seqs) > 0:
			for n in neighbor_seqs:
				out.write(n.fam+'\t'+n.group+'\t'+",".join(n.functions_array)+'\t'+n.name.split("|")[0]+'\t'+n.orf_feq.replace(".",",")+'\t'+n.orf_hits+'\t'+n.seq+'\t'+len(n.seq)+'\t'+n.peptides+'\t'+n.freq.replace(".",",")+'\t'+n.hits+'\t'+n.dna+'\n')
	out.close()
	
	function_hash = {}
	function = ""
	for p in protein_array:
		if p.function != function:
			function = p.function
			array = [p.fam]
			function_hash[function] = array
		else:
			function_hash[function].append(p.fam)
	out = open(protein_dir_name+"/"+peptide_dir_name.split("/")[-1]+"/functions/summary.txt", 'w')
	out.write("EC number\thits\tfamily distribution")
	#array = sorted(function_hash, key=lambda x: (x[0].replace(".","").replace("x","0")))
	array = function_hash
	for key in array: 
		out.write(key+'\t'+str(len(array[key])))
		fam_count_hash={}
		for x in array[key]:
			if x not in fam_count_hash:
				fam_count_hash[x] = 0
			fam_count_hash[x] += 1
		#out_arr = natsort.natsorted(fam_count_hash)
		out_arr = fam_count_hash
		for arr in out_arr:
			out.write("\t"+str(out_arr[arr])+" "+arr)
		out.write("\n")	
	out.close()
				
