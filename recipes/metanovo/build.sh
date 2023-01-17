#!/bin/bash

# Copy executable scripts
declare -a metanovo_scripts=(
    metanovo_source/bin/bash/metanovo.sh
    metanovo_source/bin/bash/compomics.sh
    metanovo_source/bin/python/bp_export_tags.py
    metanovo_source/bin/python/bp_mapped_tags.py
    metanovo_source/bin/python/bp_export_proteins.py
    metanovo_source/bin/python/bp_fasta_prepare.py
    metanovo_source/bin/python/bp_parse_tags.py
)

for script in "${metanovo_scripts[@]}"; do
    cp $script "$PREFIX/bin"
done

# Copy python libraries.
cp metanovo_source/lib/tagmatch.py "$PREFIX/lib/python3.9/site-packages"

# Create source file. This sets paths for MetaNovo dependencies.
mkdir -p "$PREFIX/etc/conda/activate.d"
cp "$RECIPE_DIR/metanovo_activate.sh" "$PREFIX/etc/conda/activate.d/${PKG_NAME}_activate.sh"

# Create config/ directory for MetaNovo config
METANOVO_CONFIG_DIR="$PREFIX/config"
mkdir "$METANOVO_CONFIG_DIR"

# Copy default configuration.
cp metanovo_source/bin/config/metanovo_config.sh "$METANOVO_CONFIG_DIR"

# Create bio/ directory for MetaNovo dependencies and extract their downloads.
METANOVO_DEPENDENCIES="$PREFIX/bio"
DENOVOGUI_DIR="$METANOVO_DEPENDENCIES/DeNovoGUI"
UTILITIES_DIR="$METANOVO_DEPENDENCIES/utilities"
SEARCHGUI_DIR="$METANOVO_DEPENDENCIES/SearchGUI"

mkdir "$METANOVO_DEPENDENCIES"

mkdir "$DENOVOGUI_DIR"
cp -R denovogui_download/* "$DENOVOGUI_DIR"

mkdir "$UTILITIES_DIR"
cp -R compomics_utilities_download/*  "$UTILITIES_DIR"

mkdir "$SEARCHGUI_DIR"
cp -R searchgui_download/*  "$SEARCHGUI_DIR"
