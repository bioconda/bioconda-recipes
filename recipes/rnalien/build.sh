#!/bin/bash
if [hash stack &>hash.out]; then
	wget -qO- https://get.haskellstack.org/ | sh
else
	echo "Stack available"
fi
stack setup
stack build
