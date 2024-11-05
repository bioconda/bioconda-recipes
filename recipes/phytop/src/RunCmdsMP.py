#!/usr/bin/env python
#coding utf-8
'''RUN system CoMmanDS in Multi-Processing'''
import sys
import os, stat
import shutil
from io import IOBase
#import psutil
import subprocess
from optparse import OptionParser
import logging
logging.basicConfig(level = logging.INFO,
			format='%(asctime)s [%(levelname)s] %(message)s', 
			datefmt='%y-%m-%d %H:%M:%S',)
logger = LOGGER = logging.getLogger(__name__)

import multiprocessing
try:
	import pp
except ImportError as e:
	pass
	#logger.warn('{}\nparallel computing is not available'.format(e))
try:
	import drmaa    # for grid
	GRID = True
	from tempfile import NamedTemporaryFile
except (RuntimeError,ImportError,AttributeError,OSError) as e:
	if "DRMAA_LIBRARY_PATH" in format(e):
#		logger.warning('Grid computing is not available because DRMAA not configured properly: {}'.format(e))
		pass
	else:
#		logger.warning('Grid computing is not available because DRMAA not installed: {}'.format(e))
		pass
	logger.info('No DRMAA (see https://github.com/pygridtools/drmaa-python), Switching to local mode.')
	GRID = False

__version__ = '1.1'

class Grid(object):
	def __init__(self, cmd_list=None,
			work_dir=None, out_path=None,
			err_path=None, grid_opts='',
			cpu=1, mem='1g', template=None,
			tc_tasks = None, script=None,
			join_files=True, stdout=False):
		self.cmd_list = cmd_list
		try: self.grid = self.which_grid()
		except Exception as e:
			logger.warn(e)
			self.grid = 'unknown'
		self.grid_opts = grid_opts
		self.template = template
#		if tc_tasks is not None:
#			if self.grid == 'sge':
#				self.grid_opts += ' -tc {}'.format(tc_tasks)
#		if self.grid == 'sge':
		self.grid_opts = self.grid_opts.format(cpu=cpu, mem=mem, tc=tc_tasks)
		if self.cmd_list is not None:
			self.script = script
			if self.script is None:
				fp = NamedTemporaryFile('w+t', delete=False)
				self.script = fp.name
			else:
				fp = open(self.script, 'w')
			self.make_script(fp)
			fp.close()
			os.chmod(self.script, stat.S_IRWXU)
			self.script = os.path.realpath(self.script)
			self.work_dir = work_dir
			if self.work_dir is None:
				self.work_dir = os.getcwd()
			self.out_path = out_path	# The path to a file representing job's stdout.
			self.err_path = err_path	# The path to a file representing job's stderr
			if self.out_path is None:
				self.out_path = ':' + self.script + '.out'
			elif not self.out_path.startswith(':'):
				self.out_path = ':' + self.out_path
			if self.err_path is None:
				self.err_path = ':' + self.script + '.err'
			elif not self.err_path.startswith(':'):
				self.err_path = ':' + self.err_path
			self.join_files = join_files	# True if stdin and stdout should be merged, False otherwise.
			self.stdout = stdout

	def make_script(self, fout=sys.stdout):
		print('#!/bin/bash', file=fout)
		if self.template is None:
			self.template = 'if [ $SGE_TASK_ID -eq {id} ]; then\n{cmd}\nfi'
			if self.grid == 'sge':
