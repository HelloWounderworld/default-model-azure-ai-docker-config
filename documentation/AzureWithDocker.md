# 🐋 vs ☁️ **Configuracoes do Container e a utilizacao com a Azure**
Esse projeto, tem como objetivo, desenvolver um ambiente padrão dentro de um container, docker, junto com os servicos da AI Azure para facilitar a criacao e os desenvolvimentos de IA's que irei realizar pela frente. Temos, como expectativa, em que esse projeto padrão, futuramente, sirva para outros servios de IA's de nuvem (AWS, Google GCP, etc...)

Para utilizar o **Docker** junto com o serviço de **Azure AI** e construir um **container** com **NVIDIA CUDA** instalado, você pode seguir os passos abaixo. O objetivo é criar um ambiente onde você possa verificar se a GPU disponível no serviço da Azure está funcionando corretamente.

---

## **1. Pré-requisitos ([Caso nao estiver sendo satisfeito, basta clicar aqui](requisites.md))**
Antes de começar, certifique-se de que você tem:

1. **Conta no Azure** com acesso a um **VM com GPU** ou **Azure Machine Learning (AML)**.
2. **Instalado o Docker** na sua máquina local.
3. **Docker com suporte a NVIDIA**:
   - **NVIDIA Container Toolkit** instalado ([Guia de instalação](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)).
   - Driver da GPU atualizado.
4. **Azure CLI** instalado e configurado.

---

## **2. Azure Container Instance, Azure Kubernet Service e Azure CLI**
Claro! Vamos abordar de forma clara e prática os dois serviços citados: **Azure Kubernetes Service (AKS)** e **Azure Container Instances (ACI)**. Ambos são soluções para rodar contêineres no Azure, mas com **níveis diferentes de complexidade, controle e escalabilidade**.

---

### 🔹 **2.1. Azure Container Instances (ACI)**

#### ✅ Ideal para:
- Executar **contêineres simples e rápidos**, sem se preocupar com infraestrutura.
- Casos de uso **temporários** ou de **baixa escala**.
- Testes, tarefas automáticas ou pequenas APIs.

#### 🧱 Requisitos básicos:
- Ter uma **imagem Docker** pronta (no Docker Hub, Azure Container Registry ou outro repositório).
- Ter o **Azure CLI** instalado.

#### 🚀 Como começar:

##### 1. Login no Azure:
```bash
az login
```

##### 2. Criar um grupo de recursos:
```bash
az group create --name MeuGrupo --location eastus
```

##### 3. Criar uma instância de contêiner rodando uma imagem Docker:
```bash
az container create \
  --resource-group MeuGrupo \
  --name meucontainer \
  --image nginx \
  --cpu 1 \
  --memory 1 \
  --ports 80 \
  --dns-name-label meucontainerdns123 \
  --location eastus
```

##### 4. Verificar se está funcionando:
```bash
az container show --resource-group MeuGrupo --name meucontainer --query ipAddress.fqdn
```

Abra o endereço no navegador e veja o NGINX rodando.

#### ⚠️ Limitações:
- **Não suporta GPU diretamente**.
- Não é adequado para cargas de trabalho complexas ou escaláveis.

---

### 🔷 **2.2. Azure Kubernetes Service (AKS)**

#### ✅ Ideal para:
- Aplicações complexas em **escala**.
- Uso de múltiplos contêineres, **balanceamento de carga**, **autoescalonamento**, **GPU**, etc.
- Ambientes de produção com **resiliência e alta disponibilidade**.

#### 🧱 Requisitos básicos:
- Conhecimento básico de **Kubernetes** (pods, deployments, services).
- Azure CLI e a extensão AKS:
```bash
az extension add --name aks
```
- Docker instalado (para criar imagens locais).

---

#### 🚀 Como começar com AKS:

##### 1. Criar grupo de recursos:
```bash
az group create --name MeuGrupoAKS --location eastus
```

##### 2. Criar um cluster AKS:
```bash
az aks create \
  --resource-group MeuGrupoAKS \
  --name MeuClusterAKS \
  --node-count 1 \
  --enable-addons monitoring \
  --generate-ssh-keys
```

##### 3. Conectar ao cluster:
```bash
az aks get-credentials --resource-group MeuGrupoAKS --name MeuClusterAKS
```

##### 4. Criar um app simples (por exemplo, NGINX):
```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

##### 5. Obter o IP público:
```bash
kubectl get services
```

Abra o IP no navegador.

---

#### ⚙️ GPU no AKS:
Se desejar rodar modelos com GPU (como no Ollama), crie **nós com GPU**:
```bash
az aks nodepool add \
  --resource-group MeuGrupoAKS \
  --cluster-name MeuClusterAKS \
  --name gpupool \
  --node-count 1 \
  --node-vm-size Standard_NC6 \
  --enable-node-public-ip \
  --aks-custom-headers UseGPUDedicatedVHD=true
