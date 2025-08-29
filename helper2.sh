#!/bin/bash
set -euo pipefail

export TRACE_ALL_EVENTS=yes

LD_PRELOAD=/projappl/project_462000949/lumi-po-benchmark/mpitrace/roctx/libmpitrace-legacy.so "$@"
