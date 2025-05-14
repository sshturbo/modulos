#!/bin/bash

echo "==> Parando serviços Docker..."
systemctl stop docker 2>/dev/null
systemctl stop containerd 2>/dev/null

echo "==> Desabilitando serviços Docker..."
systemctl disable docker 2>/dev/null
systemctl disable containerd 2>/dev/null

echo "==> Matando processo 'container' na porta 28071..."
PID=$(lsof -ti :28071)
if [ -n "$PID" ]; then
    kill -9 $PID && echo "Processo $PID finalizado."
else
    echo "Nenhum processo ativo na porta 28071."
fi

echo "==> Removendo pacotes docker.io..."
apt-get purge -y docker.io
apt-get autoremove -y --purge
apt-get autoclean -y

echo "==> Removendo diretórios do Docker..."
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm -rf /etc/docker
rm -rf ~/.docker

echo "==> Limpando arquivos systemd residuais..."
rm -f /etc/systemd/system/docker.service
rm -f /etc/systemd/system/docker.socket
rm -f /etc/systemd/system/containerd.service
systemctl daemon-reload
systemctl reset-failed

echo "==> Verificando rc.local, crontab, e inicializações..."
sed -i '/container/d' /etc/rc.local 2>/dev/null
(crontab -l | grep -v "container") | crontab -

echo "==> Docker removido com sucesso e porta 28071 liberada!"
