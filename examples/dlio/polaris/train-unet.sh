#!/bin/bash -l
#PBS -A CSC250STDM12
#PBS -k doe
#PBS -l walltime=00:10:00
#PBS -l filesystems=home:grand
#PBS -l select=4
#PBS -l place=scatter
#PBS -N dlio-train
# export all variables to this script
#PBS -V

cd ${PBS_O_WORKDIR}
NNODES=`wc -l < $PBS_NODEFILE`
NRANKS_PER_NODE=8
NDEPTH=1
NTHREADS=1
NTOTRANKS=$(( NNODES * NRANKS_PER_NODE ))

export DARSHAN_LOG_DIR_PATH=`pwd`
export LD_PRELOAD=${DARSHAN_RUNTIME_ROOT}/lib/libdarshan.so
# We don't need to profile Python loading modules, so we've set up a config
# file to only look at our training data
export DARSHAN_CONFIG_PATH=`pwd`/darshan-dlio.cfg
export DARSHAN_ENABLE_NONMPI=1

source ./dlio-environment.sh

mpiexec -np ${NTOTRANKS} python ${DLIO}/src/dlio_benchmark.py workload=unet3d \
	++workload.workflow.generate_data=False \
	++workload.dataset.data_folder=/grand/radix-io/scratch/robl/dlio/data/unet3d/ \
	++workload.checkpoint.checkpoint_folder=/grand/radix-io/scratch/robl/dlio/data/unet3d/ \
	++workload.workflow.train=True \
	++workload.workflow.evaluation=True\
	++workload.dataset.num_files_train=64 \
	++workload.train.epochs=5

