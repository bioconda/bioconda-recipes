#!/bin/bash
set -euo pipefail

"$R" --vanilla --slave -e "source('demo/run_demo.R');
stopifnot(length(anno) > 0L, nrow(se) == length(anno),
ncol(se) == 2L, ncol(combineSE) == 2L, length(chi_GTF) > 0L,
length(Teddy::annotateTEPosition(chi_GTF, te, combineSE = combineSE, minoverlap = 5)) > 0L)"
