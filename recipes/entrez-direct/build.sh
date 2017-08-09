#!/bin/bash

sh "setup.sh"
mv edirect.pl efetch epost efilter eproxy einfo econtact elink espell enotify esummary entrez-phrase-search xtract "$PREFIX/bin/"
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"

