//#include <zlib.h>
#include "HyperLogLog.h"
#include "Sketch.h"
#include "MurmurHash3.h"
#include "hash_int.h"
//#include "x86intrin.h"
//#include "immintrin.h"

using namespace Sketch;


std::array<uint32_t,64> HyperLogLog::sum_counts(const std::vector<uint8_t> &sketchInfo) const {
	std::array<uint32_t,64> sum_count {0};//default 64
	for(uint64_t i=0; i<sketchInfo.size(); ++i){
		sum_count[sketchInfo[i]]++;
	}
	return sum_count;
}








/* 
template<typename T>
inline void avx512_statistic(std::vector<uint32_t> &sketch1, std::vector<uint32_t> &sketch2, T &c1l, T &c1g, T &c2l, T &c2g, T &ceq){
	//SIMD 
	//buffer
	uint32_t * CBuffer;
	CBuffer = _mm_malloc(16*64*5*sizeof(uint32_t), 32);//512

	uint32_t * c1lBuffer = _mm_malloc(16*64*sizeof(uint32_t), 32); //CBuffer;
	uint32_t * c1gBuffer = _mm_malloc(16*64*sizeof(uint32_t), 32); //CBuffer+16*64;
	uint32_t * c2lBuffer = _mm_malloc(16*64*sizeof(uint32_t), 32); //CBuffer+16*64*2;
	uint32_t * c2gBuffer = _mm_malloc(16*64*sizeof(uint32_t), 32); //CBuffer+16*64*3;
	uint32_t * ceqBuffer = _mm_malloc(16*64*sizeof(uint32_t), 32); //CBuffer+16*64*4;

	for(int i=0; i<64; ++i){
		for(int j=0; j<16; ++j){
			c1lBuffer[j*64+i] = 0;	
			c1gBuffer[j*64+i] = 0;	
			c2lBuffer[j*64+i] = 0;	
			c2gBuffer[j*64+i] = 0;	
			ceqBuffer[j*64+i] = 0;	
		}

		//fprintf(stdout,"%ld, ", c1[i]);
	}

	__m512i v_epi32_1 = _mm512_set1_epi32(1);
	__m512i v_def_val = _mm512_set1_epi32(63);
	__m512i v_scale = _mm512_set_epi32(64*15, 64*14, 64*13, 64*12,
			64*11, 64*10, 64*9, 64*8,
			64*7, 64*6, 64*5, 64*4,
			64*3, 64*2, 64, 0);

	for(uint64_t i=0; i<sketch1.size(); i+=16) {
		//load
		//__m512i v_sketch1 = _mm512_loadu_epi32(&sketch1[i]); // icpc AVX512F
		//__m512i v_sketch2 = _mm512_loadu_epi32(&sketch2[i]);
		__m512i v_sketch1 = _mm512_load_epi32(&sketch1[i]); //g++ AVX512F
		__m512i v_sketch2 = _mm512_load_epi32(&sketch2[i]);
		__m512i v_index1 = _mm512_add_epi32(v_sketch1, v_scale);
		__m512i v_index2 = _mm512_add_epi32(v_sketch2, v_scale);

		//compare
		__mmask16 v_msk_lt = _mm512_cmplt_epi32_mask(v_sketch1, v_sketch2);
		//gather //AVX512F
		__m512i v_c1l = _mm512_mask_i32gather_epi32(v_def_val, v_msk_lt, v_index1, c1lBuffer, 4);
		__m512i v_c2g = _mm512_mask_i32gather_epi32(v_def_val, v_msk_lt, v_index2, c2gBuffer, 4);
		//add
		v_c1l = _mm512_maskz_add_epi32(v_msk_lt, v_c1l, v_epi32_1);
		v_c2g = _mm512_maskz_add_epi32(v_msk_lt, v_c2g, v_epi32_1);
		//fprintf(stdout, " test: %ld,", _mm512_reduce_add_epi32(v_c1l));
		//scatter  //AVX512F 
		_mm512_mask_i32scatter_epi32(c1lBuffer, v_msk_lt, v_index1, v_c1l, 4);
		_mm512_mask_i32scatter_epi32(c2gBuffer, v_msk_lt, v_index2, v_c2g, 4);

		//compare
		__mmask16 v_msk_gt = _mm512_cmpgt_epi32_mask(v_sketch1, v_sketch2);
		//gather
		__m512i v_c1g = _mm512_mask_i32gather_epi32(v_def_val, v_msk_gt, v_index1, c1gBuffer, 4);
		__m512i v_c2l = _mm512_mask_i32gather_epi32(v_def_val, v_msk_gt, v_index2, c2lBuffer, 4);
		//add
		v_c1g = _mm512_maskz_add_epi32(v_msk_gt, v_c1g, v_epi32_1);
		v_c2l = _mm512_maskz_add_epi32(v_msk_gt, v_c2l, v_epi32_1);
		//scatter
		_mm512_mask_i32scatter_epi32(c1gBuffer, v_msk_gt, v_index1, v_c1g, 4);
		_mm512_mask_i32scatter_epi32(c2lBuffer, v_msk_gt, v_index2, v_c2l, 4);

		//compare
		__mmask16 v_msk_eq = _mm512_cmpeq_epi32_mask(v_sketch1, v_sketch2);
		//gather
		__m512i v_ceq = _mm512_mask_i32gather_epi32(v_def_val, v_msk_eq, v_index1, ceqBuffer, 4);
		//add
		v_ceq = _mm512_maskz_add_epi32(v_msk_eq, v_ceq, v_epi32_1);
		//scatter
		_mm512_mask_i32scatter_epi32(ceqBuffer, v_msk_eq, v_index1, v_ceq, 4);

	}
	//merge

	//for(int i=0; i<64; ++i){
	//	for(int j=0; j<16; ++j){
	//		c1l[i] = c1l[i] + c1lBuffer[j*64+i];	
	//		c1g[i] = c1g[i] + c1gBuffer[j*64+i];	
	//		c2l[i] = c2l[i] + c2lBuffer[j*64+i];	
	//		c2g[i] = c2g[i] + c2gBuffer[j*64+i];	
	//		ceq[i] = ceq[i] + ceqBuffer[j*64+i];	
	//	}

	//	fprintf(stdout,"%ld, ", c1[i]);
	//}

	for (int j=0; j<64; j+=16){
		__m512i v_merge = _mm512_set1_epi32(0);
		for (int i=0; i<16; ++i){
			//__m512i v_temp = _mm512_loadu_epi32(c1lBuffer+i*64+j);
			__m512i v_temp = _mm512_load_epi32(c1lBuffer+i*64+j);
			v_merge = _mm512_add_epi32(v_merge, v_temp);
		}
		//_mm512_storeu_epi32(c1l.data()+j, v_merge);
		_mm512_store_epi32(c1l.data()+j, v_merge);
	}
	for (int j=0; j<64; j+=16){
		__m512i v_merge = _mm512_set1_epi32(0);
		for (int i=0; i<16; ++i){
			//__m512i v_temp = _mm512_loadu_epi32(c1gBuffer+i*64+j);
			__m512i v_temp = _mm512_load_epi32(c1gBuffer+i*64+j);
			v_merge = _mm512_add_epi32(v_merge, v_temp);
		}
		//_mm512_storeu_epi32(c1g.data()+j, v_merge);
		_mm512_store_epi32(c1g.data()+j, v_merge);
	}
	for (int j=0; j<64; j+=16){
		__m512i v_merge = _mm512_set1_epi32(0);
		for (int i=0; i<16; ++i){
			//__m512i v_temp = _mm512_loadu_epi32(c2lBuffer+i*64+j);
			__m512i v_temp = _mm512_load_epi32(c2lBuffer+i*64+j);
			v_merge = _mm512_add_epi32(v_merge, v_temp);
		}
		//_mm512_storeu_epi32(c2l.data()+j, v_merge);
		_mm512_store_epi32(c2l.data()+j, v_merge);
	}
	for (int j=0; j<64; j+=16){
		__m512i v_merge = _mm512_set1_epi32(0);
		for (int i=0; i<16; ++i){
			//__m512i v_temp = _mm512_loadu_epi32(c2gBuffer+i*64+j);
			__m512i v_temp = _mm512_load_epi32(c2gBuffer+i*64+j);
			v_merge = _mm512_add_epi32(v_merge, v_temp);
		}
		//_mm512_storeu_epi32(c2g.data()+j, v_merge);
		_mm512_store_epi32(c2g.data()+j, v_merge);
	}
	for (int j=0; j<64; j+=16){
		__m512i v_merge = _mm512_set1_epi32(0);
		for (int i=0; i<16; ++i){
			//__m512i v_temp = _mm512_loadu_epi32(ceqBuffer+i*64+j);
			__m512i v_temp = _mm512_load_epi32(ceqBuffer+i*64+j);
			v_merge = _mm512_add_epi32(v_merge, v_temp);
		}
		//_mm512_storeu_epi32(ceq.data()+j, v_merge);
		_mm512_store_epi32(ceq.data()+j, v_merge);
	}

	_mm_free(c1lBuffer);
	_mm_free(c1gBuffer);
	_mm_free(c2lBuffer);
	_mm_free(c2gBuffer);
	_mm_free(ceqBuffer);
	//#if DEBUG
	//	for(int i=0; i<64; i++){
	//		if(c1l[i] != c1l_old[i])
	//			fprintf(stdout," [W:%s:%d] error new=%ld, old=%ld \n", __LINE__, c1l[i], c1l_old[i]);
	//		if(c1g[i] != c1g_old[i])
	//			fprintf(stdout," [W:%s:%d] error new=%ld, old=%ld \n", __LINE__, c1g[i], c1g_old[i]);
	//		if(c2l[i] != c2l_old[i])
	//			fprintf(stdout," [W:%s:%d] error new=%ld, old=%ld \n", __LINE__, c2l[i], c2l_old[i]);
	//		if(c2g[i] != c2g_old[i])
	//			fprintf(stdout," [W:%s:%d] error new=%ld, old=%ld \n", __LINE__, c2g[i], c2g_old[i]);
	//		if(ceq[i] != ceq_old[i])
	//			fprintf(stdout," [W:%s:%d] error new=%ld, old=%ld \n", __LINE__, ceq[i], ceq_old[i]);
	//	}
	//#endif


	return;
}

*/

