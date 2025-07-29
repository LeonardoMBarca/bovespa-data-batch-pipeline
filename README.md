# 📈 Bovespa Data Pipeline

Pipeline de dados automatizado para coleta, processamento e análise de dados da Bovespa e Bitcoin, utilizando AWS Lambda, S3, Glue, Athena e Kinesis.

## 🏗️ Arquitetura

O projeto implementa uma arquitetura serverless na AWS com os seguintes componentes:

- **AWS Lambda**: Funções para coleta diária de dados da Bovespa e backup de dados Bitcoin
- **Amazon S3**: Armazenamento de dados brutos e processados (Data Lake)
- **AWS Glue**: ETL para transformação e catalogação dos dados
- **Amazon Athena**: Consultas SQL nos dados processados
- **Amazon Kinesis**: Streaming de dados Bitcoin em tempo real
- **Amazon EC2**: Instância para processamento de streams
- **CloudWatch**: Agendamento e monitoramento

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Docker](https://docs.docker.com/get-docker/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.0)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## 🚀 Configuração e Deploy

### 1. Configuração das Credenciais AWS

Configure suas credenciais AWS:

```bash
aws configure
```

Ou exporte as variáveis de ambiente:

```bash
export AWS_ACCESS_KEY_ID="sua-access-key"
export AWS_SECRET_ACCESS_KEY="sua-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 2. Criação do Bucket para Terraform State

Crie um bucket S3 para armazenar o estado do Terraform:

```bash
aws s3 mb s3://terraform-state-bucket-bovespa-SEU-ACCOUNT-ID
```

**⚠️ IMPORTANTE**: Edite o arquivo `IaC/version.tf` e altere o nome do bucket para o seu:

```hcl
backend "s3" {
  bucket = "terraform-state-bucket-bovespa-SEU-ACCOUNT-ID"
  key    = "infra/tfstate_file.tfstate"
  region = "us-east-1"
}
```

### 3. Configuração das Variáveis de Ambiente

Na pasta raiz do projeto:

```bash
cp .env.exemple .env
```

Edite o arquivo `.env` com suas configurações:

```bash
export AWS_ACCESS_KEY_ID="sua-access-key"
export AWS_SECRET_ACCESS_KEY="sua-secret-key"
export AWS_SESSION_TOKEN=""  # Se usando SSO
export TF_VAR_create_new_role_daily_lambda_bovespa=false
export TF_VAR_name_role_daily_lambda_bovespa="sua-role-existente"
# ... outras variáveis
```

### 4. Deploy dos Containers Lambda

#### 4.1 Lambda Daily Bovespa

```bash
cd IaC/scripts/lambda-scripts/daily-lambda-bovespa/
cp .env.exemple .env
```

Edite o `.env` com suas configurações:

```bash
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID=123456789012
export LAMBDA_REPO="lambda-libs"
export FUNCAO_LAMBDA="daily-lambda-bovespa"
```

Faça o deploy:

```bash
make deploy
cd ../../../../
```

#### 4.2 Lambda Bitcoin Backup

```bash
cd IaC/scripts/lambda-scripts/bitcoin-backup-assync-lambda/
cp .env.exemple .env
```

Edite o `.env` com suas configurações:

```bash
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID=123456789012
export LAMBDA_REPO="lambda-bitcoin-libs"
export FUNCAO_LAMBDA="bitcoin-backup-assync"
```

Faça o deploy:

```bash
make deploy
cd ../../../../
```

### 5. Deploy da Infraestrutura

```bash
cd IaC/
terraform init
terraform plan
terraform apply
```

Confirme com `yes` quando solicitado.

## 📊 Como Usar

Após o deploy completo:

1. **Dados da Bovespa**: Coletados automaticamente todos os dias via CloudWatch Events
2. **Dados Bitcoin**: Stream contínuo processado via Kinesis
3. **Consultas**: Use o Athena para consultar os dados processados
4. **Monitoramento**: Acompanhe via CloudWatch Logs

## 🗂️ Estrutura do Projeto

```
bovespa-data-pipeline/
├── IaC/                          # Infraestrutura como Código
│   ├── modules/                  # Módulos Terraform
│   ├── scripts/
│   │   ├── lambda-scripts/       # Código das funções Lambda
│   │   └── glue-script/          # Scripts do AWS Glue
│   └── *.tf                      # Arquivos Terraform
├── .env.exemple                  # Exemplo de variáveis de ambiente
└── README.md
```

## 🧹 Limpeza

Para destruir toda a infraestrutura:

```bash
cd IaC/
terraform destroy
```

## 📝 Notas Importantes

- Os containers Lambda devem ser enviados ao ECR **antes** do `terraform apply`
- Certifique-se de ter as permissões necessárias na AWS
- O bucket de state do Terraform deve ser único globalmente
- Mantenha suas credenciais AWS seguras e nunca as commite no repositório

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor, abra uma issue ou pull request.

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.