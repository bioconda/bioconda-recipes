#!/bin/bash

sed -i "s/'misc==0.2.8'//" setup.py
sed -i 's/0.2.8/0.2.10/' requirements.txt
$PYTHON setup.py install
cp *.py ${PREFIX}/bin/
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/get_all_utrs.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/count_aligned_reads.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/count_reads.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/run_bowtie.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/extract_cds_coordinates.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/mygene_utils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/join_long_chromosomes.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/split_bed12_blocks.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/get_read_length_distribution.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/fasta_to_fastq.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/create_aligned_read_count_bar_chart.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/remove_duplicate_sequences.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/reorder_fasta.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/gffread_utils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/bam_to_wiggle.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/pyensembl_utils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/convert_ccds_to_bed.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/parse_meme_names.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/fastx_utils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/bed12_to_gtf.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/calculate_bed_overlap.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/create_mygene_report.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/extract_bed_sequences.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/filter_bam_by_ids.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/fix_all_bed_files.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/merge_isoforms.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/remove_multimapping_reads.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/bam_utils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/gtf_utils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/fastq_pe_dedupe.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/bam_utils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/plot_read_length_distribution.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/run_tmhmm.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/remove_duplicate_bed_entries.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/download_srr_files.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/remove_duplicate_bed_entries.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/subtract_bed.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/gtf_to_bed12.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/bedx_to_bedy.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/bed_to_bigBed.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/metacyc_utils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/meme_utils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/split_long_chromosomes.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/bed_utils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/run_signalp.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/TestBedUtils.py
sed -i 's/misc/pymisc-utils/' ${PREFIX}/bin/bio.py
chmod 755 ${PREFIX}/bin/*.py
