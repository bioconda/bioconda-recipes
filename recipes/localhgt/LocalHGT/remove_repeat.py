#!/usr/bin/env python3

"""
some breakpoint pairs are too close, we only keep a 
representive one from the nearby bkps. 
"""

import sys

infile = sys.argv[1]
outfile = sys.argv[2]
cutoff = 50

def main():
    inf = open(infile)
    outf = open(outfile, 'w')
    record = []
    for line in inf:
        if line[0] == "#":
            print (line, end='', file = outf)
            continue
        flag = True
        array = line.split(",")
        if array[0] != "from_ref":
            # print (array)
            array[1] = int(array[1])
            array[5] = int(array[5])       
            for rec in record:
                if array[0] == rec[0] and abs(array[1] - rec[1])<cutoff \
                and array[4] == rec[4] and abs(array[5] - rec[5])<cutoff:
                    flag = False
                    break
                elif array[4] == rec[0] and abs(array[5] - rec[1])<cutoff \
                and array[0] == rec[4] and abs(array[1] - rec[5])<cutoff:
                    flag = False
                    break
        if flag:
            record.append(array[:6])
            print (line, end='', file = outf)

    inf.close()
    outf.close()

main()