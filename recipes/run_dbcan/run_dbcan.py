#!/usr/bin/env python3
#########################################################
# dbCAN2 Driver Script (Stand Alone Version)
#
# Written by Tanner Yohe in the Yin Lab at NIU
# Revised by Le Huang in the Zhang Lab at NKU
# Updated by Mohamad Majd Raslan in the Yin Lab at NIU
# Updated by Wei Li created table
# Updated by Le Huang at NKU
# Last updated 09/08/19
# updated information[Le Huang]: 1. suitable for python3 users 2. fixed the bugs when the count of sequences is small.
# Accepts user input
# Predicts genes if needed
# Runs input against HMMER, DIAMOND, and Hotpep
# Optionally predicts CGCs with CGCFinder
# Creats an overview table using output files from core
# tools from Hotpep.out,hmmer.out and diamond.out
##########################################################
from subprocess import Popen, call, check_output
import os
import argparse
import sys


parser = argparse.ArgumentParser(description='dbCAN2 Driver Script')


parser.add_argument('inputFile', help='User input file. Must be in FASTA format.')
parser.add_argument('inputType', choices=['protein', 'prok', 'meta'], help='Type of sequence input. protein=proteome; prok=prokaryote; meta=metagenome') #protein=proteome, prok=prokaryote nucleotide, meta=metagenome nucleotide
parser.add_argument('--cluster', '-c', help='Predict CGCs via CGCFinder. This argument requires an auxillary locations file if a protein input is being used')
parser.add_argument('--dbCANFile',default="dbCAN.txt", help='Indicate the file name of HMM database such as dbCAN.txt, please use the newest one from dbCAN2 website.')
parser.add_argument('--dia_eval', default=1e-102,type=float, help='DIAMOND E Value')
parser.add_argument('--dia_cpu', default=2, type=int, help='Number of CPU cores that DIAMOND is allowed to use')
parser.add_argument('--hmm_eval', default=1e-15, type=float, help='HMMER E Value')
parser.add_argument('--hmm_cov', default=0.35, type=float, help='HMMER Coverage val')
parser.add_argument('--hmm_cpu', default=1, type=int, help='Number of CPU cores that HMMER is allowed to use')
parser.add_argument('--hotpep_hits', default=6, type=int, help='Hotpep Hit value')
parser.add_argument('--hotpep_freq', default=2.6, type=float, help='Hotpep Frequency value')
parser.add_argument('--hotpep_cpu', default=3, type=int, help='Number of CPU cores that Hotpep is allowed to use')
parser.add_argument('--tf_eval', default=1e-4, type=float, help='tf.hmm HMMER E Value')
parser.add_argument('--tf_cov', default=0.35, type=float, help='tf.hmm HMMER Coverage val')
parser.add_argument('--tf_cpu', default=1, type=int, help='tf.hmm Number of CPU cores that HMMER is allowed to use')
parser.add_argument('--stp_eval', default=1e-4, type=float, help='stp.hmm HMMER E Value')
parser.add_argument('--stp_cov', default=0.3, type=float, help='stp.hmm HMMER Coverage val')
parser.add_argument('--stp_cpu', default=1, type=int, help='stp.hmm Number of CPU cores that HMMER is allowed to use')
parser.add_argument('--out_pre', default="", help='Output files prefix')
parser.add_argument('--out_dir', default="output", help='Output directory')
parser.add_argument('--db_dir', default="db/", help='Database directory')
parser.add_argument('--cgc_dis', default=2, help='CGCFinder Distance value')
parser.add_argument('--cgc_sig_genes', default='tp', choices=['tp', 'tf','all'], help='CGCFinder Signature Genes value')
parser.add_argument('--tools', '-t', nargs='+', choices=['hmmer', 'diamond', 'hotpep', 'all'], default='all', help='Choose a combination of tools to run')
parser.add_argument('--use_signalP', default=False, type=bool, help='Use signalP or not, remember, you need to setup signalP tool first. Because of signalP license, Docker version does not have signalP.')
args = parser.parse_args()

