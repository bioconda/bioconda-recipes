import sys, os
import re
import math
import itertools
import numpy as np
from collections import OrderedDict
from ete3 import Tree, TreeStyle, AttrFace, NodeStyle, ImgFace, faces
from ete3.coretype.tree import TreeError
from scipy.stats import chi2
from .RunCmdsMP import logger, run_cmd
from .small_tools import mk_ckp, check_ckp

COLORS = ('#1f77b4', '#ff7f0e', '#2ca02c', '#d62728')

class BL:
	def __init__(self, species_tree, gene_trees):
		self.species_tree = species_tree	# Tree object, labeled
		self.gene_trees = gene_trees	# treefile path
	def run(self):
		d_quartet =self.tree2quartet(self.species_tree)
	#	print(d_quartet)
		return self.get_BL(self.gene_trees, d_quartet)
	def tree2quartet(self, tree):
		leaf_names = tree.get_leaf_names()
		d_quartet = OrderedDict()
		i = 0
		for node in tree.traverse():
			if node.is_leaf() or node.is_root():
				continue
			i += 1
			if not node.name:
				node.name = 'N{}'.format(i)

			sisters = node.get_sisters()
			assert len(sisters) == 1, 'not bifurcating with more than one sisters: {}'.format(node)
			sister = sisters[0]
			if sister.is_root():
				continue
			children = node.get_children()
			assert len(children) == 2, 'not bifurcating with more than two children: {}'.format(node)
			child1, child2 = children
			sister_names = sister.get_leaf_names()
			child1_names = child1.get_leaf_names()
			child2_names = child2.get_leaf_names()
			outgroup_names = set(leaf_names) - set(sister_names) - set(child1_names) - set(child2_names)
			outgroup_names = list(outgroup_names)
			if not outgroup_names:
				continue
			if node.name in d_quartet:
				raise ValueError('non-unique node name: {}'.format(node.name))
			d_quartet[node.name] = [outgroup_names, sister_names, child1_names, child2_names] # O,S,L,R
		return d_quartet
	def get_BL(self, gene_trees, d_quartet, cutoff=0.8):
		qs = ['q1', 'q2', 'q3']
		d_qdist = {}
		j = 0
		for line in open(gene_trees):
			gtree = Tree(line)
			for name, quartet in d_quartet.items():
				if name not in d_qdist:
					d_qdist[name] = {q:[] for q in qs}
				d_dist = {q:[] for q in qs}
				i = 0
#				print(name, quartet)
				for to, ts, tl, tr in itertools.product(*quartet):
					j += 1
					qtree = gtree.copy('newick')
					try: qtree.prune([to, ts, tl, tr], preserve_branch_length=True)
					except ValueError: continue	# node not found
					qtree.set_outgroup(to)
					qtree.prune([ts, tl, tr], preserve_branch_length=True)
					anc = qtree.get_common_ancestor(qtree.get_leaves())
					d_map = dict(zip([ts, tr, tl], qs))
					for child in anc.get_children():
						if child.is_leaf():
							tn = d_map[child.name]
						else:
							dist = child.get_distance(anc)
					i += 1
					d_dist[tn] += [dist]
				max_q, dists = max(d_dist.items(), key=lambda x: len(x[1]))
				if 1.0*len(dists) < cutoff:
					continue
				dist = np.mean(dists)
				d_qdist[name][max_q] += [dist]
		logger.info('processed {} times'.format(j))
		return d_qdist

def convertNHX(inNwk, ):
	def convert(line):
		last_end = 0
		patterns = []
		for match in re.compile(r"'\[(\S+?)\]':(\d+\.?\d*)").finditer(line):
			start = match.start()
			end = match.end()
			patterns.append( line[last_end:start] )
			branch, length = match.groups()
			new_str = ':{}[&&NHX:{}]'.format(length, branch.replace(';', ':'))
			patterns.append( new_str )
			last_end = end
		patterns.append( line[last_end:] )
		return ''.join(patterns)
	nwk = []
	for line in open(inNwk):
		nwk += [convert(line)]
	return ''.join(nwk)