/*

   template<typename T>
   inline void avx2_statistic(std::vector<uint32_t> &sketch1, std::vector<uint32_t> &sketch2, T &c1l, T &c1g, T &c2l, T &c2g, T &ceq){
//SIMD 
//buffer
//uint32_t * CBuffer;
//CBuffer = _mm_malloc(16*64*5*sizeof(uint32_t), 32);//512

uint32_t * c1lBuffer = _mm_malloc(8*64*sizeof(uint32_t), 32); //CBuffer;//8=256/32
uint32_t * c1gBuffer = _mm_malloc(8*64*sizeof(uint32_t), 32); //CBuffer+16*64;
uint32_t * c2lBuffer = _mm_malloc(8*64*sizeof(uint32_t), 32); //CBuffer+16*64*2;
uint32_t * c2gBuffer = _mm_malloc(8*64*sizeof(uint32_t), 32); //CBuffer+16*64*3;
uint32_t * ceqBuffer = _mm_malloc(8*64*sizeof(uint32_t), 32); //CBuffer+16*64*4;

for(int i=0; i<64; ++i){
for(int j=0; j<8; ++j){
c1lBuffer[j*64+i] = 0;	
c1gBuffer[j*64+i] = 0;	
c2lBuffer[j*64+i] = 0;	
c2gBuffer[j*64+i] = 0;	
ceqBuffer[j*64+i] = 0;	
}

//fprintf(stdout,"%ld, ", c1[i]);
}

//__m512i v_epi32_1 = _mm512_set1_epi32(1);
__m256i v_epi32_1 = _mm256_set1_epi32(1); //AVX
__m256i v_def_val = _mm256_set1_epi32(63);
__m256i v_scale = _mm256_set_epi32(
64*7, 64*6, 64*5, 64*4,
64*3, 64*2, 64, 0);

for(uint64_t i=0; i<sketch1.size(); i+=8) {
//load
//__m512i v_sketch1 = _mm512_loadu_epi32(&sketch32_1[i]);
__m256i v_sketch1 = _mm256_loadu_si256((__m256i *) &sketch1[i]);
__m256i v_sketch2 = _mm256_loadu_si256((__m256i *) &sketch2[i]);
__m256i v_index1 = _mm256_add_epi32(v_sketch1, v_scale);
__m256i v_index2 = _mm256_add_epi32(v_sketch2, v_scale);

//compare
//__mmask16 v_msk_gt = _mm512_cmpgt_epi32_mask(v_sketch1, v_sketch2);
__m256i v_msk_gt = _mm256_cmpgt_epi32(v_sketch1, v_sketch2);
//gather
//__m256i v_c1g = _mm256_mask_i32gather_epi32(v_def_val, v_msk_gt, v_index1, c1gBuffer, 4);
__m256i v_c1g = _mm256_mask_i32gather_epi32(v_def_val, (int *) c1gBuffer, v_index1, v_msk_gt, 4);
//__m512i v_c2l = _mm512_mask_i32gather_epi32(v_def_val, v_msk_gt, v_index2, c2lBuffer, 4);
__m256i v_c2l = _mm256_mask_i32gather_epi32(v_def_val, (int *) c2lBuffer, v_index2, v_msk_gt, 4);
//add
//add mask
__m256i v_add_gt = _mm256_and_si256(v_epi32_1, v_msk_gt);
v_c1g = _mm256_add_epi32(v_c1g, v_add_gt);
v_c2l = _mm256_add_epi32(v_c2l, v_add_gt);

//scatter
_mm256_fake_scatter_epi32(c1gBuffer, v_index1, v_c1g);
_mm256_fake_scatter_epi32(c2lBuffer, v_index2, v_c2l);

//compare
//__mmask16 v_msk_eq = _mm512_cmpeq_epi32_mask(v_sketch1, v_sketch2);
__m256i v_msk_eq = _mm256_cmpeq_epi32(v_sketch1, v_sketch2);
//gather
//__m512i v_ceq = _mm512_mask_i32gather_epi32(v_def_val, v_msk_eq, v_index1, ceqBuffer, 4);
__m256i v_ceq = _mm256_mask_i32gather_epi32(v_def_val, (int *) ceqBuffer, v_index1, v_msk_eq, 4);
//add
//v_ceq = _mm512_maskz_add_epi32(v_msk_eq, v_ceq, v_epi32_1);
__m256i v_add_eq = _mm256_and_si256(v_epi32_1, v_msk_eq);
v_ceq = _mm256_add_epi32(v_ceq, v_add_eq);
//scatter
//_mm512_mask_i32scatter_epi32(ceqBuffer, v_msk_eq, v_index1, v_ceq, 4);
_mm256_fake_scatter_epi32(ceqBuffer, v_index1, v_ceq);

//compare // AVX2
//__mmask16 v_msk_lt = _mm512_cmplt_epi32_mask(v_sketch1, v_sketch2);
__m256i v_msk_lt = _mm256_xor_si256(_mm256_or_si256(v_msk_gt, v_msk_eq), v_epi32_1);
//gather 
//__m512i v_c1l = _mm512_mask_i32gather_epi32(v_def_val, v_msk_lt, v_index1, c1lBuffer, 4);
//__m512i v_c2g = _mm512_mask_i32gather_epi32(v_def_val, v_msk_lt, v_index2, c2gBuffer, 4);
__m256i v_c1l = _mm256_mask_i32gather_epi32(v_def_val, (int *) c1lBuffer, v_index1, v_msk_lt, 4);
__m256i v_c2g = _mm256_mask_i32gather_epi32(v_def_val, (int *) c2gBuffer, v_index2, v_msk_lt, 4);
//add
//v_c1l = _mm512_maskz_add_epi32(v_msk_lt, v_c1l, v_epi32_1);
//v_c2g = _mm512_maskz_add_epi32(v_msk_lt, v_c2g, v_epi32_1);
__m256i v_add_lt = _mm256_and_si256(v_epi32_1, v_msk_lt);
v_c1l = _mm256_add_epi32(v_c1l, v_add_lt);
v_c2g = _mm256_add_epi32(v_c2g, v_add_lt);
//scatter   
//_mm512_mask_i32scatter_epi32(c1lBuffer, v_msk_lt, v_index1, v_c1l, 4);
//_mm512_mask_i32scatter_epi32(c2gBuffer, v_msk_lt, v_index2, v_c2g, 4);
_mm256_fake_scatter_epi32(c1lBuffer, v_index1, v_c1l);
_mm256_fake_scatter_epi32(c2gBuffer, v_index2, v_c2g);


}
//merge

//for(int i=0; i<64; ++i){
//	for(int j=0; j<16; ++j){
//		c1l[i] = c1l[i] + c1lBuffer[j*64+i];	
//		c1g[i] = c1g[i] + c1gBuffer[j*64+i];	
//		c2l[i] = c2l[i] + c2lBuffer[j*64+i];	
//		c2g[i] = c2g[i] + c2gBuffer[j*64+i];	
//		ceq[i] = ceq[i] + ceqBuffer[j*64+i];	
//	}

//	fprintf(stdout,"%ld, ", c1[i]);
//}

for (int j=0; j<64; j+=8){
	__m256i v_merge = _mm256_set1_epi32(0);
	for (int i=0; i<8; ++i){
		__m256i v_temp = _mm256_loadu_si256((__m256i *) c1lBuffer+i*64+j);//512
		v_merge = _mm256_add_epi32(v_merge, v_temp);
	}
	_mm256_store_si256((__m256i *)c1l.data()+j, v_merge);
}
for (int j=0; j<64; j+=8){
	__m256i v_merge = _mm256_set1_epi32(0);
	for (int i=0; i<8; ++i){
		__m256i v_temp = _mm256_loadu_si256((__m256i *)c1gBuffer+i*64+j);
		v_merge = _mm256_add_epi32(v_merge, v_temp);
	}
	_mm256_store_si256((__m256i *)c1g.data()+j, v_merge);
}
for (int j=0; j<64; j+=8){
	__m256i v_merge = _mm256_set1_epi32(0);
	for (int i=0; i<8; ++i){
		__m256i v_temp = _mm256_loadu_si256((__m256i *)c2lBuffer+i*64+j);
		v_merge = _mm256_add_epi32(v_merge, v_temp);
	}
	_mm256_store_si256((__m256i *)c2l.data()+j, v_merge);
}
for (int j=0; j<64; j+=8){
	__m256i v_merge = _mm256_set1_epi32(0);
	for (int i=0; i<8; ++i){
		__m256i v_temp = _mm256_loadu_si256((__m256i *)c2gBuffer+i*64+j);
		v_merge = _mm256_add_epi32(v_merge, v_temp);
	}
	_mm256_store_si256((__m256i *)c2g.data()+j, v_merge);
}
for (int j=0; j<64; j+=8){
	__m256i v_merge = _mm256_set1_epi32(0);
	for (int i=0; i<16; ++i){
		__m256i v_temp = _mm256_loadu_si256((__m256i *)ceqBuffer+i*64+j);
		v_merge = _mm256_add_epi32(v_merge, v_temp);
	}
	_mm256_store_si256((__m256i *)ceq.data()+j, v_merge);
}

_mm_free(c1lBuffer);
_mm_free(c1gBuffer);
_mm_free(c2lBuffer);
_mm_free(c2gBuffer);
_mm_free(ceqBuffer);
return;
}

inline void _mm256_fake_scatter_epi32(uint32_t *mem_addr, __m256i vindex, __m256i src)
{
	for(int i=0; i<8; i++)
		//mem_addr[((long long *)&vindex)[i]] = ((uint32_t *)&src)[i];
		mem_addr[((uint32_t *)&vindex)[i]] = ((uint32_t *)&src)[i];
	return;
}
*/


