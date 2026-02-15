# trello-queue-infra

Infraestrutura para receber webhooks do Trello, publicar eventos em uma fila SQS e processar com Lambda. Os artefatos da Lambda ficam em um bucket S3 dedicado. O repositório foi estruturado por ambiente e por modulos reutilizaveis.

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

## Observacoes

- Nenhum recurso deve ser criado manualmente no console.
- As roles do GitHub Actions usam OIDC e restringem o assume role ao repo e branch configurados.