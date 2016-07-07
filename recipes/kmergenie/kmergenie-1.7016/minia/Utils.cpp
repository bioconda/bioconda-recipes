#include "Utils.h"
#include "Bank.h"

// some globals that don't really belong anywhere
int nks; // min abundance
uint32_t max_couv = 2147483646; // note: uint_abundance_t is 32 bits in SortingCount.cpp
struct timeval tim;
uint64_t nbkmers_solid = 0, b1_size = 0; 

const char *solid_kmers_file = (char *)"solid_kmers_binary"; 
const char *false_positive_kmers_file = (char *)"false_positive_kmers";
const char *bloom_file = (char *)"bloom_data";
const char *assembly_file = (char *)"contigs.fa";
const char *branching_kmers_file = (char *)"branching_kmers"; // (only useful for multiple assemblies with same bloom&debloom structure (ie debugging))
const char *binary_read_file = (char *)"reads_binary";
const char *histo_file_name = (char *)"histo";
const char *breakpoints_file_name = (char *)"breakpoints";

const char *assoc_kmer_file = (char *)"paired_kmer";


// prefix-based output files naming 
char prefix[1024];
char fileName[1024];
char *return_file_name(const char *suffix)
{
    if (strlen(prefix)>0)
        sprintf(fileName,"%s.%s",prefix,suffix);
    else
        sprintf(fileName,"%s",suffix);
    return fileName;
}


int readlen;

#ifndef NO_BLOOM_UTILS
template <typename T, typename U>
// T can be Bloom, BloomCpt, BloomCpt3 or LinearCounter (just needs to support add(kmer_type) and possibly contains(kmer_type))
// U can be BloomCpt or BloomCpt3
void bloom_pass_reads(Bank *Sequences, T *bloom_to_insert, U *bloom_counter, char *stderr_message)
{
    int64_t NbRead = 0;
    int64_t NbInsertedKmers = 0;
    Sequences->rewind_all();
    char * rseq;
    long i;
    kmer_type kmer, graine, graine_revcomp;


    while (Sequences->get_next_seq(&rseq,&readlen))
    {
      for (i=0; i<readlen-sizeKmer+1; i++)
        {
            kmer = extractKmerFromRead(rseq,i,&graine,&graine_revcomp);

            if (bloom_counter != NULL)
            {
                // discard kmers which are not solid
                if( ! bloom_counter->contains_n_occ(kmer,nks)) continue;
            }

            bloom_to_insert->add(kmer);
            NbInsertedKmers++;

        }
        NbRead++;
        if ((NbRead%10000)==0) fprintf (stderr,stderr_message,13,NbRead);
    }
//    fprintf (stderr,"\nInserted %lld %s kmers in the bloom structure.\n",(long long)NbInsertedKmers,"(redundant)");

}


template <typename T> // T can be Bloom, BloomCpt or BloomCpt3
void bloom_pass_reads_binary(T *bloom_to_insert, BloomCpt *bloom_counter, char *stderr_message)
{
  //fprintf(stderr,"binary pass \n");
  int64_t NbRead = 0;
  int64_t NbInsertedKmers = 0;
  kmer_type kmer;
  
  // read solid kmers from disk
  BinaryBank * SolidKmers = new BinaryBank(return_file_name(solid_kmers_file),sizeof(kmer),0);

  while(SolidKmers->read_element(&kmer))
    {
      // printf("kmer %lld\n",kmer);
      bloom_to_insert->add(kmer);
      NbInsertedKmers++;
      NbRead++;
      if ((NbRead%10000)==0) fprintf (stderr,stderr_message,13,(long long)NbRead);
    }
//  fprintf (stderr,"\nInserted %lld %s kmers in the bloom structure.\n",(long long)NbInsertedKmers,"solid");
  SolidKmers->close();
  
}

int estimated_BL1;
uint64_t estimated_BL1_freesize;

float NBITS_PER_KMER = 11 ; // number of bits per kmer that optimizes bloo1 size



