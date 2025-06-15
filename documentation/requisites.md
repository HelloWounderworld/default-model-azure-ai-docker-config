# Requisitos a serem atendidos antes de trabalhar com contêineres Docker e Azure

## Pré-requisitos

Antes de começar, verifique o seguinte:

- Você possui uma conta Azure e acesso a uma VM com GPU.
- O Docker está instalado na Máquina Virtual.
- Docker compatível com NVIDIA:
  - O NVIDIA Container Toolkit está instalado (Guia de instalação).
  - O driver da GPU está atualizado.

Aqui estão as etapas detalhadas para atender a todos os pré-requisitos listados.

## 1. Criar uma conta Azure com acesso a uma VM com GPU

### Criar uma conta Azure:
- Acesse [portal.azure.com](https://portal.azure.com).
- Clique em "Criar conta" (se ainda não tiver uma conta). Complete o processo de registro.

### Configurar uma máquina virtual com GPU:
- No portal Azure, vá para "Máquinas Virtuais" e clique em "Criar máquina virtual".
- Selecione uma região compatível com GPU (ex: East US, West Europe).
- Defina o tipo de segurança como Padrão.
- Escolha um tamanho de VM com GPU, como a série NC (NVIDIA Tesla K80/V100) ou ND (para aprendizado profundo).
- Complete a configuração da VM e gere uma chave SSH. (Durante o processo, você será solicitado a baixar um arquivo .pem, que é importante para acessar a VM a partir da máquina local.)
- Se estiver usando Windows, use uma distribuição Linux no WSL ou dentro do contêiner Docker. Envie o arquivo .pem para a pasta .ssh e renomeie-o para "id_rsa.pem".
- Em seguida, use o comando `chmod 400 ~/.ssh/id_rsa.pem` para definir as permissões.
- Depois, use o comando `ssh -i ~/.ssh/id_rsa.pem <username>@<ip_address>`.
- Se você conseguir acessar a VM a partir da máquina local, o processo está concluído.

## 2. Instalar o Docker na Máquina Virtual

### Instalação do Docker em Ubuntu/Debian:
- [Instale o Docker Engine.](https://docs.docker.com/engine/install/ubuntu/)

## 3. Configurar o Docker com suporte a NVIDIA

### Antes de começar a instalação, verifique o que já está instalado:
- O NVIDIA Container Toolkit adiciona suporte ao runtime NVIDIA no Docker. Para verificar se está configurado, execute o seguinte comando:
  ```bash
  docker info | grep "Runtimes"
  ```
- Se o runtime NVIDIA estiver instalado, você verá:
  ```
  Runtimes: nvidia runc
  ```

- Se "nvidia" não estiver na lista, o toolkit pode não estar instalado.

### Outra forma de verificar:
- Execute o comando:
  ```bash
  nvidia-smi
  ```
- Isso confirmará se o driver está instalado na Máquina Virtual, o que é necessário para o NVIDIA Container Toolkit.

### Se o driver estiver instalado, você verá uma saída semelhante a:
```
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 560.41                 Driver Version: 561.03         CUDA Version: 12.6     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4050 ...    On  |   00000000:01:00.0 Off |                  N/A |
| N/A   27C    P0            590W /  125W |       0MiB /   6141MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```

### Para instalar o driver NVIDIA via linha de comando em Ubuntu, caso não for exibido nada em nvidia-smi ([Guia de instalação](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/index.html)):
1. Primeiro, instale o "ubuntu-driver":
   ```bash
   sudo apt update
   sudo apt upgrade -y
   sudo apt-get install ubuntu-drivers-common
   sudo apt-get install alsa-utils
   ```

2. Em seguida, visualize a lista de drivers:
   ```bash
   sudo ubuntu-drivers list
   ```
   ou
   ```bash
   sudo ubuntu-drivers devices
   ```

3. Se você ver uma saída semelhante a esta, a instalação foi bem-sucedida:
   ```
   == /sys/devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0004:00/VMBUS:00/47505500-0001-0000-3130-444531454238/pci0001:00/0001:00:00.0 ==
   modalias : pci:v000010DEd00001EB8sv000010DEsd000012A2bc03sc02i00
   vendor   : NVIDIA Corporation
   model    : TU104GL [Tesla T4]
   driver   : nvidia-driver-470 - distro non-free
   driver   : nvidia-driver-535 - distro non-free recommended
   driver   : nvidia-driver-535-server - distro non-free
   driver   : nvidia-driver-570-server - distro non-free
   driver   : nvidia-driver-470-server - distro non-free
   driver   : xserver-xorg-video-nouveau - distro free builtin
   ```

4. Instale o driver (recomenda-se o driver marcado como recomendado):
   ```bash
   sudo apt install -y nvidia-driver-XXX
   ```

5. Após a instalação, reinicie:
   ```bash
   sudo reboot
   ```

6. Verifique se o driver foi instalado corretamente:
   ```bash
   nvidia-smi
   ```

### Atualização do driver NVIDIA:
- Identifique a GPU:
  ```bash
  nvidia-smi
  ```

- Baixe o driver apropriado do site oficial da NVIDIA.
- Siga as instruções de instalação para o seu sistema operacional.

### Instalar o NVIDIA Container Toolkit ([Guia de instalação](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)):
Para Ubuntu Linux, siga estas etapas:
1. Adicione o repositório NVIDIA:
   ```bash
   curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
   && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
   sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
   sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   ```

2. Instale o NVIDIA Container Toolkit:
   ```bash
   sudo apt-get update
   sudo apt-get install -y nvidia-container-toolkit
   sudo nvidia-ctk runtime configure --runtime=docker
   sudo systemctl restart docker
   ```

3. Execute um contêiner de teste que utiliza GPU para confirmar a instalação:
   ```bash
   docker info | grep "Runtimes"
   ```
   A confirmação da instalação deve ser:
   ```
   Runtimes: io.containerd.runc.v2 nvidia runc
   ```

## Resumo das etapas concluídas

Ao seguir estas etapas, você pode:
- Ter uma conta Azure com acesso a GPU.
- Ter o Docker instalado na sua máquina local.
- Ter suporte da NVIDIA configurado para uso com Docker.
