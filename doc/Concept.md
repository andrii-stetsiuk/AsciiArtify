## Concept: Local Kubernetes options for AsciiArtify PoC (minikube vs kind vs k3d)

### Вступ
Розглядаємо три популярні інструменти для локальних Kubernetes‑кластерів:
- minikube — офіційний інструмент від Kubernetes SIGs, акцент на простоту локального девелопменту та аддони.
- kind — Kubernetes in Docker, чудово підходить для CI та швидкого підняття багато-вузлових кластерів.
- k3d — легковажний кластер на базі k3s (Kubernetes від Rancher) поверх Docker; дуже швидкий старт, невеликий footprint.

Мета: обрати інструмент для PoC стартапу “AsciiArtify” з фокусом на швидкість старту, простоту, стабільність і можливість подальшої автоматизації.

### Характеристики (порівняльна таблиця)

| Критерій | minikube | kind | k3d |
|---|---|---|---|
| Підтримка ОС/арх | Linux, macOS, Windows; x86_64/arm64 | Linux, macOS, Windows; x86_64/arm64 | Linux, macOS, Windows; x86_64/arm64 |
| Рантайм/драйвер | Docker, Podman, QEMU/HyperKit/VirtualBox (залежно від ОС) | Docker/Podman (контейнери) | Docker (k3s всередині) |
| Старт кластера | Швидкий, але важчий ніж kind/k3d у деяких конфігураціях | Дуже швидкий | Дуже швидкий (часто найшвидший) |
| Багатовузловість | Так | Так (через конфіг) | Так (простий прапор/конфіг) |
| Ingress | Аддон `ingress` (NGINX) | Ручне налаштування (часто NGINX/Traefik) | Traefik у k3s за замовчуванням |
| LoadBalancer | `minikube tunnel` або Metallb‑addon | Потрібен Metallb або порти на нодах | Мапінг портів на вбудований LB (`-p "host:80@loadbalancer"`) |
| Локальний реєстр | `minikube addons enable registry` | Приклади локреєстру (окремий контейнер) | Вбудовані команди `k3d registry create/use` |
| Аддони | Багато вбудованих аддонів | Немає “аддонів” як таких | Функціонал k3s (Traefik, servicelb) |
| Автоматизація | CLI + деякі конфіги | Відмінні declarative‑конфіги кластера | CLI + конфіг‑файли |
| CI‑френдлі | Добре | Чудово (стандарт де-факто) | Чудово |
| Ресурсний слід | Середній | Середній/низький | Низький (k3s) |
| Документація/комʼюніті | Сильні | Сильні | Сильні |

### Переваги та недоліки
- minikube
  - Переваги: офіційний, великий набір аддонів, працює на різних драйверах, простий старт.
  - Недоліки: інколи важчий/повільніший за kind/k3d; різні драйвери можуть додати варіативність у поведінці.
- kind
  - Переваги: дуже швидкий в CI, детермінований, потужні конфіг‑файли для топологій (multi‑node, extraMounts, порт‑мапінг).
  - Недоліки: немає “аддонів” з коробки; для Ingress/LB потрібні додаткові кроки.
- k3d
  - Переваги: найменший footprint (k3s), дуже швидкий, Traefik та servicelb за замовчуванням, простий порт‑мапінг і локреєстр.
  - Недоліки: базується на k3s (не 100% ідентичний “повному” kube), вимагає Docker.

### Рекомендація для PoC “AsciiArtify”
Для швидкого PoC з локальною розробкою і мінімальним тертям рекомендуємо k3d:
- миттєвий старт і низькі вимоги (k3s),
- простий доступ з хоста через порт‑мапінг,
- готовий Ingress‑контролер (Traefik).

kind — ідеальний вибір для CI та відтворюваних середовищ тестування.
minikube — чудовий для навчання та сценаріїв, де важлива гнучкість аддонів і різні драйвери.

---

### Демонстрація: “Hello World” на k3d

