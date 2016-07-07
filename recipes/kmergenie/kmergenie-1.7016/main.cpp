#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h> // for mkdir()
#include <errno.h> // for mkdir() errors
#include <inttypes.h>
#include <stdint.h>
#include <algorithm> // for max/min
#include <sys/time.h>
#include <libgen.h> // for basename()
#include <string>
#include <vector>
#include <cmath> // for sqrt()
#include <pthread.h>

#define STR_EXPAND(tok) #tok
#define STR(tok) STR_EXPAND(tok)

using namespace std;

#define LARGEST_K_IN_MAKEFILE 121

float hash16_factor = 0.1;
typedef uint64_t uint_abundance_t;
const char *est_histo_file_name = (char *)"est_histo";

#include "minia/Bank.h"
#include "minia/Pool.h"
#include "minia/Bloom.h"
#include "minia/Utils.h"
#include "minia/Kmer.h"
#include "minia/MultiConsumer.h"
#include "minia/Hashing.h"

class HistogramEstimator
{
public:
    virtual uint64_t finish(uint64_t *histo_count) = 0;
    virtual void process(kmer_type kmer) = 0;
};

class NaiveSampling : HistogramEstimator
{
    int reduction_factor;
    uint64_t estimated_distinct_kmers;

public:
    Hash16 *hash;

    NaiveSampling(uint64_t estimated_distinct_kmers, int reduction_factor) : reduction_factor(reduction_factor), estimated_distinct_kmers(estimated_distinct_kmers)
    {
        uint64_t estimated_nb_elements = estimated_distinct_kmers/reduction_factor;
        //printf("estimated nb elements in hash16: %ld\n",estimated_nb_elements);
        hash = new Hash16(max((int)ceilf(log2f(hash16_factor*estimated_nb_elements)),1));
    }

    inline void process(kmer_type lkmer)
    {
        // some hashing to uniformize repartition
        uint64_t kmer_hash = Hashing::hashcode(lkmer);
        
        // check if this kmer should be included
        if ((kmer_hash % reduction_factor ) != 0) 
            return;

        hash->add(lkmer);
    }
    
    uint64_t finish(uint64_t *histo_count)
    {
        hash->start_iterator();
        uint64_t nb_kmers = 0;
        while (hash->next_iterator())
        {
            uint_abundance_t abundance = hash->iterator.cell_ptr->val;
            uint_abundance_t saturated_abundance;
            saturated_abundance = (abundance >= 10000) ? 10000 : abundance;
            histo_count[saturated_abundance]++;
            nb_kmers++;
        }
        return nb_kmers;
    }   
        
};

// vars set in main() and read in threads
typedef NaiveSampling estimatorMethod;

int largestSizeKmer;
int step;
std::vector<MultiReadsConsumer> mrc;
std::vector<MultiReads> mr;
std::vector<estimatorMethod> ns;


void thread_code(void *arg)
{
    pair<int,int> *p = static_cast<pair<int,int>*>(arg);
    char *rseq;
    int readlen;
    bool running = true;

    int from_queue = p->first;
    int to_queue = p->second;

    while (true)
    {
        for (int i = from_queue; i < to_queue; i++)
        {
            mrc[i].consume(rseq,readlen);

            running = (readlen > 0);
            if (!running)
                break;

            // set k-mer length
            int sizeKmer = largestSizeKmer - i*step;
            kmer_type kmerMask;
            if (sizeKmer == (int)(sizeof(kmer_type)*4))
                kmerMask = -1;
            else
                kmerMask = (((kmer_type)1)<<(sizeKmer*2))-1;


            int nbkmers = readlen - sizeKmer + 1;

            kmer_type lkmer, graine, graine_revcomp;

            for (int j=0; j<nbkmers; j++)
            {
                lkmer = extractKmerFromRead(rseq,j,&graine,&graine_revcomp, true, sizeKmer, kmerMask);
                ns[i].process(lkmer);
            }
        }
        if (!running)
            break;
    }
}