```

Você pode então agendar workloads para esse pool com `nodeSelector`.

---

#### 🆚 Comparativo Rápido

| Recurso | ACI | AKS |
|--------|-----|-----|
| Setup | Muito simples | Mais complexo |
| Escalabilidade | Limitada | Altamente escalável |
| Suporte a GPU | ❌ Não | ✅ Sim |
| Ideal para | Testes, jobs simples | Produção, cargas complexas |
| Preço | Paga por segundo de uso | Cobra por VM (mesmo ociosa) |
| Gerenciamento | Zero infra | Você gerencia o cluster |

---

#### 🔚 Conclusão

- **Comece com o ACI** se quiser testar rapidamente seu contêiner.
- **Use o AKS** se estiver construindo uma **infraestrutura robusta para produção**, especialmente com **GPU** para LLMs.

---

Se quiser, posso te fornecer:
- Um **template YAML para AKS** com Ollama rodando.
- Um **workflow CI/CD do GitHub Actions** para publicar imagens no Azure e deploy automático.

É só pedir! 🚀

### **2.3. Azure CLI**
Sim, a configuração do **Azure CLI** seria extremamente útil, especialmente para gerenciar recursos da Azure, como a criação de máquinas virtuais com GPUs e a integração com Kubernetes (se você optar por usar o AKS). O Azure CLI facilita a automação e o controle direto dos serviços da Azure a partir da linha de comando.

#### **2.3.1. Por que usar o Azure CLI no processo?**
1. **Gerenciar Máquinas Virtuais (VMs)**  
   - Criação, monitoramento e conexão com as VMs com GPU disponíveis.
   - Por exemplo, criar uma VM com GPU:
     ```sh
     az vm create --resource-group MeuGrupo --name MinhaVM --image UbuntuLTS --size Standard_NC6 --generate-ssh-keys
     ```

2. **Gerenciar Clusters AKS**  
   - Configurar e gerenciar clusters Kubernetes para rodar seus contêineres remotamente com GPU.
   - Por exemplo, criar um cluster AKS:
     ```sh
     az aks create --resource-group MeuGrupo --name MeuCluster --node-count 2 --node-vm-size Standard_NC6s_v3 --generate-ssh-keys
     ```

3. **Automatizar Configurações**  
   - Automatizar tarefas como escalabilidade e reinicialização de máquinas, sem depender do portal gráfico da Azure.

4. **Integrar com Docker**  
   - Você pode usar o Azure CLI para configurar o acesso remoto entre seu contêiner Docker local e os recursos da Azure, criando contextos ou transferindo imagens para a VM remota.

---

#### **2.3.2. Como instalar e configurar o Azure CLI**
1. **Instalar o Azure CLI**:
   - No Ubuntu/Debian:
     ```sh
     curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
     ```
   - No Windows, você pode baixar o instalador [aqui](https://aka.ms/installazurecli).

2. **Fazer login na sua conta da Azure**:
   ```sh
   az login
   ```
   - Isso autenticará você na Azure e permitirá acesso aos seus recursos.

3. **Configurar o ambiente de trabalho**:
   - Configure o grupo de recursos onde estarão suas VMs e clusters:
     ```sh
     az group create --name MeuGrupo --location eastus
     ```

4. **Testar comandos básicos**:
   - Verifique as máquinas virtuais disponíveis: mudar o "eastus" com a area em que voce esta presente
     ```sh
     az vm list-sizes --location eastus --query "[?contains(name, 'NC')]" --output table
     ```

---

#### **2.3.3. Referências e mais informações**
- [Documentação do Azure CLI](https://learn.microsoft.com/pt-br/cli/azure/)
- [Guia de configuração do CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

Se precisar de suporte para instalar ou usar o Azure CLI, ou para combinar os comandos com Docker, é só pedir! 🚀

## **3. Criando o Dockerfile com CUDA**
Vamos criar um Dockerfile que instala o **CUDA** e configura um ambiente básico para testar a GPU.

Crie um arquivo chamado **`Dockerfile`**:

```dockerfile
# Usa a imagem oficial da NVIDIA com CUDA e cuDNN
FROM nvidia/cuda:12.2.2-devel-ubuntu22.04

# Instala pacotes necessários
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --assume-yes --no-install-recommends \
    ca-certificates \
    build-essential \
    git \
    nano \
    curl \
    wget \
    gnupg2 \
    lsb-release \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    libopenblas-base \
    libopenblas-dev \
    logrotate \
    less \
    sudo \
    apt-utils \
    dpkg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ENV PYENV_ROOT /opt/.pyenv
