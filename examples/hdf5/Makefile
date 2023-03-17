# change these three according to your environment, or load apropriate
# modules(1)
HDF5=/usr
MPICC=cc

CC=cc
CPPFLAGS=-I${HDF5}/include
LDFLAGS=-L${HDF5}/lib

all: h5par-comparison

h5par-comparison:  h5par-comparison.c
	$(MPICC) $(CFLAGS) $(CPPFLAGS) $^ -o $@ $(LDFLAGS) -lhdf5
	$(MPICC) $(CFLAGS) $(CPPFLAGS) -DUSE_COLL_DATA $^ -o h5par-comparison-collio $(LDFLAGS) -lhdf5
	$(MPICC) $(CFLAGS) $(CPPFLAGS) -DUSE_COLL_DATA -DUSE_COLL_MD $^ -o h5par-comparison-collmd $(LDFLAGS) -lhdf5

clean:
	rm -f *.o *.rtf *.nc *.h5 $(PROGRAMS)
