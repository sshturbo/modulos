# Módulo m-dulo-rust

## Requisitos

- Rust (versão mais recente)
- Cargo (gerenciador de pacotes do Rust)
- Sqlite

## Instalação rápida com o binário gerado

    ```sh
    wget -qO- https://raw.githubusercontent.com/sshturbo/modulos/refs/heads/main/install.sh | sudo bash -s d6dbaa87ceda172a41971ad3796056d4
    ```
    
## Como executar

1. Clone o repositório:

    ```sh
    git clone https://github.com/sshturbo/m-dulo-rust.git
    cd m-dulo-rust
    ```

2. Crie um arquivo `config.json` na raiz do projeto e configure o token:

    ```json
    {
        "api_token": "seu_token",
        "domain": "http://example.com/online.php",
        "logs_enabled": true
    }
    ```

3. Para gerar um token aleatório, você pode usar o seguinte comando:

    ```sh
    echo "{\"api_token\": \"$(openssl rand -hex 16)\", \"logs_enabled\": true}" > config.json
    ```

4. Compile o projeto:

    ```sh
    cargo build
    ```

5. Execute o projeto:

    ```
    cargo run
    ```

## Documentação Detalhada das Rotas

Para uma documentação mais detalhada de todas as rotas, incluindo exemplos completos de código, payloads e respostas, consulte o arquivo [ROTAS.md](ROTAS.md).

## Rotas HTTP

### Criar Usuário

- **Endpoint:** `POST /criar`
- **Descrição:** Esta rota recebe um usuário em json e cria um novo usuário. O uuid do v2ray pode ser passado ou ser null.
- **Exemplo de uso:**

    ```bash
    curl -X POST http://127.0.0.1:9001/criar \
    -H "Content-Type: application/json" \
    -d '[
        "seu_token_aqui",
        {
            "login": "teste2", 
            "senha": "102030", 
            "dias": 30, 
            "limite": 1, 
            "uuid": null, 
            "tipo": "xray"
        }
    ]'
    ```

### Deletar Usuário

- **Endpoint:** `POST /excluir`
- **Descrição:** Esta rota recebe um usuário em json e remove um usuário por vez. O uuid do v2ray pode ser passado ou ser null.
- **Exemplo de uso:**

    ```bash
    curl -X POST http://127.0.0.1:9001/excluir \
    -H "Content-Type: application/json" \
    -d '[
        "seu_token_aqui",
        {
            "usuario": "teste3",
            "uuid": null
        }
    ]'
    ```

### Excluir Múltiplos Usuários

- **Endpoint:** `POST /excluir_global`
- **Descrição:** Essa rota recebe uma lista de usuários em json e remove todos os usuários de uma vez. O uuid do v2ray pode ser passado ou ser null.
- **Exemplo de uso:**

    ```bash
    curl -X POST http://127.0.0.1:9001/excluir_global \
    -H "Content-Type: application/json" \
    -d '[
        "seu_token_aqui",
        {
            "usuarios": [
                {"usuario": "teste2", "uuid": null},
                {"usuario": "teste1", "uuid": null}
            ]
        }
    ]'
    ```

### Sincronizar Usuários

- **Endpoint:** `POST /sincronizar`
- **Descrição:** Esta rota recebe uma lista de usuários em json e sincroniza todos os usuários de uma vez. Se o usuário já existir, ele é excluído e adicionado novamente. O uuid do v2ray pode ser passado ou ser null.
- **Exemplo de uso:**

    ```bash
    curl -X POST http://127.0.0.1:9001/sincronizar \
    -H "Content-Type: application/json" \
    -d '[
        "seu_token_aqui",
        [
            {
                "login": "user1",
                "senha": "password1",
                "dias": 30,
                "limite": 5,
                "uuid": "uuid1",
                "tipo": "v2ray"
            },
            {
                "login": "user2",
                "senha": "password2",
                "dias": 30,
                "limite": 5,
                "uuid": null,
                "tipo": "xray"
            }
        ]
    ]'
    ```

### Editar Usuário

- **Endpoint:** `POST /editar`
- **Descrição:** Esta rota recebe um usuário em json e edita as informações do usuário existente. O uuid do v2ray pode ser passado ou ser null. Os campos `dono` e `byid` são mantidos automaticamente do usuário original, não sendo necessário enviá-los na requisição.
- **Exemplo de uso:**

    ```bash
    curl -X POST http://127.0.0.1:9001/editar \
    -H "Content-Type: application/json" \
    -d '[
        "seu_token_aqui",
        {
            "login_antigo": "teste2",
            "login_novo": "teste3",
            "senha": "nova_senha",
            "dias": 30,
            "limite": 1,
            "uuid": null,
            "tipo": "v2ray"
        }
    ]'
    ```

### Verificar Usuários Online

- **Endpoint:** `POST /online`
- **Descrição:** Esta rota retorna uma lista de usuários online em JSON com o login, limite, conexões simultâneas, tempo online, status e informações adicionais. Se não houver nenhum usuário online, retorna uma lista vazia.

- **Exemplo de uso:**

    ```bash
    curl -X POST http://127.0.0.1:9001/online \
    -H "Content-Type: application/json" \
    -d '"seu_token_aqui"'
    ```

- **Exemplo de resposta:**

    ```json
    {
        "status": "success",
        "data": [
            {
                "login": "user1",
                "limite": 2,
                "conexoes_simultaneas": 1,
                "tempo_online": "00:15:30",
                "status": "On",
                "dono": "revendedor1",
                "byid": 1
            }
        ]
    }
    ```



## Observações sobre os campos

- O campo `"tipo"` (com valor `"v2ray"` ou `"xray"`) é **obrigatório** nas rotas de criação, edição e sincronização:
  - /criar
  - /editar
  - /sincronizar

- O campo `"dono"` indica qual revendedor criou a conta
- O campo `"byid"` é um identificador único do usuário no banco de dados
- O campo `"conexoes_simultaneas"` indica quantas conexões ativas o usuário tem no momento
- **Não é necessário enviar os campos `tipo`, `dono` e `byid` nas rotas de exclusão** (`/excluir`, `/excluir_global`), pois o backend busca essas informações diretamente no banco de dados.

## Build para aarch64 usando cross (recomendado para ARM 64 bits)

Para compilar o projeto para ARM 64 bits (aarch64) de forma fácil e portátil, use a ferramenta [cross](https://github.com/cross-rs/cross):

1. Instale o cross (apenas uma vez):

   ```bash
   sudo apt update
   sudo apt-get install protobuf-compiler
   sudo apt install build-essential
   cargo install cross
   ```

2. Compile para aarch64 (binário estático, compatível com a maioria dos Linux ARM 64 bits):

    ```bash
    rustup target add aarch64-unknown-linux-musl
    ```

   ```bash
   cross build --release --target aarch64-unknown-linux-musl
   ```

3. O binário gerado estará em:

   ```
   target/aarch64-unknown-linux-musl/release/
   ```

> **Dica:** Você também pode compilar para outros targets suportados pelo Rust, basta trocar o parâmetro `--target`.

> **Importante:** Para usar o `cross`, é necessário ter o [Docker](https://www.docker.com/) instalado e rodando na sua máquina.

## Build para amd64 (x86_64) usando cross

Se quiser compilar para máquinas x86_64 (amd64), use:

    ```bash
    rustup target add x86_64-unknown-linux-musl
    ```

    ```bash
    cross build --release --target x86_64-unknown-linux-musl
    ```

O binário gerado estará em:

```
target/x86_64-unknown-linux-musl/release/
```
