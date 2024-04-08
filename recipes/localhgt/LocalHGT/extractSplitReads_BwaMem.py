#!/usr/bin/env python

import sys
import getopt
import string
from optparse import OptionParser
import re

def extractSplitsFromBwaMem(inFile,numSplits,includeDups,minNonOverlap):
	if inFile == "stdin":
		data = sys.stdin
	else:
		data = open(inFile, 'r')
	for line in data:
		split = 0
		if line[0] == '@':
			print(line.strip())
			continue
		samList = line.strip().split('\t')
		sam = SAM(samList)
		if includeDups==0 and (1024 & sam.flag)==1024:
			continue
		for el in sam.tags:
			if "SA:" in el:
				if(len(el.split(";")))<=numSplits:
					split = 1
					mate = el.split(",")
					mateCigar = mate[3]
					mateFlag = int(0)
					if mate[2]=="-": mateFlag = int(16)
		if split:
			read1 = sam.flag & 64
			if read1 == 64: tag = "_1"
			else: tag="_2"
			samList[0] = sam.query + tag
			readCigar = sam.cigar
			readCigarOps = extractCigarOps(readCigar,sam.flag)
			readQueryPos = calcQueryPosFromCigar(readCigarOps)
			mateCigarOps = extractCigarOps(mateCigar,mateFlag)
			mateQueryPos = calcQueryPosFromCigar(mateCigarOps)
			overlap = calcQueryOverlap(readQueryPos.qsPos,readQueryPos.qePos,mateQueryPos.qsPos,mateQueryPos.qePos)
			nonOverlap1 = 1 + readQueryPos.qePos - readQueryPos.qsPos - overlap
			nonOverlap2 = 1 + mateQueryPos.qePos - mateQueryPos.qsPos - overlap
			mno = min(nonOverlap1, nonOverlap2)
			if mno >= minNonOverlap:
				print("\t".join(samList))

#--------------------------------------------------------------------------------------------------
# functions
#--------------------------------------------------------------------------------------------------

class SAM (object):
	"""
	__very__ basic class for SAM input.
	"""
	def __init__(self, samList = []):
		if len(samList) > 0:
			self.query    = samList[0]
			self.flag     = int(samList[1])
			self.ref      = samList[2]
			self.pos      = int(samList[3])
			self.mapq     = int(samList[4])
			self.cigar    = samList[5]
			self.matRef   = samList[6]
			self.matePos  = int(samList[7])
			self.iSize    = int(samList[8])
			self.seq      = samList[9]
			self.qual     = samList[10]
			self.tags     = samList[11:]#tags is a list of each tag:vtype:value sets
			self.valid    = 1
		else:
			self.valid = 0
			self.query = 'null'

	def extractTagValue (self, tagID):
		for tag in self.tags:
			tagParts = tag.split(':', 2);
			if (tagParts[0] == tagID):
				if (tagParts[1] == 'i'):
					return int(tagParts[2]);
				elif (tagParts[1] == 'H'):
					return int(tagParts[2],16);
				return tagParts[2];
		return None;

#-----------------------------------------------
cigarPattern = '([0-9]+[MIDNSHP])'
cigarSearch = re.compile(cigarPattern)
atomicCigarPattern = '([0-9]+)([MIDNSHP])'
atomicCigarSearch = re.compile(atomicCigarPattern)

def extractCigarOps(cigar,flag):
	if (cigar == "*"):
		cigarOps = []
	elif (flag & 0x0010):
		cigarOpStrings = cigarSearch.findall(cigar)
		cigarOps = []
		for opString in cigarOpStrings:
			cigarOpList = atomicCigarSearch.findall(opString)
#			print cigarOpList
			# "struct" for the op and it's length
			cigar = cigarOp(cigarOpList[0][0], cigarOpList[0][1])
			# add to the list of cigarOps
			cigarOps.append(cigar)
			cigarOps = cigarOps
		cigarOps.reverse()
		##do in reverse order because negative strand##
	else:
		cigarOpStrings = cigarSearch.findall(cigar)
		cigarOps = []
		for opString in cigarOpStrings:
			cigarOpList = atomicCigarSearch.findall(opString)
			# "struct" for the op and it's length
			cigar = cigarOp(cigarOpList[0][0], cigarOpList[0][1])
			# add to the list of cigarOps
			cigarOps.append(cigar)
#			cigarOps = cigarOps
	return(cigarOps)

def calcQueryPosFromCigar(cigarOps):
	qsPos = 0
	qePos = 0
	qLen  = 0
	# if first op is a H, need to shift start position
	# the opPosition counter sees if the for loop is looking at the first index of the cigar object
	opPosition = 0
	for cigar in cigarOps:
		if opPosition == 0 and (cigar.op == 'H' or cigar.op == 'S'):
			qsPos += cigar.length
			qePos += cigar.length
			qLen  += cigar.length
		elif opPosition > 0 and (cigar.op == 'H' or cigar.op == 'S'):
			qLen  += cigar.length
		elif cigar.op == 'M' or cigar.op == 'I':
			qePos += cigar.length
			qLen  += cigar.length
			opPosition += 1
	d = queryPos(qsPos, qePos, qLen);
	return d

class cigarOp (object):
    """
    sturct to store a discrete CIGAR operations
    """
    def __init__(self, opLength, op):
        self.length = int(opLength)
        self.op     = op

class queryPos (object):
    """
    struct to store the start and end positions of query CIGAR operations
    """
    def __init__(self, qsPos, qePos, qLen):
        self.qsPos = int(qsPos)
        self.qePos = int(qePos)
        self.qLen  = int(qLen)


def calcQueryOverlap(s1,e1,s2,e2):
	o = 1 + min(e1, e2) - max(s1, s2)
	return max(0, o)

###############################################

class Usage(Exception):
	def __init__(self, msg):
		self.msg = msg

def main():

	usage = """%prog -i <file>
extractSplitReads_BwaMem v0.1.0
Author: Ira Hall
Description: Get split-read alignments from bwa-mem in lumpy compatible format. Ignores reads marked as duplicates.
Works on read or position sorted SAM input. Tested on bwa mem v0.7.5a-r405.
	"""
	parser = OptionParser(usage)

	parser.add_option("-i", "--inFile", dest="inFile",
		help="A SAM file or standard input (-i stdin).",
		metavar="FILE")
	parser.add_option("-n", "--numSplits", dest="numSplits", default=2, type = "int",
		help="The maximum number of split-read mappings to allow per read. Reads with more are excluded. Default=2",
		metavar="INT")
	parser.add_option("-d", "--includeDups", dest="includeDups", action="store_true",default=0,
		help="Include alignments marked as duplicates. Default=False")
	parser.add_option("-m", "--minNonOverlap", dest="minNonOverlap", default=20, type = "int",
		help="minimum non-overlap between split alignments on the query (default=20)",
		metavar="INT")
	(opts, args) = parser.parse_args()
	if opts.inFile is None:
		parser.print_help()
		print()
	else:
		try:
			extractSplitsFromBwaMem(opts.inFile, opts.numSplits, opts.includeDups, opts.minNonOverlap)
		except IOError as err:
			sys.stderr.write("IOError " + str(err) + "\n");
			return
if __name__ == "__main__":
	sys.exit(main())
