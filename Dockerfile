FROM ubuntu:22.04

# System deps + build tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo python3.10 python3.10-distutils python3-pip ffmpeg git pkg-config \
    libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev \
    libswscale-dev libswresample-dev libavfilter-dev aria2 unzip \
    build-essential python3.10-dev gcc g++ \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

WORKDIR /app
RUN git clone https://github.com/myshell-ai/OpenVoice openvoice
WORKDIR /app/openvoice

# Copy only runtime requirements
COPY requirements.txt .

# === Install build dependencies first ===
RUN pip install --no-cache-dir "cython<3.0.0" numpy
RUN pip install --no-cache-dir . --no-build-isolation
RUN pip install --no-cache-dir -r requirements.txt

# Download checkpoints
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M \
    https://huggingface.co/camenduru/OpenVoice/resolve/main/checkpoints_1226.zip \
    -d /app/openvoice -o checkpoints_1226.zip \
 && unzip /app/openvoice/checkpoints_1226.zip \
 && mv checkpoints openvoice/checkpoints \
 && mv resources openvoice/resources \
 && rm checkpoints_1226.zip

EXPOSE 7860

# Fix Gradio bind
RUN sed -i "s/demo.launch(/demo.launch(server_name='0.0.0.0', /" openvoice/openvoice_app.py

WORKDIR /app/openvoice/openvoice
CMD ["python3", "-m", "openvoice_app", "--share"]