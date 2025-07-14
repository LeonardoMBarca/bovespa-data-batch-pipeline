# 📊 Bovespa Data Batch Pipeline

Pipeline de dados em lote para coleta e processamento de dados da Bovespa usando AWS (Lambda, Glue, S3 e CloudWatch).

## 📁 Estrutura do Projeto

```bash
IaC/
├── modules/
│ ├── s3/ # Buckets S3 (state, datalake, scripts)
│ ├── lambda/ # Funções Lambda (coleta e trigger)
│ ├── glue/ # Job de processamento Glue
│ ├── iam/ # Roles e políticas IAM
│ └── cloudwatch/ # Agendamento de eventos
├── main.tf # Orquestração dos módulos
├── variables.tf # Variáveis globais
└── version.tf # Backend e providers
```

## 🔧 Pré-requisitos

### 1. 🔐 Credenciais AWS

Configure no arquivo `~/.aws/credentials`:

```bash
[default]
aws_access_key_id = SUA_KEY
aws_secret_access_key = SUA_SECRET
aws_session_token = SEU_TOKEN   # caso temporário
```

### 2. 🪣 Configurar o Bucket do Terraform (State Remoto)

Antes de iniciar o Terraform:

1. Crie um bucket S3 manualmente.
2. Edite o arquivo `IaC/version.tf` com o nome do bucket:

```bash
backend "s3" {
  bucket = "NOME-DO-SEU-BUCKET"
  key    = "infra/tfstate_file.tfstate"
  region = "us-east-1"
}
```

### 3. 🐳 Docker

Necessário para empacotar a imagem da função Lambda com as dependências (`pandas`, `requests`, `pyarrow`, etc).

Verifique:

```bash
docker --version
```

Instale conforme seu sistema operacional:

* **Linux (Ubuntu)**: [Guia Oficial](https://docs.docker.com/engine/install/ubuntu/)
* **Windows/macOS**: [Docker Desktop](https://docs.docker.com/desktop/)

### 4. ⚙️ Inicialização e Deploy da Infraestrutura

Configure as variáveis de ambiente:

```bash
export TF_VAR_name_role_daily_lambda_bovespa="" # nome da role
export TF_VAR_create_new_role_lambda_glue_activation="" # true ou false
export TF_VAR_name_role_lambda_glue_activation="" # nome da role
export TF_VAR_create_new_glue_job="" # true ou false
export TF_VAR_name_glue_job="" # nome da role
export TF_VAR_create_new_role_glue_job="" # true ou false
export TF_VAR_name_glue_job_role="" # nome da role
```

Configure as variáveis do arquivo `terraform.tfvars` caso deseje alterar o valor das variáveis.

E faça a configuração da infraestrutura com terraform:

```bash
cd IaC
terraform init
terraform plan
terraform apply
```

## 🐍 Lambda com Dependências via Docker + ECR

### Estrutura da Lambda

```bash
lambda-scripts/
└── daily-lambda-bovespa/
    ├── app/
    │   ├── main.py
    │   └── config.py
    ├── requirements.txt
    └── Makefile
```

### 📦 Primeira Configuração (ECR)

Só precisa ser feita uma vez:

```bash
# 1. Fazer login no ECR
aws ecr get-login-password | docker login --username AWS --password-stdin <sua-conta>.dkr.ecr.<sua-regiao>.amazonaws.com

# 2. Criar repositório no ECR
aws ecr create-repository --repository-name <nome-repositorio>

# 3. Construir a imagem Docker
docker build -t <nome-repositorio> .

# 4. Criar tag para o ECR
docker tag <nome-repositorio>:latest <sua-conta>.dkr.ecr.<sua-regiao>.amazonaws.com/<nome-repositorio>:latest

# 5. Enviar imagem para o ECR
docker push <sua-conta>.dkr.ecr.us-east-1.amazonaws.com/<nome-repositorio>:latest
```

### 🔄 Atualização de Imagem (Makefile)

Primeiramente exporte as variáveis de ambiente com as informações necessárias:

```bash
export AWS_REGION=<sua-região>
export AWS_ACCOUNT_ID=<id-da-sua-conta>
export LAMBDA_REPO=<nome-do-seu-repositorio>
```

Após isto execute os comandos:

```bash
cd IaC/lambda-scripts/daily-lambda-bovespa
make deploy
```

Esse comando irá:

* Buildar a imagem Docker
* Fazer login no ECR
* Subir a imagem
* (⚠️ *Não atualizar a função Lambda diretamente*) ← **só será atualizada via `terraform apply`**

### 🧠 Fluxo da Solução

```grmermaid
A[CloudWatch Event] --> B[Lambda Daily]
B --> C[S3 Raw Data]
C --> D[Lambda Glue Trigger]
D --> E[Glue Job]
E --> F[Processed Data]
```

## 📚 Links Úteis

* 📖 [Terraform Docs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* 📘 [AWS ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
* 🔬 [API Bovespa](https://www.b3.com.br/pt_br/market-data-e-indices/)
