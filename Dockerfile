FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    iptables \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://tailscale.com/install.sh | sh

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app

COPY backend ./backend

RUN cd backend && uv sync

EXPOSE 10000

ENV TAILSCALE_AUTH_KEY=${TAILSCALE_AUTH_KEY}

CMD ["sh", "-c", "tailscaled --tun=userspace-networking & sleep 5 && tailscale up --authkey=$TAILSCALE_AUTH_KEY --accept-routes --hostname=deer-flow-render && echo 'Tailscale IP:' && tailscale ip -4 && cd backend && uv run uvicorn src.gateway.app:app --host 0.0.0.0 --port 10000"]