template<typename T>
void HyperLogLog::compTwoSketch(const std::vector<uint8_t> &sketch1, const std::vector<uint8_t> &sketch2, T &c1, T &c2, T &cu, T &cg1, T &cg2, T &ceq) const {
	assert(sketch1.size()==sketch2.size());//
	std::array<uint32_t, 64> c1l{0}, c2l{0}, c1g{0}, c2g{0};
	/* */
//#pragma vector aligned
//#pragma omp simd aligned(sketch1, sketch2, c1l, c2l, c1g, c2g, ceq : 64)
	for(uint64_t i=0; i<sketch1.size(); ++i) {
//  __asm__ __volatile__("DEBUG0:":::);
    uint8_t idx1 = sketch1[i];
    uint8_t idx2 = sketch2[i];
    int num =(idx1 < idx2);
    //int num = ((idx1 - idx2) >> 31) & 1;
    int num1 = (idx1 == idx2);

    c1l[idx1] += num;
    c2g[idx2] += num;

    c1g[idx1] += 1 - num - num1;
    c2l[idx2] += 1 - num - num1;

    ceq[idx1] += num1;

//  __asm__ __volatile__("DEBUG1:":::);
  

		//TODO: SIMD
		//if(sketch1[i]<sketch2[i]){
		//	c1l[sketch1[i]]++;
		//	c2g[sketch2[i]]++;
		//} else if(sketch1[i]>sketch2[i]){
		//	c1g[sketch1[i]]++;
		//	c2l[sketch2[i]]++;
		//} else{
		//	ceq[sketch1[i]]++;
		//}
	}
	/* 
	   std::vector<uint32_t> sketch32_1, sketch32_2;
	   for(uint64_t i=0; i<sketch1.size(); i++) {
	   sketch32_1.push_back(sketch1[i]);
	   sketch32_2.push_back(sketch2[i]);
	   }
	//SIMD
	avx512_statistic(sketch32_1, sketch32_2, c1l, c1g, c2l, c2g, ceq);
	//TODO: BUG in fake_scatter
	//avx2_statistic(sketch32_1, sketch32_2, c1l, c1g, c2l, c2g, ceq);
	*/
	for(int i=0; i<64; ++i) {
		c1[i] = c1l[i] + ceq[i] + c1g[i];
		c2[i] = c2l[i] + ceq[i] + c2g[i];
		cu[i] = c1g[i] + ceq[i] + c2g[i];
		cg1[i] = c1g[i];
		cg2[i] = c2g[i];
		//	fprintf(stdout,"%ld, ", c1[i]);
	}

}


