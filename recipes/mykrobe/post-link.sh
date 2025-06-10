#!/bin/bash

if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "x86_64" ]]; then
  mykrobe panels --help
else
  mykrobe panels update_metadata
  mykrobe panels update_species all
fi