'''
def some functions
'''
def runHmmScan(outPath, hmm_cpu, dbDir, hmm_eval, hmm_cov, db_name):
    hmmer = Popen(['hmmscan', '--domtblout', '%sh%s.out' % (outPath, db_name), '--cpu', hmm_cpu, '-o', '/dev/null', '%s%s.hmm' % (dbDir,db_name), '%suniInput' % outPath])
    hmmer.wait()
    call('hmmscan-parser.py %sh%s.out %s %s > %s%s.out'%(outPath, db_name, hmm_eval, hmm_cov, outPath, db_name), shell=True)
    if os.path.exists('%sh%s.out' % (outPath, db_name)):
        call(['rm', '%sh%s.out' % (outPath, db_name)])

####
#run_dbcan.py [inputFile] [inputType]
####

##########################
# Begin Setup and Input Checks

dbDir = args.db_dir
prefix = args.out_pre
outDir = args.out_dir

if not dbDir.endswith("/") and len(dbDir) > 0:
    dbDir += "/"

if not outDir.endswith("/") and len(outDir) > 0:
    outDir += "/"

outPath = outDir + prefix
auxFile = ""
input = args.inputFile
inputType = args.inputType
find_clusters = False
if args.cluster != None:
    find_clusters = True
    if inputType == "protein":
        auxFile = args.cluster
    else:
        auxFile = '%sprodigal.gff'%outPath

if not os.path.isdir(dbDir):
    print(dbDir , "ERROR: The database directory does not exist")
    exit()

if not os.path.isfile(dbDir+'CAZy.dmnd'):
    print("ERROR: No CAZy DIAMOND database found. \
    Please make sure that your CAZy DIAMOND databased is named 'CAZy.dmnd' and is located in your database directory")
    exit()

if not os.path.isfile(dbDir + args.dbCANFile):
    print("ERROR: No dbCAN HMM database found. \
    Please make sure that your dbCAN HMM database is named 'dbCAN-HMMdb-V7.txt' or the newest one, has been through hmmpress, and is located in your database directory")
    exit()

if not os.path.isdir(outDir):
    call(['mkdir', outDir])

if find_clusters and inputType == "protein":
    if len(auxFile) > 0:
        print(auxFile)
        if not os.path.isfile(auxFile):
                print("ERROR: It seems that the auxillary filename that you provided does not exist, or is not a file")
                exit()
    else:
        print("ERROR: Please provide an auxillary input file with the position of each gene. This file can either be in BED or GFF format")
        exit()
tools = [True, True, True] #DIAMOND, HMMER, Hotpep
if args.tools != 'all':
    if 'diamond' not in args.tools:
        tools[0] = False
    if 'hmmer' not in args.tools:
        tools[1] = False
    if 'hotpep' not in args.tools:
        tools[2] = False


# End Setup and Input Checks
#########################
# Begin Gene Prediction Tools


if inputType == 'prok':
    call(['prodigal', '-i', input, '-a', '%suniInput'%outPath, '-o', '%sprodigal.gff'%outPath, '-f', 'gff', '-q'])
if inputType == 'meta':
    # call(['FragGeneScan1.30/run_FragGeneScan.pl', '-genome='+input, '-out=%sfragGeneScan'%outPath, '-complete=1', '-train=complete', '-thread=10'])
    call(['FragGeneScan', '-s', input, '-o', '%sfragGeneScan'%outPath, '-w 1','-t comlete', '-p 10'])

#Frag Gene Scan
if inputType == 'meta':
    call(['cp', '%sfragGeneScan.faa'%outPath, '%suniInput'%outPath])

#Proteome
if inputType == 'protein':
    call(['cp', input, '%suniInput'%outPath])

# End Gene Prediction Tools
#######################
# Begin SignalP
if args.use_signalP:
    print("***************************0. SIGNALP start*************************************************\n\n")
    signalpos = Popen('signalp -t gram+ %suniInput > %ssignalp.neg' % (outPath, outPath), shell=True)
    signalpneg = Popen('signalp -t gram- %suniInput > %ssignalp.pos' % (outPath, outPath), shell=True)

# End SignalP
#######################
# Begin Core Tools

if tools[0]:
    print("***************************1. DIAMOND start*************************************************\n\n")
    diamond = Popen(['diamond', 'blastp', '-d', '%sCAZy.dmnd' % dbDir, '-e', str(args.dia_eval), '-q', '%suniInput' % outPath, '-k', '1', '-p', str(args.dia_cpu), '-o', '%sdiamond.out'%outPath, '-f', '6'])

