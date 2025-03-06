#include "MinHash.h"
#include "Sketch.h"
#include "MurmurHash3.h"
#include <sys/stat.h>
#include "hash.h"
#include <algorithm>
#include <iostream>
#include <omp.h>
#include <immintrin.h>
#include <string.h>
#include <list>
#include <cstring>
#include <stdint.h>
#include <math.h>
#include <cstring>
#include <cstdlib>
#include <unordered_set>
#include <queue>
#include "common.h"
#ifndef NOPYTHON
#include "pybind.h"
#endif

using namespace std;
using Sketch::sketchInfo_t;
//for compile cpu dispatch
#if defined __AVX512F__ && defined __AVX512CD__
uint32_t u32_intersect_vector_avx512(const uint32_t *list1,  uint32_t size1, const uint32_t *list2, uint32_t size2, uint32_t size3, uint64_t *i_a, uint64_t *i_b);
uint64_t u64_intersect_vector_avx512(const uint64_t *list1,  uint64_t size1, const uint64_t *list2, uint64_t size2, uint64_t size3, uint64_t *i_a, uint64_t *i_b);
#else 
#if defined __AVX2__
//implement by avx2

size_t u32_intersect_vector_avx2(const uint32_t *list1, uint32_t size1, const uint32_t *list2, uint32_t size2, uint32_t size3, uint64_t* i_a, uint64_t* i_b);

size_t u64_intersect_vector_avx2(const uint64_t *list1, uint64_t size1, const uint64_t *list2, uint64_t size2, uint64_t size3, uint64_t* i_a, uint64_t* i_b);
#else
#if defined __SSE4_1__
//implement by sse
uint64_t u64_intersection_vector_sse(const uint64_t *list1, uint64_t size1, const uint64_t *list2, uint64_t size2, uint64_t size3, uint64_t *i_a, uint64_t *i_b);

uint64_t u32_intersection_vector_sse(const uint32_t *list1, uint64_t size1, const uint32_t *list2, uint64_t size2, uint64_t size3, uint64_t *i_a, uint64_t *i_b);

#else
//implement without optimization
#endif
#endif
#endif

hash_u HashList::at(int index) const
{
	hash_u hash;

	if ( use64 )
	{
		hash.hash64 = hashes64.at(index);
	}
	else
	{
		hash.hash32 = hashes32.at(index);
	}

	return hash;
}

void HashList::clear()
{
	if ( use64 )
	{
		std::vector<hash64_t>().swap(hashes64);
	}
	else
	{
		std::vector<hash32_t>().swap(hashes32);
	}
}

void HashList::resize(int size)
{
	if ( use64 )
	{
		hashes64.resize(size);
	}
	else
	{
		hashes32.resize(size);
	}
}

void HashList::set32(int index, uint32_t value)
{
	hashes32[index] = value;
}

void HashList::set64(int index, uint64_t value)
{
	hashes64[index] = value;
}

void HashList::sort()
{
	if ( use64 )
	{
		std::sort(hashes64.begin(), hashes64.end());
	}
	else
	{
		std::sort(hashes32.begin(), hashes32.end());
	}
}

void HashPriorityQueue::clear()
{
	if ( use64 )
	{
		std::priority_queue<hash64_t>().swap(queue64);
		//while ( queue64.size() )
		//{
		//    queue64.pop();
		//}
	}
	else
	{
		std::priority_queue<hash32_t>().swap(queue32);
		//while ( queue32.size() )
		//{
		//    queue32.pop();
		//}
	}
}

hash_u HashPriorityQueue::top() const
{
	hash_u hash;

	if ( use64 )
	{
		hash.hash64 = queue64.top();
	}
	else
	{
		hash.hash32 = queue32.top();
	}

	return hash;
}

uint32_t HashSet::count(hash_u hash) const
{
	if ( use64 )
	{
		if ( hashes64.count(hash.hash64) )
		{
			return hashes64.at(hash.hash64);
		}
		else
		{
			return 0;
		}
	}
	else
	{
		if ( hashes32.count(hash.hash32) )
		{
			return hashes32.at(hash.hash32);
		}
		else
		{
			return 0;
		}
	}
}

void HashSet::erase(hash_u hash)
{
	if ( use64 )
	{
		hashes64.erase(hash.hash64);
	}
	else
	{
		hashes32.erase(hash.hash32);
	}
}

void HashSet::insert(hash_u hash, uint32_t count)
{
	if ( use64 )
	{
		hash64_t hash64 = hash.hash64;

		if ( hashes64.count(hash64) )
		{
			hashes64[hash64] = hashes64.at(hash64) + count;
		}
		else
		{
			hashes64[hash64] = count;
		}
	}
	else
	{
		hash32_t hash32 = hash.hash32;

		if ( hashes32.count(hash32) )
		{
			hashes32[hash32] = hashes32.at(hash32) + count;
		}
		else
		{
			hashes32[hash32] = count;
		}
	}
}

void HashSet::toCounts(std::vector<uint32_t> & counts) const
{
	if ( use64 )
	{
		for ( robin_hood::unordered_map<hash64_t, uint32_t>::const_iterator i = hashes64.begin(); i != hashes64.end(); ++i )
		{
			counts.push_back(i->second);
		}
	}
	else
	{
		for ( robin_hood::unordered_map<hash32_t, uint32_t>::const_iterator i = hashes32.begin(); i != hashes32.end(); ++i )
		{
			counts.push_back(i->second);
		}
	}
}

void HashSet::toHashList(HashList & hashList) const
{
	if ( use64 )
	{
		for ( robin_hood::unordered_map<hash64_t, uint32_t>::const_iterator i = hashes64.begin(); i != hashes64.end(); ++i )
		{
			hashList.push_back64(i->first);
		}
	}
	else
	{
		for ( robin_hood::unordered_map<hash32_t, uint32_t>::const_iterator i = hashes32.begin(); i != hashes32.end(); ++i )
		{
			hashList.push_back32(i->first);
		}
	}
}

MinHashHeap::MinHashHeap(bool use64New, uint64_t cardinalityMaximumNew, uint64_t multiplicityMinimumNew, uint64_t memoryBoundBytes) :
	use64(use64New),
	hashes(use64New),
	hashesQueue(use64New),
	hashesPending(use64New),
	hashesQueuePending(use64New)
{
	cardinalityMaximum = cardinalityMaximumNew;
	multiplicityMinimum = multiplicityMinimumNew;

	multiplicitySum = 0;

}

MinHashHeap::~MinHashHeap()
{}

void MinHashHeap::computeStats()
{
	vector<uint32_t> counts;
	hashes.toCounts(counts);

	for ( int i = 0; i < counts.size(); i++ )
	{
		cout << counts.at(i) << endl;
	}
}

void MinHashHeap::clear()
{
	hashes.clear();
	hashesQueue.clear();

	hashesPending.clear();
	hashesQueuePending.clear();

	multiplicitySum = 0;
}

void MinHashHeap::tryInsert(hash_u hash)
{
	if
		(
		 hashes.size() < cardinalityMaximum ||
		 hashLessThan(hash, hashesQueue.top(), use64)
		)
		{
			if ( hashes.count(hash) == 0 )
			{

				if ( multiplicityMinimum == 1 || hashesPending.count(hash) == multiplicityMinimum - 1 )
				{
					hashes.insert(hash, multiplicityMinimum);
					hashesQueue.push(hash);
					multiplicitySum += multiplicityMinimum;

					if ( multiplicityMinimum > 1 )
					{
						// just remove from set for now; will be removed from
						// priority queue when it's on top
						//
						hashesPending.erase(hash);
					}
				}
				else
				{
					if ( hashesPending.count(hash) == 0 )
					{
						hashesQueuePending.push(hash);
					}

					hashesPending.insert(hash, 1);
				}
			}
			else
			{
				hashes.insert(hash, 1);
				multiplicitySum++;
			}

			if ( hashes.size() > cardinalityMaximum )
			{
				multiplicitySum -= hashes.count(hashesQueue.top());
				hashes.erase(hashesQueue.top());

				// loop since there could be zombie hashes (gone from hashesPending)
				//
				while ( hashesQueuePending.size() > 0 && hashLessThan(hashesQueue.top(), hashesQueuePending.top(), use64) )
				{
					if ( hashesPending.count(hashesQueuePending.top()) )
					{
						hashesPending.erase(hashesQueuePending.top());
					}

					hashesQueuePending.pop();
				}

				hashesQueue.pop();
			}
		}
}

hash_u getHash(const char * seq, int length, uint32_t seed, bool use64)
{

#ifdef ARCH_32
	char data[use64 ? 8 : 4];
	MurmurHash3_x86_32(seq, length > 16 ? 16 : length, seed, data);
	if ( use64 )
	{
		MurmurHash3_x86_32(seq + 16, length - 16, seed, data + 4);
	}
#else
	char data[16];
	MurmurHash3_x64_128(seq, length, seed, data);
#endif

	hash_u hash;

	if ( use64 )
	{
		hash.hash64 = *((hash64_t *)data);
	}
	else
	{
		hash.hash32 = *((hash32_t *)data);
	}

	return hash;
}

bool hashLessThan(hash_u hash1, hash_u hash2, bool use64)
{
	if ( use64 )
	{
		return hash1.hash64 < hash2.hash64;
	}
	else
	{
		return hash1.hash32 < hash2.hash32;
	}
}


namespace Sketch
{



	void saveMinHashes(vector<Sketch::MashLite>& sketches, Sketch::sketchInfo_t& info, string outputFile){
		bool use64 = info.half_k - info.drlevel > 8 ? true : false;
		FILE * fp = fopen(outputFile.c_str(), "w+");
		int sketchNumber = sketches.size();
		info.genomeNumber = sketchNumber;
		info.id = (info.half_k << 8) + (info.half_subk << 4) + info.drlevel;
		fwrite(&info, sizeof(Sketch::sketchInfo_t), 1, fp);

		int * genomeNameSize = new int[sketchNumber];
		int * hashsize = new int[sketchNumber];
		//uint64_t totalNumber = 0;
		//uint64_t totalLength = 0;
		for(int i = 0; i < sketchNumber; i++){
			genomeNameSize[i] = sketches[i].fileName.length();
				hashsize[i] = sketches[i].hashList64.size();
			//totalNumber += hashsize[i];
			//totalLength += genomeNameSize[i];
		}
		//cerr << "the sketches size is: " << sketchNumber << endl;
		//cerr << "the total hash number is: " << totalNumber << endl;
		//cerr << "the total name length is: " << totalLength << endl;
		//fwrite(&parameter, sizeof(kssd_parameter_t), 1, fp);
		//fwrite(&sketchNumber, sizeof(int), 1, fp);
		fwrite(genomeNameSize, sizeof(int), sketchNumber, fp);
		fwrite(hashsize, sizeof(int), sketchNumber, fp);
		for(int i = 0; i < sketchNumber; i++){
			const char * namePoint = sketches[i].fileName.c_str();
			fwrite(namePoint, sizeof(char), genomeNameSize[i], fp);
				uint64_t * curPoint = sketches[i].hashList64.data();
				fwrite(curPoint, sizeof(uint64_t), hashsize[i], fp);
		}
		fclose(fp);
		delete [] genomeNameSize;
		delete [] hashsize;

	}



#if defined __AVX512F__ && defined __AVX512CD__
	__m512i inline min512(__m512i v1, __m512i v2){
		__mmask8 msk_gt, msk_lt;
		msk_gt = _mm512_cmpgt_epi64_mask(v1, v2);
		msk_lt = _mm512_cmplt_epi64_mask(v1, v2);

		return (msk_gt < msk_lt) ? v1 : v2;
	}