// loading bloom from disk
template <typename T> //bloocpt or bloocpt3
Bloom *bloom_create_bloo1(T *bloom_counter, bool from_dump)
{

    BinaryBank * SolidKmers ;
    
    if(from_dump && nsolids) // from dump and known number of solid kmers 
    {
        //nsolids is sotred in a config file
        //number of solid kmers cannot be computed precisely from bloom file, imprecision of 0-7
        estimated_BL1 = max( (int)ceilf(log2f(nsolids*NBITS_PER_KMER)), 1);
        estimated_BL1_freesize =  (uint64_t)(nsolids*NBITS_PER_KMER);
        b1_size = (uint64_t) estimated_BL1_freesize; nbkmers_solid = nsolids ;  // for correct printf in print_size_summary
        
        printf("load bloom from dump, containing %lli solid kmers  b1_size %lli\n",nsolids,b1_size);

    }
    else
    {
        // get true number of solid kmers, in order to precisely size the bloom filter
        SolidKmers = new BinaryBank(return_file_name(solid_kmers_file),sizeof(kmer_type),0);
        estimated_BL1 = max( (int)ceilf(log2f(SolidKmers->nb_elements()*NBITS_PER_KMER)), 1);
        estimated_BL1_freesize =  (uint64_t)(SolidKmers->nb_elements()*NBITS_PER_KMER);
        //printf("nelem %lli nbits %g \n",(long long)(SolidKmers->nb_elements()),NBITS_PER_KMER);
    }
    
    //printf("Allocating %0.1f MB of memory for the main Bloom structure (%g bits/kmer)\n",(1LL<<estimated_BL1)/1024.0/1024.0/8.0,NBITS_PER_KMER);
    if(estimated_BL1_freesize ==0) estimated_BL1_freesize =10;

    //printf("freesize %lli estimated_BL1_freesize  %0.1f MB of memory for the main Bloom structure (%g bits/kmer)\n",(long long)estimated_BL1_freesize,(estimated_BL1_freesize)/1024.0/1024.0/8.0,NBITS_PER_KMER);
    
    Bloom *bloo1;
#if CUSTOMSIZE
    bloo1 = new Bloom((uint64_t)estimated_BL1_freesize);
#else
    bloo1 = new Bloom(estimated_BL1);
#endif

    bloo1->set_number_of_hash_func((int)floorf(0.7*NBITS_PER_KMER));

    if (from_dump)
        bloo1->load(return_file_name(bloom_file)); // just load the dump 
    else
    {
        bloom_pass_reads_binary(bloo1, bloom_counter, (char*)"%cInsert solid Kmers in Bloom %lld"); // use the method reading SolidKmers binary file, was useful when varying Bloom size (!= dumped size)
        //bloo1->dump(return_file_name(bloom_file)); // create bloom dump
        SolidKmers->close();
    }

    return bloo1;    
}

// wrapper for default behavior: don't load from dump
template <typename T> //bloocpt or bloocpt3
Bloom *bloom_create_bloo1(T *bloom_counter)
{
    return bloom_create_bloo1(bloom_counter, false);
}

template Bloom *bloom_create_bloo1<BloomCpt>(BloomCpt *bloom_counter); // trick to avoid linker errors: http://www.parashift.com/c++-faq-lite/templates.html#faq-35.13
template Bloom *bloom_create_bloo1<BloomCpt>(BloomCpt *bloom_counter, bool from_dump); 

// --------------------------------------------------------------------------------
// below this line: unused kmer counting code

FILE * F_kmercpt_read;
FILE * F_kmercpt_write;

