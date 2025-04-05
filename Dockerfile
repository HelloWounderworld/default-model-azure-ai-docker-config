# Usa a imagem oficial da NVIDIA com CUDA e cuDNN
FROM nvidia/cuda:12.2.2-devel-ubuntu22.04

# Instala pacotes necessários
RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Define o ambiente correto para CUDA
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# Instala pacotes Python para testar GPU
RUN pip3 install --upgrade pip && \
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Copia e executa um script de teste da GPU
COPY test_gpu.py /test_gpu.py
CMD ["python3", "/test_gpu.py"]
