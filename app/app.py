import os
import socket
import pymysql
from flask import Flask, jsonify, render_template_string

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_NAME = os.getenv("DB_NAME", "labdb")
DB_USER = os.getenv("DB_USER", "labuser")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")

APP_MODE = "ECS"
APP_TITLE = "ECS Application Dashboard"
APP_MESSAGE = "ECS app is running"
HOSTNAME = socket.gethostname()

def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        connect_timeout=5,
        cursorclass=pymysql.cursors.DictCursor
    )

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{{ app_title }}</title>
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: Arial, Helvetica, sans-serif;
      background: linear-gradient(135deg, #0f172a, #111827, #1e293b);
      color: #e5e7eb;
      min-height: 100vh;
      padding: 32px;
    }

    .container {
      max-width: 1200px;
      margin: 0 auto;
    }

    .hero {
      background: rgba(255,255,255,0.06);
      border: 1px solid rgba(255,255,255,0.12);
      border-radius: 20px;
      padding: 32px;
      margin-bottom: 24px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.25);
      backdrop-filter: blur(10px);
    }

    .badge {
      display: inline-block;
      padding: 8px 14px;
      background: #2563eb;
      color: white;
      border-radius: 999px;
      font-size: 14px;
      font-weight: bold;
      margin-bottom: 18px;
    }

    h1 {
      font-size: 40px;
      margin-bottom: 12px;
    }

    .subtitle {
      color: #cbd5e1;
      font-size: 18px;
      margin-bottom: 20px;
      line-height: 1.6;
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 20px;
      margin-bottom: 24px;
    }

    .card {
      background: rgba(255,255,255,0.06);
      border: 1px solid rgba(255,255,255,0.12);
      border-radius: 18px;
      padding: 22px;
      box-shadow: 0 8px 20px rgba(0,0,0,0.20);
    }

    .card h2 {
      font-size: 20px;
      margin-bottom: 14px;
      color: #93c5fd;
    }

    .meta-row {
      margin-bottom: 10px;
      color: #d1d5db;
      line-height: 1.6;
      word-break: break-word;
    }

    .route-list {
      list-style: none;
      margin-top: 8px;
    }

    .route-list li {
      padding: 10px 0;
      border-bottom: 1px solid rgba(255,255,255,0.08);
      color: #dbeafe;
    }

    .route-list li:last-child {
      border-bottom: none;
    }

    .btn-row {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      margin-top: 16px;
    }

    button {
      border: none;
      background: #2563eb;
      color: white;
      padding: 12px 16px;
      border-radius: 10px;
      cursor: pointer;
      font-size: 14px;
      font-weight: bold;
      transition: 0.2s ease;
    }

    button:hover {
      background: #1d4ed8;
      transform: translateY(-1px);
    }

    .secondary {
      background: #0f766e;
    }

    .secondary:hover {
      background: #0d9488;
    }

    .output {
      margin-top: 16px;
      background: #020617;
      border: 1px solid rgba(255,255,255,0.12);
      border-radius: 12px;
      padding: 16px;
      min-height: 180px;
      overflow: auto;
      white-space: pre-wrap;
      font-family: Consolas, monospace;
      color: #a7f3d0;
    }

    .footer {
      text-align: center;
      margin-top: 18px;
      color: #94a3b8;
      font-size: 14px;
    }

    .status-good {
      color: #4ade80;
      font-weight: bold;
    }

    .status-warn {
      color: #facc15;
      font-weight: bold;
    }

    .status-bad {
      color: #f87171;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="hero">
      <div class="badge">{{ app_mode }}</div>
      <h1>{{ app_title }}</h1>
      <p class="subtitle">
        {{ app_message }}. This dashboard gives you a clean front end for your Flask routes and lets you test app health and database connectivity in real time.
      </p>

      <div class="grid">
        <div class="card">
          <h2>Application Info</h2>
          <div class="meta-row"><strong>Hostname:</strong> {{ hostname }}</div>
          <div class="meta-row"><strong>DB Host:</strong> {{ db_host }}</div>
          <div class="meta-row"><strong>DB Name:</strong> {{ db_name }}</div>
          <div class="meta-row"><strong>DB User:</strong> {{ db_user }}</div>
        </div>

        <div class="card">
          <h2>Available Routes</h2>
          <ul class="route-list">
            <li><strong>/</strong> - Dashboard page</li>
            <li><strong>/health</strong> - App health check</li>
            <li><strong>/dbcheck</strong> - Database connectivity test</li>
            <li><strong>/info</strong> - App metadata as JSON</li>
          </ul>
        </div>

        <div class="card">
          <h2>Quick Actions</h2>
          <div class="btn-row">
            <button onclick="runCheck('/health')">Test /health</button>
            <button class="secondary" onclick="runCheck('/dbcheck')">Test /dbcheck</button>
            <button onclick="runCheck('/info')">Test /info</button>
          </div>
          <div id="output" class="output">Click a button to test a route.</div>
        </div>
      </div>
    </div>

    <div class="footer">
      Built for your AWS lab: ALB → ECS → Flask → RDS
    </div>
  </div>

  <script>
    async function runCheck(route) {
      const output = document.getElementById("output");
      output.textContent = "Loading " + route + "...";

      try {
        const res = await fetch(route);
        const data = await res.json();
        output.textContent = JSON.stringify(data, null, 2);
      } catch (err) {
        output.textContent = "Request failed:\\n" + err;
      }
    }
  </script>
</body>
</html>
"""

@app.get("/")
def index():
    return render_template_string(
        HTML_TEMPLATE,
        app_mode=APP_MODE,
        app_title=APP_TITLE,
        app_message=APP_MESSAGE,
        hostname=HOSTNAME,
        db_host=DB_HOST,
        db_name=DB_NAME,
        db_user=DB_USER
    )

@app.get("/health")
def health():
    return jsonify({
        "status": "ok",
        "app_mode": APP_MODE,
        "hostname": HOSTNAME
    }), 200

@app.get("/info")
def info():
    return jsonify({
        "app_mode": APP_MODE,
        "message": APP_MESSAGE,
        "hostname": HOSTNAME,
        "db_host": DB_HOST,
        "db_name": DB_NAME,
        "db_user": DB_USER
    }), 200

@app.get("/dbcheck")
def dbcheck():
    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT NOW() AS db_time, DATABASE() AS current_db")
            result = cursor.fetchone()
        conn.close()
        return jsonify({
            "status": "connected",
            "result": result
        }), 200
    except Exception as e:
        return jsonify({
            "status": "failed",
            "error": str(e)
        }), 500