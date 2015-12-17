##Setup

These scripts help create recipes for bioconductor packages. You can set up an
environment for running them using:

```bash
conda config --add channels bioconda
conda create -n bioconductor-recipes --file requirements.txt
source activate bioconductor-recipes
```

## Single Bioconductor recipe

To make a single recipe:

```bash
./bioconductor_skeleton.py --recipes ../../recipes GenomicRanges
```

Note that the case of the bioconductor package must match that of the actual
R package.  Use `--force` to overwrite the recipe.  The conda recipe
`../../recipes/bioconductor-genomicranges` will be created.

This script:

- parses the Bioconductor web page for the current version
- checks to see if a tarball for the version is available on
  [bioaRchive](https://bioarchive.galaxyproject.org/) and if so uses that for
  long-term stability. Otherwise it uses the tarball from the Bioconductor
  page.
- downloads the tarball to the `cached_bioconductor_tarballs` dir and extracts
  the `DESCRIPTION` file
- parses the DESCRIPTION file to identify dependencies
- converts dependencies to package names more friendly to `conda`,
  specifically prefixing `bioconductor-` or `r-` as needed and using lowercase
  package names
- bumps the build number if package versions are the same but something else in
  the recipe changed
- calculates md5sum on the cached tarball
- writes a `meta.yaml` and `build.sh` file to `recipes/<new package name>`.


Like building recipes with `conda skeleton`, it may take a few rounds of trying
to build the package, failing because of missing dependencies, running
`bioconductor_scraper.py` again to build dependency recipes, and trying to
build again:

```bash
(
    cd ../../
    docker pull bioconda/bioconda-builder
    docker run \
        -v `pwd`:/bioconda-recipes bioconda/bioconda-builder \
        -v --packages bioconductor-genomicranges
)

```

## Updating recipes

This is most needed when there is a new release of Bioconductor.

When possible, the tarball URLs in the recipes created by
`bioconductor_skeleton.py` point to the bioaRchive tarballs, which should have
more long-term stability. However, sometimes the latest package version listed
on the bioconductor page at the time of recipe creation is not available in
bioaRchive. In this case the recipe points to the bioconductor site's tarball.
However, a new release of Bioconductor will break that URL.

Two helper scripts make this as painless as possible:

`update_bioconductor_packages.py` does the following: 

- searches the recipe dir for `bioconductor-*` and `r-*` packages
- returns them topologically sorted such that if the packages are built in
  order, dependencies will be built first.

`update-bioconductor-packages-wrapper.sh` does the following:

- rolls back all changes in the recipes dir for any `bioconductor-` or `r-`
  recipes
- calls `update_bioconductor_packages.py` to get the toposorted list of
  existing recipes to work on
- for each R package, runs `conda skeleton cran --update-outdated` on the
  recipe
- for bioconductor packages, runs `bioconductor_skeleton.py` with `--force` to
  overwrite the existing recipes. This script also pays attention to whether or
  not there is a new bioaRchive tarball (even if the package version was
  unchanged), in which case it bumps the build number to trigger a re-build of
  the recipe

So in practice, when a new Bioconductor release comes out, you should simply
have to do:

```bash
./update-bioconductor-packages-wrapper.sh ../../recipes
(
    cd ../../
    docker run \
        -v `pwd`:/bioconda-recipes bioconda/bioconda-builder \
        -v
)
```

Note that some packages specify dependency versions using strings that are not
allowed by conda. For example, GenomicFeatures 1.22.6 specifies RSQLite 0.8-1.
That `-1` is not allowed by conda. Rather than be tricky about automatically
fixing version strings, currently you have to fix this manually. In this case,
since the earliest RSQLite conda package is 1.0.0, we can either get rid of the
version specification or change it to 1.0.0.
