#include "Sketch.h"
//#include <iostream>
#include <sys/time.h>
#include <zlib.h>
#include "kseq.h"
#include <vector>
#include <math.h>
#include <random>
//#include <sstream>
#include <fstream>
#include <err.h>
#include <sys/stat.h>
#include <omp.h>
#include <sstream>
#include "common.h"
using namespace std;

typedef struct fileInfo
{
  string fileName;
} fileInfo_t;

KSEQ_INIT(gzFile, gzread)

//  double get_sec(){
//    struct timeval tv;
//    gettimeofday(&tv, NULL);
//    return tv.tv_sec + (double)tv.tv_usec/1000000;
//  }


int main(int argc, char* argv[])
{
	if(argc < 3){
		cerr << "run as: " << argv[0] << " bac.txt" << endl;
		return 1;
	}
  string inputFile = argv[1];
  double thres = stod(argv[2]);
  int numThreads = stoi(argv[3]);
  ifstream fs(inputFile);
  if(!fs){
    err(errno, "cannot open the inputFile: %s\n", inputFile.c_str());
  }
  vector<fileInfo_t> fileList;
  uint64_t totalSize = 0;
  string fileName;
  while(getline(fs, fileName)){
    struct stat cur_stat;
    stat(fileName.c_str(), &cur_stat);
    fileInfo_t tmpF;
    tmpF.fileName = fileName;
    fileList.push_back(tmpF);
  }
  double t1 = get_sec();
  vector<string> fileArr;
  for(size_t i = 0; i < fileList.size(); i++){
    fileArr.push_back(fileList[i].fileName);
  }
  int small_file_number = fileArr.size();
  vector<Sketch::OrderMinHash > vomh;
  cerr << "=====total small files: " << small_file_number << endl;
	vector<string> resFileName;
	#pragma omp parallel for num_threads(numThreads) schedule(dynamic)
  for(size_t t = 0; t <small_file_number; t++)
  {
		gzFile fp1;
    kseq_t * ks1;
    fp1 = gzopen(fileArr[t].c_str(), "r");
    if(fp1 == NULL){
      err(errno, "cannot open the genome file: %s\n", fileArr[t].c_str());
    }
    ks1 = kseq_init(fp1);
		Sketch::OrderMinHash omh1;
		while(1){
      int length = kseq_read(ks1);
      if(length < 0){
        break;
 			}
			omh1.buildSketch(ks1->seq.s);
			break;
    }//end while, read the file
		#pragma omp critical
      {
				vomh.push_back(omh1);
				resFileName.push_back(fileArr[t]);
      }
    gzclose(fp1);
    kseq_destroy(ks1);
  }
	double t2 = get_sec();
	cerr << "sketch time is: " << t2 - t1 << endl;

	string cmd = "mkdir -p res_dir";
	int ret = system(cmd.c_str());
	if(ret == 0){
		cerr << "write the result int the directory: res_dir" << endl;
	}
	else{
		cerr << "ERROR: cannot create the directory: res_dir" << endl;
		return 1;
	}
	string prefixName = "res_dir/res.dist.";

	vector<FILE*> fp_arr;
	for(int i = 0; i < numThreads; i++){
		string file_name = "res_dir/res.dist." + to_string(i);
		FILE* fp = fopen(file_name.c_str(), "w+");
		fp_arr.push_back(fp);
	}

	cerr << "vomh size is: " << vomh.size() << endl;

	#pragma omp parallel for num_threads(numThreads) schedule(dynamic)
	for(int i = 0; i < vomh.size(); i++){
		int tid = omp_get_thread_num();
		for(int j = i+1; j < vomh.size(); j++){
			double dist = vomh[i].distance(vomh[j]);
			if(dist < thres){
				fprintf(fp_arr[tid], "%s\t%s\t%ld\n", resFileName[i].c_str(), resFileName[j].c_str(), dist);
			}
		}
	}
	for(int i = 0; i < numThreads; i++){
		fclose(fp_arr[i]);
	}


	double t3 = get_sec();
	cerr << "dist time is: " << t3 - t2 << endl;

}




















