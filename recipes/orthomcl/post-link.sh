#!/bin/bash

printf "To run OrthoMCL you need to copy the config file located in $PREFIX/share/orthomcl/orthomcl.config.template to your working directory as orthomcl.config.\ne.g. cp $PREFIX/share/orthomcl/orthomcl.config.template location_to_your_working_dir/orthomcl.config" >> "$PREFIX/.messages.txt"

exit 0
