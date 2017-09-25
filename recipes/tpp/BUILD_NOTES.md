The following are miscellaneous notes on the process of getting TPP to build
in the conda system (which was not straightward), for use by future
packagers/maintainers.

### Static builds

A few of the TPP programs ask for static compilation, but the static libs of
various core dependencies (libc, etc) don't seem to be present on the conda
build system or in any of its packages. As a result, I had to remove the
'-static' flag in a few places in the Makefiles to get the build working.

### Silent makes

Most, if not all, of the calls to `make` were patched to include the
`--silent` flag to cut down on otherwise copious output during the build.

### Windows-specific components

Since bioconda does not officially support Windows builds, various
Windows-specific targets were removed.

### Avoiding conflicts with other conda packages

The TPP distribution includes a number of programs which are also available
within conda, including hardklor, msconvert, X!Tandem, etc. A number of
patches were applied to avoid installing these binaries from the TPP package
so that users don't inadvertently have their conda-managed versions
overwritten.
