#include "shuffle.h"
#include <cstdio>
#include <err.h>




dim_shuffle_t* read_shuffle_dim(string shuffle_file){
	FILE * shuf_in = fopen(shuffle_file.c_str(), "rb");
	if(shuf_in == NULL){
		err(errno, "ERROR: read_shuffle_dim(), cannot read shuffle file: %s\n", shuffle_file.c_str());
	}
	dim_shuffle_t * dim_shuffle = (dim_shuffle_t *)malloc(sizeof(dim_shuffle_t));
	int read_dim_shuffle = fread(&(dim_shuffle->dim_shuffle_stat), sizeof(dim_shuffle_stat_t), 1, shuf_in);
	int dim_size = 1 << 4* dim_shuffle->dim_shuffle_stat.subk;
	dim_shuffle->shuffled_dim= (int*) malloc(sizeof(int) * dim_size);
	int read_shuffled_dim = fread(dim_shuffle->shuffled_dim, sizeof(int), dim_size, shuf_in);
	if(read_dim_shuffle != 1 || read_shuffled_dim != dim_size){
		cerr << "ERROR: read_shufffle_dim(), error read dim_shuffle, shuffled_dim" << endl;
		exit(1);
	}
	return dim_shuffle;
}

int write_shuffle_dim_file(dim_shuffle_stat_t* stat, string shuffle_file){
	if(stat->k < stat->subk){
		fprintf(stderr, "ERROR: write_shuffle_dim_file(), half_k %d should be larger than sub_k %d\n", stat->k, stat->subk);
		exit(1);
	}
	if(stat->subk >= 8){
		fprintf(stderr, "ERROR: write_shuffle_dim_file(), subk %d should be smaller than 8\n", stat->subk);
		exit(1);
	}
	//int bit_after_reduction = stat->k - stat->drlevel;
	//if(bit_after_reduction > 8){
	//	fprintf(stderr, "Error: write_shuffle_dim_file(), too large half_k(%d) and too small drlevel(%d), use little -k(%d) or large -l(%d)\n", stat->k, stat->drlevel, stat->k-1, stat->drlevel+1);
	//	exit(1);
	//}
	int dim_after_reduction = 1 << (4 * (stat->subk - stat->drlevel));
	if(dim_after_reduction < MIN_SUBCTX_DIM_SMP_SZ){
		fprintf(stderr, "Warning: write_shuffle_dim_file(), dimension after reduction %d is smaller than the suggested minimal, which might cause loss of robustness, -s %d is suggested", dim_after_reduction, stat->drlevel+3);
	}

	FILE* fp_out = fopen(shuffle_file.c_str(), "wb+");
	if(!fp_out){
		fprintf(stderr, "ERROR: write_shuffle_dim_file(), error open shuffle file %s\n", shuffle_file.c_str());
		exit(1);
	}

	stat->id = (stat->k << 8) + (stat->subk << 4) + stat->drlevel;
	//cerr << "the stat->id is: " << stat->id << endl;
	//stat->id = 348842630;
	int* shuffled_dim = shuffleN(1 << 4*stat->subk, 0);
	shuffled_dim = shuffle(shuffled_dim, 1 << 4*stat->subk, stat->id);
	int ret = fwrite(stat, sizeof(dim_shuffle_stat_t), 1, fp_out);
	ret += fwrite(shuffled_dim, sizeof(int), 1 << 4*stat->subk, fp_out);
	fclose(fp_out);
	free(shuffled_dim);

	return ret;
}

int * generate_shuffle_dim(int half_subk){
	int dim_size = 1 << 4 * half_subk;
	int * shuffled_dim = shuffleN(dim_size, 0);
	shuffled_dim = shuffle(shuffled_dim, dim_size, 348842630);

	//printf("print the shuffle_dim : \n");
	//for(int i = 0; i < dim_size; i++)
	//	printf("%lx\n", shuffled_dim[i]);
	//exit(0);

	return shuffled_dim;
}

int * shuffleN(int n, int base)
{
	int * arr;
	arr = (int* ) malloc(n * sizeof(int));
	for(int i = 0; i < n; i++){
		arr[i] = i + base;
	}
	
	return shuffle(arr, n, 23);
}

int * shuffle(int arr[], int length, uint64_t seed)
{
	if(length > RAND_MAX){
		err(errno, "shuffling array length %d must be less than RAND_MAX: %d", length, RAND_MAX);
	}
	//srand(time(NULL));
	srand(seed);
	int j, tmp;
	for(int i = length-1; i > 0; i--)
	{
		j = rand() % (i + 1);
		tmp = arr[i];
		arr[i] = arr[j];
		arr[j] = tmp;
	}
	
	return arr;
}







