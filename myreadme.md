# To build
`bash build_apptainer.sh`

## To run:
At `examples/basic/offline_inference/basic.py` see:
``` 
LOCAL_DIR = os.path.abspath("/share/bigyang/local")
os.environ["HF_HOME"] = LOCAL_DIR
os.environ["TRANSFORMERS_OFFLINE"] = "1"
os.environ["HF_DATASETS_OFFLINE"] = "1"
```
So, set `LOCAL_DIR` wherever the model is downloaded/or you want to download.

```apptainer exec --userns --cleanenv --nv \
  --bind "$PWD:/workspace/vllm" \
  --pwd /workspace/vllm \
  --env PREPEND_PATH=/workspace/vllm/.venv/bin \
  build/vllm.sif \
  /workspace/vllm/.venv/bin/python examples/basic/offline_inference/basic.py```