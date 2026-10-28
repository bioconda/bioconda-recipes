#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/share

FusionFilter_DIR_NAME="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
FusionFilter_INSTALL_PATH="$PREFIX/share/$FusionFilter_DIR_NAME"
# Make the install directory and move the FusionFilter files to that location.
mkdir -p $FusionFilter_INSTALL_PATH
# Split the copy into two commands for readability.
cp -R $SRC_DIR/*.pl $SRC_DIR/lib $SRC_DIR/util $SRC_DIR/AnnotFilterRuleLib $SRC_DIR/testing $FusionFilter_INSTALL_PATH
cp -R $SRC_DIR/LICENSE $SRC_DIR/Makefile $SRC_DIR/README.md $FusionFilter_INSTALL_PATH
chmod a+x $FusionFilter_INSTALL_PATH/*.pl 
chmod a+x $FusionFilter_INSTALL_PATH/util/*.pl 
chmod a+x $FusionFilter_INSTALL_PATH/util/paralog_clustering_util/*.pl 
chmod a+x $FusionFilter_INSTALL_PATH/testing/*/*.sh 

# Connecting lib files.
cd $PREFIX/lib
ln $FusionFilter_INSTALL_PATH/lib/Fasta_reader.pm
ln $FusionFilter_INSTALL_PATH/lib/Fasta_retriever.pm
ln $FusionFilter_INSTALL_PATH/lib/Gene_obj_indexer.pm
ln $FusionFilter_INSTALL_PATH/lib/Gene_obj.pm
ln $FusionFilter_INSTALL_PATH/lib/Gene_overlap_check.pm
ln $FusionFilter_INSTALL_PATH/lib/GTF.pm
ln $FusionFilter_INSTALL_PATH/lib/GTF_utils.pm
ln $FusionFilter_INSTALL_PATH/lib/Longest_orf.pm
ln $FusionFilter_INSTALL_PATH/lib/Nuc_translator.pm
ln $FusionFilter_INSTALL_PATH/lib/Overlap_piler.pm
ln $FusionFilter_INSTALL_PATH/lib/Pipeliner.pm
ln $FusionFilter_INSTALL_PATH/lib/Process_cmd.pm
ln $FusionFilter_INSTALL_PATH/lib/TiedHash.pm

# We need links to lib, util, util/paralog_clustering_util, and AnnotFilterRuleLib
# directories, because various executables expect those directories to exist in the same
# directory as themselves.
cd $PREFIX/bin
ln -s $FusionFilter_INSTALL_PATH/lib
ln -s $FusionFilter_INSTALL_PATH/util
ln -s $FusionFilter_INSTALL_PATH/AnnotFilterRuleLib
ln -s $FusionFilter_INSTALL_PATH/util/paralog_clustering_util
ln -s $FusionFilter_INSTALL_PATH/blast_and_promiscuity_filter.pl
ln -s $FusionFilter_INSTALL_PATH/prep_genome_lib.pl
ln -s $FusionFilter_INSTALL_PATH/util/blast_check_pair.pl
ln -s $FusionFilter_INSTALL_PATH/util/blast_filter.pl
ln -s $FusionFilter_INSTALL_PATH/util/blast_outfmt6_replace_trans_id_w_gene_symbol.pl
ln -s $FusionFilter_INSTALL_PATH/util/build_chr_gene_alignment_index.pl
ln -s $FusionFilter_INSTALL_PATH/util/build_fusion_annot_db_index.pl
ln -s $FusionFilter_INSTALL_PATH/util/build_prot_info_db.pl
ln -s $FusionFilter_INSTALL_PATH/util/gencode_extract_relevant_gtf_exons.pl
ln -s $FusionFilter_INSTALL_PATH/util/gtf_file_to_feature_seqs.pl
ln -s $FusionFilter_INSTALL_PATH/util/gtf_to_exon_gene_records.pl
ln -s $FusionFilter_INSTALL_PATH/util/gtf_to_gene_spans.pl
ln -s $FusionFilter_INSTALL_PATH/util/index_blast_pairs.pl
ln -s $FusionFilter_INSTALL_PATH/util/index_blast_pairs.remove_gene_pair.pl
ln -s $FusionFilter_INSTALL_PATH/util/index_blast_pairs.remove_overlapping_genes.pl
ln -s $FusionFilter_INSTALL_PATH/util/index_cdna_seqs.pl
ln -s $FusionFilter_INSTALL_PATH/util/index_pfam_domain_info.pl
ln -s $FusionFilter_INSTALL_PATH/util/isoform_blast_gene_chr_conversion.pl
ln -s $FusionFilter_INSTALL_PATH/util/isoform_blast_mapping_indexer.pl
ln -s $FusionFilter_INSTALL_PATH/util/just_blast_test.pl
ln -s $FusionFilter_INSTALL_PATH/util/make_super_locus.pl
ln -s $FusionFilter_INSTALL_PATH/util/promiscuity_filter.pl
ln -s $FusionFilter_INSTALL_PATH/util/remove_long_intron_readthru_transcripts.pl
