# -*- coding: utf-8 -*-

import sys, yaml, pyaml


def main(argv=None):
	import argparse
	parser = argparse.ArgumentParser(
		description='Process and dump prettified YAML to stdout.')
	parser.add_argument('path', nargs='?', metavar='path',
		help='Path to YAML to read (default: use stdin).')
	opts = parser.parse_args(argv or sys.argv[1:])

	src = open(opts.path) if opts.path else sys.stdin
	try: data = yaml.safe_load(src)
	finally: src.close()

	pyaml.pprint(data)


if __name__ == '__main__': sys.exit(main())