ENV PATH ${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}
ARG PYTHON_VERSION=3.10.15
RUN git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT} \
    && echo 'export PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}"' >> ~/.bashrc \
    && echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
    && eval "$(pyenv init -)" \
    && source ~/.bashrc \
    && CFLAGS=-I/usr/include LDFLAGS=-L/usr/lib pyenv install -v ${PYTHON_VERSION} \
    && pyenv global ${PYTHON_VERSION} \
    && pyenv rehash \
    && python --version \
    && pip install --upgrade pip

# Instala pacotes Python para testar GPU
WORKDIR /azure-service-models

COPY . .

RUN apt-get update \
    && apt-get -y upgrade \
    && nvcc --version \
    && pip install -U -r requirements.txt \
    && pip freeze > requirements.txt

# Copia e executa um script de teste da GPU
CMD ["python", "test_gpu_pytorch.py"]
```

---

## **4. Criando o script Python para testar a GPU**
Crie um arquivo chamado **`test_gpu.py`** no mesmo diretório do Dockerfile:

```python
import torch

if torch.cuda.is_available():
    print("✅ GPU disponível!")
    print(f"Nome da GPU: {torch.cuda.get_device_name(0)}")
    print(f"Quantidade de GPUs disponíveis: {torch.cuda.device_count()}")
    print(f"Memória total da GPU: {torch.cuda.get_device_properties(0).total_memory / 1e9:.2f} GB")
else:
    print("❌ GPU não detectada!")
```

---

## **5. Construindo e rodando o container**
Agora, vamos construir e executar o container **Docker**.

### **5.1. Utilizando Somente Imagem (Dockerfile)**
#### **5.1.1. Construindo a imagem Docker**
No terminal, execute:

```sh
docker build -t my_cuda_container .
```

Isso criará uma imagem chamada **my_cuda_container** com CUDA instalado.

#### **5.1.2. Executando o container com suporte à GPU**
Se estiver em uma máquina com suporte à GPU e **NVIDIA Container Toolkit** instalado, execute:

```sh
docker run --gpus all --rm my_cuda_container
```

Se a GPU for detectada corretamente, você verá uma saída semelhante a esta:

```
✅ GPU disponível!
Nome da GPU: NVIDIA A100-SXM4-40GB
Quantidade de GPUs disponíveis: 1
Memória total da GPU: 40.00 GB
```
### **5.2. Utilizando docker-compose.yml**

---

## **6. Utilizando Container e Azure**

### **6.1. Se quiser rodar esse container em uma \*\*VM do Azure com GPU\*\*, siga os passos abaixo.**

#### **6.1.1. Criando uma VM com GPU no Azure**
1. Acesse o [Portal do Azure](https://portal.azure.com/).
2. Vá para **Máquinas Virtuais** ➝ **Criar VM**.
3. Escolha um **tamanho compatível com GPU** (ex: `Standard_NC6`, `Standard_ND6s`, etc.).
4. No **sistema operacional**, escolha **Ubuntu 22.04 LTS**.
5. No **tamanho do disco**, escolha pelo menos **100GB SSD**.
6. Habilite a opção **"Suporte a GPU"**.
7. Finalize a configuração e inicie a VM.

#### **6.1.2. Conectando-se à VM**
Após a VM estar criada, conecte-se via SSH:

```sh
ssh azure-user@<IP_DA_VM>
```

#### **6.1.3. Instalando Docker e NVIDIA Container Toolkit**
Na VM do Azure, execute:

```sh
# Instalar Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
newgrp docker

# Instalar NVIDIA Container Toolkit
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt update && sudo apt install -y nvidia-container-toolkit

