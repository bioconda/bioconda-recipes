#!/usr/bin/env Rscript

# TEST: load library and execute each method once using example data

library(immunedeconv);

# exclude CIBERSORT, as it requires additional user input.
exclude_methods = c('cibersort', 'cibersort_abs');
methods = deconvolution_methods[!deconvolution_methods %in% exclude_methods];

# small test dataset with five samples
expr_mat = example_gene_expression_matrix[,1:5]

lapply(methods, function(method) {
         res = deconvolute(expr_mat, method, indications=rep('brca', 5));

         # check that the matrix dimensions are consistent: 5 samples + 1 cell type
         stopifnot(ncol(res) == 5 + 1);
})
