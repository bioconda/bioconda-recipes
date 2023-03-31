#! /usr/bin/env python3

"""Extract the results from a single genome eval. Parses the file given by --log-file-name
for the F1 summary table, extracts the main information and outputs a .csv that can then
be imported elsewhere. Expects every eval to be in a seperate subfolder (like with
the 'trials' folder of nni)."""

import os
import h5py
import numpy as np
import argparse
from helixer.prediction.Metrics import ConfusionMatrix

def parse_total_acc(log_file):
    next(log_file)
    line = next(log_file)
    acc_overall = line.strip().split(' ')[-1]
    return acc_overall

def parse_f1_line(log_file):
    line_parts = next(log_file).strip().split('|')
    f1_idx = 5 if 'PRINT' in line_parts[0] else 4  # check if we have an nni log file
    return line_parts[f1_idx].strip()

parser = argparse.ArgumentParser()
parser.add_argument('-mf', '--main-folder', type=str, required=True)
parser.add_argument('-lfn', '--log-file-name', type=str, default='trial.log')
parser.add_argument('-i', '--ignore', action='append')
args = parser.parse_args()

header = ['genome', 'f1_ig', 'f1_utr', 'f1_exon', 'f1_intron', 'legacy_f1_cds', 'sub_genic',
          'f1_genic', 'genic_acc_overall', 'f1_no_phase', 'f1_phase_0', 'f1_phase_1',
          'f1_phase_2', 'phase_acc_overall', 'folder_name']
print(','.join(header))

for sub_folder in os.listdir(args.main_folder):
    sub_folder_path = os.path.join(args.main_folder, sub_folder)
    if not os.path.isdir(sub_folder_path):
        continue
    if args.ignore and sub_folder in args.ignore:
        continue
    log_file_path = os.path.join(sub_folder_path, args.log_file_name)
    if not os.path.exists(log_file_path) or not os.path.getsize(log_file_path) > 0:
        continue

    # get genome name
    parameters = eval(open(os.path.join(sub_folder_path, 'parameter.cfg')).read())
    path = parameters['parameters']['test_data']
    genome = path.split('/')[-2] # this may have to change depending on the folder structure

    # parse metric table
    log_file = open(log_file_path)
    results = []
    for line in log_file:
        # genic results table start
        if 'Precision' in line:
            next(log_file)  # skip line
            for i in range(7):
                results.append(parse_f1_line(log_file))
                if i == 3:
                    next(log_file)  # skip line
            results.append(parse_total_acc(log_file))

            # skip until next table
            for i in range(22):
                next(log_file)

            # phase results table start
            for i in range(4):
                results.append(parse_f1_line(log_file))
            results.append(parse_total_acc(log_file))

    # merge everything into one string
    str_rows = [genome] + results + [sub_folder]
    print(','.join(str_rows))
