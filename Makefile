IMAGE ?= asciiartify:local
CLUSTER ?= asciiartify

.PHONY: help
help:
	@echo "Targets:"
	@echo "  docker-build   - build Docker image ($(IMAGE))"
	@echo "  docker-run     - run container locally on :8000"
	@echo "  k3d-up         - create k3d cluster ($(CLUSTER)) with 8080->LB:80"
	@echo "  k3d-load       - import local image into k3d cluster"
	@echo "  k8s-apply      - apply k8s manifests (namespace,deployment,service,ingress)"
	@echo "  k3d-down       - delete k3d cluster"
	@echo "  clean          - remove python caches"

.PHONY: docker-build
docker-build:
	docker build -t $(IMAGE) .

.PHONY: docker-run
docker-run:
	docker run --rm -p 8000:8000 $(IMAGE)

.PHONY: k3d-up
k3d-up:
	k3d cluster create $(CLUSTER) -p "8080:80@loadbalancer"

.PHONY: k3d-load
k3d-load:
	k3d image import $(IMAGE) -c $(CLUSTER)

.PHONY: k8s-apply
k8s-apply:
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml
	kubectl apply -f k8s/ingress.yaml

.PHONY: k3d-down
k3d-down:
	k3d cluster delete $(CLUSTER)

.PHONY: clean
clean:
	find . -name "__pycache__" -type d -prune -exec rm -rf '{}' +
	find . -name "*.pyc" -delete


