#!/usr/bin/env Rscript
library(immunedeconv)
library(readr)
library(dplyr)
library(testit)

test_mat = read_tsv("tests/testthat/bulk_mat.tsv") %>% as.data.frame() %>% tibble::column_to_rownames("gene_symbol")

lapply(deconvolution_methods, function(method) {
         # cibersort requires the binary path to be set, n/a in unittest.
         if(!method %in% c("cibersort", "cibersort_abs")) {
           print(paste0("method is ", method))
           res = deconvolute(test_mat, method, indications=rep("brca", ncol(test_mat)))
           # matrix has the 'cell type' column -> +1
           assert("matrix dimensions consistent", ncol(res) == ncol(test_mat) + 1)
           assert("cell type column exists", colnames(res)[1] == "cell_type")
           assert("sample names consistent with input", colnames(res)[-1] == colnames(test_mat))
         }
})
