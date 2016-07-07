//
//  Bank.h
//
//  Created by Guillaume Rizk on 28/11/11.
//  Modified by Rayan Chikhi on 16/2/13
//

#ifndef Bank_h
#define Bank_h
#include <stdio.h>
#include "Kmer.h"

#include <zlib.h> // Added by Pierre Peterlongo on 02/08/2012.

#define TAILLE_NOM 1024
#define MAX_NB_FILES 2000

#define BUFFER_SIZE 16384 // same as kseq.h 

#define WRITE_BUFFER  32768// 16384  //800000

#define KMERSBUFFER_MAX_READLEN 4096 // grows dynamically if needed

#define BINREADS_BUFFER 100000

off_t fsize(const char *filename) ;

// heavily inspired by kseq.h from Heng Li (https://github.com/attractivechaos/klib)
typedef struct 
{
    gzFile stream;
    unsigned char *buffer;
    int buffer_start, buffer_end;
    bool eof;
    char last_char;
    char *fname;
    uint64_t estimated_filesize;
} buffered_file_t;

typedef struct 
{
    int length ,max;
    char *string;
} variable_string_t;
	
// supports opening multiple fasta/fastq files
class Bank{

    public:

        Bank(char *fname);
        Bank(char **fname, int nb_files_);
        void init(char **fname, int nb_files_);
        void close();

        bool get_next_seq(char **nseq, int *len);
        bool get_next_seq_from_file(char **nseq, int *len, int file_id);
    
        bool get_next_seq_from_file(char **nseq, char **cheader, int *len, int *hlen, int file_id);
        bool get_next_seq(char **nseq, char **cheader, int *len, int *hlen);
    
        bool get_next_seq(char **nseq, char **cheader, int *len, int *hlen, int  * id_file);//also return file id
        bool get_next_seq(char **nseq, int *len, int * id_file); //also return file id

        void open_stream(int i); // internal functions
        void close_stream(int i);
        void rewind_all();

        variable_string_t *read, *dummy, *header;

        int nb_files; // total nb of files
        int index_file; // index of current file
        uint64_t filesizes; // estimate of total size for all files

        signed int buffered_gets(buffered_file_t *bf, variable_string_t *s, char *dret, bool append, bool allow_spaces);

        ~Bank();

        uint64_t estimate_kmers_volume(int k);
        uint64_t estimate_nb_reads();
        int estimate_max_readlen();

        // functions that enable to read the same portion twice
        void save_position();
        void load_position();
        int restore_index_file;
        z_off_t restore_pos;

        buffered_file_t  **buffered_file;
};

class BinaryBank
{
    protected:
        char filename[TAILLE_NOM];
        FILE * binary_read_file;
        const int sizeElement;
        void * buffer;
        int cpt_buffer;
        int cpt_init_buffer;

    int buffer_size_nelem;
    public:
        BinaryBank(char *filename, int sizeElement, bool write);
        BinaryBank ();
        void write_element(void *element);
        size_t read_element(void *element);
        size_t read_element_buffered(void *element);

        void write( void *element, int size);
        void write_element_buffered(void *element);

        size_t read( void *element, int size);
        void rewind_all();
        void close();
        void open(bool write);
        off_t nb_elements();
        ~BinaryBank();

};



class BinaryBankConcurrent :  public BinaryBank
{

    int * cpt_buffer_tid; //  this counter is now in  bytes
    int nthreads ;
    void * bufferT;
    public:
    BinaryBankConcurrent(char *given_filename, int given_sizeElement, bool write, int given_nthreads) ;
    void write_element_buffered(void *element, int tid);
    void write_buffered( void *element, int size, int tid);
    void write_buffered( void *element, int size, int tid, bool can_flush);
    void flush(int tid);

    void close();
    ~BinaryBankConcurrent();

};



class BinaryReads
{
    char filename[TAILLE_NOM];
    // const int sizeElement;
    unsigned char * buffer;
    int cpt_buffer;
    unsigned int  read_write_buffer_size;


    public:
    FILE * binary_read_file;

    BinaryReads(char *filename, bool write);
    // void write_element(void *element);
    //size_t read_element(void *element);
    void write_read(char * read, int readlen);
    void rewind_all();
    void close();
    void open(bool write);
    void mark_newfile();
    ~BinaryReads();

};



class KmersBuffer
{

    char * buffer;
    int cpt_buffer;
    int blocksize_toread;

    unsigned int  read_write_buffer_size;
     int cpt_binSeq_read;
     int binSeq_toread;

    public:
    int max_read_length;
    BinaryReads * binfile;
    FILE * binary_read_file;
    int nkmers; //number of kmers in the buffer
    int nseq_step;
    int buffer_size;
    kmer_type * kmers_buffer; 
    KmersBuffer(BinaryReads *bfile, int  pbuffer_size, int nseq_task );
    int readkmers();
    char * binSeq;// [MAX_READ_LENGTH];
    char * binSeq_extended;//[MAX_READ_LENGTH];
    void reset_max_readlen(int read_length);

    ~KmersBuffer();
};

void  compute_kmer_table_from_one_seq(int readlen, char * seq, kmer_type * kmer_table )  ;

#endif
