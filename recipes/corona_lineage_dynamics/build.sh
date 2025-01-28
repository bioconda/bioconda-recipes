#!/bin/bash

CONDA_PREFIX=$PREFIX
g++ --std=c++17 scripts/count_lineages_country.cpp -o scripts/count_lineages_country -O2 -lstdc++fs -lboost_regex -I ${CONDA_PREFIX}/include/ -L ${CONDA_PREFIX}/lib/

Rscript -e 'install.packages("devtools", repos="https://cloud.r-project.org");
    '

Rscript -e 'install.packages(c("XML", "binom", "plotly", "htmlwidgets", "countrycode", "doParallel",
  "dplyr", "foreach", "htmltools", "plyr", "Rcpp", "RCurl", "readr", "stringr", "tictoc", "tidyr",
  "xtable"), repos="https://cloud.r-project.org");
  if (!require("devtools")) install.packages("devtools",
    repos="https://cloud.r-project.org");
    devtools::install_github("rstudio/d3heatmap");'


# Define the target directory
TARGET_DIR=$PREFIX/share/corona_lineage_dynamics

# Create the target directory
mkdir -p $TARGET_DIR

# Copy the entire repository to the target directory
cp -r * $TARGET_DIR/

# Create the proxy script in $PREFIX/bin
mkdir -p $PREFIX/bin
cat > $PREFIX/bin/corona_lineage_dynamics <<EOF 
#!/bin/bash
bash $TARGET_DIR/SDPlots_lineages_local.sh "\$@"
EOF

# Make the proxy script executable
chmod +x $PREFIX/bin/corona_lineage_dynamics

