GROMACS versions are released in series, so we maintain one
recipe folder for each major version.

Do not update more than 1 recipe at a time.  To build GROMACS for a single SIMD
takes approximatly 25 minutes.  3 SIMD types built for both nompi and OpenMPI
results in a build of 2hr30 minutes for Linux and 2hrs for OSX.  This pushes close
to the maximum allowed build time.


# Notes for future releases

- GROMACS 2021.1: This version of GROMACS has a fault and has to be patched manually.
This patch will need to be removed for future versions.

- AVX512: This was removed from the SIMD list as it is not widly used on laptops and
desktops currently.  It should be added back in the future, but another SIMD type
will need to be removed to keep the build time down.

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