Передумови: встановлені Docker, kubectl, k3d.

1) Створити кластер (1 server, 1 agent) з мапінгом порту 8080 на LB:

```bash
k3d cluster create asciiartify \
  --servers 1 --agents 1 \
  -p "8080:80@loadbalancer"
```

2) Розгорнути простий hello‑сервіс (nginxdemos/hello):
```bash
kubectl create deployment hello --image=nginxdemos/hello
kubectl expose deployment hello --port 80 --target-port 80 --type ClusterIP
```

3) Створити Ingress (Traefik у k3s активний за замовчуванням):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello
spec:
  rules:
    - host: localhost
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: hello
                port:
                  number: 80
```

```bash
kubectl apply -f ingress.yaml
```

4) Перевірка:
```bash
curl -sS http://localhost:8080 | head -n 5
```
Очікування: відповідь “Welcome to nginx!”/“Hello from...” сторінка прикладу.

5) Прибирання:
```bash
k3d cluster delete asciiartify
```

Вбудоване демо:

<video src="demo/asciiartify-k3d-demo.mp4" controls muted playsinline poster="demo/asciiartify-k3d-demo.gif" width="960">
  Your browser does not support the video tag. See GIF below.
</video>

_Fallback (GIF if video is not present):_

![k3d asciiartify demo](demo/asciiartify-k3d-demo.gif)

Посилання на демо‑запис (asciinema/GIF) у каталозі `doc/demo/`. Формат і подача натхнені прикладом у репозиторії `dive` — інструмент для аналізу шарів Docker‑образу [див. README demo секцію](https://github.com/wagoodman/dive?tab=readme-ov-file).

---

### Висновки
- k3d — найкращий вибір для PoC “AsciiArtify”: швидкий, легкий, із зручним доступом і готовим Ingress.
- kind — рекомендовано для CI та автоматизованого тестування багатовузлових конфігурацій.
- minikube — гарний варіант для навчання та випадків, де корисні численні аддони та різноманітні драйвери.

Рекомендація: стартувати з k3d для локального PoC, а для CI додати кластери на kind. Це забезпечить швидкість розробки та відтворюваність тестів.

## Concept: Локальний Kubernetes для PoC “AsciiArtify” — minikube vs kind vs k3d

### Вступ
Для локальної розробки та PoC на Kubernetes найпопулярніші інструменти:
- **minikube**: локальний одно/багато-вузловий кластер Kubernetes, працює поверх різних драйверів (Docker, HyperKit/Hyper-V, VirtualBox тощо) і має корисні аддони (Ingress, Dashboard).
- **kind** (Kubernetes in Docker): запускає кластер(и) Kubernetes всередині контейнерів Docker. Простий, швидкий, ідеальний для CI, максимально близький до «ванільного» Kubernetes.
- **k3d**: обгортка для запуску легковажного Kubernetes-дистрибутиву **k3s** у Docker. Дуже швидкий старт, корисні дефолти (локальне сховище, вбудований Ingress Controller Traefik).

Ціль — обрати інструмент для PoC стартапу “AsciiArtify” з огляду на швидкість, простоту, можливості автоматизації та підтримку.

### Характеристики

| Характеристика | minikube | kind | k3d |
| --- | --- | --- | --- |
| Підтримувані ОС | macOS, Linux, Windows | macOS, Linux, Windows | macOS, Linux, Windows |
| Архітектури CPU | amd64, arm64 | amd64, arm64 | amd64, arm64 |
| Залежність від Docker | Необов’язково (є різні драйвери) | Обов’язково | Обов’язково |
| Тип кластера | Повноцінний kubeadm-кластер | Ванільний K8s у контейнерах | k3s (легковажний K8s) у контейнерах |
| Мультивузловість | Так | Так | Так |
| Швидкість старту | Середня | Висока | Дуже висока |
| Аддони з коробки | Dashboard, Ingress, ін. | Ні (все встановлюємо вручну) | Traefik Ingress, local-path storage у k3s |
| StorageClass за замовч. | Є (minikube) | Потрібно налаштувати | Є (k3s local-path) |
| Ingress | Аддон (nginx) | Встановлюється окремо | Traefik у k3s |
| LoadBalancer локально | `minikube tunnel` | Потрібно MetalLB/інше | k3s ServiceLB (klipper) + порт-мапінг k3d |
| Автоматизація (CI) | Можлива, але важчий старт | Відмінна для CI | Відмінна для dev і CI |
| Керування кількома кластерами | Так | Так (через config) | Так |
| Документація/спільнота | Дуже широка | Дуже широка | Широка (k3s/k3d) |

### Переваги та недоліки
- **minikube**
  - Переваги: багатий набір аддонів; працює без Docker; дружній для початківців; зрозумілі команди (`minikube service`, `minikube tunnel`).
  - Недоліки: старт повільніший; більше «важить»; у CI вимагає додаткових кроків.
- **kind**
  - Переваги: дуже швидкий; максимально наближений до ванільного Kubernetes; ідеальний для CI; reproducible кластери з YAML-конфігами.
  - Недоліки: немає аддонів за замовч.; Ingress/Storage/LoadBalancer — встановлювати окремо; потребує Docker.
- **k3d**
  - Переваги: найшвидший dev‑цикл; k3s дає локальне сховище та Traefik; простий порт‑мапінг; зручний для демо/PoC.
  - Недоліки: це k3s (не «ванільний» Kubernetes); інколи відмінності у поведінці/фічах порівняно з upstream.

### Демонстрація (рекомендовано: k3d)
Нижче — коротке демо розгортання «Hello World» у кластері, створеному через k3d. Обрано k3d, бо він максимально швидкий і дає потрібні дефолти (Ingress Traefik, локальне сховище) для PoC.

Попередні вимоги:
- Встановлений Docker
- macOS/Linux/Windows

Створення кластера:

```bash
# macOS (через Homebrew)
brew install k3d

