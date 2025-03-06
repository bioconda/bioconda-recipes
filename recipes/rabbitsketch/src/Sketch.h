#ifndef Sketch_H
#define Sketch_H
#include "shuffle.h"
#include <map>
#include <vector>
#include <string>
//#include <string.h>
#include <stdint.h>
#include <float.h>
#include <unordered_set>
#include "MinHash.h"
#include "histoSketch.h"
#include "HyperLogLog.h"
//#include "Kssd.h"
#include <cstdint>
#if defined(_MSC_VER)
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#endif  

#define COMPONENT_SZ 7
//#define MIN_SUBCTX_DIM_SMP_SZ 4096
#define _64MASK 0xffffffffffffffffLLU
#define CTX_SPC_USE_L 8
#define LD_FCTR 0.6
#define DEFAULT_CHAR_KSSD -1



//typedef struct fileInfo
//{
//	string fileName;
//	uint64_t fileSize;
//} fileInfo_t;

//typedef struct sketch
//{
//	string fileName;
//	string seqName;
//	string comment;
//	int id;
//	vector<uint32_t> hashSet;
//	vector<uint64_t> hashSet64;
//} sketch_t;


//for converting Kssd sketch into RabbitKSSD sketch format
typedef struct co_dirstat
{
  unsigned int shuf_id;
  bool koc;
  int kmerlen;
  int dim_rd_len;
  int comp_num;
  int infile_num;
  uint64_t all_ctx_ct;
} co_dstat_t;

typedef struct setResult
{
  int common;
  int size0;
  int size1;
  double jaccard;
} setResult_t;

struct DistInfo
{
  string refName;
  int common;
  int refSize;
  double jorc;
  double dist;
};
struct cmpDistInfo
{
  bool operator()(DistInfo d1, DistInfo d2){
    return d1.dist < d2.dist;
  }
};
/// \brief Sketch namespace
namespace Sketch{
  struct fileInfo_t {
    std::string fileName;
    uint64_t fileSize;
  };
  struct sketch_t {
    std::string fileName;
    std::vector<uint32_t> hashSet;
    std::vector<uint64_t> hashSet64;
    int id;
  };

  struct sketchInfo_t
  {
    int id;
    int half_k;
    int half_subk;
    int drlevel;
    int genomeNumber;
  };
  typedef uint64_t hash_t;

  struct WMHParameters
  {
    int kmerSize;
    int sketchSize;
    int windowSize;
    double * r; 
    double * c; 
    double * b; 
  };

  struct Reference
  {
    // no sequence for now
    std::string name;
    std::string comment;
    uint64_t length;
    HashList hashesSorted;
    std::vector<uint32_t> counts;
  };

  struct MashLite {
    std::string fileName;               
    int id;                            
    //std::vector<uint32_t> hashList;    
    std::vector<uint64_t> hashList64;  

    MashLite() : id(0) {}
  };

  void transMinHashes(vector<MashLite>& sketches, sketchInfo_t& info, string dictFile, string indexFile, int numThreads);
  void index_tridist_MinHash(vector<MashLite>& sketches, sketchInfo_t& info, string refSketchOut, string outputFile, int kmer_size, double maxDist, int isContainment, int numThreads);
  void saveMinHashes(vector<MashLite>& sketches, sketchInfo_t& info, string outputFile);
  // Sketching seqeunces using minhash method
  class MinHash
  {

    public:
      /// minhash init with parameters
      MinHash(int k = 21, int size = 1000, uint32_t seed = 42, bool rc = true):
        kmerSize(k), sketchSize(size), seed(seed), use64(true), noncanonical(!rc)
    {
      minHashHeap = new MinHashHeap(use64, sketchSize);

      this->kmerSpace = pow(alphabetSize, kmerSize);

      this->totalLength = 0;

      this->needToList = true;
    }
      /* for the containment of sequences(genomes).
       * the size of minHashHeap(as sketchSize) is proportatd with the sequence(genome) length.
       * addbyxxm 2021/9/18
       */
      int id;
      MashLite toLite(vector<uint64_t> hashL) const {
        MashLite lite;
        lite.fileName = fileName;
        lite.id = id;
        //lite.hashList = hashList;
        lite.hashList64 = hashL;
        return lite;
      }
      /// minhash is updatable with multiple sequences
      void update(char * seq);

      /// merge two minhashes
      void merge(MinHash& msh);

