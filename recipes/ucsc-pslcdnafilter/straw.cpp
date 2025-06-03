/*
  The MIT License (MIT)

  Copyright (c) 2017-2021 Aiden Lab, Rice University, Baylor College of Medicine

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/
#include <cstring>
#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <cmath>
#include <set>
#include <utility>
#include <vector>
#include <streambuf>
//#include <curl/curl.h>
#include <iterator>
#include <algorithm>
#include "zlib.h"
#include "straw.h"
extern "C" {
#include "../../inc/fakeCurl.h"
#include <cstdint>
}

using namespace std;


// Added UCSC: Dirty hack, but it's hard to quickly extract a list of available normalization options.
// This gets populated by readFooter and readFooterURL, so you have to make a quick dummy data request
// with straw() to set it up (e.g. to the first listed chromosome for a 1 bp window).
set<string> globalNormOptions;

/*
  Straw: fast C++ implementation of dump. Not as fully featured as the
  Java version. Reads the .hic file, finds the appropriate matrix and slice
  of data, and outputs as text in sparse upper triangular format.

  Currently only supporting matrices.

  Usage: straw [observed/oe/expected] <NONE/VC/VC_SQRT/KR> <hicFile(s)> <chr1>[:x1:x2] <chr2>[:y1:y2] <BP/FRAG> <binsize>
 */

// callback for libcurl. data written to this buffer
static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t realsize = size * nmemb;
    struct MemoryStruct *mem;
    mem = (struct MemoryStruct *) userp;

    mem->memory = static_cast<char *>(realloc(mem->memory, mem->size + realsize + 1));
    if (mem->memory == nullptr) {
        /* out of memory! */
        printf("not enough memory (realloc returned NULL)\n");
        return 0;
    }

    std::memcpy(&(mem->memory[mem->size]), contents, realsize);
    mem->size += realsize;
    mem->memory[mem->size] = 0;

    return realsize;
}

// get a buffer that can be used as an input stream from the URL
char *getData(CURL *curl, int64_t position, int64_t chunksize) {
    std::ostringstream oss;
    struct MemoryStruct chunk{};
    chunk.memory = static_cast<char *>(malloc(1));
    chunk.size = 0;    /* no data at this point */
    oss << position << "-" << position + chunksize;
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *) &chunk);
    curl_easy_setopt(curl, CURLOPT_RANGE, oss.str().c_str());
    // Setting FAILONERROR because otherwise this library has a bad habit of assuming data exists
    // and parsing what it gets back, regardless of whether it has run off the end of the file.
    curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1);
    CURLcode res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        throw strawException("curl_easy_perform() failed: " + string(curl_easy_strerror(res)));
        //fprintf(stderr, "curl_easy_perform() failed: %s\n",
        //        curl_easy_strerror(res));
    }

    return chunk.memory;
}

bool readMagicString(istream &fin) {
    string str;
    getline(fin, str, '\0');
    return str[0] == 'H' && str[1] == 'I' && str[2] == 'C';
}

char readCharFromFile(istream &fin) {
    char tempChar;
    fin.read(&tempChar, sizeof(char));
    return tempChar;
}

int16_t readInt16FromFile(istream &fin) {
    int16_t tempInt16;
    fin.read((char *) &tempInt16, sizeof(int16_t));
    return tempInt16;
}

int32_t readInt32FromFile(istream &fin) {
    int32_t tempInt32;
    fin.read((char *) &tempInt32, sizeof(int32_t));
    return tempInt32;
}

int64_t readInt64FromFile(istream &fin) {
    int64_t tempInt64;
    fin.read((char *) &tempInt64, sizeof(int64_t));
    return tempInt64;
}

float readFloatFromFile(istream &fin) {
    float tempFloat;
    fin.read((char *) &tempFloat, sizeof(float));
    return tempFloat;
}

double readDoubleFromFile(istream &fin) {
    double tempDouble;
    fin.read((char *) &tempDouble, sizeof(double));
    return tempDouble;
}

void convertGenomeToBinPos(const int64_t origRegionIndices[4], int64_t regionIndices[4], int32_t resolution) {
    for (uint16_t q = 0; q < 4; q++) {
        // used to find the blocks we need to access
        regionIndices[q] = origRegionIndices[q] / resolution;
    }
}

static CURL *initCURL(const char *url) {
    CURL *curl = curl_easy_init();
    if (curl) {
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl, CURLOPT_USERAGENT, "straw");
        curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1);
    } else {
        throw strawException("Unable to initialize curl");
        //cerr << "Unable to initialize curl " << endl;
        //exit(2);
    }
    return curl;
}

class HiCFileStream {
public:
    string prefix = "http"; // HTTP code
    ifstream fin;
    CURL *curl;
    bool isHttp = false;

    explicit HiCFileStream(const string &fileName) {
        if (std::strncmp(fileName.c_str(), prefix.c_str(), prefix.size()) == 0) {
            isHttp = true;
            curl = initCURL(fileName.c_str());
            if (!curl) {
                throw strawException("URL " + fileName + " cannot be opened for reading");
                //cerr << "URL " << fileName << " cannot be opened for reading" << endl;
                //exit(3);
            }
        } else {
            fin.open(fileName, fstream::in | fstream::binary);
            if (!fin) {
                throw strawException("File " + fileName + " cannot be opened for reading");
                //cerr << "File " << fileName << " cannot be opened for reading" << endl;
                //exit(4);
            }
        }
    }

    void close() {
        if (isHttp) {
            curl_easy_cleanup(curl);
        } else {
            fin.close();
        }
    }

    char *readCompressedBytes(indexEntry idx) {
        if (isHttp) {
            return getData(curl, idx.position, idx.size);
        } else {
            char *buffer = new char[idx.size];
            fin.seekg(idx.position, ios::beg);
            fin.read(buffer, idx.size);
            return buffer;
        }
    }
};

char *readCompressedBytesFromFile(const string &fileName, indexEntry idx) {
    HiCFileStream *stream = new HiCFileStream(fileName);
    char *compressedBytes = stream->readCompressedBytes(idx);
    stream->close();
    delete stream;
    return compressedBytes;
}

// reads the header, storing the positions of the normalization vectors and returning the masterIndexPosition pointer
map<string, chromosome> readHeader(istream &fin, int64_t &masterIndexPosition, string &genomeID,
                                   int32_t &numChromosomes, int32_t &version, int64_t &nviPosition,
                                   int64_t &nviLength, vector<string> &attributes) {
    map<string, chromosome> chromosomeMap;
    if (!readMagicString(fin)) {
        throw strawException("Hi-C magic string is missing, does not appear to be a hic file");
        // Not sure why this function was trying to continue after this failure (the next step is
        // reading resolutions from the file, which clearly isn't going to work).
        //cerr << "Hi-C magic string is missing, does not appear to be a hic file" << endl;
        masterIndexPosition = -1;
        return chromosomeMap;
    }

    version = readInt32FromFile(fin);
    if (version < 6) {
        throw strawException("Version " + to_string(version) + " no longer supported");
        // Not sure why this function was trying to continue after this failure (the next step is
        // reading resolutions from the file, which clearly isn't going to work).
        //cerr << "Version " << version << " no longer supported" << endl;
        masterIndexPosition = -1;
        return chromosomeMap;
    }
    masterIndexPosition = readInt64FromFile(fin);
    getline(fin, genomeID, '\0');

    if (version > 8) {
        nviPosition = readInt64FromFile(fin);
        nviLength = readInt64FromFile(fin);
    }

    int32_t nattributes = readInt32FromFile(fin);

    // reading attribute-value dictionary
    for (int i = 0; i < nattributes; i++) {
        string key, value;
        getline(fin, key, '\0');
        getline(fin, value, '\0');
        attributes.insert(attributes.end(), key);
        attributes.insert(attributes.end(), value);
    }

    numChromosomes = readInt32FromFile(fin);
    // chromosome map for finding matrixType
    for (int i = 0; i < numChromosomes; i++) {
        string name;
        int64_t length;
        getline(fin, name, '\0');
        if (version > 8) {
            length = readInt64FromFile(fin);
        } else {
            length = (int64_t) readInt32FromFile(fin);
        }

        chromosome chr;
        chr.index = i;
        chr.name = name;
        chr.length = length;
        chromosomeMap[name] = chr;
    }
    return chromosomeMap;
}

