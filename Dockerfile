FROM ubuntu:24.04

# System deps + build tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo software-properties-common ffmpeg git pkg-config \
    libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev \
    libswscale-dev libswresample-dev libavfilter-dev aria2 unzip \
    build-essential gcc g++ \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3.10 python3.10-venv python3.10-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create venv with Python 3.10
RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip

WORKDIR /app
RUN git clone https://github.com/myshell-ai/OpenVoice openvoice
WORKDIR /app/openvoice

# Copy only runtime requirements
COPY requirements.txt .

# === Install build dependencies first ===
RUN pip install --no-cache-dir "cython<3.0.0" numpy
# Install OpenVoice package without deps to avoid pulling older pinned versions
# (e.g. faster-whisper==0.9.0 requires av==10.* which can't build on FFmpeg 6.x)
RUN pip install --no-cache-dir . --no-deps --no-build-isolation
# Install runtime deps from our requirements.txt (unpinned faster-whisper gets latest)
RUN pip install --no-cache-dir -r requirements.txt

# Install MeloTTS (required for OpenVoice V2)
RUN pip install --no-cache-dir git+https://github.com/myshell-ai/MeloTTS.git
RUN python -m unidic download

# Download V1 checkpoints
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M \
    https://huggingface.co/camenduru/OpenVoice/resolve/main/checkpoints_1226.zip \
    -d /app/openvoice -o checkpoints_1226.zip \
 && unzip /app/openvoice/checkpoints_1226.zip \
 && mv checkpoints openvoice/checkpoints \
 && mv resources openvoice/resources \
 && rm checkpoints_1226.zip

# Download V2 checkpoints
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M \
    https://myshell-public-repo-host.s3.amazonaws.com/openvoice/checkpoints_v2_0417.zip \
    -d /app/openvoice -o checkpoints_v2_0417.zip \
 && unzip /app/openvoice/checkpoints_v2_0417.zip -d openvoice/ \
 && rm checkpoints_v2_0417.zip

EXPOSE 7860

# Fix Gradio bind
RUN sed -i "s/demo.launch(/demo.launch(server_name='0.0.0.0', /" openvoice/openvoice_app.py

WORKDIR /app/openvoice/openvoice
CMD ["python", "-m", "openvoice_app", "--share"]
