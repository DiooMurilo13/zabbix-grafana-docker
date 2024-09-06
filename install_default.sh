#!/bin/bash

# Atualize o índice de pacotes
apt update -y && \

# Instale o jq e git
apt install -y jq git && \

# Instale dependências para o Docker
apt install -y apt-transport-https ca-certificates curl software-properties-common && \

# Adicione a chave GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \

# Adicione o repositório do Docker
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \

# Atualize o índice de pacotes novamente
apt update -y && \

# Instale o Docker
apt install -y docker-ce && \

# Adicione o usuário root ao grupo docker
usermod -aG docker root

# Mensagem de conclusão
echo "Configuração concluída com sucesso."

# pega o ip da maquina e troca no .env
IP_ADDRESS=$(hostname -I | awk '{print $1}')
sed -i "s|^DEFAULT_URL=.*|DEFAULT_URL=http://$IP_ADDRESS|" .env
sed -i 's/^MYSQL_PASSWORD=.*/MYSQL_PASSWORD=senha/' .env

#inicia containers
docker compose up -d

#inicia configuracao default do grafana
./init_grafana.sh