#			print >> fout, '#$ {}'.format(self.grid_opts)
				self.template = 'if [ $SGE_TASK_ID -eq {id} ]; then\n{cmd}\nfi'
			elif self.grid == 'slurm':
				self.template = 'if [ $SLURM_ARRAY_TASK_ID -eq {id} ]; then\n{cmd}\nfi'
		for i, cmd in enumerate(self.cmd_list):
			grid_cmd = self.template.format(id=i+1, cmd=cmd)
			print(grid_cmd, file=fout)
	def submit(self):
		job_status = []
		s = drmaa.Session()
		s.initialize()
		jt = s.createJobTemplate()
		jt.jobEnvironment = os.environ.copy()
		jt.nativeSpecification = self.grid_opts
		jt.remoteCommand = self.script
		jt.workingDirectory = self.work_dir
		if not self.stdout:
			jt.outputPath = self.out_path
		else:
			self.join_files = False
		jt.errorPath = self.err_path
		logger.info('submiting {}'.format([self.script, self.grid_opts]))
		jt.joinFiles = self.join_files
		joblist = s.runBulkJobs(jt, 1, len(self.cmd_list), 1)
		jobid = joblist[0].split('.')[0]
		if self.grid == 'sge':
			sub_info = '{} -t 1-{} {} -o {}'.format('qqsub', len(self.cmd_list), self.grid_opts, self.out_path.strip(':'))
			_qsub_log(jobid, self.work_dir, self.script, sub_info)
		#jid = s.runJob(jt)
		s.synchronize(joblist, drmaa.Session.TIMEOUT_WAIT_FOREVER, False)
		logger.info('waiting for {} tasks'.format(len(joblist)))
		for curjob in joblist:
			try:
				retval = s.wait(curjob, drmaa.Session.TIMEOUT_WAIT_FOREVER)
			except Exception as e:
				logger.warn('Job {}: {}'.format(curjob, e))
				job_status += [(None, 1)]
				continue
			logger.info('Task: {0} finished with status {1}, exit code {2}'.format(
					retval.jobId, retval.hasExited, retval.exitStatus))
			task_id, status = retval.jobId, (not retval.hasExited) + retval.exitStatus
			job_status += [(task_id, status)]
			if self.stdout:
				outfile = '{script}.o{taskid}'.format(
							script=os.path.basename(self.script),
							taskid=task_id)
				f = sys.stdout
				for line in open(outfile):
					f.write(line)
				os.remove(outfile)
		s.deleteJobTemplate(jt)
		s.exit()
		return job_status
	def which_grid(self):
		with drmaa.Session() as s:
			name = s.drmaaImplementation
#		grid, version = name.split()
#		if grid == 'OGS/GE':
		if 'OGS/GE' in name or 'SGE' in name:
			return 'sge'
		elif 'Slurm' in name:
			return 'slurm'
		else:
			logger.warn('Please provide your grid system `{}` to auther'.format(name))
		return 'sge'
def run_tasks(cmd_list, tc_tasks=None, mode='grid', grid_opts='', cpu=1, mem='1g', cont=1,
			retry=1, script=None, out_path=None, completed=None, cmd_sep='\n', **kargs):
	if not cmd_list:
		logger.info('cmd_list with 0 command. exit with 0')
		return 0

	variables = vars()
	del variables['cmd_list']
	logger.info( 'VARS: {}'.format(variables))

	close_cmp = False
	# file name
	xmod = 'a' if cont else 'w'
	if completed is not None and not isinstance(completed, IOBase):
		completed = open(completed, xmod)
		close_cmp = True
	ntry = 0
	out_path0 = out_path
	tc_tasks0 = tc_tasks
	while True:
		ntry += 1
		logger.info('running {} commands: try {}'.format(len(cmd_list), ntry))
