![RabbitSketch](sketch.png)
RabbitSketch is a highly optimized sketching library that exploits the power of modern multi-core CPUs. It supports various sketching algorithms including MinHash, OrderMinHash, and HyperLogLog. RabbitSketch achieves significant speedups compared to existing implementations, ranging from 2.30x to 49.55x.In addition, we provide flexible and easy-to-use interfaces for both Python and C++. The similarity analysis of 455GB genomic data can be completed in about 5 minutes using RabbitSketch with Python code.
Detailed API documentation at https://rabbitsketch.readthedocs.io/en/latest
## Getting Started
A Linux system on a recent x86_64 CPU is required.

### Installing (C++ interface) 


```bash
cd RabbitSketch
mkdir build
cd build
cmake -DCXXAPI=ON .. -DCMAKE_INSTALL_PREFIX=.
make
make install
export LD_LIBRARY_PATH=`pwd`/lib:$LD_LIBRARY_PATH
```


### Testing (C++)

If the Kssd algorithm is used, the shuffled file must first be generated. You can generate the shuffled file in the `shuf_file/` directory by running `exe_generate_shuf_file`. Here, L represents the drlevel, and K represents halfk. By default, we use `L3K10.shuf`.

```bash
cd ../examples/
#default install dir: ../build/
make 
#./exe_generate_shuf_file
./exe_SKETCH_ALGORITHM FILE_PATH threshold(0.05) thread_num 
```
We will get the distance among large-scale genome sequences.

```bash
./exe_generate_shuf_file
./exe_main genome1.fna genome2.fna
```
We will get the distance between genome1 and genome2 with different algorithm


### PYTHON bind
**pip install:**
```bash
cd RabbitSketch
pip install . --user
```
or
```bash
#pypi available (not up to date)
#pip install rabbitsketch --user
```
**cmake install**
```bash
cd RabbitSketch
mkdir build
cd build
cmake .. #default with pybind support
make
```
**test using bpython or python**

```bash
#pip install -r requirement.txt 
cd examples
python rabbitsketch_pymp.py #require fastx
```
We will get the Jaccard index among large-scale genome sequences with Python API. 
