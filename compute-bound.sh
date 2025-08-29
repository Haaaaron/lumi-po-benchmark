#!/bin/bash -l
#SBATCH --job-name compute-bound-mpitrace
#SBATCH -o ./slurm_output/output_%j.txt
#SBATCH -e ./slurm_errors/errors_%j.txt
#SBATCH --account=project_462000949

# # ## Test run
#SBATCH --partition=dev-g
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=2
#SBATCH --gpus-per-node=2
#SBATCH --time 0:15:00

#Small run
# #SBATCH --partition=small-g
# #SBATCH --nodes=1
# #SBATCH --ntasks=8
# #SBATCH --ntasks-per-node=8
# #SBATCH --gpus-per-node=8
# #SBATCH --time 12:00:00
# #SBATCH --mem=0
module load LUMI/24.03 partition/G cpeGNU/24.03  cray-fftw rocm/6.2.2
module use /pfs/lustrep2/projappl/project_462000125/samantao-public/mymodules
module use cray-python/3.11.7
#module load CrayEnv PrgEnv-cray craype-accel-amd-gfx90a cray-mpich rocm/6.0.3 cray-fftw/3.3.10.7
#module load LUMI/24.03 partition/G  craype-accel-amd-gfx90a PrgEnv-amd cray-fftw rocm/6.2.2 

export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID
export MPICH_GPU_SUPPORT_ENABLED=1
#export NCCL_NCHANNELS_PER_PEER=32
export HSA_ENABLE_SDMA=0

BINARY="./benchmarks/compute-bound/build/suN_gauge"
BENCH_TYPE=$(basename "$(dirname "$(dirname "$BINARY")")")
NUM_TASKS="${SLURM_NTASKS:-1}"
NUM_NODES="${SLURM_NNODES:-1}"
NUM_GPUS="${SLURM_GPUS_PER_NODE:-0}"
mkdir -p results
OUTDIR="results/${BENCH_TYPE}-n-${NUM_NODES}-t-${NUM_TASKS}-g-${NUM_GPUS}-${SLURM_JOB_ID:-nojobid}"
mkdir -p "$OUTDIR"

srun ./helper.sh $OUTDIR $BINARY  >> out-$SLURM_JOB_ID.txt

mv -- *"${SLURM_JOB_ID}"* "$OUTDIR" 2>/dev/null || true

