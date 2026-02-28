#!/bin/sh

set -e

# mulled-tests can't handle source_files <https://github.com/bioconda/bioconda-recipes/pull/29042#issuecomment-864465780>
# So we're using this script to run tests that need source_files.

cyntenator -t "(HSX.txt MMX.txt)" -h phylo HSCFMM.blast "((HSX.txt:1.2 MMX.txt:1.3):0.5 CFX.txt:2.5):1" | diff -wu human_mouse -

cyntenator -t "(human_mouse CFX.txt)" -h phylo HSCFMM.blast "((HSX.txt:1.2 MMX.txt:1.3):0.5 CFX.txt:2.5):1"

cyntenator -last -t "((HSX.txt MMX.txt) CFX.txt)" -h phylo HSCFMM.blast  "((HSX.txt:1.2 MMX.txt:1.3):0.5 CFX.txt:2.5):1"

cyntenator  -t "(HSX.txt MMX.txt)" -h blast HSCFMM.blast
