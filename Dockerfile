FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl && apt-get clean

RUN pip install uv

RUN adduser --disabled-password --gecos '' appuser

COPY requirements.txt .

RUN uv pip install --system -r requirements.txt

COPY . .

RUN chown -R appuser:appuser /app

RUN python manage.py migrate

RUN python manage.py collectstatic --noinput

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["gunicorn", "demo.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "120", "--max-requests", "500"]