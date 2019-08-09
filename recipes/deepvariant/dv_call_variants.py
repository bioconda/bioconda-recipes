#!/opt/anaconda1anaconda2anaconda3/bin/python
#
# Wrapper script for DeepVariant call_variants

BINARY_DIR="/opt/anaconda1anaconda2anaconda3/BINARYSUB"
MODEL_DIRS= {"wgs": "/opt/anaconda1anaconda2anaconda3/WGSMODELSUB",
             "wes": "/opt/anaconda1anaconda2anaconda3/WESMODELSUB"}

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
        print(subprocess.check_output([sys.executable, "%s/call_variants.zip" % real_dirname(BINARY_DIR), "--help"]))
        print()
        print("Wrapper arguments")
        parser.print_help()

def main():
    parser = argparse.ArgumentParser(description="DeepVariant call_variants wrapper", add_help=False)
    parser.add_argument("--cores", default=1)
    parser.add_argument("--outfile", required=True)
    parser.add_argument("--examples", required=True, help="Example directory from make_examples")
    parser.add_argument("--sample", required=True, help="Sample name")
    parser.add_argument("--model", default="wgs", choices=sorted(MODEL_DIRS.keys()),
                        help="DeepVariant trained model to use, defaults to wgs")
    parser.add_argument("-h", "--help", action=DVHelp)

    args = parser.parse_args()

    bin_dir = real_dirname(BINARY_DIR)
    model_dir = real_dirname(MODEL_DIRS[args.model])
    py_exe = sys.executable
    cmd = ("{py_exe} {bin_dir}/call_variants.zip "
           "--outfile {args.outfile} --examples {args.examples}/{args.sample}.tfrecord@{args.cores}.gz "
           "--checkpoint {model_dir}/model.ckpt")
    sys.exit(subprocess.call(cmd.format(**locals()), shell=True))

if __name__ == '__main__':
    main()
