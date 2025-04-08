# Bioconda Recipe for bbmapy

This directory contains the Bioconda recipe for bbmapy, a Python wrapper for BBTools.

## Recipe Structure

- `bbmapy/`: Directory containing the recipe files
  - `meta.yaml`: Main recipe file
  - `README.md`: Documentation for the package

## Dependencies
bbmapy requires **java** to be available. If it is not available, bbmapy will use the install-jdk conda/pip package to install adoptium (eclipse) JRE to the conda prefix.

## Submitting to Bioconda

To submit this recipe to Bioconda, follow these steps:

1. Fork the [bioconda-recipes](https://github.com/bioconda/bioconda-recipes) repository
2. Create a new branch for your recipe
3. Copy the contents of the `bbmapy/` directory to `recipes/bbmapy/` in your fork
4. Commit the changes and push to your fork
5. Create a pull request to the bioconda-recipes repository

## Building Locally

To build the recipe locally, you can use the following commands:

```bash
# Install conda-build
conda install -c conda-forge conda-build

# Build the recipe
conda build recipes/bbmapy

# Install the package
conda install --use-local bbmapy
```
