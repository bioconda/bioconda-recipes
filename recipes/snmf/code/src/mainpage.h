/**
 * @file mainpage.h 
 * @mainpage [replop] PhD project: a set of tools for population genetics
 *
 * @date 2011-2014
 * 
 * 
 * 
 * @brief This API (Application Programming Interface) gathers groups of codes
 * for data conversion, sNMF, LFMM and pca. 
 * 
 * Each directory is associated with a module. A module gathers a set
 * of functions with a common objective. There are two types of modules:
 * tool modules and program modules. There is also the main module
 * containing all the main functions.

 * The tool modules are:
 * - io: manage in and out, read and write (for matrices mainly)
 * - matrix: matrix calculation functions (cholesky, sylvester, rand)
 * - stats: statistical tools (Warning, the random generator is in matrix/rand)
 * - nnlsm: compute the non-negative least square solution with an active-set method
 * developped by Kim and Park (2011).
 * - bituint: manage binary matrices stored in bits.
 * 
 * Each program module has the same organization. There are:
 * - a principal file (same name as the directory and called by the main), 
 * - an error manager file called error_{module name}, 
 * - a file to manage print print_{nom module}, 
 * - a file to manage parameters called register_{nom module}. 
 * - If a structure is used to store parameters, it is declared in the header of the principal file. 
 * - A file called update_{name of a variable} gathers a set of functions to update the given variable. 
 * - Files called thread_* gather functions for multithreading. 
 *  A file called *_algo is the principal file for the estimation algorithm. 
 * 
 * The convert module is a bit different because it gathers several programs for data conversion.
 * 
 * The program modules are:
 * - convert: convert from the geno, lfmm, vcf, ancestrymap, ped to the lfmm and geno formats.
 * - sNMF: estimate the admixture coefficients. (web page http://membres-timc.imag.fr/Olivier.Francois/snmf.html) sNMF and it sub-programs (crossEntropy) use binary matrix format, bituint. sNMF uses nnlsm to calculate 
the parameters of the model. 
 * - crossEntropy: calculate the cross-entropy after a sNMF run.
 * - createDataSet: create a data set with masked genotypes.
 * - LFMM: test for the association between an environmental variable and genotypic data using latent factor mixed
models. (web page: http://membres-timc.imag.fr/Olivier.Francois/lfmm.html)
 * - pca: calculate a Principal Component Analysis (PCA) of a genetic data set.
 * - tracyWidom: perform tracy-Widom tests for a given set of eigenvalues.
 *
 * A Lapack module is not documented. It gathers a subset of functions from the package
   dedicated to matrix calculation, Lapack.
 */