class AstralTree:
	def __init__(self, astral, alter=None, genetrees=None, 
			max_pval=0.05, tmpdir='tmp', prefix=None, both_plot=True,
			clades=None, onshow=None, noshow=None, add_bl=False,
			collapsed=None, subset=None, sort=False, notext=False,
			test_clades=None, astral_bin='astral-pro', outgroup=None,
			pie=False, cp=False, figfmt='png', colors=None,
			figsize=3, fontsize=13, 
			branch_size=48, # fontsize of branch text
			leaf_size=60,
			pie_size=30, pie_fold=6,
			align=False, # align tip labels
			polytomy_test=False, # test for polytomies
			):
		self.treefile = astral
		self.treestr = convertNHX(self.treefile)
		self.tree = Tree(self.treestr)
		self.max_pval = max_pval
		self.tmpdir = tmpdir
		self.prefix = prefix
		self.clades = self.parse_clades(clades)
		self.onshow = self.lazy_parse_clades(onshow)	# only  show barcharts on some nodes
		self.noshow = self.lazy_parse_clades(noshow)	# don't show barcharts on some nodes
		self.collapsed = self.lazy_parse_clades(collapsed)	# collapse some clades
		if collapsed == []:
			self.collapsed = self.clades.keys()
		self.subset = self.lazy_parse_clades(subset)	# only show a subset taxa
		self.test_clades = self.lazy_parse_clades(test_clades) # test four-taxons
		self.astral_bin = astral_bin
		self.outgroup = outgroup
		self.alter = alter	# show another tree
		self.genetrees = genetrees	# branch lengths
		self.add_bl = add_bl	# add branch lengths
		self.sort = sort	# sort q1,q2,q3 or not
		self.notext = notext # draw text or not
		self.figsize = figsize	# barcharts
		self.fontsize = fontsize	# barcharts text
		self.branch_size = branch_size
		self.figfmt = figfmt
		self.both_plot = both_plot # plot both histogram and barcharts
		self.pie = pie
		self.cp = cp
		self.leaf_size = leaf_size
		if self.pie:
			self.leaf_size = self.leaf_size / pie_fold
			self.branch_size = self.branch_size / pie_fold
		self.pie_size = pie_size
		self.align = align
		self.polytomy_test = polytomy_test
		if self.prefix is None:
			self.prefix = os.path.basename(self.treefile)
		if colors is None:
			self.colors = COLORS
		elif isinstance(colors, str):
			self.colors = colors.split(',')
		else:
			self.colors = self.colors
	def check(self):
		if not re.compile(r'f1=\S+f2=\S+f3=\S+').search(self.treestr):
			#raise ValueError('Keys f1, f2 and f3 are not found in {}. \
#Please check...'.format(self.treefile))
			logger.warn('Keys f1, f2 and f3 are not found in {}. \
Please check...'.format(self.treefile))
	def lazy_parse_clades(self, args):
		if not args:
			return args
		clades =[]
		for arg in args:
			if os.path.exists(arg) and os.path.getsize(arg)>0:
				clades += [line.strip().split()[0] for line in open(arg)]
			else:
				clades += [arg]
		return clades
	def merge_trees(self):
		for node in self.tree.traverse():
			if node.is_leaf():
				continue
			leaf_names = node.get_leaf_names()
			try:
				f1, f2, f3 = node.f1, node.f2, node.f3
			except AttributeError: continue
			anc = self.alter.get_common_ancestor(leaf_names)
			anc.f1, anc.f2, anc.f3 = f1, f2, f3
		return self.alter
	def number_nodes(self, tree):
		i = 0
		clades_file = '{}/{}.nodes.tsv'.format(self.tmpdir, self.prefix)
		f_nodes = open(clades_file, 'w')
		for node in tree.traverse():
			node.show = True
			if node.is_leaf():
				continue
			i += 1
			if node.name:
				continue
