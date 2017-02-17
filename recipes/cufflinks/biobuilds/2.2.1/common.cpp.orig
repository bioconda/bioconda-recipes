/*
 *  common.cpp
 *  cufflinks
 *
 *  Created by Cole Trapnell on 3/23/09.
 *  Copyright 2008 Cole Trapnell. All rights reserved.
 *
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <iostream>
#include <stdarg.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <libgen.h>
#include <string.h>

#include "getopt.h"
#include "common.h"
#include "replicates.h"

using namespace std;


// Non-option globals
bool final_est_run = true;
bool allow_junk_filtering = true;
bool user_provided_fld = false;

// Behavior options
int num_threads = 1;
bool no_update_check = false;
bool cuff_quiet = false;
#if ASM_VERBOSE
bool cuff_verbose = true;
#else
bool cuff_verbose = false;
#endif
bool output_fld = false;
bool output_bias_params = false;

// General options
BundleMode bundle_mode = HIT_DRIVEN;
BundleMode init_bundle_mode = HIT_DRIVEN;
int max_partner_dist = 50000;
uint32_t max_gene_length = 3500000;
std::string ref_gtf_filename = "";
std::string mask_gtf_filename = "";
std::string contrast_filename = "";
bool use_sample_sheet = false;
std::string norm_standards_filename = "";
std::string output_dir = "./";
std::string fasta_dir;
string default_library_type = "fr-unstranded";
string library_type = default_library_type;


// Abundance estimation options
bool corr_bias = false;
bool corr_multi = false;

BiasMode bias_mode = VLMM;
int def_frag_len_mean = 200;
int def_frag_len_std_dev = 80;
int def_max_frag_len = 800;
int max_frag_len = 800;
int min_frag_len = 1;
float min_isoform_fraction = 0.1;
int max_mle_iterations = 5000;
int num_importance_samples = 10000;
bool use_compat_mass = false;
bool use_total_mass = false;
bool model_mle_error = false;

// Ref-guided assembly options
int overhang_3 = 600;
int ref_merge_overhang_tolerance = 30;
int tile_len = 405;
int tile_off = 15;
bool enable_faux_reads = true;
bool enable_5_extend = true;

// Assembly options
uint32_t min_intron_length = 50;
uint32_t max_intron_length = 300000;
int olap_radius = 50;
int bowtie_overhang_tolerance = 8; // Typically don't need to change this, except in special cases, such as meta-assembly.
int min_frags_per_transfrag = 10;
int microexon_length = 25;
float pre_mrna_fraction = 0.15;
float high_phred_err_prob = 0.50; // about MAPQ = 3
double small_anchor_fraction = 7 / 75.0;
double binomial_junc_filter_alpha = 0.001;
double trim_3_dropoff_frac = .1;
double trim_3_avgcov_thresh = 10.0;
std::string user_label = "CUFF";

bool cond_prob_collapse = true;

bool emit_count_tables = false;
bool use_fisher_covariance = true;
bool split_variance = false;
bool bootstrap = true;
int num_bootstrap_samples = 20;
double bootstrap_fraction = 1.0;
double bootstrap_delta_gap = 0.001;
int max_frags_per_bundle = 1000000;
//bool analytic_diff = false;
bool no_differential = false;
double num_frag_count_draws = 100;
double num_frag_assignments = 50;
double max_multiread_fraction = 0.75;
double max_frag_multihits = 10000000;
int min_reps_for_js_test = 3;
bool no_effective_length_correction = false;
bool no_length_correction = false;
bool no_js_tests = false;

bool no_scv_correction = false;

double min_outlier_p = 0.0001;


// SECRET OPTIONS: 
// These options are just for instrumentation and benchmarking code

float read_skip_fraction = 0.0;
bool no_read_pairs = false;
int trim_read_length = -1;
double mle_accuracy = 1e-5;




// END SECRET OPTIONS

bool bias_run = false;

std::string cmd_str;

map<string, ReadGroupProperties> library_type_table;
const ReadGroupProperties* global_read_properties = NULL;

map<string, DispersionMethod> dispersion_method_table;
string default_dispersion_method = "pooled";
DispersionMethod dispersion_method = DISP_NOT_SET;

map<string, LibNormalizationMethod> lib_norm_method_table;
string default_lib_norm_method = "geometric";
string default_cufflinks_lib_norm_method = "classic-fpkm";
LibNormalizationMethod lib_norm_method = LIB_NORM_NOT_SET;

boost::shared_ptr<const std::map<std::string, LibNormStandards> > lib_norm_standards;

// Output format table for Cuffnorm:
map<string, OutputFormat> output_format_table;
string default_output_format = "simple-table"; // note: the default is only for cuffnorm, Cuffdiff always uess the cuffdiff format
OutputFormat output_format = OUTPUT_FMT_NOT_SET;


#if ENABLE_THREADS
boost::thread_specific_ptr<std::string> bundle_label;
#else
boost::shared_ptr<std::string> bundle_label;
#endif

long random_seed = 0;

extern void print_usage();

bool gaurd_assembly()
{
	return ref_gtf_filename == "";
}

void asm_verbose(const char* fmt,...)
{
#if !ASM_VERBOSE
	return;
#endif
     va_list argp;
     va_start(argp, fmt);
     vfprintf(stderr, fmt, argp);
     va_end(argp);
}

void verbose_msg(const char* fmt,...) {

	if (!cuff_verbose)
		return;
	
   va_list argp;
   va_start(argp, fmt);
   vfprintf(stderr, fmt, argp);
   va_end(argp);
}


/**
 * Parse an int out of optarg and enforce that it be at least 'lower';
 * if it is less than 'lower', than output the given error message and
 * exit with an error and a usage message.
 */
 

