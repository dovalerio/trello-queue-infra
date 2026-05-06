# trello-queue-infra

Infraestrutura como código (Terraform) para o sistema de processamento assíncrono de webhooks do Trello. Recebe eventos via API Gateway HTTP v2, publica em SQS e processa com Lambda. Cada ambiente (dev/homolog/prod) é independente, com estado remoto no S3 e lock no DynamoDB.

Repositório da aplicação: [trello-queue-publisher](https://github.com/dovalerio/trello-queue-publisher)

## Arquitetura

```
Trello Webhook
      │
      ▼
┌─────────────────────┐
│  API Gateway HTTP v2 │  POST /  (payload_format_version 2.0)
│                     │  HEAD /  (validação do webhook)
└──────────┬──────────┘
           │  Lambda Proxy
           ▼
┌─────────────────────┐
│   Lambda Function   │  Runtime: python3.13
│ trello-queue-pub..  │  Artefato via S3 (versionado)
└──────────┬──────────┘
           │  SendMessage
           ▼
┌─────────────────────┐     ┌──────────────────────┐
│     SQS Queue       │────▶│   SQS Dead-Letter     │
│  (fila principal)   │     │   Queue (DLQ)         │
│  maxReceiveCount: 3 │     │   Retenção: 14 dias   │
└─────────────────────┘     └──────────────────────┘

Artefatos Lambda:
┌─────────────────────┐
│    S3 Bucket        │  Bucket isolado por ambiente
│  (artifacts)        │  Referenciado pelo Terraform
└─────────────────────┘

CI/CD (GitHub Actions → AWS):
┌─────────────────────┐
│   OIDC Role         │  Sem credenciais estáticas
│  (IAM)              │  Restrito a repo + branch
└─────────────────────┘
```

## Requisitos

- Terraform >= 1.6
- AWS Provider ~> 5

## Estrutura

- Modulos reutilizaveis em `modules/`
- Ambientes em `env/` (dev, homolog, prod)

## Como inicializar

Escolha o ambiente e inicialize:

```bash
terraform -chdir=env/dev init
```

Se preferir informar backend via CLI:

```bash
terraform -chdir=env/dev init \
	-backend-config="bucket=trello-dev-tfstate" \
	-backend-config="key=trello/dev/terraform.tfstate" \
	-backend-config="region=us-east-1" \
	-backend-config="dynamodb_table=trello-dev-tfstate-lock"
```

## Como planejar

```bash
terraform -chdir=env/dev plan \
	-var="lambda_artifact_key=artifacts/trello-queue-publisher.zip"
```

## Como aplicar

```bash
terraform -chdir=env/dev apply \
	-var="lambda_artifact_key=artifacts/trello-queue-publisher.zip"
```

## Como promover versao da Lambda

1) Gere o artefato no repositiorio do app.
2) Envie para o bucket de artefatos do ambiente alvo.
3) Atualize a chave do artefato no Terraform:

```bash
terraform -chdir=env/dev apply \
	-var="lambda_artifact_key=artifacts/trello-queue-publisher-2026-02-15.zip"
```

Se voce usa versionamento de objeto no S3, pode fixar a versao com `lambda_artifact_object_version`.

## Promocao entre ambientes

- Atualize a chave do artefato (ou a versao) no ambiente desejado.
- Rode `plan` e `apply` no diretorio do ambiente correspondente.

## Modulos

| Módulo | Responsabilidade |
|---|---|
| `s3` | Bucket de artefatos da Lambda, por ambiente |
| `sqs` | Fila principal + DLQ com redrive policy configurável |
| `lambda` | Função com permissão de leitura SQS e trigger event source mapping |
| `api-gateway` | HTTP API v2, rotas POST e HEAD, integração Lambda proxy |
| `iam` | Role OIDC para GitHub Actions, least-privilege |

## Observacoes

- Nenhum recurso deve ser criado manualmente no console.
- As roles do GitHub Actions usam OIDC e restringem o assume role ao repo e branch configurados.
- A DLQ retém mensagens por 14 dias; após 3 falhas na fila principal a mensagem é redirecionada automaticamente.