#			if node.is_root():
#				node.support = ''
			name = 'N{}'.format(i)
			node.name = name
			line = [name, ','.join(node.get_leaf_names())]
			f_nodes.write('\t'.join(line)+'\n')
		f_nodes.close()
		return clades_file
	def mark_show(self, tree, onshow=None, noshow=None):
		default = False if onshow else True
		for node in tree.traverse():
			node.show = default
			if onshow and node.name in set(onshow):
				node.show = True
			elif noshow and node.name in set(noshow):
				node.show = False
	def get_leaf_names(self, tree, nodes, d_map):
		names = set([])
		for name in nodes:
			try:
		#		print(name, d_map[name]) 
				names = names | set(d_map[name])
			except KeyError:
				try: ancestor = tree&name
				except TreeError as e: raise TreeError('{} {}'.format(name, e))
				names = names | set(ancestor.get_leaf_names())
		return names
	def test(self):
		self.alter = None
		prefix0 = self.prefix
		d_map = self.name_clades(self.tree, self.clades) if self.clades else {}
		tree0 = self.tree

		outgroup = self.test_clades[0]
		ingroups = self.test_clades[1:]
		for ingroup3 in itertools.combinations(ingroups, 3):
			ingroup3 = list(ingroup3)
			logger.info('Testing {} (outgroup) + {} (ingroup)'.format(outgroup, ingroup3))
			subset_leaf_names = self.get_leaf_names(tree0, [outgroup] + ingroup3, d_map)
			outgroup_leaf_names = self.get_leaf_names(tree0, [outgroup], d_map)
			self.prefix = '{}.{}'.format(prefix0, '-'.join(ingroup3))
			genetrees = '{}/{}.genetrees'.format(self.tmpdir, self.prefix)
			sptree = genetrees + '.astral'
			cmd = 'nw_prune {genetrees0} {leaves} -v | nw_reroot -l - {outgroup} > {genetrees} && {astral_bin} -i {genetrees} -u 2 -t 4 -o {sptree}'.format(
					genetrees0=self.genetrees, leaves=' '.join(subset_leaf_names), genetrees=genetrees,
					astral_bin=self.astral_bin, sptree=sptree, outgroup=' '.join(outgroup_leaf_names) )
			run_cmd(cmd, log=True)
			self.tree = Tree(convertNHX(sptree))
			self.process_quartet()
	def run(self):
		if self.test_clades is not None:
			if self.test_clades == []:
				self.test_clades = list(self.clades.keys())
			if self.outgroup:
				self.test_clades = [self.outgroup] + [c for c in self.test_clades if c != self.outgroup]
			self.test()
		else:
			self.process_quartet()
	def process_quartet(self):
		# check f1, f2, f3
		self.check()
		# merge
		if self.alter is not None:
			self.alter = Tree(self.alter)
			self.tree = self.merge_trees()
		# name inner nodes
		clades_file = self.number_nodes(self.tree)
		logger.info('Clades info file: `{}`, which can be renamed and edited as input of `-clades`'.format(clades_file))
		
		# load genetrees
		if self.genetrees and self.add_bl:
			ckpfile = '{}/{}.genetrees.dists'.format(self.tmpdir, self.prefix)
			data = check_ckp(ckpfile)
			if data:
				d_dist, = data
			else:
				d_dist = BL(self.tree, self.genetrees).run()
				mk_ckp(ckpfile, d_dist)
		# replace clade names
		if self.clades:
			self.name_clades(self.tree, self.clades)
		if self.onshow or self.noshow:
			self.mark_show(self.tree, self.onshow, self.noshow)
		# subset
		if self.subset:
			self.subset_tree(self.tree, self.subset)
		# collapse
		if self.collapsed:
			self.collapse_tree(self.tree, self.collapsed)
			
		i = 0
		info_file = '{}.info.tsv'.format(self.prefix)
		f_info = open(info_file, 'w')
		line = ['node', 'n', 'p_value', 'q1', 'q2', 'q3', 'ILS_explain', 'IH_explain', 'ILS_index', 'IH_index']
		f_info.write('\t'.join(line)+'\n')
		_colors = self.colors[:3]
		fsize = self.leaf_size
		for node in self.tree.traverse():
			if node.is_leaf():
				node.sp = ' {}'.format(node.name.replace('_', " "))
				N = AttrFace("sp", fsize=fsize, fgcolor="black", fstyle='italic')
				if self.align:
					node.add_face(N, 0, position='aligned')
				else:
					node.add_face(N, 0, )
			#	node.img_style["draw_descendants"] = False
				continue
			try:
				f1, f2, f3 = node.f1, node.f2, node.f3
			except AttributeError: continue
			f1, f2, f3 = map(float, [f1, f2, f3])
			n = sum([f1, f2, f3])
			if n == 0:
				logger.warn('Zero in node: {}'.format(node.name))
				continue
			q1, q2, q3 = f1/n, f2/n, f3/n
			coalescent_unit = node.dist
			#eq2 = eq3 = math.exp(-coalescent_unit) / 3	# expected
			eq2 = eq3 = (1-q1) / 2	# expected
			eq1 = 1 - eq2 - eq3
			if self.polytomy_test:
				eq1 = eq2 = eq3 = 1.0/3
			ef1, ef2, ef3 = n*eq1, n*eq2, n*eq3
			try: chi_sq = (ef1-f1)**2/ef1 + (ef2-f2)**2/ef2 + (ef3-f3)**2/ef3
			except ZeroDivisionError: chi_sq = 0
			pval = 1-chi2.cdf(chi_sq, 1)
			if pval > self.max_pval: # ILS
				IH_index = 0
				IH_explain = 0
				ILS_index = eq2	# (>0, <0.33)
				ILS_explain = q2+q3
				hline = eq3
			else:
				xq2, xq3 = max(q2, q3), min(q2, q3)
				IH_index = (xq2-xq3) / (q1 - xq3 + xq2-xq3)	# how many introgression (>0,<0.5)
				IH_explain = xq2-xq3
				ILS_index = xq3
				ILS_explain = xq3*2
				hline = xq3
		#	hline = math.exp(-coalescent_unit) / 3 # expected
		#	hline = (1-q1) / 2
			ILS_index = ILS_index / (1.0/3)
			IH_index = IH_index
			print(hline, pval, i, f1, f2, f3, n, [q1, q2, q3])
			try: pp = node.support = float(node.pp1)
			except AttributeError: pp = node.support
			# theta = 2* Lm/Lc
			i += 1
