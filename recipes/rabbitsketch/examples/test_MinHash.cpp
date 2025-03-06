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
	if(argc < 4){
		cerr << "run as: " << argv[0] << " bac.txt threshold threads" << endl;
		return 1;
	}
	Sketch::sketchInfo_t info;
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
	//vector<string> fileArr;

	while (std::getline(fs, fileName)) {
		struct stat cur_stat;
		if (stat(fileName.c_str(), &cur_stat) != 0) {
			std::cerr << "err" << fileName << std::endl;
			continue;
		}
		uint64_t curSize = cur_stat.st_size;
		totalSize += curSize;
		fileInfo_t tmpF;
		tmpF.fileName = fileName;
		fileList.push_back(tmpF);
	}
	fs.close();
	int small_file_number = fileList.size();
	int process_bar_size = get_progress_bar_size(small_file_number); 

	double t1 = get_sec();
	
  //method1
  vector<Sketch::MinHash*> vmh;
  //method2
  //vector<Sketch::MashLite> vmh;
	cerr << "=====total small files: " << small_file_number << endl;
	vector<string> resFileName;

#pragma omp parallel for num_threads(numThreads) schedule(dynamic)
	for(size_t t = 0; t < small_file_number; t++)
	{
		std::vector<uint64_t> hashList64;
    gzFile fp1;
		kseq_t * ks1;
		fp1 = gzopen(fileList[t].fileName.c_str(), "r");
		if(fp1 == NULL){
			err(errno, "cannot open the genome file: %s\n", fileList[t].fileName.c_str());
		}
		ks1 = kseq_init(fp1);

		Sketch::MinHash * mh1 = new Sketch::MinHash();
		mh1->fileName = fileList[t].fileName;
		//		mh1->id = t;
		while(1){
			int length = kseq_read(ks1);
			if(length < 0){
				break;
			}
			mh1->update(ks1->seq.s);	
		}//end while, read the file

#pragma omp critical
		{ 
      //method1
      vmh.push_back(mh1);
			resFileName.push_back(fileList[t].fileName);
			//method2
      //hashList64 = mh1->storeMinHashes();
      //Sketch::MashLite lite = mh1->toLite(hashList64);
      //vmh.push_back(lite);
		}
    delete mh1;
		gzclose(fp1);
		kseq_destroy(ks1);
	}

	double t2 = get_sec();
	cerr << "sketch time is: " << t2 - t1 << endl;
	//Method 1
	// Mash distance calculation with block-based method	
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
		
			cerr << "vmh size is: " << vmh.size() << endl;
		
			#pragma omp parallel for num_threads(numThreads) schedule(dynamic)
			for(int i = 0; i < vmh.size(); i++){
				int tid = omp_get_thread_num();
				for(int j = i+1; j < vmh.size(); j++){
					double dist = vmh[i]->distance(vmh[j]);
					if(dist < thres){
						fprintf(fp_arr[tid], "%s\t%s\t%f\n", resFileName[i].c_str(), resFileName[j].c_str(), dist);
					}
				}
			}
			for(int i = 0; i < numThreads; i++){
				fclose(fp_arr[i]);
			}
		
			double t3 = get_sec();
			cerr << "dist time is: " << t3 - t2 << endl;

	//Method 2
	//index dictionary for large scale genome similarity analysis



	//std::string outputFile = "100.sketch";
	//info.genomeNumber = vmh.size();
	//std::cout << "sketch num: " << vmh.size() << std::endl;

	//Sketch::saveMinHashes(vmh, info, "100.sketch"); 
	//std::cerr << "save sketches to : 100.sketch" << std::endl;

	//double tstart = get_sec();
	//std::string dictFile = outputFile + ".dict";
	//std::string indexFile = outputFile + ".index";
	//transMinHashes(vmh, info, dictFile, indexFile,numThreads); 
	//double tend = get_sec();
	//std::cerr << "=============== transSketches time: " << tend - tstart << " s" << std::endl;

	//Sketch::index_tridist_MinHash(vmh, info, "100.sketch", "100.sketch.dist", 21, thres, 0, numThreads);


	//double t3 = get_sec();
	//cerr << "dist time is: " << t3 - tend << endl;
	return 0;
}