vector<int32_t> readResolutionsFromHeader(istream &fin) {
    int numBpResolutions = readInt32FromFile(fin);
    vector<int32_t> resolutions;
    for (int i = 0; i < numBpResolutions; i++) {
        int32_t res = readInt32FromFile(fin);
        resolutions.push_back(res);
    }
    return resolutions;
}

//https://www.techiedelight.com/get-slice-sub-vector-from-vector-cpp/
vector<double> sliceVector(vector<double> &v, int64_t m, int64_t n) {
    vector<double> vec;
    copy(v.begin() + m, v.begin() + n + 1, back_inserter(vec));
    return vec;
}

// assume always an odd number for length of vector;
// eve if even, this calculation should be close enough
double getMedian(vector<double> &v) {
    size_t n = v.size() / 2;
    nth_element(v.begin(), v.begin() + n, v.end());
    return v[n];
}

void rollingMedian(vector<double> &initialValues, vector<double> &finalResult, int32_t window) {
    // window is actually a ~wing-span
    if (window < 1) {
        finalResult = initialValues;
        return;
    }

    /*
    finalResult.push_back(initialValues[0]);
    int64_t length = initialValues.size();
    for (int64_t index = 1; index < length; index++) {
        int64_t initialIndex;
        int64_t finalIndex;
        if (index < window) {
            initialIndex = 0;
            finalIndex = 2 * index;
        } else {
            initialIndex = index - window;
            finalIndex = index + window;
        }

        if (finalIndex > length - 1) {
            finalIndex = length - 1;
        }

        vector<double> subVector = sliceVector(initialValues, initialIndex, finalIndex);
        finalResult.push_back(getMedian(subVector));
    }
    */
    finalResult = initialValues;
}

void populateVectorWithFloats(istream &fin, vector<double> &vector, int64_t nValues) {
    for (int j = 0; j < nValues; j++) {
        double v = readFloatFromFile(fin);
        vector.push_back(v);
    }
}

void populateVectorWithDoubles(istream &fin, vector<double> &vector, int64_t nValues) {
    for (int j = 0; j < nValues; j++) {
        double v = readDoubleFromFile(fin);
        vector.push_back(v);
    }
}

int64_t readThroughExpectedVectorURL(CURL *curl, int64_t currentPointer, int32_t version, vector<double> &expectedValues, int64_t nValues,
                               bool store, int32_t resolution) {
    if (store) {
        int32_t bufferSize = nValues * sizeof(double) + 10000;
        if (version > 8) {
            bufferSize = nValues * sizeof(float) + 10000;
        }
        char *buffer = getData(curl, currentPointer, bufferSize);
        memstream fin(buffer, bufferSize);

        vector<double> initialExpectedValues;
        if (version > 8) {
            populateVectorWithFloats(fin, initialExpectedValues, nValues);
        } else {
            populateVectorWithDoubles(fin, initialExpectedValues, nValues);
        }
        int32_t window = 5000000 / resolution;
        rollingMedian(initialExpectedValues, expectedValues, window);
        delete buffer;
    }

    if (version > 8) {
        return nValues * sizeof(float);
    } else {
        return nValues * sizeof(double);
    }
}

void readThroughExpectedVector(int32_t version, istream &fin, vector<double> &expectedValues, int64_t nValues,
                               bool store, int32_t resolution) {
    if (store) {
        vector<double> initialExpectedValues;
        if (version > 8) {
            populateVectorWithFloats(fin, initialExpectedValues, nValues);
        } else {
            populateVectorWithDoubles(fin, initialExpectedValues, nValues);
        }
        int32_t window = 5000000 / resolution;
        rollingMedian(initialExpectedValues, expectedValues, window);
    } else if (nValues > 0) {
        if (version > 8) {
            fin.seekg(nValues * sizeof(float), ios_base::cur);
        } else {
            fin.seekg(nValues * sizeof(double), ios_base::cur);
        }
    }
}

int64_t readThroughNormalizationFactorsURL(CURL *curl, int64_t currentPointer, int32_t version, bool store, vector<double> &expectedValues,
                                     int32_t c1, int32_t nNormalizationFactors) {

    if (store) {
        int32_t bufferSize = nNormalizationFactors * (sizeof(int32_t) + sizeof(double)) + 10000;
        if (version > 8) {
            bufferSize = nNormalizationFactors * (sizeof(int32_t) + sizeof(float )) + 10000;
        }
        char *buffer = getData(curl, currentPointer, bufferSize);
        memstream fin(buffer, bufferSize);

        for (int j = 0; j < nNormalizationFactors; j++) {
            int32_t chrIdx = readInt32FromFile(fin);
            double v;
            if (version > 8) {
                v = readFloatFromFile(fin);
            } else {
                v = readDoubleFromFile(fin);
            }
            if (chrIdx == c1) {
                for (double &expectedValue : expectedValues) {
                    expectedValue = expectedValue / v;
                }
            }
        }
        delete buffer;
    }

    if (version > 8) {
        return nNormalizationFactors * (sizeof(int32_t) + sizeof(float));
    } else {
        return nNormalizationFactors * (sizeof(int32_t) + sizeof(double));
    }
}

void readThroughNormalizationFactors(istream &fin, int32_t version, bool store, vector<double> &expectedValues,
                                     int32_t c1) {
    int32_t nNormalizationFactors = readInt32FromFile(fin);
    if (store) {
        for (int j = 0; j < nNormalizationFactors; j++) {
            int32_t chrIdx = readInt32FromFile(fin);
            double v;
            if (version > 8) {
                v = readFloatFromFile(fin);
            } else {
                v = readDoubleFromFile(fin);
            }
            if (chrIdx == c1) {
                for (double &expectedValue : expectedValues) {
                    expectedValue = expectedValue / v;
                }
            }
        }
    } else if (nNormalizationFactors > 0) {
        if (version > 8) {
            fin.seekg(nNormalizationFactors * (sizeof(int32_t) + sizeof(float)), ios_base::cur);
        } else {
            fin.seekg(nNormalizationFactors * (sizeof(int32_t) + sizeof(double)), ios_base::cur);
        }
    }
}

int64_t readStringFromURL(istream &fin, string &basicString) {
    getline(fin, basicString, '\0');
    return (basicString.length() + 1);
}