      /// return the jaccard index
      double jaccard(MinHash * msh);			

      double containJaccard(MinHash * msh);

      double containDistance(MinHash * msh);
      /// return mutation distance defined in Mash instead of jaccard distance
      double distance(MinHash * msh);

      //print hash values for debug
      void printMinHashes();

      //get hash values for saving
      vector<uint64_t> storeMinHashes();

      //load hash valued from files
      void loadMinHashes(vector<uint64_t> hashArr);

      /// return totalSeqence length, including multiple updates
      uint64_t getTotalLength(){return totalLength;}

      ///Estimate the cardinality count
      int count(){ return minHashHeap->estimateSetSize();}
      // parameters

      /// return kmerSize
      int getKmerSize() { return kmerSize; }

      // return alphabet size
      //uint32_t getAlphabetSize() { return alphabetSize; }

      // return whether to preserve case
      //bool isPreserveCase() { return preserveCase; }

      // return whether to use 64bit hash
      //bool isUse64() { return use64; }
      //save file name
      string fileName;
      /// return hash seed
      uint32_t getSeed() {return seed; }

      /// return sketch size
      uint32_t getMaxSketchSize() {return sketchSize; }

      /// return whether to use reverse complement
      bool isReverseComplement() { return !noncanonical; }

      /// test whether this minhash is empty
      bool isEmpty() { 
        //if(this->needToList){
        //	this->heapToList();
        //	this->needToList = false;
        //}

        if(this->reference.hashesSorted.size() <= 0)
          return true;
        else
          return false;

      }

      /// get sketch size, it should be less than max sketch size
      int getSketchSize() {
        //if(this->needToList)
        //{
        //	this->heapToList();
        //	this->needToList = false;
        //}

        return this->reference.hashesSorted.size();
      }

    private:
      bool needToList = true;
      double kmerSpace;
      MinHashHeap * minHashHeap;
      Reference reference;
      uint64_t totalLength = 0;

      double pValue(uint64_t x, uint64_t lengthRef, uint64_t lengthQuery, double kmerSpace, uint64_t sketchSize);
      void heapToList();

      //parameters
      int kmerSize;
      uint32_t alphabetSize; //nuc sequences
      uint32_t seed;
      uint64_t sketchSize; //minHashesPerWindow
      bool noncanonical;
      bool use64; //always true (remove support for hash32)

      //FIXME: perserveCase is not included in constructor
      bool preserveCase = false;
  };

  std::tuple<int, int, int, int*> read_shuffled_file(std::string filepath);
  struct kssd_parameter_t {
    int half_k;
    int half_subk;
    int drlevel;
    int rev_add_move;
    int half_outctx_len;
    int * shuffled_dim;
    int dim_start;
    int dim_end;
    unsigned int kmer_size;
    int hashSize;
    int hashLimit;
    uint64_t domask;
    uint64_t tupmask;
    uint64_t undomask0;
    uint64_t undomask1;
    robin_hood::unordered_map<uint32_t, int> shuffled_map;

    kssd_parameter_t(int half_k_, int half_subk_, int drlevel_, string shuffle_file)
      : 
        half_k(half_k_),
        half_subk(half_subk_),
        drlevel(drlevel_),
        //shuffled_dim(shuffled_dim_),
        half_outctx_len(half_k_ - half_subk_),
        rev_add_move(4 * half_k_ - 2),
        kmer_size(2 * half_k_),
        dim_start(0),
        dim_end(1 << 4 * (half_subk - drlevel)),
        hashSize(2000), 
        hashLimit(2000 * LD_FCTR)
    {
      if (half_subk_ - drlevel_ < 3) {
        std::cerr << "Error: the half_subk - drlevel should be at least 3. Current half_subk and drlevel are: "
          << half_subk_ << " and " << drlevel_ << " respectively." << std::endl;
        throw std::invalid_argument("Invalid parameters for kssd_parameter_t");
      }

      auto result = Sketch::read_shuffled_file(shuffle_file);
      //half_k = std::get<0>(result);
      //half_subk = std::get<1>(result);
      //drlevel = std::get<2>(result);
      shuffled_dim = std::get<3>(result);
      int comp_bittl = 64 - 4 * half_k;
      tupmask = _64MASK >> comp_bittl;
      domask = (tupmask >> (4 * half_outctx_len)) << (2 * half_outctx_len);
      uint64_t undomask = (tupmask ^ domask) & tupmask;
      undomask1 = undomask & (tupmask >> ((half_k + half_subk) * 2));
      undomask0 = undomask ^ undomask1;
      int dim_size = 1 << (4 * half_subk);

      for (int t = 0; t < dim_size; t++) {
        if (shuffled_dim[t] < (1 << (4 * (half_subk - drlevel_))) && shuffled_dim[t] >= 0) { // ensure dim_start = 0
          shuffled_map[t] = shuffled_dim[t];
          //		std::cout << "Inserted into shuffled_map: " << t << " -> " << shuffled_dim[t] << std::endl;
        }
      }

    }
  };

