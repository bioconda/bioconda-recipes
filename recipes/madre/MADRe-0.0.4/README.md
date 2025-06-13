# MADRe
Strain-level metagenomic classification with Metagenome Assembly driven Database Reduction approach

before running:
```
git clone https://github.com/lbcb-sci/MADRe
conda create -n MADRe_env python=3.10 scikit-learn minimap2 flye metamdbg hairsplitter seqkit kraken2 -c conda-forge -c bioconda 
conda activate MADRe_env
```
set up the configuration (config.ini file):
```                                                               
[PATHS]
metaflye = /path/to/flye
metaMDBG = /path/to/metaMDBG
minimap = /path/to/minimap2
hairsplitter = /path/to/hairsplitter.py
seqkit = /path/to/seqkit

[DATABASE]
predefined_db = /path/to/database.fna
strain_species_json = ./database/taxids_species.json
```

Recommended database is Kraken2 bacteria database - instructions on how to build it you can find in the section [Build database](#build-database).


simple run:
```
python MADRe.py --reads [path_to_the_reads] --out-folder [path_to_the_out_folder] --config config.ini
```

more information:
```
python MADRe.py --help
```

Information on how to run specific MADRe steps find in section [Run specific steps](#run-specific-steps).

## Build database

Recommend database is the kraken2 built bacteria database following next steps:
```
kraken2-build --download-taxonomy --db $DBNAME
kraken2-build --download-library bacteria --db $DBNAME
kraken2-build --build --db $DBNAME
```

Detailed instructions that are including the one listed here can be found at [kraken2 github page](https://github.com/DerrickWood/kraken2/blob/master/docs/MANUAL.markdown).

If you want to use your database it is important to have taxonomy information for the references included in the database. 

References in the database should have headers in this way:

```
>|taxid|accession_number
```

```../database/taxids_species.json``` file contains information on species taxid for every strain taxid obtained from NCBI taxonomy (downloaded December 2024.). 

For building new taxids index from newer taxonomy file or for different taxonomic levels you can use ```database/build_json_taxids.py```.

## Run specific steps

MADRe is the pipeline contained of two main steps: 1) database reduction and 2) read classification.

It is possible to run those steps independently. More infromation on running can be obtained with:

```
python src/DatabaseReduction.py --help
python src/ReadClassification.py --help
```

### Database reduction information

To run database reduction step separately you need to provide names of the output paths, mapping PAF file containg contigs mappings to large database (database needs to follow rules from [Build database](#build-database) section) and text file containing how many strains are collapsed in which contig. If contig represents only one strain there should be 0 next to it, if it represents 2 strains, 1 is collapsed so there should be 1 next to it. The file should look like this:
```
...
contig_7:0 
contig_8:0 
contig_8:1 
contig_8:2 
contig_8:3
...
```

If as output you only specify ```--reduced_list_txt``` you won't get fasta file of reduced database, just list of references that should go to reduced database. To get fasta file of reduced database specify ```--reduced_db```.

Database reduction step uses taxid index. By default it uses ```database/taxid_species.json```. If specific large database is used, then right taxid index should be provided using ```--strain_species_info```.


### Read classification information

To run read classification step separately you need to provide PAF file containing read mappings to the reference. This step can be run on any database (database needs to follow rules from [Build database](#build-database) section), so it doesn't have to be previously reduced.

Read classification step uses taxid index. By default it uses ```database/taxid_species.json```. If specific large database is used, then right taxid index should be provided using ```--strain_species_info```.

Output file is text file containg lines as: ```read_id : reference```.

### Read Classification with clustering

As part of read classification step, clustering of very similar strains can also be performed. If you want to perform clustering provide path to the directory with output clustering files using ```--clustering_out```. Output clustering files are:
```
clusters.txt - Every line represents one cluster. References in cluster separated with spaces.
representatives.txt - Every line represents a cluster representative reference of the cluster from that line in clusters.txt file.
```

## Abundance calculation

For abundance calculation information run:

```
python src/CalculateAbundances.py --help
```
The input to this step is read classification output file that has lines as ```read_id : reference```. This file can be obtained with read classification step.

The default output is rc_abundances.out containing read count abundances. If you want to calculate abundance as sum_of_read_lengths/reference_length you need to provide database path used in read classification step using ```--db``` - be aware that this step if database is big takes a little bit longer than calculation of just read count abundances. 

If you want to calculate cluster abundances, you need to provide path to the directory containing ```clusters.txt``` and ```representatives.txt``` files. In that case output files will contain only represetative references with sumarized abundances for cluster that reference is represetative of.