if tools[1]:
    print("***************************2. HMMER start*************************************************\n\n")
    hmmer = Popen(['hmmscan', '--domtblout', '%sh.out' % outPath, '--cpu', str(args.hmm_cpu), '-o', '/dev/null', '%s%s' % (dbDir,args.dbCANFile), '%suniInput' % outPath])

if tools[2]:
    count = int(check_output("tr -cd '>' < %suniInput | wc -c" % outPath, shell=True))    #number of genes in input file
    # numThreads = args.hotpep_cpu
    numThreads = args.hotpep_cpu if count >= args.hotpep_cpu else count                     #number of cores for Hotpep to use, revised by Le Huang 12/17/2018
    count_per_file = count / numThreads                                                #number of genes per core
    inter = input.split('/')[-1]
    directory = inter.split('.')[0]
    if not os.path.exists('Hotpep/%s' % directory):
        os.makedirs('Hotpep/%s' % directory)
    num_files = 1
    num_genes = 0
    out = open("Hotpep/%s/orfs%s.txt" % (directory, str(num_files)), 'w')
    with open('%suniInput' % outPath, 'r') as f:
        for line in f:
            if line.startswith(">"):
                num_genes += 1
                if num_genes > count_per_file and num_files != numThreads:
                    out.close()
                    num_files += 1
                    num_genes = 0
                    out = open("Hotpep/"+directory+"/orfs"+str(num_files)+".txt", 'w')
            out.write(line)

    os.chdir('Hotpep/')
    print("\n***************************3. HotPep start***************************************************\n\n")
    hotpep = Popen(['train_many_organisms_many_families.py', directory, str(numThreads), str(args.hotpep_hits), str(args.hotpep_freq)])
    os.chdir('../')

if tools[0]:
    diamond.wait()
    print("***************************1. DIAMOND end***************************************************")
if tools[1]:
    hmmer.wait()
    print("***************************2. HMMER end***************************************************")
    call('hmmscan-parser.py %sh.out %s %s > %shmmer.out'%(outPath, str(args.hmm_eval), str(args.hmm_cov), outPath), shell=True)
    if os.path.exists('%sh.out' % outPath):
        call(['rm', '%sh.out' % outPath])
if tools[2]:
    hotpep.wait()
    print("***************************3. hotPep end***************************************************")
    hotpepDir = 'Hotpep/'+directory
    call(['cp', '%s/Results/output.txt' % hotpepDir, '%sHotpep.out' % outPath])

# End Core Tools
########################
# Begin Adding Column Headers

if tools[2]:
    with open(outPath+'Hotpep.out') as f:
        with open(outPath+'temp', 'w') as out:
            out.write('CAZy Family\tPPR Subfamily\tGene ID\tFrequency\tHits\tSignature Peptides\n')
            for line in f:
                out.write(line)
    call(['mv', outPath+'temp', outPath+'Hotpep.out'])
if tools[1]:
    with open(outDir+prefix+'hmmer.out') as f:
        with open(outDir+prefix+'temp', 'w') as out:
            out.write('HMM Profile\tProfile Length\tGene ID\tGene Length\tE Value\tProfile Start\tProfile End\tGene Start\tGene End\tCoverage\n')
            for line in f:
                out.write(line)
    call(['mv', outDir+prefix+'temp', outDir+prefix+'hmmer.out'])
if tools[0]:
    with open(outDir+prefix+'diamond.out') as f:
        with open(outDir+prefix+'temp', 'w') as out:
            out.write('Gene ID\tCAZy ID\t% Identical\tLength\tMismatches\tGap Open\tGene Start\tGene End\tCAZy Start\tCAZy End\tE Value\tBit Score\n')
            for line in f:
                out.write(line)
    call(['mv', outDir+prefix+'temp', outDir+prefix+'diamond.out'])

# End Adding Column Headers
########################
# Begin CGCFinder

if find_clusters:
    print("*****************************CGC-Finder start************************************")

