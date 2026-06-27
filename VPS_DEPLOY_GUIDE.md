# DeepHeal VPS Deployment Guide

This guide walks you through resolving the browser security errors observed when deploying DeepHeal on a VPS over HTTP, and making all features — including the **voice/microphone** — work correctly in production.

---

## ❗ The Problem: Browser Security Headers on HTTP

When you deploy to a public IP (e.g., `http://187.77.14.62:5000`) over **plain HTTP**, modern browsers enforce two important security restrictions:

1. **`Cross-Origin-Opener-Policy` header is ignored**: This header is only respected on **HTTPS** origins. The browser drops it silently on HTTP.

2. **Microphone / Voice Recognition is blocked**: The **Web Speech API** (`speech_to_text` on Flutter Web) requires a *Secure Context* — meaning `https://` or `localhost`. On a plain `http://` VPS IP, the browser will refuse to grant microphone access entirely.

---

## ✅ Solution: Set Up HTTPS with Nginx + Let's Encrypt

### Step 1 — Prerequisites on your VPS
```bash
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx
```

### Step 2 — Point a Domain to your VPS IP
- Buy or use a free domain (e.g., Freenom, DuckDNS).
- Create an **A record** pointing `yourdomain.com` → `187.77.14.62`.
- Wait a few minutes for DNS to propagate.

### Step 3 — Obtain a Free SSL Certificate
```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```
Certbot will automatically edit your Nginx config to enable HTTPS on port 443.

### Step 4 — Nginx Reverse Proxy Configuration

Replace the contents of `/etc/nginx/sites-available/deepheal` with:

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # Redirect all HTTP to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # Flutter Web Frontend (served as static files from build/web)
    location / {
        root /var/www/deepheal/web;
        index index.html;
        try_files $uri $uri/ /index.html;

        # Required COOP/COEP headers for SharedArrayBuffer and Web features
        add_header Cross-Origin-Opener-Policy "same-origin";
        add_header Cross-Origin-Embedder-Policy "require-corp";
    }

    # FastAPI Backend Proxy
    location /api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # CORS headers for API calls from Flutter
        add_header Access-Control-Allow-Origin "*";
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
        add_header Access-Control-Allow-Headers "Content-Type, Authorization";
    }
}
```

Enable and reload:
```bash
sudo ln -sf /etc/nginx/sites-available/deepheal /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### Step 5 — Update the Flutter API URL for Production

In `lib/core/constants/api_constants.dart`, update your `baseUrl` for web:

```dart
static String get baseUrl {
  if (kIsWeb) return "https://yourdomain.com/api";  // ← use your domain + /api prefix
  if (Platform.isAndroid) return "http://10.0.2.2:8000";
  return "http://127.0.0.1:8000";
}
```

### Step 6 — Build and Deploy the Flutter Web App
```bash
# On your local machine:
flutter build web --release

# Copy the build/web folder to your VPS:
scp -r build/web/* user@187.77.14.62:/var/www/deepheal/web/
```

### Step 7 — Run the Backend as a Service
Create `/etc/systemd/system/deepheal.service`:
```ini
[Unit]
Description=DeepHeal FastAPI Backend
After=network.target

[Service]
User=www-data
WorkingDirectory=/home/user/deepheal/backend
ExecStart=/usr/bin/python3 -m uvicorn app.main:app --host 127.0.0.1 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable deepheal
sudo systemctl start deepheal
sudo systemctl status deepheal
```

---

## 🛠️ Testing Voice Feature During Staging (Without a Domain)

If you need to test the **voice/microphone** feature on your VPS IP during staging, use this browser flag in Chrome:

1. Open a new tab and navigate to:
   ```
   chrome://flags/#unsafely-treat-insecure-origin-as-secure
   ```

2. Enable the flag and add your VPS IP with port:
   ```
   http://187.77.14.62:5000
   ```

3. Click **Relaunch**. Chrome will now grant microphone permissions for that specific HTTP origin.

> ⚠️ **This is for development/testing only.** Never use this flag in production.

---

## 📋 Error Reference Table

| Console Error | Cause | Fix |
|---|---|---|
| `Cross-Origin-Opener-Policy header has been ignored` | Page is served over HTTP | Set up HTTPS with Nginx + Certbot |
| `Origin-Agent-Cluster header conflict` | Mixed HTTP/HTTPS headers | Ensure all traffic goes through HTTPS, remove duplicate headers |
| `ERR_CONNECTION_RESET on favicon.ico` | Browser tries HTTPS on HTTP port | Serve app via Nginx on port 443 |
| `Microphone access denied` | HTTP is not a Secure Context | Use HTTPS or the Chrome flag for testing |
| `API key not valid (Gemini)` | Invalid API key in `.env` | Replace with a valid key from [Google AI Studio](https://aistudio.google.com/) |

---

## 🔑 Getting a Valid Gemini API Key

The chatbot will use AI responses when a valid key is present:

1. Visit [https://aistudio.google.com/](https://aistudio.google.com/)
2. Sign in with a Google account
3. Click **"Get API Key"** → **"Create API key in new project"**
4. Copy the key and update `backend/.env`:
   ```env
   GEMINI_API_KEY=your_new_valid_key_here
   ```
5. Restart the backend server for the change to take effect.