//in last partition : create solid kmers file, and load solid kmers in bloo1 bloom
void end_kmer_count_partition(bool last_partition, Hash16 *hasht1)
{

    int value;
    int cptk=0;
    int64_t nso=0;
    /////////////////////////begin write files 
    rewind (F_kmercpt_read);
    rewind (F_kmercpt_write);

#ifndef MINGW
    ftruncate(fileno(F_kmercpt_write), 0); //erase previous file 
#else // tempfix? fileno is not accepted by mingw
    fclose(F_kmercpt_write);
    F_kmercpt_write = fopen("kmer_count2","wb+");
#endif
    BinaryBank * SolidKmers = NULL; 
    kmer_type graine;

    if (last_partition)
        SolidKmers = new BinaryBank(return_file_name(solid_kmers_file),sizeof(kmer_type),1);

    while(fread(&graine, sizeof(graine),1, F_kmercpt_read)){
        fread(&cptk, sizeof(cptk), 1, F_kmercpt_read);

        hasht1->remove(graine,&value); // if graine is present, get value of graine and remove graine, else value=0
        cptk +=  value;

        fwrite(&graine, sizeof(graine), 1, F_kmercpt_write);
        fwrite(&cptk, sizeof(cptk), 1, F_kmercpt_write);  

        if (last_partition && cptk >= nks)
            // if last partition, also need to search for solid kmers in remaining of hasht1, so this is not enough:
        {
            SolidKmers->write_element(&graine);
            nso++;
        }

    }
    hasht1->dump(F_kmercpt_write); // dump remaining of hasht1

    if (last_partition)  
    {
        nso+=hasht1->getsolids(NULL,SolidKmers,nks); // get remaining solids of hasht1
        fprintf(stderr,"nsolid kmers =  %lli  \n",(long long)nso);

        SolidKmers->close();

#ifndef MINGW
        ftruncate(fileno(F_kmercpt_read), 0); //erase previous file 
#else // tempfix? fileno is not accepted by mingw
        fclose(F_kmercpt_read);
        F_kmercpt_read = fopen("kmer_count2","wb+");
#endif

    } 
} 



template <typename T>
void exact_kmer_count(Bank *Sequences, T *bloom_counter, unsigned long max_memory)
{
   FILE * count_file = fopen("kmer_count","wb+");
   FILE * count_file_2 = fopen("kmer_count2","wb+");
   FILE * F_tmp;

   F_kmercpt_read  = count_file  ;
   F_kmercpt_write = count_file_2;

   Sequences->rewind_all();
   
   unsigned int max_kmer_per_part = max_memory*1024LL*1024LL /sizeof(cell<kmer_type>);
    int numpart = 0;
    char * rseq;
    long i;
    int64_t NbRead = 0;
    int64_t NbInserted = 0;
    int64_t NbInserted_unique = 0;
    kmer_type kmer, graine, graine_revcomp;

    // that code makes hasht1 occupy full memory. should probably be reduced (but we're deprecating that procedure, right?)
    int NBITS_HT = max( (int)ceilf(log2f((max_memory*1024L*1024L)/sizeof(cell_ptr_t))), 1); 
    Hash16 *hasht1 =new Hash16(NBITS_HT); 

    // partitioned exact kmer counting based on Bloom filter for solidity:
    // the bloom filter enables membership test for a set S of supposedly solid kmers (contains false positives)
    // read the (redundant) kmers from the reads, and load only those in S, in chunks, into a hash table
    // at each pass, update a file containing the true count of non-redundant supposedly solid kmers (S)
    // at the end, analyze the file to keep only those with true count >= solid
   while (Sequences->get_next_seq(&rseq,&readlen))
     {
       for (i=0; i<readlen-sizeKmer+1; i++)
	 {
	   kmer = extractKmerFromRead(rseq,i,&graine,&graine_revcomp);

	   // discard kmers which are not solid
	   if( ! bloom_counter->contains_n_occ(kmer,nks)) continue;
	   
	   //insert into hasht1
	   NbInserted_unique += hasht1->add(kmer);
	   NbInserted++;

	   if(hasht1->nb_elem >max_kmer_per_part) //end partition
	     {
	       
	       fprintf(stderr,"End of Kmer count partition  %lli / %i \n",(long long)(hasht1->nb_elem),max_kmer_per_part);
	       
	       if(numpart==0)
		 hasht1->dump(F_kmercpt_write);
	       else
	        end_kmer_count_partition(false,hasht1);

	       //swap file pointers
	       F_tmp = F_kmercpt_read;
	       F_kmercpt_read = F_kmercpt_write;
	       F_kmercpt_write = F_tmp;
	       /////////end write files
	       
	       //reset hash table
	       hasht1->empty_all();
	       
	       numpart++;
	     } ///end partition
	   
	 } 
             NbRead++;
        if ((NbRead%10000)==0) fprintf (stderr,"%cLoop through reads for exact kmer count %lld",13,(long long)NbRead);
     } 
   fprintf (stderr," \nTotal Inserted in hash (ie output of Bloom)  unique %lli   /  %lli  redundants \n",(long long)NbInserted_unique,(long long)NbInserted);
      ///////////////////////// last partition 
   end_kmer_count_partition(true,hasht1);
   delete hasht1;
 } 