	void inline transpose8_epi64(__m512i *row0, __m512i* row1, __m512i* row2,__m512i* row3, __m512i* row4, __m512i * row5,__m512i* row6,__m512i * row7)
	{
		__m512i __t0,__t1,__t2,__t3,__t4,__t5,__t6,__t7;
		__m512i __tt0,__tt1,__tt2,__tt3,__tt4,__tt5,__tt6,__tt7;

		__m512i idx1,idx2;
		idx1 = _mm512_set_epi64(0xD,0xC,0x5,0x4,0x9,0x8,0x1,0x0);
		idx2 = _mm512_set_epi64(0xF,0xE,0x7,0x6,0xB,0xA,0x3,0x2);

		__t0 = _mm512_unpacklo_epi64(*row0,*row1);
		__t1 = _mm512_unpackhi_epi64(*row0,*row1);
		__t2 = _mm512_unpacklo_epi64(*row2,*row3);
		__t3 = _mm512_unpackhi_epi64(*row2,*row3);
		__t4 = _mm512_unpacklo_epi64(*row4,*row5);
		__t5 = _mm512_unpackhi_epi64(*row4,*row5);
		__t6 = _mm512_unpacklo_epi64(*row6,*row7);
		__t7 = _mm512_unpackhi_epi64(*row6,*row7);


		__tt0 = _mm512_permutex2var_epi64(__t0,idx1,__t2);
		__tt2 = _mm512_permutex2var_epi64(__t0,idx2,__t2);
		__tt1 = _mm512_permutex2var_epi64(__t1,idx1,__t3);
		__tt3 = _mm512_permutex2var_epi64(__t1,idx2,__t3);
		__tt4 = _mm512_permutex2var_epi64(__t4,idx1,__t6);
		__tt6 = _mm512_permutex2var_epi64(__t4,idx2,__t6);
		__tt5 = _mm512_permutex2var_epi64(__t5,idx1,__t7);
		__tt7 = _mm512_permutex2var_epi64(__t5,idx2,__t7);

		*row0 = _mm512_shuffle_i64x2(__tt0,__tt4,0x44);
		*row1 = _mm512_shuffle_i64x2(__tt1,__tt5,0x44);
		*row2 = _mm512_shuffle_i64x2(__tt2,__tt6,0x44);
		*row3 = _mm512_shuffle_i64x2(__tt3,__tt7,0x44);

		*row4 = _mm512_shuffle_i64x2(__tt0,__tt4,0xEE);
		*row5 = _mm512_shuffle_i64x2(__tt1,__tt5,0xEE);
		*row6 = _mm512_shuffle_i64x2(__tt2,__tt6,0xEE);
		*row7 = _mm512_shuffle_i64x2(__tt3,__tt7,0xEE);
	}
#else 
#ifdef __AVX2__
	// implement by avx2
	void inline transpose4_epi64(__m256i *row1, __m256i *row2, __m256i *row3, __m256i *row4)
	{
		__m256i vt1, vt2, vt3, vt4;

		vt1 = _mm256_unpacklo_epi64(*row1, *row2);
		vt2 = _mm256_unpackhi_epi64(*row1, *row2);
		vt3 = _mm256_unpacklo_epi64(*row3, *row4);
		vt4 = _mm256_unpackhi_epi64(*row3, *row4);

		*row1 =_mm256_permute2x128_si256(vt1, vt3, 0x20);
		*row2 =_mm256_permute2x128_si256(vt2, vt4, 0x20);
		*row3 =_mm256_permute2x128_si256(vt1, vt3, 0x31);
		*row4 =_mm256_permute2x128_si256(vt2, vt4, 0x31);
	}

#else
	//non vectorization 
#endif
#endif




	void transMinHashes(vector<Sketch::MashLite>& sketches, Sketch::sketchInfo_t& info, string dictFile, string indexFile, int numThreads){
		//int half_k = info.half_k;
		//int drlevel = info.drlevel;
		bool use64 = true;
		//bool use64 = half_k - drlevel > 8 ? true : false;
		if(use64)
			cerr << "transSketches: use64" << endl;
		else
			cerr << "transSketches: not use64" << endl;

		double t0 = get_sec();
		//size_t dict_size = (1LLU << (4*(half_k-drlevel))) / 64;
		//uint64_t* dict = (uint64_t*)malloc(dict_size * sizeof(uint64_t));
		//memset(dict, 0, dict_size * sizeof(uint64_t));
		robin_hood::unordered_map<uint64_t, vector<uint32_t>> hash_map_arr;
		//std::unordered_map<uint64_t, vector<uint32_t>> hash_map_arr;
		//std::map<uint64_t, vector<uint32_t>> hash_map_arr;
		for(size_t i = 0; i < sketches.size(); i++){
			#pragma omp parallel for num_threads(numThreads) schedule(dynamic)
			for(size_t j = 0; j < sketches[i].hashList64.size(); j++){
				uint64_t cur_hash = sketches[i].hashList64[j];
				//cerr << cur_hash << endl;
				//dict[cur_hash/64] |= (0x8000000000000000LLU >> (cur_hash % 64));
				#pragma omp critical
				{
				hash_map_arr.insert({cur_hash, vector<uint32_t>()});
				hash_map_arr[cur_hash].push_back(i);
			}
			}
		}
		//string filterFile = indexFile + ".filter";
		//FILE* fp_filter = fopen(filterFile.c_str(), "w+");
		//fwrite(dict, sizeof(uint64_t), dict_size, fp_filter);
		//fclose(fp_filter);
		//free(dict);
		double t1 = get_sec();
#ifdef Timer_inner
		cerr << "the time of generate the bloom dictionary and hash_map_arr is: " << t1 - t0 << endl;
#endif
		size_t hash_number = hash_map_arr.size();
		size_t total_size = 0;
		uint64_t* hash_arr = (uint64_t*)malloc(hash_number * sizeof(uint64_t));
		uint32_t* hash_size_arr = (uint32_t*)malloc(hash_number * sizeof(uint32_t));
		FILE* fp_dict = fopen(dictFile.c_str(), "w+");
		if(!fp_dict){
			cerr << "ERROR: transSketches, cannot open dictFile: " << dictFile << endl;
			exit(1);
		}
		size_t cur_id = 0;
		for(auto x : hash_map_arr){
			hash_arr[cur_id] = x.first;
			fwrite(x.second.data(), sizeof(uint32_t), x.second.size(), fp_dict);
			hash_size_arr[cur_id] = x.second.size();
			total_size += x.second.size();
			cur_id++;
		}
		cerr << "the total size is: " << total_size << endl;
		fclose(fp_dict);
		double t2 = get_sec();
#ifdef Timer_inner
		cerr << "the time of writing dictFile is: " << t2 - t1 << endl;
#endif

		FILE* fp_index = fopen(indexFile.c_str(), "w+");
		if(!fp_index){
			cerr << "ERROR: transSketches, cannot open indexFile: " << indexFile << endl;
			exit(1);
		}
		fwrite(&hash_number, sizeof(size_t), 1, fp_index);
		fwrite(hash_arr, sizeof(uint64_t), hash_number, fp_index);
		fwrite(hash_size_arr, sizeof(uint32_t), hash_number, fp_index);
		fclose(fp_index);
		double t3 = get_sec();
#ifdef Timer_inner
		cerr << "the time of writing indexFile is: " << t3 - t2 << endl;
#endif

		//cerr << "the hashSize is: " << hashSize << endl;
		//cerr << "the totalIndex is: " << totalIndex << endl;

		cerr << "Finish trans"<< endl;
	}