# Створити кластер з порт-мапінгом LB: хост:8080 -> кластер:80
k3d cluster create asciiartify \
  --agents 1 --servers 1 \
  -p "8080:80@loadbalancer"

kubectl cluster-info
kubectl get nodes -o wide
```

Маніфест «Hello World» (Deployment + Service + Ingress, Traefik у k3s обробить Ingress):

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: asciiartify
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello
  namespace: asciiartify
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
        - name: http-echo
          image: hashicorp/http-echo:0.2.3
          args:
            - "-text=Hello, AsciiArtify"
          ports:
            - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: hello
  namespace: asciiartify
spec:
  selector:
    app: hello
  ports:
    - name: http
      port: 5678
      targetPort: 5678
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello
  namespace: asciiartify
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: hello
                port:
                  number: 5678
```

Застосування та перевірка:

```bash
kubectl apply -f hello.yaml
kubectl -n asciiartify get all

# Перевірка відповіді (Ingress слухає на порту 80, який ми пробросили на 8080)
curl -s http://localhost:8080
# Очікувано: "Hello, AsciiArtify"
```

Альтернативи для Ingress/експозиції:
- minikube: `minikube addons enable ingress`, `minikube service <name> -n <ns> --url`
- kind: встановити ingress-nginx або Traefik, опрацювати NodePort/port-forward

### Висновки та рекомендації
- **Для PoC “AsciiArtify” рекомендується k3d**: найшвидший старт, мінімум налаштувань, дефолтні компоненти (Traefik, local-path storage), простий порт‑мапінг. Ідеально для швидких демо і локальних сценаріїв.
- **kind** — якщо важлива максимальна сумісність із ванільним Kubernetes або інтеграція з CI-пайплайнами, де критична повторюваність середовища.
- **minikube** — зручний для навчання/воркшопів, має аддони і GUI Dashboard, гнучкий щодо гіпервізорів, але може бути повільнішим і важчим для автоматизації.



