FROM python:3.6-alpine

RUN pip install -U Flask requests

WORKDIR /app
COPY flask-app.py /app/app.py

ENV Docker True
CMD ["python", "app.py"]