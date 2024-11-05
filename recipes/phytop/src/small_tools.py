
'''
2016-4-20	remove_short_seqs		ZRG	add
2016-4-20	fq_switch		ZRG	add
2016-4-20	mkdirs		ZRG	add
2016-4-20	is_complete_cds		ZRG	add
2016-4-20	time_convert		ZRG	add
2016-4-20	is_gz		ZRG	add
2016-4-22	table2xls	ZRG add
2016-4-22	combine_tabs_2xls	ZRG add
2016-4-25	open_file	ZRG add
2016-6-8	run_time	ZRG
2016-8-28	backup_file	ZRG
2016-9-21	count_record ZRG
'''

import sys
import os
import gzip
import re
import time
import shutil
import subprocess
import collections
import pickle
from Bio import SeqIO
from .RunCmdsMP import logger

ISOTIMEFORMAT='%Y-%m-%d %X'

def lazy_decode(line):
	try: line = line.decode()
	except AttributeError: pass
	return line

def mk_ckp(ckgfile, *data, log=True):
	with open(ckgfile, 'wb') as f:
		for dat in data:
			pickle.dump(dat, f)
	if log:
		logger.info('New check point file: `{}`'.format(ckgfile))
def check_ckp(ckgfile, log=True, overwrite=False):
	if os.path.exists(ckgfile):
		if overwrite:
			if log:
				logger.info('Check point file: `{}` exists; but overwrite'.format(ckgfile))
			return False
		if log:
			logger.info('Check point file: `{}` exists; skip this step'.format(ckgfile))

		if os.path.getsize(ckgfile) == 0:
			return True
		data = []
		with open(ckgfile, 'rb') as f:
			while True:
				try: dat = pickle.load(f)
				except EOFError: break
				data += [dat]
		return data
	return False
def tr_numeric(val):
	try: return int(val)
	except:
		try: return float(val)
		except: return val
def parse_key_opts(args):
	d = {}
	pops = []
	for i, arg in enumerate(args):
		kv = arg.split('=', 1)
		if len(kv) != 2:
			continue
		pops += [i]
		key, val = kv
		val = tr_numeric(val)
		d[key] = val
	for i in sorted(pops, reverse=1):
		args.pop(i)
	return d
def parse_kargs(*args):
	return parse_key_opts(*args)

def sorted_version(lst, **kargs):
	return sorted(lst, key=lambda x: get_version(x), **kargs)
def get_version(value):
	try:
		v, d = re.compile(r'^(\S+?)(\d+)$').match(value).groups()
		d = int(d)
	except AttributeError:
		v, d = value, 0
	return d

def get_hex_colors(n):
	import matplotlib.pyplot as plt
	plt.switch_backend('agg')
	import matplotlib.colors as colors
	import matplotlib.cm as cmx
	values = list(range(n))
	jet = cm = plt.get_cmap('jet')
	cNorm  = colors.Normalize(vmin=0, vmax=values[-1])
	scalarMap = cmx.ScalarMappable(norm=cNorm, cmap=jet)
	colorVal = [scalarMap.to_rgba(v) for v in values]
	return [colors.to_hex(v) for v in colorVal]
def getHtml(url):
		import urllib.request, urllib.error, urllib.parse,socket
		socket.setdefaulttimeout(5)
		socket.setdefaulttimeout(5)
		try:
				page = urllib.request.urlopen(url)
				html = page.read()
				return html
		except socket.timeout:
				print('time out, trying again!')
				time.sleep(5)
				return getHtml(url)
		except urllib.error.HTTPError as e:
				if e.code == 404:
						return e.code
				print('HTTPError code: ', e.code, ', trying again!')
				time.sleep(5)
				return getHtml(url)
		except urllib.error.URLError as e:
				print('URLError reason',e.reason,', trying again!')
				time.sleep(5)
				return getHtml(url)
		except:
				'UnknownError, trying again!'
				time.sleep(5)
				return getHtml(url)

def remove_short_seqs(inSeq, outSeq, minLen=200, format='fasta'):
	'''Remove sequences shorter than the cutoff.'''
	f = open(outSeq, 'w')
	for record in SeqIO.parse(inSeq, format):
		if len(record.seq) >= minLen:
			SeqIO.write(record, f, format)
		else:
			continue
	f.close()

def fq_switch(inFq):
	if os.path.exists(inFq):
		return inFq
	elif os.path.exists(inFq+'.gz'):
		return inFq+'.gz'
	else:
		raise IOError('File %s is NOT exists' % inFq)

def mkdirs(*dirs):
	'''compatible while multiprocessing with pp module'''
	for DIR in dirs:
		if os.path.exists(DIR):
			pass
		else:
			try: os.makedirs(DIR)
			except OSError: pass
def rmdirs(*dirs):
	for DIR in dirs:
		if os.path.exists(DIR):
			try: shutil.rmtree(DIR)
			except OSError: os.remove(DIR)
		else:
			pass
def cpdir(from_dir, to_dir):
	shutil.copytree(from_dir, to_dir)

def test_f(xfile):	#"test -f"
	return os.path.exists(xfile)

def test_s(xfile):	#"test -s"
	return os.path.exists(xfile) and os.path.getsize(xfile)>0
def test_r(xfile): # readable
	try: 
		f = open(xfile)
		f.close()
		return True
	except:
		return False
def is_complete_cds(Seq, translate_table=1):
	'''A Bio.Seq object (CDS) is complete (both start and end codons present)?'''
	try:
		pro_seq = Seq.translate(table=translate_table, to_stop=True, cds=True)
		return True
	except CodonTable.TranslationError:
		return False

