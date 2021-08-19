CC = gcc 

CFLAGS = -Wall -D_GNU_SOURCE
LFLAGS = -lm

ifeq ($(mode), debug)
 CFLAGS += -g
else
 CFLAGS += -O3 -DNDEBUG # -march=native
ifeq ($(mode), profile)
 CFLAGS += -pg -g
endif
endif
ifeq ($(mode), parallel)
CFLAGS += -DPARALLEL -DPORTABLE_PTHREADS 
LFLAGS += -pthread 
endif
ifeq ($(mode), parallelDebug)
CFLAGS += -DPARALLEL -g
LFLAGS += -pthread 
endif

RM = rm -fr

TARGETS = RogueNaRok rnr-prune rnr-lsi  rnr-tii  rnr-mast 

all :  $(TARGETS)

rnr-objs = common.o RogueNaRok.o  Tree.o BitVector.o HashTable.o List.o Array.o  Dropset.o ProfileElem.o legacy.o newFunctions.o parallel.o Node.o
lsi-objs = rnr-lsi.o common.o Tree.o BitVector.o   HashTable.o legacy.o newFunctions.o List.o
tii-objs = rnr-tii.o common.o BitVector.o Tree.o HashTable.o List.o legacy.o newFunctions.o 
mast-objs = rnr-mast.o common.o List.o Tree.o BitVector.o HashTable.o legacy.o newFunctions.o
prune-objs = rnr-prune.o common.o Tree.o BitVector.o HashTable.o  legacy.o newFunctions.o List.o

rnr-lsi: $(lsi-objs)
	$(CC) $(CFLAGS) -o $@ $^ $(LFLAGS) 
rnr-tii: $(tii-objs)
	$(CC) $(CFLAGS)  -o $@ $^ $(LFLAGS) 
rnr-mast: $(mast-objs)
	$(CC) $(CFLAGS) -o $@ $^ $(LFLAGS) 
rnr-prune: $(prune-objs)
	$(CC) $(CFLAGS) -o $@ $^ $(LFLAGS) 

ifeq ($(mode),parallel)
RogueNaRok: $(rnr-objs)
	$(CC) $(CFLAGS) -o $@-parallel $^ $(LFLAGS) 
else
RogueNaRok: $(rnr-objs)
	$(CC) $(CFLAGS) -o $@ $^ $(LFLAGS) 
endif

%.o : %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

clean : 
	$(RM) $(rnr-objs) $(lsi-objs) $(tii-objs) $(mast-objs) $(prune-objs) $(TARGETS)  $(TESTS) $(rnr-test-objs) RogueNaRok-parallel

