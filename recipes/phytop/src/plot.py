import sys,os
import copy
import argparse
import shutil
import json
import math
import multiprocessing
from collections import OrderedDict, Counter
from .Astral import AstralTree
from .RunCmdsMP import logger
from .small_tools import mkdirs
from .__version__ import version


bindir = os.path.dirname(os.path.realpath(__file__))

def makeArgparse():
	parser = argparse.ArgumentParser( 
		formatter_class=argparse.RawDescriptionHelpFormatter,
		description='Visualizing ILS/IH signals on species tree from ASTRAL.',
		)
	# input
	group_in = parser.add_argument_group('Input', '')
	group_in.add_argument("astral", metavar='NEWICK',
					help="Species tree output by ASTRAL (using option `-u 2` for C++ versions and `-t 2` for JAVA versions) [required]")
	group_in.add_argument('-alter', default=None, type=str, dest='alter',  metavar='NEWICK',
                    help="Show the tree (e.g. a timetree) instead of the ASTRAL tree (their topologies MUST be identical) [default=%(default)s]")
	group_in.add_argument('-g', '-genetrees', default=None, type=str, dest='genetrees',  metavar='NEWICK',
                    help="gene trees for branch lengths in TEST mode [default=%(default)s]")

	# set tree
	group_tree = parser.add_argument_group('Tree options', '')
	group_tree.add_argument('-align', action="store_true", default=False,
                    help="Align tips [default=%(default)s]")
	group_tree.add_argument('-cp', '-concordance_percent', action="store_true", default=False,
                    help="Show gene-species trees concordance percent at inner nodes instead of PP [default=%(default)s]")
	group_tree.add_argument('-branch_size', default=48, type=float,
                    help="Font size of text in branch [default=%(default)s]")
	group_tree.add_argument('-leaf_size', default=60, type=float,
                    help="Font size of leaf name [default=%(default)s]")

	# set barcharts
	group_bar = parser.add_argument_group('Barcharts/Piecharts options', '')
	group_bar.add_argument('-sort', action="store_true", default=False, 
                    help="Sort q1, q2 and q3, which will miss the directionality [default=%(default)s]")
	group_bar.add_argument('-notext', action="store_true", default=False, 
                    help="Do not draw text on the barcharts [default=%(default)s]")
	group_bar.add_argument('-figsize', default=3, type=float, 
					help="Figure size of barcharts [default=%(default)s]")
	group_bar.add_argument('-fontsize', default=13, type=float,
                    help="Font size of text in barcharts [default=%(default)s]")
	group_bar.add_argument('-figfmt', default='png', type=str,
                    help="Figure format of barcharts in tmpdir [default=%(default)s]")
	group_bar.add_argument('-colors', default=None, type=str,
                    help="Set colors for barcharts/piecharts [default=%(default)s]")
	group_bar.add_argument('-polytomy_test', action="store_true", default=False,
                    help="Test for polytomies [default=%(default)s]")

	# pie
#	group_pie = parser.add_argument_group('Piecharts options', '')
	group_bar.add_argument('-pie', '-pie_chart', action="store_true", default=False, dest='pie',
                    help="Use piechart instead of barchart [default=%(default)s]")
	group_bar.add_argument('-pie_size', default=30, type=float, 
                    help="Size of Piecharts [default=%(default)s]")
#	group_pie.add_argument('-pie_fold', default=6, type=float,
#                    help="Fold of font size between Barcharts and Piecharts [default=%(default)s]")

	# bl
	group_bl = parser.add_argument_group('Branch length (BL) options', '')	
	group_bl.add_argument('-bl', action="store_true", default=False, dest='add_bl',
					help="Branch lengths to check [default=%(default)s]")

	# test
	group_test = parser.add_argument_group('Test mode', '')
	group_test.add_argument('-test', default=None, type=str,  nargs='*', dest='test_clades',  metavar='TAXON/FILE',
                    help="Test four-taxon (the first is outgroup and others are sampled for three ingroups) [default=%(default)s]")
	group_test.add_argument('-astral_bin', default='astral-pro', type=str,  metavar='STR',
                    help="ASTRAL command ('astral-pro', 'astral-hybrid', ...) [default=%(default)s]")
	group_test.add_argument('-outgroup', default=None, type=str, metavar='STR',
                    help="Outgroup [default: the first of `-test`]")
					
	# clade operateion
	group_clade = parser.add_argument_group('Clade operateion', '')
	group_clade.add_argument('-clades', default=None, type=str,  dest='clades',  metavar='FILE',
                    help="Difinition of clades [default=%(default)s]")

	group_clade.add_argument('-collapse', default=None, type=str, nargs='*', dest='collapsed',  metavar='TAXON/FILE',
					help="Collapse clades [default=%(default)s]")
	group_clade.add_argument('-onshow', default=None, type=str, nargs='+', dest='onshow',  metavar='TAXON/FILE',
                    help="Only show charts on these inner nodes [default=%(default)s]")
	group_clade.add_argument('-noshow', default=None, type=str, nargs='+', dest='noshow',  metavar='TAXON/FILE',
                    help="Don't show charts on these inner nodes [default=%(default)s]")
	group_clade.add_argument('-subset', default=None, type=str, nargs='+', dest='subset',  metavar='TAXON/FILE',
                    help="Show a subset clade with their MCRA [default=%(default)s]")

	# output
	group_out = parser.add_argument_group('Output', '')
	group_out.add_argument('-pre', '-prefix', default=None, type=str, dest='prefix', metavar='STR',
					help="Prefix for output [default=%(default)s]")
	group_out.add_argument('-tmp', '-tmpdir', default='tmp', dest='tmpdir', type=str, metavar='DIR',
					help="Temporary directory [default=%(default)s]")


	args = parser.parse_args()
	return args

def plot(**kargs):
	mkdirs(kargs['tmpdir'])
	AstralTree(**kargs).run()
def main():
	args = makeArgparse()
	logger.info('Command: {}'.format(' '.join(sys.argv)))
	logger.info('Version: {}'.format(version))
	logger.info('Arguments: {}'.format(args.__dict__))
	pipeline = plot(**args.__dict__)

if __name__ == '__main__':
	main()
