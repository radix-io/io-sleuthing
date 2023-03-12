#!/bin/bash -l
#PBS -A CSC250STDM12
#PBS -k doe
#PBS -l walltime=20:00
#PBS -l filesystems=home:grand
#PBS -l select=8
#PBS -l place=scatter

#PBS -N ior
# export all variables to this script
#PBS -V

set -ueo pipefail

#module swap PrgEnv-intel PrgEnv-gnu

cd ${PBS_O_WORKDIR}
NNODES=`wc -l < $PBS_NODEFILE`
# Testing I/O performance, not trying to mimmic an application.  Only need a
# few clients to saturate the link
NRANKS_PER_NODE=4
NDEPTH=1
NTHREADS=1
NTOTRANKS=$(( NNODES * NRANKS_PER_NODE ))

IOR=${HOME}/soft/cray/ior-4.0.0rc1
PATH=${IOR}/bin:${PATH}
OUTPUT=/grand/radix-io/scratch/$USER/ior

# for comparison, one file-per-process (-F), not-striped run.  should represent
# fastest reads and writes (even if not ideal for subsequent use)
export IOR_HINT__MPI__striping_factor=1
# -a MPIIO: using MPI-IO so we can pass the "striping_factor" hint
# -e      : fsync after each write phase: push out dirty data to storage
# -C      : reorder ranks: read from a different rank than the one that wrote
# -s      : segments: each client will write to eight regions
# -i      : repeat experiment five times: lots of variability in I/O
# -t      : transfer size: how big each request will be
# -b      : block size:  how big each region will be in the file (needs to be a multiple of transfer size)

mpiexec -n ${NTOTRANKS} --ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth \
        ior --mpiio.showHints -a MPIIO \
	-F \
	-e -C -s 8 -i 5 \
	-t 1MiB -b 64MiB -o ${OUTPUT}/ior-fpp-nostripe.out
