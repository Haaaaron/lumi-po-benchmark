#!/bin/bash -l
#SBATCH --job-name memory-bound-mpitrace
#SBATCH -o ./slurm_output/output_%j.txt
#SBATCH -e ./slurm_errors/errors_%j.txt
#SBATCH --account=project_462000949

# # ## Test run
#SBATCH --partition=dev-g
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --time 0:30:00

#Small run
# #SBATCH --partition=small-g
# #SBATCH --nodes=1
# #SBATCH --ntasks=8
# #SBATCH --ntasks-per-node=8
# #SBATCH --gpus-per-node=8
# #SBATCH --time 12:00:00
# #SBATCH --mem=0

#Standard run
# #SBATCH --partition=standard-g
# #SBATCH --nodes=1
# #SBATCH --ntasks=8
# #SBATCH --ntasks-per-node=8
# #SBATCH --gpus-per-node=8
# #SBATCH --time 00:30:00
# #SBATCH --mem=0

module load LUMI/24.03 partition/G cpeGNU/24.03  cray-fftw rocm/6.2.2
module use /pfs/lustrep2/projappl/project_462000125/samantao-public/mymodules
module load omniperf
module load cray-python/3.11.7
#module load CrayEnv PrgEnv-cray craype-accel-amd-gfx90a cray-mpich rocm/6.0.3 cray-fftw/3.3.10.7
#module load LUMI/24.03 partition/G  craype-accel-amd-gfx90a PrgEnv-amd cray-fftw rocm/6.2.2 

export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID
export MPICH_GPU_SUPPORT_ENABLED=1
#export NCCL_NCHANNELS_PER_PEER=32
export HSA_ENABLE_SDMA=0
export MPICH_ASYNC_PROGRESS=1
export MPICH_GPU_IPC_ENABLED=
export MPICH_GPU_IPC_THRESHOLD
export FI_CXI_RDZV_THRESHOLD
export MPICH_OFI_CXI_COUNTER_REPORT=3
#export FI_CXI_DEFAULT_CQ_SIZE=131072
#export FI_CXI_DEFAULT_TX_SIZE=32768
#export FI_CXI_RX_MATCH_MODE=software
#export FI_MR_CACHE_MONITOR=userfaultfd

BINARY="./benchmarks/memory-bound/build/suN_gauge"
BENCH_TYPE="mb"
NUM_TASKS="${SLURM_NTASKS:-1}"
NUM_NODES="${SLURM_NNODES:-1}"
NUM_GPUS="${SLURM_GPUS_PER_NODE:-0}"
mkdir -p res_omn
OUTDIR="res_omn/${BENCH_TYPE}_n_${NUM_NODES}_t_${NUM_TASKS}_g_${NUM_GPUS}_${SLURM_JOB_ID:-nojobid}"
mkdir -p "$OUTDIR"

# GPUSID="4 5 2 3 6 7 0 1"
# GPUSID=(${GPUSID})
# if [ ${#GPUSID[@]} -gt 0 -a -n "${SLURM_NTASKS_PER_NODE}" ]; then
#     export ROCR_VISIBLE_DEVICES=${GPUSID[$((SLURM_LOCALID / ($SLURM_NTASKS_PER_NODE / ${#GPUSID[@]})))]}
# fi

srun omniperf profile -n $OUTDIR -- $BINARY  >> out-$SLURM_JOB_ID.txt

mv -- *"${SLURM_JOB_ID}"* "$OUTDIR" 2>/dev/null || true
