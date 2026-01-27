# Gemini Code Assistant Context

This document provides context for the Gemini Code Assistant to understand and effectively assist with this project.

## Project Overview

This project provides a Dockerized environment for running "OpenVoice," a voice manipulation and conversion tool developed by MyShell AI.

The core of the project is the `Dockerfile`, which automates the setup of a complete and isolated environment for OpenVoice. This ensures that the application runs consistently across different machines without complex manual configuration.

### Key Technologies

*   **Docker:** The project is containerized using Docker, with a `Dockerfile` that defines the environment.
*   **Python:** The OpenVoice application and its dependencies are written in Python.
*   **Ubuntu:** The Docker container is based on the Ubuntu 22.04 operating system.

### Architecture

The `Dockerfile` performs the following steps:

1.  **Base Image:** Starts with a clean `ubuntu:22.04` image.
2.  **System Dependencies:** Installs essential system libraries, including Python 3.9, `ffmpeg`, and `git`.
3.  **Python Environment:** Upgrades `pip` and sets up the working directory.
4.  **Source Code:** Clones the official OpenVoice repository from GitHub.
5.  **Python Dependencies:** Installs the required Python packages from `requirements.txt`.
6.  **Model Checkpoints:** Downloads the pre-trained model checkpoints necessary for OpenVoice to function.
7.  **Application Patch:** Applies a small fix to the Gradio interface to ensure it's accessible from outside the container.
8.  **Entrypoint:** Sets the default command to launch the OpenVoice Gradio web application.

## Building and Running

### Building the Docker Image

To build the Docker image, use the following command from the project root directory:

```bash
docker build -t myshell-openvoice .
```

### Running the Application

To run the OpenVoice application, execute the following command:

```bash
docker run -it -p 7860:7860 myshell-openvoice
```

Once the container is running, you can access the OpenVoice web interface by navigating to `http://localhost:7860` in your web browser.

## Development Conventions

*   **Dependency Management:** Python dependencies are managed via the `requirements.txt` file. To add or update a dependency, modify this file and rebuild the Docker image.
*   **Environment Configuration:** The entire development and runtime environment is defined within the `Dockerfile`. Any changes to the environment, such as installing new system packages, should be made in the `Dockerfile`.
*   **Continuous Integration:** The `.github/workflows/docker-image.yml` file defines a simple CI pipeline that builds the Docker image on every push and pull request to the `main` branch. This helps ensure that the `Dockerfile` is always in a working state.
