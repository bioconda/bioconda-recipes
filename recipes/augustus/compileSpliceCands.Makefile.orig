compileSpliceCands : compileSpliceCands.o list.h list.o
	gcc $(LDFLAGS) -o compileSpliceCands compileSpliceCands.o list.o;
#	cp compileSpliceCands ../../bin
compileSpliceCands.o : compileSpliceCands.c 
	gcc -Wall -pedantic -ansi $(CPPFLAGS) -c compileSpliceCands.c 

all : compileSpliceCands

clean : 
	rm -f compileSpliceCands compileSpliceCands.o ../../bin/compileSpliceCands list.o