int parseInt(int lower, const char *errmsg, void (*print_usage)()) {
    long l;
    char *endPtr= NULL;
    l = strtol(optarg, &endPtr, 10);
    if (endPtr != NULL) {
        if (l < lower) {
            cerr << errmsg << endl;
            print_usage();
            exit(1);
        }
        return (int32_t)l;
    }
    cerr << errmsg << endl;
    print_usage();
    exit(1);
    return -1;
}

/**
 * Parse an int out of optarg and enforce that it be at least 'lower';
 * if it is less than 'lower', than output the given error message and
 * exit with an error and a usage message.
 */
float parseFloat(float lower, float upper, const char *errmsg, void (*print_usage)()) {
    float l;
    l = (float)atof(optarg);
	
    if (l < lower) {
        cerr << errmsg << endl;
        print_usage();
        exit(1);
    }
	
    if (l > upper)
    {
        cerr << errmsg << endl;
        print_usage();
        exit(1);
    }
	
    return l;
	
    cerr << errmsg << endl;
    print_usage();
    exit(1);
    return -1;
}

/* Function with behaviour like `mkdir -p'  */
/* found at: http://niallohiggins.com/2009/01/08/mkpath-mkdir-p-alike-in-c-for-unix/ */

int mkpath(const char *s, mode_t mode)
{
    char *q, *r = NULL, *path = NULL, *up = NULL;
    int rv;
    
    rv = -1;
    if (strcmp(s, ".") == 0 || strcmp(s, "/") == 0)
        return (0);
    
    if ((path = strdup(s)) == NULL)
        exit(1);
    
    if ((q = strdup(s)) == NULL)
        exit(1);
    
    if ((r = dirname(q)) == NULL)
        goto out;
    
    if ((up = strdup(r)) == NULL)
        exit(1);
    
    if ((mkpath(up, mode) == -1) && (errno != EEXIST))
        goto out;
    
    if ((mkdir(path, mode) == -1) && (errno != EEXIST))
        rv = -1;
    else
        rv = 0;
    
out:
    if (up != NULL)
        free(up);
    free(q);
    free(path);
    return (rv);
}

