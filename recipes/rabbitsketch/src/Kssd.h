#include <iostream>
#include <vector>
#include <stdint.h>
#include <string>
#include "common.h"
#include <fstream>
//#include "Sketch.h"
using namespace std;

//typedef struct fileInfo
//{
//	string fileName;
//	uint64_t fileSize;
//} fileInfo_t;
//
//typedef struct sketch
//{
//	string fileName;
//	string seqName;
//	string comment;
//	int id;
//	vector<uint32_t> hashSet;
//	vector<uint64_t> hashSet64;
//} sketch_t;
//
//typedef struct sketchInfo
//{
//	int id;
//	int half_k;
//	int half_subk;
//	int drlevel;
//	int genomeNumber;
//} sketchInfo_t;
//
////for converting Kssd sketch into RabbitKSSD sketch format
//typedef struct co_dirstat
//{
//  unsigned int shuf_id;
//	bool koc;
//	int kmerlen;
//	int dim_rd_len;
//	int comp_num;
//	int infile_num;
//	uint64_t all_ctx_ct;
//} co_dstat_t;
//
//typedef struct setResult
//{
//	int common;
//	int size0;
//	int size1;
//	double jaccard;
//} setResult_t;
//
//struct DistInfo
//{
//	string refName;
//	int common;
//	int refSize;
//	double jorc;
//	double dist;
//};
//struct cmpDistInfo
//{
//	bool operator()(DistInfo d1, DistInfo d2){
//		return d1.dist < d2.dist;
//	}
//};
//
 

//bool existFile(string fileName);
//bool isFastaList(string inputList);
//bool isFastqList(string inputList);
//bool isFastaGZList(string inputList);
//bool isFastqGZList(string inputList);
//
//bool cmpSketch(sketch_t s1, sketch_t s2);
//
////for result accuracy testing
//bool cmpSketchName(sketch_t s1, sketch_t s2);
//
//bool isSketchFile(string inputFile);
//bool sketchFastaFile(string inputFile, bool isQuery, int numThreads, kssd_parameter_t parameter, vector<sketch_t>& sketches, sketchInfo_t& info, string outputFile);
//bool sketchFastqFile(string inputFile, bool isQuery, int numThreads, kssd_parameter_t parameter, int leastQual, int leastNumKmer, vector<sketch_t>& sketches, sketchInfo_t& info, string outputFile);
//void saveSketches(vector<sketch_t>& sketches, sketchInfo_t& info, string outputFile);
//void readSketches(vector<sketch_t>& sketches, sketchInfo_t& info, string inputFile);
//void transSketches(vector<sketch_t>& sketches, sketchInfo_t& info, string dictFile, string indexFile, int numThreads);
//void printSketches(vector<sketch_t>& sketches, string outputFile);
//void printInfos(vector<sketch_t>& sketches, string outputFile);
//void convertSketch(vector<sketch_t>& sketches, sketchInfo_t& info, string inputDir, int numThreads);
//void convert_from_RabbitKSSDSketch_to_KssdSketch(vector<sketch_t>& sketches, sketchInfo_t& info, string outputDir, int numThreads);
//void index_tridist(vector<sketch_t>& sketches, sketchInfo_t& info, string refSketchOut, string outputFile, int kmer_size, double maxDist, int isContainment, int numThreads);
//void tri_dist(vector<sketch_t>& sketches, string outputFile, int kmer_size, double maxDist, int numThreads);
//void index_dist(vector<sketch_t>& ref_sketches, sketchInfo_t& ref_info, string refSketchOut, vector<sketch_t>& query_sketches, string outputFile, int kmer_size, double maxDist, uint64_t maxNeighbor, bool isNeighbor, int isContainment, int numThreads);
//void dist(vector<sketch_t>& ref_sketches, vector<sketch_t>& query_sketches, string outputFile, int kmer_size, double maxDist, int numThreads);

