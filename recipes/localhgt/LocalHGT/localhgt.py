#!/usr/bin/env python3

import argparse
import textwrap
import subprocess
from infer_HGT_breakpoint import detect_breakpoint
from infer_HGT_event import detect_event
import sys
import os

def script1_function(arg1, arg2):
    # Implement the logic for script1_function
    print("Running script1_function with arguments:", arg1, arg2)

def script2_function(arg):
    # Implement the logic for script2_function
    print("Running script2_function with argument:", arg)

def main():
    # Create the top-level parser
    parser = argparse.ArgumentParser(description='LocalHGT: an ultrafast HGT detection method from large microbial communities',      
    epilog=textwrap.dedent('''\
    Note: To use LocalHGT, first detect HGT breakpoints with 'localhgt bkp'.
        After that, detect HGT events based on the detected HGT breakpoints with 'localhgt event'.
        Detailed documentation can be found at https://github.com/deepomicslab/LocalHGT
    '''))

    # Create subparsers for each function (script)
    subparsers = parser.add_subparsers(title='Command', dest='function')

    # Create a parser for script1_function
    # parser_script1 = subparsers.add_parser('script1', help='Script 1 help')
    # parser_script1.add_argument('arg1', help='Argument 1 for script1')
    # parser_script1.add_argument('arg2', help='Argument 2 for script1')

    parser_script1 = subparsers.add_parser('bkp', help='Detect HGT breakpoints from metagenomic sequencing data.', \
    description='''Detect HGT breakpoints from metagenomic sequencing data.  Example: localhgt bkp -r reference.fa --fq1 test.1.fq --fq2 test.2.fq -s test -o outdir
''',\
    add_help=False, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    # parser_script1 = argparse.ArgumentParser(description="Detect HGT breakpoints from metagenomics sequencing data.", add_help=False, \
    # usage="python %(prog)s -h", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    required = parser_script1.add_argument_group("required arguments")
    optional = parser_script1.add_argument_group("optional arguments")
    required.add_argument("-r", type=str, help="<str> Uncompressed reference file, which contains all the representative references of concerned bacteria.", metavar="\b")
    required.add_argument("--fq1", type=str, help="<str> Uncompressed fastq 1 file.", metavar="\b")
    required.add_argument("--fq2", type=str, help="<str> Uncompressed fastq 2 file.", metavar="\b")
    required.add_argument("-s", type=str, default="sample", help="<str> Sample name.", metavar="\b")
    required.add_argument("-o", type=str, default="./", help="<str> Output folder.", metavar="\b")

    optional.add_argument("-k", type=int, default=32, help="<int> kmer length.", metavar="\b")
    optional.add_argument("-t", type=int, default=10, help="<int> number of threads.", metavar="\b")
    optional.add_argument("-e", type=int, default=3, help="<int> number of hash functions (1-9).", metavar="\b")
    optional.add_argument("-a", type=int, default=1, help="<0/1> 1 indicates retain reads with XA tag.", metavar="\b")
    optional.add_argument("-q", type=int, default=20, help="<int> minimum read mapping quality in BAM.", metavar="\b")
    optional.add_argument("--seed", type=int, default=1, help="<int> seed to initialize a pseudorandom number generator.", metavar="\b")
    optional.add_argument("--use_kmer", type=int, default=1, help="<1/0> 1 means using kmer to extract HGT-related segment, 0 means using original reference.", metavar="\b")
    optional.add_argument("--hit_ratio", type=float, default=0.1, help="<float> minimum fuzzy kmer match ratio to extract a reference fragment.", metavar="\b")
    optional.add_argument("--match_ratio", type=float, default=0.08, help="<float> minimum exact kmer match ratio to extract a reference fragment.", metavar="\b")
    optional.add_argument("--max_peak", type=int, default=300000000, help="<int> maximum candidate BKP count.", metavar="\b")
    optional.add_argument("--sample", type=float, default=2000000000, help="<float> down-sample in kmer counting: (0-1) means sampling proportion, (>1) means sampling base count (bp).", metavar="\b")
    optional.add_argument("--refine_fq", type=int, default=0, help="<0/1> 1 indicates refine the input fastq file using fastp (recommended).", metavar="\b")
    optional.add_argument("--read_info", type=int, default=1, help="<0/1> 1 indicates including reads info, 0 indicates not (just for evaluation).", metavar="\b")
    optional.add_argument("-h", "--help", action="help")



    # Create a parser for script2_function
    parser_script2 = subparsers.add_parser('event', help='Infer complete HGT events based on detected HGT breakpoints.', \
    description='''Infer complete HGT events based on detected HGT breakpoints.  Example: localhgt event -r reference.fa -b outdir -f test_event.csv''',\
    add_help=False, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    required2 = parser_script2.add_argument_group("required arguments")
    optional2 = parser_script2.add_argument_group("optional arguments")
    required2.add_argument("-r", type=str, help="<str> <str> Uncompressed reference file, which contains all the representative references of concerned bacteria.", metavar="\b")
    required2.add_argument("-b", type=str, help="<str> the folder stores all the breakpoint results from all samples, i.e., a folder stores all the *acc.csv files generated by 'localhgt bkp'", metavar="\b")
    required2.add_argument("-f", type=str, default="complete_HGT_event.csv", help="<str> Output file to save all inferred HGT events.", metavar="\b")
    optional2.add_argument("-n", type=int, default=2, help="<int> minimum supporting split read number", metavar="\b")
    optional2.add_argument("-m", type=int, default=500, help="<int> minimum transfer sequence length", metavar="\b")
    optional2.add_argument("-h", "--help", action="help")

    # Parse the command-line arguments
    args = parser.parse_args()

    # Execute the selected function (script) with its respective parameters
    if args.function == 'bkp':
        # script1_function(args.arg1, args.arg2)
        if args.r == None:
            os.system(f"python {sys.argv[0]} bkp -h")
        else:
            detect_breakpoint(args)
    elif args.function == 'event':
        # script2_function(args.arg)
        if args.r == None:
            os.system(f"python {sys.argv[0]} event -h")
        else:
            detect_event(args)
    else:
        # print('Invalid function choice')
        os.system(f"python {sys.argv[0]} -h")

if __name__ == '__main__':
    main()
