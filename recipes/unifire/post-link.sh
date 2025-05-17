#!/bin/bash

set -euo pipefail

# Print instructions for downloading UniFIRE URML and template input files
cat <<'EOF'
***************************************************************
   _    _       _  __ _           
  | |  | |     (_)/ _(_)          
  | |  | |_ __  _| |_ _  ___ _ __ 
  | |  | | '_ \| |  _| |/ _ \ '__|
  | |__| | | | | | | | |  __/ |   
   \____/|_| |_|_|_| |_|\___|_|  

     UniProt Functional annotation Inference Rule Engine
***************************************************************

# ------------------------------------------------------------
# Retrieving Unifire URML and template input files
# ------------------------------------------------------------

To download the URML and template input files, replace '2025_02'
with the version you need and run the following commands. If you are
using this in a container, then you will need to do this outside of the
container and then mount the data into the container.

wget ftp://ftp.ebi.ac.uk/pub/contrib/UniProt/UniFIRE/rules/arba-urml-2025_02.xml
wget ftp://ftp.ebi.ac.uk/pub/contrib/UniProt/UniFIRE/rules/unirule-urml-2025_02.xml
wget ftp://ftp.ebi.ac.uk/pub/contrib/UniProt/UniFIRE/rules/unirule-templates-2025_02.xml
wget ftp://ftp.ebi.ac.uk/pub/contrib/UniProt/UniFIRE/rules/unirule.pirsr-urml-2025_02.xml
wget https://proteininformationresource.org/pirsr/pirsr_data_latest.tar.gz

To extract the PIRSR data archive, run:

tar -xzf pirsr_data_latest.tar.gz

# ------------------------------------------------------------
# Running PIRSR
# ------------------------------------------------------------

**NOTE**: hmmeralign is provided in the environment/image. It is not necessary to
provide the `-a` flag when running `pirsr`

# ------------------------------------------------------------
# Retrieving taxa.sqlite for updateIPRScanWithTaxonomicLineage
# ------------------------------------------------------------

To get `taxa.sqlite`, follow the "NCBI Example" instructions at:

https://etetoolkit.github.io/ete/tutorial/tutorial_taxonomy.html#setting-up-local-copies-of-the-ncbi-and-gtdb-taxonomy-databases

mount the file into the container and provide it via the `-t` flag

EOF
