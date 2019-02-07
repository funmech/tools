FROM python:3.6-alpine

RUN pip install -U Flask

WORKDIR /app
COPY flask-app.py /app/app.py

CMD ["python", "app.py"]