	void index_tridist_MinHash(vector<MashLite>& sketches, Sketch::sketchInfo_t& info, string refSketchOut, string outputFile, int kmer_size, double maxDist, int isContainment, int numThreads){

#ifdef Timer
		double t0 = get_sec();
#endif
		string indexFile = refSketchOut + ".index";
		string dictFile = refSketchOut + ".dict";
		//bool use64 = info.half_k - info.drlevel > 8 ? true : false;
		bool use64 = true;
		robin_hood::unordered_map<uint64_t, vector<uint32_t>> hash_map_arr;
		uint32_t* sketchSizeArr = NULL;
		size_t* offset = NULL;
		uint32_t* indexArr = NULL;
		//uint64_t* dict;
		if(use64)
		{
			cerr << "-----use hash64 in index_tridist() " << endl;
			size_t hash_number;
			FILE* fp_index = fopen(indexFile.c_str(), "rb");
			if(!fp_index){
				cerr << "ERROR: index_tridist(), cannot open index file: " << indexFile << endl;
				exit(1);
			}
			int read_hash_num = fread(&hash_number, sizeof(size_t), 1, fp_index);
			uint64_t * hash_arr = new uint64_t[hash_number];
			uint32_t * hash_size_arr = new uint32_t[hash_number];
			size_t read_hash_arr = fread(hash_arr, sizeof(uint64_t), hash_number, fp_index);
			size_t read_hash_size_arr = fread(hash_size_arr, sizeof(uint32_t), hash_number, fp_index);
			if(read_hash_num != 1 || read_hash_arr != hash_number || read_hash_size_arr != hash_number){
				cerr << "ERROR: index_tridist(), error read hash_number, hash_arr, and hash_size_arr" << endl;
				exit(1);
			}

			fclose(fp_index);

			FILE* fp_dict = fopen(dictFile.c_str(), "rb");
			if(!fp_dict){
				cerr << "ERROR: index_tridist(), cannot open dict file: " << dictFile << endl;
				exit(1);
			}
			uint32_t max_hash_size = 1LLU << 24;
			uint32_t* cur_point = new uint32_t[max_hash_size];
			for(size_t i = 0; i < hash_number; i++){
				uint32_t cur_hash_size = hash_size_arr[i];
				if(cur_hash_size > max_hash_size){
					max_hash_size = cur_hash_size;
					cur_point = new uint32_t[max_hash_size];
				}
				uint32_t hash_size = fread(cur_point, sizeof(uint32_t), cur_hash_size, fp_dict);
				if(hash_size != cur_hash_size){
					cerr << "ERROR: index_tridist(), the read hash number is not equal to the saved hash number information" << endl;
					exit(1);
				}
				vector<uint32_t> cur_genome_arr(cur_point, cur_point + cur_hash_size);
				uint64_t cur_hash = hash_arr[i];
				hash_map_arr.insert({cur_hash, cur_genome_arr});
			}
			delete [] cur_point;
			delete [] hash_arr;
			delete [] hash_size_arr;
			fclose(fp_dict);
		}
		else
		{
			cerr << "-----not use hash64 in index_tridist() " << endl;
			size_t hashSize;
			uint64_t totalIndex;
			FILE * fp_index = fopen(indexFile.c_str(), "rb");
			if(!fp_index){
				cerr << "ERROR: index_tridist(), cannot open the index sketch file: " << indexFile << endl;
				exit(1);
			}
			int read_hash_size = fread(&hashSize, sizeof(size_t), 1, fp_index);
			int read_total_index = fread(&totalIndex, sizeof(uint64_t), 1, fp_index);
			//sketchSizeArr = (uint32_t*)malloc(hashSize * sizeof(uint32_t));
			sketchSizeArr = new uint32_t[hashSize];
			size_t read_sketch_size_arr = fread(sketchSizeArr, sizeof(uint32_t), hashSize, fp_index);

			//offset = (size_t*)malloc(hashSize * sizeof(size_t));
			offset = new size_t[hashSize];
			uint64_t totalHashNumber = 0;
			for(size_t i = 0; i < hashSize; i++){
				totalHashNumber += sketchSizeArr[i];
				offset[i] = sketchSizeArr[i];
				if(i > 0) offset[i] += offset[i-1];
			}
			if(totalHashNumber != totalIndex){
				cerr << "ERROR: index_tridist(), mismatched total hash number" << endl;
				exit(1);
			}
			fclose(fp_index);

			//cerr << "the hashSize is: " << hashSize << endl;
			//cerr << "totalIndex is: " << totalIndex << endl;
			//cerr << "totalHashNumber is: " << totalHashNumber << endl;
			//cerr << "offset[n-1] is: " << offset[hashSize-1] << endl;;

			//indexArr = (uint32_t*)malloc(totalHashNumber * sizeof(uint32_t));
			indexArr = new uint32_t[totalHashNumber];
			FILE * fp_dict = fopen(dictFile.c_str(), "rb");
			if(!fp_dict){
				cerr << "ERROR: index_tridist(), cannot open the dictionary sketch file: " << dictFile << endl;
				exit(1);
			}
			size_t read_index_arr = fread(indexArr, sizeof(uint32_t), totalHashNumber, fp_dict);
			if(read_hash_size != 1 || read_total_index != 1 || read_sketch_size_arr != hashSize || read_index_arr != totalHashNumber){
				cerr << "ERROR: index_tridist(), error read hash_size, total_index, sketch_size_arr, index_arr" << endl;
				exit(1);
			}
		}

#ifdef Timer
		double t1 = get_sec();
		cerr << "===================time of read index and offset sketch file is: " << t1 - t0 << endl;
#endif
		size_t numRef = sketches.size();

		vector<FILE*> fpArr;
		vector<FILE*> fpIndexArr;
		vector<string> dist_file_list;
		vector<string> dist_index_list;
		//vector<int*> intersectionArr;
		int** intersectionArr = new int*[numThreads];

		string folderPath = outputFile + ".dir";
		string command0 = "mkdir -p " + folderPath;
		int status = system(command0.c_str());
		if(!status){
			cerr << "success create: " << folderPath << endl;
		}

		for(int i = 0; i < numThreads; i++)
		{
			string tmpName = folderPath + '/' + outputFile + '.' + to_string(i);
			dist_file_list.push_back(tmpName);
			FILE * fp0 = fopen(tmpName.c_str(), "w+");
			fpArr.push_back(fp0);

			string tmpIndexName = outputFile + ".index." + to_string(i);
			dist_index_list.push_back(tmpIndexName);
			FILE * fp1 = fopen(tmpIndexName.c_str(), "w+");
			fpIndexArr.push_back(fp1);

			//int * arr = (int*)malloc(numRef * sizeof(int));
			//int* arr = new int[numRef];
			//intersectionArr.push_back(arr);
			intersectionArr[i] = new int[numRef];
		}

		//cerr << "before generate the intersection " << endl;

		int progress_bar_size = get_progress_bar_size(numRef);
		cerr << "=====total: " << numRef << endl;
#pragma omp parallel for num_threads(numThreads) schedule(dynamic)
		for(size_t i = 0; i < numRef; i++){
			if(i % progress_bar_size == 0) cerr << "=====finish: " << i << endl;
			int tid = omp_get_thread_num();
			fprintf(fpIndexArr[tid], "%s\t%s\n", sketches[i].fileName.c_str(), dist_file_list[tid].c_str());
			memset(intersectionArr[tid], 0, numRef * sizeof(int));
				for(size_t j = 0; j < sketches[i].hashList64.size(); j++){
					uint64_t hash64 = sketches[i].hashList64[j];
					//if(!(dict[hash64/64] & (0x8000000000000000LLU >> (hash64 % 64))))	continue;
					if(hash_map_arr.count(hash64) == 0) continue;
					//for(auto x : hash_map_arr[hash64])
					for(size_t k = 0; k < hash_map_arr[hash64].size(); k++){
						size_t cur_index = hash_map_arr[hash64][k];
						intersectionArr[tid][cur_index]++;
						//cerr << hash64 << '\t' << cur_index << endl;
					}
				}

			string strBuf("");
			for(size_t j = i+1; j < numRef; j++){
				int common = intersectionArr[tid][j];
				int size0, size1;
				//		if(use64){
				//			size0 = sketches[i]->storeMinHashes().size();
				//			size1 = sketches[j]->storeMinHashes().size();
				//		}
				//		else{
				size0 = sketches[i].hashList64.size();
				size1 = sketches[j].hashList64.size();
				//		}
				if(!isContainment){
					int denom = size0 + size1 - common;
					double jaccard;
					if(size0 == 0 || size1 == 0)
						jaccard = 0.0;
					else
						jaccard = (double)common / denom;
					double mashD;
					if(jaccard == 1.0)
						mashD = 0.0;
					else if(jaccard == 0.0)
						mashD = 1.0;
					else
						mashD = (double)-1.0 / kmer_size * log((2 * jaccard)/(1.0 + jaccard));
					if(mashD < maxDist){
						strBuf += sketches[j].fileName + '\t' + sketches[i].fileName + '\t' + to_string(common) + '|' + to_string(size0) + '|' + to_string(size1) + '\t' + to_string(jaccard) + '\t' + to_string(mashD) + '\n';
					}
					//fprintf(fpArr[tid], " %s\t%s\t%d|%d|%d\t%lf\t%lf\n", sketches[j].fileName.c_str(), sketches[i].fileName.c_str(), common, size0, size1, jaccard, mashD);
				}
				else{
					int denom = std::min(size0, size1);
					double containment;
					if(size0 == 0 || size1 == 0)
						containment = 0.0;
					else
						containment = (double)common / denom;
					double AafD;
					if(containment == 1.0)
						AafD = 0.0;
					else if(containment == 0.0)
						AafD = 1.0;
					else
						AafD = (double)-1.0 / kmer_size * log(containment);
					if(AafD < maxDist)
						strBuf += sketches[j].fileName + '\t' + sketches[i].fileName + '\t' + to_string(common) + '|' + to_string(size0) + '|' + to_string(size1) + '\t' + to_string(containment) + '\t' + to_string(AafD) + '\n';
					//fprintf(fpArr[tid], " %s\t%s\t%d|%d|%d\t%lf\t%lf\n", sketches[j].fileName.c_str(), sketches[i].fileName.c_str(), common, size0, size1, containment, AafD);
				}
			}
			fprintf(fpArr[tid], "%s", strBuf.c_str());
			strBuf = "";
		}


		//cerr << "finished multithread computing" << endl;

		for(int i = 0; i < numThreads; i++)
		{
			fclose(fpArr[i]);
			fclose(fpIndexArr[i]);
			delete [] intersectionArr[i];
		}
		//cerr << "finished fpArr fclose" << endl;

#ifdef Timer
		double t2 = get_sec();
		cerr << "===================time of multiple threads distance computing and save the subFile is: " << t2 - t1 << endl;
#endif

		uint64_t totalSize = 0;
		uint64_t maxSize = 1LLU << 32; //max total distance file size 4GB
		bool isMerge = false;
		for(int i = 0; i < numThreads; i++){
			struct stat cur_stat;
			stat(dist_file_list[i].c_str(), &cur_stat);
			uint64_t curSize = cur_stat.st_size;
			totalSize += curSize;
		}
		if(totalSize <= maxSize)	isMerge = true;

		if(isMerge){
			FILE * cofp;
			FILE * com_cofp = fopen(outputFile.c_str(), "w");
			cerr << "-----save the output distance file: " << outputFile << endl;
			fprintf(com_cofp, " genome0\tgenome1\tcommon|size0|size1\tjaccard\tmashD\n");
			int bufSize = 1 << 24;
			int lengthRead = 0;
			char * bufRead = (char*)malloc((bufSize+1) * sizeof(char));
			for(int i = 0; i < numThreads; i++)
			{
				cofp = fopen(dist_file_list[i].c_str(), "rb+");
				while(1)
				{
					lengthRead = fread(bufRead, sizeof(char), bufSize, cofp);
					//cerr << "the lengthRead is: " << lengthRead << endl;
					fwrite(bufRead, sizeof(char), lengthRead, com_cofp);
					if(lengthRead < bufSize) break;
				}
				fclose(cofp);
				remove(dist_file_list[i].c_str());
				remove(dist_index_list[i].c_str());
			}
			remove(folderPath.c_str());

			free(bufRead);
			fclose(com_cofp);
		}
		else{
			cerr << "-----the output distance file is too big to merge into one single file, saving the result into directory: " << folderPath << endl;
			FILE * cofp1;
			string outputIndexFile = outputFile + ".index";
			cerr << "-----save the index between genomes and distance sub-files into: " << outputIndexFile << endl;
			FILE * com_cofp1 = fopen(outputIndexFile.c_str(), "w+");
			fprintf(com_cofp1, "genomeName\tdistFileName\n");
			int bufSize = 1 << 24;
			int lengthRead = 0;
			char * bufRead = (char*)malloc((bufSize+1) * sizeof(char));
			for(int i = 0; i < numThreads; i++){
				cofp1 = fopen(dist_index_list[i].c_str(), "rb+");
				while(1){
					lengthRead = fread(bufRead, sizeof(char), bufSize, cofp1);
					fwrite(bufRead, sizeof(char), lengthRead, com_cofp1);
					if(lengthRead < bufSize) break;
				}
				fclose(cofp1);
				remove(dist_index_list[i].c_str());
			}
			free(bufRead);
			fclose(com_cofp1);
		}

#ifdef Timer
		double t3 = get_sec();
		cerr << "===================time of merge the subFiles into final files is: " << t3 - t2 << endl;
#endif

	}








