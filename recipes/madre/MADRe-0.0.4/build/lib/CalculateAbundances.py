import argparse
import logging
import os

logging.basicConfig(
    level=logging.INFO, 
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler()
    ]
)

def get_ref_count_read_class(read_class_file):
    f = open(read_class_file, "r")
    ref_count = {}
    read_class = {}

    line = f.readline()
    while line != '':
        read_id, ref = line.strip().split(' : ')
        read_class[read_id] = ref
        if ref in ref_count:
            ref_count[ref] += 1
        else:
            ref_count[ref] = 1

        line = f.readline()

    ref_count = dict(sorted(ref_count.items(), key=lambda item: item[1], reverse=True))
    return ref_count, read_class

def get_reads_lens(reads_file):
    f = open(reads_file, "r")
    reads_lens = {}

    line = f.readline()
    rlen = 0

    if reads_file.endswith('fasta') or reads_file.endswith('fa') or reads_file.endswith('fna'):

        while line != "":
            if line.startswith(">"):
                if rlen > 0:
                    reads_lens[read_id] = rlen
                read_id = line.strip().split()[0][1:]
                rlen = 0
            else:
                rlen += len(line.strip())
            
            line = f.readline()
        if rlen > 0:
            reads_lens[read_id] = rlen

    elif reads_file.endswith('fastq') or reads_file.endswith('fq'):

        while line != "":
            read_id = line.strip().split()[0][1:]
            rlen = len(f.readline().strip())
            reads_lens[read_id] = rlen
            f.readline()
            f.readline()
            line = f.readline()

    f.close()

    return reads_lens

def get_refs_lens(reduced_db):
    f = open(reduced_db, "r")

    refs_lens = {}
    rlen = 0
    line = f.readline()
    while line != "":
        if line.startswith(">"):
            
            if rlen > 0:
                refs_lens[ref] = rlen
            ref = line.strip().split()[0][1:]
            rlen = 0
        else:  
            rlen += len(line.strip())
        line = f.readline()

    refs_lens[ref] = rlen

    return refs_lens



def output_abundances(ref_count, read_class, ref_lens, reads_lens, clusters, represetatives, clusters_ids, rc_abundances_file, abundances_file):

    f_rc = open(rc_abundances_file, "w")
    ref_abud = {}
    for_print = []

    if len(clusters.keys()) > 0:


        for ref, count in ref_count.items():
            if ref in clusters_ids: 
                cluster_id = clusters_ids[ref]
                cluster = clusters[cluster_id]
                rep_found = False
                if len(cluster) == 1:
                    #f_rc.write(f"{ref} : {count}\n")
                    for_print.append((ref,count,0))
                else:
                    represetative = represetatives[cluster_id]
                    count_all = 0
                    for r in cluster:
                        if r in ref_count:
                            count_all += ref_count[r]
                    for_print.append((represetative,count_all,1))

            else:
                #f_rc.write(f"{ref} : {count}\n")
                for_print.append((ref,count,0))

        for_print = list(set(for_print))
        for_print = sorted(for_print, key=lambda x: x[1], reverse=True)
        for p in for_print:
            if p[2] == 0:
                f_rc.write(f"{p[0]} : {p[1]}\n")
            else:
                f_rc.write(f"{p[0]} - with cluster : {p[1]}\n")
    else:
        for ref, count in ref_count.items():
            f_rc.write(f"{ref} : {count}\n")
            if ref not in ref_lens:
                continue
            if len(reads_lens) > 0:
                ref_reads = [key for key, value in read_class.items() if value == ref]

                sum_reads_len = sum([reads_lens[r] for r in ref_reads])
                abud = sum_reads_len / ref_lens[ref]
                ref_abud[ref] = abud

    f_rc.close()

    if  len(reads_lens) > 0:
        f_a = open(abundances_file, "w")

        ref_abud_s = dict(sorted(ref_abud.items(), key=lambda item: item[1], reverse=True))
        for ref, abud in ref_abud_s.items():
            f_a.write(f"{ref} : {abud}\n")
        f_a.close()

def get_clusters(clusters_dir):
    f = open(clusters_dir+"/clusters.txt", "r")
    cluster_id = 0
    line = f.readline()
    clusters = {}
    clusters_ids = {}
    while line != '':
        parts = line.strip().split()
        clusters[cluster_id] = parts
        for p in parts:
            clusters_ids[p] = cluster_id
        cluster_id += 1
        line = f.readline()
    f.close()
    f = open(clusters_dir+"/representatives.txt", "r")
    representatives = []
    line = f.readline()
    while line != '':
        representatives.append(line.strip())
        line = f.readline()
    f.close()

    return clusters_ids, clusters, representatives




def run(args):
    logging.info("Parameters:")
    # logging.info(f"Reduced database file path: {args.reduced_db}")
    logging.info(f"Reads file path: {args.reads}")
    logging.info(f"Read classification file path: {args.read_class}")
    logging.info(f"Read count abundances file path: {args.rc_abudances_out}") 
    if args.abudances_out != "": 
        logging.info(f"Relative abundances file path: {args.abudances_out}") #napraviti da je ovo opcionalno
        if args.db is None:
            abundances_out = ""
            logging.warning("Database path missing. Skipping relative abundance estimation...")
        else:
            logging.info(f"Database file path: {args.db}")
            abundances_out = args.abudances_out
    else:
        abundances_out = "" 
    if args.clusters != "":
        logging.info(f"Clusters dir: {args.clusters}")
        if os.path.exists(args.clusters+"/clusters.txt") and os.path.exists(args.clusters+"/representatives.txt"):
            logging.info("Clusters files found.")
        else:
            logging.warning("Clusters files not found. Skipping clustering...")
            args.clusters = ""

    ref_count, reads_class = get_ref_count_read_class(args.read_class)
    if abundances_out != "":
        reads_lens = get_reads_lens(args.reads)
        refs_lens = get_refs_lens(args.db)
    else:
        reads_lens = []
        refs_lens = []
    if args.clusters != "":
        clusters_ids, clusters, represetatives = get_clusters(args.clusters)
    else:
        clusters_ids = {}
        clusters = {}
        represetatives = []
    output_abundances(ref_count, reads_class, refs_lens, reads_lens, clusters, represetatives, clusters_ids, args.rc_abudances_out, abundances_out)




def main():
    parser = argparse.ArgumentParser(description="MADRe.")


    parser.add_argument(
        "--db", type=str, default=None, 
        help="Path to the database file (fasta). If DatabaseReduction used - path to the reduced database. WARNING: Required for estimated abundances calculation."
    )

    parser.add_argument(
        "--reads", type=str, default=None, required=True,
        help="Path to the reads file (fastq/fasta)."
    )

    parser.add_argument(
        "--read_class", type=str, required=True,
        help="Path to the input file with classification labels for reads from read classification step. (default=read_classification.out)" 
    )

    parser.add_argument(
        "--rc_abudances_out", type=str, default="rc_abundances.out",
        help="Path to the output file with read count. (default=rc_abundances.out)"
    )

    parser.add_argument(
        "--abudances_out", type=str, default="",
        help="Path to the output file with estimated abundances. If path is not given this file is not going to be generated. WARNING: In case of large sample and large database that can be computationally exhaustive job."
    )

    parser.add_argument(
        "--clusters", type=str, default="",
        help="Path to dir that contains clusters.txt and representatives.txt files. If provided, the abundances in output files will be reported including cluster information."
    )

    # parser.add_argument(
    #     "--threads", type=int, default=32,
    #     help="Number of threads (default=32)."
    # ) 
    
    args = parser.parse_args()

    run(args)

if __name__ == "__main__":
    main()