########################
# Begin TF,TP, STP prediction
    '''
    previous tf_v1 uses diamond, tf_v2 uses hmmer
    tf hmmer 
    '''
    #call(['diamond', 'blastp', '-d', dbDir+'tf_v1/tf.dmnd', '-e', '1e-10', '-q', '%suniInput' % outPath, '-k', '1', '-p', '1', '-o', outDir+prefix+'tf.out', '-f', '6'])
    runHmmScan(outPath, str(args.tf_cpu), dbDir, str(args.tf_eval), str(args.tf_cov), "tf-1")
    runHmmScan(outPath, str(args.tf_cpu), dbDir, str(args.tf_eval), str(args.tf_cov), "tf-2")
    '''
    stp
    '''

    # call(['hmmscan', '--domtblout', '%shstp.out' % outPath, '--cpu', str(args.hmm_cpu), '-o', '/dev/null', '%sstp.hmm' % dbDir, '%suniInput' % outPath])
    # call('hmmscan-parser.py %shstp.out %s %s > %sstp.out'%(outPath, str(args.hmm_eval), str(args.hmm_cov), outPath), shell=True)
    # if os.path.exists('%shstp.out' % outPath):
    #     call(['rm', '%shstp.out' % outPath])
    runHmmScan(outPath, str(args.stp_cpu), dbDir, str(args.stp_eval), str(args.stp_cov), "stp")
    
    '''
    tp diamond
    '''
    call(['diamond', 'blastp', '-d', dbDir+'tcdb.dmnd', '-e', '1e-10', '-q', '%suniInput' % outPath, '-k', '1', '-p', '1', '-o', outDir+prefix+'tp.out', '-f', '6'])

    
    tp = set()
    tf = set()
    stp = set()

    tp_genes = {}
    tf_genes = {}
    stp_genes = {}
    # with open(outDir+prefix+'tf.out') as f:
    #     for line in f:
    #         row = line.rstrip().split('\t')
    #         tf.add(row[0])
    #         if not row[0] in tf_genes:
    #             tf_genes[row[0]] = row[1]
    #         else:
    #             tf_genes[row[0]] += ','+row[1]

    with open("%stf-1.out" % outPath) as f:
        for line in f:
            row = line.rstrip().split('\t')
            tf.add(row[2])
            row[0] = "DBD-Pfam|" + row[0]
            if not row[2] in tf_genes:
                tf_genes[row[2]] = row[0]
            else:
                tf_genes[row[2]] += ',' + row[0]

    with open("%stf-2.out" % outPath) as f:
        for line in f:
            row = line.rstrip().split('\t')
            tf.add(row[2])
            row[0] = "DBD-SUPERFAMILY|" + row[0]
            if not row[2] in tf_genes:
                tf_genes[row[2]] = row[0]
            else:
                tf_genes[row[2]] += ',' + row[0]

    with open(outDir+prefix+'tp.out') as f:
        for line in f:
            row = line.rstrip().split('\t')
            tp.add(row[0])
            if not row[0] in tp_genes:
                tp_genes[row[0]] = row[1]
            else:
                tp_genes[row[0]] += ','+row[1]

    with open("%sstp.out" % outPath) as f:
        for line in f:
            row = line.rstrip().split('\t')
            stp.add(row[2])
            row[0] = "STP|" + row[0]
            if not row[2] in stp_genes:
                stp_genes[row[2]] = row[0]
            else:
                stp_genes[row[2]] += ',' + row[0]
# End TF and TP prediction
##########################
# Begine CAZyme Extraction
    cazyme_genes = {}
    dia = set()
    hot = set()
    hmm = set()
    if tools[0]:
        with open(outDir+prefix+'diamond.out') as f:
            next(f)
            for line in f:
                row = line.rstrip().split('\t')
                dia.add(row[0])
                if row[0] not in cazyme_genes:
                    cazyme_genes[row[0]] = set()
                cazyme_genes[row[0]].add(row[1].split('|')[1])
    if tools[1]:
        with open(outDir+prefix+'hmmer.out') as f:
            next(f)
            for line in f:
                row = line.rstrip().split('\t')
                hmm.add(row[2])
                if row[2] not in cazyme_genes:
                    cazyme_genes[row[2]] = set()
                cazyme_genes[row[2]].add(row[0].split('.')[0])
    if tools[2]:
        with open(outDir+prefix+'Hotpep.out') as f:
            next(f)
            for line in f:
                row = line.rstrip().split('\t')
                hot.add(row[2])
                if row[2] not in cazyme_genes:
                    cazyme_genes[row[2]] = set()
                cazyme_genes[row[2]].add(row[0])
    if tools.count(True) > 1:
        temp1 = hmm.intersection(hot)
        temp2 = hmm.intersection(dia)
        temp3 = dia.intersection(hot)
        cazyme = temp1.union(temp2, temp3)
    else:
        cazyme = hmm.union(dia, hot)
