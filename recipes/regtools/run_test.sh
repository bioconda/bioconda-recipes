#!/usr/bin/env bash
#help output is to stderr
HELP="$(regtools --help 2>&1 >/dev/null)"
VERSION="$(regtools --version 2>&1 >/dev/null)"
EXPECTED='
Program:	regtools
Version:	0.2.0
Usage:		regtools <command> [options]
Command:	junctions		Tools that operate on feature junctions.
					(eg. exon-exon junctions from RNA-seq.)
		cis-ase			Tools related to allele specific expression in cis.
		cis-splice-effects	Tools related to splicing effects of variants.
		variants		Tools that operate on variants.'
if [ "$HELP" = "$EXPECTED" ] && [ "$VERSION" = "$EXPECTED" ]
then
  exit 0
fi
exit 1
