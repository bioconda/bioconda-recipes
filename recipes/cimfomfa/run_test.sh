#!/bin/bash

if [[ -x "$PREFIX/lib/libtingea.la" ]]; then
	:
else
	exit 1
fi

if [[ -f "$PREFIX/lib/libtingea.a" ]]; then
        :
else
        exit 1
fi

if [[ -d "$PREFIX/include/tingea" ]]; then
	:
else
        exit 1
fi
