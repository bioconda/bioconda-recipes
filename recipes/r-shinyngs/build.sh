#!/bin/bash

# The reason for the additions to DESCRIPTION is that we need packrat and
# rsconnect to find the package for shinyapps.io deployment. This normally
# doesn't work for github packages except those installed via
# devtools::install_github(), but the DESCRIPTON edits here should mimic that.
# I'm doing the same for a key dependency, d3heatmap, which is now archived in
# CRAN (so packrat won't find it from there), but we can pull from github.

ammend_description_for_packrat(){
    description=$1
    remoterepo=$2
    remoteusername=$3
    remoteref=$4
   
    remotesha=$(git ls-remote https://github.com/$remoteusername/$remoterepo tags/$remoteref | cut -f1) 

    echo -e """RemoteType: github
RemoteHost: api.github.com
RemoteRepo: $remoterepo
RemoteUsername: $remoteusername
RemoteRef: $remoteref
RemoteSha: $remotesha
GithubRepo: $remoterepo
GithubUsername: $remoteusername
GithubRef: $remoteref
GithubSHA1: $remotesha
NeedsCompilation: no""" >> $description
}

ammend_description_for_packrat "shinyngs/DESCRIPTION" "shinyngs" "pinin4fjords" "v$PKG_VERSION"
ammend_description_for_packrat "d3heatmap/DESCRIPTION" "d3heatmap" "cran" "$D3HEATMAP_VERSION"

${R} CMD INSTALL --build d3heatmap ${R_ARGS}
${R} CMD INSTALL --build shinyngs ${R_ARGS}

# copy supplementary scripts
chmod +x shinyngs/exec/*.R
cp shinyngs/exec/*.R ${PREFIX}/bin
