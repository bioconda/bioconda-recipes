import os
import yaml
import argparse
from pprint import pprint
from termcolor import colored
from abc import ABC, abstractmethod


class ParameterParser(ABC):
    """Bundles code that parses script parameters from the command line and a config file."""

    def __init__(self, config_file_path=''):
        # Do NOT use default values in the argparse configuration but specify them seperately later
        # (except for the config file itself)
        # This is needed to give the cli parameters precedent over the ones in the config file
        self.parser = argparse.ArgumentParser(argument_default=argparse.SUPPRESS)
        self.io_group = self.parser.add_argument_group("Data input and output")
        self.io_group.add_argument('--config-path', type=str, default=config_file_path,
                              help='Config in form of a YAML file with lower priority than parameters given on the command line.')

        self.data_group = self.parser.add_argument_group("Data generation parameters")
        self.data_group.add_argument('--compression', type=str, choices=['gzip', 'lzf'],
                                     help='Compression algorithm used for the intermediate .h5 output '
                                          'files with a fixed compression level of 4. '
                                          '(Default is "gzip", which is much slower than "lzf".)')
        self.data_group.add_argument('--no-multiprocess', action='store_true',
                                     help='Whether to not parallize the numerification of large sequences. Uses half the memory '
                                          'but can be much slower when many CPU cores can be utilized.')

        # Default values have to be specified - and potentially added - here
        self.defaults = {'compression': 'gzip', 'no_multiprocess': False}

    @abstractmethod
    def check_args(self, args):
        pass

    def load_and_merge_parameters(self, args):
        config = {}
        if args.config_path and os.path.isfile(args.config_path):
            with open(args.config_path, 'r') as f:
                try:
                    yaml_config = yaml.safe_load(f)
                    if yaml_config:
                        # an empty yaml file will result in a None object
                        config = yaml_config
                        # check if the types in the config file align with the types given in the defaults
                        for key, value in config.items():
                            assert key in self.defaults, f'Parameter "{key}" from the config file is unknown'
                            msg = f'Type of config parameter "{key}" must be {type(self.defaults[key]).__name__}'
                            assert type(value) == type(self.defaults[key]), msg

                except yaml.YAMLError as e:
                    print(f'An error occured during parsing of the YAML config file: {e} '
                          '\nNot using the config file.')
        else:
            print(f'No config file found\n')

        # merge the config and cli parameters with the cli parameters having priority
        # there are no type checks being done for config parameters
        config = {**self.defaults, **config, **vars(args)}
        return argparse.Namespace(**config)

    def get_args(self):
        args = self.parser.parse_args()
        args = self.load_and_merge_parameters(args)
        self.check_args(args)

        print(colored('Helixer.py config: ', 'yellow'))
        pprint(vars(args))
        print()
        return args


class ExportParameterParser(ParameterParser):
    def __init__(self, config_file_path=''):
        super().__init__(config_file_path)
        self.io_group.add_argument('--h5-output-path', type=str, required=True,
                                   help='HDF5 output file for the encoded data. Must end with ".h5"')

    def check_args(self, args):
        assert args.h5_output_path.endswith('.h5'), '--output-path must end with ".h5"'

