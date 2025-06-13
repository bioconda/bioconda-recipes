import argparse
import logging
import json
from pathlib import Path
import numpy as np
from sklearn.cluster import DBSCAN
from sklearn.metrics import pairwise_distances
import warnings
from sklearn.exceptions import DataConversionWarning
import os

warnings.filterwarnings(action='ignore', category=DataConversionWarning)


logging.basicConfig(
    level=logging.INFO,  
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler() 
    ]
)

def load_dict_from_json(filename):
    with open(filename, 'r') as file:
        return json.load(file)

def species_split(U, NU, species_class, genomes, SS_info_json):
    SS_info = load_dict_from_json(SS_info_json)

    species = list(set(species_class.values()))

    U_species = {}
    NU_species = {}
    
    for s in species:
        U_species[s] = {}
        NU_species[s] = {}

    for read_id, value_list in U.items():
        s = species_class[read_id]
        U_species[s][read_id] = value_list

    for read_id, value_list in NU.items():
        s = species_class[read_id]
        new_value_list = [[], [], [], 0]
        for i, ind in enumerate(value_list[0]):
            #s_v = int(SS_info[genomes[ind].split('|')[1]])
            s_v = SS_info[genomes[ind].split('|')[1]]
            if s_v == s:
                tmp = new_value_list[0]
                tmp.append(ind)
                new_value_list[0] = tmp

                tmp = new_value_list[1]
                tmp.append(value_list[1][i])
                new_value_list[1] = tmp

                tmp = new_value_list[2]
                tmp.append(value_list[2][i])
                new_value_list[2] = tmp

                new_value_list[3] = max(new_value_list[2])

        NU_species[s][read_id] = new_value_list

    return U_species, NU_species

    


def species_identification(U, NU, genomes, SS_info_json):
    SS_info = load_dict_from_json(SS_info_json)

    c_problematic = []
    species_class = {}

    all_mappings = {**U, **NU}

    for read_id, values in all_mappings.items():

        taxids_genomes = []
        for g in values[0]:
            taxids_genomes.append(genomes[g])
        species_taxids = []
        for t in taxids_genomes:
            t_a = t.split('|')[1]
            species_taxids.append(SS_info[t_a])

        if len(set(species_taxids)) > 1:
            c_problematic.append(read_id)
            species_class[read_id] = max(set(species_taxids), key=species_taxids.count)
        else:
            #species_class[read_id] = int(list(set(species_taxids))[0])
            species_class[read_id] = list(set(species_taxids))[0]

    # if len(c_problematic):
    #     logging.info(f'Not classified on species level: {len(c_problematic)}')

    return species_class


def mapping_output(mapping_class_path, predictions_mapping):

    reduced = []
    if mapping_class_path is not None:
        f = open(mapping_class_path, "w")
        for contig, class_label in predictions_mapping.items():
            reduced.append(class_label)
            f.write(f"{contig} : {class_label}\n")
        f.close()

    logging.info("Mapping classification written in the file.")

def calculate_mapping_class(paf_path, mapping_class_path=None, beta=2):
    logging.info("Mapping information extraction.")

    predictions_mapping = {}
    predictions_mapping_vcg = {}
    predictions_mapping_vcg_count = {}
    U = {}
    NU = {}

    genomes = {}
    genomes_names = {}
    genomes_id = 0
    genomes_list = []

    with open(paf_path, "r") as f:
        line = f.readline()
        while line != '':

            parts = line.split()
            read_id = parts[0]
        
            length_q = int(parts[3].strip()) - int(parts[2].strip())
            length_t = int(parts[8].strip()) - int(parts[7].strip())

            length = max(length_t, length_q)
            nm = int(parts[9].strip().split(':')[-1])
            value_cig = float(nm) / float(length)

            ref_prediction = parts[5].strip()

            if ref_prediction not in genomes_list:
                genomes[genomes_id] = ref_prediction
                genomes_names[ref_prediction] = genomes_id
                genomes_id += 1
                genomes_list.append(ref_prediction)
            ref_id = genomes_names[ref_prediction]

            if read_id in predictions_mapping_vcg:

                if ref_prediction in predictions_mapping_vcg[read_id]:
                    if predictions_mapping_vcg[read_id][ref_prediction] > float(value_cig):
                        predictions_mapping_vcg[read_id][ref_prediction] = float(value_cig)
                    predictions_mapping_vcg_count[read_id][ref_prediction] += 1
                else:
                    predictions_mapping_vcg[read_id][ref_prediction] = float(value_cig)
                    predictions_mapping_vcg_count[read_id][ref_prediction] = 1
                    
            else:
                predictions_mapping_vcg[read_id] = {ref_prediction:float(value_cig)}
                predictions_mapping_vcg_count[read_id] = {ref_prediction:1}


            line = f.readline()

    for read_id, candidates in predictions_mapping_vcg.items():

        max_values = max(list(candidates.values()))

        for candidate,value_cig in candidates.items():
            ref_id = genomes_names[candidate]
            if (read_id not in U) and (read_id not in NU):
                U[read_id] = [[ref_id], [value_cig], [value_cig], value_cig]
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
            NU[read_id][2].append(value_cig)
            if value_cig > NU[read_id][3]:
                NU[read_id][3] = float(value_cig)

    if mapping_class_path is not None:
        mapping_output(mapping_class_path, predictions_mapping)

    return U, NU, genomes


