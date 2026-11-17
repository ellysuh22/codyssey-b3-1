#!/bin/bash
# EC2 사용자 데이터 (Ubuntu 24.04 LTS)
# 첫 부팅 시 Nginx 설치 + 메인 페이지(/) + 헬스체크(/health) 구성
set -euxo pipefail

apt-get update -y
apt-get install -y nginx

cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html lang="ko">
<head><meta charset="utf-8"><title>Hello Cloud</title></head>
<body style="font-family:sans-serif;text-align:center;margin-top:20vh">
  <h1>Hello Cloud</h1>
  <p>B3-1 · AWS EC2 + Nginx (ap-northeast-2)</p>
</body>
</html>
EOF

cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    location = /health {
        default_type text/plain;
        return 200 "OK\n";
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

nginx -t
systemctl enable nginx
systemctl restart nginx
