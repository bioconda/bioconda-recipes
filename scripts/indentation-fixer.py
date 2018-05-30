#!/usr/bin/env python
"""
Tries to make YAML indentation a consistent 2-spaces.

Identifies inconsistent indenation by tracking the indentation jump.
"""
import sys
import argparse
ap = argparse.ArgumentParser()
ap.add_argument('infile', help='Input file to work on')
ap.add_argument('--inplace', '-i', action='store_true', help='Edit in-place')
ap.add_argument('--detect', '-d', action='store_true', help='''If specified, do
                not do any edits but only print the filename to stdout if there
                was an indentation inconsistency detected''')
ap.add_argument('--show', '-s', action='store_true', help='''If specified, will
                also print out which line is problematic.''')
args = ap.parse_args()
data = open(args.infile).readlines()
results = []
level = 0
last_indent = 0
for line in data:
    current_indent = len(line) - len(line.strip(' '))
    diff = current_indent - last_indent
    was_indented = diff > 0
    was_dedented = (diff < 0)

    if was_indented:
        level += 1
    if was_dedented:
        level -= 1
    if current_indent == 0:
        level = 0

    correct_indentation = level * '  '
    detected_indentation = current_indent * ' '
    if correct_indentation != detected_indentation and args.detect:
        print(args.infile)
        break
    if args.show and (correct_indentation != detected_indentation):
        results.append(
            '# The following line has incorrect indentation '
            '({0} instead of {1} spaces):'
            .format(current_indent, level * 2)
        )
        results.append(line)

    if not args.detect:
        if len(line.strip()) == 0:
            results.append(line.strip())
        else:
            results.append(correct_indentation + line.strip())

    last_indent = current_indent

results = '\n'.join(results) + '\n'
if args.inplace:
    with open(args.infile, 'w') as fout:
        fout.write(results)
else:
    print(results, end='')
