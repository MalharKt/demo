FROM python:3.13

WORKDIR /app

# Copy application files
COPY main.py requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Command to execute the script
CMD ["python", "main.py"]

