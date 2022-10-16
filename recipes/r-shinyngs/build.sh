#!/bin/bash

# The reason for the additions to DESCRIPTION is that we need packrat and
# rsconnect to find the package for shinyapps.io deployment. This normally
# doesn't work for github packages except those installed via
# devtools::install_github(), but the DESCRIPTON edits here shoudl mimic that.

echo -e """RemoteType: github
RemoteHost: api.github.com
RemoteRepo: shinyngs
RemoteUsername: pinin4fjords
RemoteRef: v$PKG_VERSION
RemoteSha: $SHA256
GithubRepo: shinyngs
GithubUsername: pinin4fjords
GithubRef: v$PKG_VERSION
GithubSHA1: $SHA256
NeedsCompilation: no""" >> DESCRIPTION

${R} CMD INSTALL --build . ${R_ARGS}

# copy supplementary scripts
chmod +x exec/*.R
cp exec/*.R ${PREFIX}/bin
