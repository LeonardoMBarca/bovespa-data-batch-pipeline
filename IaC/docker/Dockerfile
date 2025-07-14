FROM public.ecr.aws/lambda/python:3.11 as build

# Atualiza e instala zip
RUN yum install -y gcc gcc-c++ make zip tar gzip

# Diretório de trabalho
WORKDIR /opt

# Copia o requirements.txt
COPY lambda-layers/requirements.txt .

# Instala pacotes no formato Lambda
RUN pip3 install --upgrade pip && \
    pip3 install --only-binary=:all: -r requirements.txt -t python/

# Compacta a pasta python
RUN zip -r9 /opt/layer_env.zip python/

# Exporta apenas o zip
FROM scratch as export
COPY --from=build /opt/layer_env.zip /layer_env.zip
