#!/bin/bash

set -x
set -euo pipefail

TMPDIR=$(mktemp -d)
unzip -d $TMPDIR gatkPythonPackageArchive.zip
cd $TMPDIR

# NB: patch cannot be applied automatically by conda-build as gatkPythonPackageArchive.zip
# needs to be extracted first.  I decided to place it here so everything is in one file
# and I don't have to play with paths.
cat >$TMPDIR/io_intervals_and_counts.diff <<"EOF"
--- gcnvkernel/io/io_intervals_and_counts.py	2020-04-29 07:22:31.306406730 +0200
+++ gcnvkernel/io/io_intervals_and_counts.py	2020-04-29 07:22:44.458460968 +0200
@@ -38,9 +38,9 @@
     if return_interval_list:
         interval_list_pd = counts_pd[list(interval_dtypes_dict.keys())]
         interval_list = _convert_interval_list_pandas_to_gcnv_interval_list(interval_list_pd, read_counts_tsv_file)
-        return sample_name, counts_pd[io_consts.count_column_name].as_matrix(), interval_list
+        return sample_name, counts_pd[io_consts.count_column_name].values, interval_list
     else:
-        return sample_name, counts_pd[io_consts.count_column_name].as_matrix(), None
+        return sample_name, counts_pd[io_consts.count_column_name].values, None


 def load_interval_list_tsv_file(interval_list_tsv_file: str,
EOF

patch -p0 <$TMPDIR/io_intervals_and_counts.diff 

$PYTHON setup_gcnvkernel.py install
