# capim-whats-web

UI estilo WhatsApp Web para atendimento via WhatsApp Cloud API (Meta Graph API).

## Stack

- Ruby 3.4.9 (ver `.ruby-version`)
- Rails 8 + Hotwire (Turbo Streams via ActionCable)
- PostgreSQL (usado também para Solid Cable / Solid Queue / Solid Cache)
- Tailwind + Importmap
- Kamal para deploy

## Setup

```bash
bin/setup        # instala gems, cria o banco, roda migrações
bin/dev          # sobe Rails + Tailwind watcher + Solid Queue (Procfile.dev)
```

A app sobe em `http://localhost:3000`. Raiz (`/`) é a inbox (`conversations#index`).

### Pré-requisitos locais

- PostgreSQL rodando (banco `capim_whats_web_development` é criado pelo `bin/setup`)
- `mise` ou equivalente para Ruby 3.4.9

## Variáveis de ambiente

Copie `.env.example` para `.env` e preencha:

| Var | Obrigatória | Descrição |
| --- | --- | --- |
| `WHATSAPP_PHONE_NUMBER_ID` | sim | ID do número registrado na WhatsApp Business Platform |
| `WHATSAPP_BUSINESS_ACCOUNT_ID` | sim | WABA ID (usado pra sincronizar templates) |
| `WHATSAPP_API_VERSION` | não | Versão da Graph API. Default: `v21.0` |

Em produção, também:

| Var | Descrição |
| --- | --- |
| `CAPIM_WHATS_WEB_DATABASE_PASSWORD` | Senha do Postgres de produção |
| `RAILS_MASTER_KEY` | Chave pra descriptografar `config/credentials.yml.enc` |

## Credentials (Rails encrypted credentials)

Rode `bin/rails credentials:edit` e adicione:

```yaml
whatsapp:
  access_token: SEU_TOKEN_DA_META           # Token do System User (permanente) ou temporário pra testes
  app_secret: APP_SECRET_DO_APP_META        # usado pra validar HMAC dos webhooks
  verify_token: STRING_QUE_VOCE_ESCOLHER    # tem que bater com o que você configurar no painel da Meta

# Opcional — só se usar S3 pro Active Storage em produção
aws:
  access_key_id: ...
  secret_access_key: ...
```

> **Nota:** o `config/credentials.yml.enc` desse repo é novo e vazio — nada foi copiado de outro projeto. Você vai precisar criar seus próprios credentials e guardar o `config/master.key` em lugar seguro (ele está no `.gitignore`).

## Webhook do WhatsApp

Endpoint: `/webhooks/whatsapp`

- `GET` — handshake de verificação da Meta (usa `whatsapp.verify_token`)
- `POST` — eventos (valida HMAC com `whatsapp.app_secret`)

Pra desenvolvimento local, exponha a porta via ngrok/cloudflared e configure a URL pública no painel da Meta → WhatsApp → Configuration → Webhooks.

## Testes

```bash
bin/rails test
bin/rubocop
bin/brakeman
bin/bundler-audit
```

Ou tudo de uma vez: `bin/ci`.

## Deploy

Via Kamal (`config/deploy.yml` + `.kamal/secrets`). `RAILS_MASTER_KEY` é lido de `config/master.key` localmente — não commite essa chave.
