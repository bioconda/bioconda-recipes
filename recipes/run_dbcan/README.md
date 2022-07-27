# run_dbcan 2.0

This is the standalone version of dbCAN annotation tool for automated CAZyme annotation (known as run_dbCAN.py), written by Le Huang and Tanner Yohe.

If you want to use our dbCAN2 webserver, please go to http://bcb.unl.edu/dbCAN2/.

If you use dbCAN standalone tool or/and our web server for publication, please cite us:

*Han Zhang, Tanner Yohe, **Le Huang**, Sarah Entwistle, Peizhi Wu, Zhenglu Yang, Peter K Busk, Ying Xu, Yanbin Yin;
dbCAN2: a meta server for automated carbohydrate-active enzyme annotation, Nucleic Acids Research,
Volume 46, Issue W1, 2 July 2018, Pages W95–W101, https://doi.org/10.1093/nar/gky418*
```
@article{doi:10.1093/nar/gky418,
author = {Zhang, Han and Yohe, Tanner and Huang, Le and Entwistle, Sarah and Wu, Peizhi and Yang, Zhenglu and Busk, Peter K and Xu, Ying and Yin, Yanbin},
title = {dbCAN2: a meta server for automated carbohydrate-active enzyme annotation},
journal = {Nucleic Acids Research},
volume = {46},
number = {W1},
pages = {W95-W101},
year = {2018},
doi = {10.1093/nar/gky418},
URL = {http://dx.doi.org/10.1093/nar/gky418},
eprint = {/oup/backfile/content_public/journal/nar/46/w1/10.1093_nar_gky418/1/gky418.pdf}
}
```

If you want to use pre-computed bacterial CAZyme sequences/annotations directly, please go to http://bcb.unl.edu/dbCAN_seq/ and cite us:

**Le Huang**, Han Zhang, Peizhi Wu, Sarah Entwistle, Xueqiong Li, Tanner Yohe, Haidong Yi, Zhenglu Yang, Yanbin Yin;
dbCAN-seq: a database of carbohydrate-active enzyme (CAZyme) sequence and annotation, Nucleic Acids Research,
Volume 46, Issue D1, 4 January 2018, Pages D516–D521, https://doi.org/10.1093/nar/gkx894*
```
@article{doi:10.1093/nar/gkx894,
author = {Huang, Le and Zhang, Han and Wu, Peizhi and Entwistle, Sarah and Li, Xueqiong and Yohe, Tanner and Yi, Haidong and Yang, Zhenglu and Yin, Yanbin},
title = {dbCAN-seq: a database of carbohydrate-active enzyme (CAZyme) sequence and annotation},
journal = {Nucleic Acids Research},
volume = {46},
number = {D1},
pages = {D516-D521},
year = {2018},
doi = {10.1093/nar/gkx894},
URL = {http://dx.doi.org/10.1093/nar/gkx894},
eprint = {/oup/backfile/content_public/journal/nar/46/d1/10.1093_nar_gkx894/2/gkx894.pdf}
}
```



## run_dbcan.py Stand Alone Version2.0 User Mannual

Rewritten by Huang Le in the Zhang Lab at NKU; V1 version was written by Tanner Yohe of the Yin lab at NIU.

Last updated 12/24/18

### updating info
- ## 15/04/2019 We created a docker which has the same environment as mine. You can keep away from complicated setup process. You can run our program in any system (Windows, Mac OS, Ubuntu, centos). Why not give it a try?
```
1. Make sure docker is installed on your computer successfully.
2. docker pull haidyi/run_dbcan:latest
3. docker run --name <preferred_name> -v <host-path>:<container-path> -it haidyi/run_dbcan:latest python run_dbcan.py <input_file> [params] --out_dir <output_dir>
```
Note: If you want to use your own sequence, mount it and result_dir to the container.