  struct KssdLite {
    std::string fileName;               
    int id;                            
    std::vector<uint32_t> hashList;    
    std::vector<uint64_t> hashList64;  

    KssdLite() : id(0) {}
  };



  class Kssd{
    public:


      //Kssd(int half_k, int half_subk, int drlevel, std::vector<int> shuffled_dim)
      //	:params_(half_k, half_subk, drlevel, std::move(shuffled_dim)),
      //	dim_size_(1 << (4 * half_subk)), use64_((half_k - drlevel) > 8)
      Kssd(kssd_parameter_t params)
        : params_(std::move(params)),
        dim_size_(1 << (4 * params_.half_subk)),
        use64((params_.half_k - params_.drlevel) > 8),
        half_outctx_len(params_.half_outctx_len),
        rev_add_move(params_.rev_add_move),
        half_k_(params_.half_k),
        drlevel_(params_.drlevel),
        half_subk_(params_.half_subk),
        kmer_size(params_.kmer_size),
        dim_start(params_.dim_start),
        dim_end(params_.dim_end),
        hashSize(params_.hashSize),
        hashLimit(params_.hashLimit),
        tupmask(params_.tupmask),
        domask(params_.domask),
        undomask0(params_.undomask0),
        undomask1(params_.undomask1),
        shuffled_dim_(params_.shuffled_dim),
        shuffled_map(params_.shuffled_map),
        component_num(0) 
          //comp_bittl(64 - 4 * params_.half_k)
    {
    }


      Kssd(const Kssd&) = delete;
      Kssd& operator=(const Kssd&) = delete;

      KssdLite toLite() const {
        KssdLite lite;
        lite.fileName = fileName;
        lite.id = id;
        lite.hashList = hashList;
        lite.hashList64 = hashList64;
        return lite;
      }


      Kssd(Kssd&&) = default;
      Kssd& operator=(Kssd&&) = default;

      ~Kssd() = default;
      std::unordered_set<uint32_t> hashSet;
      std::unordered_set<uint64_t> hashSet64;
      std::vector<uint64_t> hashList64;
      std::vector<uint32_t> hashList;

      std::string fileName;
      vector<uint32_t> storeHashes();
      vector<uint64_t> storeHashes64();
      void update(const char* seq);
      bool existFile(string fileName);
      bool isFastaList(string inputList);
      bool isFastqList(string inputList);
      bool isFastaGZList(string inputList);
      bool isFastqGZList(string inputList);
      int id;
      double jaccard(Kssd* kssd);
      double distance(Kssd* kssd);

      void loadHashes64(vector<uint64_t> hashArr);
      void loadHashes(vector<uint32_t> hashArr);
      //std::tuple<int, int, int, std::unique_ptr<int[]>> read_shuffled_file(std::string filepath);
      bool cmpSketch(sketch_t s1, sketch_t s2);

      //for result accuracy testing
      bool cmpSketchName(sketch_t s1, sketch_t s2);
      bool isSketchFile(string inputFile);
      //	void saveSketches(vector<Kssd*>& sketches, sketchInfo_t& info, string outputFile);
      void readSketches(vector<Kssd*>& sketches, sketchInfo_t& info, string inputFile);
      void printSketches(vector<Kssd*>& sketches, string outputFile);
      void printInfos(vector<Kssd*>& sketches, string outputFile);
      void convertSketch(vector<Kssd*>& sketches, sketchInfo_t& info, string inputDir, int numThreads);
      void tri_dist(vector<Kssd*>& sketches, string outputFile, int kmer_size, double maxDist, int numThreads);
      void dist(vector<Kssd*>& ref_sketches, vector<sketch_t>& query_sketches, string outputFile, int kmer_size, double maxDist, int numThreads);
      int get_half_subk();
      int get_drlevel();
      int get_half_k();

