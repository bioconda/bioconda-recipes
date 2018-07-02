#!/usr/bin/env python3
from subprocess import check_output, STDOUT, CalledProcessError

# ===============================================================
# This testing module is written this way because centroid_homfold
#  returns exit code of 1 on the -h command


def verify_centroid(prog):
    msgversion = '{} is not installed'.format(prog)
    msgpath = '{} could not be located (not in PATH).'.format(prog)
    # double try because help returns exit status 1
    try:
        try:
            a = check_output(
                [prog, '-h'],
                stderr=STDOUT
            )
        except CalledProcessError as e:
            a = e.output

        a = a.decode()
        b = a.split()
        if b[0] == 'CentroidHomfold' or b[0] == 'CentroidFold' or b[0] == 'CentroidAlifold':
            return True
        else:
            print(msgversion)
            return False
    except FileNotFoundError:
        print(msgpath)
        return False

for i in ['centroid_homfold', 'centroid_fold', 'centroid_alifold']:
    if not verify_centroid(i):
        exit(1)
else:
    exit(0)