// TODO: using SIMD to accelerate
 void HyperLogLog::update(char* seq) {
 	//reverse&complenment
 	const uint64_t LENGTH = strlen(seq);
 	for(uint64_t i = 0; i < LENGTH; i++){
 		if(seq[i] > 96 && seq[i] < 123){
 			seq[i] -= 32;
 		}
 	}

	uint32_t qq = q();
 	char* seqRev;
 	seqRev = new char[LENGTH];
 	char table[4] = {'T','G','A','C'};
 	for ( uint64_t i = 0; i < LENGTH; i++ )
 	{
 		char base = seq[i];
 		base >>= 1;
 		base &= 0x03;
 		seqRev[LENGTH - i - 1] = table[base];
 	}
 	//sequence -> kmer
 	//fprintf(stderr, "seqRev = %s \n", seqRev);
 	const int KMERLEN = 32;
 	if(LENGTH < KMERLEN) return;
	int lanes = 8;
	//remainder
// 	for(uint64_t i=0; i<((LENGTH-KMERLEN)/lanes)*lanes; i+=lanes) 
//	{
// 	//for(uint64_t i=((LENGTH-KMERLEN)/lanes)*lanes; i<LENGTH-KMERLEN; ++i) 
// 		//char kmer[KMERLEN+1];
// 		char kmer_fwd[KMERLEN+1];
// 		char kmer_rev[KMERLEN+1];
// 		memcpy(kmer_fwd, seq+i, KMERLEN);
// 		memcpy(kmer_rev, seqRev+LENGTH-i-KMERLEN, KMERLEN);
// 		kmer_fwd[KMERLEN] = '\0';
// 		kmer_rev[KMERLEN] = '\0';
//
// 		if(memcmp(kmer_fwd, kmer_rev, KMERLEN) <= 0) {
// 			//fprintf(stderr, "kmer_fwd = %s \n", kmer_fwd);
// 			//addh(kmer_fwd);
// 			//calc 64bit int hashes and count leading zero
// 			//step1 hash to int
// 			//step2 call int hash 
// 			//step3 lzcnt
// 		    //uint8_t mask = 0x06; //FIXME: not general only works for DNA sequences, it's just a trick.
//	        uint64_t res = 0;
//	        for(int i = 0; i < KMERLEN; i++)
//	        {
//		    	uint8_t meri = (uint8_t)kmer_fwd[i];
//		    	meri &= 0x06;
//		    	meri >>= 1;
//		    	res |= (uint64_t)meri;
//		    	res << 2;
//			}
//			uint64_t hashval = mc::murmur3_fmix(res, 42);
//			const uint32_t index(hashval >> q());
//			const uint8_t lzt(clz(((hashval << 1)|1) << (np_ - 1)) + 1);
//			core_[index] = std::max(core_[index], lzt);
//#if LZ_COUNTER
//			++clz_counts_[clz(((hashval << 1)|1) << (np_ - 1)) + 1];
//#endif
//
//			
// 		} else {
// 			//fprintf(stderr, "kmer_rev = %s \n", kmer_rev);
// 			//calc 64bit hashes and count leading zero
// 			//addh(kmer_rev);
// 			//	        
// 			uint64_t res = 0;
//	        for(int i = 0; i < KMERLEN; i++)
//	        {
//		    	uint8_t meri = (uint8_t)kmer_rev[i];
//		    	meri &= 0x06;
//		    	meri >>= 1;
//		    	res |= (uint64_t)meri;
//		    	res << 2;
//			}
//			uint64_t hashval = mc::murmur3_fmix(res, 42);
//			const uint32_t index(hashval >> q());
//			const uint8_t lzt(clz(((hashval << 1)|1) << (np_ - 1)) + 1);
//			core_[index] = std::max(core_[index], lzt);
//#if LZ_COUNTER
//			++clz_counts_[clz(((hashval << 1)|1) << (np_ - 1)) + 1];
//#endif
// 			
// 		}
//		//fprintf(stderr,"calling int hashes\n");
// 
// 	}
//
//
#if defined __AVX512F__  && defined __AVX512DQ__
	//__m512i vzero   = _mm512_set1_epi64(0);
	__m512i vconst0 = _mm512_set1_epi64(0xff51afd7ed558ccd);
	__m512i vconst1 = _mm512_set1_epi64(0xc4ceb9fe1a85ec53);
//	__mmask8 weight_msk = l > 0 ? 0xFF : 0x00;
	//fprintf(stderr, "using AVX512\n");
#endif
#if defined __AVX512F__  && defined __AVX512CD__
	__m512i v1 = _mm512_set1_epi64(1);
#endif 

 	for(uint64_t i=0; i<((LENGTH-KMERLEN)/lanes)*lanes; i+=lanes) 
 	//for(uint64_t i=0; i<LENGTH-KMERLEN; ++i) 
	{
		char kmer_fwd[8*(KMERLEN+1)];
		char kmer_rev[8*(KMERLEN+1)];
		const char * this_kmer;
		uint64_t resv[8];
		for (int j = 0; j< lanes; j++)
		{
			memcpy(&kmer_fwd[j*(KMERLEN+1)], seq+i+j, KMERLEN);
			memcpy(&kmer_rev[j*(KMERLEN+1)], seqRev+LENGTH-(i+j)-KMERLEN, KMERLEN);
			kmer_fwd[j*(KMERLEN+1) + KMERLEN] = '\0';
			kmer_rev[j*(KMERLEN+1) + KMERLEN] = '\0';

			if(memcmp(kmer_fwd, kmer_rev, KMERLEN) <= 0) {
				this_kmer = kmer_fwd;
			}else {
				this_kmer = kmer_rev;
			}
 			uint64_t res = 0;
	        for(int i = 0; i < KMERLEN; i++)
	        {
		    	uint8_t meri = (uint8_t)this_kmer[i];
		    	meri &= 0x06;
		    	meri >>= 1;
		    	res |= (uint64_t)meri;
		    	res << 2;
			}
			resv[j] = res;
		}

		//int hash
		//for (int j = i; j< i + lanes; j++)
		uint64_t hashvalv[8];

			//fprintf(stderr, "kmer_fwd = %s \n", kmer_fwd);
			//addh(kmer_fwd);
		#if defined __AVX512F__ && __AVX512DQ__
		//using AVX512
		//__m512i va = _mm512_loadu_si512((void *)&intHash[id + 0 * 8]);
		//__m512i vocc = _mm512_loadu_si512((void *)&occ[id + 0 * 8]);
		//__m512i vb = _mm512_mask_add_epi64(va, weight_msk, va, vocc);

		__m512i vb = _mm512_loadu_si512((void *)resv);
		__m512i vseed = _mm512_set1_epi64(42);
		__m512i va = _mm512_xor_epi64(vb, vseed);
		__m512i vtmp = _mm512_srli_epi64(va, 33);
		vb = _mm512_xor_epi64(va, vtmp);
		va = _mm512_mullo_epi64(vb, vconst0);
		vtmp = _mm512_srli_epi64(va, 33);
		vb = _mm512_xor_epi64(va, vtmp);
		va = _mm512_mullo_epi64(vb, vconst1);
		vtmp = _mm512_srli_epi64(va, 33);
		vb = _mm512_xor_epi64(va, vtmp);
		_mm512_storeu_si512(hashvalv, vb);

		#else	
		for (int j = 0; j< lanes; j++)
			hashvalv[j] = mc::murmur3_fmix(resv[j], 42);
		#endif
		uint64_t indexv[8];
		uint64_t lztv[8];
		//#if 0
		#if defined __AVX512CD__  && __AVX512F__
		//indexv[j] = hashvalv[j] >> qq;
		__m512i vhash = _mm512_loadu_si512((void*)hashvalv);
		__m512i vindex = _mm512_srli_epi64(vhash, (uint8_t)qq);	
		_mm512_storeu_si512(indexv, vindex);

		//lztv[j] = clz(((hashvalv[j] << 1)|1) << (np_ - 1)) + 1;
		__m512i vlzhash = _mm512_slli_epi64(vhash, 1);
		vhash = _mm512_or_epi64(vlzhash, v1);
		vlzhash = _mm512_slli_epi64(vhash, (uint8_t)(np_ - 1));
		vhash = _mm512_lzcnt_epi64(vlzhash);
		vlzhash = _mm512_add_epi64(vhash, v1);
		_mm512_storeu_si512(lztv, vlzhash);

		#else 

		for (int j = 0; j< lanes; j++)
		{
			//const uint32_t index(hashvalv[j] >> q());
			indexv[j] = hashvalv[j] >> qq;
			//const uint8_t lzt(clz(((hashvalv[j] << 1)|1) << (np_ - 1)) + 1);
			lztv[j] = clz(((hashvalv[j] << 1)|1) << (np_ - 1)) + 1;
 		}

		#endif 

		for (int j = 0; j< lanes; j++)
		{
			//core_[uint32_t(indexv[j])] = std::max(core_[(uint32_t)(indexv[j])], (uint8_t)lztv[j]);
			core_[indexv[j]] = std::max(core_[indexv[j]], (uint8_t)lztv[j]);
#if LZ_COUNTER
			++clz_counts_[clz(((hashvalv[j] << 1)|1) << (np_ - 1)) + 1];
			//++clz_counts_[lztv[j]];
#endif

		}

	}


	//remainder
 	for(uint64_t i=((LENGTH-KMERLEN)/lanes)*lanes; i<LENGTH-KMERLEN; ++i) 
 	//for(uint64_t i=0; i<LENGTH-KMERLEN; ++i) 
	{
		char kmer_fwd[KMERLEN+1];
		char kmer_rev[KMERLEN+1];
		memcpy(kmer_fwd, seq+i, KMERLEN);
		memcpy(kmer_rev, seqRev+LENGTH-i-KMERLEN, KMERLEN);
		kmer_fwd[KMERLEN] = '\0';
		kmer_rev[KMERLEN] = '\0';
		if(memcmp(kmer_fwd, kmer_rev, KMERLEN) <= 0) {
			//fprintf(stderr, "kmer_fwd = %s \n", kmer_fwd);
			//addh(kmer_fwd);
 			uint64_t res = 0;
	        for(int i = 0; i < KMERLEN; i++)
	        {
		    	uint8_t meri = (uint8_t)kmer_fwd[i];
		    	meri &= 0x06;
		    	meri >>= 1;
		    	res |= (uint64_t)meri;
		    	res << 2;
			}
			uint64_t hashval = mc::murmur3_fmix(res, 42);
			const uint32_t index(hashval >> q());
			const uint8_t lzt(clz(((hashval << 1)|1) << (np_ - 1)) + 1);
			core_[index] = std::max(core_[index], lzt);
#if LZ_COUNTER
			++clz_counts_[clz(((hashval << 1)|1) << (np_ - 1)) + 1];
#endif

		} else {
			//fprintf(stderr, "kmer_rev = %s \n", kmer_rev);
			//addh(kmer_rev);
 			uint64_t res = 0;
	        for(int i = 0; i < KMERLEN; i++)
	        {
		    	uint8_t meri = (uint8_t)kmer_rev[i];
		    	meri &= 0x06;
		    	meri >>= 1;
		    	res |= (uint64_t)meri;
		    	res << 2;
			}
			uint64_t hashval = mc::murmur3_fmix(res, 42);
			const uint32_t index(hashval >> q());
			const uint8_t lzt(clz(((hashval << 1)|1) << (np_ - 1)) + 1);
			core_[index] = std::max(core_[index], lzt);
#if LZ_COUNTER
			++clz_counts_[clz(((hashval << 1)|1) << (np_ - 1)) + 1];
#endif

		}
 
 	}

 	delete [] seqRev;
 }
 