void bloom_count(Bank *Reads, unsigned long max_memory)
{

#define NBITS_BLOOMCPT 23 // 33 :4GB (4 bits/elem)   // size of the bloom counter table to count kmers 

    fprintf(stderr,"nbits bloom counter: %i \n",NBITS_BLOOMCPT);

    BloomCpt3 * bloocpt  =   new BloomCpt3(NBITS_BLOOMCPT);
    BloomCpt3 * bloocpt2 =   new BloomCpt3(NBITS_BLOOMCPT);

    bloocpt->setSeed( 0x4909FEA3A68CC6A7LL);
    bloocpt2->setSeed( 0x0CD5DA28467C5492LL);

    //  bloocpt->set_number_of_hash_func(4);
    // bloocpt2->set_number_of_hash_func(6);


    ///////////////////////////////////first pass ; count kmers with Bloom cpt


    bloom_pass_reads(Reads,bloocpt, (BloomCpt * ) NULL, (char*)"%cFirst pass %lld");


    fprintf (stderr,"\n ____________   Second bloom counter   _________\n");

    bloom_pass_reads(Reads,bloocpt2, bloocpt, (char*)"%cSecond pass %lld");

STARTWALL(count);

    fprintf(stderr,"\n------------------ second pass  bloom counter   \n\n");

     delete bloocpt;
    
    ////////////////////////////////////// exact kmer count with hash table partitionning,
    //also create solid kmers file and fills bloo1

    exact_kmer_count(Reads,bloocpt2,max_memory);

    //////////////////////////////////////

    STOPWALL(count,"Counted kmers");

    fprintf(stderr,"\n------------------ Counted kmers and kept those with abundance >=%i \n\n",nks);
    
    
    ////////////////////////////////////////////////////fin bloom insert
    
    //delete bloocpt2;
}



void estimate_distinct_kmers(unsigned long genome_size, Bank *Reads)
{
    int size_linearCounter = genome_size * 8; // alloc 8 bits * genome size for counting, i.e. ~ as much as the assembly Bloom size
    LinearCounter *linearCounter = new LinearCounter(size_linearCounter);
    
    bloom_pass_reads(Reads,linearCounter, (BloomCpt * ) NULL, (char*)"%cEstimating number of distinct kmers (%lld reads processed so far)");

    long nb_distinct_kmers = linearCounter->count();

    if (linearCounter->is_accurate())
        printf("Estimated that %ld distinct kmers are in the reads\n",nb_distinct_kmers);
    else
        printf("Cannot estimate the number of distinct kmers. Allocate a larger counter\n");
    delete linearCounter;
}

uint64_t extrapolate_distinct_kmers(Bank *Reads)
{
    // start with 100MB RAM estimation and grow if necessary
    return extrapolate_distinct_kmers_wrapped(100000000L, Reads);
}

