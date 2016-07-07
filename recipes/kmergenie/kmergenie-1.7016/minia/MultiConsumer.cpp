#include "MultiConsumer.h"

template<typename Task>
MultiConsumer<Task>::MultiConsumer() : sizeBuffer(0), maxSizeBuffer(NB_PACKETS), allDone(false)
{
    mutex = new pthread_mutex_t;
    mutex2 = new pthread_mutex_t;
    pthread_mutex_init(mutex, NULL);
    pthread_mutex_init(mutex2, NULL);

    notFull = new pthread_cond_t;
    notEmpty = new pthread_cond_t;
    pthread_cond_init(notFull, NULL);
    pthread_cond_init(notEmpty, NULL);

}

template<typename Task>
void MultiConsumer<Task>::produce(Task *task) {
  
  pthread_mutex_lock(mutex);
  while (sizeBuffer == maxSizeBuffer) {
    pthread_cond_wait(notFull, mutex);
  }
  
  buffer[sizeBuffer++] = task;

  pthread_cond_signal(notEmpty);
  
  pthread_mutex_unlock(mutex);  
}

template<typename Task>
Task *MultiConsumer<Task>::consume() {
  
  Task *task;
  pthread_mutex_lock(mutex);
  
  while (sizeBuffer == 0) {
    
    if (isAllDone()) {
      pthread_mutex_unlock(mutex);
      return NULL;
    }
   
    pthread_cond_wait(notEmpty, mutex);
  }
  
  task = buffer[--sizeBuffer];
  
  pthread_cond_signal(notFull);
 
  pthread_mutex_unlock(mutex);
  
  return task;
}

template<typename Task>
void MultiConsumer<Task>::setAllDone() {
  pthread_mutex_lock(mutex2);
  allDone = true; 
  pthread_cond_signal(notEmpty);
  pthread_mutex_unlock(mutex2);  
}

template<typename Task>
bool MultiConsumer<Task>::isAllDone() {
  bool res;
  pthread_mutex_lock(mutex2);
  res = allDone;
  pthread_mutex_unlock(mutex2);
  return res;
}


// wrapper around MultiConsumer to bundle 10 MB of reads together

MultiReads::MultiReads(int thread_id) : thread_id(thread_id) 
{
    mc = new MultiConsumer<reads_packet>();
    new_packet();
}

void MultiReads::new_packet()
{
    current_packet = new reads_packet;
    nbRead = 0;
    nbNucleotides = 0;
}

void MultiReads::produce(char *read, int readlen) {
    if (nbRead > 0 && nbNucleotides > MAX_NUCL_IN_PACKET)
    {
        mc->produce(current_packet);
        //printf("%d - produced (%d in stack)\n", thread_id, mc->sizeBuffer); 
        new_packet();
    }

    current_packet->reads.push_back(read);
    nbRead++;
    nbNucleotides += readlen;
}

void MultiReads::setAllDone() {
    if (nbRead > 0) // produce that last packet
    {
        mc->produce(current_packet);
    }
    mc->setAllDone();
}

bool MultiReadsConsumer::is_finished_packet()
{
    return nbRead == current_packet->reads.size();
}

void MultiReadsConsumer::consume(char* &read, int &readlen)
{
    if (!has_packet || is_finished_packet())
    {
        if (current_packet != NULL)
        {
            delete current_packet;
        }

        //printf("%d - attempting to consume (%d remaining)\n", thread_id, mc->sizeBuffer); 
        current_packet = mc->consume();
        //printf("%d - consumed (%d remaining)\n", thread_id, mc->sizeBuffer); 

        nbRead = 0;
        has_packet = true;

        if (current_packet == NULL) // no more reads, all done
        {
            readlen = 0;
            return;
        }
    }

    readlen = current_packet->reads[nbRead].length();
    read = (char *)current_packet->reads[nbRead].c_str();

    nbRead++;    
}
