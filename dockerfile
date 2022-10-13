
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

ENV authtoken=

# update torch for rtx 3090
RUN pip install torch==1.12.0+cu116 torchvision==0.13.0+cu116 torchaudio==0.12.0 --extra-index-url https://download.pytorch.org/whl/cu116
RUN pip cache purge

RUN echo "\n" > startup.sh
# RUN echo "service nginx restart \n" > startup.sh
RUN echo "./ngrok config add-authtoken \${authtoken} \n" >> startup.sh
RUN echo "./ngrok http 5000 & \n" >> startup.sh
RUN echo "python3 scripts/invoke.py --web --host 0.0.0.0 --port 5000" >> startup.sh
RUN chmod +x startup.sh

# window.location.protocol
COPY frontend/dist/assets/index.989a0ca2.js frontend/dist/assets/index.989a0ca2.js
CMD ["/bin/bash", "startup.sh"]
