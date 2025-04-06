# 🐋 & ☁️  **Introdução do uso de Docker Container com GPU em nuvem oferecido pela Azure**

## **Objetivo**
Eu tenho um objetivo de criar uma IA. Porem, o unico problema para criar essa IA seria a utilizacao da GPU. O meu notebook gamer nao tem uma GPU tao potente. Logo, imagino que a Azure tenha. Ou seja, eu acho que so iria querer utilizar a GPU da Azure mesmo, pois essa mesma IA que eu criar, nao queria que ela ficasse dependente somente dos recursos da Azure, mas, sim, que ela tenha mais versatilidade em ser implementada em diversos ambientes.

Você está no caminho certo, pensando em como utilizar a infraestrutura da Azure para suprir a necessidade de GPUs mais potentes, mas sem limitar sua IA apenas ao ambiente da Azure. Aqui está um plano estratégico que pode ajudar:

### 1. **Utilizar a GPU da Azure para Treinamento**
   - A Azure oferece máquinas virtuais com GPUs avançadas, como as da NVIDIA, ótimas para treinamento de modelos complexos de IA.
   - Você pode usar serviços como o **Azure Machine Learning** para configurar ambientes de treinamento, utilizar GPUs e ajustar os hiperparâmetros de forma eficiente.
   - As GPUs da Azure têm escalabilidade, permitindo que você treine modelos maiores ou mais complexos com tranquilidade.

### 2. **Generalizar e Tornar a IA Versátil**
   - Depois de criar e treinar seu modelo na Azure, salve-o em formatos portáteis, como **ONNX (Open Neural Network Exchange)**. Esse formato facilita a implementação em diferentes ambientes e frameworks, como PyTorch ou TensorFlow.
   - Você pode testar e ajustar sua IA para rodar em dispositivos com menor poder computacional (como CPUs ou GPUs menos potentes), aproveitando otimizações como a **quantização**.

### 3. **Containerizar com Docker**
   - Após desenvolver e validar sua IA, use o **Docker** para criar um contêiner que encapsule todos os requisitos necessários para rodar sua IA, independentemente do ambiente.
   - Dessa forma, você garante que sua IA será compatível com servidores locais, máquinas pessoais e até outros provedores de nuvem.
   - Um contêiner bem configurado com suporte a GPU (via NVIDIA Docker) garante que, ao migrar para diferentes hardware, o desempenho seja consistente.

### 4. **Preparação para Ambientes Diversos**
   - Para rodar sua IA em múltiplos ambientes, faça testes em locais como servidores com especificações variadas, edge devices ou até clusters. Utilize ferramentas como Kubernetes para orquestrar os contêineres em diferentes configurações.

Se você quiser saber mais sobre como configurar GPUs específicas na Azure ou criar contêineres robustos no Docker, posso te orientar passo a passo. O que você acha? 🚀

## **Implementacao**
Ótimo! Aqui estão as instruções e referências para cada etapa mencionada, para que você possa começar a explorar e implementar sua IA:

---

### **1. Utilizar a GPU da Azure para Treinamento**
- **Configuração Inicial**:
  1. Crie uma conta na Azure e configure um **Azure Machine Learning Workspace**.
  2. Solicite cotas para GPUs na sua região (ex.: NVIDIA A100 ou V100).
  3. Configure uma máquina virtual com suporte a GPU, como as séries **NC** ou **ND**.