#			name = 'N{}'.format(i)
#			node.name = name
#			line = [name, ','.join(node.get_leaf_names())]
#			f_nodes.write('\t'.join(line)+'\n')
			name = node.name
			Pfmt = '{:.3f}' if pval > self.max_pval else '{:.2e}'
			P = Pfmt.format(pval)
			text = '$n$={:.0f}\n$P$={}\nILS-e={:.1%}\nIH-e={:.1%}\nILS-i={:.1%}\nIH-i={:.1%}'.format(
				n, P, ILS_explain, IH_explain, ILS_index, IH_index)

			kargs = dict(hline=hline, text=text,
					sort=self.sort, notext=self.notext, figsize=self.figsize, fontsize=self.fontsize)
			if not self.pie:
				if self.both_plot and self.genetrees and self.add_bl:
					outfig = '{}/{}.{}.both.{}'.format(self.tmpdir, self.prefix, name, self.figfmt)
					joint_plot(bardata=[q1, q2, q3], histdata=d_dist[node.name], outfig=outfig, colors=_colors, **kargs)
				else:
					outfig = '{}/{}.{}.bar.{}'.format(self.tmpdir, self.prefix, name, self.figfmt)
					values, labels, colors = plot_bar([q1, q2, q3], outfig=outfig, colors=_colors, **kargs)
					#hline=hline, text=text, 
					#sort=self.sort, notext=self.notext, figsize=self.figsize, fontsize=self.fontsize)
		#	outfig = '{}/{}.{}.dist.pdf'.format(self.tmpdir, self.prefix, name)
		#	plot_dist(data=d_dist[node.name], outfig=outfig, figsize=self.figsize,)
			if node.show:	
				if self.cp:
					cp = '{:.0f}'.format(max(q1, q2, q3)*100)
					concord_text = faces.TextFace(cp, fsize=self.branch_size)
					node.add_face(concord_text, column=0, position = "branch-top")
				pp = '{:.0f}'.format(pp*1e2)
				support_text = faces.TextFace(pp, fsize=self.branch_size)
				if not node.is_root():
					node.add_face(support_text, column=0, position = "branch-bottom")
				if self.pie:
					values = [v*100 for v in [q1, q2, q3]]
					values = [values[x] for x in [1,0,2]]
					colors = [_colors[x] for x in [1,0,2]]
					face = faces.PieChartFace(values, width=self.pie_size, height=self.pie_size, colors=colors,)
					node.add_face(face, column=1, position="branch-right")