	void MinHash::update(char * seq)
	{
		const uint64_t length = strlen(seq);
		totalLength += length;

		// to uppercase 
		// note: kmers sequences with different cases will lead to different hashes
		if( ! preserveCase )
			for ( uint64_t i = 0; i < length; i++ )
			{
				if ( seq[i] > 96 && seq[i] < 123 )
				{
					seq[i] -= 32;
				}
			}

		char * seqRev;

		if ( ! noncanonical )
		{
			seqRev = new char[length];
			reverseComplement(seq, seqRev, length);
		}

#if defined __AVX512F__ && defined __AVX512BW__

		int pend_k = ((kmerSize - 1) / 16 + 1) * 16;
		int n_kmers = length - kmerSize + 1;
		int n_kmers_body = (n_kmers / 16) * 16;

		const uint8_t* input8 = (const uint8_t *)seq;
		const uint8_t* input8_rev = (const uint8_t *)seqRev;
		uint64_t res[16 * 2];
		uint64_t res2[2];
		uint8_t kmer_buf[kmerSize];

		__m512i v0, v1;
		__m512i vi[8];
		__m512i vj[8];
		__m512i vi_forword[8];
		__m512i vi_reverse[8];
		__m512i vj_forword[8];
		__m512i vj_reverse[8];
		__m512i vzero = _mm512_setzero_si512();

		__mmask64 mask_load = 0xffffffffffffffff;
		mask_load >>= (64 - kmerSize);

		for(int i = 0; i < n_kmers_body-1; i+=16)
		{
			vi_forword[0] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 0);
			vi_forword[1] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 1);
			vi_forword[2] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 2);
			vi_forword[3] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 3);
			vi_forword[4] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 4);
			vi_forword[5] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 5);
			vi_forword[6] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 6);
			vi_forword[7] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 7);


			vj_forword[0] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 8);
			vj_forword[1] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 9);
			vj_forword[2] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 10);
			vj_forword[3] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 11);
			vj_forword[4] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 12);
			vj_forword[5] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 13);
			vj_forword[6] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 14);
			vj_forword[7] = _mm512_mask_loadu_epi8(vzero, mask_load, input8 + i + 15);

			if( !noncanonical){

				vi_reverse[0] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 0 - kmerSize);
				vi_reverse[1] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 1 - kmerSize);
				vi_reverse[2] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 2 - kmerSize);
				vi_reverse[3] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 3 - kmerSize);
				vi_reverse[4] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 4 - kmerSize);
				vi_reverse[5] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 5 - kmerSize);
				vi_reverse[6] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 6 - kmerSize);
				vi_reverse[7] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 7 - kmerSize);

				vj_reverse[0] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 8 - kmerSize);
				vj_reverse[1] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 9 - kmerSize);
				vj_reverse[2] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 10 - kmerSize);
				vj_reverse[3] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 11 - kmerSize);
				vj_reverse[4] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 12 - kmerSize);
				vj_reverse[5] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 13 - kmerSize);
				vj_reverse[6] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 14 - kmerSize);
				vj_reverse[7] = _mm512_mask_loadu_epi8(vzero, mask_load, input8_rev + length - i - 15 - kmerSize);


				vi[0] = min512(vi_forword[0], vi_reverse[0]);
				vi[1] = min512(vi_forword[1], vi_reverse[1]);
				vi[2] = min512(vi_forword[2], vi_reverse[2]);
				vi[3] = min512(vi_forword[3], vi_reverse[3]);
				vi[4] = min512(vi_forword[4], vi_reverse[4]);
				vi[5] = min512(vi_forword[5], vi_reverse[5]);
				vi[6] = min512(vi_forword[6], vi_reverse[6]);
				vi[7] = min512(vi_forword[7], vi_reverse[7]);

				vj[0] = min512(vj_forword[0], vj_reverse[0]);
				vj[1] = min512(vj_forword[1], vj_reverse[1]);
				vj[2] = min512(vj_forword[2], vj_reverse[2]);
				vj[3] = min512(vj_forword[3], vj_reverse[3]);
				vj[4] = min512(vj_forword[4], vj_reverse[4]);
				vj[5] = min512(vj_forword[5], vj_reverse[5]);
				vj[6] = min512(vj_forword[6], vj_reverse[6]);
				vj[7] = min512(vj_forword[7], vj_reverse[7]);

			}else{

				vi[0] = vi_forword[0];
				vi[1] = vi_forword[1];
				vi[2] = vi_forword[2];
				vi[3] = vi_forword[3];
				vi[4] = vi_forword[4];
				vi[5] = vi_forword[5];
				vi[6] = vi_forword[6];
				vi[7] = vi_forword[7];

				vj[0] = vj_forword[0];
				vj[1] = vj_forword[1];
				vj[2] = vj_forword[2];
				vj[3] = vj_forword[3];
				vj[4] = vj_forword[4];
				vj[5] = vj_forword[5];
				vj[6] = vj_forword[6];
				vj[7] = vj_forword[7];
			}

			transpose8_epi64(&vi[0], &vi[1], &vi[2], &vi[3], &vi[4], &vi[5], &vi[6], &vi[7]); 
			transpose8_epi64(&vj[0], &vj[1], &vj[2], &vj[3], &vj[4], &vj[5], &vj[6], &vj[7]); 

			MurmurHash3_x64_128_avx512_8x16(vi, vj, pend_k, kmerSize, seed, res);// the seed in Mash is 42; verified by xxm;

			hash_u hash;
			for(int j = 0; j < 16; j++){
				if(use64)
					hash.hash64 = res[j * 2];
				else
					hash.hash32 = (uint32_t)res[j * 2];
				minHashHeap->tryInsert(hash);
			}
		}

		//tail
		for(int i = n_kmers_body; i < n_kmers; i++){
			bool noRev = true;
			if(!noncanonical && (memcmp(input8 + i, input8_rev + length - i - kmerSize, kmerSize) >= 0)){
				noRev = false;
			}
			if(noRev)
			{
				for(int j = 0; j < kmerSize; j++)
				{
					//kmer_buf[j] = input8[i + j];
					kmer_buf[j] = input8[i + j];
				}
			}
			else
			{
				for(int j = 0; j < kmerSize; j++)
				{
					//kmer_buf[j] = input8[i + j];
					kmer_buf[j] = input8_rev[length - i - kmerSize + j];
				}
			}

			MurmurHash3_x64_128(kmer_buf, kmerSize, seed, res2);// the getHash just need the lower 64bit of the total 128bit of res[i];
			hash_u hash;
			if(use64)
				hash.hash64 = res2[0];
			else
				hash.hash32 = (uint32_t)res2[0];

			minHashHeap->tryInsert(hash);

		}
		//============================================================================================================================================================

#else
#if defined __AVX2__

		int pend_k = ((kmerSize - 1) / 16 + 1) * 16;
		int n_kmers = length - kmerSize + 1;
		int n_kmers_body = (n_kmers / 4) * 4;
		const uint8_t * input8 = (const uint8_t *)seq;
		const uint8_t * input8_rev = (const uint8_t *)seqRev;
		uint64_t res[4 * 2];
		uint64_t res2[2];
		uint8_t kmer_buf[kmerSize];

		__m256i vi[4];
		//__m256i vzero = _mm256_set1_epi32(0x0);
		uint8_t maskArr[32];
		for(int i = 0; i < kmerSize; i++){
			maskArr[i] = 0xff;
		}
		for(int i = kmerSize; i < 32; i++){
			maskArr[i] = 0x0;
		}
		__m256i vmask = _mm256_loadu_si256((__m256i *)maskArr);
		for(int i = 0; i < n_kmers_body - 1; i+=4){
			vi[0] = _mm256_loadu_si256((__m256i *)(noncanonical || memcmp(input8 + i + 0, input8_rev + length - i - 0 - kmerSize, kmerSize) <= 0 ? input8 + i + 0 : input8_rev + length - i - 0 - kmerSize));
			vi[1] = _mm256_loadu_si256((__m256i *)(noncanonical || memcmp(input8 + i + 1, input8_rev + length - i - 1 - kmerSize, kmerSize) <= 0 ? input8 + i + 1 : input8_rev + length - i - 1 - kmerSize));
			vi[2] = _mm256_loadu_si256((__m256i *)(noncanonical || memcmp(input8 + i + 2, input8_rev + length - i - 2 - kmerSize, kmerSize) <= 0 ? input8 + i + 2 : input8_rev + length - i - 2 - kmerSize));
			vi[3] = _mm256_loadu_si256((__m256i *)(noncanonical || memcmp(input8 + i + 3, input8_rev + length - i - 3 - kmerSize, kmerSize) <= 0 ? input8 + i + 3 : input8_rev + length - i - 3 - kmerSize));
			vi[0] = _mm256_and_si256(vi[0], vmask);
			vi[1] = _mm256_and_si256(vi[1], vmask);
			vi[2] = _mm256_and_si256(vi[2], vmask);
			vi[3] = _mm256_and_si256(vi[3], vmask);

			transpose4_epi64(&vi[0], &vi[1], &vi[2], &vi[3]);

			MurmurHash3_x64_128_avx2_8x4(vi, pend_k, kmerSize, seed, res);

			hash_u hash;
			for(int j = 0; j < 4; j++)
			{
				if(use64)	
					hash.hash64 = res[j * 2];
				else
					hash.hash32 = (uint32_t)res[j * 2];

				minHashHeap->tryInsert(hash);
			}
		}

		for(int i = n_kmers_body; i < n_kmers; i++)
		{
			//bool noRev = (memcmp(input8 + i, input8_rev + length -i - kmerSize, kmerSize) <= 0) || noncanonical;
			bool noRev = true;
			if(!noncanonical && (memcmp(input8 + i, input8_rev + length - i - kmerSize, kmerSize) >= 0)){
				noRev = false;
			}
			if(noRev){
				for(int j = 0; j < kmerSize; j++){
					kmer_buf[j] = input8[i + j];
				}
			}
			else{
				for(int j = 0; j < kmerSize; j++){
					kmer_buf[j] = input8_rev[length - i - kmerSize + j];
				}
			}

			MurmurHash3_x64_128(kmer_buf, kmerSize, seed, res2);
			hash_u hash;
			if(use64)
				hash.hash64 = res2[0];
			else
				hash.hash32 = (uint32_t)res2[0];

			minHashHeap->tryInsert(hash);

		}

#else

		//implement by no optmization
		for ( uint64_t i = 0; i < length - kmerSize + 1; i++ )
		{

			const char *kmer_fwd = seq + i;
			const char *kmer_rev = seqRev + length - i - kmerSize;
			const char * kmer = (noncanonical || memcmp(kmer_fwd, kmer_rev, kmerSize) <= 0) ? kmer_fwd : kmer_rev;
			bool filter = false;

			hash_u hash = getHash(kmer, kmerSize, seed, use64);

			minHashHeap->tryInsert(hash);
		}
