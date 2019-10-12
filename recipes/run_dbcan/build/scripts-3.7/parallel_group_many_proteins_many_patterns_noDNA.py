#!python
from multiprocessing.dummy import Pool as ThreadPool
from subprocess import call
import sys
import natsort
import os
import os.path

from Hotpep.hotpep_data import hotpep_data_path

protein_dir_name = hotpep_data_path("fungus_fungus")
if len(sys.argv) > 2:
	protein_dir_name = sys.argv[2].replace("?", " ")
peptide_dir_name = hotpep_data_path("CAZY_PPR_patterns/GH")
if len(sys.argv) > 3:
	peptide_dir_name = sys.argv[3].replace("?", " ")

threads = 8
peptide_length = 6 #length of conserved peptides
hit_cut_off = 3 #number of conserved peptides necessary to classify a protein
freq_cut_off = 1.0 #minimum sum of frequencies necessary to classify a protein

if len(sys.argv) > 1:
	threads = int(sys.argv[1])
if len(sys.argv) > 4:
	peptide_length = int(sys.argv[4])
if len(sys.argv) > 5:
	hit_cut_off = int(sys.argv[5])
if len(sys.argv) > 6:
	freq_cut_off = float(sys.argv[6])
variables = [ protein_dir_name.replace(" ", "?"), peptide_dir_name.replace(" ", "?"), peptide_length, hit_cut_off, freq_cut_off ]

class Protein:
	def __init__(self, sequ):
		self.seq = sequ.upper()
		self.dna = None
		self.name = None
		self.peptides = None
		self.hits = None
		self.freq = None
		self.group = None
		self.subp = None
		self.accession = None
		self.neighbour_seqs = None
		
	
def callCustom(args):
	return call(args, shell=True)
	
print ("Assigning proteins to groups")
args_array = []
var1 = 1
varlist = " ".join(str(x) for x in variables)
pool = ThreadPool(threads)
while var1 <= threads:
	args_array.append(("bact_group_many_proteins_many_patterns.py "+ str(var1) + " " + varlist))
	var1 += 1
pool.map(callCustom, args_array)

print("Collecting Results")

pep_list_array = []
try:
	f = open(peptide_dir_name+"/large_fams.txt", 'r')
except:
	f = open(peptide_dir_name+"/fam_list.txt", 'r')
for line in f:
	pep_list_array.append(line.rstrip())
f.close()
pep_list_hash = {}
for fam in pep_list_array:
	pep_list_hash[fam]=[]
natsort.natsorted(pep_list_array)
var1 = 1
fam = ""
while var1 <= threads:
	f = open(protein_dir_name+"/thread"+str(var1)+".txt", 'r').readlines()
	for x in range(len(f)):
		line = f[x].rstrip()
		if line.startswith("Family"):
			fam = line.split(" ")[-1]
		elif line.startswith(">"):
			p = Protein(f[x+1].rstrip())
			p.name = line
			p.peptides = f[x+2].rstrip()
			p.hits = int(f[x+3].rstrip())
			p.freq = float(f[x+4].rstrip())
			p.group = int(f[x+5].rstrip())
			pep_list_hash[fam].append(p)
	var1 += 1
	
output_dir_name = protein_dir_name+'/Results'
if not os.path.exists(output_dir_name):
	call(["mkdir", output_dir_name])
for fam in pep_list_array:
	hit_array = pep_list_hash[fam]
	#if len(hit_array) > 0:
	fam_file = open(output_dir_name+"/output.txt", "a")
	hit_array.sort(key= lambda x: (x.group, -x.freq, -x.hits))
	for p in hit_array:
		fam_file.write(fam+ '\t' +str(p.group)+"\t"+p.name.split(' ')[0][1:]+"\t"+str(p.freq)+"\t"+str(p.hits)+"\t"+p.peptides+"\n")
	fam_file.close()