uint64_t extrapolate_distinct_kmers_wrapped(unsigned long nbytes_memory, Bank *Reads)
{
    unsigned long size_linearCounter = nbytes_memory * 8L; // alloc 8 bits * nbytes for counting
    LinearCounter *linearCounter = new LinearCounter(size_linearCounter);
    int stops = 100000;

    // variant of bloom_pass_reads

    int64_t NbRead = 0;
    int64_t NbInsertedKmers = 0;
    Reads->rewind_all();
    char * rseq;
    long i;
    kmer_type kmer, graine, graine_revcomp;

    long nb_distinct_kmers = 0; 
    long previous_nb_distinct_kmers = 0; 
    uint64_t estimated_nb_reads = Reads->estimate_nb_reads();
    bool stop = false;

    while (Reads->get_next_seq(&rseq,&readlen))
    {
        if (stop)
            break;

        for (i=0; i<readlen-sizeKmer+1; i++)
        {
            kmer = extractKmerFromRead(rseq,i,&graine,&graine_revcomp);

            linearCounter->add(kmer);
            NbInsertedKmers++;

            if (NbInsertedKmers % stops == 0 && NbRead != 0)
            {
                previous_nb_distinct_kmers = nb_distinct_kmers;
                nb_distinct_kmers = linearCounter->count()*estimated_nb_reads/NbRead;
                //printf("estimated now: %ld\n",nb_distinct_kmers);

                // the following condition will grossly over-estimate the number of distinct kmers
                // I expect the correct result to be in the same order of magnitude
                if (abs((int)(nb_distinct_kmers-previous_nb_distinct_kmers)) < previous_nb_distinct_kmers/20) // 5% error
                    stop = true;

                if (!linearCounter->is_accurate())
                    stop = true;
            }
        }
        NbRead++;
        if ((NbRead%10000)==0) fprintf (stderr,(char*)"%cExtrapolating number of distinct kmers %lld",13,NbRead);
    }

    if (!linearCounter->is_accurate())
    {
        printf("Inaccurate estimation, restarting with %lu MB RAM\n",(2*nbytes_memory)/1024/1024);
        delete linearCounter;
        return extrapolate_distinct_kmers_wrapped(2*nbytes_memory, Reads);
    }
    nb_distinct_kmers = linearCounter->count()*estimated_nb_reads/NbRead; // this is a very rough estimation

    printf("Linear estimation: ~%ld M distinct %d-mers are in the reads\n",nb_distinct_kmers/1000000L,sizeKmer);
    delete linearCounter;
    return nb_distinct_kmers;
}
#endif 


