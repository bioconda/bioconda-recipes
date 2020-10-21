#!/usr/bin/env bash

cat <<EOF >> ${PREFIX}/.messages.txt

Please run install_db.sh to download all required BLAST and SWISS-PROT database files to ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/db/.
If you already have these files downloaded, please set the variable BLASTDB accordingly (e.g. export BLASTDB=/path/to/blast_swiss-prot_directory/).

The default settings file is ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/settings.default.cjson.
If you want to use your own settings file, please set the variable SETTINGS_FILE accordingly (e.g. export SETTINGS_FILE=/path/to/settings_file/).

EOF
