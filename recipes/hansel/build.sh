#!/bin/env bash

#Install Heidelburg Subtyping
pip install heidelberg_subtyping

#Change so that the system's python isn't hardcoded, instead uses current global python version.
#sed -i 's|/#!/usr/bin/python|#!/usr/bin/env python|g' ~/anaconda3/bin/heidelberg_subtyping