# Documentação Detalhada das Rotas HTTP

## URL Base
```
http://127.0.0.1:9001
```

## Autenticação
Todas as rotas requerem autenticação via token. O token deve ser configurado no arquivo `config.json` na raiz do projeto:

```json
{
    "api_token": "seu_token_aqui",
    "logs_enabled": true
}
```

O token deve ser enviado no corpo da requisição JSON como primeiro elemento de uma tupla [token, dados].

Por exemplo:
```json
[
    "LecKh4OdOTzps3PpBCQsLTVpnkFCNjs8",
    { "dados": "aqui" }
]
```

## 1. Criar Usuário
**Endpoint:** `POST /criar`

### Payload
```json
[
    "LecKh4OdOTzps3PpBCQsLTVpnkFCNjs8",
    {
        "login": "usuario1",
        "senha": "senha123",
        "dias": 30,
        "limite": 1,
        "uuid": null,
        "tipo": "xray"
    }
]
```

### Exemplo com curl
```bash
curl -X POST http://127.0.0.1:9001/criar \
-H "Content-Type: application/json" \
-d '[
    "LecKh4OdOTzps3PpBCQsLTVpnkFCNjs8",
    {
        "login": "usuario1",
        "senha": "senha123",
        "dias": 30,
        "limite": 1,
        "uuid": null,
        "tipo": "xray"
    }
]'
```

## 2. Excluir Usuário
**Endpoint:** `POST /excluir`

### Payload
```json
[
    "LecKh4OdOTzps3PpBCQsLTVpnkFCNjs8",
    {
        "usuario": "usuario1",
        "uuid": null
    }
]
```

### Exemplo com curl
```bash
curl -X POST http://127.0.0.1:9001/excluir \
-H "Content-Type: application/json" \
-d '[
    "LecKh4OdOTzps3PpBCQsLTVpnkFCNjs8",
    {
        "usuario": "usuario1",
        "uuid": null
    }
]'
```

## 3. Excluir Múltiplos Usuários
**Endpoint:** `POST /excluir_global`

### Payload
```json
[
    "LecKh4OdOTzps3PpBCQsLTVpnkFCNjs8",
    {
        "usuarios": [
            {
                "usuario": "usuario1",
                "uuid": null
            },
            {
                "usuario": "usuario2",
                "uuid": "123e4567-e89b-12d3-a456-426614174000"
            }
        ]
    }
]
```

### Exemplo com curl
```bash
curl -X POST http://127.0.0.1:9001/excluir_global \
-H "Content-Type: application/json" \
-d '[
    "LecKh4OdOTzps3PpBCQsLTVpnkFCNjs8",
    {
        "usuarios": [
            {
                "usuario": "usuario1",
                "uuid": null
            },
            {
                "usuario": "usuario2",
                "uuid": "123e4567-e89b-12d3-a456-426614174000"
            }
        ]
    }
]'
```
