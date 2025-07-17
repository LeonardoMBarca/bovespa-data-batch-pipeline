FROM public.ecr.aws/lambda/python:3.11

COPY requirements.txt .

RUN pip install --upgrade pip \
    && pip install --only-binary=:all: -r requirements.txt 

COPY app ${LAMBDA_TASK_ROOT}

CMD ["main.handler"]