def pathoscope_redistribution(NU, genomes):
    G = len(genomes)

    pi = [1./G for _ in genomes]

        
    for j in NU:
        z = NU[j] 
        ind = z[0] 
        pitmp = [pi[k] for k in ind]      
        xtmp = [1.*pitmp[k]*z[2][k] for k in range(len(ind))] 
            
        xsum = sum(xtmp)

        if xsum == 0:
            xnorm = [0.0 for k in xtmp]
        else:
            xnorm = [1.*k/xsum for k in xtmp]            

        NU[j][2] = xnorm  

    return NU

def find_medoid(cluster_indices, dist_matrix):
    if len(cluster_indices) == 1:
        return cluster_indices[0] 
    
    sub_matrix = dist_matrix[np.ix_(cluster_indices, cluster_indices)]
    medoid_idx = cluster_indices[np.argmin(sub_matrix.mean(axis=1))]
    return medoid_idx
        


def run(args):
    logging.info("Parameters:")
    logging.info(f"Strain-Species info JSON file path: {args.strain_species_info}")
    logging.info(f"Input PAF file path: {args.paf_path}")
    # logging.info(f"Mapping classification labels file path: {args.mapping_class_out}")
    logging.info(f"Final classification labels file path: {args.read_class_output}")
    # logging.info(f"Threads: {args.threads}")
    if args.clustering_out != "":
        logging.info(f"Clustering output dir: {args.clustering_out}")
        if not os.path.exists(args.clustering_out):
            os.system(f"mkdir {args.clustering_out}")
        clusters_file = open(args.clustering_out + "/clusters.txt", "w")
        representatives_file = open(args.clustering_out + "/representatives.txt", "w")
        representatives_global = []
        clustering = True
    else:
        clustering = False


    U, NU, genomes = calculate_mapping_class(args.paf_path, mapping_class_path=None, beta=0.5)

    species_class = species_identification(U, NU, genomes, args.strain_species_info)
    U_species, NU_species = species_split(U, NU, species_class, genomes, args.strain_species_info)


    species = list(set(species_class.values()))
    references = list(set(genomes.values()))
    ref_count = {}
    ambigous_species = {}
    ambigous_refs = {}
    ambigous_refs_count = {}
    ambigous_refs_reads = {}
    new_class = {}

    for r in references:
        ref_count[r] = 0
        ambigous_refs = {}
        ambigous_refs_count[r] = 0
        ambigous_refs_reads[r] = []
        new_class[r] = 0

    f_read_clas = open(args.read_class_output, "w")
        

    for s in species:
        NU_result = pathoscope_redistribution(NU_species[s], genomes)
        ambigous_species[s] = 0 

        all_mappings = {**U_species[s], **NU_result}

        genome_read_dict = {}
        for i, name in genomes.items():
            genome_read_dict[name] = [0] * len(all_mappings.keys())
        reads_index_dict = {}  
        ind = 0
        for read_id in all_mappings.keys():
            reads_index_dict[read_id] = ind
            ind += 1
        
        for read_id, value_list in all_mappings.items():
            results = value_list[2]
            genome = genomes[value_list[0][results.index(max(results))]] 
            w = [i for i, x in enumerate(results) if x == max(results)]
            p = [value_list[0][i] for i in w]
            genome_list = [genomes[i] for i in p]
                
            if len(genome_list) == 1:
                genome = genome_list[0]
                f_read_clas.write(read_id + ' : ' + str(genome) + '\n')    
                ref_count[genome] += 1
                ambigous_refs_count[genome] += 1
                temp = genome_read_dict[genome]
                temp[reads_index_dict[read_id]] = 1
                genome_read_dict[genome] = temp

            else:
                for r in genome_list:
                    ambigous_refs_count[r] += 1
                    t = ambigous_refs_reads[r]
                    t.append(read_id)
                    ambigous_refs_reads[r] = t

                    temp = genome_read_dict[r]
                    temp[reads_index_dict[read_id]] = 1
                    genome_read_dict[r] = temp

                    # for ss in genome_list:
                    #     if r == ss:
                    #         continue
                    #     if ss in ambigous_refs[r]:
                    #         ambigous_refs[r][ss] += 1
                    #     else:
                    #         ambigous_refs[r][ss] = 1
                ambigous_species[s] += 1

        if clustering:
            new_genome_read_dict = {}
            for ref, arr in genome_read_dict.items():
                if 1 in arr:
                    new_genome_read_dict[ref] = arr

            ref_ids = list(new_genome_read_dict.keys())
            arrays = np.array(list(new_genome_read_dict.values()))
            dist_matrix = pairwise_distances(arrays, metric='jaccard')
            db = DBSCAN(metric='precomputed', eps=0.9, min_samples=1)
            labels = db.fit_predict(dist_matrix)

            representatives = {}
            unique_labels = set(labels)

            for label in unique_labels:
                if label == -1:
                    continue  

                cluster_indices = np.where(labels == label)[0]  
                medoid_idx = find_medoid(cluster_indices, dist_matrix)  
                representatives[label] = ref_ids[medoid_idx]  

            # Print results
            # print("Cluster Representatives (Medoids):")
            for cluster_id, medoid in representatives.items():
                # print(f"Cluster {cluster_id}: Representative -> {medoid}")
                cluster_refs = [ref_ids[i] for i, val in enumerate(labels) if val == cluster_id]
                representatives_global.append(medoid)

                for ref in cluster_refs:
                    clusters_file.write(ref + " ")
                clusters_file.write("\n")

        for read_id, value_list in all_mappings.items():

            results = value_list[2]
            genome = genomes[value_list[0][results.index(max(results))]] 
            w = [i for i, x in enumerate(results) if x == max(results)]
            p = [value_list[0][i] for i in w]
            genome_list = [genomes[i] for i in p]

            if len(genome_list) > 1:
                m = 0
                mr = ''
                for r in genome_list:
                    c = ambigous_refs_count[r]
                    if c > m:
                        mr = r
                        m = c
                f_read_clas.write(read_id + ' : ' + str(mr) + '\n') 
                
                new_class[mr] += 1 
                ref_count[r] += 1

    if clustering:
        for rep in representatives_global:
            representatives_file.write(rep + "\n")           
  

def main():
    parser = argparse.ArgumentParser(description="MADRe.")

    parser.add_argument(
        "--paf_path", type=str, required=True,
        help="Path to the PAF file of assembly mapped to database."
    )

    parser.add_argument(
        "--strain_species_info", type=str, required=True,
        help="An additional parameter required if a custom database path is provided. JSON file with info about species taxid for every strain taxid in the database. If you want to use default one provide path to MADRe/database/taxids_species.json."
    )

    
    # parser.add_argument(
    #     "--mapping_class_out", type=str, default="mapping_read_classification.out",
    #     help="Path to the output file with classification labels for reads after only mapping. (default = mapping_read_classification.out)"
    # )
     
    # parser.add_argument(
    #     "--threads", type=int, default=32,
    #     help="Number of threads (default=32)."
    # )

    parser.add_argument(
        "--read_class_output", type=str, default="read_classification.out",
        help="Path to the output file with classification labels for reads. (default=read_classification.out)" 
    )

    parser.add_argument(
        "--clustering_out", type=str, default="",
        help="Path to clustering output directory. If provided clustering using mapping info from --paf_path will be performed, otherwise not."
    )
    
    args = parser.parse_args()

    run(args)

if __name__ == "__main__":
    main()
