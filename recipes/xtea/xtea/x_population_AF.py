import os
import sys

l_pop_code=['AFR', 'AMR', 'EAS', 'EUR', 'SAS', 'WAS', 'OCN', 'CAS']
f_base=0.00001
n_level=int(1.0/f_base)+1
n_high_af=0.1

def add_a_site(f_af, s_pop, m_af):
    for i in range(n_level):
        if (float(i)*f_base) > f_af:
            break
        m_af[s_pop][i]+=1

####
def cnt_population_AF(sf_vcf, sf_out_csv):
    m_pop_af={}
    for pop_code in l_pop_code:
        m_pop_af[pop_code]=[]
        for i in range(n_level):
            m_pop_af[pop_code].append(0)

    sf_sites = sf_out_csv + ".high_af.sites"
    with open(sf_vcf) as fin_vcf, open(sf_sites, "w") as fout_sites:
        for line in fin_vcf:
            if line[0]=="#":
                continue
            fields=line.split('\t')
            # chrm=fields[0]
            # pos=fields[1]
            # s_site="{0}_{1}".format(chrm, pos)
            sinfo=fields[7]
            info_fields=sinfo.split(";")
####
            n_cnt = 0
            s_tmp_pop_code = ""
            s_tmp_af = ""

            for sterm in info_fields:
                info_sub_fields=sterm.split("=")
                s_term_id=info_sub_fields[0]
                s_term_value=info_sub_fields[1]

                for s_pop_code in l_pop_code:
                    if s_pop_code+"_AF" == s_term_id:
                        n_cnt+=1
                        s_tmp_pop_code=s_pop_code
                        s_tmp_af=s_term_value
                if n_cnt>1:
                    break

            if n_cnt==1:
                f_tmp_af=float(s_tmp_af)
                add_a_site(f_tmp_af, s_tmp_pop_code, m_pop_af)
                if f_tmp_af > n_high_af:
                    fout_sites.write(line.rstrip()+"\n")

    with open(sf_out_csv, "w") as fout_csv:
        fout_csv.write("AF,Population,Count\n")
        for pop_code in m_pop_af:
            for i in range(n_level):
                f_tmp=float(i)*f_base
                n_cnt=m_pop_af[pop_code][i]
                sinfo="{0},{1},{2}\n".format(f_tmp, pop_code, n_cnt)
                fout_csv.write(sinfo)
#

if __name__ == '__main__':
    sf_vcf=sys.argv[1]
    sf_out=sys.argv[2]
    cnt_population_AF(sf_vcf, sf_out)
####