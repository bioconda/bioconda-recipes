#!/opt/anaconda1anaconda2anaconda3/bin/python
#
# Wrapper script for DeepVariant postprocess_variants

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
        cmd = ("export LD_LIBRARY_PATH={lib_path}:\"$LD_LIBRARY_PATH\" && "
               "{py_exe} {bin_dir}/postprocess_variants.zip --help")
        try:
            subprocess.check_output(cmd.format(**locals()), shell=True)
        except subprocess.CalledProcessError as e:
            print(e.stdout.decode('UTF-8'))
        print()
        print("Wrapper arguments")
        parser.print_help()

def main():
    parser = argparse.ArgumentParser(description="DeepVariant postprocess_variants wrapper", add_help=False)
    parser.add_argument("--ref", required=True, help="Reference genome")
    parser.add_argument("--infile", required=True, help="Input tfrecord file from call_variants")
    parser.add_argument("--outfile", required=True)
    parser.add_argument("--gvcf_infile", help="Input gVCF tfrecord file from make_examples, formatted as {{gvcf}}/{{sample}}.gvcf.tfrecord@{{cores}}.gz, with arguments as supplied to make_examples.")
    parser.add_argument("--gvcf_outfile", help="gVCF output file")
    parser.add_argument("-h", "--help", action=DVHelp)

    args = parser.parse_args()

    bin_dir = real_dirname(BINARY_DIR)
    conda_path = os.path.dirname(os.path.realpath(sys.executable))
    lib_path = os.path.join(os.path.dirname(conda_path), "lib")
    py_exe = sys.executable
    gvcf = ("--nonvariant_site_tfrecord_path {args.gvcf_infile} "
            "--gvcf_outfile {args.gvcf_outfile} ").format(**locals()) if args.gvcf_infile and args.gvcf_outfile else ""
    cmd = ("export LD_LIBRARY_PATH={lib_path}:\"$LD_LIBRARY_PATH\" && "
           "{py_exe} {bin_dir}/postprocess_variants.zip "
           "{gvcf} "
           "--ref {args.ref} --infile {args.infile} --outfile {args.outfile}")
    sys.exit(subprocess.call(cmd.format(**locals()), shell=True))

if __name__ == '__main__':
    main()
