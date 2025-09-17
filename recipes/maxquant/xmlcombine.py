#!/usr/bin/env python

# Script to extend modifications/enzymes/databases/crosslinks/annotation_config.xml
# with custom xml files in the recipe dir

import sys
from xml.etree.ElementTree import parse, tostring


def combine(files):
	first = None
	for file in files:
		xml_data = parse(file).getroot()
		if first is None:
			first = xml_data
		else:
			first.extend(xml_data)
	if first is not None:
		print(tostring(first, encoding="unicode"))


if __name__ == "__main__":
	combine(sys.argv[1:])