// reads the footer from the master pointer location. takes in the chromosomes,
// norm, unit (BP or FRAG) and resolution or binsize, and sets the file
// position of the matrix and the normalization vectors for those chromosomes
// at the given normalization and resolution
bool readFooterURL(CURL *curl, int64_t master, int32_t version, int32_t c1, int32_t c2, const string &matrixType,
                const string &norm, const string &unit, int32_t resolution, int64_t &myFilePos,
                indexEntry &c1NormEntry, indexEntry &c2NormEntry, vector<double> &expectedValues) {

    int64_t currentPointer = master;

    char *buffer = getData(curl, currentPointer, 100);
    memstream fin1(buffer, 100);

    if (version > 8) {
        int64_t nBytes = readInt64FromFile(fin1);
        currentPointer += 8;
    } else {
        int32_t nBytes = readInt32FromFile(fin1);
        currentPointer += 4;
    }

    stringstream ss;
    ss << c1 << "_" << c2;
    string key = ss.str();

    int32_t nEntries = readInt32FromFile(fin1);
    currentPointer += 4;
    delete buffer;

    int32_t bufferSize0 = nEntries * 50;
    buffer = getData(curl, currentPointer, bufferSize0);
    memstream fin2(buffer, bufferSize0);

    bool found = false;
    for (int i = 0; i < nEntries; i++) {
        string keyStr;
        currentPointer += readStringFromURL(fin2, keyStr);

        int64_t fpos = readInt64FromFile(fin2);
        int32_t sizeinbytes = readInt32FromFile(fin2);
        currentPointer += 12;
        if (keyStr == key) {
            myFilePos = fpos;
            found = true;
        }
    }
    delete buffer;
    if (!found) {
        cerr << "Remote file doesn't have the given chr_chr map " << key << endl;
        return false;
    }

    if ((matrixType == "observed" && norm == "NONE") ||
        ((matrixType == "oe" || matrixType == "expected") && norm == "NONE" && c1 != c2))
        return true; // no need to read norm vector index

    // read in and ignore expected value maps; don't store; reading these to
    // get to norm vector index
    buffer = getData(curl, currentPointer, 100);
    memstream fin3(buffer, 100);

    int32_t nExpectedValues = readInt32FromFile(fin3);
    if (fin3.bad() || fin3.fail())
    {
        throw strawException("Unable to read expected values from file - it might be truncated early");
    }
    currentPointer += 4;
    delete buffer;
    for (int i = 0; i < nExpectedValues; i++) {

        buffer = getData(curl, currentPointer, 1000);
        memstream fin4(buffer, 1000);

        string unit0;
        currentPointer += readStringFromURL(fin4, unit0);

        int32_t binSize = readInt32FromFile(fin4);
        currentPointer += 4;

        int64_t nValues;
        if (version > 8) {
            nValues = readInt64FromFile(fin4);
            currentPointer += 8;
        } else {
            nValues = (int64_t) readInt32FromFile(fin4);
            currentPointer += 4;
        }

        delete buffer;

        bool store = c1 == c2 && (matrixType == "oe" || matrixType == "expected") && norm == "NONE" && unit0 == unit &&
                     binSize == resolution;

        currentPointer += readThroughExpectedVectorURL(curl, currentPointer, version, expectedValues, nValues, store, resolution);

        buffer = getData(curl, currentPointer, 100);
        memstream fin5(buffer, 100);
        int32_t nNormalizationFactors = readInt32FromFile(fin5);
        currentPointer += 4;
        delete buffer;

        currentPointer += readThroughNormalizationFactorsURL(curl, currentPointer, version, store, expectedValues, c1, nNormalizationFactors);
    }

    if (c1 == c2 && (matrixType == "oe" || matrixType == "expected") && norm == "NONE") {
        if (expectedValues.empty()) {
            cerr << "Remote file did not contain expected values vectors at " << resolution << " " << unit << endl;
            return false;
        }
        return true;
    }

    buffer = getData(curl, currentPointer, 100);
    memstream fin6(buffer, 100);
    nExpectedValues = readInt32FromFile(fin6);
    if (fin6.bad() || fin6.fail())
    {
        throw strawException("Unable to read normalized expected values from file - it might be truncated early");
    }
    currentPointer += 4;
    delete buffer;
    for (int i = 0; i < nExpectedValues; i++) {
        buffer = getData(curl, currentPointer, 1000);
        memstream fin7(buffer, 1000);

        string nType, unit0;
        currentPointer += readStringFromURL(fin7, nType);
        currentPointer += readStringFromURL(fin7, unit0);

        int32_t binSize = readInt32FromFile(fin7);
        currentPointer += 4;

        int64_t nValues;
        if (version > 8) {
            nValues = readInt64FromFile(fin7);
            currentPointer += 8;
        } else {
            nValues = (int64_t) readInt32FromFile(fin7);
            currentPointer += 4;
        }
        bool store = c1 == c2 && (matrixType == "oe" || matrixType == "expected") && nType == norm && unit0 == unit &&
                     binSize == resolution;

        delete buffer;

        currentPointer += readThroughExpectedVectorURL(curl, currentPointer, version, expectedValues, nValues, store, resolution);

        buffer = getData(curl, currentPointer, 100);
        memstream fin8(buffer, 100);
        int32_t nNormalizationFactors = readInt32FromFile(fin8);
        currentPointer += 4;
        delete buffer;

        currentPointer += readThroughNormalizationFactorsURL(curl, currentPointer, version, store, expectedValues, c1, nNormalizationFactors);
    }

    if (c1 == c2 && (matrixType == "oe" || matrixType == "expected") && norm != "NONE") {
        if (expectedValues.empty()) {
            cerr << "Remote file did not contain normalized expected values vectors at " << resolution << " " << unit << endl;
            return false;
        }
    }

    buffer = getData(curl, currentPointer, 100);
    memstream fin9(buffer, 100);
    nEntries = readInt32FromFile(fin9);
    if (fin9.bad() || fin9.fail())
    {
        throw strawException("Unable to read normalization vectors from file - it might be truncated early");
    }
    currentPointer += 4;
    delete buffer;

    bool found1 = false;
    bool found2 = false;
    int32_t bufferSize2 = nEntries*60;
    buffer = getData(curl, currentPointer, bufferSize2);
    memstream fin10(buffer, bufferSize2);

    // added UCSC
    globalNormOptions.clear();

    for (int i = 0; i < nEntries; i++) {
        string normtype;
        currentPointer += readStringFromURL(fin10, normtype);

        // added UCSC
        globalNormOptions.insert(normtype);

        int32_t chrIdx = readInt32FromFile(fin10);
        currentPointer += 4;
        string unit1;
        currentPointer += readStringFromURL(fin10, unit1);

        int32_t resolution1 = readInt32FromFile(fin10);
        int64_t filePosition = readInt64FromFile(fin10);
        currentPointer += 12;

        int64_t sizeInBytes;
        if (version > 8) {
            sizeInBytes = readInt64FromFile(fin10);
            currentPointer += 8;
        } else {
            sizeInBytes = (int64_t) readInt32FromFile(fin10);
            currentPointer += 4;
        }

        if (chrIdx == c1 && normtype == norm && unit1 == unit && resolution1 == resolution) {
            c1NormEntry.position = filePosition;
            c1NormEntry.size = sizeInBytes;
            found1 = true;
        }
        if (chrIdx == c2 && normtype == norm && unit1 == unit && resolution1 == resolution) {
            c2NormEntry.position = filePosition;
            c2NormEntry.size = sizeInBytes;
            found2 = true;
        }
    }
    delete buffer;
    if (!found1 || !found2) {
/*
        cerr << "Remote file did not contain " << norm << " normalization vectors for one or both chromosomes at "
             << resolution << " " << unit << endl;
*/
        throw strawException("Remote file did not contain " + norm + " normalization vectors for one or both chromosomes at "
             + to_string(resolution) + " " + unit);
    }
    return true;
}

