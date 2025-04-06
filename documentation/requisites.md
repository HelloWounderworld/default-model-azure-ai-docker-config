# **Requisitos que precisam serem satisfeitas antes de comercarmos a mexer com docker Container e Azure**

## **Pré-requisitos**
Antes de começar, certifique-se de que você tem:

1. **Conta no Azure** com acesso a um **VM com GPU** ou **Azure Machine Learning (AML)**.
2. **Instalado o Docker** na sua máquina local.
3. **Docker com suporte a NVIDIA**:
   - **NVIDIA Container Toolkit** instalado ([Guia de instalação](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)).
   - Driver da GPU atualizado.
4. **Azure CLI** instalado e configurado.

Aqui está uma explicação detalhada e passo a passo para atender a todos os pré-requisitos listados.

---

### **1. Conta no Azure com acesso a uma VM com GPU ou Azure Machine Learning (AML)**

1. **Criar uma conta na Azure**:
   - Acesse [portal.azure.com](https://portal.azure.com).
   - Clique em "Criar Conta" (caso ainda não tenha uma conta). Complete o processo de cadastro.

2. **Configurar uma máquina virtual com GPU**:
   - No portal da Azure, vá até **Máquinas Virtuais** e clique em "Criar Máquina Virtual".
   - Escolha uma região com suporte a GPUs (por exemplo, **East US**, **West Europe**).
   - Escolha um tamanho de VM com GPU, como as séries **NC** (NVIDIA Tesla K80/V100) ou **ND** (para aprendizado profundo).
   - Complete a configuração da VM e gere as chaves SSH.

3. **Alternativa: Configurar o Azure Machine Learning**:
   - No portal da Azure, procure por **Azure Machine Learning** e crie um workspace.
   - Configure um cluster de computação com GPUs para treinar modelos, se necessário.

### **2. Instalar o Docker na máquina local**

#### **Instalar Docker no Ubuntu/Debian**:
1. Atualize os pacotes:
   ```sh
   sudo apt-get update
   ```
2. Instale pacotes necessários:
   ```sh
   sudo apt-get install -y ca-certificates curl gnupg
   ```
3. Adicione o repositório Docker:
   ```sh
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```
4. Instale o Docker:
   ```sh
   sudo apt-get update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io
   ```
5. Verifique a instalação:
   ```sh
   docker --version
   ```

#### **Instalar Docker no Windows/Mac**:
1. Baixe o instalador em [docker.com](https://www.docker.com/products/docker-desktop/).
2. Siga as instruções para completar a instalação.
3. Verifique se o Docker Desktop está ativo.

#### **Referencias**

- [Instalacao do Docker Engine](https://docs.docker.com/engine/)

### **3. Configurar Docker com Suporte a NVIDIA**

#### **Antes de comecar com as instalacoes, verifique o que ja esta satisfeito**
O NVIDIA Container Toolkit adiciona o suporte ao **NVIDIA runtime** no Docker. Para verificar se ele está configurado, execute o comando abaixo:

```sh
docker info | grep "Runtimes"
```

Se o NVIDIA runtime estiver instalado, você verá algo como:

```
Runtimes: nvidia runc
```

Caso não veja "nvidia" listado, o toolkit provavelmente ainda não está instalado.

A outra laternativa seria voce realizar o seguinte

```sh
nvidia-smi
```

Assim, verificar se na sua maquina local, tem o driver instalado, pois isso seria necessario para o NVIDIA Container Toolkit.

Se, de fato, o driver estiver instalado localmente, na sua maquina, ela ira exibir algo do seguinte tipo abaixo:

```sh
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

#### **Atualizar o driver da GPU NVIDIA**
1. Identifique sua GPU:
   ```sh
   nvidia-smi
   ```
2. Baixe o driver apropriado no site oficial da [NVIDIA](https://www.nvidia.com/Download/index.aspx).
3. Siga as instruções de instalação para o seu sistema operacional.

#### **Instalar o NVIDIA Container Toolkit  ([Guia de instalação](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html))**
Para Linux Ubuntu, siga os passos abaixo:

1. Adicione o repositório NVIDIA:
   ```sh
   curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   ```
2. Instale o NVIDIA Container Toolkit:
   ```sh
   sudo apt-get update
   sudo apt-get install -y nvidia-container-toolkit
   sudo nvidia-ctk runtime configure --runtime=docker
   sudo systemctl restart docker
   ```
3. Verifique a instalação executando um contêiner de teste com GPU:
   ```sh
   docker info | grep "Runtimes"
   ```
   - A confirmacao da sua instalacao estara como o seguinte abaixo:
   ```sh
   Runtimes: io.containerd.runc.v2 nvidia runc
   ```

### **4. Instalar e configurar o Azure CLI**

#### **Instalar o Azure CLI**:
1. No Ubuntu/Debian:
   ```sh
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```
2. No Windows/Mac:
   - Baixe e instale o CLI a partir da [página oficial](https://aka.ms/installazurecli).

#### **Configurar o Azure CLI**:
1. Faça login com sua conta Azure:
   ```sh
   az login
   ```
2. Configure o grupo de recursos:
   ```sh
   az group create --name MeuGrupo --location eastus
   ```
3. Verifique as máquinas disponíveis com GPU:
   ```sh
   az vm list-sizes --location eastus --query "[?contains(name, 'NC')]" --output table
   ```

---

### **Resumo dos Passos Completos**
Ao seguir essas etapas, você terá:
1. Uma conta no Azure com acesso à GPU.
2. Docker instalado na sua máquina local.
3. Suporte a NVIDIA no Docker, pronto para usar GPUs.
4. Azure CLI instalado e configurado para gerenciar remotamente os recursos da Azure.

Se você encontrar algum problema em uma dessas etapas, estou aqui para ajudar! 🚀