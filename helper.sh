#!/bin/bash
module load LUMI/24.03 partition/G cpeGNU/24.03 cray-fftw rocm/6.2.2

OUTDIR="$1"
shift
BINARY=("$@")
RANK="${OMPI_COMM_WORLD_RANK:-${MV2_COMM_WORLD_RANK:-${SLURM_PROCID:-0}}}"
echo "OMPI_COMM_WORLD_RANK='${RANK}'"

if [[ "$RANK" == "0" ]]; then
    echo "Running rocprof on rank $RANK"
    rocprof \
        --roctx-trace \
        --hip-trace \
        -d "$OUTDIR" \
        -o "$OUTDIR/results.csv" \
        ./helper2.sh "$BINARY"
    mv -- "out-${SLURM_JOB_ID}"* "$OUTDIR" 2>/dev/null || true
else
    ./helper2.sh "$BINARY"
fi
