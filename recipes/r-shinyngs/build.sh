#!/bin/bash

# The reason for the devtools install is that uploads to shinyapps.io only
# works with GitHub dependencies installed via devtools (see
# https://docs.rstudio.com/shinyapps.io/getting-started.html#important-note-on-github-packages).
# I'm relying on the PKG hash to maintain consistency with the hash in the
# meta.yaml.

shinyngs="devtools::install_github('pinin4fjords/shinyngs', ref='v$PKG_VERSION', dependencies = FALSE, upgrade = FALSE)"
d3heatmap="devtools::install_github('talgalili/d3heatmap', dependencies = FALSE, upgrade = FALSE)"

$R -e "$d3heatmap; $shinyngs"

# copy supplementary scripts
chmod +x exec/*.R
cp exec/*.R ${PREFIX}/bin
