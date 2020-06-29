# R/SGCCA 

#### Author : Etienne CAMENEN

#### Key-words: 
omics, RGCCA, multi-block

#### EDAM operation
analysis, correlation, visualisation

#### Contact
arthur.tenenhaus@l2s.centralesupelec.fr

#### Short description
Performs multi-variate analysis (PCA, CCA, PLS, R/SGCCA, etc.) and produces textual and graphical outputs (e.g. variables and individuals plots).

---

## Description
A user-friendly multi-blocks analysis (Regularized Generalized Canonical Correlation Analysis, RGCCA) with all default settings predefined. The software produces figures to explore the analysis' results: individuals and variables projected on two components of the multi-block analysis, list of top variables and explained variance in the model.
 
More information about:
- [RGCCA](https://cran.r-project.org/web/packages/RGCCA/vignettes/vignette_RGCCA.pdf)
- [input / output formats](https://github.com/rgcca-factory/RGCCA/tree/release/3.0.0#input-files)


## Usage instruction

### Installation
```
conda create -n rgcca -c icm-iconics/label/develop r-rgcca
```

### Execution (with Russet data)
```
conda activate rgcca && \
cd ${CONDA_PREFIX} && \
wget https://raw.githubusercontent.com/rgcca-factory/RGCCA/release/3.0.0/inst/extdata/agriculture.tsv && \
Rscript inst/launcher.R -d agriculture.tsv
 ```
 
 More information about the command-line parameters [here](https://github.com/rgcca-factory/RGCCA/tree/release/3.0.0#command-line).