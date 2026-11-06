## To run:
```apptainer exec --userns --cleanenv --nv \
  --bind "$PWD:/workspace/vllm" \
  --pwd /workspace/vllm \
  --env PREPEND_PATH=/workspace/vllm/.venv/bin \
  build/vllm.sif \
  /workspace/vllm/.venv/bin/python examples/basic/offline_inference/basic.py```