    private:
      kssd_parameter_t params_;
      int half_k_;
      int half_subk_;
      int drlevel_;
      //std::unique_ptr<int[]> shuffled_dim_;
      int * shuffled_dim_;
      int dim_size_;
      bool use64=  (half_k_ - drlevel_) > 8;
      int half_outctx_len;
      int rev_add_move;
      int kmer_size;
      int dim_start;
      int dim_end;
      int hashSize;
      int hashLimit;
      int component_num;
      int comp_bittl;

      uint64_t tupmask;
      uint64_t domask;
      uint64_t undomask;
      uint64_t undomask0;
      uint64_t undomask1;
      int get_hashSize(int half_k, int drlevel);
      void SetToList64();
      void SetToList();


      static const int BaseMap[128]; 

      robin_hood::unordered_map<uint32_t, int> shuffled_map;

  };

  void index_tridist(vector<KssdLite>& sketches, sketchInfo_t& info, string refSketchOut, string outputFile, int kmer_size, double maxDist, int isContainment, int numThreads);
  void saveSketches(vector<KssdLite>& sketches, Sketch::sketchInfo_t& info, std::string outputFile);
  void transSketches(vector<KssdLite>& sketches, sketchInfo_t& info, string dictFile, string indexFile, int numThreads);
  //	struct KSSDParameters
  //	{
  //		int half_k;
  //		int half_subk;
  //		int drlevel;
  //		int* shuffled_dim;
  //	
  //		int* shuffleN(int n, int base);
  //		int* shuffle(int arr[], int length);
  //		int get_hashSize(int half_k, int drlevel);
  //		int hashSize;
  //	
  //		KSSDParameters(int half_k_=10, int half_subk_=6, int drlevel_=3):
  //			half_k(half_k_), half_subk(half_subk_), drlevel(drlevel_)
  //		{
  //			int dim_size = 1 << 4 * half_subk;
  //			shuffled_dim = (int*)malloc(sizeof(int) * dim_size);
  //			shuffled_dim = shuffleN(dim_size, 0);
  //			shuffled_dim = shuffle(shuffled_dim, dim_size);
  //			hashSize = get_hashSize(half_k, drlevel);
  //		}
  //	
  //	};
  //
  //	class KSSD
  //	{
  //		public:
  //			KSSD(KSSDParameters parameter)
  //			{
  //				for(int i = 0; i< 128; i++)
  //				{
  //					BaseMap[i] = DEFAULT_CHAR_KSSD;
  //				}
  //				BaseMap['a'] = 0;
  //				BaseMap['c'] = 1;
  //				BaseMap['g'] = 2;
  //				BaseMap['t'] = 3;
  //				BaseMap['A'] = 0;
  //				BaseMap['C'] = 1;
  //				BaseMap['G'] = 2;
  //				BaseMap['T'] = 3;
  //				shuffled_dim = parameter.shuffled_dim;
  //				half_k = parameter.half_k;
  //				half_subk = parameter.half_subk;
  //				drlevel = parameter.drlevel;
  //				hashSize = parameter.hashSize;
  //	
  //	
  //				half_outctx_len = half_k - half_subk;
  //				rev_addmove = 4 * half_k - 2;
  //				kmer_size = 2 * half_k;
  //				dim_start = 0;
  //				dim_end = MIN_SUBCTX_DIM_SMP_SZ;
  //				hashLimit = hashSize * LD_FCTR;
  //				component_num = half_k - drlevel > COMPONENT_SZ ? 1LU << 4 * (half_k - drlevel - COMPONENT_SZ) : 1;
  //				comp_bittl = 64 - 4 * half_k;
  //				tupmask = _64MASK >> comp_bittl;
  //				domask = (tupmask >> (4 * half_outctx_len)) << (2 * half_outctx_len);
  //				undomask = (tupmask ^ domask) & tupmask;
  //				undomask1 = undomask &	(tupmask >> ((half_k + half_subk) * 2));
  //				undomask0 = undomask ^ undomask1;
  //	
  //			}
  //	
  //			void update(char* seq);
  //			double jaccard(KSSD* kssd);
  //			double distance(KSSD* kssd);
  //			void printHashes();
  //			vector<uint64_t> storeHashes();
  //			void loadHashes(vector<uint64_t> hashArr);
  //			int get_half_k();
  //			int get_half_subk();
  //			int get_drlevel();
  //	
  //		private:
  //			int half_k;
  //			int half_subk;
  //			int drlevel;
  //			int half_outctx_len;
  //			int rev_addmove;
  //			int kmer_size;
  //			int dim_start;
  //			int dim_end;
  //			int hashSize;
  //			int hashLimit;
  //			Reference reference;
  //			int component_num;
  //			int comp_bittl;
  //			int BaseMap[128];
  //			int* shuffled_dim;
  //	
  //			uint64_t tupmask;
  //			uint64_t domask;
  //			uint64_t undomask;
  //			uint64_t undomask0;
  //			uint64_t undomask1;
  //	
  //			vector<uint64_t> hashList;
  //			unordered_set<uint64_t> hashSet;
  //	
  //			int get_hashSize(int half_k, int drlevel);
  //			void SetToList();
  //	
  //	};


