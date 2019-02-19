#!/opt/anaconda1anaconda2anaconda3/bin/python
#
# Wrapper script for DeepVariant make_examples

BINARY_DIR="/opt/anaconda1anaconda2anaconda3/BINARYSUB"

import argparse
import os
import subprocess
import sys

def real_dirname(path):
    """Return the symlink-resolved, canonicalized directory-portion of path."""
    return os.path.realpath(path)

class DVHelp(argparse._HelpAction):
    def __call__(self, parser, namespace, values, option_string=None):
        print("Baseline DeepVariant arguments")
        bin_dir = real_dirname(BINARY_DIR)
        conda_path = os.path.dirname(os.path.realpath(sys.executable))
        lib_path = os.path.join(os.path.dirname(conda_path), "lib")
        py_exe = sys.executable
        cmd = ("export LD_LIBRARY_PATH={lib_path}:$LD_LIBRARY_PATH && "
               "{py_exe} {bin_dir}/make_examples.zip --help")
        print(subprocess.check_output(cmd.format(**locals()), shell=True))
        print()
        print("Wrapper arguments")
        parser.print_help()

def main():
    parser = argparse.ArgumentParser(description="DeepVariant make_examples wrapper", add_help=False)
    parser.add_argument("--cores", default=1)
    parser.add_argument("--sample", required=True, help="Sample name")
    parser.add_argument("--ref", required=True, help="Reference genome")
    parser.add_argument("--reads", required=True, help="Input BAM file")
    parser.add_argument("--regions", required=True, help="Genomic region to process")
    parser.add_argument("--logdir", required=True)
    parser.add_argument("--examples", required=True, help="Output directory for examples")
    parser.add_argument("-h", "--help", action=DVHelp)

    args = parser.parse_args()

    bin_dir = real_dirname(BINARY_DIR)
    conda_path = os.path.dirname(os.path.realpath(sys.executable))
    lib_path = os.path.join(os.path.dirname(conda_path), "lib")
    py_exe = sys.executable
    split_inputs = " ".join(str(x) for x in range(0, int(args.cores)))
    cmd = ("export PATH={conda_path}:$PATH && export LD_LIBRARY_PATH={lib_path}:$LD_LIBRARY_PATH && "
           "parallel --eta --halt 2 --joblog {args.logdir}/log --res {args.logdir} "
           "{py_exe} {bin_dir}/make_examples.zip "
           "--mode calling --ref {args.ref} --reads {args.reads} --regions {args.regions} "
           "--examples {args.examples}/{args.sample}.tfrecord@{args.cores}.gz --task {{}} "
           "::: {split_inputs}")
    sys.exit(subprocess.call(cmd.format(**locals()), shell=True))

if __name__ == '__main__':
    main()
