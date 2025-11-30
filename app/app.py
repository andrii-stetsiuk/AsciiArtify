from flask import Flask, request, render_template_string
import pyfiglet

app = Flask(__name__)

INDEX_HTML = """
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>AsciiArtify</title>
    <style>
      body { font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif; margin: 2rem; }
      pre { background: #111; color: #0f0; padding: 1rem; overflow: auto; }
      form { display: grid; gap: 0.5rem; max-width: 560px; }
      input, select, button { padding: 0.5rem; font-size: 1rem; }
    </style>
  </head>
  <body>
    <h1>AsciiArtify</h1>
    <form method="post">
      <input name="text" placeholder="Hello, World!" value="{{text}}" />
      <label>
        Font:
        <select name="font">
          <option value="">standard</option>
          {% for f in fonts %}
          <option value="{{f}}" {% if f==font %}selected{% endif %}>{{f}}</option>
          {% endfor %}
        </select>
      </label>
      <button type="submit">Render</button>
    </form>
    <h2>Result</h2>
    <pre>{{art}}</pre>
  </body>
  </html>
"""


@app.get("/healthz")
def healthz():
    return "ok", 200


@app.route("/", methods=["GET", "POST"])
def index():
    text = request.form.get("text", "Hello, AsciiArtify!")
    font = request.form.get("font", "standard")
    try:
        art = pyfiglet.figlet_format(text, font=font if font else "standard")
    except Exception:
        art = pyfiglet.figlet_format(text, font="standard")
    # обмежимо список для UI, повний список може бути дуже довгим
    fonts = sorted(pyfiglet.FigletFont.getFonts())[:50]
    return render_template_string(INDEX_HTML, art=art, text=text, font=font, fonts=fonts)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)


