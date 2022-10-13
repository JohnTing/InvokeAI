
FROM continuumio/miniconda3:latest

RUN apt update
RUN apt install -y wget curl git

RUN git clone https://github.com/invoke-ai/InvokeAI.git
WORKDIR /InvokeAI
RUN pip install -r requirements.txt
RUN pip cache purge
RUN python3 scripts/preload_models.py
RUN mkdir -p /InvokeAI/models/ldm/stable-diffusion-v1
RUN curl -Lo /InvokeAI/models/ldm/stable-diffusion-v1/model.ckpt https://cloudflare-ipfs.com/ipfs/bafybeicpamreyp2bsocyk3hpxr7ixb2g2rnrequub3j2ahrkdxbvfbvjc4/model.ckpt


RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
RUN tar zxvf ngrok-v3-stable-linux-amd64.tgz

ENV authtoken 1234
ENV port 5000

RUN apt install nginx -y
RUN echo "server { \
    listen 80; server_name _; \
    location / { include proxy_params; proxy_pass http://127.0.0.1:5000; } \
    location /static { alias <path-to-your-application>/static; expires 30d; } \
    location /socket.io { \
        include proxy_params; \
        proxy_http_version 1.1; \
        proxy_buffering off; \
        proxy_set_header Upgrade \$http_upgrade; \
        proxy_set_header Connection \"Upgrade\"; \
        proxy_pass http://127.0.0.1:5000/socket.io; \
    }}" > /etc/nginx/sites-available/default

RUN echo "\n" > startup.sh

RUN echo "service nginx restart \n" > startup.sh
RUN echo "./ngrok config add-authtoken \${authtoken} \n" >> startup.sh
RUN echo "./ngrok http 80 & \n" >> startup.sh
RUN echo "python3 scripts/invoke.py --web --host 0.0.0.0 --port 5000" >> startup.sh
RUN chmod +x startup.sh


# https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-386.tgz

# CMD [ "python3 scripts/invoke.py --web --host 0.0.0.0 --port 9090 &"]

# CMD ["cd /InvokeAI && python3 scripts/invoke.py --web --host 0.0.0.0 --port ${port}"]


CMD ["/bin/bash", "startup.sh"]