#ifndef _COMMON_H_
#define _COMMON_H_
#include <iostream> 
#include <cstdint>
#include <sys/time.h>
#include <unistd.h>
//typedef struct kssd_parameter
//{
//	int half_k;
//	int half_subk;
//	int drlevel;
//	int rev_add_move;
//	int half_outctx_len;
//	int * shuffled_dim;
//	int dim_start;
//	int dim_end;
//	unsigned int kmer_size;
//	int hashSize;
//	int hashLimit;
//	uint64_t domask;
//	uint64_t tupmask;
//	uint64_t undomask0;
//	uint64_t undomask1;
//} kssd_parameter_t;
//
//static const int BaseMap[128] = 
//{
//-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
//-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
//-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
//-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
//-1, 0, -1, 1, -1, -1, -1, 2, -1, -1, -1, -1, -1, -1, -1, -1, 
//-1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
//-1, 0, -1, 1, -1, -1, -1, 2, -1, -1, -1, -1, -1, -1, -1, -1, 
//-1, -1, -1, -1, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
//};
//
static const uint32_t primer[25] = 
{
	251, 509, 1021, 2039, 4093, 8191, 16381,
	32749, 65521, 131071, 262139, 524287,
	1048573, 2097143, 4194301, 8388593, 16777213,
	33554393, 67108859, 134217689, 268435399,
	536870909, 1073741789, 2147483647, 4294967291
};


double get_sec();
unsigned int get_hashSize(int half_k, int drlevel);
//kssd_parameter_t initParameter(int half_k, int half_subk, int drlevel, int * shuffled_dim);
uint64_t get_total_system_memory();
int get_progress_bar_size(int total_num);

#endif