#endif
#endif

		if ( ! noncanonical )
		{
			delete [] seqRev;
		}

		//needToList = true;
		heapToList();
	}

	/* addbyxxm
	 * (1)	The merge or the heapToList from heap to update list(where hash values store) need to promise the elements in the list are unique(no repeat element in list).
	 *		The jaccard calculation will be wrong answer if there are repeat element in the hashesSorted list.
	 * (2)	The memory free of intermediate variables is necessary for lower memory footprint especially for large data sets and large sketchSize.
	 * 		The imtermediate variables include: tmp HashesLists, MinHashHeap objects, tmp Sets, etc.
	 */
	void MinHash::heapToList()
	{
		HashList & hashlist = reference.hashesSorted;
		//hashlist.clear();
		hashlist.setUse64(use64);
		HashList tmpHashlist;
		tmpHashlist.setUse64(use64);
		minHashHeap -> toHashList(tmpHashlist);
		//minHashHeap -> toCounts(reference.counts);
		if(use64)
			hashlist.hashes64.insert(hashlist.hashes64.end(), tmpHashlist.hashes64.begin(), tmpHashlist.hashes64.end());
		else
			hashlist.hashes32.insert(hashlist.hashes32.end(), tmpHashlist.hashes32.begin(), tmpHashlist.hashes32.end());
		hashlist.sort();
		if(use64){
			robin_hood::unordered_set<uint64_t> mergedSet;
			for(int i = 0; i < hashlist.size(); i++){
				mergedSet.insert(hashlist.hashes64[i]);
				if(mergedSet.size() >= sketchSize) break;
			}
			hashlist.clear();
			for(auto i = mergedSet.begin(); i != mergedSet.end(); ++i){
				hashlist.hashes64.push_back(*i);
			}
			//clear mergedSet and free memory
			robin_hood::unordered_set<uint64_t>().swap(mergedSet);


		}
		else{
			robin_hood::unordered_set<uint32_t> mergedSet;
			for(int i = 0; i < hashlist.size(); i++){
				mergedSet.insert(hashlist.hashes32[i]);
				if(mergedSet.size() >= sketchSize) break;
			}
			hashlist.clear();
			for(auto i = mergedSet.begin(); i != mergedSet.end(); ++i){
				hashlist.hashes32.push_back(*i);
			}
			//clear mergedSet and free memory
			robin_hood::unordered_set<uint32_t>().swap(mergedSet);
		}

		hashlist.sort();

		//hashlist.resize(hashlist.size() < sketchSize ? hashlist.size() : sketchSize);
		minHashHeap -> clear();
		tmpHashlist.clear();

	}

	void MinHash::printMinHashes()
	{
		for(int i = 0; i < reference.hashesSorted.size(); i++){
			if(use64)
				cerr << "hash64 " <<  i << " " << reference.hashesSorted.at(i).hash64 << endl;
			else
				cerr << "hash32 " <<  i << " " << reference.hashesSorted.at(i).hash32 << endl;
		}
		return;
	}

	vector<uint64_t> MinHash::storeMinHashes()
	{
		vector<uint64_t> res;
		for(int i = 0; i < reference.hashesSorted.size(); i++){
			if(use64)
				res.push_back(reference.hashesSorted.at(i).hash64);
			else
				res.push_back(reference.hashesSorted.at(i).hash32);
		}
		return res;
	}

	void MinHash::loadMinHashes(vector<uint64_t> hashArr)
	{
		for(int i = 0; i < hashArr.size(); i++){
			if(use64)
				reference.hashesSorted.hashes64.push_back(hashArr[i]);
			else
				reference.hashesSorted.hashes32.push_back((uint32_t)hashArr[i]);
		}
	}

	/* addbyxxm
	 * (1)	The merge or the heapToList from heap to update list(where hash values store) need to promise the elements in the list are unique(no repeat element in list).
	 *			The jaccard calculation will be wrong answer if there are repeat element in the hashesSorted list.
	 * (2)	The memory free of intermediate variables is necessary for lower memory footprint especially for large data sets and large sketchSize.
	 * 			The imtermediate variables include: tmp HashesLists, MinHashHeap objects, tmp Sets, etc.
	 * (3) 	The minHash for sequence(genome) containment does not support merge operation since the sketchSize is not fixed size but proportional with the sequence(genome) length. 
	 */
	void MinHash::merge(MinHash& msh)
	{
		//msh.heapToList();
		HashList & mshList = msh.reference.hashesSorted;	
		if(use64)
			reference.hashesSorted.hashes64.insert(reference.hashesSorted.hashes64.end(), msh.reference.hashesSorted.hashes64.begin(), msh.reference.hashesSorted.hashes64.end());
		else
			reference.hashesSorted.hashes32.insert(reference.hashesSorted.hashes32.end(), msh.reference.hashesSorted.hashes32.begin(), msh.reference.hashesSorted.hashes32.end());
		reference.hashesSorted.sort();
		if(use64){
			robin_hood::unordered_set<uint64_t> mergedSet;
			for(int i = 0; i < reference.hashesSorted.hashes64.size(); i++){
				mergedSet.insert(reference.hashesSorted.hashes64[i]);
				if(mergedSet.size() >= sketchSize) break;
			}
			reference.hashesSorted.clear();
			for(auto i = mergedSet.begin(); i != mergedSet.end(); ++i){
				reference.hashesSorted.hashes64.push_back(*i);
			}
			//clear mergedSet and free memory
			robin_hood::unordered_set<uint64_t>().swap(mergedSet);
		}
		else{
			robin_hood::unordered_set<uint32_t> mergedSet;
			for(int i = 0; i < reference.hashesSorted.hashes32.size(); i++){
				mergedSet.insert(reference.hashesSorted.hashes32[i]);
				if(mergedSet.size() >= sketchSize) break;
			}
			reference.hashesSorted.clear();
			for(auto i = mergedSet.begin(); i != mergedSet.end(); ++i){
				reference.hashesSorted.hashes32.push_back(*i);
			}
			//clear mergedSet and free memory
			robin_hood::unordered_set<uint32_t>().swap(mergedSet);
		}

		reference.hashesSorted.sort();

		return;	
	}

	double MinHash::containJaccard(MinHash * msh)
	{
		//cerr << "use the containJaccard in minHash.cpp " << endl;
		uint64_t i = 0;
		uint64_t j = 0;
		uint64_t common = 0;
		//uint64_t denom = 0;
		const HashList & hashesSortedRef = this->reference.hashesSorted;
		const HashList & hashesSortedQry = msh->reference.hashesSorted;
		uint64_t denom = std::min(hashesSortedRef.size(), hashesSortedQry.size());
		uint64_t sumSketchSize = hashesSortedRef.size() + hashesSortedQry.size();
#if defined __AVX512F__ && defined __AVX512CD__
		//	cerr << "the avx512 ===========================================" << endl;
		if(hashesSortedRef.get64())
		{
			common = u64_intersect_vector_avx512((uint64_t*)hashesSortedRef.hashes64.data(), hashesSortedRef.size(), (uint64_t*)hashesSortedQry.hashes64.data(), hashesSortedQry.size(), sumSketchSize, &i, &j);
		}
		else
		{
			common = u32_intersect_vector_avx512((uint32_t*)hashesSortedRef.hashes32.data(), hashesSortedRef.size(), (uint32_t*)hashesSortedQry.hashes32.data(), hashesSortedQry.size(), sumSketchSize, &i, &j);
		}
#else
#ifdef __AVX2__
		//	cerr << "the avx2 ===========================================" << endl;
		if(hashesSortedRef.get64())
		{
			common = u64_intersect_vector_avx2((uint64_t*)hashesSortedRef.hashes64.data(), hashesSortedRef.size(), (uint64_t*)hashesSortedQry.hashes64.data(), hashesSortedQry.size(), sumSketchSize, &i, &j);
		}
		else
		{
			common = u32_intersect_vector_avx2((uint32_t*)hashesSortedRef.hashes32.data(), hashesSortedRef.size(), (uint32_t*)hashesSortedQry.hashes32.data(), hashesSortedQry.size(), sumSketchSize, &i, &j);
		}
#else
#ifdef __SSE4_1__
		//	cerr << "the sse ===========================================" << endl;
		if(hashesSortedRef.get64())
		{
			common = u64_intersection_vector_sse((uint64_t*)hashesSortedRef.hashes64.data(), hashesSortedRef.size(), (uint64_t*)hashesSortedQry.hashes64.data(), hashesSortedQry.size(), sumSketchSize, &i, &j);
		}
		else
		{
			common = u32_intersection_vector_sse((uint32_t*)hashesSortedRef.hashes32.data(), hashesSortedRef.size(), (uint32_t*)hashesSortedQry.hashes32.data(), hashesSortedQry.size(), sumSketchSize, &i, &j);
		}
#else
		//	cerr << "the without SIMD ===========================================" << endl;

		while ( i < hashesSortedRef.size() && j < hashesSortedQry.size() )
		{
			if ( hashLessThan(hashesSortedRef.at(i), hashesSortedQry.at(j), hashesSortedRef.get64()) )
			{
				i++;
			}
			else if ( hashLessThan(hashesSortedQry.at(j), hashesSortedRef.at(i), hashesSortedRef.get64()) )
			{
				j++;
			}
			else
			{
				i++;
				j++;
				common++;
			}
		}
#endif
#endif
#endif

		double jaccard = double(common) / denom;
		return jaccard;
	}


	double MinHash::jaccard(MinHash * msh)
	{

		uint64_t i = 0;
		uint64_t j = 0;
		uint64_t common = 0;
		uint64_t denom = 0;
		const HashList & hashesSortedRef = this->reference.hashesSorted;
		const HashList & hashesSortedQry = msh->reference.hashesSorted;
		//	cout << "the size of hashesSortedRef is: " << this->reference.hashesSorted.size() << endl;
		//	cout << "the size of hashesSortedQry is: " << msh->reference.hashesSorted.size() << endl;
		//	for(int index = 0; index < reference.hashesSorted.size(); index++){
		//		if(use64)
		//			cout << index << " " << reference.hashesSorted.at(index).hash64 << " " << msh->reference.hashesSorted.at(index).hash64 << endl;
		//		else
		//			cout << index << " " << reference.hashesSorted.at(index).hash32 << " " << msh->reference.hashesSorted.at(index).hash32 << endl;
		//	}

#if defined __AVX512F__ && defined __AVX512CD__
		//	cerr << "the avx512 ===========================================" << endl;
		if(hashesSortedRef.get64())
		{
			//cerr << "implement the 64bit avx512 addbyxxm " << endl;
			common = u64_intersect_vector_avx512((uint64_t*)hashesSortedRef.hashes64.data(), hashesSortedRef.size(), (uint64_t*)hashesSortedQry.hashes64.data(), hashesSortedQry.size(), sketchSize, &i, &j);
			//cout << "the common from avx512 is: " << common << endl;

			denom = i + j - common;
		}
		else
		{
			//cerr << "implement the 32bit avx512 addbyxxm " << endl;
			//exit(0);
			common = u32_intersect_vector_avx512((uint32_t*)hashesSortedRef.hashes32.data(), hashesSortedRef.size(), (uint32_t*)hashesSortedQry.hashes32.data(), hashesSortedQry.size(), sketchSize, &i, &j);
			denom = i + j - common;
		}
#else
#ifdef __AVX2__
		//	cerr << "the avx2 ===========================================" << endl;
		// implement by avx2

		if(hashesSortedRef.get64())
		{
			common = u64_intersect_vector_avx2((uint64_t*)hashesSortedRef.hashes64.data(), hashesSortedRef.size(), (uint64_t*)hashesSortedQry.hashes64.data(), hashesSortedQry.size(), sketchSize, &i, &j);
			//add later
			denom = i + j - common;
		}
		else
		{
			common = u32_intersect_vector_avx2((uint32_t*)hashesSortedRef.hashes32.data(), hashesSortedRef.size(), (uint32_t*)hashesSortedQry.hashes32.data(), hashesSortedQry.size(), sketchSize, &i, &j);
			denom = i + j - common;
		}
#else
#ifdef __SSE4_1__
		// implement by sse
		//	cerr << "the sse ===========================================" << endl;

		if(hashesSortedRef.get64())
		{
			common = u64_intersection_vector_sse((uint64_t*)hashesSortedRef.hashes64.data(), hashesSortedRef.size(), (uint64_t*)hashesSortedQry.hashes64.data(), hashesSortedQry.size(), sketchSize, &i, &j);
			//add later
			denom = i + j - common;
		}
		else
		{
			common = u32_intersection_vector_sse((uint32_t*)hashesSortedRef.hashes32.data(), hashesSortedRef.size(), (uint32_t*)hashesSortedQry.hashes32.data(), hashesSortedQry.size(), sketchSize, &i, &j);
			denom = i + j - common;
		}
#else
		//implement without optimization	
		//	cerr << "the naive ===========================================" << endl;

		while ( denom < sketchSize && i < hashesSortedRef.size() && j < hashesSortedQry.size() )
		{
			if ( hashLessThan(hashesSortedRef.at(i), hashesSortedQry.at(j), hashesSortedRef.get64()) )
			{
				i++;
			}
			else if ( hashLessThan(hashesSortedQry.at(j), hashesSortedRef.at(i), hashesSortedRef.get64()) )
			{
				j++;
			}
			else
			{
				//		cout << "res: " << (uint64_t)hashesSortedRef.at(i).hash64 << endl;
				i++;
				j++;
				common++;
			}

			denom++;
		}
		//cout << "the common from native without SIMD is: " << common << endl;
#endif
#endif
#endif

		if ( denom < sketchSize )
		{
			// complete the union operation if possible

			if ( i < hashesSortedRef.size() )
			{
				denom += hashesSortedRef.size() - i;
			}

			if ( j < hashesSortedQry.size() )
			{
				denom += hashesSortedQry.size() - j;
			}

			if ( denom > sketchSize )
			{
				denom = sketchSize;
			}
		}

		double jaccard = double(common) / denom;
		return jaccard;
	}
	double MinHash::containDistance(MinHash * msh)
	{
		double distance;
		double maxDistance = 1;
		double maxPValue = 1;

		double jaccard_ = this->containJaccard(msh);
		if(jaccard_ == 1.0)	return 0;
		distance = -log(2 * jaccard_ / (1. + jaccard_)) / kmerSize;

		if ( distance > 1 )
		{
			distance = 1;
		}

		if ( maxDistance >= 0 && distance > maxDistance )
		{
			return 1.;
		}
		return distance;

	}

	double MinHash::distance(MinHash * msh)
	{
		double distance;
		double maxDistance = 1;
		double maxPValue = 1;

		double jaccard_ = this->jaccard(msh);
		if(jaccard_ == 1.0)	return 0;
		distance = -log(2 * jaccard_ / (1. + jaccard_)) / kmerSize;

		if ( distance > 1 )
		{
			distance = 1;
		}

		if ( maxDistance >= 0 && distance > maxDistance )
		{
			return 1.;
		}
		//double pValue_ = pValue(common, this->length, msh->length, kmerSpace, denom);
		//if ( maxPValue >= 0 && pValue_ > maxPValue )
		//{
		//	cerr << "the pValue is larger than maxPValue " << endl;
		//	return 1.;
		//}
		return distance;


	}
	/*
		 double MinHash::pValue(uint64_t x, uint64_t lengthRef, uint64_t lengthQuery, double kmerSpace, uint64_t sketchSize)
		 {
		 if ( x == 0 )
		 {
		 return 1.;
		 }

		 double pX = 1. / (1. + kmerSpace / lengthRef);
		 double pY = 1. / (1. + kmerSpace / lengthQuery);
	//  cerr << endl;
	//	cerr << "kmerspace: " << kmerSpace << endl;
	//	cerr << "px: " << pX << endl;
	//	cerr << "py: " << pY << endl;
	double r = pX * pY / (pX + pY - pX * pY);

	//double M = (double)kmerSpace * (pX + pY) / (1. + r);

	//return gsl_cdf_hypergeometric_Q(x - 1, r * M, M - r * M, sketchSize);
	// 	return 0.1;   
	//	cerr << "r = " << r << endl;
	return gsl_cdf_binomial_Q(x - 1, r, sketchSize);
	//#ifdef USE_BOOST
	//    return cdf(complement(binomial(sketchSize, r), x - 1));
	//#else
	//    return gsl_cdf_binomial_Q(x - 1, r, sketchSize);
	//#endif
	}
	*/

	//FIXME: it only works for DNA sequences
	void reverseComplement(const char * src, char * dest, int length)
	{
		char table[4] = {'T','G','A','C'};
		for ( int i = 0; i < length; i++ )
		{
			char base = src[i];
			base >>= 1;
			base &= 0x03;
			dest[length - i - 1] = table[base];
		}
	}

}

