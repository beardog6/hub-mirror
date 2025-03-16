# NAME: vllm:openai-gemma-3

# Base image with ROCm support
FROM vllm/vllm-openai:latest

WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y git curl && apt-get clean

# Clone vLLM repository
RUN git clone https://github.com/vllm-project/vllm.git
WORKDIR /workspace/vllm

# Upgrade pip and install AMD SMI utility
RUN pip install --upgrade pip 

# Install Python dependencies
RUN pip install --upgrade numba scipy huggingface-hub[cli,hf_transfer] setuptools_scm && \
    pip install "numpy<2" && \
    pip install -r requirements/cuda.txt

# Install specific Transformers version for Gemma 3 support
RUN pip install git+https://github.com/huggingface/transformers@v4.49.0-Gemma-3

# Set up GPU architecture and install vLLM
RUN VLLM_USE_PRECOMPILED=1 pip install --editable .

# Set working directory for when container starts
WORKDIR /workspace

# Default command when container starts
ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
