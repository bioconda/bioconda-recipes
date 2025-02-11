#!/usr/bin/env bash

mkdir -p $PREFIX/bin

files=(polap
	polap-conda-environment-fmlrc.yaml
	polap-conda-environment.yaml
	polap-mt.1.c70.3.faa
	polap-pt.2.c70.3.faa
	run-polap-ncbitools
	polap-command-completion.sh
	polap-constants.sh
	polap-function-set-variables.sh
	polap-git-hash-version.sh
	polap-package-common.sh
	polap-package-mtcontigs.sh
	polap-parsing.sh
	polap-revision1.sh
	polap-test-variables.sh
	polap-variables-common.sh
	polap-variables-main.sh
	polap-variables-mtcontigs.sh
	polap-version.sh
	run-polap-function-annotate-contig.sh
	run-polap-function-annotate.sh
	run-polap-function-archive.sh
	run-polap-function-assemble.sh
	run-polap-function-bioproject.sh
	run-polap-function-errors.sh
	run-polap-function-include.sh
	run-polap-function-log.sh
	run-polap-function-menus.sh
	run-polap-function-miscellaneous.sh
	run-polap-function-mtdna.sh
	run-polap-function-oga.sh
	run-polap-function-polishing.sh
	run-polap-function-seeds.sh
	run-polap-function-taxonomy.sh
	run-polap-function-template.sh
	run-polap-function-test.sh
	run-polap-function-utilities.sh
	run-polap-function-wga.sh
	run-polap-sh-create-depth-file.sh
	run-polap-sh-half-cut.sh
	run-polap-sh-minimap2-paf2tab.sh
	run-polap-py-find-cc.py
	run-polap-py-mtdna-find-cycle-with-node-revisits.py
	run-polap-py-select-mtdna-2-nx-find-circular-path.py
	run-polap-py-select-mtdna-2-nx-simple-cycles.py
	run-polap-pairs.R
	run-polap-r-assemble-bioproject-3-length-match.R
	run-polap-r-blast-mtdna-1-determine-gene.R
	run-polap-r-bridge.R
	run-polap-r-cc2mtcontig.R
	run-polap-r-contig2edge.R
	run-polap-r-depth-distribution.R
	run-polap-r-depthfilter-gfa.R
	run-polap-r-determine-depth-range_1.R
	run-polap-r-determine-depth-range_2.R
	run-polap-r-determine-depth-range_3.R
	run-polap-r-determine-depth-range_4.R
	run-polap-r-determine-depth-range_5.R
	run-polap-r-determine-depth-range_6.R
	run-polap-r-determine-depth-range.R
	run-polap-r-edges-stats.R
	run-polap-r-final-filter-mtcontig.R
	run-polap-r-final-mtcontig.R
	run-polap-r-final-seed-mtcontig.R
	run-polap-r-genes-bed4.R
	run-polap-r-genes.R
	run-polap-r-get-bioproject-1.R
	run-polap-r-global-richness.R
	run-polap-r-jellyfish.R
	run-polap-r-mtcontig-contig.R
	run-polap-r-mtcontig.R
	run-polap-r-pairs.R
	run-polap-r-plastid-determine-depth-range_1.R
	run-polap-r-plastid-determine-depth-range_6.R
	run-polap-r-plastid-determine-depth-range.R
	run-polap-r-plot-mtdna.R
	run-polap-r-prepare-cc.R
	run-polap-r-preselect-annotation.R
	run-polap-r-select-mtdna-1-nx-gfa-links.R
	run-polap-r-taxonomy.R
	run-polap-r-template.R
	run-polap-r-test-reads-bar-graph.R
	polap.sh)

for i in "${files[@]}"; do
	cp src/$i $PREFIX/bin
done

chmod +x $PREFIX/bin/polap
chmod +x $PREFIX/bin/polap.sh
