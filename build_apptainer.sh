#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BUILD_ROOT=${VLLM_BUILD_ROOT:-"$REPO_ROOT/build"}
STORAGE_ROOT=${VLLM_STORAGE_ROOT:-/share/bigyang}
mkdir -p "$BUILD_ROOT" "$STORAGE_ROOT/tmp" "$STORAGE_ROOT/cache" "$STORAGE_ROOT/uv-cache"
BUILD_ROOT=$(cd "$BUILD_ROOT" && pwd)
STORAGE_ROOT=$(cd "$STORAGE_ROOT" && pwd)
export APPTAINER_TMPDIR="$STORAGE_ROOT/tmp"
export APPTAINER_CACHEDIR="$STORAGE_ROOT/cache"
export TMPDIR="$APPTAINER_TMPDIR"

if [ "${1:-}" != "--install-only" ]; then
    apptainer build "$BUILD_ROOT/vllm.sif" "$REPO_ROOT/vllm.def"
fi

# Installation runs on the internet-connected node and does not need a GPU.
apptainer exec --userns --cleanenv --nv \
  --bind "$PWD:/workspace/vllm" \
  --bind "/share/bigyang:/share/bigyang" \
  --pwd /workspace/vllm build/vllm.sif bash -e -c '
        uv venv --python 3.12 --seed --managed-python
        source .venv/bin/activate
        uv pip install numpy setuptools wheel
        export UV_CACHE_DIR=/share/bigyang/tmp
        export TMPDIR=/share/bigyang/tmp
        export VLLM_PRECOMPILED_WHEEL_LOCATION="https://github.com/vllm-project/vllm/releases/download/v0.30.0/vllm-0.30.0+cu129-cp38-abi3-manylinux_2_28_$(uname -m).whl"
        # Match both wheel variants to the CUDA 13.0 container, without GPU detection.
        VLLM_USE_PRECOMPILED=1 uv pip install --editable . --torch-backend=cu129
    '

# echo "Ready: $BUILD_ROOT/vllm.sif and $REPO_ROOT/.venv"
# echo "Run on the GPU node with --nv and the same /workspace/vllm bind path."
