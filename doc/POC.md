## Argo CD POC: Доступ до веб-інтерфейсу

Ця коротка інструкція демонструє, як встановити Argo CD у кластер Kubernetes і отримати доступ до його веб-інтерфейсу. За основу взято приклад з офіційної документації Argo CD ([офіційні інструкції](https://argo-cd.readthedocs.io/en/stable/)).

### Передумови
- Встановлений `kubectl` і доступ до працюючого кластеру Kubernetes.

### Кроки
1) Створіть простір імен для Argo CD та перевірте його наявність:

```bash
kubectl create namespace argocd
kubectl get namespace
```

2) Встановіть Argo CD у простір імен `argocd`:

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

3) Перевірте ресурси та стежте за підняттям подів:

```bash
kubectl get all -n argocd
kubectl get po -n argocd -w
```

4) Прокиньте порт до сервісу `argocd-server` (залиште процес активним):

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443&
```

5) Отримайте початковий пароль користувача `admin` і відкрийте інтерфейс:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

- Ім'я користувача: `admin`
- Пароль: значення з команди вище
- URL інтерфейсу: `https://localhost:8080`

Примітка: сертифікат є самопідписаним — у браузері може знадобитися дозволити з'єднання.

### Додатково
- Після початкового входу рекомендовано змінити пароль адміністратора через UI або CLI.
- Детальніше дивіться у розділах встановлення та доступу в [документації Argo CD](https://argo-cd.readthedocs.io/en/stable/).