#					if self.cp:
#						cp = '{:.0f}'.format(values[1])
#						concord_text = faces.TextFace(cp, fsize=8)
#						node.add_face(concord_text, column=0, position = "branch-top")
				else:
					print(outfig)
					face = ImgFace(outfig, ) #width=500, height=500)
					#face = faces.SVGFace(outfig)
					#face = faces.BarChartFace(values, colors=colors, labels=labels, min_value=0, max_value=1, width=100, height=100, label_fsize=2, scale_fsize=2)
					#faces.add_face_to_node(face, node, column=0)
					node.add_face(face, column=0, position="branch-right")
			line = [name, n, pval, q1, q2, q3, ILS_explain, IH_explain, ILS_index, IH_index]
			line = map(str, line)
			f_info.write('\t'.join(line)+'\n')
		f_info.close()
#		print(dir(node))
		# write tree
		labeled_treefile = '{}/{}.label.tree'.format(self.tmpdir, self.prefix)
		self.tree.write(format=1, outfile=labeled_treefile)
		logger.info('Labeled tree file: `{}`'.format(labeled_treefile))
		logger.info('Information file: `{}`'.format(info_file))

		#	node.img_style["size"] = 0
		ts = TreeStyle()
		ts.show_leaf_name = False
#		ts.show_branch_support = True
		ts.scale_length = 1
		# # Set bold red branch to the root node
		style = NodeStyle()
		style["fgcolor"] = "#0f0f0f"
		style["size"] = 0
#		branch_color = '#7200da'
#		style["vt_line_color"] = branch_color
#		style["hz_line_color"] = branch_color
		style["vt_line_width"] = 1
		style["hz_line_width"] = 1
#		style["vt_line_type"] = 0 # 0 solid, 1 dashed, 2 dotted
#		style["hz_line_type"] = 0
#		self.tree.set_style(style)
		for node in self.tree.traverse():
			node.img_style = style

		outfig = self.prefix + '.pdf'
		logger.info('Final plot: `{}`'.format(outfig))
		self.tree.render(outfig, w=1000, tree_style=ts, dpi=300)
	def parse_clades(self, cfg):
		d_clades = OrderedDict()
		if not cfg:
			return d_clades

		for line in open(cfg):
			temp = line.strip().split()
			mcra = temp[0]
			leaf_names = temp[1].split(',')
			if mcra in d_clades and leaf_names != d_clades[mcra]:
				logger.error('Conflict clade `{}`: {} vs {}.'.format(mcra, leaf_names, d_clades[mcra]))
			d_clades[mcra] = leaf_names
		return d_clades
	def name_clades(self, tree, d_clades):
		d_map = {}
		for mcra, leaf_names in d_clades.items():
			try: leaf_names = self.name_clade(tree, mcra, leaf_names)
			except UnboundLocalError: continue
			d_map[mcra] = leaf_names
		return d_map
	def name_clade(self, tree, mcra, leaf_names):
		if len(leaf_names) == 1:
			leaf_name = leaf_names[0]
			try: ancestor = tree&leaf_name
			except TreeError as e: pass
#				logger.warn(leaf_name, e)
		else:
			try: ancestor = tree.get_common_ancestor(leaf_names)
			except ValueError as e: pass
		#		logger.error(leaf_names, e)
		leaf_names = ancestor.get_leaf_names()		
		ancestor.name = mcra
		return leaf_names

	def collapse_tree(self, tree, clades):
		keep, remove = set(tree.get_leaf_names()), set([])
		for mcra in clades:
			try: ancestor = tree&mcra
			except TreeError as e: #continue # cannot find
				#logger.warn(mcra, e)
				continue
			keep.add(mcra)
			leaf_names = ancestor.get_leaf_names()
			if len(leaf_names) > 1:
				remove = remove | set(leaf_names)

#		print(self.tree.write())
#		print (self.tree.write(is_leaf_fn=collapsed_leaf))
#		self.tree = Tree( self.tree.write(is_leaf_fn=collapsed_leaf) )
		keep = keep - remove
		tree.prune(keep)
#		print(ancestor.is_leaf())
#		print(self.tree.write())
	def subset_tree(self, tree, leaf_names):
		ancestor = tree.get_common_ancestor(self.to_leafs(tree, leaf_names))
		keep = set(ancestor.get_leaf_names())
