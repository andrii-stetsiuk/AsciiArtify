#!/usr/bin/env bash
set -euo pipefail

CLUSTER="${CLUSTER:-asciiartify}"
IMAGE="${IMAGE:-asciiartify:local}"

echo "[1/5] Create k3d cluster: ${CLUSTER}"
k3d cluster create "${CLUSTER}" -p "8080:80@loadbalancer" || true

echo "[2/5] Build image: ${IMAGE}"
docker build -t "${IMAGE}" .

echo "[3/5] Import image into k3d"
k3d image import "${IMAGE}" -c "${CLUSTER}"

echo "[4/5] Apply Kubernetes manifests"
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

echo "[5/5] Test"
sleep 5
set +e
curl -fsS http://localhost:8080 >/dev/null && echo "OK: http://localhost:8080" || echo "Visit http://localhost:8080 after pods become Ready"
set -e