def time_convert(number):
	'''Simply convert format of date.
usage:
import time
ISOTIMEFORMAT='%Y-%m-%d %X'
start = time.time()
end = time.time()
time_convert(end-start)'''
	hour = int(number/3600)
	min = int((number-3600*hour)/60)
	sec = number - 3600*hour - 60*min
	return '%sh%sm%0.2fs' %(hour,min,sec)

def is_gz(input_file):
	'''Is a gzip file?'''
	if os.path.splitext(input_file)[-1] == '.gz':
		return True
	else:
		return False

def table2xls(table_file, xls_file = None):
	# init
	import xlwt
	if not xls_file:
		xls_file = table_file + '.xls'

	wb = xlwt.Workbook()
	ws1= wb.add_sheet('Sheet1')

	i = 0
	for line in open(table_file,'r'):
		temp = line.rstrip().split('\t')
		j = 0
		for value in temp:
			# try: value = value.strip().decode('gbk')
			# except UnicodeDecodeError: value = 'NULL'
			ws1.write(i,j,value)
			j += 1
		i += 1
	wb.save(xls_file)

def combine_tabs_2xls(table_files, xls_file = None, sheets = None):
	# init
	if not xls_file:
		xls_file = table_file[0] + '.xls'
	if not sheets:
		sheets = table_file

	wb = xlwt.Workbook()
	for table_file, sheet in zip(table_files, sheets):
		ws1= wb.add_sheet(sheet)
		i = 0
		for line in open(table_file,'r'):
			temp = line.rstrip().split('\t')
			j = 0
			for value in temp:
				ws1.write(i,j,value)
				j += 1
			i += 1
	wb.save(xls_file)
def get_suffix(infile):
	return os.path.splitext(infile)[-1]
def open_file(infile, mode='r'):
	suffix = os.path.splitext(infile)[-1]
	if suffix == '.gz':
		import gzip
		return gzip.open(infile, mode)
	elif suffix == '.bz2':
		import bz2
		return bz2.BZ2File(infile, mode)
	else:
		return open(infile, mode)
def lazy_open(infile):
	'''return a iterator of a object (file or iterable instance)'''
	if isinstance(infile, str) and  os.path.isfile(infile):
		return open_file(infile)
	elif isinstance(infile, collections.abc.Iterable):
		# such as list, tuple
		return iter(infile)
	else:
		raise TypeError('{} is neither a file nor a iterable instance'.format(infile))

def run_time(func):
	def _run_time():
		start = time.time()
		logFile = 'main.logfile'
		f = open(logFile,'a')
		print('Start at %s ...' % time.strftime(ISOTIMEFORMAT, time.localtime()), file=f)
		print('Runing commands:', file=f)

		print('  %s' % func(), file=f)

		print('End   at %s .' % time.strftime(ISOTIMEFORMAT, time.localtime()), file=f)
		end = time.time()
		print('Total Time Used: %s\n' % time_convert(end-start), file=f)
		f.close()
	return _run_time

class pypsl:
	def __init__(self, inPsl):
		self.input = inPsl
	def read(self):
		title = ''
		for line in open(self.input, 'r'):
			if re.compile(r'\d+').match(line):
				self.match = int(temp[0])
				self.mis_match = int(temp[1])
				self.rep_match = int(temp[2])
				self.ambigs = int(temp[3])
				self.q_gap_count = int(temp[4])
				self.q_gap_bases = int(temp[5])
				self.t_gap_count = int(temp[6])
				self.t_gap_bases = int(temp[7])
				self.strand = temp[8]
				self.q_name = temp[9]
				self.q_size = int(temp[10])
				self.q_start = int(temp[11])
				self.q_end = int(temp[12])
				self.t_name = temp[13]
				self.t_size = int(temp[14])
				self.t_start = int(temp[15])
				self.t_end = int(temp[16])
				self.block_count = int(temp[17])
				self.block_sizes = temp[18].rstrip(',').split(',')
				self.q_starts = temp[19].rstrip(',').split(',')
				self.t_starts = temp[20].rstrip(',').split(',')
				self.block_sizes = [int(value) for value in self.block_sizes]
				self.q_starts = [int(value) for value in self.q_starts]
				self.t_starts = [int(value) for value in self.q_starts]
def bk_not_overwrite(input_file_bk):
	if os.path.exists(input_file_bk):
		return bk_not_overwrite(input_file_bk + '.1')
	else:
		return input_file_bk

def backup_file(input_file):
	input_file_bk = input_file + '.bk'
	input_file_bk = bk_not_overwrite(input_file_bk)
	shutil.move(input_file, input_file_bk)
	return (input_file_bk, input_file)

#@run_time
def count_record(inFile, format):
	if is_gz(inFile):
		cat = 'zcat'
	else:
		cat = 'cat'
	if format in set(['fastq', 'fq']):
		cmd = '%s "%s"| grep -c "^+$"' % (cat, inFile,)
	elif format in set(['fasta', 'fa', 'fna', 'faa', 'fas']):
		cmd = '%s "%s"| grep -c "^>"' % (cat, inFile,)
	elif format in set(['text', 'txt']):
		cmd = '%s "%s"| wc -l' % (cat, inFile,)
	job = subprocess.Popen(cmd,stdout=subprocess.PIPE,\
					stderr=subprocess.PIPE,shell=True)
	output = job.communicate()
	try: return int(output[0])
	except ValueError: print(output)

def flattern(nested):
	try:
		for sublist in nested:
			for element in flattern(sublist):
				yield element
	except TypeError:
		yield nested
def flatten(*args):
	return flattern2(*args)
def flattern2(nested):
	for sublist in nested:
		for element in sublist:
			yield element
