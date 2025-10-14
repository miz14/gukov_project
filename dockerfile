FROM python:3.13-slim

WORKDIR /app

COPY bots/req.txt bots/

RUN pip install -r bots/req.txt

COPY . .

CMD ["python", "bots/bot1/main.py"]