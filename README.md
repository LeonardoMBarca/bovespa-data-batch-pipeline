# Bovespa Data Batch Pipeline

Pipeline de dados em lote para coleta e processamento de dados da Bovespa usando AWS.


## Instalação do Terraform

- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli


## Arquitetura da Infraestrutura

### Componentes AWS

- **S3 Bucket**: `datalake-pregao-bovespa` - Armazenamento dos dados
- **Lambda Functions**:
  - `daily_lambda_bovespa` - Coleta diária de dados (execução às 12:00 UTC)
  - `lambda_glue_activation` - Ativação do job Glue quando novos arquivos chegam
- **CloudWatch Events**: Agendamento da execução diária
- **IAM Roles**: Permissões específicas para cada Lambda

### Fluxo de Dados

1. **Coleta**: Lambda executa diariamente via CloudWatch Event
2. **Armazenamento**: Dados salvos no S3 (pasta `raw/`)
3. **Processamento**: S3 trigger ativa Lambda que inicia job Glue
4. **Transformação**: Glue processa arquivos `.parquet`

## Configuração

### 1. Credenciais AWS

Configure o arquivo `~/.aws/credentials` com suas credenciais:

```ini
[default]
aws_access_key_id = <sua_access_key>
aws_secret_access_key = <sua_secret_key>
aws_session_token = <seu_session_token>
```

### 2. Variáveis de Ambiente (Opcional)

Para evitar criar o arquivo `terraform.tfvars` ou ter que colocar os valores a mão no terminal, você pode definir as variáveis como variáveis de ambiente. Crie um arquivo para facilitar:

**Linux/Mac (env_vars.sh):**
```bash
#!/bin/bash
export TF_VAR_create_new_role_daily_lambda_bovespa="" # true ou false
export TF_VAR_name_role_daily_lambda_bovespa="" # nome da role
export TF_VAR_create_new_role_lambda_glue_activation="" # true ou false
export TF_VAR_name_role_lambda_glue_activation="" # nome da role
```

Execute:
```bash
source env_vars.sh
```

**Windows (env_vars.bat):**
```batch
set TF_VAR_create_new_role_daily_lambda_bovespa= # true ou false
set TF_VAR_name_role_daily_lambda_bovespa= # nome da role
set TF_VAR_create_new_role_lambda_glue_activation= # true ou false
set TF_VAR_name_role_lambda_glue_activation= # nome da role
```

Execute:
```cmd
env_vars.bat
```

**PowerShell (env_vars.ps1):**
```powershell
$env:TF_VAR_create_new_role_daily_lambda_bovespa="" # true ou false
$env:TF_VAR_name_role_daily_lambda_bovespa= # nome da role
$env:TF_VAR_create_new_role_lambda_glue_activation="" # true ou false
$env:TF_VAR_name_role_lambda_glue_activation= # nome da role
```

Execute:
```powershell
.\env_vars.ps1
```

### 3. Variáveis (terraform.tfvars)

```hcl
create_new_role_daily_lambda_bovespa = true
name_role_daily_lambda_bovespa = "daily-lambda-bovespa-role"
create_new_role_lambda_glue_activation = true
name_role_lambda_glue_activation = "lambda-glue-activation-role"
```

### 4. Deploy

```bash
cd IaC
terraform init
terraform plan
terraform apply
```