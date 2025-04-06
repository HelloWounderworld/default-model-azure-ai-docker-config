import torch

if torch.cuda.is_available():
    print("✅ GPU disponível!")
    print(f"Nome da GPU: {torch.cuda.get_device_name(0)}")
    print(f"Quantidade de GPUs disponíveis: {torch.cuda.device_count()}")
    print(f"Memória total da GPU: {torch.cuda.get_device_properties(0).total_memory / 1e9:.2f} GB")
else:
    print("❌ GPU não detectada!")