# 📊 Bovespa Data Batch Pipeline

Pipeline de dados em lote para coleta e processamento de dados da Bovespa usando AWS (Lambda, Glue, S3 e CloudWatch).

## 📋 Guia de Instalação e Execução (Passo a Passo)

Este guia apresenta a sequência **EXATA** de passos para configurar e executar o pipeline de dados da Bovespa.

### 📝 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

1. **AWS CLI** - [Guia de instalação](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. **Terraform** - [Guia de instalação](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3. **Docker** - [Guia de instalação](https://docs.docker.com/engine/install/)
4. **Git** - Para clonar este repositório

## 🚀 Passo a Passo Completo

### Passo 1: Configurar Credenciais AWS
#### Opção 1
```bash
# Edite o arquivo de credenciais AWS
nano ~/.aws/credentials

# Adicione suas credenciais no formato:
[default]
aws_access_key_id = SUA_KEY
aws_secret_access_key = SUA_SECRET
aws_session_token = SEU_TOKEN   # caso temporário
```

#### Opção 2
```bash
# Exporte suas credenciais AWS para o terminal
export AWS_ACCESS_KEY_ID="SUA_KEY"
export AWS_SECRET_ACCESS_KEY="SUA_SECRET_KEY"
export AWS_SESSION_TOKEN="SEU_TOKEN" # caso temporário
```

### Passo 2: Configurar todas as variáveis de ambiente
```bash
# Cole no terminal preenchendo com suas informações
# Variáveis para o ECR
export AWS_REGION="us-east-1" # Altere conforme sua região
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export LAMBDA_REPO_BITCOIN="lambda-bitcoin-libs" # Nome do repo ECR a ser criado
export FUNCAO_LAMBDA_BITCOIN="bitcoin-backup-assync" # Nome da função lambda que será criada
export LAMBDA_REPO_BOVESPA="lambda-libs" # Nome do repo ECR a ser criado
export FUNCAO_LAMBDA_BOVESPA="daily-lambda-bovespa" # Nome da fição lambda que será criada

# Variáveis para o terraform
export TF_VAR_create_new_role_daily_lambda_bovespa=
export TF_VAR_name_role_daily_lambda_bovespa=
export TF_VAR_create_new_role_lambda_glue_activation=
export TF_VAR_name_role_lambda_glue_activation=
export TF_VAR_create_new_glue_job=false
export TF_VAR_name_glue_job=
export TF_VAR_create_new_role_glue_job=
export TF_VAR_name_glue_job_role=
export TF_VAR_create_new_ec2_profile_role=
export TF_VAR_instance_profile_role_name=
export TF_VAR_create_new_firehose_role=
export TF_VAR_create_new_role_lambda_bitcoin_backup=
export TF_VAR_role_firehose=
export TF_VAR_role_lambda_backup_name=
```
As variáveis com informações já preenchidas acima (exceto AWS_REGION) estão com os valores definidos para serem compatíveis com o código, caso seja necessário altera-las, deve ser feito a alteração também das variáveis do .tfvars (LAMBDA_REPO_BITCOIN e LAMBDA_REPO_BOVESPA) E/OU DO NOME DOS LAMBDAS NO main.tf (FUNCAO_LAMBDA_BITCOIN e FUNCAO_LAMBDA_BOVESPA)

### Passo 3: Criar Bucket S3 para o Terraform State

É necessário criar um Bucket no S3 manualmente para armazenar o Terraform State, coloque o nome do bucket de `terraform-state-bucket-bovespa-{SEU-ACCOUNT-ID}`.

### Passo 4: Configurar o Backend do Terraform

```bash
# Edite o arquivo version.tf com o nome do bucket criado
nano IaC/version.tf

# Modifique a seção backend para:
backend "s3" {
  bucket = "terraform-state-bucket-bovespa-SEU-ACCOUNT-ID" # Substituindo por seu account ID
  key    = "infra/tfstate_file.tfstate"
  region = "us-east-1"
}
```

### Passo 5: Criar Repositório ECR para os Lambdas e Enviar as Imagens Docker para o ECR

```bash
# Vá para a pasta do lambda 1
cd IaC/scripts/lambda-scripts/daily-lambda-bovespa

# Crie o repositório ECR
aws ecr create-repository --repository-name $LAMBDA_REPO_BOVESPA --region $AWS_REGION

# Faça login no ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Construa a imagem Docker
docker build -t $LAMBDA_REPO_BOVESPA .

# Crie a tag para o ECR
docker tag $LAMBDA_REPO_BOVESPA:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$LAMBDA_REPO_BOVESPA:latest

# Envie a imagem para o ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$LAMBDA_REPO_BOVESPA:latest

# Volte para o diretório raiz do projeto
cd ../../../../

# Vá para a pasta do outro lambda para subir o outro container
cd IaC/scripts/lambda-scripts/bitcoin-backup-assync-lambda

# Crie o repositório ECR
aws ecr create-repository --repository-name $LAMBDA_REPO_BITCOIN --region $AWS_REGION

# Faça login no ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Construa a imagem Docker
docker build -t $LAMBDA_REPO_BOVESPA .

# Crie a tag para o ECR
docker tag $LAMBDA_REPO_BITCOIN:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$LAMBDA_REPO_BITCOIN:latest

# Envie a imagem para o ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$LAMBDA_REPO_BITCOIN:latest
```

### Passo 6: Inicializar e Aplicar o Terraform

```bash
# Navegue até o diretório IaC
cd IaC

# Inicialize o Terraform
terraform init

# Verifique o plano de execução
terraform plan

# Aplique as mudanças
terraform apply
```

Confirme digitando `yes` quando solicitado.

### Passo 7: Atualizar Código da Lambda no ECR (Opcional)

1. Modifique os arquivos em `IaC/scripts/lambda-scripts/daily-lambda-bovespa/app/` ou `IaC/scripts/lambda-scripts/bitcoin-backup-assync-lambda`
2. Execute o processo de atualização:

```bash
cd IaC/scripts/lambda-scripts/daily-lambda-bovespa
# ou
cd IaC/scripts/lambda-scripts/bitcoin-backup-assync-lambda

make deploy
```

### Passo 8: Acessar a Instância do EC2 (Opcional)
```bash
# Criar par de chaves na AWS
aws ec2 create-key-pair --key-name chave-ec2-stream --query 'KeyMaterial' --output text > ~/.ssh/chave-ec2-stream.pem

# Definir permissões corretas
chmod 400 ~/.ssh/chave-ec2-stream.pem

# Conectar à instância EC2
ssh -i ~/.ssh/chave-ec2-stream.pem ec2-user@IP_PUBLICO_DA_INSTÂNCIA
```
Obs: O IP público da instância aparece no final do resultao do comando `terraform apply` e também pode ser pego pelo console.

## 📚 Links Úteis

* 📖 [Terraform Docs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* 📘 [AWS ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
* 🔬 [API Bovespa](https://www.b3.com.br/pt_br/market-data-e-indices/)
* 🐳 [Docker Docs](https://docs.docker.com/)