  class WMinHash{
    public:
      //WMinHash(int k = 21, int size = 50, int windowSize = 20, double paraDWeight = 0.0):
      WMinHash(WMHParameters parameters, double paraDWeight = 0.0):
        kmerSize(parameters.kmerSize), histoSketchSize(parameters.sketchSize), minimizerWindowSize(parameters.windowSize), paraDecayWeight(paraDWeight)
    {	
      //numBins = pow(kmerSize, alphabetSize); //need to be confirmed
      //histoDimension = pow(kmerSize, alphabetSize); //need to be confirmed
      numBins = pow(kmerSize, 4); //consult from HULK
      histoDimension = numBins; //need to be confirmed

      binsArr = (double *)malloc(numBins * sizeof(double));
      memset(binsArr, 0, numBins*sizeof(double));//init binsArr

      int g = ceil(2 / EPSILON);
      int d = ceil(log(1 - DELTA) / log(0.5));
      countMinSketch = (double *)malloc(d * g *sizeof(double));
      memset(countMinSketch, 0, d*g*sizeof(double));//init countMinSketch 

      r = parameters.r;
      c = parameters.c;
      b = parameters.b;

      //	//the r, c, b and getCWS need to be outClass
      //	r = (double *)malloc(histoSketchSize * histoDimension * sizeof(double));
      //	c = (double *)malloc(histoSketchSize * histoDimension * sizeof(double));
      //	b = (double *)malloc(histoSketchSize * histoDimension * sizeof(double));
      //	getCWS(r, c, b, histoSketchSize, histoDimension);

      ////for getCWS test debug
      //	FILE * fp;
      //	fp = fopen("cws.txt", "w");
      //	for(int i = 0; i < histoSketchSize*histoDimension; i++){
      //		fprintf(fp, "%ld\t%lf\t%lf\t%lf\n", i, r[i], c[i], b[i]);
      //	}

      histoSketches = (uint32_t *) malloc (histoSketchSize * sizeof(uint32_t));
      histoWeight = (double *) malloc (histoSketchSize * sizeof(double));
      for(int i = 0; i < histoSketchSize; i++){
        histoWeight[i] = DBL_MAX;
      }
      //memset(histoWeight, 0, histoSketchSize * sizeof(double));

      //add the applyConceptDrift and decayWeight.
      if(paraDecayWeight < 0.0 || paraDecayWeight > 1.0){
        cerr << "the paraDecayWeight must between 0.0 and 1.0 " << endl;
        exit(1);
      }
      else{
        applyConceptDrift = true;
      }
      if(paraDecayWeight == 1.0){
        applyConceptDrift = false;
      }
      decayWeight = 1.0;
      if(applyConceptDrift){
        decayWeight = exp(-paraDecayWeight);
      }

      needToCompute = true;

    }


      ~WMinHash();

      /// weightedMinHash is updatable with multiple sequences
      void update(char * seq);

      void computeHistoSketch();

      /// return the jaccard index
      double wJaccard(WMinHash * wmh);

      /// return the distance which is negative correlation with jaccard index
      double distance(WMinHash * wmh);

      /// print hash value fo debug
      void getWMinHash();

