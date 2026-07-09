[![Bioconda][bioconda_logo]][no_link]

# The bioconda channel

[![Gitter][gitter_badge]][gitter_link]

[Conda](http://anaconda.org) is a platform- and language-independent package
manager that supports easy distribution, installation and version management of
software. The [bioconda channel](https://anaconda.org/bioconda) is a Conda
channel providing bioinformatics related packages for **Linux** and **macOS**,
supporting both x86_64 and aarch64/arm64 architectures.
This repository hosts the corresponding recipes.

## User guide

Please visit https://bioconda.github.io for details.

## Developer guide

Please visit the new docs at https://bioconda.github.io/contributor/index.html for details.

## Nightly build status
The nightly uploader jobs build any recipes that exist on master but were not successfully uploaded to the [bioconda channel](https://anaconda.org/bioconda). Any failure in the nightly build should be resolved with a PR for the affected recipe.

| arch          | build status                                                            |
|---------------|-------------------------------------------------------------------------|
| linux-64      | [![Nightly linux-64][nightly_linux-64_badge]][nightly_linux-64_link]    |
| osx-64        | [![Nightly osx-64][nightly_osx-64_badge]][nightly_osx-64_link]          |
| osx-arm64     | [![Nightly osx-arm64][nightly_osx-arm64_badge]][nightly_osx-arm64_link] |
| linux-aarch64 | [CircleCI (login required)][nightly_linux-aarch64_link]                 |

<!-- Markdown reference-style links -->

[bioconda_logo]: https://raw.githubusercontent.com/bioconda/bioconda-recipes/master/logo/bioconda_monochrome_small.png
[no_link]: #

[gitter_badge]: https://badges.gitter.im/bioconda/bioconda-recipes.svg
[gitter_link]: https://gitter.im/bioconda/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge

[nightly_linux-64_badge]: https://dev.azure.com/bioconda/bioconda-recipes/_apis/build/status/Nightly%20uploader?branchName=master&jobName=build_and_push_linux&label=Nightly%20linux-64
[nightly_linux-64_link]: https://dev.azure.com/bioconda/bioconda-recipes/_build/latest?definitionId=4

[nightly_osx-64_badge]: https://dev.azure.com/bioconda/bioconda-recipes/_apis/build/status/Nightly%20uploader?branchName=master&jobName=build_and_push_osx&label=Nightly%20osx-64
[nightly_osx-64_link]: https://dev.azure.com/bioconda/bioconda-recipes/_build/latest?definitionId=4

[nightly_osx-arm64_badge]: https://github.com/bioconda/bioconda-recipes/actions/workflows/nightly.yml/badge.svg
[nightly_osx-arm64_link]: https://github.com/bioconda/bioconda-recipes/actions/workflows/nightly.yml

[nightly_linux-aarch64_link]: https://app.circleci.com/insights/github/bioconda/bioconda-recipes/workflows/Nightly%20(ARM)/overview?branch=master&reporting-window=last-24-hours
