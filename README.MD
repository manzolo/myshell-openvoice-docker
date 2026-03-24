# OpenVoice Docker Setup

<a href="https://www.buymeacoffee.com/manzolo">
  <img src=".github/workflows/blue-button.png" alt="Buy Me A Coffee" width="200">
</a>

![Version](https://img.shields.io/badge/version-2.0-blue)

This project is a **Docker wrapper** for [OpenVoice](https://github.com/myshell-ai/OpenVoice) by MyShell AI. It provides a convenient way to run OpenVoice inside a Docker container on an Ubuntu base image, without modifying the upstream application code.

> **Note:** This repository only packages the upstream OpenVoice application. Any bugs or feature requests related to the OpenVoice application itself should be reported to the [upstream repository](https://github.com/myshell-ai/OpenVoice/issues), not here.

## Prerequisites

Before you can use this Docker image, you need to have Docker installed on your system.

### Installing Docker

Follow the instructions on the [official Docker website](https://docs.docker.com/get-docker/) to install Docker for your operating system.

## Usage
To build the Docker image, use the following command:

```bash
docker build -t myshell-openvoice .
```

## Running OpenVoice
To run OpenVoice with the Docker image, you can use the following example command:

```bash
docker run -it -p 7860:7860 myshell-openvoice
```

Now you have a Docker container ready to run the OpenVoice application. Access the OpenVoice application at http://localhost:7860 in your web browser.


## References
- [OpenVoice MyShell GitHub Repository](https://github.com/myshell-ai/OpenVoice)

- [Docker Official Website](https://docs.docker.com/get-docker/)

Feel free to explore and adapt this Docker image based on your specific use case and requirements. For more details on OpenAI Whisper and its usage, refer to the official documentation.