//void HyperLogLog::update(char* seq) {
//    const uint64_t LENGTH = strlen(seq);
//    #pragma omp parallel for
//    for(uint64_t i = 0; i < LENGTH; i++){
//        if(seq[i] > 96 && seq[i] < 123){
//            seq[i] -= 32;
//        }
//    }
//
//    char* seqRev;
//    seqRev = new char[LENGTH];
//    char table[4] = {'T','G','A','C'};
//    #pragma omp parallel for
//    for ( uint64_t i = 0; i < LENGTH; i++ )
//    {
//        char base = seq[i];
//        base >>= 1;
//        base &= 0x03;
//        seqRev[LENGTH - i - 1] = table[base];
//    }
//
//    const int KMERLEN = 32;
//    if(LENGTH < KMERLEN) {
//        delete [] seqRev;
//        return;
//    }
//
//    #pragma omp parallel for
//    for(uint64_t i=0; i<LENGTH-KMERLEN; ++i) {
//        char kmer_fwd[KMERLEN+1];
//        char kmer_rev[KMERLEN+1];
//        memcpy(kmer_fwd, seq+i, KMERLEN);
//        memcpy(kmer_rev, seqRev+LENGTH-i-KMERLEN, KMERLEN);
//        kmer_fwd[KMERLEN] = '\0';
//        kmer_rev[KMERLEN] = '\0';
//        if(memcmp(kmer_fwd, kmer_rev, KMERLEN) <= 0) {
//            addh(kmer_fwd);
//        } else {
//            addh(kmer_rev);
//        }
//    }
//
//    delete [] seqRev;
//}
//

