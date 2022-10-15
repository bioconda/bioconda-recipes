#!/bin/bash

# The reason for the devtools install is that uploads to shinyapps.io only
# works with GitHub dependencies installed via devtools (see
# https://docs.rstudio.com/shinyapps.io/getting-started.html#important-note-on-github-packages).
# I'm relying on the PKG hash to maintain consistency with the hash in the
# meta.yaml.

$R -e "devtools::install_github('pinin4fjords/shinyngs@'$PKG_HASH', dependencies = FALSE, upgrade = FALSE)"
$R -e "devtools::install_github('talgalili/d3heatmap', dependencies = FALSE, upgrade = FALSE)"

# copy supplementary scripts
chmod +x exec/*.R
cp exec/*.R ${PREFIX}/bin
