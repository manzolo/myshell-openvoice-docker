# Usa l'immagine di base di Ubuntu
FROM ubuntu:22.04

# Aggiorna il sistema e installa le dipendenze necessarie
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo \
    python3.9 \
    python3-distutils \
    python3-pip \
    ffmpeg \
    git

# Aggiorna pip
RUN pip install --upgrade pip

# Imposta il working directory nel container
WORKDIR /app

# Installa openai-whisper
RUN git clone https://github.com/myshell-ai/OpenVoice openvoice

RUN pip install gradio==3.50.2 langid faster-whisper whisper-timestamped unidecode eng-to-ipa pypinyin cn2an

# Imposta il working directory nel container
WORKDIR /app/openvoice

RUN pip install -e .
RUN pip install soundfile librosa inflect jieba silero

RUN apt -y install -qq aria2 unzip
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/OpenVoice/resolve/main/checkpoints_1226.zip -d /app/openvoice -o checkpoints_1226.zip
RUN unzip /app/openvoice/checkpoints_1226.zip 
RUN mv /app/openvoice/checkpoints /app/openvoice/openvoice/checkpoints 
RUN mv /app/openvoice/resources /app/openvoice/openvoice/resources 

EXPOSE 7860

RUN sed -i "s/demo.launch(debug=True, show_api=True, share=args.share)/demo.launch(server_name='0.0.0.0', debug=True, show_api=True, share=args.share)/" /app/openvoice/openvoice/openvoice_app.py

WORKDIR /app/openvoice/openvoice

# Comando di default quando il container viene avviato
CMD ["python3", "-m", "openvoice_app" ,"--share"]
