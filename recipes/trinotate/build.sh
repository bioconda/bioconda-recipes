#!/bin/bash

mkdir -p perl-build/scripts

mv util/generate_Trinotate_report.txt util/generate_Trinotate_report.sh
mv util/auto_Trinotate.txt util/auto_Trinotate.sh

cp -rf PerlLib perl-build/lib
cp -rf sample_data ${PREFIX}/trinotate-sample-data

find . -name "*.pl" | grep -v sample_data | xargs -I {} cp -rf {} perl-build/scripts/
cp Trinotate perl-build/scripts

cd perl-build

cp ${RECIPE_DIR}/Build.PL ./

perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

chmod +rx $PREFIX/bin/assign_eggnog_funccats.pl
chmod +rx $PREFIX/bin/test_Heatmap.pl
chmod +rx $PREFIX/bin/import_samples_n_expression_matrix.pl
chmod +rx $PREFIX/bin/autoTrinotate.pl
chmod +rx $PREFIX/bin/trinotate_report_summary.pl
chmod +rx $PREFIX/bin/update_seq_n_annotation_fields.pl
chmod +rx $PREFIX/bin/import_expression_and_DE_results.pl
chmod +rx $PREFIX/bin/count_table_fields.pl
chmod +rx $PREFIX/bin/run_TrinotateWebserver.pl
chmod +rx $PREFIX/bin/cleanMe.pl
chmod +rx $PREFIX/bin/rnammer_supperscaffold_gff_to_indiv_transcripts.pl
chmod +rx $PREFIX/bin/Trinotate_PFAM_loader.pl
chmod +rx $PREFIX/bin/import_expression_matrix.pl
chmod +rx $PREFIX/bin/extract_specific_genes_from_all_matrices.pl
chmod +rx $PREFIX/bin/test_GenomeBrowser.pl
chmod +rx $PREFIX/bin/import_transcript_clusters.pl
chmod +rx $PREFIX/bin/init_Trinotate_sqlite_db.pl
chmod +rx $PREFIX/bin/create_clusters_tables.pl
chmod +rx $PREFIX/bin/Trinotate_GTF_loader.pl
chmod +rx $PREFIX/bin/obo_to_tab.pl
chmod +rx $PREFIX/bin/test_Sunburst.pl
chmod +rx $PREFIX/bin/run_cluster_functional_enrichment_analysis.pl
chmod +rx $PREFIX/bin/extract_GO_assignments_from_Trinotate_xls.pl
chmod +rx $PREFIX/bin/test_Barplot.pl
chmod +rx $PREFIX/bin/import_Trinotate_xls_as_annot.pl
chmod +rx $PREFIX/bin/make_cXp_html.pl
chmod +rx $PREFIX/bin/build_DE_cache_tables.pl
chmod +rx $PREFIX/bin/test_Piechart.pl
chmod +rx $PREFIX/bin/prep_nuc_prot_set_for_trinotate_loading.pl
chmod +rx $PREFIX/bin/Trinotate_RNAMMER_loader.pl
chmod +rx $PREFIX/bin/PFAMtoGoParser.pl
chmod +rx $PREFIX/bin/extract_GO_for_BiNGO.pl
chmod +rx $PREFIX/bin/superScaffoldGenerator.pl
chmod +rx $PREFIX/bin/RnammerTranscriptome.pl
chmod +rx $PREFIX/bin/Trinotate_GO_to_SLIM.pl
chmod +rx $PREFIX/bin/sqlite.pl
chmod +rx $PREFIX/bin/Trinotate_GTF_or_GFF3_annot_prep.pl
chmod +rx $PREFIX/bin/obo_tab_to_sqlite_db.pl
chmod +rx $PREFIX/bin/test_Lineplot.pl
chmod +rx $PREFIX/bin/EMBL_swissprot_parser.pl
chmod +rx $PREFIX/bin/Trinotate_BLAST_loader.pl
chmod +rx $PREFIX/bin/TrinotateSeqLoader.pl
chmod +rx $PREFIX/bin/Trinotate_SIGNALP_loader.pl
chmod +rx $PREFIX/bin/runMe.pl
chmod +rx $PREFIX/bin/Trinotate_get_feature_name_encoding_attributes.pl
chmod +rx $PREFIX/bin/test_Scatter2D.pl
chmod +rx $PREFIX/bin/Trinotate_report_writer.pl
chmod +rx $PREFIX/bin/EMBL_dat_to_Trinotate_sqlite_resourceDB.pl
chmod +rx $PREFIX/bin/import_DE_results.pl
chmod +rx $PREFIX/bin/import_samples_only.pl
chmod +rx $PREFIX/bin/test_GO_DAG.pl
chmod +rx $PREFIX/bin/PFAM_dat_parser.pl
chmod +rx $PREFIX/bin/shrink_db.pl
chmod +rx $PREFIX/bin/import_transcript_names.pl
chmod +rx $PREFIX/bin/Trinotate_TMHMM_loader.pl
chmod +rx $PREFIX/bin/Trinotate
chmod +rx $PREFIX/bin/import_transcript_annotations.pl
chmod +rx $PREFIX/bin/cleanme.pl
chmod +rx $PREFIX/bin/Build_Trinotate_Boilerplate_SQLite_db.pl
chmod +rx $PREFIX/bin/print.pl