      //void setKmerSize(int kmerSizeNew) { kmerSize = kmerSizeNew; }
      //void setAlphabetSize(int alphabetSizeNew) { alphabetSize = alphabetSizeNew; }
      //void setNumBins(int numBinsNew) { numBins = numBinsNew; }
      //void setMinimizerWindowSize(int minimizerWindowSizeNew) { minimizerWindowSize = minimizerWindowSizeNew; }
      //void setHistoSketchSize(int histoSketchSizeNew); //{ histoSketchSize = histoSketchSizeNew; }
      //void setHistoDimension(int histoDimensionNew); //{ histoDimension = histoDimensionNew; }
      //void setParaDecayWeight(double paraDecayWeightNew) { paraDecayWeight = paraDecayWeightNew; }
      //void setApplyConceptDrift(bool applyConceptDriftNew) { applyConceptDrift = applyConceptDriftNew; }

      /// return kmerSize
      int getKmerSize() { return kmerSize; }

      /// return the minimizer window size
      int getMinimizerWindowSize() { return minimizerWindowSize; }

      //int getAlphabetSize() { return alphabetSize; }
      //int getNumBins() { return numBins; }
      //int getMinimizerWindowSize() { return minimizerWindowSize; }
      //int getHistoSketchSize() { return histoSketchSize; }
      //int getHistoDimension() { return histoDimension; }
      //double getParaDecayWeight() { return paraDecayWeight; }
      //bool isApplyComceptDrift() { return applyConceptDrift; }




    private:
      WMHParameters parameters;
      int kmerSize;
      int alphabetSize = 4;
      int numBins;
      int minimizerWindowSize;
      int histoSketchSize;
      int histoDimension;
      double paraDecayWeight;
      bool applyConceptDrift;
      double decayWeight;

      bool needToCompute = true;
      double * binsArr;
      double * countMinSketch; 
      std::vector<uint64_t> sketches;
      std::vector<Bin> kmerSpectrums;
      uint32_t * histoSketches;
      double * histoWeight;


      double * r;
      double * c;
      double * b;



  };

  //OMinHash
  struct OSketch {
    //std::string       name;
    int               k, l, m;
    std::vector<char> data;
    std::vector<char> rcdata;

    bool operator==(const OSketch& rhs) const {
      return k == rhs.k && l == rhs.l && m == rhs.m && data == rhs.data && rcdata == rhs.rcdata;
    }

  };

  /// Sketching and compare sequences or strings using Order MinHash algorithm.
  class OrderMinHash{

    public:
      /// OrderMinHash constructor
      OrderMinHash() : seq(nullptr), rcseq(nullptr), m_k(21), m_l(2), m_m(500), rc(false), mtSeed(32)  {};
      /// OrderMinHash constructor for sketching sequences using default parameters
      OrderMinHash(char * seqNew);
      ~OrderMinHash() {if (rcseq != NULL) delete rcseq;};

      /// return sketch result in `OSketch` type
      OSketch getSektch(){ return sk;}

      /** \rst
        Build a `OrderMinHash` sketch.
        `seqNew` is NULL pointer in default.
        If seqNew is NULL pointer, buildSketch() will rebuild sketh using old data.
        This is useful when chaning parameters and build a new sketch.
        \endrst
        */
      void buildSketch(char * seqNew);

      /** 
        Return similarity between two `OrderMinHash` sketches. In `OrderMinHash` class, there is no jaccard function provied. Because `OrderMinHash` is a proxy of edit distance instead of jaccard index.
        */
      double similarity(OrderMinHash & omh2);

      /// Return distance between two `OrderMinHash` sketches
      double distance(OrderMinHash & omh2)
      {
        return (double)1.0 - similarity(omh2);
      }

      /// Set parameter `kmerSize`: default 21.
      void setK(int k){ m_k = k; }

      /// Set parameter `l`: default 2 (normally 2 - 5).
      void setL(int l){ m_l = l; }

      /// Set parameter `m`: default 500.
      void setM(int m){ m_m = m; }

      /// Set seed value for random generator: default 32.
      void setSeed(uint64_t seedNew) { mtSeed = seedNew; }

      /** 
        Choose whether to deal with reverse complement sequences: default false.
        Reverse complement is normally used in biological sequences such as DNA or protein sequences.
        */
      void setReverseComplement(bool isRC){rc = isRC;}

      /// Return parameter `kmerSize`.
      int getK(){return m_k;}	

      /// Return parameter `l`.
      int getL(){return m_l;}	

      /// Return parameter `m`.
      int getM(){return m_m;}		

      /// Return random generator seed value.
      uint64_t getSeed() { return mtSeed; }

      /// Test whether to deal with reverse complement kmers.
      bool isReverseComplement(){return rc;}