void init_library_table()
{
    ReadGroupProperties fr_unstranded;
    fr_unstranded.platform(UNKNOWN_PLATFORM);
	fr_unstranded.mate_strand_mapping(FR);
    fr_unstranded.std_mate_orientation(MATES_POINT_TOWARD);
    fr_unstranded.strandedness(UNSTRANDED_PROTOCOL);
    
    library_type_table["fr-unstranded"] = fr_unstranded;
        	
	ReadGroupProperties fr_firststrand;
    fr_firststrand.platform(UNKNOWN_PLATFORM);
	fr_firststrand.mate_strand_mapping(RF);
    fr_firststrand.std_mate_orientation(MATES_POINT_TOWARD);
    fr_firststrand.strandedness(STRANDED_PROTOCOL);
	
    library_type_table["fr-firststrand"] = fr_firststrand;

	ReadGroupProperties fr_secondstrand;
    fr_secondstrand.platform(UNKNOWN_PLATFORM);
	fr_secondstrand.mate_strand_mapping(FR);
    fr_secondstrand.std_mate_orientation(MATES_POINT_TOWARD);
    fr_secondstrand.strandedness(STRANDED_PROTOCOL);
	
    library_type_table["fr-secondstrand"] = fr_secondstrand;
	
	ReadGroupProperties ff_unstranded;
    ff_unstranded.platform(UNKNOWN_PLATFORM);
	ff_unstranded.mate_strand_mapping(FF);
    ff_unstranded.std_mate_orientation(MATES_POINT_TOWARD);
    ff_unstranded.strandedness(UNSTRANDED_PROTOCOL);
    
    library_type_table["ff-unstranded"] = ff_unstranded;
	
	ReadGroupProperties ff_firststrand;
    ff_firststrand.platform(UNKNOWN_PLATFORM);
	ff_firststrand.mate_strand_mapping(FF);
    ff_firststrand.std_mate_orientation(MATES_POINT_TOWARD);
    ff_firststrand.strandedness(STRANDED_PROTOCOL);
	
    library_type_table["ff-firststrand"] = ff_firststrand;
	
	ReadGroupProperties ff_secondstrand;
    ff_secondstrand.platform(UNKNOWN_PLATFORM);
	ff_secondstrand.mate_strand_mapping(RR);
    ff_secondstrand.std_mate_orientation(MATES_POINT_TOWARD);
    ff_secondstrand.strandedness(STRANDED_PROTOCOL);
	
    library_type_table["ff-secondstrand"] = ff_secondstrand;
    
    ReadGroupProperties transfrags;
    transfrags.platform(UNKNOWN_PLATFORM);
	transfrags.mate_strand_mapping(FR);
    transfrags.std_mate_orientation(MATES_POINT_TOWARD);
    transfrags.strandedness(UNSTRANDED_PROTOCOL);
	transfrags.complete_fragments(true);
    
    library_type_table["transfrags"] = transfrags;
	
    //global_read_properties = &(library_type_table.find(default_library_type)->second);
}

void print_library_table()
{
    fprintf (stderr, "\nSupported library types:\n");
    for (map<string, ReadGroupProperties>::const_iterator itr = library_type_table.begin();
         itr != library_type_table.end();
         ++itr)
    {
        if (itr->first == default_library_type)
        {
            fprintf(stderr, "\t%s (default)\n", itr->first.c_str());
        }
        else            
        {
            fprintf(stderr, "\t%s\n", itr->first.c_str());
        }
    }
}

void init_dispersion_method_table()
{
    dispersion_method_table["pooled"] = POOLED;
    dispersion_method_table["blind"] = BLIND;
    dispersion_method_table["per-condition"] = PER_CONDITION;
    dispersion_method_table["poisson"] = POISSON;
}

