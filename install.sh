#!/bin/bash

# ===============================
# ConfiguraÃ§Ãµes e VariÃ¡veis Globais
# ===============================
APP_DIR="/opt/myapp"
DEPENDENCIES=("unzip")
VERSION="1.0.0"
FILE_URL="https://github.com/sshturbo/modulos/releases/download/$VERSION"
ARCH=$(uname -m)
SERVICE_FILE_NAME="m-dulo.service"

# Verifica se o token foi passado como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <API_TOKEN>"
    exit 1
fi
API_TOKEN="$1"

# Determinar arquitetura e nome do arquivo para download
case $ARCH in
x86_64)
    FILE_NAME="m-dulo-x86_64-unknown-linux-musl.zip"
    DOCKER_ARCH="x86_64"
    ;;
aarch64)
    FILE_NAME="m-dulo-aarch64-unknown-linux-musl.zip"
    DOCKER_ARCH="aarch64"
    ;;
*)
    echo "Arquitetura $ARCH nÃ£o suportada."
    exit 1
    ;;
esac

# ===============================
# FunÃ§Ãµes UtilitÃ¡rias
# ===============================
print_centered() {
    printf "\e[33m%s\e[0m\n" "$1"
}

progress_bar() {
    local total_steps=$1
    for ((i = 0; i < total_steps; i++)); do
        echo -n "#"
        sleep 0.1
    done
    echo " COMPLETO!"
}

run_with_spinner() {
    local command="$1"
    local message="$2"
    echo -n "$message"
    $command &>/tmp/command_output.log &
    local pid=$!
    while kill -0 $pid 2>/dev/null; do
        echo -n "."
        sleep 1
    done
    wait $pid
    if [ $? -ne 0 ]; then
        echo " ERRO!"
        cat /tmp/command_output.log
        exit 1
    else
        echo " FEITO!"
    fi
}

print_centered "Modulos do painel Web Pro"
print_centered "VersÃ£o: $VERSION"
print_centered "Arquitetura: $ARCH"

install_if_missing() {
    local package=$1
    if ! command -v $package &>/dev/null; then
        run_with_spinner "apt-get install -y $package" "INSTALANDO $package"
    else
        print_centered "$package JÃ ESTÃ INSTALADO."
    fi
}

# ===============================
# ValidaÃ§Ãµes Iniciais
# ===============================
if [[ $EUID -ne 0 ]]; then
    echo "Este script deve ser executado como root."
    exit 1
fi

# Instalar dependÃªncias
for dep in "${DEPENDENCIES[@]}"; do
    install_if_missing $dep
done

# ===============================
# ConfiguraÃ§Ã£o da AplicaÃ§Ã£o
# ===============================
# Configurar diretÃ³rio da aplicaÃ§Ã£o
if [ -d "$APP_DIR" ]; then
    print_centered "DIRETÃ“RIO $APP_DIR JÃ EXISTE. EXCLUINDO ANTIGO..."
    if systemctl list-units --full -all | grep -Fq "$SERVICE_FILE_NAME"; then
        echo "PARANDO SERVIÃ‡O. FEITO!"
        sudo systemctl stop m-dulo
        echo "DESABILITANDO SERVIÃ‡O. FEITO!"
        sudo systemctl disable m-dulo
    else
        print_centered "SERVIÃ‡O $SERVICE_FILE_NAME NÃƒO ENCONTRADO."
    fi
    run_with_spinner "rm -rf $APP_DIR" "EXCLUINDO DIRETÃ“RIO"
else
    print_centered "DIRETÃ“RIO $APP_DIR NÃƒO EXISTE. NADA A EXCLUIR."
fi
mkdir -p $APP_DIR

# Baixar e configurar o mÃ³dulo
print_centered "BAIXANDO $FILE_NAME..."
run_with_spinner "wget --timeout=30 -O $APP_DIR/$FILE_NAME $FILE_URL/$FILE_NAME" "BAIXANDO ARQUIVO"

print_centered "EXTRAINDO ARQUIVOS..."
run_with_spinner "unzip $APP_DIR/$FILE_NAME -d $APP_DIR" "EXTRAINDO ARQUIVOS"
run_with_spinner "rm $APP_DIR/$FILE_NAME" "REMOVENDO ARQUIVO ZIP"
progress_bar 5

# Criar arquivo config.json
printf '{
  "api_token": "%s",
  "domain": "example.com/online.php",
  "logs_enabled": true
}\n' "$API_TOKEN" >"$APP_DIR/config.json"

chmod -R 775 $APP_DIR

# Configurar serviÃ§o systemd
if [ -f "$APP_DIR/$SERVICE_FILE_NAME" ]; then
    cp "$APP_DIR/$SERVICE_FILE_NAME" /etc/systemd/system/
    chmod 644 /etc/systemd/system/$SERVICE_FILE_NAME
    systemctl daemon-reload
    systemctl enable $SERVICE_FILE_NAME
    systemctl start $SERVICE_FILE_NAME
    print_centered "SERVIÃ‡O $SERVICE_FILE_NAME CONFIGURADO E INICIADO COM SUCESSO!"
else
    print_centered "Erro: Arquivo de serviÃ§o nÃ£o encontrado."
    exit 1
fi

progress_bar 10
print_centered "MÃ“DULO INSTALADO E CONFIGURADO COM SUCESSO!"
