#!/usr/bin/env bash

cat <<EOF >> ${PREFIX}/.messages.txt

Please run 'DRAM-setup.py prepare_databases --output_dir /absolute/path/to/store/databases/' to download all required DRAM database files to '/absolute/path/to/store/databases/'.
'/absolute/path/to/store/databases/' is the local location where one wants the database files downloaded.

EOF
