# hAMRoaster

## *H*armonized *AMR O*utput comp*A*ri*S*on *T*ool *ER*


hAMRoaster is an analysis pipeline that can compare the output of nine different tools for detecting AMR genes and provide metrics of their performance. For most tools, hAMRoaster requires preprocessing with hAMRonization. 

#### Installing hAMRoaster

To install hAMRoaster, run `conda install -c ewissel hamroaster` . 

#### Test your install

`hAMRoaster -h` 
*(notice the caps)*

## hAMRoaster Commands

hAMRoaster has several required and optional commands. At a minimum, users **must** provide the following flags. 

* `--ham_out` : the full path to the output file from hAMRonization. If using the data published with this tool, the file is in `study_data/`

* `--name`: a unique identifier for this run. This name will be the name of the output directory created for the hAMRoaster run, and the name will be included in all the output file names. 

* `--AMR_key` : the full path to the file of known AMR phenotypes; the file is expected to be a tsv in the following format: taxa_name, antibiotic tested, result of antibiotic resting, and testing standard. This matches the output for the [NCBI BioSample AntiBioGram](https://www.ncbi.nlm.nih.gov/biosample/?term=antibiogram%5bfilter%5d). An example file is in `study_data/mock_2_key.csv`.

##### Optional Arguments

* `--abx_map` : While hAMRoaster comes with it's own classifications for antibiotics and their drug class, users can provide their own classification scheme. This expects the drug class to in the first column, and the antibiotics or drugs that fit into that drug class in the next two columns. hAMRoaster's default classification is located in `db_files/cleaned_drug_class_key.csv`. 

* `--fargene` : If users want to test the output of fARGene runs, they can point to the directory of the fARGene output. Because fARGene requires multiple runs for all the built in models, hAMRoaster expects users to point to a generic `fargene_output` directory, and for each run to be a subdirectory named after the AMR model analyzed for that run. For example, for a fARGene run with the model flag `class_a`, hAMRoaster expects their to be a directory named `class_a` within the fargene output directory specified with this parameter, and that the `class_a` subdirectory contains the output of that fARGene run. 

* `--shortbred` : If users want to test the output of a shortBRED run, they can use this flag to specifcy the full path to the output file from shortbred (include the file in the path). 

* `--shortbred_map` : This flag can point to a specific file that maps the shortbred IDs to their AMR gene names. hAMRoaster included the mapping file created with the shortbred publication in 2016. It is used by default and located in `db_files/ShortBRED_ABR_Metadata.tab`. 
