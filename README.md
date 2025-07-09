# 📊 Bovespa Data Batch Pipeline

> Pipeline de dados em lote para coleta e processamento de dados da Bovespa usando AWS

---

## 🏗️ Arquitetura da Infraestrutura

### 🔧 Componentes AWS

| Serviço | Recurso | Descrição |
|---------|---------|-----------|
| **S3** | `terraform-state-bucket-bovespa-{conta}` | Armazenamento do estado do Terraform |
| **S3** | `datalake-pregao-bovespa` | Armazenamento dos dados coletados |
| **Lambda** | `daily-lambda-bovespa` | Coleta diária de dados (12:00 UTC) |
| **Lambda** | `lambda-glue-activation` | Ativação automática do job Glue |
| **CloudWatch** | Events Rule | Agendamento da execução diária |
| **IAM** | Roles específicas | Permissões para cada Lambda |

### 🔄 Fluxo de Dados

```mermaid
graph LR
    A[CloudWatch Event] --> B[Lambda Daily]
    B --> C[S3 Raw Data]
    C --> D[Lambda Glue Trigger]
    D --> E[Glue Job]
    E --> F[Processed Data]
```

1. **⏰ Agendamento**: CloudWatch Event dispara diariamente às 12:00 UTC
2. **📥 Coleta**: Lambda executa e coleta dados da Bovespa
3. **💾 Armazenamento**: Dados salvos no S3 (pasta `raw/`)
4. **🚀 Trigger**: S3 event ativa Lambda de processamento
5. **⚙️ Transformação**: Glue processa arquivos `.parquet`

---

## ⚙️ Configuração e Deploy

### 📋 Pré-requisitos

#### 1. 🔐 Credenciais AWS

Configure suas credenciais no arquivo `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = <sua_access_key>
aws_secret_access_key = <sua_secret_key>
aws_session_token = <seu_session_token>  # Se usando sessão temporária
```

#### 2. 🪣 State Bucket (OBRIGATÓRIO)

**⚠️ IMPORTANTE**: Antes de executar `terraform init`, você deve:

1. Criar manualmente um bucket S3 para o estado do Terraform
2. Alterar o nome do bucket no arquivo `IaC/version.tf`

```hcl
# IaC/version.tf
backend "s3" {
  bucket = "SEU-BUCKET-TERRAFORM-STATE"  # ← Altere aqui
  key    = "infra/tfstate_file.tfstate"
  region = "us-east-1"
}
```

### 🛠️ Configuração de Variáveis

Escolha **uma** das opções abaixo:

#### Opção A: Arquivo terraform.tfvars (Recomendado)

```hcl
# IaC/terraform.tfvars
create_new_role_daily_lambda_bovespa = true
name_role_daily_lambda_bovespa = "daily-lambda-bovespa-role"
create_new_role_lambda_glue_activation = true
name_role_lambda_glue_activation = "lambda-glue-activation-role"
```

#### Opção B: Variáveis de Ambiente

**🐧 Linux/Mac:**
```bash
# env_vars.sh
#!/bin/bash
export TF_VAR_create_new_role_daily_lambda_bovespa="true"
export TF_VAR_name_role_daily_lambda_bovespa="daily-lambda-bovespa-role"
export TF_VAR_create_new_role_lambda_glue_activation="true"
export TF_VAR_name_role_lambda_glue_activation="lambda-glue-activation-role"

# Executar:
source env_vars.sh
```

**🪟 Windows (CMD):**
```batch
REM env_vars.bat
set TF_VAR_create_new_role_daily_lambda_bovespa=true
set TF_VAR_name_role_daily_lambda_bovespa=daily-lambda-bovespa-role
set TF_VAR_create_new_role_lambda_glue_activation=true
set TF_VAR_name_role_lambda_glue_activation=lambda-glue-activation-role

REM Executar:
env_vars.bat
```

**💙 PowerShell:**
```powershell
# env_vars.ps1
$env:TF_VAR_create_new_role_daily_lambda_bovespa="true"
$env:TF_VAR_name_role_daily_lambda_bovespa="daily-lambda-bovespa-role"
$env:TF_VAR_create_new_role_lambda_glue_activation="true"
$env:TF_VAR_name_role_lambda_glue_activation="lambda-glue-activation-role"

# Executar:
.\env_vars.ps1
```

### 🚀 Deploy da Infraestrutura

```bash
# 1. Navegar para o diretório
cd IaC

# 2. Inicializar Terraform
terraform init

# 3. Planejar mudanças
terraform plan

# 4. Aplicar infraestrutura
terraform apply
```

---

## 🔧 Instalação do Terraform

### 🪟 Windows

1. **📥 Download**
   - Acesse: https://www.terraform.io/downloads
   - Baixe o arquivo ZIP para Windows

2. **⚙️ Instalação**
   ```cmd
   # Extrair terraform.exe para C:\terraform
   # Adicionar C:\terraform ao PATH do sistema
   ```

3. **✅ Verificação**
   ```cmd
   terraform --version
   ```

### 🐧 Linux

**Ubuntu/Debian:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**CentOS/RHEL:**
```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```

**✅ Verificação:**
```bash
terraform --version
```

---

## 📚 Recursos Úteis

- 📖 [Documentação Oficial do Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- 🏗️ [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- 📊 [Bovespa API Documentation](https://www.b3.com.br/pt_br/market-data-e-indices/)

---

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

---

**📝 Nota**: Este pipeline foi desenvolvido para fins educacionais e de demonstração. Certifique-se de revisar as configurações de segurança antes de usar em produção.