#		print(ancestor, keep, dir(tree), )
		tree.prune(keep)
	def to_leafs(self, tree, taxa):
		names = []
		for taxon in taxa:
			node = tree&taxon
			if node.is_leaf():
				taxon = [taxon]
			else:
				taxon = node.get_leaf_names()
			names += taxon
		return names
def collapsed_leaf(node):
	return node not in d_collapse


def joint_plot(bardata, histdata, outfig=None, figsize=3, **kargs):
	from matplotlib import gridspec
	import matplotlib.pyplot as plt
	gs = gridspec.GridSpec(3, 2)
	fig = plt.figure(figsize=(figsize, figsize))
#	axs = []
	ax1 = fig.add_subplot(gs[0, 0])
	ax2 = fig.add_subplot(gs[1, 0], sharex=ax1, sharey=ax1)
	ax3 = fig.add_subplot(gs[2, 0], sharex=ax1, sharey=ax1)
	axs = [ax1, ax2, ax3]
#	for i in range(3):
#		fig.add_subplot(gs[i, 0], sharex='all', sharey='all')
	fig.subplots_adjust(hspace=0)
	ax = fig.add_subplot(gs[:, 1])
#	axs = [fig.add_subplot(gs[i, 0]) for i in range(3)]
	kargs['fontsize'] /= 2
	plot_dist(histdata, axs=axs, **kargs)
	plot_bar(bardata, ax=ax, **kargs)
	plt.savefig(outfig, bbox_inches='tight', transparent=True, dpi=300)
	plt.close()

def plot_bar(qs=[1,0,0], outfig=None, ax=None, hline=None, ymax=1, text=None, sort=False, notext=False,
		figsize=3, fontsize=14, colors=COLORS, **kargs):
	import matplotlib.pyplot as plt
	import matplotlib
	matplotlib.rcParams['ytick.minor.visible'] = True
	if sort:
		qs = list(sorted(qs, reverse=1))
	if ax is None:
		fig, ax = plt.subplots(figsize=(figsize, figsize))
#	plt.figure(figsize=(figsize, figsize))
	x = list(range(len(qs)))
	labs = ['q{}'.format(v+1) for v in x]
	cs = colors[:len(qs)]
	print(x, qs, hline)
	ax.bar(x, qs, color=cs, tick_label=labs, align='center', width=0.67)
	if hline is not None:
		ax.axhline(y=hline, color='gray', ls='--')
	if text is not None and not notext:
		ax.text(0.3*max(x), 0.98*ymax, text, fontsize=fontsize,
				horizontalalignment='left', verticalalignment='top')
	ax.set_ylim(0, ymax)
	for label in ax.yaxis.get_majorticklabels():
		label.set_rotation('vertical')
	if outfig is not None:
		plt.savefig(outfig, bbox_inches='tight', transparent=True, dpi=300)
		plt.close()
	return qs, labs, cs
def plot_dist(data, axs=None, outfig=None, figsize=3, bins=30, limit=97.5, colors=COLORS, **kargs):
	import matplotlib.pyplot as plt
#	import seaborn as sns
#	plt.figure(figsize=(figsize, figsize))
	if axs is None:
		fig, axs = plt.subplots(3, 1, sharex='all', sharey='all', figsize=(figsize, figsize))
		fig.subplots_adjust(hspace=0)
	full = []
	for vals in data.values():
		full += vals
	xlim = np.percentile(full, limit)
	colors = colors[:3]
	for key, ax, color in zip(['q1', 'q2', 'q3'], axs, colors):
		#full += data[key]
		#sns.displot(data[key], color=color, ax=ax)
		#sns.histplot(data[key], color=color, ax=ax)
		ax.hist(data[key], color=color, range=(0,xlim), bins=bins)
#		ax.set_ylabel('')
		ax.set_xlim(0, xlim)
		if key != 'q3':
			for label in ax.xaxis.get_majorticklabels():
				label.set_visible(False)
			for tick in ax.xaxis.get_ticklines():
				tick.set_visible(False)
			for tick in ax.xaxis.get_minorticklines():
				tick.set_visible(False)

	if outfig is not None:
		plt.savefig(outfig, bbox_inches='tight', transparent=True, dpi=600)
		plt.close()

def main():
#	print(convertNHX(sys.argv[1]))
	AstralTree(sys.argv[1]).run()

if __name__ == '__main__':
	main()
