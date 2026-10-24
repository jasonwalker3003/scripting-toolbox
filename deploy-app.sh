#!/bin/bash
# deploy-app.sh: installs a Spring Boot jar as a systemd service, then checks it answers.
# Run it on the server as root, e.g. from your PC: ssh jason@IP 'sudo bash -s' < deploy-app.sh
# Optional argument: the jar's URL. Without one it uses your newest build-tools-demo release.
set -euo pipefail

REPO=https://github.com/jasonwalker3003/build-tools-demo
URL=${1:-$REPO/releases/latest/download/demo-0.0.1-SNAPSHOT.jar}
APP_DIR=/opt/demo
export DEBIAN_FRONTEND=noninteractive

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this as root (sudo)."
  exit 2
fi

if ! command -v java > /dev/null; then
  cloud-init status --wait > /dev/null || true
  apt-get -o DPkg::Lock::Timeout=300 update -q < /dev/null
  apt-get -o DPkg::Lock::Timeout=300 install -y -q openjdk-21-jre-headless < /dev/null
fi

id demo > /dev/null 2>&1 || useradd --system --home-dir "$APP_DIR" --create-home \
  --shell /usr/sbin/nologin demo
curl -fsSL -o /tmp/demo.jar "$URL"
install -o demo -g demo -m 644 /tmp/demo.jar "$APP_DIR/demo.jar"
rm -f /tmp/demo.jar

cat > /etc/systemd/system/demo.service <<'EOF'
[Unit]
Description=Demo Spring Boot app
After=network.target

[Service]
User=demo
WorkingDirectory=/opt/demo
ExecStart=/usr/bin/java -jar /opt/demo/demo.jar
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable demo
systemctl restart demo

echo "Waiting for the app to answer on port 8080..."
for _ in $(seq 1 30); do
  if curl -fs -o /dev/null http://localhost:8080/; then
    echo "Deployed: $(curl -s http://localhost:8080/)"
    exit 0
  fi
  sleep 3
done
echo "The app didn't answer within 90 seconds. Look at: journalctl -u demo -n 30"
exit 1
