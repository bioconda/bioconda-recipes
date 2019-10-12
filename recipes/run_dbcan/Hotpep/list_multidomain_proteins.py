#!/usr/bin/env python3
import sys
import os
import os.path

from Hotpep.hotpep_data import hotpep_data_path

protein_collection = hotpep_data_path("fungus_fungus/Chaetomium_thermophilum")
if len(sys.argv) > 1:
	protein_collection = sys.argv[1].replace("?", " ")
cazyme_array = ["AAexp"]
if len(sys.argv) > 2:
	cazyme_array = sys.argv[2].split("_")

assension_family_hash = {}

for cazy_class in cazyme_array:
	if os.path.exists(protein_collection+"/"+cazy_class):
		for filename in os.listdir(protein_collection+"/"+cazy_class):
			if "summary" not in filename and filename.endswith(".txt"):
				fam = filename[:-4]
				array = open(protein_collection+"/"+cazy_class+"/"+filename, 'r').readlines()
				array = array[1:]
				for hit in array:
					arr = hit.split('/t')
					if len(arr) >1:
						if arr[1] not in assension_family_hash:
							assension_family_hash[arr[1]] = []
						assension_family_hash[arr[1]].append(fam+"_"+arr[0])

for key in assension_family_hash:
	if len(assension_family_hash[key]) < 2:
		assension_family_hash.pop(key, 0)
array = assension_family_hash
if len(array) > 0:
	with open(protein_collection+"/summary_multidomain_enzymes.txt", "w") as out:
		out.write("Protein\tDomains\n")
		for arr in array:
			out.write(arr[0]+'\t'+'\t'.join(arr[1])+'\n')
			
