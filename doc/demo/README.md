## Demo recording guide (k3d + AsciiArtify)

Цей каталог призначений для зберігання демо‑записів (asciinema або GIF) у стилі презентації з README проєктів на GitHub (натхнення: [dive README demo](https://github.com/wagoodman/dive?tab=readme-ov-file)).

### Варіант A: asciinema → GIF
1) Запис CLI‑сесії:
```bash
asciinema rec demo.cast
# виконайте:
#   k3d cluster create asciiartify -p "8080:80@loadbalancer"
#   docker build -t asciiartify:local .
#   k3d image import asciiartify:local -c asciiartify
#   kubectl apply -f k8s/
#   curl -s http://localhost:8080 | head -n 5
#   k3d cluster delete asciiartify
# і далі Ctrl-D для завершення
```
2) Конвертація у GIF (приклад з `agg` або `asciicast2gif`):
```bash
docker run --rm -v $PWD:/data ghcr.io/asciinema/agg:latest \
  -i /data/demo.cast -o /data/asciiartify-k3d-demo.gif
```
3) Перекладіть `asciiartify-k3d-demo.gif` у цей каталог і переконайтесь, що воно показується у `../Concept.md`.

### Варіант B: пряма запис екрана → GIF
Запишіть термінал (1080p, темна тема), обріжте до 10–20 секунд, збережіть як `asciiartify-k3d-demo.gif`.


