# Bioconda Recipe for HYMET

This directory contains the Bioconda recipe for HYMET (Hybrid Metagenomic Tool), a taxonomic identification tool for metagenomic sequence analysis.

## Recipe Structure

- `meta.yaml`: Main recipe file defining package metadata, dependencies, and build information
- `build.sh`: Build script that installs the tool to the conda environment

## Building and Installing

### From bioconda channel (after publishing)

```bash
conda install -c bioconda hymet
```

### From local recipe

```bash
conda build .
conda install --use-local hymet
```

## Post-installation Steps

After installing HYMET, you need to download the required reference databases:

1. Download the database files from Google Drive:
   - [sketch1.msh.gz](https://drive.google.com/drive/folders/1YC0N77UUGinFHNbLpbsucu1iXoLAM6lm)
   - [sketch2.msh.gz](https://drive.google.com/drive/folders/1YC0N77UUGinFHNbLpbsucu1iXoLAM6lm)
   - [sketch3.msh.gz](https://drive.google.com/drive/folders/1YC0N77UUGinFHNbLpbsucu1iXoLAM6lm)

2. Place these files in the data directory of your HYMET installation and unzip them:

```bash
# Locate your conda environment
CONDA_ENV=$(dirname $(dirname $(which hymet)))

# Create data directory if it doesn't exist
mkdir -p $CONDA_ENV/bin/data

# Copy downloaded files to data directory
cp sketch*.msh.gz $CONDA_ENV/bin/data/

# Unzip files
gunzip $CONDA_ENV/bin/data/sketch1.msh.gz
gunzip $CONDA_ENV/bin/data/sketch2.msh.gz
gunzip $CONDA_ENV/bin/data/sketch3.msh.gz
```

3. Run the configuration script to setup taxonomy files:

```bash
hymet-config
```

## Usage

To run HYMET on your metagenomic data:

```bash
hymet
```

The script will prompt you for the input directory containing your FASTA files.

## Support

For questions or issues, please visit the [HYMET GitHub repository](https://github.com/inesbmartins02/HYMET) or open an issue. 