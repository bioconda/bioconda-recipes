import argparse
import sys
import subprocess
import logging
import json
from pathlib import Path

CLEAN_THRESHOLD = {'less-strict':0.9,'strict':0.99, 'very-strict':0.999} 
MIN_CONTIG_LEN = 1000

logging.basicConfig(
    level=logging.INFO,  # Set log level to INFO
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler()  # Log to console
    ]
)

def mapping_output(mapping_class_path, mapping_reduced_path, predictions_mapping, predictions_mapping_vcg):

    reduced = []
    if mapping_class_path is not None:
        f = open(mapping_class_path, "w")
        for contig, class_label in predictions_mapping.items():
            reduced.append(class_label)
            f.write(f"{contig} : {class_label}\n")
        f.close()

    if mapping_reduced_path is not None:
        if mapping_class_path is None:
            for contig, class_label in predictions_mapping.items():
                reduced.append(class_label)
        reduced = list(set(reduced))
        f = open(mapping_reduced_path, "w")
        for v in reduced:
            f.write(f"{v}\n")
        f.close()
    logging.info("Mapping information written in the files.")

    

def calculate_mapping_class(paf_path, number_of_clusters, mapping_class_path=None, mapping_reduced_path=None):

    logging.info("Mapping information extraction.")

    predictions_mapping = {}
    predictions_mapping_vcg = {}
    U = {}
    NU = {}

    genomes = {}
    genomes_names = {}
    genomes_id = 0
    genomes_list = []
    
    with open(paf_path, "r") as f:
        line = f.readline()
        primary = False
        while line != '':

            parts = line.split()
            read_id = parts[0]

            if 'scaffold' in read_id:
                read_id = read_id.replace('scaffold', 'contig')

            start_pos = int(parts[2])
            end_pos = int(parts[3])
            
            ref_prediction = parts[5].strip()
            

            if len(parts) < 13:
                logging.warning("PAF file does not contain all necessery information.")
            


            if int(parts[1]) < MIN_CONTIG_LEN: 
                line = f.readline()
                continue


            if int(parts[11]) == 0: 
                line = f.readline()
                continue
            

            length_q = int(parts[3].strip()) - int(parts[2].strip())
            length_t = int(parts[8].strip()) - int(parts[7].strip())

            length = max(length_t, length_q)
            nm = int(parts[9].strip().split(':')[-1])

            value_cig = (((2.0 * float(length)) * float(nm)) / (float(length) + float(nm)))

            if ref_prediction not in genomes_list:
                genomes[genomes_id] = ref_prediction
                genomes_names[ref_prediction] = genomes_id
                genomes_id += 1
                genomes_list.append(ref_prediction)
            ref_id = genomes_names[ref_prediction]

            if read_id in predictions_mapping_vcg:
                if ref_prediction in predictions_mapping_vcg[read_id]:
                    predictions_mapping_vcg[read_id][ref_prediction] += float(value_cig)
                else:
                    predictions_mapping_vcg[read_id][ref_prediction] = float(value_cig)
                    
            else:
                predictions_mapping_vcg[read_id] = {ref_prediction:float(value_cig)}
            line = f.readline()
    
    for read_id, candidates in predictions_mapping_vcg.items():

        max_values = max(list(candidates.values()))

        for candidate,value_cig in candidates.items():
            ref_id = genomes_names[candidate]
            if (read_id not in U) and (read_id not in NU):
                U[read_id] = [[ref_id], [value_cig], [float(value_cig)], value_cig]
                predictions_mapping[read_id] = candidate
                continue

            if value_cig == max_values:
                predictions_mapping[read_id] = candidate
    
            if read_id in U:
                if ref_id in U[read_id][0]:
                    continue
                NU[read_id] = U[read_id]
                del U[read_id]  

            if ref_id in NU[read_id][0]:
                continue

            NU[read_id][0].append(ref_id)
            NU[read_id][1].append(value_cig)
            if value_cig > NU[read_id][3]:
                NU[read_id][3] = float(value_cig)

    logging.info("Finished with mapping classification. Writing results to the output files.")
    if mapping_class_path is not None or mapping_reduced_path is not None:
        mapping_output(mapping_class_path, mapping_reduced_path, predictions_mapping, predictions_mapping_vcg)

    return U, NU, genomes

def clear_NU(U, NU, number_of_clusters, genomes_ids, strictness):
    NU_cleaned = {}
    for contig, nu_values in NU.items():
        nu_value_0_1 = zip(nu_values[0],nu_values[1])
        m = max(nu_values[1])
        max_num_clusters = max(number_of_clusters[contig]+2, 1)

        nu_value_0_1 = sorted(nu_value_0_1, key=lambda x: x[1], reverse=True)[:max_num_clusters]
        nu_value_0_1_new = []

        for c, v in nu_value_0_1:
            if v > CLEAN_THRESHOLD[strictness]*m:
                nu_value_0_1_new.append((c,v))
            # else:
            #     #print('cleanam: ' + str(genomes_ids[c]) + ', ' + str(v))
            #     break
    
        nu_value_0, nu_value_1 = zip(*nu_value_0_1_new)
        NU_cleaned[contig] = [nu_value_0, nu_value_1, nu_values[2], nu_values[3]]

    return U, NU_cleaned