bool readFooter(istream &fin, int64_t master, int32_t version, int32_t c1, int32_t c2, const string &matrixType,
                const string &norm, const string &unit, int32_t resolution, int64_t &myFilePos,
                indexEntry &c1NormEntry, indexEntry &c2NormEntry, vector<double> &expectedValues) {

    if (version > 8) {
        int64_t nBytes = readInt64FromFile(fin);
    } else {
        int32_t nBytes = readInt32FromFile(fin);
    }

    stringstream ss;
    ss << c1 << "_" << c2;
    string key = ss.str();

    int32_t nEntries = readInt32FromFile(fin);
    bool found = false;
    for (int i = 0; i < nEntries; i++) {
        string keyStr;
        getline(fin, keyStr, '\0');
        int64_t fpos = readInt64FromFile(fin);
        int32_t sizeinbytes = readInt32FromFile(fin);
        if (keyStr == key) {
            myFilePos = fpos;
            found = true;
        }
    }
    if (!found) {
        cerr << "File doesn't have the given chr_chr map " << key << endl;
        return false;
    }

    if ((matrixType == "observed" && norm == "NONE") ||
        ((matrixType == "oe" || matrixType == "expected") && norm == "NONE" && c1 != c2))
        return true; // no need to read norm vector index

    // read in and ignore expected value maps; don't store; reading these to
    // get to norm vector index
    int32_t nExpectedValues = readInt32FromFile(fin);
    if (fin.bad() || fin.fail())
    {
        throw strawException("Unable to read expected values from file - it might be truncated early");
    }
    for (int i = 0; i < nExpectedValues; i++) {
        string unit0;
        getline(fin, unit0, '\0'); //unit
        int32_t binSize = readInt32FromFile(fin);

        int64_t nValues;
        if (version > 8) {
            nValues = readInt64FromFile(fin);
        } else {
            nValues = (int64_t) readInt32FromFile(fin);
        }

        bool store = c1 == c2 && (matrixType == "oe" || matrixType == "expected") && norm == "NONE" && unit0 == unit &&
                     binSize == resolution;
        readThroughExpectedVector(version, fin, expectedValues, nValues, store, resolution);
        readThroughNormalizationFactors(fin, version, store, expectedValues, c1);
    }

    if (c1 == c2 && (matrixType == "oe" || matrixType == "expected") && norm == "NONE") {
        if (expectedValues.empty()) {
            cerr << "File did not contain expected values vectors at " << resolution << " " << unit << endl;
            return false;
        }
        return true;
    }

    nExpectedValues = readInt32FromFile(fin);
    if (fin.bad() || fin.fail())
    {
        throw strawException("Unable to read normalized expected values from file - it might be truncated early");
    }

    for (int i = 0; i < nExpectedValues; i++) {
        string nType, unit0;
        getline(fin, nType, '\0'); //typeString
        getline(fin, unit0, '\0'); //unit
        int32_t binSize = readInt32FromFile(fin);
        int64_t nValues;
        if (version > 8) {
            nValues = readInt64FromFile(fin);
        } else {
            nValues = (int64_t) readInt32FromFile(fin);
        }
        bool store = c1 == c2 && (matrixType == "oe" || matrixType == "expected") && nType == norm && unit0 == unit &&
                     binSize == resolution;
        readThroughExpectedVector(version, fin, expectedValues, nValues, store, resolution);
        readThroughNormalizationFactors(fin, version, store, expectedValues, c1);
    }

    if (c1 == c2 && (matrixType == "oe" || matrixType == "expected") && norm != "NONE") {
        if (expectedValues.empty()) {
            cerr << "File did not contain normalized expected values vectors at " << resolution << " " << unit << endl;
            return false;
        }
    }

    // Index of normalization vectors
    nEntries = readInt32FromFile(fin);
    bool found1 = false;
    bool found2 = false;

    // added UCSC
    globalNormOptions.clear();
    if (fin.bad() || fin.fail())
    {
        throw strawException("Unable to read normalization vectors from file - it might be truncated early");
    }

    for (int i = 0; i < nEntries; i++) {
        string normtype;
        getline(fin, normtype, '\0'); //normalization type
        int32_t chrIdx = readInt32FromFile(fin);
        string unit1;
        getline(fin, unit1, '\0'); //unit
        int32_t resolution1 = readInt32FromFile(fin);
        int64_t filePosition = readInt64FromFile(fin);
        int64_t sizeInBytes;
        if (version > 8) {
            sizeInBytes = readInt64FromFile(fin);
        } else {
            sizeInBytes = (int64_t) readInt32FromFile(fin);
        }

        // added UCSC
        globalNormOptions.insert(normtype);

        if (chrIdx == c1 && normtype == norm && unit1 == unit && resolution1 == resolution) {
            c1NormEntry.position = filePosition;
            c1NormEntry.size = sizeInBytes;
            found1 = true;
        }
        if (chrIdx == c2 && normtype == norm && unit1 == unit && resolution1 == resolution) {
            c2NormEntry.position = filePosition;
            c2NormEntry.size = sizeInBytes;
            found2 = true;
        }
    }
    if (!found1 || !found2) {
/*
        cerr << "File did not contain " << norm << " normalization vectors for one or both chromosomes at "
             << resolution << " " << unit << endl;
*/
        throw strawException("File did not contain " + norm + " normalization vectors for one or both chromosomes at "
             + to_string(resolution) + " " + unit);
    }
    return true;
}

indexEntry readIndexEntry(istream &fin) {
    int64_t filePosition = readInt64FromFile(fin);
    int32_t blockSizeInBytes = readInt32FromFile(fin);
    indexEntry entry = indexEntry();
    entry.size = (int64_t) blockSizeInBytes;
    entry.position = filePosition;
    return entry;
}

void setValuesForMZD(istream &fin, const string &myunit, float &mySumCounts, int32_t &mybinsize,
                     int32_t &myBlockBinCount, int32_t &myBlockColumnCount, bool &found) {
    string unit;
    getline(fin, unit, '\0'); // unit
    readInt32FromFile(fin); // Old "zoom" index -- not used
    float sumCounts = readFloatFromFile(fin); // sumCounts
    readFloatFromFile(fin); // occupiedCellCount
    readFloatFromFile(fin); // stdDev
    readFloatFromFile(fin); // percent95
    int32_t binSize = readInt32FromFile(fin);
    int32_t blockBinCount = readInt32FromFile(fin);
    int32_t blockColumnCount = readInt32FromFile(fin);
    found = false;
    if (myunit == unit && mybinsize == binSize) {
        mySumCounts = sumCounts;
        myBlockBinCount = blockBinCount;
        myBlockColumnCount = blockColumnCount;
        found = true;
    }
}

void populateBlockMap(istream &fin, int32_t nBlocks, map<int32_t, indexEntry> &blockMap) {
    for (int b = 0; b < nBlocks; b++) {
        int32_t blockNumber = readInt32FromFile(fin);
        blockMap[blockNumber] = readIndexEntry(fin);
    }
}

// reads the raw binned contact matrix at specified resolution, setting the block bin count and block column count
map<int32_t, indexEntry> readMatrixZoomData(istream &fin, const string &myunit, int32_t mybinsize, float &mySumCounts,
                                            int32_t &myBlockBinCount, int32_t &myBlockColumnCount, bool &found) {

    map<int32_t, indexEntry> blockMap;
    setValuesForMZD(fin, myunit, mySumCounts, mybinsize, myBlockBinCount, myBlockColumnCount, found);

    int32_t nBlocks = readInt32FromFile(fin);
    if (found) {
        populateBlockMap(fin, nBlocks, blockMap);
    } else {
        fin.seekg(nBlocks * (sizeof(int32_t) + sizeof(int64_t) + sizeof(int32_t)), ios_base::cur);
    }
    return blockMap;
}

// reads the raw binned contact matrix at specified resolution, setting the block bin count and block column count
map<int32_t, indexEntry> readMatrixZoomDataHttp(CURL *curl, int64_t &myFilePosition, const string &myunit,
                                                int32_t mybinsize, float &mySumCounts, int32_t &myBlockBinCount,
                                                int32_t &myBlockColumnCount, bool &found) {
    map<int32_t, indexEntry> blockMap;
    int32_t header_size = 5 * sizeof(int32_t) + 4 * sizeof(float);
    char *first = getData(curl, myFilePosition, 1);
    if (first[0] == 'B') {
        header_size += 3;
    } else if (first[0] == 'F') {
        header_size += 5;
    } else {
        cerr << "Unit not understood" << endl;
        return blockMap;
    }
    delete first;
    char *buffer = getData(curl, myFilePosition, header_size);
    memstream fin(buffer, header_size);
    setValuesForMZD(fin, myunit, mySumCounts, mybinsize, myBlockBinCount, myBlockColumnCount, found);
    int32_t nBlocks = readInt32FromFile(fin);
    delete buffer;

    if (found) {
        int32_t chunkSize = nBlocks * (sizeof(int32_t) + sizeof(int64_t) + sizeof(int32_t));
        buffer = getData(curl, myFilePosition + header_size, chunkSize);
        memstream fin2(buffer, chunkSize);
        populateBlockMap(fin2, nBlocks, blockMap);
        delete buffer;
    } else {
        myFilePosition = myFilePosition + header_size
                         + (nBlocks * (sizeof(int32_t) + sizeof(int64_t) + sizeof(int32_t)));
    }
    return blockMap;
}

// goes to the specified file pointer in http and finds the raw contact matrixType at specified resolution, calling readMatrixZoomData.
// sets blockbincount and blockcolumncount
map<int32_t, indexEntry> readMatrixHttp(CURL *curl, int64_t myFilePosition, const string &unit, int32_t resolution,
                                        float &mySumCounts, int32_t &myBlockBinCount, int32_t &myBlockColumnCount) {
    int32_t size = sizeof(int32_t) * 3;
    char *buffer = getData(curl, myFilePosition, size);
    memstream bufin(buffer, size);

    int32_t c1 = readInt32FromFile(bufin);
    int32_t c2 = readInt32FromFile(bufin);
    int32_t nRes = readInt32FromFile(bufin);
    int32_t i = 0;
    bool found = false;
    myFilePosition = myFilePosition + size;
    delete buffer;
    map<int32_t, indexEntry> blockMap;

    while (i < nRes && !found) {
        // myFilePosition gets updated within call
        blockMap = readMatrixZoomDataHttp(curl, myFilePosition, unit, resolution, mySumCounts, myBlockBinCount,
                                          myBlockColumnCount, found);
        i++;
    }
    if (!found) {
        cerr << "Error finding block data" << endl;
    }
    return blockMap;
}