uint64_t u64_intersect_scalar_stop(const uint64_t *list1, uint64_t size1, const uint64_t *list2, uint64_t size2, uint64_t size3,
		uint64_t *i_a, uint64_t *i_b){
	uint64_t counter=0;
	const uint64_t *end1 = list1+size1, *end2 = list2+size2;
	*i_a = 0;
	*i_b = 0;
	//uint64_t stop = 0;
	// hard to get only the loop instructions, now only a tiny check at the top wrong

	while(list1 != end1 && list2 != end2 ){
		if(*list1 < *list2){
			list1++;
			(*i_a)++;
			size3--;
		}else if(*list1 > *list2){
			list2++; 
			(*i_b)++;
			size3--;
		}else{
			//result[counter++] = *list1;
			counter++;
			list1++; list2++; 
			(*i_a)++;
			(*i_b)++;
			size3--;
		}
		if(size3 == 0) break;
	}

	return counter;
}

uint64_t u32_intersect_scalar_stop(const uint32_t *list1, uint32_t size1, const uint32_t *list2, uint32_t size2, uint32_t size3,
		uint64_t *i_a, uint64_t *i_b){
	uint64_t counter=0;
	const uint32_t *end1 = list1+size1, *end2 = list2+size2;
	*i_a = 0;
	*i_b = 0;
	//uint64_t stop = 0;
	// hard to get only the loop instructions, now only a tiny check at the top wrong
	while(list1 != end1 && list2 != end2 ){
		if(*list1 < *list2){
			list1++;
			(*i_a)++;
			size3--;
		}else if(*list1 > *list2){
			list2++; 
			(*i_b)++;
			size3--;
		}else{
			//result[counter++] = *list1;
			counter++;
			list1++; list2++; 
			(*i_a)++;
			(*i_b)++;
			size3--;
		}
		if(size3 == 0) break;
	}
	return counter;
}
#if defined __AVX512F__ && defined __AVX512CD__

static /*constexpr*/ std::array<uint64_t,8*7> u64_prepare_shuffle_vectors(){
	std::array<uint64_t,8*7> arr = {};
	uint64_t start=1;
	for(uint64_t i=0; i<7; ++i){
		uint64_t counter = start;
		for(uint64_t j=0; j<8; ++j){
			arr[i*8 + j] = counter % 8;
			++counter;
		}
		++start;
	}
	return arr;
}
static const /*constexpr*/ auto u64_shuffle_vectors_arr = u64_prepare_shuffle_vectors();

static const /*constexpr*/ __m512i *u64_shuffle_vectors = (__m512i*)u64_shuffle_vectors_arr.data();
static void inline
inspect(__m512i v){
	uint64_t f[8] __attribute__((aligned(64)));
	_mm512_store_epi64(f,v);
	printf("[%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld]\n", f[0], f[1], f[2], f[3],f[4], f[5], f[6], f[7]);
}
uint64_t u64_intersect_vector_avx512(const uint64_t *list1,  uint64_t size1, const uint64_t *list2, uint64_t size2, uint64_t size3, uint64_t *i_a, uint64_t *i_b)
{
	//assert(size3 <= size1 + size2);
	uint64_t count=0;
	*i_a = 0;
	*i_b = 0;
	uint64_t st_a = (size1 / 8) * 8;
	uint64_t st_b = (size2 / 8) * 8;
	//	uint64_t stop = (size3 / 16) * 16;

	uint64_t i_a_s, i_b_s;

	if(size3 <= 8){
		count += u64_intersect_scalar_stop(list1, size1, list2, size2, size3, i_a, i_b);
		return count;
	}

	uint64_t stop = size3 - 8;

	__m512i sv0  = _mm512_set_epi64(0,7,6,5,4,3,2,1);
	__m512i sv1  = _mm512_set_epi64(1,0,7,6,5,4,3,2);
	__m512i sv2  = _mm512_set_epi64(2,1,0,7,6,5,4,3);
	__m512i sv3  = _mm512_set_epi64(3,2,1,0,7,6,5,4);
	__m512i sv4  = _mm512_set_epi64(4,3,2,1,0,7,6,5);
	__m512i sv5  = _mm512_set_epi64(5,4,3,2,1,0,7,6);
	__m512i sv6  = _mm512_set_epi64(6,5,4,3,2,1,0,7);

	//__m512i vzero = _mm512_setzero_epi32();
	while(*i_a < st_a && *i_b < st_b){
		__m512i v_a = _mm512_loadu_si512((__m512i*)&list1[*i_a]);
		__m512i v_b = _mm512_loadu_si512((__m512i*)&list2[*i_b]);

		uint64_t a_max = list1[*i_a+7];
		uint64_t b_max = list2[*i_b+7];

		*i_a += (a_max <= b_max) * 8;
		*i_b += (a_max >= b_max) * 8;

		__mmask16 cmp0 = _mm512_cmpeq_epu64_mask(v_a, v_b);
		__m512i rot0 = _mm512_permutexvar_epi64(sv0, v_b);
		__mmask16 cmp1 = _mm512_cmpeq_epu64_mask(v_a, rot0);
		__m512i rot1 = _mm512_permutexvar_epi64(sv1, v_b);
		__mmask16 cmp2 = _mm512_cmpeq_epu64_mask(v_a, rot1);
		__m512i rot2 = _mm512_permutexvar_epi64(sv2, v_b);
		__mmask16 cmp3 = _mm512_cmpeq_epu64_mask(v_a, rot2);
		cmp0 = _mm512_kor(_mm512_kor(cmp0, cmp1), _mm512_kor(cmp2, cmp3));

		__m512i rot3 = _mm512_permutexvar_epi64(sv3, v_b);
		__mmask16 cmp4 = _mm512_cmpeq_epu64_mask(v_a, rot3);
		__m512i rot4 = _mm512_permutexvar_epi64(sv4, v_b);
		__mmask16 cmp5 = _mm512_cmpeq_epu64_mask(v_a, rot4);
		__m512i rot5 = _mm512_permutexvar_epi64(sv5, v_b);
		__mmask16 cmp6 = _mm512_cmpeq_epu64_mask(v_a, rot5);
		__m512i rot6 = _mm512_permutexvar_epi64(sv6, v_b);
		__mmask16 cmp7 = _mm512_cmpeq_epu64_mask(v_a, rot6);
		cmp4 = _mm512_kor(_mm512_kor(cmp4, cmp5), _mm512_kor(cmp6, cmp7));


		cmp0 = _mm512_kor(cmp0, cmp4);

		//_mm512_mask_compressstoreu_epi64(&result[count], cmp0, v_a);
		//__m512i vres = _mm512_mask_compress_epi64(_mm512_setzero_epi32(), cmp0, v_a);
		//if(cmp0 > 0)
		//	inspect(vres);
		count += _mm_popcnt_u64(cmp0);
		if(*i_a + *i_b - count >= stop){
			count -= _mm_popcnt_u64(cmp0);
			*i_a -= (a_max <= b_max) * 8;
			*i_b -= (a_max >= b_max) * 8;
			break;
		}

	}
	count += u64_intersect_scalar_stop(list1+*i_a, size1-*i_a, list2+*i_b, size2-*i_b, size3 - (*i_a+*i_b - count), &i_a_s, &i_b_s);

	*i_a += i_a_s;
	*i_b += i_b_s;
	return count;

}