def get_number_of_clusters(num_collapsed_strains):
    number_of_clusters = {}

    f = open(num_collapsed_strains, "r")
    line = f.readline()
    while line != "":
        parts = line.strip().split(':')
        read_id = parts[0]
        if 'scaffold' in read_id:
                read_id = read_id.replace('scaffold', 'contig')
        number_of_clusters[read_id] = int(parts[1]) + 1
        line = f.readline()

    return number_of_clusters
      

def EM(U, NU, genomes, max_iter, em_epsilon):

    logging.info("Starting EM.")
    ### Initial values
    pi = [1/len(genomes) for _ in genomes] 
    init_pi = pi
    theta = [1/len(genomes) for _ in genomes] 
    pisum_beg = [0 for _ in genomes]
    U_best = [U[i][1][0] for i in U]
    U_total = 0

    if U_best:
        U_total = sum(U_best)

    for i in U: 
        pisum_beg[U[i][0][0]]+=U[i][1][0]/U[i][3]

    if U_total > 0:
        for i in range(len(pisum_beg)):
            pisum_beg[i] = pisum_beg[i]/U_total
    xsum = 0

    len_NU = 1 if len(NU)==0 else len(NU)

    for i in range(max_iter):   
        pi_old = pi
        thetasum=[0 for k in genomes]
        # E Step 

        for j in NU: 
            z = NU[j] 
            ind = z[0]
            pitmp = [pi[k] for k in ind]
            xtmp = [1.*pitmp[k]*z[1][k]/z[3]for k in range(len(ind))] 
            
            xsum = sum(xtmp)

            if xsum == 0:
                xnorm = [0.0 for _ in xtmp]         
            else:
                xnorm = [1.*k/xsum for k in xtmp]   
          
            NU[j][2] = xnorm
            for k in range(len(ind)):
                thetasum[ind[k]] += xnorm[k]

        # M step    
        pisum = [thetasum[k]+pisum_beg[k] for k in range(len(thetasum))]   

        #pi = [(1.*k+pip)/(len(U)+len(NU)+pip*len(pisum)) for k in pisum]
        pi = [(1.*k)/(len(U)+len(NU)+len(pisum)) for k in pisum]

        if (i == 0):
            init_pi = pi

        theta = thetasum

        cutoff = 0.0

        for k in range(len(pi)):
            cutoff += abs(pi_old[k]-pi[k])

        if ((cutoff <= em_epsilon) or len_NU == 1):
            break


    logging.info(f"Number of performed iterations: {i}")

    return init_pi, pi, theta, NU 

def load_dict_from_json(filename):
    with open(filename, 'r') as file:
        return json.load(file)

def get_reduced_list(U, NU, reduced_list, genomes_ids, SS_info_json, number_of_clusters): 
    logging.info("Finilizing list of genomes for reduced database.")
    logging.info("Iterating through UNIQUE:")

    for c,v in U.items():
        cl = genomes_ids[v[0][0]]
        reduced_list.append(cl)
        logging.info(f"Adding {c} with genome {cl}.")
        #reduced_taxids.append(parts[1])

    logging.info("")
    logging.info("Iterating throug NON-UNIQUE:")
    SS_info = load_dict_from_json(SS_info_json)

    for c,v in NU.items():
        cl = genomes_ids[v[0][v[2].index(max(v[2]))]]
        m = max(v[2])
        cl_v2_n = [r/m for r in v[2]]
        cl_v1_n = [r for r in v[1]]
        gen = [genomes_ids[v[0][i]] for i in range(len(v[2]))]
        gt = [(a,b) for a,b in zip(gen, cl_v2_n)]
        gt = sorted(gt, key=lambda x: x[1], reverse=True)
        #logging.info(f"{c} : {gt} - max: {cl_v1_n} - clust: {number_of_clusters[c]}")

        # print(gt)
        # if number_of_clusters[c] < len(gt):
        #     gt = gt[:number_of_clusters[c]]
        # print(gt)

        c_taxids = {}

        for a,b in gt:
            
            taxid = a.split('|')[1]
            species_t = SS_info[taxid]
            if species_t in c_taxids:
                c_taxids[species_t] += b
            else:
                c_taxids[species_t] = b
        species = max(c_taxids, key=c_taxids.get)
        c_reduced = []
        for a,b in gt:
            taxid = a.split('|')[1]
            species_t = SS_info[taxid]
            if species_t == species:
                reduced_list.append(a) 
                c_reduced.append(a)
            else:
                logging.info(f'Removing {c} - {a}')
        #logging.info(f"{c} : {c_reduced}")
        
    

