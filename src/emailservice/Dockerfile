FROM python:3.11-slim

WORKDIR /app

COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the default email service port
EXPOSE 8080

CMD ["python", "email_server.py"]
