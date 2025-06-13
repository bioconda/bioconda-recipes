import json
import time
import argparse

def run(args):

    f_acc_wgs = open(args.wgs_acc2taxid, 'r')
    acc_taxid = {}
    rank_taxid = {}

    f_acc_wgs.readline()
    line = f_acc_wgs.readline()
    while line != '':
        parts = line.strip().split()
        acc = parts[0]
        taxid = parts[2]

        acc_taxid[acc] = taxid
        rank_taxid[taxid] = 'non'
    
        line = f_acc_wgs.readline()

    f_acc_wgs.close()


    f_acc_gb = open(args.gb_acc2taxid, 'r')
    # acc_taxid = {}
    # rank_taxid = {}

    f_acc_gb.readline()
    line = f_acc_gb.readline()
    while line != '':
        parts = line.strip().split()
        acc = parts[0]
        taxid = parts[2]

        acc_taxid[acc] = taxid
        rank_taxid[taxid] = 'non'
    
        line = f_acc_gb.readline()

    f_acc_gb.close()

    f_nodes = open(args.nodes, 'r')

    taxid_species = {}
    norank_taxid = {}


    line = f_nodes.readline()

    rank_taxid['2'] = 'bacteria'
    taxid_parent = {}
    species = []

    while line != '':
        parts = line.strip().split("\t|\t")
        taxid = parts[0]
        rank = parts[2]


    
        parent_taxid = parts[1]
        taxid_parent[taxid] = parent_taxid
        if rank == args.rank:
            species.append(taxid)

        norank_taxid[taxid] = parent_taxid
        rank_taxid[taxid] = rank

 

        line = f_nodes.readline()

    for taxid, parent_taxid in norank_taxid.items():
        rank = rank_taxid[taxid]
        parent_rank = rank_taxid[parent_taxid]

        while parent_rank != args.rank and parent_taxid != '1' and parent_rank != 'bacteria':
            parent_taxid = norank_taxid[parent_taxid]
            parent_rank = rank_taxid[parent_taxid]
        

        if parent_rank == args.rank:
            taxid_species[taxid] = parent_taxid
        else:
            taxid_species[taxid] = '-1'

    for taxid in species:
        taxid_species[taxid] = taxid


    f_nodes.close()

    filtered_taxid_species = {key: value for key, value in taxid_species.items() if value != "-1"}


    f_json = open(args.out_taxids, "w")
    json.dump(filtered_taxid_species, f_json, indent=4)


def main():
    parser = argparse.ArgumentParser(description="MADRe.")

    parser.add_argument(
        "--wgs_acc2taxid", type=str, required=True,
        help="Path to nucl_wgs.accession2taxid file."
    )

    parser.add_argument(
        "--gb_acc2taxid", type=str, required=True,
        help="Path to gb.accession2taxid file."
        )

    parser.add_argument(
        "--nodes", type=str, required=True,
        help="Path to nodes.dmp file."
    )

    parser.add_argument(
        "--rank", type=str, default='species',
        help="Rank for index. default: species"
    )

    parser.add_argument(
        "--out_taxids", type=str, default='taxids_index.json',
        help="Path to the output json file. default: taxids_index.json"
    )

    args = parser.parse_args()

    run(args)

if __name__ == "__main__":
    main()
