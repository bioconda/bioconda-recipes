#! /usr/bin/env python3
import argparse
from pprint import pprint

from helixer.core.scripts import ExportParameterParser
from helixer.export.exporter import HelixerExportController, HelixerFastaToH5Controller


if __name__ == '__main__':
    pp = ExportParameterParser(config_file_path='config/fasta2h5_config.yaml')
    pp.io_group.add_argument('--fasta-path', type=str, default=None, required=True,
                             help='Fasta input file for direct FASTA to .h5 file conversion.')
    pp.io_group.add_argument('--species', type=str, default='', help='Species name. Will be added to the .h5 file.')
    pp.data_group.add_argument('--subsequence-length', type=int, default=21384,
                               help='Size of the chunks each genomic sequence gets cut into. (Default is 21384.)')
    args = pp.get_args()

    controller = HelixerFastaToH5Controller(args.fasta_path, args.h5_output_path)
    controller.export_fasta_to_h5(chunk_size=args.subsequence_length, compression=args.compression,
                                  multiprocess=not args.no_multiprocess, species=args.species)
