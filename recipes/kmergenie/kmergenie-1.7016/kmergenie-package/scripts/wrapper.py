# Enable to call KmerGenie from python
# used in GATB and AutoVelvet

import sys, os
from subprocess import call

def execute(program, cmdline="", interpreter=""):
    DIR = os.path.dirname(os.path.realpath(__file__))
    try:
        return call("%s %s/%s %s" % (interpreter, DIR, program, cmdline), shell=True)
    except OSError as e:
        print >>sys.stderr, "Execution of '%s' with command-line '%s' failed:" % (program, cmdline), e

def parse_kmergenie_results(output_folder="."):
    # getting genome size with histograms
    results = []
    with open( output_folder + '/histograms.dat') as f:
        f.next() # skip header
        for line in f:
            k, genome_size, cov_cutoff = [ int(x) if x.isdigit() else None for x in line.strip().split() ]
            results += [(genome_size, k, cov_cutoff)]
    return results

def all_k_values_fitted_or_not(output_folder="."):
    import glob, re
    prefix = output_folder + '/histograms'
    list_histograms = sorted(glob.glob(prefix+"-k*.histo"))
    k_values = []
    for histfile in list_histograms:    
        k = int(re.findall(r'\d+',histfile)[-1])
        k_values += [k]
    return k_values
    

def kmergenie(list_reads, output_folder=".", one_pass=False):

    print("running kmergenie")

    ret = execute('kmergenie', "%s %s" % (list_reads, "-o %s/histograms %s " % (output_folder, "--one-pass" if one_pass else "")))

    if ret:
        print("kmergenie could not detect a best k; aborting")
        sys.exit(1)

    results = parse_kmergenie_results(output_folder)
    genome_size, k, min_abundance = max(results)

    if genome_size == None:
        print("could not retrieve best k / genome size from kmergenie (examine %s/histograms.dat); aborting" % output_folder)
        sys.exit(1)

    print "best k from kmergenie:", k
    print "approximate genome size:", genome_size
    print "min abundance:", min_abundance

    return genome_size, k, min_abundance
