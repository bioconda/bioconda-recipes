#!/usr/bin/env python
"""
Bumps the build number for a recipe
"""
import argparse
ap = argparse.ArgumentParser()
ap.add_argument('infile')
ap.add_argument('--inplace', action='store_true')
args = ap.parse_args()

lines = open(args.infile).readlines()

res = []
for line in lines:
    line = line.rstrip('\n')
    if 'number:' in line:
        toks = line.split(': ')
        if len(toks) > 1:
            num = toks[-1]
            if num.isdigit():
                bumped = int(num) + 1
                line = '{0}: {1}'.format(toks[0], bumped)
    res.append(line)

res = '\n'.join(res) + '\n'

if args.inplace:
    with open(args.infile, 'w') as fout:
        fout.write(res)

else:
    print(res, end='')