void print_dispersion_method_table()
{
    fprintf (stderr, "\nSupported dispersion methods:\n");
    for (map<string, DispersionMethod>::const_iterator itr = dispersion_method_table.begin();
         itr != dispersion_method_table.end();
         ++itr)
    {
        if (itr->first == default_dispersion_method)
        {
            fprintf(stderr, "\t%s (default)\n", itr->first.c_str());
        }
        else
        {
            fprintf(stderr, "\t%s\n", itr->first.c_str());
        }
    }
}


void init_lib_norm_method_table()
{
    lib_norm_method_table["geometric"] = GEOMETRIC;
    lib_norm_method_table["classic-fpkm"] = CLASSIC_FPKM;
    lib_norm_method_table["quartile"] = QUARTILE;
    lib_norm_method_table["estimated-absolute"] = ESTIMATED_ABSOLUTE;
    //lib_norm_method_table["tmm"] = TMM;
    //lib_norm_method_table["absolute"] = ABSOLUTE;
}

void init_cufflinks_lib_norm_method_table()
{
    lib_norm_method_table["classic-fpkm"] = CLASSIC_FPKM;
    //lib_norm_method_table["quartile"] = QUARTILE;
    //lib_norm_method_table["absolute"] = ABSOLUTE;
}


void print_lib_norm_method_table()
{
    fprintf (stderr, "\nSupported library normalization methods:\n");
    for (map<string, LibNormalizationMethod>::const_iterator itr = lib_norm_method_table.begin();
         itr != lib_norm_method_table.end();
         ++itr)
    {
        if (itr->first == default_lib_norm_method)
        {
            fprintf(stderr, "\t%s (default)\n", itr->first.c_str());
        }
        else if(itr->first == "estimated-absolute") // hide this one for now.
        {
            continue;
        }
        {
            fprintf(stderr, "\t%s\n", itr->first.c_str());
        }
    }
}

void init_output_format_table()
{
    output_format_table["cuffdiff"] = CUFFDIFF_OUTPUT_FMT;
    output_format_table["simple-table"] = SIMPLE_TABLE_OUTPUT_FMT;
}

void print_output_format_table()
{
    fprintf (stderr, "\nSupported output formats:\n");
    for (map<string, OutputFormat>::const_iterator itr = output_format_table.begin();
         itr != output_format_table.end();
         ++itr)
    {
        if (itr->first == default_output_format)
        {
            fprintf(stderr, "\t%s (default)\n", itr->first.c_str());
        }
        else
        {
            fprintf(stderr, "\t%s\n", itr->first.c_str());
        }
    }
}



// c_seq is complement, *NOT* REVERSE complement
void encode_seq(const string seqStr, char* seq, char* c_seq)
{
    
	for (size_t i = 0; i < seqStr.length(); ++i)
	{
		switch(seqStr[i])
		{
			case 'A' : 
			case 'a' : seq[i] = 0; c_seq[i] = 3; break;
			case 'c' : 
			case 'C' : seq[i] = 1; c_seq[i] = 2; break;
			case 'G' :
			case 'g' : seq[i] = 2; c_seq[i] = 1; break;
			case 'T' :
			case 't' : seq[i] = 3; c_seq[i] = 0; break;
			default  : seq[i] = 4; c_seq[i] = 4; break; // N
		}
	}
}


ReadGroupProperties::ReadGroupProperties() : 
    _strandedness(UNKNOWN_STRANDEDNESS), 
    _std_mate_orient(UNKNOWN_MATE_ORIENTATION),
    _platform(UNKNOWN_PLATFORM),
    _total_map_mass(0.0),
    _norm_map_mass(0.0),
    _internal_scale_factor(1.0),
    _external_scale_factor(1.0),
    _complete_fragments(false)
{
    _mass_dispersion_model = boost::shared_ptr<MassDispersionModel const>(new PoissonDispersionModel(""));
} 
