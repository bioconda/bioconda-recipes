#!/bin/bash
mkdir -p $PREFIX/bin
cp src/* $PREFIX/bin

cp Rfam_for_miRDeep.fa $PREFIX/bin

chmod +x $PREFIX/bin/bwa_sam_converter.pl
chmod +x $PREFIX/bin/clip_adapters.pl
chmod +x $PREFIX/bin/collapse_reads_md.pl
chmod +x $PREFIX/bin/convert_bowtie_output.pl
chmod +x $PREFIX/bin/excise_precursors_iterative_final.pl
chmod +x $PREFIX/bin/excise_precursors.pl
chmod +x $PREFIX/bin/extract_miRNAs.pl
chmod +x $PREFIX/bin/fastaparse.pl
chmod +x $PREFIX/bin/fastaselect.pl
chmod +x $PREFIX/bin/fastq2fasta.pl
chmod +x $PREFIX/bin/find_read_count.pl
chmod +x $PREFIX/bin/geo2fasta.pl
chmod +x $PREFIX/bin/get_mirdeep2_precursors.pl
chmod +x $PREFIX/bin/illumina_to_fasta.pl
chmod +x $PREFIX/bin/make_html2.pl
chmod +x $PREFIX/bin/make_html.pl
chmod +x $PREFIX/bin/mapper.pl
chmod +x $PREFIX/bin/mirdeep2bed.pl
chmod +x $PREFIX/bin/miRDeep2_core_algorithm.pl
chmod +x $PREFIX/bin/miRDeep2.pl
chmod +x $PREFIX/bin/parse_mappings.pl
chmod +x $PREFIX/bin/perform_controls.pl
chmod +x $PREFIX/bin/permute_structure.pl
chmod +x $PREFIX/bin/prepare_signature.pl
chmod +x $PREFIX/bin/quantifier.pl
chmod +x $PREFIX/bin/remove_white_space_in_id.pl
chmod +x $PREFIX/bin/rna2dna.pl
chmod +x $PREFIX/bin/samFLAGinfo.pl
chmod +x $PREFIX/bin/sam_reads_collapse.pl
chmod +x $PREFIX/bin/sanity_check_genome.pl
chmod +x $PREFIX/bin/sanity_check_mapping_file.pl
chmod +x $PREFIX/bin/sanity_check_mature_ref.pl
chmod +x $PREFIX/bin/sanity_check_reads_ready_file.pl
chmod +x $PREFIX/bin/select_for_randfold.pl
chmod +x $PREFIX/bin/survey.pl

touch $PREFIX/install_successful