def output_reduced_list(reduced_list, reduced_list_f):
    reduced_list = list(set(reduced_list))
    f = open(reduced_list_f, 'w')
    for r in reduced_list:
        f.write(r + '\n')
    f.close()


def do_reduction(database, reduced_list, reduced_db, threads):
    
    logging.info("Starting database reduction process using seqkit.")

    try:
        
        command = [
            "seqkit", "grep", "-f", reduced_list, "-j", str(threads), database
        ]
        
        logging.info(f"Running command: {' '.join(command)}")

        with open(reduced_db, "w") as output_file:
            subprocess.run(command, stdout=output_file, check=True)
        
        logging.info(f"Filtered FASTA saved to {reduced_db}")
    
    except subprocess.CalledProcessError as e:
        logging.error(f"Error occurred during seqkit execution: {e}")
    except Exception as e:
        logging.error(f"An error occurred: {e}")


def run(args):
    logging.info("Parameters:")
    logging.info(f"Database file path: {args.database}")
    logging.info(f"Strain-Species info JSON file path: {args.strain_species_info}")
    logging.info(f"Input PAF file path: {args.paf_path}")
    logging.info(f"Number of collapsed strains file path: {args.num_collapsed_strains}")
    logging.info(f"Reduced list file path: {args.reduced_list_txt}")
    if args.mapping_class:
        logging.info(f"Mapping contig classification file path: {args.mapping_class}")
    if args.mapping_reduced_db:
        logging.info(f"Mapping reduced database file path: {args.mapping_reduced_db}")
    if args.reduced_db:
        logging.info(f"Reduced database file path: {args.reduced_db}")
    logging.info(f"Strictness: {args.strictness}")
    logging.info(f"Min contig length: {args.min_contig_len}")
    logging.info(f"Number of threads used: {args.threads}")

    number_of_clusters = get_number_of_clusters(args.num_collapsed_strains)
    U, NU, genomes_ids = calculate_mapping_class(args.paf_path, number_of_clusters, args.mapping_class, args.mapping_reduced_db)

    U, NU = clear_NU(U, NU, number_of_clusters, genomes_ids, args.strictness)

    init_pi, pi, theta, NU = EM(U, NU, list(genomes_ids.values()), 25, 0.0001)

    reduced_list = []

    get_reduced_list(U, NU, reduced_list, genomes_ids, args.strain_species_info, number_of_clusters)

    output_reduced_list(reduced_list, args.reduced_list_txt)
    
    if args.reduced_db:
        do_reduction(args.database, args.reduced_list_txt, args.reduced_db, args.threads)



def main():
    parser = argparse.ArgumentParser(description="MADRe.")

    parser.add_argument(
        "--database", type=str, required=True,
        help="Path to the strating database file (fasta/fna)."
    )

    parser.add_argument(
        "--strain_species_info", type=str, required=True,
        help="An additional parameter required if a custom database path is provided. JSON file with info about species taxid for every strain taxid in the database. If you want to use default one provide path to MADRe/database/taxids_species.json."
    )

    parser.add_argument(
        "--paf_path", type=str, required=True,
        help="Path to the PAF file of assembly mapped to database."
    )

    parser.add_argument(
        "--num_collapsed_strains", type=str, required=True,
        help="File containing info about number of collapsed strains for every contig (hairsplitter output)."
    )

    parser.add_argument(
        "--reduced_list_txt", type=str, required=True,
        help="Path to the file with list of genomes for reduced database."
    )

    parser.add_argument(
        "--reduced_db", type=str, default=None,
        help="Path to the reduced database file (fasta)."
    )
    
    parser.add_argument(
        "--mapping_class", type=str, default=None,
        help="Path to the output mapping contig classification."
    )

    parser.add_argument(
        "--mapping_reduced_db", type=str, default=None,
        help="Path to the output mapping reduced database."
    )
     
    parser.add_argument(
        "--threads", type=int, default=32,
        help="Number of threads (default=32)."
    )

    parser.add_argument(
        "--strictness", type=str, default='very-strict', choices=['less-strict', 'strict', 'very-strict'],
        help="strictness of database reduction - choices: less-strict, strict, very-strict - default: very-strict"
    )
    
    parser.add_argument(
        "--min_contig_len", type=int, default=MIN_CONTIG_LEN,
        help="Filter out contigs shorter than min_contig_len (default=1000)."
    )

    args = parser.parse_args()

    # Check if a custom database is provided, and ensure `--strain_species_info` is also provided
    # if args.database != PREDEFINED_DB and args.strain_species_info == PREDEFINED_DB_JSON:
    #     print("Error: When using a custom database path, you must also specify '--strain_species_info'.")
    #     sys.exit(1)
    run(args)

if __name__ == "__main__":
    main()