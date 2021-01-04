import os
sf_folder="/homes/simonchu/simonchu_nobackup/xTEA_rslts/merged_population/"
sf_list=sf_folder+"HGDP_SGDP_1000G_vcf.list"
sf_pop=sf_folder+"HGDP_SGDP_1000G_sample_info2.tsv"
m_sample_pop={}
with open(sf_pop) as fin_pop:
	for line in fin_pop:
		fields=line.split()
		s_sample=fields[0]
		s_pop=fields[3]
		m_sample_pop[s_sample]=s_pop

sf_sample_sva_cnt=sf_folder+"sample_SVA_cnt.csv"
m_pop_cnt={}
with open(sf_list) as fin_list, open(sf_sample_sva_cnt,"w") as fout_cnt:
	fout_cnt.write("Sample,Population,Count\n")
	for line in fin_list:
		fields=line.split()
		s_sample=fields[0]
		sf_vcf=fields[1]
		n_sva=0
		with open(sf_vcf) as fin_vcf:
			for line in fin_vcf:
				if line[0]=="#":
					continue
				if "SVA" in line:
					n_sva+=1
		s_pop=m_sample_pop[s_sample]
		if s_pop not in m_pop_cnt:
			m_pop_cnt[s_pop]=1
		else:
			m_pop_cnt[s_pop]+=1

		fout_cnt.write(s_sample+","+s_pop+","+str(n_sva)+"\n")

sf_pop_sample_cnt=sf_folder+"pop_sample_cnt.csv"
with open(sf_pop_sample_cnt,"w") as fout_pop:
	fout_pop.write("Population,Count\n")
	for s_pop in m_pop_cnt:
		n_sample=m_pop_cnt[s_pop]
		fout_pop.write(s_pop+","+str(n_sample)+"\n")
####