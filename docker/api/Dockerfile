FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install uv
RUN uv pip install -r requirements.txt --system

COPY . .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]