float needleman_wunch_mtg(string a, string b, int * nbmatch,int * nbmis,int * nbgaps, int deb )
{
    float gap_score = -5;
    float mismatch_score = -5;
    float match_score = 10;
#define nw_score(x,y) ( (x == y) ? match_score : mismatch_score )
	
    int n_a = a.length(), n_b = b.length();
    float ** score =  (float **) malloc (sizeof(float*) * (n_a+1));
    for (int ii=0; ii<(n_a+1); ii++)
    {
        score [ii] = (float *) malloc (sizeof(float) * (n_b+1));
    }
    
	// float score[n_a+1][n_b+1];  //stack is too small
    // float pointer[n_a+1][n_b+1];
	
    for (int i = 0; i <= n_a; i++)
        score[i][0] = gap_score * i;
    for (int j = 0; j <= n_b; j++)
        score[0][j] = gap_score * j;
	
    // compute dp
    for (int i = 1; i <= n_a; i++)
    {
        for (int j = 1; j <= n_b; j++)
        {
            float match = score[i - 1][j - 1] + nw_score(a[i-1],b[j-1]);
            float del =  score[i - 1][j] + gap_score;
            float insert = score[i][j - 1] + gap_score;
            score[i][j] = max( max(match, del), insert);
        }
    }
	
    // traceback
    int i=n_a, j=n_b;
    float identity = 0;
	int nb_mis = 0;
	int nb_gaps = 0;
	
	int nb_end_gaps = 0 ;
	bool end_gap = true;
	
    while (i > 0 && j > 0)
    {
		
        float score_current = score[i][j], score_diagonal = score[i-1][j-1], score_up = score[i][j-1], score_left = score[i-1][j];
        if (score_current == score_diagonal + nw_score(a[i-1], b[j-1]))
        {
			//if(deb==1)printf("eat %i %i \n",i,j);
			
            if (a[i-1]== b[j-1])
			{
			//	if(deb==1)printf("match  %c %c \n",a[i-1],b[j-1]);
				
                identity++;
			}
			else
			{
			//	if(deb==1)printf("mis  %c %c \n",a[i-1],b[j-1]);
				
				nb_mis++;
			}
            i -= 1;
            j -= 1;
			
			
			end_gap = false;
        }
        else
        {
            if (score_current == score_left + gap_score)
			{
				//if(deb==1)printf("add gap s1 at ij %i %i \n",i,j);
				i -= 1;
			}
            else if (score_current == score_up + gap_score)
			{
			//	if(deb==1)printf("add gap s2 at ij %i %i \n",i,j);
				j -= 1;
			}
			
			
			if(!end_gap) //pour ne pas compter gap terminal
			{
				
				nb_gaps++;
			}
        }
    }
	
	//pour compter gaps au debut  :
	nb_gaps += i+j;
	//if(deb==1)printf("add gaps i j %i %i \n",i,j);
	
    identity /= max( n_a, n_b); // modif GR 27/09/2013    max of two sizes, otherwise free gaps
    
    if(nbmatch!=NULL) *nbmatch = identity;
    if(nbmis!=NULL)  *nbmis = nb_mis;
    if(nbgaps!=NULL) *nbgaps = nb_gaps;
    
    for (int ii=0; ii<(n_a+1); ii++)
    {
        free (score [ii]);
    }
    free(score);
    
    //printf("---nw----\n%s\n%s -> %.2f\n--------\n",a.c_str(),b.c_str(),identity);
    return identity;
}


float needleman_wunch(string a, string b )
{
    float gap_score = -5;
    float mismatch_score = -5;
    float match_score = 10;
    #define nw_score(x,y) ( (x == y) ? match_score : mismatch_score )

    int n_a = a.length(), n_b = b.length();
    float ** score =  (float **) malloc (sizeof(float*) * (n_a+1));
    for (int ii=0; ii<(n_a+1); ii++)
    {
        score [ii] = (float *) malloc (sizeof(float) * (n_b+1));
    }
    
   // float score[n_a+1][n_b+1];  //stack is too small
    // float pointer[n_a+1][n_b+1];

    for (int i = 0; i <= n_a; i++)
        score[i][0] = gap_score * i;
    for (int j = 0; j <= n_b; j++)
        score[0][j] = gap_score * j;
   
    // compute dp 
    for (int i = 1; i <= n_a; i++)
    {
        for (int j = 1; j <= n_b; j++)
        {
            float match = score[i - 1][j - 1] + nw_score(a[i-1],b[j-1]);
            float del =  score[i - 1][j] + gap_score;
            float insert = score[i][j - 1] + gap_score;
            score[i][j] = max( max(match, del), insert);
        }
    }

    // traceback
    int i=n_a, j=n_b;
    float identity = 0;
	int nb_mis = 0;
	int nb_gaps = 0;
	
	int nb_end_gaps = 0 ;
	bool end_gap = true;
	
    while (i > 0 && j > 0)
    {

        float score_current = score[i][j], score_diagonal = score[i-1][j-1], score_up = score[i][j-1], score_left = score[i-1][j];
        if (score_current == score_diagonal + nw_score(a[i-1], b[j-1]))
        {

            if (a[i-1]== b[j-1])
                identity++;
			else
				nb_mis++;
            i -= 1;
            j -= 1;
			
			
			end_gap = false;
        }
        else 
        {
            if (score_current == score_left + gap_score)
				i -= 1;
            else if (score_current == score_up + gap_score)
				j -= 1;

        }
    }

    identity /= max( n_a, n_b); // modif GR 27/09/2013    max of two sizes, otherwise free gaps
    
    for (int ii=0; ii<(n_a+1); ii++)
    {
        free (score [ii]);
    }
    free(score);
    
    //printf("---nw----\n%s\n%s -> %.2f\n--------\n",a.c_str(),b.c_str(),identity);
    return identity;
}



