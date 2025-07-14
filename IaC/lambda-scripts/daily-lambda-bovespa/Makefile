REGIÃO ?= $(AWS_REGION)
CONTA ?= $(AWS_ACCOUNT_ID)
REPOSITÓRIO ?= $(LAMBDA_REPO)
IMAGEM_TAG ?= latest
IMAGEM_URI := $(CONTA).dkr.ecr.$(REGIÃO).amazonaws.com/$(REPOSITÓRIO):$(IMAGEM_TAG)

login:
	aws ecr get-login-password --region $(REGIÃO) | docker login --username AWS --password-stdin $(CONTA).dkr.ecr.$(REGIÃO).amazonaws.com

build:
	docker build -t $(IMAGEM_URI) .

push: build login
	docker push $(IMAGEM_URI)

# DESCOMENTE SE QUISER ATUALIZAR A FUNÇÃO LAMBDA AUTOMATICAMENTE SEM PRECISAR DO TERRAFORM
# update-lambda: push
# 	aws lambda update-function-code \
# 		--function-name $(FUNCAO_LAMBDA) \
# 		--image-uri $(IMAGEM_URI) \
# 		--region $(REGIÃO)

deploy: push
