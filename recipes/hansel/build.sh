#!/bin/env bash

#Change so that the system's python isn't hardcoded, instead uses current global python version.
sed -i 's|/#!/usr/bin/python|#!/usr/bin/env python|g' $HOME/anaconda3/bin/heidelberg_subtyping

#Install Heidelburg Subtyping
pip install heidelberg_subtyping