- More user friendly
- Adds `stp hmmdb` signature gene in CGC_Finder.py (stp means signal transduction proteins; the hmmdb was constructed by Catherine Ausland of the Yin lab at NIU)
- Changes tfdb from `tfdb` to `tf.hmm`, which is added to `db/` directory (tfdb was a fasta format sequence file, which contains just bacterial transcription factor proteins; tf.hmm is a hmmer format file containing hmms downloaded from the Pfam and SUPERFAMILY database according to the DBD database: http://www.transcriptionfactor.org)
- Uses newest dbCAN-HMM db and CAZy db
- Fixes bugs in HotPep python version to fit python 3 user.
- Added certain codes to make it robust. Thanks to suggestion from [Mick](mick.watson@roslin.ed.ac.uk).

### Function
- Accepts user input
- Predicts genes if needed
- Runs input against HMMER, DIAMOND, and Hotpep
- Optionally predicts CGCs with CGCFinder


### STEP by STEP install

Many people told me they meet a lot of problems during setting up. Therefore, I write a step by step tutorial to install our run_dbcan project. 

Here we go:

Env: Ubuntu-16-04

1. Install python3
```
sudo apt-get install python3
```
And then install pip
```
sudo apt-get install python3-pip
```

2. Install Diamond
```
wget http://github.com/bbuchfink/diamond/releases/download/v0.9.24/diamond-linux64.tar.gz

tar xzf diamond-linux64.tar.gz
``` 
 The extracted diamond binary file should be moved to a directory contained in your executable search path (PATH environment variable).

3.  Install hmmer
```
wget http://eddylab.org/software/hmmer/hmmer-3.1b2.tar.gz
```
And add its path to ./bashrc

4. Install signalP
You have to obtain your own academic license of SignalP and download it from [here](http://www.cbs.dtu.dk/cgi-bin/sw_request?signalp+4.1), and then move tarball (Signalp-4.1.tar.gz) into `run_dbcan/tools/` by yourself.
```
cd run_dbcan/tools/
tar xzf Signalp-4.1.tar.gz
cd Signalp-4.1
```
Edit the paragraph labeled  "GENERAL SETTINGS, CUSTOMIZE ..." in the top of
   the file 'signalp'. The following twovmandatory variables need to be set:
   
   	SIGNALP		full path to the signalp-4.1 directory on your system
	outputDir	where to store temporary files (writable to all users)

   In addition,  for practical reasons,  it is possible to limit the number of
   input sequences allowed per run (MAX_ALLOWED_ENTRIES).

Use mine as an example:
```
###############################################################################
#               GENERAL SETTINGS: CUSTOMIZE TO YOUR SITE
###############################################################################

# full path to the signalp-4.1 directory on your system (mandatory)
BEGIN {
    $ENV{SIGNALP} = '/home/abc/Desktop/run_dbcan/tools/signalp-4.1';
}

# determine where to store temporary files (must be writable to all users)
my $outputDir = "/home/abc/Desktop/run_dbcan/tools/signalp-4.1/output";

# max number of sequences per run (any number can be handled)
my $MAX_ALLOWED_ENTRIES=100000;
```

And then, use this command:

```
sudo cp signalp /usr/bin/signalp
sudo chmod 777 /usr/bin/signalp
```

5. install Prodigal
```
git clone https://github.com/hyattpd/Prodigal.git
cd Prodigal
make install
prodigal -h
mv /<path>/prodigal run_dbcan/tools/
```

6. install FragGeneScan1.31.tar.gz
Download FragGeneScan1.31.tar.gz from this website:
https://sourceforge.net/projects/fraggenescan/files/latest/download

```
tar xvf FragGeneScan1.31.tar.gz
cd FragGeneScan1.31
make
make clean
make fgs

vim ~/.bashrc
export PATH="<yourpath>/FragGeneScan1.31:$PATH"
source ~/.bashrc
```

### REQUIREMENTS

#### TOOLS
P.S.: You do not need to download `CGCFinder`, `Hotpep-Python` and `hmmscan-parser` because they are included in run_dbcan V2. If you need to use signalp, Prodigal and FragGeneScan, we recommend you to copy them to `/usr/bin` as system application or add their path into system envrionmental variable.


[Python3]()--Be sure to use python3, not python2


[DIAMOND](https://github.com/bbuchfink/diamond)-- please install from github as instructions.

[HMMER](hmmer.org)--Please download 3.1b2version in 2015, the newest version is not suitable `wget http://eddylab.org/software/hmmer/hmmer-3.1b2.tar.gz` and add variable to your environment

[hmmscan-parser](https://github.com/linnabrown/run_dbcan/blob/master/hmmscan-parser.py)--This is included in dbCAN2.

[Hotpep-Python](https://github.com/linnabrown/run_dbcan/tree/master/Hotpep)--This newest version is included in dbCAN2.

[signalp](http://www.cbs.dtu.dk/services/SignalP/)--please download and install if you need.

[Prodigal](https://github.com/hyattpd/Prodigal)--please download and install if you need.

[FragGeneScan](http://omics.informatics.indiana.edu/FragGeneScan/)--please download and install if you need.

[CGCFinder](https://github.com/linnabrown/run_dbcan/blob/master/CGCFinder.py)--This newest version is included in dbCAN2 project.

#### DATABASES and Formatting[required!][Link](http://bcb.unl.edu/dbCAN2/download/Databases)

[CAZyDB.07312019.fa](http://bcb.unl.edu/dbCAN2/download/Databases/CAZyDB.07312019.fa)--use `diamond makedb --in CAZyDB.07312019.fa -d CAZy`

[PPR]:included in Hotpep

[dbCAN-HMMdb-V8.txt](http://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-HMMdb-V8.txt)--First use `mv dbCAN-HMMdb-V8.txt dbCAN.txt`, then use `hmmpress dbCAN.txt`

[tcdb.fa](http://bcb.unl.edu/dbCAN2/download/Databases/tcdb.fa)--use `diamond makedb --in tcdb.fa -d tcdb`

[tf-1.hmm](http://bcb.unl.edu/dbCAN2/download/Databases/tf-1.hmm)--use `hmmpress tf-1.hmm`

[tf-2.hmm](http://bcb.unl.edu/dbCAN2/download/Databases/tf-2.hmm)--use `hmmpress tf-2.hmm`

[stp.hmm](http://bcb.unl.edu/dbCAN2/download/Databases/stp.hmm)--use `hmmpress stp.hmm`

#### PYTHON MODULE

natsort						-- use `pip install natsort`


### DIRECTORY STRUCTURE

- We recommend that all the databases are put in a seperate directory. This directory can be defined with the `--db_dir` option or leave it as directory with default name `db`. Otherwise, all databases must be in the same directory as run_dbcan.py.

- The Hotpep directory must also be in the same directory as run_dbcan.py.

- When you use **FragGeneScan**, you should download this file, unpress, and add its path to user enviroenment variable. The concrete method is written on [this website](http://omics.informatics.indiana.edu/FragGeneScan/). Otherwise, you should put unzip this file in the same directory as run_dbcan.py and revise the code in `run_dbcan.py` like this:

```
# if you put FragGeneScan' path the same directory as run_dbcan.py, you can use this command.
#call(['FragGeneScan1.30/run_FragGeneScan.pl', '-genome='+input, '-out=%sfragGeneScan'%outPath, '-complete=1', '-train=complete', '-thread=10'])
#if you install FragGeneScan and add its path to environmental variable, you should use this command.
call(['FragGeneScan', '-s', input, '-o', '%sfragGeneScan'%outPath, '-w 1','-t comlete', '-p 10'])
```



### INPUT

```
python run_dbcan.py [inputFile] [inputType] [-c AuxillaryFile] [-t Tools] etc.
```

	[inputFile] - FASTA format file of either nucleotide or protein sequences

	[inputType] - protein=proteome, prok=prokaryote, meta=metagenome/mRNA/CDSs/short DNA seqs

	[--out_dir] - REQUIRED, user specifies an output directory.

	[-c AuxillaryFile]- optional, include to enable CGCFinder. If using a proteome input,
	the AuxillaryFile must be a GFF or BED format file containing gene positioning
	information. Otherwise, the AuxillaryFile may be left blank.

	[-t Tools] 		- optional, allows user to select a combination of tools to run. The options are any
					combination of 'diamond', 'hmmer', and 'hotpep'. The default value is 'all' which runs all three tools.
	[--dbCANFile]   - optional, allows user to set the file name of dbCAN HMM Database.

	[--dia_eval]    - optional, allows user to set the DIAMOND E Value. Default = 1e-102.

	[--dia_cpu]     - optional, allows user to set how many CPU cores DIAMOND can use. Default = 2.

	[--hmm_eval]    - optional, allows user to set the HMMER E Value. Default = 1e-15.

	[--hmm_cov]     - optional, allows user to set the HMMER Coverage value. Default = 0.35.

	[--hmm_cpu]     - optional, allows user to set how many CPU cores HMMER can use. Default = 1.

	[--hot_hits]    - optional, allows user to set the Hotpep Hits value. Default = 6.

	[--hot_freq]    - optional, allows user to set the Hotpep Frequency value. Default = 2.6.

	[--hot_cpu]     - optional, allows user to set how many CPU cores Hotpep can use. Default = 3.

	[--tf_eval]     - optional, allows user to set tf.hmm HMMER E Value. Default = 1e-4.

	[--tf_cov]     - optional, allows user to set tf.hmm HMMER Coverage val. Default = 0.35.

	[--tf_cpu]     - optional, allows user to tf.hmm Number of CPU cores that HMMER is allowed to use. Default = 1.

	[--stp_eval]     - optional, allows user to set stp.hmm HMMER E Value. Default = 1e-4.

	[--tf_cov]     - optional, allows user to set stp.hmm HMMER Coverage val. Default = 0.3.

	[--tf_cpu]     - optional, allows user to stp.hmm Number of CPU cores that HMMER is allowed to use. Default = 1.

	[--out_pre]     - optional, allows user to set a prefix for all output files.

	[--db_dir]      - optional, allows user to specify a database directory. Default = db/

	[--cgc_dis]     - optional, allows user to specify CGCFinder Distance value. Allowed values are integers between 0-10. Default = 2.

	[--cgc_sig_genes] - optional, allows user to specify CGCFinder Signature Genes. The options are, 'tp': TP and CAZymes, 'tf': TF and CAZymes, and 'all': TF, TP, and CAZymes. Default = 'tp'.



### OUTPUT

Several files will be outputted. they are as follows:

	uniInput - The unified input file for the rest of the tools
			(created by prodigal or FragGeneScan if a nucleotide sequence was used)

	Hotpep.out - the output from the Hotpep run

	diamond.out - the output from the diamond blast

	hmmer.out - the output from the hmmer run

	tf.out - the output from the diamond blast predicting TF's for CGCFinder

	tc.out - the output from the diamond blast predicting TC's for CGCFinder

	cgc.gff - GFF input file for CGCFinder

	cgc.out - ouput from the CGCFinder run
	
	overview.txt - Details the CAZyme predictions across the three tools with signalp results

### EXAMPLE

An example setup is available in the example directory. Included in this directory are two FASTA sequences (one protein, one nucleotide).

To run this example type, run:

```
python run_dbcan.py EscheriaColiK12MG1655.fna prok --out_dir output_EscheriaColiK12MG1655
```
or

```
python run_dbcan.py EscheriaColiK12MG1655.faa protein --out_dir output_EscheriaColiK12MG1655
```

While this example directory contains all the databases you will need (already formatted) and the Hotpep and FragGeneScan programs, you will still need to have the remaining programs installed on your machine (DIAMOND, HMMER, etc.).

To run the examples with CGCFinder turned on, run:
```
python run_dbcan.py EscheriaColiK12MG1655.fna prok -c cluster --out_dir output_EscheriaColiK12MG1655
```

or

```
python run_dbcan.py EscheriaColiK12MG1655.faa protein -c EscheriaColiK12MG1655.gff --out_dir output_EscheriaColiK12MG1655
```

Notice that the protein command has a GFF file following the -c option. A GFF or BED format file with gene position information is required to run CGCFinder when using a protein input.

If you have any questions, please feel free to contact with Dr. Yin (yanbin.yin@gmail.com or yyin@unl.edu) or me (Le Huang) on [Issue Dashboard](https://github.com/linnabrown/run_dbcan/issues).

### FAQ

#### Q) I use docker and it shows 'mkdir: cannot create directory '/to/any/path/': No such file or directory', what's the issue.

A) Please check your input directory and output directory is correct or not. If so and problem still happens, you may not mount a directory to the container. Please use -v command to mount your input sequence and output directory to the container.Please use the command:
```
docker run --name <preferred_name> -v <host-path>:<container-path> -it haidyi/run_dbcan:latest python run_dbcan.py <input_file> [params] --out_dir <output_dir>
```
You need to use `mkdir` to make a new path in your container, for example `mkdir /app/result`, and your local path of result is /to/path/result, the params of `-v` is `-v /to/path/result:/app/result`, and your `--out_dir` path is `--out_dir /app/result`.

#### Q) What kind of input file and output directory format is acceptable?
A) ./<gene_name>.faa, /path/to/where/<gene_name>.faa


#### Q) I have a permission problem using docker
A) Please use the following command, try mine as an example. Use multiple command with `sh -c`. My local directory is `~/dbcan` where I put input file `EscheriaColiK12MG1655.faa` and output directory `output_dir`. And I mount my directory to the path `/app/result` in the container using this command `-v ~/run_dbcan:/app/result`. `python run_dbcan.py XXXX` is like the previous one.
```
docker run --rm --name test_run_dbcan -v ~/run_dbcan:/app/result -it haidyi/run_dbcan:latest sh -c "sudo chmod -R 755 /app/result  && python run_dbcan.py /app/result/EscheriaColiK12MG1655.faa protein --out_dir /app/result/output_dir"
```


