#!/bin/bash

# IOR emits a "summary of all tests" after it exits.  Since we ran several
# instances of IOR, we need to massage the output file just a bit before we can
# plot it

echo "#Operation   Max(MiB)   Min(MiB)  Mean(MiB)     StdDev   Max(OPs)   Min(OPs)  Mean(OPs)     StdDev    Mean(s) Stonewall(s) Stonewall(MiB) Test# #Tasks tPN reps fPP reord reordoff reordrand seed segcnt   blksiz    xsize aggs(MiB)   API RefNum" > ior-write.dat
grep MPIIO $1 | grep write >> ior-write.dat

echo "#Operation   Max(MiB)   Min(MiB)  Mean(MiB)     StdDev   Max(OPs)   Min(OPs)  Mean(OPs)     StdDev    Mean(s) Stonewall(s) Stonewall(MiB) Test# #Tasks tPN reps fPP reord reordoff reordrand seed segcnt   blksiz    xsize aggs(MiB)   API RefNum" > ior-read.dat
grep MPIIO $1 | grep read  >> ior-read.dat