HyperLogLog HyperLogLog::merge(const HyperLogLog &other) const {
	if(other.p() != p())
		throw std::runtime_error(std::string("p (") + std::to_string(p()) + " != other.p (" + std::to_string(other.p()));
	HyperLogLog ret(*this);
	//ret += other;
	//ret.core_ = max(core_, other.core_);
	for(uint64_t i=0; i<m(); ++i){
		ret.core_[i] = std::max(core_[i],other.core_[i]); 
	}
	return ret;
}


//TODO: int hash
//HyperLogLog::inline void addh(uint64_t element) {
//	element = hash(element); //TODO: which hf_
//	add(element);
//}
inline void HyperLogLog::addh(const std::string &element) {
	//add(std::hash<std::string>{}(element));
	uint64_t res[2];
	int len = element.length();
	const uint32_t seed = 42;
	MurmurHash3_x64_128(element.c_str(), len, seed, res);
	add(res[0]);
	
}

//TODO: different hash function
//hash() {
//}

//TODO: clz is a function in clz.h
inline void HyperLogLog::add(uint64_t hashval) {
	const uint32_t index(hashval >> q());
	const uint8_t lzt(clz(((hashval << 1)|1) << (np_ - 1)) + 1);
	core_[index] = std::max(core_[index], lzt);
#if LZ_COUNTER
	++clz_counts_[clz(((hashval << 1)|1) << (np_ - 1)) + 1];
#endif
}
//Added by liumy to show sketch for testing. 
void HyperLogLog::printSketch(){
	fprintf(stdout,"Sketch info: [");
	int vecSize = core_.size();
	for(int i=0; i<vecSize-1; ++i)
		fprintf( stdout," %u,",  core_[i] );
	fprintf(stdout," %u ]\n", core_[vecSize-1]);
}