void Progress::init(uint64_t ntasks, const char * msg)
{
    gettimeofday(&timestamp, NULL);
    heure_debut = timestamp.tv_sec +(timestamp.tv_usec/1000000.0);
    
    fprintf(stderr,"| %-*s |\n",98,msg);
    
    todo= ntasks;
    done = 0;
    partial =0;
    for (int ii=0; ii<16;ii++) partial_threaded[ii]=0;
    for (int ii=0; ii<16;ii++) done_threaded[ii]=0;
    subdiv= 100;
    steps = (double)todo / (double)subdiv;
    
    if(!timer_mode)
    {
        fprintf(stderr,"[");fflush(stderr);
    }
}

void Progress::finish()
{
    set(todo);
    if(timer_mode)
        fprintf(stderr,"\n");
    else
        fprintf(stderr,"]\n");
    
    fflush(stderr);
    todo= 0;
    done = 0;
    partial =0;
    
}


void Progress::finish_threaded()// called by only one of the threads
{
    done = 0;
    double rem = 0;
    for (int ii=0; ii<16;ii++) done += (done_threaded[ii] ); 
    for (int ii=0; ii<16;ii++) partial += (partial_threaded[ii] ); 

    finish();

}

void Progress::inc(uint64_t ntasks_done, int tid)
{
    partial_threaded[tid] += ntasks_done;
    done_threaded[tid] += ntasks_done;
    while(partial_threaded[tid] >= steps)
    {
        if(timer_mode)
        {
            struct timeval timet;
            double now;
            gettimeofday(&timet, NULL);
            now = timet.tv_sec +(timet.tv_usec/1000000.0);
            uint64_t total_done  = 0;
            for (int ii=0; ii<16;ii++) total_done += (done_threaded[ii] );
            double elapsed = now - heure_debut;
            double speed = total_done / elapsed;
            double rem = (todo-total_done) / speed;
            if(total_done > todo) rem =0;
            int min_e  =  (int)(elapsed / 60) ;
            elapsed -= min_e*60;
            int min_r  =  (int)(rem / 60) ;
            rem -= min_r*60;
            
            fprintf(stderr,"%c%-5.3g  %%     elapsed: %6i min %-4.0f  sec      estimated remaining: %6i min %-4.0f  sec ",13,100*(double)total_done/todo,min_e,elapsed,min_r,rem);

        }
        else
        {
            fprintf(stderr,"-");fflush(stderr);
        }
        partial_threaded[tid] -= steps;

    }
    
}

void Progress::inc(uint64_t ntasks_done)
{
    done += ntasks_done;
    partial += ntasks_done;
    
    
    while(partial >= steps)
    {
        if(timer_mode)
        {
            gettimeofday(&timestamp, NULL);
            heure_actuelle = timestamp.tv_sec +(timestamp.tv_usec/1000000.0);
            double elapsed = heure_actuelle - heure_debut;
            double speed = done / elapsed;
            double rem = (todo-done) / speed;
            if(done>todo) rem=0;
            int min_e  = (int)(elapsed / 60) ;
            elapsed -= min_e*60;
            int min_r  = (int)(rem / 60) ;
            rem -= min_r*60;
            
            fprintf(stderr,"%c%-5.3g  %%     elapsed: %6i min %-4.0f  sec      estimated remaining: %6i min %-4.0f  sec ",13,100*(double)done/todo,min_e,elapsed,min_r,rem);
        }
        else
        {
            fprintf(stderr,"-");fflush(stderr);
        }
        partial -= steps;
    }
    
    
}


void Progress::set(uint64_t ntasks_done)
{
    if(ntasks_done > done)
        inc(ntasks_done-done);
}


