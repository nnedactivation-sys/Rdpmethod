FROM ubuntu:22.04

# Install everything
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xrdp \
    firefox \
    chromium-browser \
    curl \
    wget \
    git \
    nano \
    neofetch \
    python3 \
    python3-pip \
    dbus-x11 \
    && apt-get clean

# Set password
RUN echo 'root:Ankit@990_12' | chpasswd

# Configure xrdp
RUN sed -i 's/port=3389/port=3389/g' /etc/xrdp/xrdp.ini
RUN echo "xfce4-session" > /root/.xsession

# Install Ngrok (SECRET INGREDIENT)
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc
RUN echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list
RUN apt-get update && apt-get install -y ngrok

# Health check (24/7)
RUN echo '#!/usr/bin/env python3\n\
from http.server import HTTPServer, BaseHTTPRequestHandler\n\
class Handler(BaseHTTPRequestHandler):\n\
    def do_GET(self):\n\
        self.send_response(200)\n\
        self.end_headers()\n\
        self.wfile.write(b"RDP Running - Railway Pro")\n\
HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()' > /health.py

# Startup script - TERA TOKEN LAGA DIYA HAI 🔥
RUN echo '#!/bin/bash\n\
echo "========================================="\n\
echo "🔥 SECRET RAILWAY RDP STARTING..."\n\
echo "========================================="\n\
\n\
# Start DBus\n\
dbus-daemon --system --fork\n\
\n\
# Start xrdp\n\
service xrdp start\n\
echo "✅ RDP started on port 3389"\n\
\n\
# Start health check\n\
python3 /health.py &\n\
\n\
# NGROK - TERA TOKEN LAGA DIYA\n\
ngrok authtoken "2tLAaTQjgqZhsGfrodHInnr8LiB_84RDyhP1N3gBR2GoLoNMA"\n\
ngrok tcp 3389 --log=stdout > /tmp/ngrok.log &\n\
\n\
sleep 5\n\
echo "========================================="\n\
echo "🎯 NGROK URL:"\n\
curl -s http://localhost:4040/api/tunnels | grep -o "tcp://[0-9a-z.-]*:[0-9]*" | head -1 || echo "Waiting for URL... Check logs"\n\
echo "========================================="\n\
neofetch\n\
echo "========================================="\n\
echo "🎉 SECRET RDP READY!"\n\
echo "🔑 PASSWORD: Ankit@990_12"\n\
echo "🌐 NGROK URL: Check above or run: curl localhost:4040/api/tunnels"\n\
echo "========================================="\n\
tail -f /dev/null' > /start.sh

RUN chmod +x /start.sh

EXPOSE 3389 8080 4040

CMD ["/start.sh"]
