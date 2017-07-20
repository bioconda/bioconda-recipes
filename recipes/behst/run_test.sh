#!/bin/bash
download_behst_data.sh /tmp/behst

behst.py /tmp/behst/pressto_LUNG_enhancers.bed /tmp/behst