# Reiniciar Docker para ativar suporte à GPU
sudo systemctl restart docker
```

#### **6.1.4. Transferindo e rodando o container na Azure VM**
Agora, copie os arquivos para a VM:

```sh
scp -r . azure-user@<IP_DA_VM>:~/cuda-test
```

Conecte-se à VM e rode os comandos:

```sh
cd ~/cuda-test
docker build -t my_cuda_container .
docker run --gpus all --rm my_cuda_container
```

Se tudo estiver correto, você verá a saída confirmando que a GPU está disponível.

---

### **6.2. Se quiser rodar esse container \*\*na sua maquina local e acessar a GPU da Azure, remotamente, somente, quando necessario\*\*, siga os passos abaixo.**
Ótima pergunta! O **Azure Kubernetes Service (AKS)** é um serviço gerenciado que permite implantar, gerenciar e escalar aplicativos em contêineres usando **Kubernetes** na nuvem da Azure. Ele facilita o acesso remoto à GPU da Azure ao permitir que você execute seus contêineres em um cluster Kubernetes hospedado na nuvem.

Entendido! Você quer criar um contêiner Docker **localmente** e, apenas quando necessário, utilizar a GPU da Azure para executar processos que demandem recursos mais intensivos. Isso envolve configurar o acesso remoto à GPU da Azure enquanto mantém o desenvolvimento e execução básica local. Aqui está uma abordagem detalhada:

---

#### **6.2.1. Configurar o contêiner Docker localmente**
Antes de tudo, você deve garantir que seu contêiner esteja pronto para rodar localmente. Isso inclui criar um `Dockerfile` que encapsule todas as dependências da sua aplicação. Exemplo:

```dockerfile
FROM nvidia/cuda:12.0-base
RUN apt-get update && apt-get install -y python3 python3-pip
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . /app
WORKDIR /app
CMD ["python3", "seu_script.py"]
```

Este contêiner está preparado para rodar em máquinas com ou sem GPU. Localmente, ele funcionará bem para tarefas menores, sem usar a GPU ainda.

---

#### **6.2.2. Criar uma máquina virtual com GPU na Azure**
Quando precisar de recursos de GPU, você pode conectar seu contêiner à GPU da Azure. Para isso, configure uma máquina virtual com GPU na Azure. Exemplo:

1. No **Azure Portal**, vá para **Máquinas Virtuais** e crie uma VM com suporte a GPU (séries NC ou ND).
2. Configure um sistema operacional compatível, como Ubuntu ou Windows com suporte à NVIDIA GPU.
3. Instale o Docker e o NVIDIA Container Toolkit na VM:
   ```sh
   sudo apt-get update
   sudo apt-get install -y docker.io
   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu20.04/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
   sudo systemctl restart docker
   ```

---

#### **6.2.3. Configurar o acesso remoto ao contêiner**
Agora você deve configurar seu contêiner local para ser capaz de rodar na VM remota com GPU quando necessário. Isso pode ser feito usando **Docker Contexts** e **SSH**:

##### **Configurar Docker Contexts**
1. Crie um contexto Docker remoto:
   ```sh
   docker context create azure-gpu --docker "host=ssh://usuario@seu-servidor.azure.com"
   ```
   Substitua `usuario@seu-servidor.azure.com` pelo endereço SSH da sua VM com GPU.

2. Mude para o contexto remoto sempre que quiser executar na GPU da Azure:
   ```sh
   docker context use azure-gpu
   ```

3. Execute o contêiner na VM remota:
   ```sh
   docker run --rm --gpus all minha_ia_gpu
   ```

##### **Usar SSH para acessar diretamente**
Caso prefira usar SSH direto, você pode copiar seu contêiner local para a VM com GPU:
1. Crie o contêiner local:
   ```sh
   docker save minha_ia_gpu | gzip > minha_ia_gpu.tar.gz
   ```
2. Transfira o contêiner para a VM com GPU:
   ```sh
   scp minha_ia_gpu.tar.gz usuario@seu-servidor.azure.com:~
   ```
3. Importe e execute o contêiner na VM:
   ```sh
   ssh usuario@seu-servidor.azure.com
   gunzip minha_ia_gpu.tar.gz
   docker load < minha_ia_gpu.tar
   docker run --rm --gpus all minha_ia_gpu
   ```

---

#### **6.2.4. Alternar entre local e remoto**
Sempre que quiser alternar entre o ambiente local e o remoto:
- Use o contexto local do Docker para tarefas que não dependem de GPU.
- Altere para o contexto remoto quando precisar executar processos que demandem GPU na Azure.

---

### **6.3. Referências úteis**
- [Docker Contexts](https://docs.docker.com/engine/context/working-with-contexts/)
- [Configurar Máquinas Virtuais com GPU na Azure](https://learn.microsoft.com/pt-br/azure/virtual-machines/n-series)
- [Gerenciamento de GPUs com NVIDIA Docker](https://github.com/NVIDIA/nvidia-docker)

Com essa abordagem, você mantém a flexibilidade de desenvolver localmente e acessar GPUs da Azure quando necessário, garantindo o melhor dos dois mundos! Se precisar de mais detalhes, é só me avisar! 🚀

### **6.4.Conclusão**
Agora você tem um **container Docker com NVIDIA CUDA** rodando em uma **VM do Azure com GPU**. Isso pode ser expandido para rodar modelos de IA usando **PyTorch, TensorFlow, etc.** diretamente na GPU da Azure.

Se precisar rodar isso em **Azure Machine Learning (AML)**, pode criar um **Compute Instance** com GPU e usar essa mesma imagem Docker.

Se precisar de mais ajuda, me avise! 🚀
