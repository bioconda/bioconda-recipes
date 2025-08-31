# PADLOC-conda

<a href="https://anaconda.org/padlocbio/padloc" alt="Conda release"><img src="https://img.shields.io/conda/vn/padlocbio/padloc?color=yellow&label=conda%20release"></a>

## About

This repo contains the `meta.yaml` and `build.sh` files required for building a conda package for PADLOC.

## Building a PADLOC release

### Dependencies

- **[Conda](https://docs.conda.io/en/latest/miniconda.html)** (Miniconda recommended)
- **[Anaconda client](https://anaconda.org/anaconda/anaconda-client)**: `conda install anaconda-client`
- **[Conda build](https://anaconda.org/anaconda/conda-build)**: `conda install conda-build`
- **[GitHub CLI](https://cli.github.com/)** (optional)

### Workflow

##### Inside padloc directory

1. Make changes to PADLOC code, commit and push to GitHub.
2. Set release number (adhering to [semantic versioning](https://semver.org/)):
```bash
release="" # e.g. release=v1.0.0
```
3. Initiate release and follow prompts (this can also be done via the [GitHub website](https://github.com/padlocbio/padloc/releases/new)):

```bash
gh release create "${release}"
```

```bash
# $ gh release create v1.0.0
# ? Title (optional) v1.0.0
# ? Release notes Write my own
# ? Is this a prerelease? No
# ? Submit? Publish release
# https://github.com/padlocbio/padloc/releases/tag/1.0.0
```

4. Download tarball and check shasum:

```bash
curl -sL "https://github.com/padlocbio/padloc/archive/refs/tags/${release}.tar.gz" --output "${release}.tar.gz"
sha256sum "${release}.tar.gz"
```

5. Cleanup:

```
rm "${release}.tar.gz"
```

##### Inside padloc-conda directory

1. Bump version number in `meta.yaml` and replace shasum.
2. Build conda package:

```bash
conda config --set anaconda_upload no # stop automatic upload
conda build .
```

7. Upload to Anaconda.org (you may need to login first with `anaconda login`):

```bash
anaconda upload "<path to padloc-X.X.X-X.tar.bz2>" # conda-build prints this path
```

### Deleting a release

If you ever need to delete a release from GitHub:

```bash
release=""
gh release delete "${release}"        # delete release
git push --delete origin "${release}" # delete remote tag
git tag -d "${release}"               # delete local tag
```

If you ever need to delete a release from Anaconda:

```bash
anaconda remove "padlocbio/padloc/${release#v}"
```