// goes to the specified file pointer and finds the raw contact matrixType at specified resolution, calling readMatrixZoomData.
// sets blockbincount and blockcolumncount
map<int32_t, indexEntry> readMatrix(istream &fin, int64_t myFilePosition, const string &unit, int32_t resolution,
                                    float &mySumCounts, int32_t &myBlockBinCount, int32_t &myBlockColumnCount) {
    map<int32_t, indexEntry> blockMap;

    fin.seekg(myFilePosition, ios::beg);
    int32_t c1 = readInt32FromFile(fin);
    int32_t c2 = readInt32FromFile(fin);
    int32_t nRes = readInt32FromFile(fin);
    int32_t i = 0;
    bool found = false;
    while (i < nRes && !found) {
        blockMap = readMatrixZoomData(fin, unit, resolution, mySumCounts, myBlockBinCount, myBlockColumnCount, found);
        i++;
    }
    if (!found) {
        cerr << "Error finding block data" << endl;
    }
    return blockMap;
}

// gets the blocks that need to be read for this slice of the data.  needs blockbincount, blockcolumncount, and whether
// or not this is intrachromosomal.
set<int32_t> getBlockNumbersForRegionFromBinPosition(const int64_t *regionIndices, int32_t blockBinCount,
                                                     int32_t blockColumnCount, bool intra) {
    int32_t col1, col2, row1, row2;
    col1 = static_cast<int32_t>(regionIndices[0] / blockBinCount);
    col2 = static_cast<int32_t>((regionIndices[1] + 1) / blockBinCount);
    row1 = static_cast<int32_t>(regionIndices[2] / blockBinCount);
    row2 = static_cast<int32_t>((regionIndices[3] + 1) / blockBinCount);

    set<int32_t> blocksSet;
    // first check the upper triangular matrixType
    for (int r = row1; r <= row2; r++) {
        for (int c = col1; c <= col2; c++) {
            int32_t blockNumber = r * blockColumnCount + c;
            blocksSet.insert(blockNumber);
        }
    }
    // check region part that overlaps with lower left triangle but only if intrachromosomal
    if (intra) {
        for (int r = col1; r <= col2; r++) {
            for (int c = row1; c <= row2; c++) {
                int32_t blockNumber = r * blockColumnCount + c;
                blocksSet.insert(blockNumber);
            }
        }
    }
    return blocksSet;
}

set<int32_t> getBlockNumbersForRegionFromBinPositionV9Intra(int64_t *regionIndices, int32_t blockBinCount,
                                                            int32_t blockColumnCount) {
    // regionIndices is binX1 binX2 binY1 binY2
    set<int32_t> blocksSet;
    int32_t translatedLowerPAD, translatedHigherPAD, translatedNearerDepth, translatedFurtherDepth;
    translatedLowerPAD = static_cast<int32_t>((regionIndices[0] + regionIndices[2]) / 2 / blockBinCount);
    translatedHigherPAD = static_cast<int32_t>((regionIndices[1] + regionIndices[3]) / 2 / blockBinCount + 1);
    translatedNearerDepth = static_cast<int32_t>(log2(
            1 + abs(regionIndices[0] - regionIndices[3]) / sqrt(2) / blockBinCount));
    translatedFurtherDepth = static_cast<int32_t>(log2(
            1 + abs(regionIndices[1] - regionIndices[2]) / sqrt(2) / blockBinCount));

    // because code above assume above diagonal; but we could be below diagonal
    int32_t nearerDepth = min(translatedNearerDepth, translatedFurtherDepth);
    if ((regionIndices[0] > regionIndices[3] && regionIndices[1] < regionIndices[2]) ||
        (regionIndices[1] > regionIndices[2] && regionIndices[0] < regionIndices[3])) {
        nearerDepth = 0;
    }
    int32_t furtherDepth = max(translatedNearerDepth, translatedFurtherDepth) + 1; // +1; integer divide rounds down

    for (int depth = nearerDepth; depth <= furtherDepth; depth++) {
        for (int pad = translatedLowerPAD; pad <= translatedHigherPAD; pad++) {
            int32_t blockNumber = depth * blockColumnCount + pad;
            blocksSet.insert(blockNumber);
        }
    }

    return blocksSet;
}

void appendRecord(vector<contactRecord> &vector, int32_t index, int32_t binX, int32_t binY, float counts) {
    contactRecord record = contactRecord();
    record.binX = binX;
    record.binY = binY;
    record.counts = counts;
    vector[index] = record;
}

int32_t decompressBlock(indexEntry idx, char *compressedBytes, char *uncompressedBytes) {
    z_stream infstream;
    infstream.zalloc = Z_NULL;
    infstream.zfree = Z_NULL;
    infstream.opaque = Z_NULL;
    infstream.avail_in = static_cast<uInt>(idx.size); // size of input
    infstream.next_in = (Bytef *) compressedBytes; // input char array
    infstream.avail_out = static_cast<uInt>(idx.size * 10); // size of output
    infstream.next_out = (Bytef *) uncompressedBytes; // output char array
    // the actual decompression work.
    inflateInit(&infstream);
    inflate(&infstream, Z_NO_FLUSH);
    inflateEnd(&infstream);
    int32_t uncompressedSize = static_cast<int32_t>(infstream.total_out);
    return uncompressedSize;
}

long getNumRecordsInBlock(const string &fileName, indexEntry idx, int32_t version){
    if (idx.size <= 0) {
        return 0;
    }
    char *compressedBytes = readCompressedBytesFromFile(fileName, idx);
    char *uncompressedBytes = new char[idx.size * 10]; //biggest seen so far is 3
    int32_t uncompressedSize = decompressBlock(idx, compressedBytes, uncompressedBytes);

    // create stream from buffer for ease of use
    memstream bufferin(uncompressedBytes, uncompressedSize);
    uint64_t nRecords;
    nRecords = static_cast<uint64_t>(readInt32FromFile(bufferin));
    delete[] compressedBytes;
    delete[] uncompressedBytes; // don't forget to delete your heap arrays in C++!
    return nRecords;
}