double HyperLogLog::union_size(const HyperLogLog &other) const {
	if(jestim_ != JointEstimationMethod::ERTL_JOINT_MLE) {
		assert(m() == other.m()|| !std::fprintf(stderr, "sizes don't match! Size1: %zu. Size2: %zu\n", m(), other.m()));
		std::array<uint32_t,64> counts{0};
		std::vector<uint8_t> unionCore(m(),0);
		for(uint64_t i=0; i<m(); ++i){
			unionCore[i] = std::max(core_[i],other.core_[i]); 
		}
		counts = sum_counts(unionCore);
		return calculate_estimate(counts, get_estim(), m(), p(), alpha(), 1e-2);
	}
	//std::fprintf(stderr, "jestim is ERTL_JOINT_MLE: %s\n", JESTIM_STRINGS[jestim_]);
	const auto full_counts = ertl_joint(*this, other);
	return full_counts[0] + full_counts[1] + full_counts[2];
}


double HyperLogLog::jaccard_index(const HyperLogLog &h2) const {
	if(jestim_ == JointEstimationMethod::ERTL_JOINT_MLE) {
		auto full_cmps = ertl_joint(*this, h2);
		const auto ret = full_cmps[2] / (full_cmps[0] + full_cmps[1] + full_cmps[2]);
		return ret;
	}
	const double us = union_size(h2);
	const double ret = (creport() + h2.creport() - us) / us;
	return std::max(0., ret);
}

template<typename T>
double HyperLogLog::ertl_ml_estimate(const T& c, unsigned p, unsigned q, double relerr) const {
	/*
	   Note --
	   Putting all these optimizations together finally gives the new cardinality estimation
	   algorithm presented as Algorithm 8. The algorithm requires mainly only elementary
	   operations. For very large cardinalities it makes sense to use the strong (46) instead
	   of the weak lower bound (47) as second starting point for the secant method. The
	   stronger bound is a much better approximation especially for large cardinalities, where
	   the extra logarithm evaluation is amortized by savings in the number of iteration cycles.
	   -Ertl paper.
TODO:  Consider adding this change to the method. This could improve our performance for other
*/

#if DEBUG
	fprintf(stdout,"[W:%s:%d] Counts: ",__PRETTY_FUNCTION__, __LINE__);
	for(int i=0; i<64; i++)
		fprintf(stdout,"%d, ", c[i]);
	fprintf(stdout,"\n");
#endif

	const uint64_t m = 1ull << p;
	if (c[q+1] == m) return std::numeric_limits<double>::infinity();

	int kMin, kMax;
	for(kMin=0; c[kMin]==0; ++kMin);
	int kMinPrime = std::max(1, kMin);
	for(kMax=q+1; kMax && c[kMax]==0; --kMax);
	int kMaxPrime = std::min(static_cast<int>(q), kMax);
	double z = 0.;
	for(int k = kMaxPrime; k >= kMinPrime; z = 0.5*z + c[k--]);
	z = ldexp(z, -kMinPrime);
	unsigned cPrime = c[q+1];
	if(q) cPrime += c[kMaxPrime];
	double gprev;
	double x;
	double a = z + c[0];
	int mPrime = m - c[0];
	gprev = z + ldexp(c[q+1], -q); // Reuse gprev, setting to 0 after.
	x = gprev <= 1.5*a ? mPrime/(0.5*gprev+a): (mPrime/gprev)*std::log1p(gprev/a);
	gprev = 0;
	double deltaX = x;
	relerr /= std::sqrt(m);
	while(deltaX > x*relerr) {
		int kappaMinus1;
		frexp(x, &kappaMinus1);
		double xPrime = ldexp(x, -std::max(static_cast<int>(kMaxPrime+1), kappaMinus1+2));
		double xPrime2 = xPrime*xPrime;
		double h = xPrime - xPrime2/3 + (xPrime2*xPrime2)*(1./45. - xPrime2/472.5);
		for(int k = kappaMinus1; k >= kMaxPrime; --k) {
			double hPrime = 1. - h;
			h = (xPrime + h*hPrime)/(xPrime+hPrime);
			xPrime += xPrime;
		}
		double g = cPrime*h;
		for(int k = kMaxPrime-1; k >= kMinPrime; --k) {
			double hPrime = 1. - h;
			h = (xPrime + h*hPrime)/(xPrime+hPrime);
			xPrime += xPrime;
			g += c[k] * h;
		}
		g += x*a;
		if(gprev < g && g <= mPrime) deltaX *= (g-mPrime)/(gprev-g);
		else                         deltaX  = 0;
		x += deltaX;
		gprev = g;
	}
	return x*m;
}
template<typename HllType>
std::array<double, 3> HyperLogLog::ertl_joint(const HllType &h1, const HllType &h2) const {
	assert(h1.m() == h2.m() || !std::fprintf(stderr, "sizes don't match! Size1: %zu. Size2: %zu\n", h1.size(), h2.size()));
	std::array<double, 3> ret;
	if(h1.get_jestim() != JointEstimationMethod::ERTL_JOINT_MLE) {
		// intersection & union
		ret[2] = h1.union_size(h2);
		ret[0] = h1.creport();
		ret[1] = h2.creport();
		ret[2] = ret[0] + ret[1] - ret[2];
		ret[0] -= ret[2];
		ret[1] -= ret[2];
		ret[2] = std::max(ret[2], 0.);
		return ret;
	}
	//    using ertl_ml_estimate;
	auto p = h1.p();
	auto q = h1.q();
	std::array<uint32_t, 64> c1{0}, c2{0}, cu{0}, ceq{0}, cg1{0}, cg2{0};
	//TODO: K->C5
	//joint_unroller ju;
	//ju.sum_arrays(h1.core(), h2.core(), c1, c2, cu, cg1, cg2, ceq);
	compTwoSketch(h1.core(), h2.core(), c1, c2, cu, cg1, cg2, ceq);
	const double cAX = h1.get_is_ready() ? h1.creport() : ertl_ml_estimate(c1, h1.p(), h1.q(), 1e-2);
	const double cBX = h2.get_is_ready() ? h2.creport() : ertl_ml_estimate(c2, h2.p(), h2.q(), 1e-2);
	const double cABX = ertl_ml_estimate(cu, h1.p(), h1.q(), 1e-2);
	// std::fprintf(stderr, "Made initials: %lf, %lf, %lf\n", cAX, cBX, cABX);
	std::array<uint32_t, 64> countsAXBhalf;
	std::array<uint32_t, 64> countsBXAhalf;
	countsAXBhalf[q] = h1.m();
	countsBXAhalf[q] = h1.m();
	for(unsigned _q = 0; _q < q; ++_q) {
		// Handle AXBhalf
		countsAXBhalf[_q] = cg1[_q] + ceq[_q] + cg2[_q + 1];
		assert(countsAXBhalf[q] >= countsAXBhalf[_q]);
		countsAXBhalf[q] -= countsAXBhalf[_q];

		// Handle BXAhalf
		countsBXAhalf[_q] = cg2[_q] + ceq[_q] + cg1[_q + 1];
		assert(countsBXAhalf[q] >= countsBXAhalf[_q]);
		countsBXAhalf[q] -= countsBXAhalf[_q];
	}
	double cAXBhalf = ertl_ml_estimate(countsAXBhalf, p, q - 1, 1e-2);
	double cBXAhalf = ertl_ml_estimate(countsBXAhalf, p, q - 1, 1e-2);
	//std::fprintf(stderr, "Made halves: %lf, %lf\n", cAXBhalf, cBXAhalf);
	ret[0] = cABX - cBX;
	ret[1] = cABX - cAX;
	double cX1 = (1.5 * cBX + 1.5*cAX - cBXAhalf - cAXBhalf);
	double cX2 = 2.*(cBXAhalf + cAXBhalf) - 3.*cABX;
	ret[2] = std::max(0., 0.5 * (cX1 + cX2));
	return ret;
}




