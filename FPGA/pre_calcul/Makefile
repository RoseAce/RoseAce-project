
SRC = pre_calcul.c
EXE = pre_calcul
OUTPUT = pre_calcul.lst
OPT = -Wall -O0 -lm -std=gnu99

all : $(SRC)
	gcc $(OPT) $(SRC) -o $(EXE)
	./$(EXE) $(OUTPUT)

clean :
	rm -f *~
	rm -f *.o
	rm -f $(EXE)
	rm -f $(OUTPUT)
	rm -f \#*

.PHONY : all clean