# End CAZyme Extraction
######################
# Begin GFF preperation

    if inputType == "prok":   #use Prodigal GFF output
        with open(outDir+prefix+'prodigal.gff') as f:
            with open(outDir+prefix+'cgc.gff', 'w') as out:
                for line in f:
                    if not line.startswith("#"):
                        row = line.rstrip().split('\t')
                        num = row[-1].split(";")[0].split('_')[-1]
                        gene = row[0] + '_' + num
                        row[8] = ""
                        if gene in tf:
                            row[2] = "TF"
                            row[8] = "DB="+tf_genes[gene]
                        elif gene in tp:
                            row[2] = "TC"
                            row[8] = "DB="+tp_genes[gene]
                        elif gene in cazyme:
                            row[2] = "CAZyme"
                            row[8] = "DB="+'|'.join(cazyme_genes[gene])
                        elif gene in stp:
                            row[2] = "STP"
                            row[8] = "DB="+stp_genes[gene]
                        row[8] += ";ID="+gene
                        out.write('\t'.join(row)+'\n')


    elif inputType == "meta":  #use FragGeneScan GFF output
        with open(outDir+prefix+'fragGeneScan.gff') as f:
            with open(outDir+prefix+'cgc.gff', 'w') as out:
                for line in f:
                    if not line.startswith("#"):
                        row = line.rstrip().split('\t')
                        gene = row[-1].split(";")[0].split("=")[1]
                        if gene in tf:
                            row[2] = "TF"
                            row.insert(8, "DB=" + tf_genes[gene])
                        elif gene in tp:
                            row[2] = "TC"
                            row.insert(8, "DB=" + tp_genes[gene])
                        elif gene in stp:
                            row[2] = "STP"
                            row.insert(8, "DB=" + stp_genes[gene])
                        elif gene in cazyme:
                            row[2] = "CAZyme"
                            row.insert(8, "DB="+'|'.join(cazyme_genes[gene]))
                        else:
                            row.insert(8, "")
                        row[8] += ";ID="+gene
                        out.write('\t'.join(row)+'\n')
    else:  #user provided GFF/BED file
        gff = False
        with open(auxFile) as f:
            for line in f:
                if not line.startswith('#'):
                    if len(line.split('\t')) == 9:
                        gff = True
                        break
        if gff:  #user file was in GFF format
            with open(auxFile) as f:
                with open(outDir+prefix+'cgc.gff', 'w') as out:
                    for line in f:
                        if not line.startswith("#"):
                            row = line.rstrip().split('\t')
                            if row[2] == "CDS":
                                note = row[8].split(";")
                                gene = ""
                                notes = {}
                                for x in note:
                                    temp = x.split('=')
                                    notes[temp[0]] = temp[1]
                                if "Name" in notes:
                                    gene = notes["Name"]
                                elif "ID" in notes:
                                    gene = notes["ID"]
                                else:
                                    continue
                                if gene in tf:
                                    row[2] = "TF"
                                    row[8] = "DB="+tf_genes[gene]
                                elif gene in tp:
                                    row[2] = "TC"
                                    row[8] = "DB="+tp_genes[gene]
                                elif gene in stp:
                                    row[2] = "STP"
                                    row[8] = "DB=" + stp_genes[gene]
                                elif gene in cazyme:
                                    row[2] = "CAZyme"
                                    row[8] = "DB="+'|'.join(cazyme_genes[gene])
                                else:
                                    row[8] = ""
                                row[8] += ";ID="+gene
                                out.write('\t'.join(row)+'\n')
        else:  #user file was in BED format
            with open(auxFile) as f:
                with open(outDir+prefix+'cgc.gff', 'w') as out:
                    for line in f:
                        if line.startswith("track"):
                            continue
                        row = line.rstrip().split('\t')
                        outrow = ['.','.','.','.','.','.','.','.','']
                        gene = row[1]
                        if gene in tf:
                            outrow[2] = 'TF'
                            outrow[8] =  "DB="+tf_genes[gene]
                        elif gene in tp:
                            outrow[2] = 'TC'
                            outrow[8] = "DB="+tp_genes[gene]
                        elif gene in stp:
                            outrow[2] = 'STP'
                            outrow[8] = "DB=" + stp_genes[gene]
                        elif gene in cazyme:
                            outrow[2] = 'CAZyme'
                            outrow[8] = "DB="+'|'.join(cazyme_genes[gene])
                        else:
                            outrow[2] = 'CDS'
                        outrow[0] = row[0]
                        outrow[3] = row[2]
                        outrow[4] = row[3]
                        outrow[6] = row[4]
                        outrow[8] += ";ID="+gene
                        out.write('\t'.join(outrow)+'\n')