static /*constexpr*/ std::array<uint32_t,16*16> u32_prepare_shuffle_vectors(){
	std::array<uint32_t,16*16> arr_unalign = {};
	//std::array<uint64_t,8*7> arr = {};
	uint32_t *arr = (uint32_t *)(((long)arr_unalign.data() + 64) & (~63));
	//__m512i *temp;
	uint64_t start=1;
	for(uint64_t i=0; i<15; ++i){
		uint64_t counter = start;
		for(uint64_t j=0; j<16; ++j){
			arr[i*16 + j] = counter % 16;
			++counter;
		}
		++start;
	}
	return arr_unalign;
}
static const /*constexpr*/ auto u32_shuffle_vectors_arr = u32_prepare_shuffle_vectors();
static const /*constexpr*/ __m512i *u32_shuffle_vectors_unalign = (__m512i*)u32_shuffle_vectors_arr.data();
static const __m512i *u32_shuffle_vectors = (__m512i *)(((long)u32_shuffle_vectors_unalign + 64) & (~63));
//size3 is the stop threshold of the sum of size1&size2 
uint32_t u32_intersect_vector_avx512(const uint32_t *list1, uint32_t size1, const uint32_t *list2, uint32_t size2, uint32_t size3, uint64_t *i_a, uint64_t *i_b){
	//assert(size3 <= size1 + size2);
	uint64_t count=0;
	*i_a = 0;
	*i_b = 0;
	uint64_t st_a = (size1 / 16) * 16;
	uint64_t st_b = (size2 / 16) * 16;
	//	uint64_t stop = (size3 / 16) * 16;

	uint64_t i_a_s, i_b_s;

	if(size3 <= 16){
		count += u32_intersect_scalar_stop(list1, size1, list2, size2, size3, i_a, i_b);
		return count;
	}

	uint64_t stop = size3 - 16;
	//cout << "stop: " << stop <<  endl;
	__m512i sv0   = _mm512_set_epi32(0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1); //u32_shuffle_vectors[0 ];
	__m512i sv1   = _mm512_set_epi32(1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2); //u32_shuffle_vectors[1 ];
	__m512i sv2   = _mm512_set_epi32(2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3); //u32_shuffle_vectors[2 ];
	__m512i sv3   = _mm512_set_epi32(3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4); //u32_shuffle_vectors[3 ];
	__m512i sv4   = _mm512_set_epi32(4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5); //u32_shuffle_vectors[4 ];
	__m512i sv5   = _mm512_set_epi32(5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6); //u32_shuffle_vectors[5 ];
	__m512i sv6   = _mm512_set_epi32(6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7); //u32_shuffle_vectors[6 ];
	__m512i sv7   = _mm512_set_epi32(7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8); //u32_shuffle_vectors[7 ];
	__m512i sv8   = _mm512_set_epi32(8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9); //u32_shuffle_vectors[8 ];
	__m512i sv9   = _mm512_set_epi32(9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10); //u32_shuffle_vectors[9 ];
	__m512i sv10  = _mm512_set_epi32(10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11); //u32_shuffle_vectors[10];
	__m512i sv11  = _mm512_set_epi32(11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12); //u32_shuffle_vectors[11];
	__m512i sv12  = _mm512_set_epi32(12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13); //u32_shuffle_vectors[12];
	__m512i sv13  = _mm512_set_epi32(13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14); //u32_shuffle_vectors[13];
	__m512i sv14  = _mm512_set_epi32(14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15); //u32_shuffle_vectors[14];
	//__m512i vzero = _mm512_setzero_epi32();
	while(*i_a < st_a && *i_b < st_b){



		uint32_t a_max = list1[*i_a+15];
		uint32_t b_max = list2[*i_b+15];

		__m512i v_a = _mm512_loadu_si512((__m512i*)&(list1[*i_a]));
		__m512i v_b = _mm512_loadu_si512((__m512i*)&(list2[*i_b]));

		*i_a += (a_max <= b_max) * 16;
		*i_b += (a_max >= b_max) * 16;

		__mmask16 cmp0 = _mm512_cmpeq_epu32_mask(v_a, v_b);
		__m512i rot0 = _mm512_permutexvar_epi32(sv0, v_b);
		__mmask16 cmp1 = _mm512_cmpeq_epu32_mask(v_a, rot0);
		__m512i rot1 = _mm512_permutexvar_epi32(sv1, v_b);
		__mmask16 cmp2 = _mm512_cmpeq_epu32_mask(v_a, rot1);
		__m512i rot2 = _mm512_permutexvar_epi32(sv2, v_b);
		__mmask16 cmp3 = _mm512_cmpeq_epu32_mask(v_a, rot2);
		cmp0 = _mm512_kor(_mm512_kor(cmp0, cmp1), _mm512_kor(cmp2, cmp3));

		__m512i rot3 = _mm512_permutexvar_epi32(sv3, v_b);
		__mmask16 cmp4 = _mm512_cmpeq_epu32_mask(v_a, rot3);
		__m512i rot4 = _mm512_permutexvar_epi32(sv4, v_b);
		__mmask16 cmp5 = _mm512_cmpeq_epu32_mask(v_a, rot4);
		__m512i rot5 = _mm512_permutexvar_epi32(sv5, v_b);
		__mmask16 cmp6 = _mm512_cmpeq_epu32_mask(v_a, rot5);
		__m512i rot6 = _mm512_permutexvar_epi32(sv6, v_b);
		__mmask16 cmp7 = _mm512_cmpeq_epu32_mask(v_a, rot6);
		cmp4 = _mm512_kor(_mm512_kor(cmp4, cmp5), _mm512_kor(cmp6, cmp7));

		__m512i rot7 = _mm512_permutexvar_epi32(sv7, v_b);
		cmp1 = _mm512_cmpeq_epu32_mask(v_a, rot7);
		__m512i rot8 = _mm512_permutexvar_epi32(sv8, v_b);
		cmp2 = _mm512_cmpeq_epu32_mask(v_a, rot8);
		__m512i rot9 = _mm512_permutexvar_epi32(sv9, v_b);
		cmp3 = _mm512_cmpeq_epu32_mask(v_a, rot9);
		__m512i rot10 = _mm512_permutexvar_epi32(sv10, v_b);
		cmp5 = _mm512_cmpeq_epu32_mask(v_a, rot10);
		cmp1 = _mm512_kor(_mm512_kor(cmp1, cmp2), _mm512_kor(cmp3, cmp5));

		__m512i rot11 = _mm512_permutexvar_epi32(sv11, v_b);
		cmp2 = _mm512_cmpeq_epu32_mask(v_a, rot11);
		__m512i rot12 = _mm512_permutexvar_epi32(sv12, v_b);
		cmp3 = _mm512_cmpeq_epu32_mask(v_a, rot12);
		__m512i rot13 = _mm512_permutexvar_epi32(sv13, v_b);
		cmp5 = _mm512_cmpeq_epu32_mask(v_a, rot13);
		__m512i rot14 = _mm512_permutexvar_epi32(sv14, v_b);
		cmp6 = _mm512_cmpeq_epu32_mask(v_a, rot14);
		cmp2 = _mm512_kor(_mm512_kor(cmp2, cmp3), _mm512_kor(cmp5, cmp6));


		cmp0 = _mm512_kor(_mm512_kor(cmp0, cmp4), _mm512_kor(cmp1, cmp2));




		//_mm512_mask_compressstoreu_epi64(&result[count], cmp0, v_a);
		//__m512i vres = _mm512_mask_compress_epi64(_mm512_setzero_epi32(), cmp0, v_a);
		//if(cmp0 > 0)
		//	inspect(vres);
		count += _mm_popcnt_u32(cmp0);
		if(*i_a + *i_b - count >= stop){
			count -= _mm_popcnt_u32(cmp0);
			*i_a -= (a_max <= b_max) * 16;
			*i_b -= (a_max >= b_max) * 16;
			break;
		}

	}
	count += u32_intersect_scalar_stop(list1+*i_a, size1-*i_a, list2+*i_b, size2-*i_b, size3 - (*i_a+*i_b - count), &i_a_s, &i_b_s);

	*i_a += i_a_s;
	*i_b += i_b_s;
	return count;
}

#else
#ifdef __AVX2__

