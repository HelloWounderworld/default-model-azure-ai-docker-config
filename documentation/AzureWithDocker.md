# Default Azure AI settings with Docker
Esse projeto, tem como objetivo, desenvolver um ambiente padrão dentro de um container, docker, junto com os servicos da AI Azure para facilitar a criacao e os desenvolvimentos de IA's que irei realizar pela frente. Temos, como expectativa, em que esse projeto padrão, futuramente, sirva para outros servios de IA's de nuvem (AWS, Google GCP, etc...)

Para utilizar o **Docker** junto com o serviço de **Azure AI** e construir um **container** com **NVIDIA CUDA** instalado, você pode seguir os passos abaixo. O objetivo é criar um ambiente onde você possa verificar se a GPU disponível no serviço da Azure está funcionando corretamente.

---

## **1. Pré-requisitos**
Antes de começar, certifique-se de que você tem:

1. **Conta no Azure** com acesso a um **VM com GPU** ou **Azure Machine Learning (AML)**.
2. **Instalado o Docker** na sua máquina local.
3. **Docker com suporte a NVIDIA**:
   - **NVIDIA Container Toolkit** instalado ([Guia de instalação](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)).
   - Driver da GPU atualizado.
4. **Azure CLI** instalado e configurado.

---

## **2. Criando o Dockerfile com CUDA**
Vamos criar um Dockerfile que instala o **CUDA** e configura um ambiente básico para testar a GPU.

Crie um arquivo chamado **`Dockerfile`**:

```dockerfile
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
```

---

## **3. Criando o script Python para testar a GPU**
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

## **4. Construindo e rodando o container**
Agora, vamos construir e executar o container **Docker**.

### **4.1. Construindo a imagem Docker**
No terminal, execute:

```sh
docker build -t my_cuda_container .
```

Isso criará uma imagem chamada **my_cuda_container** com CUDA instalado.

### **4.2. Executando o container com suporte à GPU**
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

---

## **5. Subindo o container no Azure**
Se quiser rodar esse container em uma **VM do Azure com GPU**, siga os passos abaixo.

### **5.1. Criando uma VM com GPU no Azure**
1. Acesse o [Portal do Azure](https://portal.azure.com/).
2. Vá para **Máquinas Virtuais** ➝ **Criar VM**.
3. Escolha um **tamanho compatível com GPU** (ex: `Standard_NC6`, `Standard_ND6s`, etc.).
4. No **sistema operacional**, escolha **Ubuntu 22.04 LTS**.
5. No **tamanho do disco**, escolha pelo menos **100GB SSD**.
6. Habilite a opção **"Suporte a GPU"**.
7. Finalize a configuração e inicie a VM.

### **5.2. Conectando-se à VM**
Após a VM estar criada, conecte-se via SSH:

```sh
ssh azure-user@<IP_DA_VM>
```

### **5.3. Instalando Docker e NVIDIA Container Toolkit**
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

### **5.4. Transferindo e rodando o container na Azure VM**
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

## **Conclusão**
Agora você tem um **container Docker com NVIDIA CUDA** rodando em uma **VM do Azure com GPU**. Isso pode ser expandido para rodar modelos de IA usando **PyTorch, TensorFlow, etc.** diretamente na GPU da Azure.

Se precisar rodar isso em **Azure Machine Learning (AML)**, pode criar um **Compute Instance** com GPU e usar essa mesma imagem Docker.

Se precisar de mais ajuda, me avise! 🚀

# Azure Container Instance and Azure Kubernet Service
Claro! Vamos abordar de forma clara e prática os dois serviços citados: **Azure Kubernetes Service (AKS)** e **Azure Container Instances (ACI)**. Ambos são soluções para rodar contêineres no Azure, mas com **níveis diferentes de complexidade, controle e escalabilidade**.

---

## 🔹 **1. Azure Container Instances (ACI)**

### ✅ Ideal para:
- Executar **contêineres simples e rápidos**, sem se preocupar com infraestrutura.
- Casos de uso **temporários** ou de **baixa escala**.
- Testes, tarefas automáticas ou pequenas APIs.

### 🧱 Requisitos básicos:
- Ter uma **imagem Docker** pronta (no Docker Hub, Azure Container Registry ou outro repositório).
- Ter o **Azure CLI** instalado.

### 🚀 Como começar:

#### 1. Login no Azure:
```bash
az login
```

#### 2. Criar um grupo de recursos:
```bash
az group create --name MeuGrupo --location eastus
```

#### 3. Criar uma instância de contêiner rodando uma imagem Docker:
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

#### 4. Verificar se está funcionando:
```bash
az container show --resource-group MeuGrupo --name meucontainer --query ipAddress.fqdn
```

Abra o endereço no navegador e veja o NGINX rodando.

### ⚠️ Limitações:
- **Não suporta GPU diretamente**.
- Não é adequado para cargas de trabalho complexas ou escaláveis.

---

## 🔷 **2. Azure Kubernetes Service (AKS)**

### ✅ Ideal para:
- Aplicações complexas em **escala**.
- Uso de múltiplos contêineres, **balanceamento de carga**, **autoescalonamento**, **GPU**, etc.
- Ambientes de produção com **resiliência e alta disponibilidade**.

### 🧱 Requisitos básicos:
- Conhecimento básico de **Kubernetes** (pods, deployments, services).
- Azure CLI e a extensão AKS:
```bash
az extension add --name aks
```
- Docker instalado (para criar imagens locais).

---

### 🚀 Como começar com AKS:

#### 1. Criar grupo de recursos:
```bash
az group create --name MeuGrupoAKS --location eastus
```

#### 2. Criar um cluster AKS:
```bash
az aks create \
  --resource-group MeuGrupoAKS \
  --name MeuClusterAKS \
  --node-count 1 \
  --enable-addons monitoring \
  --generate-ssh-keys
```

#### 3. Conectar ao cluster:
```bash
az aks get-credentials --resource-group MeuGrupoAKS --name MeuClusterAKS
```

#### 4. Criar um app simples (por exemplo, NGINX):
```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

#### 5. Obter o IP público:
```bash
kubectl get services
```

Abra o IP no navegador.

---

### ⚙️ GPU no AKS:
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

## 🆚 Comparativo Rápido

| Recurso | ACI | AKS |
|--------|-----|-----|
| Setup | Muito simples | Mais complexo |
| Escalabilidade | Limitada | Altamente escalável |
| Suporte a GPU | ❌ Não | ✅ Sim |
| Ideal para | Testes, jobs simples | Produção, cargas complexas |
| Preço | Paga por segundo de uso | Cobra por VM (mesmo ociosa) |
| Gerenciamento | Zero infra | Você gerencia o cluster |

---

## 🔚 Conclusão

- **Comece com o ACI** se quiser testar rapidamente seu contêiner.
- **Use o AKS** se estiver construindo uma **infraestrutura robusta para produção**, especialmente com **GPU** para LLMs.

---

Se quiser, posso te fornecer:
- Um **template YAML para AKS** com Ollama rodando.
- Um **workflow CI/CD do GitHub Actions** para publicar imagens no Azure e deploy automático.

É só pedir! 🚀
