This recipe is for the MPI enabled version of GROMACS.  For the non MPI
enabled version, use the GROMACS package.

GROMACS versions are released in series, so we maintain one
recipe folder for each major version.

Be careful with the CI build time if updating multiple 
recipes, a single build takes about 1h12.

From https://manual.gromacs.org/documentation/2021.1/release-notes/index.html

> Major releases contain changes to the functionality supported, whereas patch
> releases contain only fixes for issues identified in the corresponding major
> releases.

> Two versions of GROMACS are under active maintenance, the 2021 series and the
> 2020 series. In the latter, only highly conservative fixes will be made, and
> only to address issues that affect scientific correctness.

> Naturally, some of those releases will be made after the year 2020 ends, but
> we keep 2019 in the name so users understand how up to date their version is.
> Such fixes will also be incorporated into the 2021 release series, as
> appropriate. Around the time the 2022 release is made, the 2020 series will no
> longer be maintained.