// this is the meat of reading the data.  takes in the block number and returns the set of contact records corresponding to
// that block.  the block data is compressed and must be decompressed using the zlib library functions
vector<contactRecord> readBlock(const string &fileName, indexEntry idx, int32_t version) {
    if (idx.size <= 0) {
        vector<contactRecord> v;
        return v;
    }
    char *compressedBytes = readCompressedBytesFromFile(fileName, idx);
    char *uncompressedBytes = new char[idx.size * 10]; //biggest seen so far is 3
    int32_t uncompressedSize = decompressBlock(idx, compressedBytes, uncompressedBytes);

    // create stream from buffer for ease of use
    memstream bufferin(uncompressedBytes, uncompressedSize);
    uint64_t nRecords;
    nRecords = static_cast<uint64_t>(readInt32FromFile(bufferin));
    vector<contactRecord> v(nRecords);
    // different versions have different specific formats
    if (version < 7) {
        for (uInt i = 0; i < nRecords; i++) {
            int32_t binX = readInt32FromFile(bufferin);
            int32_t binY = readInt32FromFile(bufferin);
            float counts = readFloatFromFile(bufferin);
            appendRecord(v, i, binX, binY, counts);
        }
    } else {
        int32_t binXOffset = readInt32FromFile(bufferin);
        int32_t binYOffset = readInt32FromFile(bufferin);
        bool useShort = readCharFromFile(bufferin) == 0; // yes this is opposite of usual

        bool useShortBinX = true;
        bool useShortBinY = true;
        if (version > 8) {
            useShortBinX = readCharFromFile(bufferin) == 0;
            useShortBinY = readCharFromFile(bufferin) == 0;
        }

        char type = readCharFromFile(bufferin);
        int32_t index = 0;
        if (type == 1) {
            if (useShortBinX && useShortBinY) {
                int16_t rowCount = readInt16FromFile(bufferin);
                for (int i = 0; i < rowCount; i++) {
                    int32_t binY = binYOffset + readInt16FromFile(bufferin);
                    int16_t colCount = readInt16FromFile(bufferin);
                    for (int j = 0; j < colCount; j++) {
                        int32_t binX = binXOffset + readInt16FromFile(bufferin);
                        float counts;
                        if (useShort) {
                            counts = readInt16FromFile(bufferin);
                        } else {
                            counts = readFloatFromFile(bufferin);
                        }
                        appendRecord(v, index++, binX, binY, counts);
                    }
                }
            } else if (useShortBinX && !useShortBinY) {
                int32_t rowCount = readInt32FromFile(bufferin);
                for (int i = 0; i < rowCount; i++) {
                    int32_t binY = binYOffset + readInt32FromFile(bufferin);
                    int16_t colCount = readInt16FromFile(bufferin);
                    for (int j = 0; j < colCount; j++) {
                        int32_t binX = binXOffset + readInt16FromFile(bufferin);
                        float counts;
                        if (useShort) {
                            counts = readInt16FromFile(bufferin);
                        } else {
                            counts = readFloatFromFile(bufferin);
                        }
                        appendRecord(v, index++, binX, binY, counts);
                    }
                }
            } else if (!useShortBinX && useShortBinY) {
                int16_t rowCount = readInt16FromFile(bufferin);
                for (int i = 0; i < rowCount; i++) {
                    int32_t binY = binYOffset + readInt16FromFile(bufferin);
                    int32_t colCount = readInt32FromFile(bufferin);
                    for (int j = 0; j < colCount; j++) {
                        int32_t binX = binXOffset + readInt32FromFile(bufferin);
                        float counts;
                        if (useShort) {
                            counts = readInt16FromFile(bufferin);
                        } else {
                            counts = readFloatFromFile(bufferin);
                        }
                        appendRecord(v, index++, binX, binY, counts);
                    }
                }
            } else {
                int32_t rowCount = readInt32FromFile(bufferin);
                for (int i = 0; i < rowCount; i++) {
                    int32_t binY = binYOffset + readInt32FromFile(bufferin);
                    int32_t colCount = readInt32FromFile(bufferin);
                    for (int j = 0; j < colCount; j++) {
                        int32_t binX = binXOffset + readInt32FromFile(bufferin);
                        float counts;
                        if (useShort) {
                            counts = readInt16FromFile(bufferin);
                        } else {
                            counts = readFloatFromFile(bufferin);
                        }
                        appendRecord(v, index++, binX, binY, counts);
                    }
                }
            }
        } else if (type == 2) {
            int32_t nPts = readInt32FromFile(bufferin);
            int16_t w = readInt16FromFile(bufferin);

            for (int i = 0; i < nPts; i++) {
                //int32_t idx = (p.y - binOffset2) * w + (p.x - binOffset1);
                int32_t row = i / w;
                int32_t col = i - row * w;
                int32_t bin1 = binXOffset + col;
                int32_t bin2 = binYOffset + row;

                float counts;
                if (useShort) {
                    int16_t c = readInt16FromFile(bufferin);
                    if (c != -32768) {
                        appendRecord(v, index++, bin1, bin2, c);
                    }
                } else {
                    counts = readFloatFromFile(bufferin);
                    if (!isnan(counts)) {
                        appendRecord(v, index++, bin1, bin2, counts);
                    }
                }
            }
        }
    }
    delete[] compressedBytes;
    delete[] uncompressedBytes; // don't forget to delete your heap arrays in C++!
    return v;
}

// reads the normalization vector from the file at the specified location
vector<double> readNormalizationVector(istream &bufferin, int32_t version) {
    int64_t nValues;
    if (version > 8) {
        nValues = readInt64FromFile(bufferin);
    } else {
        nValues = (int64_t) readInt32FromFile(bufferin);
    }

    uint64_t numValues;
    numValues = static_cast<uint64_t>(nValues);
    vector<double> values(numValues);

    if (version > 8) {
        for (int i = 0; i < nValues; i++) {
            values[i] = (double) readFloatFromFile(bufferin);
        }
    } else {
        for (int i = 0; i < nValues; i++) {
            values[i] = readDoubleFromFile(bufferin);
        }
    }

    return values;
}

class MatrixZoomData {
public:
    bool isIntra;
    string fileName;
    int64_t myFilePos = 0LL;
    vector<double> expectedValues;
    bool foundFooter = false;
    vector<double> c1Norm;
    vector<double> c2Norm;
    int32_t c1 = 0;
    int32_t c2 = 0;
    string matrixType;
    string norm;
    int32_t version = 0;
    int32_t resolution = 0;
    int32_t numBins1 = 0;
    int32_t numBins2 = 0;
    float sumCounts;
    int32_t blockBinCount, blockColumnCount;
    map<int32_t, indexEntry> blockMap;
    double avgCount;

    MatrixZoomData(const chromosome &chrom1, const chromosome &chrom2, const string &matrixType,
                   const string &norm, const string &unit, int32_t resolution,
                   int32_t &version, int64_t &master, int64_t &totalFileSize,
                   const string &fileName) {
        this->version = version;
        this->fileName = fileName;
        int32_t c01 = chrom1.index;
        int32_t c02 = chrom2.index;
        if (c01 <= c02) { // default is ok
            this->c1 = c01;
            this->c2 = c02;
            this->numBins1 = static_cast<int32_t>(chrom1.length / resolution);
            this->numBins2 = static_cast<int32_t>(chrom2.length / resolution);
        } else { // flip
            this->c1 = c02;
            this->c2 = c01;
            this->numBins1 = static_cast<int32_t>(chrom2.length / resolution);
            this->numBins2 = static_cast<int32_t>(chrom1.length / resolution);
        }
        isIntra = c1 == c2;

        this->matrixType = matrixType;
        this->norm = norm;
        this->resolution = resolution;

        HiCFileStream *stream = new HiCFileStream(fileName);
        indexEntry c1NormEntry{}, c2NormEntry{};

        if (stream->isHttp) {
            foundFooter = readFooterURL(stream->curl, master, version, c1, c2, matrixType, norm, unit,
                                     resolution,
                                     myFilePos,
                                     c1NormEntry, c2NormEntry, expectedValues);
        } else {
            stream->fin.seekg(master, ios::beg);
            foundFooter = readFooter(stream->fin, master, version, c1, c2, matrixType, norm,
                                     unit,
                                     resolution, myFilePos,
                                     c1NormEntry, c2NormEntry, expectedValues);
        }

        if (!foundFooter) {
            return;
        }
        stream->close();

        if (norm != "NONE") {
            c1Norm = readNormalizationVectorFromFooter(c1NormEntry, version, fileName);
            if (isIntra) {
                c2Norm = c1Norm;
            } else {
                c2Norm = readNormalizationVectorFromFooter(c2NormEntry, version, fileName);
            }
        }

        HiCFileStream *stream2 = new HiCFileStream((fileName));
        if (stream2->isHttp) {
            // readMatrix will assign blockBinCount and blockColumnCount
            blockMap = readMatrixHttp(stream2->curl, myFilePos, unit, resolution, sumCounts,
                                      blockBinCount,
                                      blockColumnCount);
        } else {
            // readMatrix will assign blockBinCount and blockColumnCount
            blockMap = readMatrix(stream2->fin, myFilePos, unit, resolution, sumCounts,
                                  blockBinCount,
                                  blockColumnCount);
        }
        stream2->close();

        if (!isIntra) {
            avgCount = (sumCounts / numBins1) / numBins2;   // <= trying to avoid overflows
        }
    }

    static vector<double> readNormalizationVectorFromFooter(indexEntry cNormEntry, int32_t &version,
                                                            const string &fileName) {
        if (cNormEntry.size == 0) {
            // no normalization entries in this file.  Bow out now and avoid an allocation error
            throw strawException("Trying to retrieve other normalization options, but none exist");
        }
        char *buffer = readCompressedBytesFromFile(fileName, cNormEntry);
        memstream bufferin(buffer, cNormEntry.size);
        vector<double> cNorm = readNormalizationVector(bufferin, version);
        delete buffer;
        return cNorm;
    }

    static bool isInRange(int32_t r, int32_t c, int32_t numRows, int32_t numCols) {
        return 0 <= r && r < numRows && 0 <= c && c < numCols;
    }