- **Referências**:
  - [Como configurar GPUs no Azure Machine Learning](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-deploy-inferencing-gpus?view=azureml-api-1).
  - [Guia para usar GPUs em máquinas virtuais da Azure](https://zenn.dev/headwaters/articles/4a714937c9d17c).

---

### **2. Generalizar e Tornar a IA Versátil com ONNX**
- **Passos**:
  1. Após treinar seu modelo (em PyTorch, TensorFlow, etc.), exporte-o para o formato **ONNX**.
  2. Teste o modelo em diferentes frameworks para garantir compatibilidade.
  3. Use ferramentas como **ONNX Runtime** para otimizar o desempenho em dispositivos variados.

- **Referências**:
  - [Introdução ao formato ONNX](https://qiita.com/ymym3412/items/05a7cecf81309a3f131e).
  - [Documentação oficial do ONNX](https://zenn.dev/uint256_t/articles/00f9379a7e69b4).

---

### **3. Containerizar com Docker**
- **Passos**:
  1. Instale o **Docker** e o **NVIDIA Container Toolkit** para suporte a GPU.
  2. Crie um `Dockerfile` que inclua as dependências do seu modelo e configure o suporte a GPU.
  3. Use `docker-compose` para gerenciar múltiplos contêineres, se necessário.

- **Exemplo de Dockerfile**:
   ```dockerfile
   FROM nvidia/cuda:12.0-base
   RUN apt-get update && apt-get install -y python3 python3-pip
   COPY requirements.txt .
   RUN pip install -r requirements.txt
   CMD ["python3", "seu_modelo.py"]
   ```

- **Referências**:
  - [Como usar GPUs com Docker](https://sreake.com/blog/gpu-used-docker-with-nvidia-cuda-image/).
  - [Guia para configurar contêineres com suporte a GPU](https://pystyle.info/docker-nvidia-container-toolkit/).

---

### **4. Preparação para Ambientes Diversos com Kubernetes**
- **Passos**:
  1. Configure um cluster Kubernetes (ex.: **Azure Kubernetes Service - AKS**).
  2. Use arquivos `yaml` para definir os recursos e configurar o suporte a GPU.
  3. Implante seus contêineres no cluster e teste a escalabilidade.

- **Referências**:
  - [O que é orquestração de contêineres?](https://www.redhat.com/en/topics/containers/what-is-container-orchestration).
  - [Guia para Kubernetes com suporte a GPU](https://www.ibm.com/think/topics/container-orchestration).

---

Com essas instruções e referências, você terá uma base sólida para começar a desenvolver sua IA e garantir que ela seja versátil e eficiente. Se precisar de ajuda em algum ponto específico, é só me chamar! 🚀

---

## **Utilizacao da GPU disponivel na Azure de forma remota**
Para utilizar a GPU da Azure, existem duas alternativas:

- Criar uma VM ou um Kubernetes e enviar o repositorio que contem os arquivos docker dentro dela e executar. Ou seja, voce tera que acessar a VM de forma remota, utilizando ssh, ou de forma direta, entrando na interface da Azure com a sua conta, para, dentro dela, trazer o docker container e nela voce executar os comandos docker para criar o container e, assim, conseguir utilizar a GPU.

- Criar o container localmente, na sua maquina, e, somente quando necessario, utilizar, remotamente, a GPU na Azure, utilizando os servicos da kubectl, que e um tipo de servico da Kubernetes disponivel na Azure.

Basicamente, a abordagem que eu gostaria de realizar, seria em casos, de se eu quiser utilizar, somente, a GPU da Azure, sem utilizar outros servicos de AI disponveis nela.

Ótima abordagem! Você pode utilizar a GPU da Azure sem depender dos serviços de IA, criando um contêiner Docker localmente e acessando os recursos de GPU na nuvem. Para verificar quais GPUs estão disponíveis na sua conta da Azure, siga estes passos:

### **Como verificar GPUs disponíveis na Azure**
1. **Acesse o portal da Azure** ([Azure Portal](https://portal.azure.com)).
2. **Navegue até "Máquinas Virtuais"** e clique em "Criar uma nova VM".
3. **Escolha um tamanho de VM** e filtre por opções que incluem GPUs (como as séries **NC, ND, NV**).
4. **Verifique as especificações** da GPU disponível, como modelo (NVIDIA A100, V100, T4, etc.).
5. **Use a CLI do Azure** para listar os tamanhos de VM com suporte a GPU:
   ```sh
   az vm list-sizes --location eastus
   ```
   Substitua `"eastus"` pela região onde deseja verificar os recursos.

Para mais detalhes sobre GPUs disponíveis na Azure, você pode conferir [este guia](https://learn.microsoft.com/pt-br/azure/virtual-desktop/graphics-enable-gpu-acceleration) e [esta documentação](https://learn.microsoft.com/pt-br/azure-stack/user/gpu-vms-about?view=azs-2408).

Se precisar de ajuda para configurar o acesso à GPU dentro do seu contêiner Docker, posso te orientar! 🚀
