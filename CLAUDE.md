# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dockerized environment for running [OpenVoice](https://github.com/myshell-ai/OpenVoice) by MyShell AI — a voice manipulation and conversion tool. The project is a thin Docker wrapper: the `Dockerfile` clones the upstream OpenVoice repo, installs dependencies (including [MeloTTS](https://github.com/myshell-ai/MeloTTS) for V2 support), downloads pre-trained model checkpoints for both V1 and V2, patches Gradio for network accessibility, and exposes a web UI on port 7860.

## Build and Run

```bash
# Build the Docker image
docker build -t myshell-openvoice .

# Run the container (Gradio UI at http://localhost:7860)
docker run -it -p 7860:7860 myshell-openvoice
```

## CI

GitHub Actions (`.github/workflows/docker-image.yml`) runs on push/PR to `main`: builds the image, starts a container, waits 60s, then health-checks with `curl -f http://localhost:7860`.

## Architecture

The project has only a few files — all environment configuration lives in the `Dockerfile`:

- **Dockerfile** — Ubuntu 24.04 base; installs Python 3.10 from the deadsnakes PPA (Ubuntu 24.04's default Python 3.12 is incompatible with upstream dependencies), creates a venv at `/opt/venv`, installs system deps (FFmpeg, build tools), clones OpenVoice, installs Python packages including MeloTTS for V2 support, downloads model checkpoints (V1 + V2) via aria2, patches `openvoice_app.py` to bind Gradio to `0.0.0.0`.
- **requirements.txt** — Python runtime dependencies (Gradio 3.50.2 pinned, faster-whisper, librosa, silero, jieba, pydub, etc.).

### Dockerfile build order (important for layer caching)

1. System packages (`apt-get`) + deadsnakes PPA for Python 3.10
2. Create Python 3.10 venv at `/opt/venv`, add to `PATH`
3. pip upgrade
4. Clone upstream OpenVoice repo to `/app/openvoice`
5. Copy and install `requirements.txt` (local override)
6. Install Cython/NumPy, then OpenVoice package with `--no-build-isolation`
7. Install MeloTTS from git + download unidic data
8. Download and extract V1 model checkpoints to `openvoice/checkpoints` and `openvoice/resources`
9. Download and extract V2 model checkpoints to `openvoice/checkpoints_v2`
10. Patch Gradio server binding
11. Entry: `python -m openvoice_app --share` (uses venv python)

## Development Conventions

- **Dependency changes**: modify `requirements.txt`, then rebuild the Docker image.
- **Environment changes**: modify the `Dockerfile` directly (new system packages, build steps, etc.).
- Build dependencies (`cython<3.0.0`, `numpy`) must be installed before the main OpenVoice package due to `--no-build-isolation`.
- The project supports ARM64 (fixed in commit `6bab03d`).
- Python 3.10 is installed via deadsnakes PPA because Ubuntu 24.04 ships Python 3.12, which is incompatible with Gradio 3.x, numpy==1.22, librosa==0.9.1, and MeloTTS.
- The Gradio web UI (`openvoice_app.py`) uses V1. V2 capabilities (via MeloTTS) are available programmatically through the OpenVoice API.
