#!/bin/bash
if ! [ -x "$(command -v stack)" ]; then
	curl -sSL https://get.haskellstack.org/ | sh
else
	echo "Stack available"
fi
stack setup
stack build
