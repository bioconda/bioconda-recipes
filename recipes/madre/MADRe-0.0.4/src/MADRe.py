import os
import logging
import argparse
from argparse import Namespace
import configparser
from pathlib import Path
import DatabaseReduction
import ReadClassification
import CalculateAbundances

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler()]
)

def run_or_skip(cmd, target_file, force=False):
    if os.path.exists(target_file) and not force:
        logging.info(f"Skipping step (file exists): {target_file}")
        return

    logging.info(f"Running: {cmd}")
    os.system(cmd)
    if not os.path.exists(target_file):
        logging.error(f"The command was not executed successfully. Exiting...")
        exit()

def main():
    parser = argparse.ArgumentParser(description="MADRe")

    parser.add_argument("--out-folder", type=str, required=True, help="Path to the output folder.")
    parser.add_argument("--reads", type=str, required=True, help="Path to the reads file (fastq/fq can be gzipped).")
    parser.add_argument("--reads_flag", type=str, default='ont', choices=['pacbio', 'hifi', 'ont'], help="Reads technology.")
    parser.add_argument("--threads", type=int, default=32, help="Number of threads (default=32).")
    parser.add_argument("-F", "--force", action="store_true", help="Force rerun all steps.")
    parser.add_argument("--config", type=str, default="config.ini", help="Path to the configuration file.")

    args = parser.parse_args()

    logging.info("Starting MADRe...")
    logging.info(f"Configuration: {args.config}")

    config = configparser.ConfigParser()
    config.read(args.config)

    PATH_METAFLYE = config["PATHS"]["metaflye"]
    PATH_METAMDBG = config["PATHS"]["metaMDBG"]
    PATH_MINIMAP = config["PATHS"]["minimap"]
    PATH_HAIRSPLITTER = config["PATHS"]["hairsplitter"]

    PREDEFINED_DB = config["DATABASE"]["predefined_db"]
    PREDEFINED_DB_JSON = Path(__file__).resolve().parent / config["DATABASE"]["strain_species_json"]

    logging.info(f"Output folder: {args.out_folder}")
    logging.info(f"Reads file: {args.reads}")
    logging.info(f"Reads technology: {args.reads_flag}")
    logging.info(f"Database: {PREDEFINED_DB}")
    logging.info(f"Strain-Species JSON: {PREDEFINED_DB_JSON}")
    logging.info(f"Threads: {args.threads}")

    if not os.path.exists(args.out_folder):
        logging.info(f"Creating output folder: {args.out_folder}")
        os.makedirs(args.out_folder)

    reads_tech_flye = {'pacbio':'--pacbio-raw', 'hifi':'--pacbio-hifi', 'ont':'--nano-raw'}
    reads_tech_minimap = {'pacbio':'-cx map-pb', 'hifi':'-cx map-hifi', 'ont':'-cx map-ont'}

    if args.reads_flag == 'ont':
        assembly_out_dir = os.path.join(args.out_folder, "metaflye")
        try:
            logging.info("Running MetaFlye...")
            command = f"{PATH_METAFLYE} {reads_tech_flye[args.reads_flag]} {args.reads} --out-dir {assembly_out_dir} --threads {args.threads} --meta 2> {args.out_folder}/metaflye.log"
            run_or_skip(command, f"{assembly_out_dir}/assembly.fasta", args.force)
        except Exception as e:
            logging.error(f"MetaFlye error: {e}")
            exit()
    else:
        assembly_out_dir = os.path.join(args.out_folder, "metaMDBG")
        try:
            logging.info("Running metaMDBG...")
            command = f"{PATH_METAMDBG} asm {assembly_out_dir} {args.reads} -t {args.threads} 2> {args.out_folder}/metaMDBG.log && gunzip {assembly_out_dir}/contigs.fasta.gz && mv {assembly_out_dir}/contigs.fasta {assembly_out_dir}/assembly.fasta"
            run_or_skip(command, f"{assembly_out_dir}/assembly.fasta", args.force)
        except Exception as e:
            logging.error(f"metaMDBG error: {e}")
            exit()

    try:
        logging.info("Running Minimap2 for database reduction...")
        command = f"{PATH_MINIMAP} -x asm5 {PREDEFINED_DB} {assembly_out_dir}/assembly.fasta -t {args.threads} > {args.out_folder}/assembly.to_big_db.paf 2> {args.out_folder}/minimap_reduction.log"
        run_or_skip(command, f"{args.out_folder}/assembly.to_big_db.paf", args.force)
    except Exception as e:
        logging.error(f"Minimap2 reduction error: {e}")
        exit()

    try:
        logging.info("Running Hairsplitter...")
        hairsplitter_out_dir = os.path.join(assembly_out_dir, "hairsplitter")
        command = f"{PATH_HAIRSPLITTER} -i {assembly_out_dir}/assembly.fasta -f {args.reads} -t {args.threads} -o {hairsplitter_out_dir} -F 2> {args.out_folder}/hairsplitter.log"
        run_or_skip(command, f"{hairsplitter_out_dir}/tmp/cleaned_assembly.fasta", args.force)
        os.system("rm -r tmp*")
        os.system("rm trash.txt")
    except Exception as e:
        logging.error(f"Hairsplitter error: {e}")
        exit()

    try:
        command = f"grep '^>' {hairsplitter_out_dir}/tmp/cleaned_assembly.fasta | sed 's/^>//; s/@/:/; s/edge/contig/' > {assembly_out_dir}/collapsed_strains.txt"
        run_or_skip(command, f"{assembly_out_dir}/collapsed_strains.txt", args.force)

    except Exception as e:
        logging.error(f"Collapsed strain processing error: {e}")
        exit()

    try:
        logging.info("Running DatabaseReduction...")
        dr_args = Namespace(
        database=PREDEFINED_DB,
        strain_species_info=str(PREDEFINED_DB_JSON),
        paf_path=f"{args.out_folder}/assembly.to_big_db.paf",
        num_collapsed_strains=f"{assembly_out_dir}/collapsed_strains.txt",
        reduced_list_txt=f"{args.out_folder}/genomes_in_reduced.txt",
        reduced_db=f"{args.out_folder}/reduced_db.fa", 
        mapping_class=None,  
        mapping_reduced_db=None,  
        threads=args.threads,
        strictness="very-strict",
        min_contig_len=1000)
        DatabaseReduction.run(dr_args)
    except Exception as e:
        logging.error(f"DatabaseReduction error: {e}")
        exit()

    try:
        logging.info("Running Minimap2 for classification...")
        command = f"{PATH_MINIMAP} {reads_tech_minimap[args.reads_flag]} {args.out_folder}/reduced_db.fa {args.reads} -t {args.threads} > {args.out_folder}/reads.to_reduced.paf 2> {args.out_folder}/minimap_classification.log"
        run_or_skip(command, f"{args.out_folder}/reads.to_reduced.paf", args.force)
    except Exception as e:
        logging.error(f"Minimap2 classification error: {e}")
        exit()

    try:
        logging.info("Running ReadClassification...")
        rc_args = Namespace(
            paf_path=f"{args.out_folder}/reads.to_reduced.paf",
            strain_species_info=str(PREDEFINED_DB_JSON),
            read_class_output=f"{args.out_folder}/read_classification.out",
            clustering_out="")
        ReadClassification.run(rc_args)
    except Exception as e:
        logging.error(f"ReadClassification error: {e}")
        exit()

    try:
        logging.info("Running CalculateAbundances...")
        ca_args = Namespace(
            db=f"{args.out_folder}/reduced_db.fa",
            reads=args.reads,
            read_class=f"{args.out_folder}/read_classification.out",
            rc_abudances_out=f"{args.out_folder}/rc_abundances.out",
            abudances_out=f"{args.out_folder}/abundances.out",
            clusters="")
        CalculateAbundances.run(ca_args)
    except Exception as e:
        logging.error(f"CalculateAbundances error: {e}")
        exit()

    logging.info("MADRe finished successfully.")

if __name__ == "__main__":
    main()