//template<typename CountArrType>
double HyperLogLog::calculate_estimate(const std::array<uint32_t,64> &counts,
		EstimationMethod estim, uint64_t m, uint32_t p, double alpha, double relerr) const {
	assert(estim <= 3);

#if DEBUG
	fprintf(stdout,"[W:%s:%d] Counts: ",__PRETTY_FUNCTION__, __LINE__);
	fprintf(stdout,"Counts: ");
	for(int i=0; i<64; i++)
		fprintf(stdout,"%d, ", counts[i]);
	fprintf(stdout,"\n");
#endif

#if ENABLE_COMPUTED_GOTO
	static constexpr void *arr [] {&&ORREST, &&ERTL_IMPROVED_EST, &&ERTL_MLE_EST};
	goto *arr[estim];
ORREST: {
#else
			switch(estim) {
				case ORIGINAL: {
#endif
								   assert(estim != ERTL_MLE);
								   double sum = counts[0];
								   for(unsigned i = 1; i < 64; ++i) if(counts[i]) sum += std::ldexp(counts[i], -i); // 64 - p because we can't have more than that many leading 0s. This is just a speed thing.
								   //for(unsigned i = 1; i < 64 - p + 1; ++i) sum += std::ldexp(counts[i], -i); // 64 - p because we can't have more than that many leading 0s. This is just a speed thing.
								   double value(alpha * m * m / sum);
								   if(value < small_range_correction_threshold(m)) {
									   if(counts[0]) {
#if DEBUG
										   std::fprintf(stderr, "[W:%s:%d] Small value correction. Original estimate %lf. New estimate %lf.\n",
												   __PRETTY_FUNCTION__, __LINE__, value, m * std::log(static_cast<double>(m) / counts[0]));
#endif
										   value = m * std::log(static_cast<double>(m) / counts[0]);
									   }
								   } else if(value > LARGE_RANGE_CORRECTION_THRESHOLD) {
									   // Reuse sum variable to hold correction.
									   // I do think I've seen worse accuracy with the large range correction, but I would need to rerun experiments to be sure.
									   sum = -std::pow(2.0L, 32) * std::log1p(-std::ldexp(value, -32));
									   if(!std::isnan(sum)) value = sum;
#if DEBUG
									   else std::fprintf(stderr, "[W:%s:%d] Large range correction returned nan. Defaulting to regular calculation.\n", __PRETTY_FUNCTION__, __LINE__);
#endif
								   }
								   return value;
							   }
#if ENABLE_COMPUTED_GOTO
ERTL_IMPROVED_EST: {
#else
					   case ERTL_IMPROVED: {
#endif
											   static const double divinv = 1. / (2.L*std::log(2.L));
											   double z = m * gen_tau(static_cast<double>((m-counts[64 - p + 1]))/static_cast<double>(m));
											   for(unsigned i = 64-p; i; z += counts[i--], z *= 0.5); // Reuse value variable to avoid an additional allocation.
											   z += m * gen_sigma(static_cast<double>(counts[0])/static_cast<double>(m));
											   return m * divinv * m / z;
										   }
#if ENABLE_COMPUTED_GOTO
ERTL_MLE_EST: return ertl_ml_estimate(counts, p, 64 - p, relerr);
#else
					   case ERTL_MLE: return ertl_ml_estimate(counts, p, 64 - p, relerr);
					   default: return 0.0;
				   }
#endif
			}