#		if out_path is not None:
#			out_path = '{}.{}'.format(out_path0, ntry)
		if mode == 'grid':
			avail_tasks = [tc_tasks0, len(cmd_list)]
			tc_tasks = min(avail_tasks)
			logger.info('reset tc_tasks to {} by {}'.format(tc_tasks, avail_tasks))
			job = Grid(cmd_list=cmd_list, tc_tasks=tc_tasks, grid_opts=grid_opts,
						script=script, out_path=out_path, cpu=cpu, mem=mem, **kargs)
			logger.info('submiting jobs with {}'.format(job.grid))
			job_status = job.submit()
			exit_codes = [status for (task_id, status) in job_status]
		elif mode == 'local':
			avail_tasks = [tc_tasks0, avail_cpu(cpu), avail_mem(mem), len(cmd_list)]
			tc_tasks = min(avail_tasks)
			logger.info('reset tc_tasks to {} by {}'.format(tc_tasks, avail_tasks))
			job_status = pp_run(cmd_list, processors=tc_tasks)
			exit_codes = []
			fout = open(out_path, xmod) if out_path is not None else None
			#f = sys.stdout
			for (stdout, stderr, status) in job_status:
				if fout is not None:
					print('>>STATUS:\t{}\n>>STDOUT:\n{}\n>>STDERR:\n{}'.format(status, stdout.decode(), stderr.decode()), file=fout)
			#		print('>>STATUS:\t{}\n>>STDERR:\n{}'.format(status, stderr), file=fout)
			#	f.write(stdout)
				exit_codes += [status]
			if fout is not None:
				fout.close()
		uncmp = []
		for cmd, status in zip(cmd_list, exit_codes):
			if status > 0:
				uncmp += [cmd]
			elif completed is not None:
				completed.write(cmd + cmd_sep)
		if ntry >= retry or not uncmp:
			logger.info('finished with {} commands uncompleted'.format(len(uncmp)))
			break
		cmd_list = uncmp
	# close
	if close_cmp:
		completed.close()
	# if completed?
	return len(uncmp)
def avail_cpu(cpu):
	cpu_count = multiprocessing.cpu_count()
	return max(1, int(1.0*cpu_count/cpu))
	