    private:

      char * seq = NULL;
      char * rcseq = NULL;
      //Parameters parameters;
      int m_k = 21, m_l = 2, m_m = 500;
      //reverse complement
      bool rc = false;
      OSketch sk;
      uint64_t mtSeed = 32; //default value

      void sketch();

      inline void compute_sketch(char * ptr, const char * seq);

      double compare_sketches(const OSketch& sk1, const OSketch& sk2, 
          ssize_t m = -1, bool circular = false);
      double compare_sketch_pair(const char* p1, const char* p2,
          unsigned m, unsigned k, unsigned l, bool circular);

  };

  class HyperLogLog{

    public:
      HyperLogLog(int np):core_(1uL<<np,0),np_(np),is_calculated_(0),estim_(EstimationMethod::ERTL_MLE),jestim_(JointEstimationMethod::ERTL_JOINT_MLE) {};
      ~HyperLogLog(){};
      void update(char* seq);
      HyperLogLog merge(const HyperLogLog &other) const;
      void printSketch();
      double distance(const HyperLogLog &h2) const {return 1.0 - jaccard_index(h2);}
      //double jaccard_index(HyperLogLog &h2); 
      double jaccard_index(const HyperLogLog &h2) const; 

    protected:
      std::vector<uint8_t> core_;//sketchInfo; 
      mutable double value_; //cardinality
      uint32_t np_; // 10-20
      mutable uint8_t is_calculated_;
      EstimationMethod                        estim_;
      JointEstimationMethod                  jestim_;
      //HashStruct                                 hf_;

    private:
      uint32_t p() const {return np_;}//verification
      uint32_t q() const {return (sizeof(uint64_t) * CHAR_BIT) - np_;}
      uint64_t m() const {return static_cast<uint64_t>(1) << np_;}
      size_t size() const {return size_t(m());}
      bool get_is_ready() const {return is_calculated_;}
      const auto &core()    const {return core_;}
      EstimationMethod get_estim()       const {return  estim_;}
      JointEstimationMethod get_jestim() const {return jestim_;}
      void set_estim(EstimationMethod val) { estim_ = std::max(val, ERTL_MLE);}
      void set_jestim(JointEstimationMethod val) { jestim_ = val;}
      void set_jestim(uint16_t val) {set_jestim(static_cast<JointEstimationMethod>(val));}
      void set_estim(uint16_t val)  {estim_  = static_cast<EstimationMethod>(val);}

      // Returns cardinality estimate. Sums if not calculated yet.
      double creport() const {
        csum();
        return value_;
      }
      double report() noexcept {
        csum();
        return creport();
      }


      //private:
      void add(uint64_t hashval);
      void addh(const std::string &element);
      double alpha()          const {return make_alpha(m());}
      static double small_range_correction_threshold(uint64_t m) {return 2.5 * m;}
      double union_size(const HyperLogLog &other) const;
      // Call sum to recalculate if you have changed contents.
      void csum() const { if(!is_calculated_) sum(); }
      void sum() const {
        const auto counts(sum_counts(core_)); // std::array<uint32_t, 64>  // K->C
        value_ = calculate_estimate(counts, estim_, m(), np_, alpha(), 1e-2);
        is_calculated_ = 1;
      }
      std::array<uint32_t,64> sum_counts(const std::vector<uint8_t> &sketchInfo) const;
      double calculate_estimate(const std::array<uint32_t,64> &counts, EstimationMethod estim, uint64_t m, uint32_t p, double alpha, double relerr) const; 
      template<typename T>
        void compTwoSketch(const std::vector<uint8_t> &sketch1, const std::vector<uint8_t> &sketch2, T &c1, T &c2, T &cu, T &cg1, T &cg2, T &ceq) const;
      template<typename T>
        double ertl_ml_estimate(const T& c, unsigned p, unsigned q, double relerr=1e-2) const; 
      template<typename HllType>
        std::array<double, 3> ertl_joint(const HllType &h1, const HllType &h2) const; 



  };


  //std::tuple<int, int, int, std::unique_ptr<int[]>> read_shuffled_file(std::string filepath);
  //std::tuple<int, int, int, std::unique_ptr<int[]>> read_shuffled_file_wrapper(std::string filepath) {
  //    return read_shuffled_file(filepath);
  //}
}//namespace sketch

#endif //Sketch_h
