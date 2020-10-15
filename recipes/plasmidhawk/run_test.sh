plaster example/exp_train*.fasta -o example/exp_pangenome -r
plasmidhawk annotate example/exp_pangenome.tsv example/exp_lab_plasmid.txt
plasmidhawk predict correct example/exp_pangenome.fasta example/exp_pangenome_lab.tsv example/exp_pred*.fasta -o example/correct_results.txt

