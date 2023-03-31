#! /usr/bin/env python3
"""
Extracts individual tables from text file with 1+ ASCII terminal tables and save to individual csv files.
"""

import re
import argparse
import os


def parse_table(splittable):
    out = []
    # splittable = table.split('\n')
    header = splittable[0]
    header = re.sub('\+|-', '', header)
    for line in splittable[1:]:
        if not line.startswith('+'):
            line = line.replace(' ', '')
            line = re.sub('\|', ',', line)
            line = re.sub('^,|,$', '', line)
            out.append(line)

    return header, '\n'.join(out)


def strip_logging_prefix(line):
    return re.sub('.*PRINT ', '', line)


def gen_tables(filein):
    out = []
    with open(filein) as f:
        for line in f:
            line = strip_logging_prefix(line)
            line = line.rstrip()
            if line.startswith('|') or line.startswith('+'):
                out.append(line)
            else:
                # ignore double non-table lines etc...
                if out:
                    yield out
                    out = []
    if out:
        yield out


def main(filein, dirout):
    seen = set()
    if not os.path.exists(dirout):
        os.mkdir(dirout)
    for table in gen_tables(filein):
        header, tab = parse_table(table)
        # force unique headers / output file names
        if header in seen:
            header += '_'
        seen.add(header)

        fileout = '{}/{}.csv'.format(dirout, header)
        with open(fileout, 'w') as f:
            f.write(tab)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--filein', required=True,
                        help='input scores file with ascii tables (e.g. stdout accs_genic_intergenic.py)')
    parser.add_argument('-o', '--outdir', required=True,
                        help='directory for output files (files themselves get table names)')
    args = parser.parse_args()
    main(args.filein, args.outdir)
