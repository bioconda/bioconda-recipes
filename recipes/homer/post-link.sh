#!/bin/bash

cat <<EOF >> ${PREFIX}/.messages.txt

For Mac users: Homer is installed.
For Linux platforms/users: Once Homer is installed with bioconda, you still 
need to call the following executable manually:

    configureHomer


EOF