int main(int argc, char *argv[])
{

    step = 10;
    int smallestSizeKmer = 15;
    int nb_threads = 1;

    if(argc <  2)
    {
        fprintf (stderr,"usage:\n");
        fprintf (stderr," %s reads_file [-o out_prefix] [-s step]\n",argv[0]);
        fprintf (stderr,"details:\n [-o out_prefix] saves results in [out_prefix].histo\n [-s step] interval between consecutive kmer sizes (default: %d)\n [-k value] largest k-mer size to evaluate (default: %d)\n [-l value] smallest k-mer size to evaluate (default: %d)\n [-e value] k-mer sampling (default: auto-detected power of 10)\n [-t value] number of threads (default: 1)\n  Input file can be fasta, fastq, gzipped or not, or a file containing a list of file names.\n",step,LARGEST_K_IN_MAKEFILE,smallestSizeKmer);
#ifdef SVN_REV
fprintf(stderr,"Running %s version %s\n",argv[0],STR(SVN_REV));
#endif
        return 0;
    }

    // reads file
    Bank *Reads = new Bank(argv[1]);

    // default prefix is the reads file basename
    char *reads_path=strdup(argv[1]); // posix basename() may alter reads_path, so use a copy
    string reads_name(basename(reads_path)); 
    free(reads_path);
    int lastindex = reads_name.find_last_of("."); 
    strcpy(prefix,reads_name.substr(0, lastindex).c_str()); 

    largestSizeKmer = Reads->estimate_max_readlen()-1;
    largestSizeKmer = min(LARGEST_K_IN_MAKEFILE,largestSizeKmer);
    if (largestSizeKmer % 2 == 0)
        largestSizeKmer--;
    largestSizeKmer = (int)floor(largestSizeKmer/10)*10+1; // force it in the ..1 form (similar to experiments in the paper)
    

    int verbose = 0;
    int reduction_factor = 0;

    for (int n_a = 2; n_a < argc ; n_a++)
    {
        if (strcmp(argv[n_a],"-o")==0)
            strcpy(prefix,argv[n_a+1]);

        if (strcmp(argv[n_a],"-e")==0)
            reduction_factor = atoi(argv[n_a+1]);

        if (strcmp(argv[n_a],"-k")==0)
            largestSizeKmer = atoi(argv[n_a+1]);

        if (strcmp(argv[n_a],"-l")==0)
            smallestSizeKmer = atoi(argv[n_a+1]);

        if (strcmp(argv[n_a],"-s")==0)
            step = atoi(argv[n_a+1]);

        if (strcmp(argv[n_a],"-t")==0)
            nb_threads = atoi(argv[n_a+1]);

        if (strcmp(argv[n_a],"-v")==0)
            verbose = 1;

        if (strcmp(argv[n_a],"-vv")==0)
            verbose = 2;
    }

    if (step <= 0)
    {
        printf("The argument \"-s\" must be strictly positive\n");
        exit(1);
    }


    if (largestSizeKmer > (int)(sizeof(kmer_type)*4))
    {
        printf("Max kmer size on this compiled version is %lu (see the README to increase it)\n",sizeof(kmer_type)*4);
        exit(1);
    }

    if (largestSizeKmer < smallestSizeKmer || largestSizeKmer == 0)
    {
        printf("Invalid smallest (%d) and largest kmer (%d) sizes\n", smallestSizeKmer, largestSizeKmer);
        exit(1);

    }

    // create output folder if it doesn't exist or warn that it cannot be created
    char *prefix_dup = strdup(prefix); // posix dirname() may alter reads_path, so use a copy
    char *prefix_path=dirname(prefix_dup); 
    int mkdir_rc = mkdir(prefix_path,S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    if (mkdir_rc == -1 && errno != EEXIST)
    {
        printf("Directory %s could not be created\n",prefix_path);
        free(prefix_dup);
        exit(1);
    }
    free(prefix_dup);

    STARTWALL(0);

    sizeKmer = abs(largestSizeKmer-21)/2 + 21; // estimate for a typical value
    if (sizeKmer == (int)(sizeof(kmer_type)*4))
        kmerMask = -1;
    else
        kmerMask = (((kmer_type)1)<<(sizeKmer*2))-1;

    uint64_t estimated_distinct_kmers = extrapolate_distinct_kmers(Reads);

    // autodetect reduction_factor
    // aim for ~ 200 MB memory usage per thread if possible
    if (reduction_factor == 0)
    {
        uint64_t hash_overhead_per_kmer = (hash16_factor * sizeof(cell_ptr_t) + sizeof(cell<hash_elem>));  // estimation of Hash16 size, as used here, in bytes
        reduction_factor = (int) ((estimated_distinct_kmers * hash_overhead_per_kmer) / 200 / 1024 / 1024);
        if (reduction_factor == 0)
            reduction_factor = 1;
    }
    printf("K-mer sampling: 1/%d\n", reduction_factor);

    // init things
    Reads->rewind_all();
    char * rseq;
    int readlen;
    int64_t estimated_NbReads = Reads->estimate_nb_reads();
    Progress progress_conversion;
    progress_conversion.init(estimated_NbReads,"processing");
    long NbRead = 0;

    int nb_kmer_values = (int)ceil(1.0*(largestSizeKmer-smallestSizeKmer+1) / step);

    if (nb_threads > nb_kmer_values)
        nb_threads = nb_kmer_values;

    if (nb_threads >= 1024)
    {
        printf("Number of threads should be lower than 1024.\n");
        exit(1);
    }

    printf("going to estimate histograms for values of k: ");
    for (int i = 0; i < nb_kmer_values ; i++)
        printf("%d ",largestSizeKmer - i*step);
    printf("\n");

    for (int i = 0; i < nb_kmer_values; i++)
        ns.push_back(estimatorMethod(estimated_distinct_kmers,reduction_factor));

    for (int i = 0; i < nb_kmer_values; i++)
    {
        mr.push_back(MultiReads(i));
        mrc.push_back(MultiReadsConsumer(mr[i],i));
    }
    
    int last_to_queue = 0;
    pthread_t threads[nb_threads];
    pair<int,int> p[1024]; // clang wants a fixed amount
    for (int i = 0; i < nb_threads; i++)
    {
        // each thread gets assigned an interval of k-mer values
        int from_queue = last_to_queue;
        int to_queue = ((nb_kmer_values * (i+1)) / nb_threads);
        last_to_queue = to_queue;
        p[i] = make_pair(from_queue, to_queue);

        pthread_create(&threads[i], NULL, (void* (*)(void*)) &thread_code, (void*)&(p[i]));
    }

    while(1)
    {
        if(! Reads->get_next_seq(&rseq,&readlen)) break; // read  original fasta file

        if (readlen > 0)
        {
            for (int i = 0; i < nb_kmer_values ; i++)
            {
                mr[i].produce(rseq,readlen);
            }
        }
        
        NbRead++;
        if ((NbRead%10000)==0)
        {
            progress_conversion.inc(10000);
        }
    }
    
    for (int i = 0; i < nb_kmer_values; i++)
    {
        mr[i].setAllDone();
    }

    for (int i = 0; i < nb_threads; i++)
    {
        int status;
        pthread_join(threads[i], (void **)&status);
    }

    //ns[0].hash->printstat();
    //ns[nb_kmer_values-1].hash->printstat();

    // histogram part

    uint64_t nb_sampled_kmers = 0;
    for (int i = 0; i < nb_kmer_values ; i++)
    {
        uint64_t  * histo_count = (uint64_t  *) calloc(10001,sizeof(uint64_t));

        nb_sampled_kmers += ns[i].finish(histo_count);

        char histo_file_name[1024];
        sprintf(histo_file_name,"%s-k%d.histo", prefix, largestSizeKmer-i*step);

        FILE * histo_file = fopen(histo_file_name,"w");
        for (int cc=1; cc<10001; cc++) {
            fprintf(histo_file,"%i\t%llu\n",cc,(unsigned long long)(histo_count[cc])* reduction_factor);
        }
        fclose(histo_file);
        free(histo_count);
    }
    STOPWALL(0,"Total");

    delete Reads;

    pthread_exit(NULL);
}


