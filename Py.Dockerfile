# Basic Python Dockerfile
FROM python:3.6-alpine

WORKDIR /code

RUN rm -rf /var/cache/apk/* && \
  rm -rf /tmp/* && \
  apk update

RUN apk add -U --no-cache build-base && \
  apk --purge del build-base && \
  rm -rf /var/cache/apk/* /tmp/*

COPY pseduo_module.py $WORKDIR
ENV PYTHONPATH $PYTHONPATH:/code
ENTRYPOINT ["python"]