    set<int32_t> getBlockNumbers(int64_t *regionIndices) const {
        if (version > 8 && isIntra) {
            return getBlockNumbersForRegionFromBinPositionV9Intra(regionIndices, blockBinCount, blockColumnCount);
        } else {
            return getBlockNumbersForRegionFromBinPosition(regionIndices, blockBinCount, blockColumnCount, isIntra);
        }
    }

    vector<double> getNormVector(int32_t index) {
        if (index == c1) {
            return c1Norm;
        } else if (index == c2) {
            return c2Norm;
        }
        cerr << "Invalid index provided: " << index << endl;
        cerr << "Should be either " << c1 << " or " << c2 << endl;
        vector<double> v;
        return v;
    }

    vector<double> getExpectedValues() {
        return expectedValues;
    }

    vector<contactRecord> getRecords(int64_t gx0, int64_t gx1, int64_t gy0, int64_t gy1) {
        if (!foundFooter) {
            vector<contactRecord> v;
            return v;
        }
        int64_t origRegionIndices[] = {gx0, gx1, gy0, gy1};
        int64_t regionIndices[4];
        convertGenomeToBinPos(origRegionIndices, regionIndices, resolution);

        set<int32_t> blockNumbers = getBlockNumbers(regionIndices);
        vector<contactRecord> records;
        for (int32_t blockNumber : blockNumbers) {
            // get contacts in this block
            //cout << *it << " -- " << blockMap.size() << endl;
            //cout << blockMap[*it].size << " " <<  blockMap[*it].position << endl;
            vector<contactRecord> tmp_records = readBlock(fileName, blockMap[blockNumber], version);
            for (contactRecord rec : tmp_records) {
                int64_t x = rec.binX * resolution;
                int64_t y = rec.binY * resolution;

                if ((x >= origRegionIndices[0] && x <= origRegionIndices[1] &&
                     y >= origRegionIndices[2] && y <= origRegionIndices[3]) ||
                    // or check regions that overlap with lower left
                    (isIntra && y >= origRegionIndices[0] && y <= origRegionIndices[1] && x >= origRegionIndices[2] &&
                     x <= origRegionIndices[3])) {

                    float c = rec.counts;
                    if (norm != "NONE") {
                        c = static_cast<float>(c / (c1Norm[rec.binX] * c2Norm[rec.binY]));
                    }
                    if (matrixType == "oe") {
                        if (isIntra) {
                            c = static_cast<float>(c / expectedValues[min(expectedValues.size() - 1,
                                                                          (size_t) floor(abs(y - x) /
                                                                                         resolution))]);
                        } else {
                            c = static_cast<float>(c / avgCount);
                        }
                    } else if (matrixType == "expected") {
                        if (isIntra) {
                            c = static_cast<float>(expectedValues[min(expectedValues.size() - 1,
                                                                      (size_t) floor(abs(y - x) /
                                                                                     resolution))]);
                        } else {
                            c = static_cast<float>(avgCount);
                        }
                    }

                    if (!isnan(c) && !isinf(c)){
                        contactRecord record = contactRecord();
                        record.binX = static_cast<int32_t>(x);
                        record.binY = static_cast<int32_t>(y);
                        record.counts = c;
                        records.push_back(record);
                    }
                }
            }
        }
        return records;
    }

    vector<vector<float> > getRecordsAsMatrix(int64_t gx0, int64_t gx1, int64_t gy0, int64_t gy1) {
        vector<contactRecord> records = this->getRecords(gx0, gx1, gy0, gy1);
        if (records.empty()) {
            vector<vector<float> > res = vector<vector<float> >(1, vector<float>(1, 0));
            return res;
        }

        int64_t origRegionIndices[] = {gx0, gx1, gy0, gy1};
        int64_t regionIndices[4];
        convertGenomeToBinPos(origRegionIndices, regionIndices, resolution);

        int64_t originR = regionIndices[0];
        int64_t endR = regionIndices[1];
        int64_t originC = regionIndices[2];
        int64_t endC = regionIndices[3];
        int32_t numRows = endR - originR + 1;
        int32_t numCols = endC - originC + 1;
        vector<vector<float> > matrix;
        for (int32_t i = 0; i < numRows; i++) {
            matrix.emplace_back(numCols, 0);
        }

        for (contactRecord cr : records) {
            if (isnan(cr.counts) || isinf(cr.counts)) continue;
            int32_t r = cr.binX / resolution - originR;
            int32_t c = cr.binY / resolution - originC;
            if (isInRange(r, c, numRows, numCols)) {
                matrix[r][c] = cr.counts;
            }
            if (isIntra) {
                r = cr.binY / resolution - originR;
                c = cr.binX / resolution - originC;
                if (isInRange(r, c, numRows, numCols)) {
                    matrix[r][c] = cr.counts;
                }
            }
        }
        return matrix;
    }

    int64_t getNumberOfTotalRecords() {
        if (!foundFooter) {
            return 0;
        }
        int64_t regionIndices[4] = {0, numBins1, 0, numBins2};
        set<int32_t> blockNumbers = getBlockNumbers(regionIndices);
        int64_t total = 0;
        for (int32_t blockNumber : blockNumbers) {
            total += getNumRecordsInBlock(fileName, blockMap[blockNumber], version);
        }
        return total;
    }
};

class HiCFile {
public:
    string prefix = "http"; // HTTP code
    int64_t master = 0LL;
    map<string, chromosome> chromosomeMap;
    string genomeID;
    int32_t numChromosomes = 0;
    int32_t version = 0;
    int64_t nviPosition = 0LL;
    int64_t nviLength = 0LL;
    vector<int32_t> resolutions;
    static int64_t totalFileSize;
    string fileName;
    vector<string> attributes;

    static size_t hdf(char *b, size_t size, size_t nitems, void *userdata) {
        size_t numbytes = size * nitems;
        b[numbytes + 1] = '\0';
        string s(b);
        int32_t found;
        found = static_cast<int32_t>(s.find("content-range"));
        if ((size_t) found == string::npos) {
            found = static_cast<int32_t>(s.find("Content-Range"));
        }
        if ((size_t) found != string::npos) {
            int32_t found2;
            found2 = static_cast<int32_t>(s.find('/'));
            //content-range: bytes 0-100000/891471462
            if ((size_t) found2 != string::npos) {
                string total = s.substr(found2 + 1);
                totalFileSize = stol(total);
            }
        }

        return numbytes;
    }

    static CURL *oneTimeInitCURL(const char *url) {
        CURL *curl = initCURL(url);
        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, hdf);
        curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1);
        return curl;
    }

    explicit HiCFile(const string &fileName) {
        this->fileName = fileName;

        // read header into buffer; 100K should be sufficient
        if (std::strncmp(fileName.c_str(), prefix.c_str(), prefix.size()) == 0) {
            CURL *curl;
            curl = oneTimeInitCURL(fileName.c_str());
            char *buffer = getData(curl, 0, 100000);
            memstream bufin(buffer, 100000);
            chromosomeMap = readHeader(bufin, master, genomeID, numChromosomes,
                                       version, nviPosition, nviLength, attributes);
            resolutions = readResolutionsFromHeader(bufin);
            curl_easy_cleanup(curl);
            delete buffer;
        } else {
            ifstream fin;
            fin.open(fileName, fstream::in | fstream::binary);
            if (!fin) {
                throw strawException("File " + fileName + " cannot be opened for reading");
                //cerr << "File " << fileName << " cannot be opened for reading" << endl;
                //exit(6);
            }
            chromosomeMap = readHeader(fin, master, genomeID, numChromosomes,
                                       version, nviPosition, nviLength, attributes);
            resolutions = readResolutionsFromHeader(fin);
            fin.close();
        }
    }

    string getGenomeID() const {
        return genomeID;
    }

    vector<int32_t> getResolutions() const {
        return resolutions;
    }

    vector<chromosome> getChromosomes() {
        chromosome chromosomes[chromosomeMap.size()];
        map<string, chromosome>::iterator iter = chromosomeMap.begin();
        while (iter != chromosomeMap.end()) {
            chromosome chrom = static_cast<chromosome>(iter->second);
            chromosomes[chrom.index] = chrom;
            iter++;
        }

        vector<chromosome> final_chromosomes;
        final_chromosomes.reserve(chromosomeMap.size());
        for(int32_t i = 0; i < chromosomeMap.size(); i++){
            final_chromosomes.push_back(chromosomes[i]);
        }
        return final_chromosomes;
    }

    MatrixZoomData * getMatrixZoomData(const string &chr1, const string &chr2, const string &matrixType,
                                       const string &norm, const string &unit, int32_t resolution) {
        chromosome chrom1 = chromosomeMap[chr1];
        chromosome chrom2 = chromosomeMap[chr2];
        return new MatrixZoomData(chrom1, chrom2, (matrixType), (norm), (unit),
                                  resolution, version, master, totalFileSize, fileName);
    }
};

