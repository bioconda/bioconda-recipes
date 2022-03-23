#!/bin/bash

# Copy executable scripts
declare -a metanovo_scripts=(
    bin/bash/metanovo.sh
    bin/bash/compomics.sh
    bin/python/bp_export_tags.py
    bin/python/bp_mapped_tags.py
    bin/python/bp_export_proteins.py
    bin/python/bp_fasta_prepare.py
    bin/python/bp_parse_tags.py
)

for script in "${metanovo_scripts[@]}"; do
    cp $script "$PREFIX/bin"
done

# Copy python libraries.
cp lib/tagmatch.py "$PREFIX/lib/python3.9/site-packages"

# Create source file. This sets paths for MetaNovo dependencies.
mkdir -p "$PREFIX/etc/conda/activate.d"
cp "$RECIPE_DIR/metanovo_activate.sh" "$PREFIX/etc/conda/activate.d/${PKG_NAME}_activate.sh"

# Create bio/ directory for MetaNovo dependencies.
METANOVO_DEPENDENCIES="$PREFIX/bio"
mkdir "$METANOVO_DEPENDENCIES"

# Install downloaded dependencies
declare -A dependency_urls

dependency_urls['PeptideShaker']='http://genesis.ugent.be/maven2/eu/isas/peptideshaker/PeptideShaker/1.16.2/PeptideShaker-1.16.2.zip'
dependency_urls['SearchGUI']='http://genesis.ugent.be/maven2/eu/isas/searchgui/SearchGUI/3.2.20/SearchGUI-3.2.20-mac_and_linux.tar.gz'
dependency_urls['DeNovoGUI']='http://genesis.ugent.be/maven2/com/compomics/denovogui/DeNovoGUI/1.15.11/DeNovoGUI-1.15.11-mac_and_linux.tar.gz'
dependency_urls['utilities']='http://genesis.ugent.be/maven2/com/compomics/utilities/4.12.0/utilities-4.12.0.zip'

for dependency in "${!dependency_urls[@]}"; do
    mkdir $METANOVO_DEPENDENCIES/$dependency
    cd $METANOVO_DEPENDENCIES/$dependency
    url=${dependency_urls[$dependency]}
    extension="${url##*.}"
    wget $url
    if [[ $extension == "gz" ]]; then
        tar -zxvf *.tar.gz && rm -rf *.tar.gz
    elif [[ $extension == "zip" ]]; then
        unzip *.zip && rm -rf *.zip
    else
        echo "File download failed" >&2
        exit 1
    fi
done
