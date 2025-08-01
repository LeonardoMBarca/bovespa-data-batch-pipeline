# Variáveis de ambiente
include .env
export

REGIAO ?= $(AWS_REGION)
CONTA ?= $(AWS_ACCOUNT_ID)
REPOSITORIO ?= $(LAMBDA_REPO_BOVESPA)
LAMBDA_FUNCTION ?= $(FUNCAO_LAMBDA_BOVESPA)
TAG ?= latest
IMAGEM_URI := $(CONTA).dkr.ecr.$(REGIAO).amazonaws.com/$(REPOSITORIO):$(TAG)

# Autenticação no ECR
login:
	aws ecr get-login-password --region $(REGIAO) | docker login --username AWS --password-stdin $(CONTA).dkr.ecr.$(REGIAO).amazonaws.com

# Build limpo (sem cache!)
build: 
	docker build --no-cache -t $(IMAGEM_URI) .

# Push da imagem para o ECR
push: build login
	docker push $(IMAGEM_URI)

# Atualiza a função Lambda com a nova imagem
update-lambda: push
	aws lambda update-function-code \
		--function-name $(LAMBDA_FUNCTION) \
		--image-uri $(IMAGEM_URI) \
		--region $(REGIAO)

# Deploy completo
deploy: update-lambda
