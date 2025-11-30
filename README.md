## AsciiArtify PoC

Простий веб‑додаток, що перетворює текст у ASCII‑арт (Flask + pyfiglet), контейнеризований і підготовлений для локального розгортання в Kubernetes (k3d).

### Локальний запуск (Python)
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app/app.py
# відкрийте http://localhost:8000
```

### Збірка контейнера
```bash
docker build -t asciiartify:local .
docker run --rm -p 8000:8000 asciiartify:local
```

### Розгортання у k3d
```bash
make k3d-up           # створити кластер (порт 8080=>LB:80)
make docker-build     # зібрати образ
make k3d-load         # завантажити образ у кластер k3d
make k8s-apply        # застосувати манифести (Namespace/Deployment/Service/Ingress)
# відкрийте http://localhost:8080
```

### Прибирання
```bash
make k3d-down
```

### Структура
```
AsciiArtify/
├─ app/
│  └─ app.py
├─ k8s/
│  ├─ namespace.yaml
│  ├─ deployment.yaml
│  ├─ service.yaml
│  └─ ingress.yaml
├─ scripts/
│  └─ k3d-demo.sh
├─ doc/
│  └─ Concept.md
├─ Dockerfile
├─ Makefile
├─ requirements.txt
├─ .dockerignore
└─ .gitignore
```


