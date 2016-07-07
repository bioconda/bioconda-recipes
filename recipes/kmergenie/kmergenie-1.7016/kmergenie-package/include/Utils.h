#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <string>
#include <inttypes.h>
#include <cmath> // for log2f
#include <algorithm> // for max
#include <unistd.h> // for truncate
#include <limits.h> // for INT_MAX

#ifndef UTILS_H
#define UTILS_H

#include "Bank.h"
#include "Kmer.h"

#ifndef NO_BLOOM_UTILS
#include "Bloom.h"
#include "Hash16.h"
#include "LinearCounter.h"
#endif

using namespace std;

#
extern struct timeval tim;
#define STARTWALL(TT) \
gettimeofday(&tim, NULL);\
double wdebut  ## TT =tim.tv_sec +(tim.tv_usec/1000000.0); 


#define STOPWALL(TT,MESSAGE)				\
gettimeofday(&tim, NULL);\
double wfin  ## TT =tim.tv_sec +(tim.tv_usec/1000000.0); \
 fprintf(stderr,"-------------------%s time Wallclock  %g s\n",MESSAGE,  wfin ## TT-wdebut ## TT  );

// global variables
extern int nks;
extern uint32_t max_couv;

extern char prefix[1024];
extern float NBITS_PER_KMER;

// constants
extern const char *solid_kmers_file;// = (char *)"solid_kmers_binary"; 
extern const char *false_positive_kmers_file ;//= (char *)"false_positive_kmers";
extern const char *bloom_file ;//= (char *)"bloom_data";
extern const char *assembly_file ;//= (char *)"contigs.fa";
extern const char *branching_kmers_file ;//= (char *)"branching_kmers"; // (only useful for multiple assemblies with same bloom&debloom structure (ie debugging))
extern const char *binary_read_file;// = (char *)"reads_binary";
extern const char *histo_file_name ;//= (char *)"histo";
extern const char *breakpoints_file_name; // = (char *)"breakpoints";
extern const char *assoc_kmer_file ;


char *return_file_name(const char *suffix);

void estimate_distinct_kmers(unsigned long genome_size, Bank *Reads);
uint64_t extrapolate_distinct_kmers(Bank *Reads);
uint64_t extrapolate_distinct_kmers_wrapped(unsigned long nbytes_memory, Bank *Reads);

#ifndef NO_BLOOM_UTILS
void bloom_count(Bank * reads, unsigned long max_memory);
template<typename T> Bloom *bloom_create_bloo1(T *bloom_counter);
template<typename T> Bloom *bloom_create_bloo1(T *bloom_counter, bool from_dump);
template<typename T>void bloom_pass_reads_binary(T *bloom_to_insert,BloomCpt *bloom_counter,char *stderr_message);
template<typename T,typename U>void bloom_pass_reads(Bank *Sequences,T *bloom_to_insert,U *bloom_counter,char *stderr_message);
#endif

float needleman_wunch(string a, string b );
float needleman_wunch_mtg(string a, string b, int * nbmatch=NULL,int * nbmis=NULL,int * nbgaps=NULL, int deb =-1 );


class Progress
{
public:
    int timer_mode; 
    struct timeval timestamp;
    double heure_debut, heure_actuelle ;
    
    uint64_t done;
    uint64_t todo;
    int subdiv ; // progress printed every 1/subdiv of total to do
    double partial;
    double partial_threaded[16];
    uint64_t done_threaded[16];

    double steps ; //steps = todo/subidv
    
    void init(uint64_t ntasks, const char * msg);
    void finish();
    void finish_threaded();// called by only one of the threads

    void inc(uint64_t ntasks_done);
    void inc(uint64_t ntasks_done, int tid); //threads collaborate to this same progress bar
    void set(uint64_t ntasks_done);
    Progress () :     timer_mode(0) {}
    //include timer, to print ETA ?
};


#endif