int64_t HiCFile::totalFileSize = 0LL;

void parsePositions(const string &chrLoc, string &chrom, int64_t &pos1, int64_t &pos2, map<string, chromosome> map) {
    string x, y;
    stringstream ss(chrLoc);
    getline(ss, chrom, ':');
    if (map.count(chrom) == 0) {
        throw strawException("chromosome " + chrom + " not found in the file.");
        //cerr << "chromosome " << chrom << " not found in the file." << endl;
        //exit(7);
    }

    if (getline(ss, x, ':') && getline(ss, y, ':')) {
        pos1 = stol(x);
        pos2 = stol(y);
    } else {
        pos1 = 0LL;
        pos2 = map[chrom].length;
    }
}

vector<contactRecord> straw(const string &matrixType, const string &norm, const string &fileName, const string &chr1loc,
                            const string &chr2loc, const string &unit, int32_t binsize) {
    if (!(unit == "BP" || unit == "FRAG")) {
        cerr << "Norm specified incorrectly, must be one of <BP/FRAG>" << endl;
        cerr << "Usage: straw [observed/oe/expected] <NONE/VC/VC_SQRT/KR> <hicFile(s)> <chr1>[:x1:x2] <chr2>[:y1:y2] <BP/FRAG> <binsize>"
             << endl;
        vector<contactRecord> v;
        return v;
    }

    HiCFile *hiCFile = new HiCFile(fileName);
    string chr1, chr2;
    int64_t origRegionIndices[4] = {-100LL, -100LL, -100LL, -100LL};
    parsePositions((chr1loc), chr1, origRegionIndices[0], origRegionIndices[1], hiCFile->chromosomeMap);
    parsePositions((chr2loc), chr2, origRegionIndices[2], origRegionIndices[3], hiCFile->chromosomeMap);

    if (hiCFile->chromosomeMap[chr1].index > hiCFile->chromosomeMap[chr2].index) {
        MatrixZoomData *mzd = hiCFile->getMatrixZoomData(chr2, chr1, matrixType, norm, unit, binsize);
        return mzd->getRecords(origRegionIndices[2], origRegionIndices[3], origRegionIndices[0], origRegionIndices[1]);
    } else {
        MatrixZoomData *mzd = hiCFile->getMatrixZoomData(chr1, chr2, matrixType, norm, unit, binsize);
        return mzd->getRecords(origRegionIndices[0], origRegionIndices[1], origRegionIndices[2], origRegionIndices[3]);
    }
}

vector<vector<float> > strawAsMatrix(const string &matrixType, const string &norm, const string &fileName, const string &chr1loc,
                   const string &chr2loc, const string &unit, int32_t binsize) {
    if (!(unit == "BP" || unit == "FRAG")) {
        cerr << "Norm specified incorrectly, must be one of <BP/FRAG>" << endl;
        cerr << "Usage: straw [observed/oe/expected] <NONE/VC/VC_SQRT/KR> <hicFile(s)> <chr1>[:x1:x2] <chr2>[:y1:y2] <BP/FRAG> <binsize>"
             << endl;
        vector<vector<float> > res = vector<vector<float> >(1, vector<float>(1, 0));
        return res;
    }

    HiCFile *hiCFile = new HiCFile(fileName);
    string chr1, chr2;
    int64_t origRegionIndices[4] = {-100LL, -100LL, -100LL, -100LL};
    parsePositions((chr1loc), chr1, origRegionIndices[0], origRegionIndices[1], hiCFile->chromosomeMap);
    parsePositions((chr2loc), chr2, origRegionIndices[2], origRegionIndices[3], hiCFile->chromosomeMap);

    if (hiCFile->chromosomeMap[chr1].index > hiCFile->chromosomeMap[chr2].index) {
        MatrixZoomData *mzd = hiCFile->getMatrixZoomData(chr2, chr1, matrixType, norm, unit, binsize);
        return mzd->getRecordsAsMatrix(origRegionIndices[2], origRegionIndices[3], origRegionIndices[0], origRegionIndices[1]);
    } else {
        MatrixZoomData *mzd = hiCFile->getMatrixZoomData(chr1, chr2, matrixType, norm, unit, binsize);
        return mzd->getRecordsAsMatrix(origRegionIndices[0], origRegionIndices[1], origRegionIndices[2], origRegionIndices[3]);
    }
}

int64_t getNumRecordsForFile(const string &fileName, int32_t binsize, bool interOnly) {
    HiCFile *hiCFile = new HiCFile(fileName);
    int64_t totalNumRecords = 0;

    int32_t indexOffset = 0;
    if (interOnly){
        indexOffset = 1;
    }

    vector<chromosome> chromosomes = hiCFile->getChromosomes();
    for(int32_t i = 0; i < chromosomes.size(); i++){
        if(chromosomes[i].index <= 0) continue;
        for(int32_t j = i + indexOffset; j < chromosomes.size(); j++){
            if(chromosomes[j].index <= 0) continue;
            MatrixZoomData *mzd;
            if(chromosomes[i].index > chromosomes[j].index){
                mzd = hiCFile->getMatrixZoomData(chromosomes[j].name, chromosomes[i].name, "observed", "NONE", "BP", binsize);
            } else {
                mzd = hiCFile->getMatrixZoomData(chromosomes[i].name, chromosomes[j].name, "observed", "NONE", "BP", binsize);
            }
            totalNumRecords += mzd->getNumberOfTotalRecords();
        }
    }

    return totalNumRecords;
}

int64_t getNumRecordsForChromosomes(const string &fileName, int32_t binsize, bool interOnly) {
    HiCFile *hiCFile = new HiCFile(fileName);
    vector<chromosome> chromosomes = hiCFile->getChromosomes();
    for(int32_t i = 0; i < chromosomes.size(); i++){
        if(chromosomes[i].index <= 0) continue;
        MatrixZoomData *mzd = hiCFile->getMatrixZoomData(chromosomes[i].name, chromosomes[i].name, "observed", "NONE", "BP", binsize);
        int64_t totalNumRecords = mzd->getNumberOfTotalRecords();
        cout << chromosomes[i].name << " " << totalNumRecords << " ";
        cout << totalNumRecords*12/1000/1000/1000 << " GB" << endl;
    }
    return 0;
}

void getHeaderFields(const string &filename, string &genome, vector<string> &chromNames, vector<int> &chromSizes,
        vector<int> &bpResolutions, vector<int> &fragResolutions, vector<string> &attributes)
/* Fill in the provided fields with information from the header of the hic file in the supplied filename.
 * fragResolutions is left empty for now, as we're not making use of it. */
{
    HiCFile *hiCFile = new HiCFile(filename);

    genome.assign(hiCFile->getGenomeID());

    vector<chromosome> chromList = hiCFile->getChromosomes();
    vector<string> myChromNames;
    myChromNames.reserve(chromList.size());
    vector<int> myChromSizes;
    myChromSizes.reserve(chromList.size());
    for(int32_t i = 0; i < chromList.size(); i++){
        myChromNames.push_back(chromList[i].name);
        myChromSizes.push_back(chromList[i].length);
    }
    chromNames = myChromNames;
    chromSizes = myChromSizes;

    vector<int> myBpResolutions;
    myBpResolutions.reserve(hiCFile->resolutions.size());
    for(int32_t i = 0; i < hiCFile->resolutions.size(); i++){
        myBpResolutions.push_back(hiCFile->resolutions[i]);
    }
    bpResolutions = myBpResolutions;

    attributes = hiCFile->attributes;

    // Ignoring fragment resolutions for now, since they're never being used here
}

set<string> getNormOptions()
/* Return the set of normalization options that have been encountered through footer parsing.
 * The result will be empty unless at least one straw() request has been made.
 */
{
    return globalNormOptions;
}
