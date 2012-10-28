CFLAGS += -Wall -std=c99 -O2 -g

all: test_gpmc test_bench_read copy pulse

copy: setpixel gestionled
	cp setpixel /bin/
	cp gestionled /bin/

test_gpmc: test_gpmc.o roseace_gpmc.o roseace_utilities.o
test_bench_read: test_bench_read.o roseace_gpmc.o roseace_utilities.o
setpixel: setpixel.o roseace_gpmc.o roseace_utilities.o
gestionled: gestionled.o roseace_gpmc.o roseace_utilities.o
pulse: pulse.o roseace_gpmc.o roseace_utilities.o

test_gpmc.o: test_gpmc.c roseace_gpmc.h roseace_utilities.h
test_bench_read.o: test_bench_read.c roseace_gpmc.h roseace_utilities.h
setpixel.o: setpixel.c roseace_gpmc.h roseace_utilities.h
gestionled.o: gestionled.c roseace_gpmc.h roseace_utilities.h
pulse.o: pulse.c roseace_gpmc.h roseace_utilities.h

clean:
	-rm -f *.o test_gpmc test_bench_read setpixel gestionled *~ *#
