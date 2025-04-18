# Contributing to Bioconda

This directory contains a recipe for HYMET that can be contributed to the Bioconda channel. Follow these steps to contribute the recipe to the Bioconda repository:

## Prerequisites

1. Fork the Bioconda recipes repository:
   ```
   https://github.com/bioconda/bioconda-recipes
   ```

2. Clone your fork to your local machine:
   ```
   git clone https://github.com/YOUR_USERNAME/bioconda-recipes.git
   cd bioconda-recipes
   ```

3. Set up a conda environment for recipe development:
   ```
   conda env create -f config/conda_build_env.yaml
   conda activate bioconda
   ```

## Adding the HYMET Recipe

1. Create a new recipe directory:
   ```
   mkdir -p recipes/hymet
   ```

2. Copy the recipe files from this directory:
   ```
   cp meta.yaml build.sh post-link.sh conda_build_config.yaml recipes/hymet/
   ```

3. Make sure to update the `meta.yaml` file with the correct SHA256 checksum after the package is published on GitHub.

4. Test the recipe locally:
   ```
   bioconda-utils build recipes/hymet
   ```

5. Create a branch and commit your changes:
   ```
   git checkout -b add-hymet-recipe
   git add recipes/hymet
   git commit -m "Add recipe for HYMET"
   ```

6. Push to your fork and create a pull request:
   ```
   git push origin add-hymet-recipe
   ```

7. Create a pull request on the Bioconda recipes repository.

## Important Notes

1. Make sure the GitHub repository for HYMET includes a proper release with the version tag that matches the version in the recipe.

2. The source URL in the recipe should point to a specific tagged release of the software (not main/master branch).

3. The license file must be included in the GitHub repository.

4. Ensure all dependencies are correctly specified in the meta.yaml file.

5. Follow the Bioconda guidelines for contributing recipes: https://bioconda.github.io/contributor/guidelines.html 