# End GFF preperation
####################
# Begin CGCFinder call

    call(['CGCFinder.py', outDir+prefix+'cgc.gff', '-o', outDir+prefix+'cgc.out', '-s', args.cgc_sig_genes, '-d', str(args.cgc_dis)])
    print("**************************************CGC-Finder end***********************************************")

# End CGCFinder call
# End CGCFinder
####################
# Begin SignalP combination
if args.use_signalP:
    print("Waiting on signalP")
    signalpos.wait()
    signalpneg.wait()
    print("SignalP complete")
    with open(outDir+prefix+'temp', 'w') as out:
        with open(outDir+prefix+'signalp.pos') as f:
            for line in f:
                if not line.startswith('#'):
                    row = line.split(' ')
                    row = [x for x in row if x != '']
                    if row[9] == 'Y':
                        out.write(line)
        with open(outDir+prefix+'signalp.neg') as f:
            for line in f:
                if not line.startswith('#'):
                    row = line.split(' ')
                    row = [x for x in row if x != '']
                    if row[9] == 'Y':
                        out.write(line)
    call('sort -u '+outDir+prefix+'temp > '+outDir+prefix+'signalp.out', shell=True)
    call(['rm', outDir+prefix+'temp', outDir+prefix+'signalp.pos', outDir+prefix+'signalp.neg'])

# End SignalP combination
#######################
#######################
# Start "blastation.py" to produce overview.txt
print ("Preparing overview table from hmmer, hotpep and diamond output...")
workdir= outDir+prefix

evalue = 1e-2

# a function to remove duplicates from lists while keeping original order
def unique(seq):
    exists = set()
    return [x for x in seq if not (x in exists or exists.add(x))]

# check that files exist. if so, read files and get the gene numbers
if(os.path.exists(workdir+"diamond.out")):
    arr_diamond = open(workdir+"diamond.out").readlines()
    diamond_genes = []
    for i in range(1,len(arr_diamond)):
        row = arr_diamond[i].split()
        diamond_genes.append(row[0])

if(os.path.exists(workdir+"Hotpep.out")):
    arr_hotpep = open(workdir+"Hotpep.out").readlines()
    hotpep_genes = []
    for i in range(1,len(arr_hotpep)):
        row = arr_hotpep[i].split()
        hotpep_genes.append(row[2])

if(os.path.exists(workdir+"hmmer.out")):
    arr_hmmer = open(workdir+"hmmer.out").readlines()
    hmmer_genes = []
    for i in range (1,len(arr_hmmer)):
        row = arr_hmmer[i].split()
        hmmer_genes.append(row[2])

if args.use_signalP and (os.path.exists(workdir + "signalp.out")):
    arr_sigp = open(workdir+"signalp.out").readlines()
    sigp_genes = {}
    for i in range (2,len(arr_sigp)):
        row = arr_sigp[i].split()
        sigp_genes[row[0]]=row[2]

