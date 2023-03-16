CC=cc
CFLAGS=-Wall -g
# if you installed pnetcdf yourself instead of through something like modules
# or spack, you'll need to set this to your install prefix
PNETCDF=/usr
CPPFLAGS=-I$(PNETCDF)/include

LDFLAGS=-L$(PNETCDF)/lib
LDLIBS=-lpnetcdf

all: pnetcdf-write pnetcdf-write-nb

pnetcdf-write: pnetcdf-write.o
pnetcdf-write-nb: pnetcdf-write.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -DPNETCDF_NON_BLOCKING $^ -o $@ $(LDLIBS)

clean:
	rm -f *.nc *.o pnetcdf-write pnetcdf-write-nb

