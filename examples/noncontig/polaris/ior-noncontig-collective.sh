#!/bin/bash -l
#PBS -A CSC250STDM12
#PBS -k doe
#PBS -l walltime=20:00
#PBS -l filesystems=home:grand
#PBS -l select=2
#PBS -l place=scatter

#PBS -N ior
# export all variables to this script
#PBS -V

set -ueo pipefail

#module swap PrgEnv-intel PrgEnv-gnu

cd ${PBS_O_WORKDIR}
NNODES=`wc -l < $PBS_NODEFILE`
NRANKS_PER_NODE=32
NDEPTH=1
NTHREADS=1
NTOTRANKS=$(( NNODES * NRANKS_PER_NODE ))

IOR=${HOME}/soft/cray/ior-4.0.0rc1
PATH=${IOR}/bin:${PATH}
OUTPUT=/grand/radix-io/scratch/$USER/ior

# darshan gives us helpful insights:
module list
export DARSHAN_LOG_DIR_PATH=`pwd`
export LD_PRELOAD=$DARSHAN_RUNTIME_ROOT/lib/libdarshan.so

# demonstrate the impact of collective I/O optimizations


export  MPICH_MPIIO_TIMERS=1
export  MPICH_MPIIO_STATS=1

# We could show how performance varies with degree of non-contiguous-ness, as
# below (from theta, hence 'aprun')
#for segs in 1 100 1000 5000 10000; do
#   aprun -N 48 -n $((48*4)) \
#      ior --mpiio.showHints  -a MPIIO -c -w \
#           --mpiio.useFileView --mpiio.useStridedDatatype -b $((10000000/$segs)) -t $((10000000/$segs)) -s $segs \
#           -o ${OUTPUT}/ior-noncontig-coll-$segs.out
#done

# instead, I think focusing on one noncontiguous workload, then trying a bunch of tuning
segs=1000
# first, default independent MPI-IO operations
rm -f ${OUTPUT}/ior-noncontig-indep-$segs.out
mpiexec -n ${NTOTRANKS} --ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth ior --mpiio.showHints -a MPIIO -w \
	--mpiio.useFileView --mpiio.useStridedDatatype -b $((10000000/$segs)) -t $((10000000/$segs)) -s $segs \
	-i 5 \
	-o ${OUTPUT}/ior-noncontig-indep-$segs.out

# then, disable data sieving
export IOR_HINT__MPI__romio_ds_write="disable"
export IOR_HINT__MPI__romio_ds_read="disable"
rm -f ${OUTPUT}/ior-noncontig-indep-nods-$segs.out
mpiexec -n ${NTOTRANKS} --ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth ior --mpiio.showHints -a MPIIO -w \
	--mpiio.useFileView --mpiio.useStridedDatatype -b $((10000000/$segs)) -t $((10000000/$segs)) -s $segs \
	-i 5 \
	-o ${OUTPUT}/ior-noncontig-indep-nods-$segs.out

# third test: turn on collective I/O
unset IOR_HINT__MPI__romio_ds_write
unset IOR_HINT__MPI__romio_ds_read
rm -f ${OUTPUT}/ior-noncontig-coll-$segs.out
mpiexec -n ${NTOTRANKS} --ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth ior --mpiio.showHints -a MPIIO -w \
        --collective \
	--mpiio.useFileView --mpiio.useStridedDatatype -b $((10000000/$segs)) -t $((10000000/$segs)) -s $segs \
	-i 5 \
	-o ${OUTPUT}/ior-noncontig-coll-$segs.out

# fourth: try out Cray's Lockahead tuning:
# these Cray hints might have a big impact on collective I/O performance.  From
# intro_mpi man page:
#     cray_cb_write_lock_mode: Sets of non-overlapping extent locks are
#                              acquired ahead of time by all MPI ranks that are
#                              writing the file and the acquired locks are not
#                              expanded beyond the size requested by the ranks
#     cb_nodes_multiplier:     Specifies the number of collective buffering
#                              aggregators (cb_nodes) per OST for Lustre files.
#                              In other words, the number of aggregators is the
#                              stripe count (striping_factor) times the
#                              multiplier.   When the locking mode is 1 or 2, a
#                              multiplier of 2 or more is usually best for
#                              writing the file
export  IOR_HINT__MPI__cray_cb_write_lock_mode=2
export  IOR_HINT__MPI__cb_nodes_multiplier=2
export  IOR_HINT__MPI__striping_factor=${NTOTRANKS}
rm -f ${OUTPUT}/ior-noncontig-coll-mode2-$segs.out
mpiexec -n ${NTOTRANKS} --ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth ior --mpiio.showHints -a MPIIO -w \
        --collective \
	--mpiio.useFileView --mpiio.useStridedDatatype -b $((10000000/$segs)) -t $((10000000/$segs)) -s $segs \
	-i 5 \
	-o ${OUTPUT}/ior-noncontig-coll-mode2-$segs.out
