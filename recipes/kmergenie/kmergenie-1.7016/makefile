SVNREV = -DSVN_REV=1.7016
PROGNAME=specialk
LDFLAGS+= -lz $(SVNREV)
SRC=minia/Pool.cpp minia/Bank.cpp minia/Hash16.cpp minia/Bloom.cpp minia/Kmer.cpp minia/Utils.cpp minia/LinearCounter.cpp minia/LargeInt.cpp minia/MultiConsumer.cpp minia/Hashing.cpp
OBJ= $(SRC:.cpp=.o)
all: $(PROGNAME)

CXXFLAGS ?= -O4
CXXFLAGS += -pthread 

DESTDIR ?=
PREFIX ?= /usr/local

ifeq ($(prof),1)
 CXXFLAGS+=-pg
endif
ifeq ($(deb),1)
 CXXFLAGS+=-O0 -DASSERTS -g 
# -fstack-check # stack overflow protection doesn't play nice with valgrind
endif

ifeq ($(osx),1)
 CXXFLAGS+= -DOSX=1
endif


ifdef k
 KMER_SIZE := $(k)
else
 KMER_SIZE := 121
endif

PYTHONOK=$(shell python -c 'import sys; print sys.hexversion>=0x02050000')

ifneq ($(PYTHONOK),True)
$(error Bad Python version. Please make sure the 'python' command is aliased to Python version greater >= 2.5.)
endif

K_BELOW_32 := $(shell echo print \( 1 if $(KMER_SIZE) \<= 32 else 0 \) | python -s)
K_BELOW_64 := $(shell echo print \( 1 if $(KMER_SIZE) \<= 64 else 0 \) | python -s)
ARCH := $(shell getconf LONG_BIT) # detects sizeof(int)
USING_UINT128 := 0
largeintlib := 0

ifeq ($(K_BELOW_32),0)

    # use uint128 when 32<k<=64 and 64-bit architecture
    ifeq ($(K_BELOW_64),1)
        ifeq ($(strip $(ARCH)),64)
            CXXFLAGS += -Dkmer_type=__uint128_t
            USING_UINT128 := 1
        endif
    endif
    
    # use a bigint library otherwise
    ifeq ($(USING_UINT128),0)
        largeintlib := largeint#ttmath
    endif
endif

# ttmath (now, largeint) is used when you type "make k=[kmer size]" with a kmer size longer than supported integer type,
ifeq ($(largeintlib),ttmath)
	KMER_PRECISION := $(shell echo print \( \($(KMER_SIZE)+15\)//16 \) | python -s)
endif
ifeq ($(largeintlib),largeint)
	KMER_PRECISION := $(shell echo print \( \($(KMER_SIZE)+31\)//32 \) | python -s)
endif

ifneq ($(largeintlib),0)
    CXXFLAGS += -D_$(largeintlib) -DKMER_PRECISION=$(KMER_PRECISION)
endif

all: $(PROGNAME) check 

$(PROGNAME): $(OBJ) main.cpp
	$(CXX) -o $@ $(OBJ) main.cpp $(CXXFLAGS) $(LDFLAGS)

%.o: %.cpp %.h
	$(CXX) -o $@ -c $< $(CXXFLAGS)


%.o: %.c %.h 
	$(CXX) -o $@ -c $< $(CXXFLAGS)
    
clean:
	rm -rf *.o minia/*.o

check: $(PROGNAME) 
	scripts/test_install

test: check

install:
	rm -f $(DESTDIR)$(PREFIX)/bin/kmergenie && ln -s `pwd`/kmergenie $(DESTDIR)$(PREFIX)/bin 
	@echo "Kmergenie is installed, via a symlink to $(DESTDIR)$(PREFIX)/bin (do not delete the contents of `pwd`)"