size_t u32_intersect_vector_avx2(const uint32_t *list1, uint32_t size1, const uint32_t *list2, uint32_t size2, uint32_t size3, uint64_t* i_a, uint64_t* i_b){
	//assert(size3 <= size1 + size2);
	uint64_t count=0;
	*i_a = 0;
	*i_b = 0;
	uint64_t st_a = (size1 / 8) * 8;
	uint64_t st_b = (size2 / 8) * 8;

	uint64_t i_a_s, i_b_s;

	if(size3 <= 16){
		count += u32_intersect_scalar_stop(list1, size1, list2, size2, size3, i_a, i_b);
		return count;
	}

	uint64_t stop = size3 - 16;
	while(*i_a < st_a && *i_b < st_b){

		uint32_t a_max = list1[*i_a+7];
		uint32_t b_max = list2[*i_b+7];

		__m256i v_a = _mm256_loadu_si256((__m256i*)&(list1[*i_a]));
		__m256i v_b = _mm256_loadu_si256((__m256i*)&(list2[*i_b]));

		*i_a += (a_max <= b_max) * 8;
		*i_b += (a_max >= b_max) * 8;


		/*constexpr*/ const int32_t cyclic_shift = _MM_SHUFFLE(0,3,2,1); //rotating right
		/*constexpr*/ const int32_t cyclic_shift2= _MM_SHUFFLE(2,1,0,3); //rotating left
		/*constexpr*/ const int32_t cyclic_shift3= _MM_SHUFFLE(1,0,3,2); //between
		__m256i cmp_mask1 = _mm256_cmpeq_epi32(v_a, v_b);
		__m256 rot1 = _mm256_permute_ps((__m256)v_b, cyclic_shift);
		__m256i cmp_mask2 = _mm256_cmpeq_epi32(v_a, (__m256i)rot1);
		__m256 rot2 = _mm256_permute_ps((__m256)v_b, cyclic_shift3);
		__m256i cmp_mask3 = _mm256_cmpeq_epi32(v_a, (__m256i)rot2);
		__m256 rot3 = _mm256_permute_ps((__m256)v_b, cyclic_shift2);
		__m256i cmp_mask4 = _mm256_cmpeq_epi32(v_a, (__m256i)rot3);

		__m256 rot4 = _mm256_permute2f128_ps((__m256)v_b, (__m256)v_b, 1);

		__m256i cmp_mask5 = _mm256_cmpeq_epi32(v_a, (__m256i)rot4);
		__m256 rot5 = _mm256_permute_ps(rot4, cyclic_shift);
		__m256i cmp_mask6 = _mm256_cmpeq_epi32(v_a, (__m256i)rot5);
		__m256 rot6 = _mm256_permute_ps(rot4, cyclic_shift3);
		__m256i cmp_mask7 = _mm256_cmpeq_epi32(v_a, (__m256i)rot6);
		__m256 rot7 = _mm256_permute_ps(rot4, cyclic_shift2);
		__m256i cmp_mask8 = _mm256_cmpeq_epi32(v_a, (__m256i)rot7);

		__m256i cmp_mask = _mm256_or_si256(
				_mm256_or_si256(
					_mm256_or_si256(cmp_mask1, cmp_mask2),
					_mm256_or_si256(cmp_mask3, cmp_mask4)
					),
				_mm256_or_si256(
					_mm256_or_si256(cmp_mask5, cmp_mask6),
					_mm256_or_si256(cmp_mask7, cmp_mask8)
					)
				);
		int32_t mask = _mm256_movemask_ps((__m256)cmp_mask);

		count += _mm_popcnt_u32(mask);

		if(*i_a + *i_b - count >= stop){
			//count -= _mm_popcnt_u32(cmp0);
			//*i_a -= (a_max <= b_max) * 16;
			//*i_b -= (a_max >= b_max) * 16;
			break;
		}

	}
	count += u32_intersect_scalar_stop(list1+*i_a, size1-*i_a, list2+*i_b, size2-*i_b, size3 - (*i_a+*i_b - count), &i_a_s, &i_b_s);

	*i_a += i_a_s;
	*i_b += i_b_s;
	return count;
}

size_t u64_intersect_vector_avx2(const uint64_t *list1, uint64_t size1, const uint64_t *list2, uint64_t size2, uint64_t size3, uint64_t* i_a, uint64_t* i_b){
	//assert(size3 <= size1 + size2);
	uint64_t count=0;
	*i_a = 0;
	*i_b = 0;
	uint64_t st_a = (size1 / 4) * 4;
	uint64_t st_b = (size2 / 4) * 4;
	//	uint64_t stop = (size3 / 16) * 16;

	uint64_t i_a_s, i_b_s;

	if(size3 <= 8){
		count += u64_intersect_scalar_stop(list1, size1, list2, size2, size3, i_a, i_b);
		return count;
	}

	uint64_t stop = size3 - 8;
	while(*i_a < st_a && *i_b < st_b){

		uint64_t a_max = list1[*i_a+3];
		uint64_t b_max = list2[*i_b+3];

		__m256i v_a = _mm256_loadu_si256((__m256i*)&(list1[*i_a]));
		__m256i v_b = _mm256_loadu_si256((__m256i*)&(list2[*i_b]));

		*i_a += (a_max <= b_max) * 4;
		*i_b += (a_max >= b_max) * 4;


		/*constexpr*/// const int64_t cyclic_shift = _MM_SHUFFLE(0,3,2,1); //rotating right
		/*constexpr*/// const int64_t cyclic_shift2= _MM_SHUFFLE(2,1,0,3); //rotating left
		/*constexpr*/// const int64_t cyclic_shift3= _MM_SHUFFLE(1,0,3,2); //between
		__m256i cmp_mask1 = _mm256_cmpeq_epi64(v_a, v_b);
		__m256i rot1 = _mm256_permute4x64_epi64(v_b, 57);//00111001
		__m256i cmp_mask2 = _mm256_cmpeq_epi64(v_a, (__m256i)rot1);
		__m256i rot2 = _mm256_permute4x64_epi64(v_b, 78);//01001110
		__m256i cmp_mask3 = _mm256_cmpeq_epi64(v_a, (__m256i)rot2);
		__m256i rot3 = _mm256_permute4x64_epi64(v_b, 147);//10010011
		__m256i cmp_mask4 = _mm256_cmpeq_epi64(v_a, (__m256i)rot3);

		__m256i cmp_mask = _mm256_or_si256(
				_mm256_or_si256(cmp_mask1, cmp_mask2),
				_mm256_or_si256(cmp_mask3, cmp_mask4)
				);
		int64_t mask = _mm256_movemask_pd((__m256d)cmp_mask);

		count += _mm_popcnt_u64(mask);
		//_mm512_mask_compressstoreu_epi64(&result[count], cmp0, v_a);
		//__m512i vres = _mm512_mask_compress_epi64(_mm512_setzero_epi32(), cmp0, v_a);
		//if(cmp0 > 0)
		//	inspect(vres);
		if(*i_a + *i_b - count >= stop){
			//count -= _mm_popcnt_u32(cmp0);
			//*i_a -= (a_max <= b_max) * 16;
			//*i_b -= (a_max >= b_max) * 16;
			break;
		}

	}
	count += u64_intersect_scalar_stop(list1+*i_a, size1-*i_a, list2+*i_b, size2-*i_b, size3 - (*i_a+*i_b - count), &i_a_s, &i_b_s);

	*i_a += i_a_s;
	*i_b += i_b_s;
	return count;
}
#else
#ifdef __SSE4_1__
// implement by sse

uint64_t u32_intersection_vector_sse(const uint32_t *list1, uint64_t size1, const uint32_t *list2, uint64_t size2, uint64_t size3, uint64_t *i_a, uint64_t *i_b){
	uint64_t count = 0;
	*i_a = 0;
	*i_b = 0;
	uint64_t st_a = (size1 / 4) * 4;
	uint64_t st_b = (size2 / 4) * 4;

	uint64_t i_a_s, i_b_s;

	if(size3 <= 8){
		count += u32_intersect_scalar_stop(list1, size1, list2, size2, size3, i_a, i_b);
		return count;
	}
	uint64_t stop = size3 - 8;
	while(*i_a < st_a && *i_b < st_b){

		uint32_t a_max = list1[*i_a + 3];
		uint32_t b_max = list2[*i_b + 3];

		__m128i v_a = _mm_loadu_si128((__m128i*)&(list1[*i_a]));
		__m128i v_b = _mm_loadu_si128((__m128i*)&(list2[*i_b]));

		*i_a += (a_max <= b_max) * 4;
		*i_b += (a_max >= b_max) * 4;

		__m128i cmp1 = _mm_cmpeq_epi32(v_a, v_b);
		__m128i rot1 = _mm_shuffle_epi32(v_b, 57);//00111001
		__m128i cmp2 = _mm_cmpeq_epi32(v_a, rot1);
		__m128i rot2 = _mm_shuffle_epi32(v_b, 78);//01001110
		__m128i cmp3 = _mm_cmpeq_epi32(v_a, rot2);
		__m128i rot3 = _mm_shuffle_epi32(v_b, 147);//10010011
		__m128i cmp4 = _mm_cmpeq_epi32(v_a, rot3);

		__m128i cmp = _mm_or_si128(_mm_or_si128(cmp1, cmp2),_mm_or_si128(cmp3, cmp4));
		int32_t mask = _mm_movemask_ps((__m128)cmp);
		count += _mm_popcnt_u32(mask);

		if(*i_a + *i_b - count >= stop) break;
	}
	count += u32_intersect_scalar_stop(list1+*i_a, size1-*i_a, list2+*i_b, size2-*i_b, size3-(*i_a+*i_b-count), &i_a_s, &i_b_s);

	*i_a += i_a_s;
	*i_b += i_b_s;

	return count;
}


uint64_t u64_intersection_vector_sse(const uint64_t *list1, uint64_t size1, const uint64_t *list2, uint64_t size2, uint64_t size3, uint64_t *i_a, uint64_t *i_b){
	uint64_t count = 0;
	*i_a = 0;
	*i_b = 0;
	uint64_t st_a = (size1 / 2) * 2;
	uint64_t st_b = (size2 / 2) * 2;

	uint64_t i_a_s, i_b_s;

	if(size3 <= 4){
		count += u64_intersect_scalar_stop(list1, size1, list2, size2, size3, i_a, i_b);
		return count;
	}
	uint64_t stop = size3 - 4;
	while(*i_a < st_a && *i_b < st_b){

		uint64_t a_max = list1[*i_a + 1];
		uint64_t b_max = list2[*i_b + 1];

		__m128i v_a = _mm_loadu_si128((__m128i*)&(list1[*i_a]));
		__m128i v_b = _mm_loadu_si128((__m128i*)&(list2[*i_b]));

		*i_a += (a_max <= b_max) * 2;
		*i_b += (a_max >= b_max) * 2;

		__m128i cmp1 = _mm_cmpeq_epi64(v_a, v_b);
		//inspect((__m128d)v_b);
		__m128d rot1 = _mm_shuffle_pd((__m128d)v_b, (__m128d)v_b, 1);//00000001
		//inspect(rot1);
		__m128i cmp2 = _mm_cmpeq_epi64(v_a, (__m128i)rot1);

		cmp1 = _mm_or_si128(cmp1, cmp2);
		int64_t mask = _mm_movemask_pd((__m128d)cmp1);
		count += _mm_popcnt_u64(mask);

		if(*i_a + *i_b - count >= stop){ break;}
	}
	count += u64_intersect_scalar_stop(list1+*i_a, size1-*i_a, list2+*i_b, size2-*i_b, size3-(*i_a+*i_b-count), &i_a_s, &i_b_s);

	*i_a += i_a_s;
	*i_b += i_b_s;

	return count;
}
#endif
#endif
#endif
