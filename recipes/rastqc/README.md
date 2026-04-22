# RastQC Bioconda recipe

This directory contains the Bioconda recipe for RastQC. One recipe builds two packages:

- **`rastqc`** — core build (short-read QC). No HDF5/Arrow deps. Installs `rastqc`.
- **`rastqc-nanopore`** — full build with `--features nanopore` (Fast5 + POD5 readers). Depends on `hdf5` and `libarrow`. Installs `rastqc-nanopore` (same CLI, renamed to avoid a file collision with the core package).

## Local build + test

```bash
# 1. Install conda-build (conda-forge rust toolchain is pulled in automatically by the recipe).
conda create -n cbuild -c conda-forge conda-build
conda activate cbuild

# 2. Build both outputs from the repo root.
conda build -c conda-forge -c bioconda recipes/rastqc

# 3. Install and smoke-test the core package.
conda create -n rqc-test -c local -c bioconda -c conda-forge rastqc
conda activate rqc-test
rastqc --version
printf '@r1\nACGT\n+\n!!!!\n' | rastqc --stdin -o /tmp/rqc-out
ls /tmp/rqc-out

# 4. Install and smoke-test the nanopore variant.
conda create -n rqc-nano-test -c local -c bioconda -c conda-forge rastqc-nanopore
conda activate rqc-nano-test
rastqc-nanopore --long-read --help
```

## Before submitting to bioconda-recipes

1. Push a release tag upstream: `git tag v0.1.0 && git push --tags`.
2. Fill `source.sha256` in `meta.yaml`:
   ```bash
   curl -sL https://github.com/Huang-lab/RastQC/archive/refs/tags/v0.1.0.tar.gz | sha256sum
   ```
3. Confirm the maintainer GitHub handle in `extra.recipe-maintainers`.

## Submission

Fork [`bioconda/bioconda-recipes`](https://github.com/bioconda/bioconda-recipes), copy this `rastqc/` directory into `recipes/rastqc/` in the fork, open a PR, and address bioconda CI feedback (linter + bulk build).
