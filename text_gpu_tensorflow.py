import tensorflow as tf
from tensorflow.python.client import device_lib

# Verifica se há GPUs disponíveis
gpus = tf.config.list_physical_devices('GPU')

if gpus:
    print(f"GPUs disponíveis: {gpus}")
else:
    print("Nenhuma GPU disponível.")

# Lista todos os dispositivos disponíveis
print(device_lib.list_local_devices())