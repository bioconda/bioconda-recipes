#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <string.h>
#include <vector>
#include <pthread.h>

#ifndef MultiConsumer_H 
#define MultiConsumer_H

using namespace std;

#define NB_PACKETS 5

#define MAX_NUCL_IN_PACKET 10000000

template<typename Task>
class MultiConsumer
{
    Task *buffer[NB_PACKETS];

    int maxSizeBuffer;

    pthread_mutex_t *mutex;
    pthread_mutex_t *mutex2;

    pthread_cond_t *notFull;
    pthread_cond_t *notEmpty;

    bool allDone;

    public:
    int sizeBuffer;
    MultiConsumer(); 
    void produce(Task *task);
    Task *consume();

    void setAllDone();
    bool isAllDone();
};

// a producer that group reads

struct reads_packet
{
    vector<string> reads;
};

class MultiReads
{
    protected:    
    reads_packet *current_packet;
    int packetOffset;
    int nbRead;
    int nbNucleotides;
    int thread_id;

    void new_packet();

    public:
    MultiConsumer<reads_packet> *mc;

    MultiReads(int thread_id);
    void produce(char *read, int readlen);
    void setAllDone();
};

// a consumer for the above producer

class MultiReadsConsumer
{
    reads_packet *current_packet;
    int packetOffset;
    int nbRead;
    int thread_id;

    bool has_packet;
    MultiConsumer<reads_packet> *mc;

    public:
    MultiReadsConsumer(MultiReads m, int thread_id) : has_packet(false), mc(m.mc), current_packet(NULL), thread_id(thread_id) {}
    bool is_finished_packet();
    void consume(char* &read, int &readlen);
};

#endif