##Catie Ausland edits BEGIN, Le add variable exists or not, remove duplicates from input lists
if len(hotpep_genes) > 0:
    if (hotpep_genes[len(hotpep_genes)-1] == None):
        hotpep_genes.pop()
        hotpep_genes = unique(hotpep_genes)
        if 'hmmer_genes' in locals():
            hmmer_genes.pop()
            hmmer_genes = unique(hmmer_genes)
        if 'diamond_genes' in locals():
            diamond_genes.pop()
            diamond_genes = unique(diamond_genes)
## Catie edits END, Le add variable exists or not, remove duplicates from input lists

# parse input, stroe needed variables
if(arr_diamond != None):
    diamond_fams = {}
    for i in range (1,len(arr_diamond)):
        row = arr_diamond[i].split("\t")
        fam = row[1].split("|")
        diamond_fams[row[0]] = fam[1]

if(arr_hmmer !=None):
    hmmer_fams = {}
    for i in range (len(arr_hmmer)):
        row = arr_hmmer[i].split("\t")
        fam = row[0].split(".")
        fam = fam[0]+"("+row[7]+"-"+row[8]+")"
        if(row[2] not in hmmer_fams):
            hmmer_fams[row[2]] = []

        hmmer_fams[row[2]].append(fam)

if(arr_hotpep != None) :
    hotpep_fams = {}
    for i in range (1,len(arr_hotpep)):
        row = arr_hotpep[i].split("\t")
        if(row[2] not in hotpep_fams):
            hotpep_fams[row[2]] = []

        hotpep_fams[row[2]].append(row[0])

#overall table
if not tools[0]:
    diamond_genes =[]
if not tools[1]:
    hmmer_genes   = []
if not tools[2]:
    hotpep_genes  =[]
    

all_genes = unique(hmmer_genes+hotpep_genes+diamond_genes)
overall_table = []
with open(workdir+"overview.txt", 'w+') as fp:
    if args.use_signalP:
        fp.write("Gene ID\tHMMER\tHotpep\tDIAMOND\tSignalp\t#ofTools\n")
    else:
        fp.write("Gene ID\tHMMER\tHotpep\tDIAMOND\t#ofTools\n")
    for gene in all_genes:
        hits = {"diamond" : "N", "hmmer" : "N", "hotpep" : "N", "tools" : 0}
        if args.use_signalP:
            hits["signalP" : "N"]
        csv = ["gene", "N", "N", "N", "N", 0]
        csv[0] = gene
        if(arr_hmmer != None):
            if gene in hmmer_genes:
                csv[5]+=1
                hits["tools"]+=1
                txt = []
                for i in range(len(hmmer_fams[gene])):
                    txt.append(hmmer_fams[gene][i])
                    temp = hmmer_fams[gene][i].split("(")
                    hmmer_fams[gene][i] = ("(").join(temp)
                hmmer_fams[gene] = ("+").join(hmmer_fams[gene])
                hits["hmmer"] = hmmer_fams[gene]
                csv[1] = ("+").join(txt)
        else:

            csv[1] = "-"
            hits["hmmer"] = "-"

        if(arr_hotpep!= None):
            if( gene in hotpep_genes):
                csv[5]+=1
                hits["tools"]+=1
                temp = []
                if gene in hotpep_fams:
                    for i in range(len(hotpep_fams[gene])):
                        temp.append(hotpep_fams[gene][i])

                    hits["hotpep"] = ("+").join(hotpep_fams[gene])
                    csv[2] = ("+").join(temp)
        else:
            csv[2] = "-"
            hits["hotpep"] = "-"

        if(arr_diamond != None):
            if(gene in diamond_genes):
                csv[5]+=1
                hits["tools"]+=1
                fams = diamond_fams[gene].split("+")
                hits["diamond"] = ""
                csv[3] = diamond_fams[gene]

        else:
            csv[3] = "-"
            hits["diamond"] = "-"

        if args.use_signalP==True and gene in sigp_genes :
            hits["signalp"] = "Y (1-"+sigp_genes[gene]+")"
            csv[4] = "Y(1-"+sigp_genes[gene]+")"


        else:
            hits["geneID"] = gene
        overall_table.append(hits)


        temp = "\t".join(str(x) for x in csv) + "\n"
        fp.write(temp)

print ("overview table complete. Saved as "+workdir+"overview.txt")
# End "blastation.py" to produce overview.txt
# End script