d_mem = {'':1e1, 'k':1e3, 'm':1e6, 'g':1e9, 't':1e12}
def avail_mem(mem, max_mem=None):
	if max_mem is None:
		import psutil
		memory = psutil.virtual_memory()
		max_mem = memory.available
	else:
		max_mem = mem2float(max_mem)
	mem = mem2float(mem)
	return max(1, int(1.0*max_mem//mem))
def limit_memory(mem, max_mem):
	logger.info('Limit memory {} per process with total memory {}'.format(
		float2mem(mem), float2mem(max_mem)))
	return avail_mem(mem, max_mem)

def available_memory():
	import psutil
	memory = psutil.virtual_memory()
	mem_free = memory.available
	return float2mem(mem_free)

def float2mem(mem):
	if isinstance(mem, str):
		try: mem = float(mem)
		except ValueError: return mem
		
	for k, v in sorted(d_mem.items(), key=lambda x:x[1], reverse=1):
		if mem > v:
			return '{:.1f}{}'.format(mem/v, k.upper())

def mem2float(mem):
	if isinstance(mem, (int, float)):
		return mem
	import re
	try:
		num, unit = re.compile(r'(\d+\.?\d*)([kmgt]?)', re.I).match(mem).groups()
		return float(num) * d_mem[unit.lower()]
	except AttributeError:
		raise AttributeError('Illegal MEMORY string `{}` (legal: 2g, 100m, 0.3t).'.format(mem))
def _qsub_log(jid, pwd, cmd, opts):
    wlog = r'''LOGFILE=/share/sge/default/common/working_dirs
JID={}
PWD={}
CMD="{} {}"
DATE=`date +"%Y-%m-%d-%H-%M-%S"`
echo "$JID:$PWD:\"$CMD\":$(whoami):$DATE" >> $LOGFILE
'''.format(jid, pwd, opts, cmd)
    run_cmd(wlog)

def file2list(cmd_file, sep="\n"):
	if not '\n' in sep:
		sep += '\n'
	if not isinstance(cmd_file, str): # file = io.TextIOWrapper in py3
		f = cmd_file
		cmd_list = f.read().split(sep)
	else:
		if not os.path.exists(cmd_file) or not os.path.getsize(cmd_file):
			cmd_list = []
		else:
			f = open(cmd_file, 'r')
			cmd_list = f.read().split(sep)
	return [cmd for cmd in cmd_list if cmd.strip()]

def run_cmd(cmd, log=False, logger=None, fail_exit=True):
	if log and logger is None:
		logger = LOGGER
	if logger is not None:
		logger.info('run CMD: `{}`'.format(cmd))
#	print(cmd)
	job = subprocess.Popen(cmd,stdout=subprocess.PIPE,\
							stderr=subprocess.PIPE,shell=True)
	output = job.communicate()
	status = job.poll()
	if logger is not None and status > 0:
		logger.warn("exit code {} for CMD `{}`: ".format(status, cmd))
		logger.warn('\n###STDOUT:<< {0} >>\n###STDERR:<< {1} >>'.format(*map(lambda x:x.decode(), output)))
		if fail_exit:
			raise ValueError('Failed to run CMD, see details above.')
	return output + (status,)

def _run_cmd(arg):
	cmd, log, logger = arg
	return run_cmd(cmd, log, logger)

def default_processors(actual=None):
	from multiprocessing import cpu_count
	available_cpus = cpu_count()
	if actual:
		if actual > available_cpus:
			return available_cpus
		else:
			return actual
	else:
		return available_cpus
def pp_run(cmd_list, processors='autodetect'):
#	'''use multiprocessing instead of pp'''
	try: return pool_run(cmd_list, processors)
	except: pass	# AssertionError: daemonic processes are not allowed to have children
								# Nest of Pool
	if processors is None:
		processors = 'autodetect'
	ppservers = ()
	job_server = pp.Server(processors, ppservers=ppservers)
	jobs = [job_server.submit(run_cmd, (cmd,), (), ('subprocess',)) for cmd in cmd_list]
	return [job() for job in jobs]

def pp_func(func, lst, args=(), funcs=(), libs=(), processors='autodetect'):
	ppservers = ()
	job_server = pp.Server(processors, ppservers=ppservers)
	jobs = [job_server.submit(func, add_args(value,args), funcs, libs) for value in lst]
	return jobs #[job() for job in jobs]
def pool_func(func, iterable, processors=8, method=None, ordered=True, imap=False, **kargs):
	'''method: map, imap, imap_unordered in Pool
ordered: False for imap_unordered
imap: True for imap'''
	pool = multiprocessing.Pool(processors)
	if method is not None:
		pool_map = eval('pool.'+method)
	elif ordered and not imap:
		pool_map = pool.map
	elif ordered:
		pool_map = pool.imap
	else:
		pool_map = pool.imap_unordered
	logger.info('Start Pool with {} process(es)'.format(processors))
#	logger.info('Using pool method: {}'.format(pool_map))
	for returned in pool_map(func, iterable, **kargs):
		yield returned
#	logger.info('Closing Pool')
	pool.close()
#	logger.info('Joining Pool')
	pool.join()

def pool_run(cmd_list, processors=8, log=True, logger=None, **kargs):
	try: processors = int(processors)
	except (TypeError,ValueError):
		processors = multiprocessing.cpu_count()
	iterable = ((cmd, log, logger) for cmd in cmd_list)
	return [ returned for returned in pool_func(_run_cmd, iterable, processors=processors, **kargs) ]

def add_args(value, args):
	if isinstance(value, tuple):
		return value + args
	else:
		return (value,) + args
def get_cmd_list(cmd_file, cmd_cpd_file=None, cmd_sep="\n", cont=True):
	if not '\n' in cmd_sep:
		cmd_sep += '\n'
	if not os.path.exists(cmd_file):
		raise IOError('Commands file : %s does NOT exist.'% (cmd_file, ))
	if cmd_cpd_file is None:
		cmd_cpd_file = cmd_file + '.completed'
	cmd_list = file2list(cmd_file, cmd_sep)
	cmd_cpd_list = file2list(cmd_cpd_file, cmd_sep)
	logger.info('{} commands in {}, {} commands in {}'.format(
				len(cmd_list), cmd_file, len(cmd_cpd_list), cmd_cpd_file))
	if cont:
		cmd_uncpd_list = sorted(list(set(cmd_list)-set(cmd_cpd_list)), \
							key=lambda x: cmd_list.index(x))
		logger.info('continue to run {} commands'.format(len(cmd_uncpd_list)))
	else:
		cmd_uncpd_list = sorted(list(set(cmd_list)), \
							key=lambda x: cmd_list.index(x))
	return cmd_uncpd_list
def submit_pp(cmd_file, processors=None, cmd_sep="\n", cont=True):
	if not '\n' in cmd_sep:
		cmd_sep += '\n'
	if not os.path.exists(cmd_file):
		raise IOError('Commands file : %s does NOT exist.'% (cmd_file, ))
	cmd_cpd_file = cmd_file + '.completed'
	cmd_list = file2list(cmd_file, cmd_sep)
	cmd_cpd_list = file2list(cmd_cpd_file, cmd_sep)
	if cont:
		cmd_uncpd_list = sorted(list(set(cmd_list)-set(cmd_cpd_list)), \
							key=lambda x: cmd_list.index(x))
	else:
		cmd_uncpd_list = sorted(list(set(cmd_list)), \
								key=lambda x: cmd_list.index(x))
		# not continue, so NONE completed
		cmd_cpd_list = []
	# for Argument list too long
	for i,cmd in enumerate(cmd_uncpd_list):
		if len(cmd.split('\n')) > 100:
			son_cmd_file = '%s.%s.sh' % (cmd_file, i)
			with open(son_cmd_file, 'w') as f:
				print(cmd, file=f)
			cmd_uncpd_list[i] = 'sh %s' % (son_cmd_file,)

	print('''
	total commands:\t%s
	skipped commands:\t%s
	retained commands:\t%s
	''' % (len(set(cmd_list)), \
	len(set(cmd_list))-len(cmd_uncpd_list), \
	len(cmd_uncpd_list)))

	if not processors:
		processors = default_processors(len(cmd_uncpd_list))
	# start pp
	ppservers = ()
	job_server = pp.Server(processors, ppservers=ppservers)
	jobs = [(cmd, job_server.submit(run_cmd, (cmd,), (), ('subprocess',))) \
			for cmd in cmd_uncpd_list]
	# recover stdout, stderr and exit status
	cmd_out_file, cmd_err_file, cmd_warn_file = \
	cmd_file + '.out', cmd_file+'.err', cmd_file+'.warning'
	if cont:
		i = len(set(cmd_list))-len(cmd_uncpd_list)
		mode = 'a'
	else:
		i = 0
		mode = 'w'
	f = open(cmd_cpd_file, mode)
	f_out = sys.stdout #open(cmd_out_file, mode)
	f_err = open(cmd_err_file, mode)
	f_warn = open(cmd_warn_file, mode)
	for cmd, job in jobs:
		i += 1
		out, err, status = job()
#		f_out.write('CMD_%s_STDOUT:\n' % i + out + cmd_sep)
		f_out.write(out)
		f_err.write('CMD_%s_STDERR:\n' % i + err + cmd_sep)
		if not status == 0:
			f_warn.write(cmd + cmd_sep)
		else:
			f.write(cmd + cmd_sep)
	f.close()
#	f_out.close()
	f_err.close()
	f_warn.close()

	job_server.print_stats()

def main():
	usage = __doc__ + "\npython %prog [options] <commands.list>"
	parser = OptionParser(usage, version="%prog " + __version__)
	parser.add_option("-p","--processors", action="store",type="int",\
					dest="processors", default=40, \
					help="number of processors [default=all available]")
	parser.add_option("-s","--separation", action="store", type="string",\
					dest="separation", default='\n', \
					help='separation between two commands [default="\\n"]')
	parser.add_option("-c","--continue", action="store", type="int",\
					dest="to_be_continue", default=1, \
					help="continue [1] or not [0] [default=%default]")
	parser.add_option("-m","--mode", action="store", type="choice",\
					dest="mode", default='grid', choices=['local', 'grid'], \
					help='run mode [default=%default]')
	parser.add_option("--retry", action="store", type="int",\
					dest="retry", default=1, \
					help="retry times [default=%default]")
	parser.add_option("--grid-opts", action="store", type="string",\
					dest="grid_opts", default='-tc {tc}', \
					help='grid options [default="%default"]')
	parser.add_option("--stdout", action="store_true", \
                    dest="stdout", default=False, \
                    help='collect grid output to stdout [default="%default"]')

	(options,args)=parser.parse_args()
	separation = options.separation
	if not args:
#		parser.print_help()
#		sys.exit()
		cmd_list = file2list(sys.stdin, sep=separation)
		cmd_file = '/io/tmp/share/RunCmdsMP.{}'.format(os.getpid())
	else:
		cmd_file = args[0]
		cmd_list = None
	processors = options.processors
	mode = options.mode
	grid_opts = options.grid_opts
	retry = options.retry
	to_be_continue = options.to_be_continue
	stdout = options.stdout
#	submit_pp(cmd_file, processors=processors, \
#				cmd_sep=separation, cont=to_be_continue)
	run_job(cmd_file, cmd_list, tc_tasks=processors, mode=mode, grid_opts=grid_opts,
                cont=to_be_continue, retry=retry, cmd_sep=separation, stdout=stdout)
def run_job(cmd_file=None, cmd_list=None, by_bin=1, tc_tasks=8, mode='grid', grid_opts='-tc {tc}', cont=1, fail_exit=True,
            ckpt=None, retry=1, out_path=None, cmd_sep='\n', **kargs):
	if not GRID and mode == 'grid':
		logger.info('GRID is not available. Turning to the local mode..')
		mode = 'local'
	tc_tasks = int(tc_tasks)
	if cmd_file is None:
		cmd_file = '/io/tmp/share/RunCmdsMP.{}'.format(os.getpid())
	if cmd_list is not None:
		if by_bin > 1:
			cmd_list2 = []
			for i in range(0, len(cmd_list), by_bin):
				cmd_list2 += ['\n'.join(cmd_list[i:i+by_bin])]
			cmd_list = cmd_list2
		cmd_sep = '\n'+cmd_sep+'\n' #if cmd_sep !='\n' else cmd_sep
		with open(cmd_file, 'w') as fp:
			print(cmd_sep.join(cmd_list), file=fp)
	if kargs.get('cpu') is None:
		kargs['cpu'] = 1
	if kargs.get('mem') is None:
		kargs['mem'] = '1g'
	ckpt = cmd_file + '.ok' if ckpt is None else ckpt
	if cont and os.path.exists(ckpt):
		logger.info('check point file `{}` exists, skipped'.format(ckpt))
		return 0
	script = cmd_file + '.sh' if mode == 'grid' else None
	out_path = cmd_file + '.out' if out_path is None else out_path
	cmd_cpd_file = cmd_file + '.completed'
	if not cont and os.path.exists(ckpt):
		os.remove(ckpt)
	if not cont and os.path.exists(cmd_cpd_file):
		os.remove(cmd_cpd_file)
	if not cont and os.path.exists(out_path):
		os.remove(out_path)
	cmd_list = get_cmd_list(cmd_file, cmd_cpd_file, cmd_sep=cmd_sep, cont=cont)
	exit = run_tasks(cmd_list, tc_tasks=tc_tasks, mode=mode, grid_opts=grid_opts,
				retry=retry, script=script, out_path=out_path, cont=cont,
				completed=cmd_cpd_file, cmd_sep=cmd_sep, **kargs)
	if fail_exit and not exit == 0:
		raise ValueError('faild to run {}, see detail in {}'.format(cmd_file, out_path))
	elif exit == 0:
		try: os.mknod(ckpt)
		except FileExistsError: pass
	return exit

if __name__ == '__main__':
	main()
