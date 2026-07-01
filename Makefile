IMAGE     ?= myshell-openvoice-docker
TAG       ?= latest
CONTAINER ?= openvoice
PORT      ?= 7860
URL       := http://localhost:$(PORT)

.DEFAULT_GOAL := help

.PHONY: help build up down restart run logs shell ps clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build . --file Dockerfile --tag $(IMAGE):$(TAG)

up: ## Start the container (detached) and print the UI URL
	docker run -d -p $(PORT):7860 --name $(CONTAINER) $(IMAGE):$(TAG)
	@echo ""
	@echo "  OpenVoice UI is starting — open: \033[1;32m$(URL)\033[0m"
	@echo "  (first load can take ~30-60s; follow logs with: make logs)"

down: ## Stop and remove the container
	-docker stop $(CONTAINER)
	-docker rm $(CONTAINER)

restart: down up ## Restart the container

run: ## Run in the foreground (Ctrl-C to stop, auto-removed on exit)
	docker run -it --rm -p $(PORT):7860 --name $(CONTAINER) $(IMAGE):$(TAG)

logs: ## Follow container logs
	docker logs -f $(CONTAINER)

shell: ## Open a shell inside the running container
	docker exec -it $(CONTAINER) bash

ps: ## Show container status
	docker ps -a --filter name=$(CONTAINER)

clean: down ## Remove the container and the image
	-docker rmi $(IMAGE):$(TAG)
