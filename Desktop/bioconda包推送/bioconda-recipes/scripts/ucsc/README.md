Supporting code for creating packages and metapackages for [UCSC
executables](http://hgdownload.cse.ucsc.edu/admin/exe/).


The script `create-ucsc-packages.py` downloads the program listing from UCSC,
downloads the source code, and creates recipes for every identified program
(e.g., 115 programs in v324). There are some special cases handled by the
script. The script uses the templates in this directory to be able to compile
the tools individually in each recipe.

Update `ucsc_config.yaml` to update the packages when a new version comes out.
