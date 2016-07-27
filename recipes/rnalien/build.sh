#!/bin/bash
if ! [ -x "$(command -v stack)" ]; then
	curl -sSL https://get.haskellstack.org/ | sh
        export PATH=/usr/local/bin/:$PATH
else
	echo "Stack available"
fi
export PATH=/root/.local/bin:/usr/local/bin/:$PATH
stack setup
stack build
