# Tarefas para construir uma VM com GPU em um servico Cloud para treinar um modelo

- Criar uma VM com GPU no Azure
- Conferir se tem o GPU rodando, nvidia-smi.
- Instalar Docker Engine
- Instalar Nvidia Container Toolkit
- Criar um container basico com as configuracoes compativeis conforme a versao do nvidia e instalar os pacotes pythons que utilizam os gpus
- Rodar scripts que testa, dentro do container, se esta conseguindo captar o uso do GPU dentro do container.
- Por fim, agora, enviar os projetos dentro da VM para mandar ver nos treinos dos modelos.
