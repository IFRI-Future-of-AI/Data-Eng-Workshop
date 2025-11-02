FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt /app/

RUN pip install uv
RUN uv pip install -r requirements.txt --system

COPY . .

CMD ["uv", "run", "python", "app.py"]