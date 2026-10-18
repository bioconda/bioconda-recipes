#!/bin/bash

python3 -m pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_core_sci_sm-0.5.4.tar.gz --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
python3 -m pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_core_sci_md-0.5.4.tar.gz --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
python3 -m pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_core_sci_lg-0.5.4.tar.gz --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
python3 -m pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_core_sci_scibert-0.5.4.tar.gz --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
python3 -m pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_ner_craft_md-0.5.4.tar.gz --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
python3 -m pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_ner_jnlpba_md-0.5.4.tar.gz --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
python3 -m pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_ner_bc5cdr_md-0.5.4.tar.gz --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
python3 -m pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_ner_bionlp13cg_md-0.5.4.tar.gz --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
