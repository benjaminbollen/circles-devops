#!/bin/sh

sudo apt install ufw
sudo ufw default deny incoming
sudo ufw allow 22/tcp
sudo ufw allow 30303
sudo ufw allow 9000
sudo ufw default allow outgoing
sudo ufw enable

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

cd /srv
mkdir -p /srv/gnosis/execution
mkdir /srv/gnosis/jwtsecret

multiline_string=$(cat <<EOF
version: "3"
services:
  execution:
    container_name: execution
    image: nethermind/nethermind:latest
    restart: always
    stop_grace_period: 1m
    networks:
      - gnosis_net
    ports:
      - 30303:30303/tcp # p2p
      - 30303:30303/udp # p2p
    expose:
      - 8545 # rpc
      - 8551 # engine api
    volumes:
      - /srv/gnosis/execution:/data
      - /srv/gnosis/nethermind_plugins:/nethermind/plugins
      - /srv/gnosis/jwtsecret/jwt.hex:/jwt.hex
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    command: |
      --config=gnosis
      --datadir=/data
      --log=INFO
      --Sync.SnapSync=false
      --JsonRpc.Enabled=true
      --JsonRpc.Host=0.0.0.0
      --JsonRpc.Port=8545
      --JsonRpc.EnabledModules=[Web3,Eth,Subscribe,Net,]
      --JsonRpc.JwtSecretFile=/jwt.hex
      --JsonRpc.EngineHost=0.0.0.0
      --JsonRpc.EnginePort=8551
      --Network.DiscoveryPort=30303
      --HealthChecks.Enabled=false
      --Pruning.CacheMb=2048
    logging:
      driver: "local"


  consensus:
    container_name: consensus
    image: sigp/lighthouse:latest-modern
    restart: always
    networks:
      - gnosis_net
    ports:
      - 9000:9000/tcp # p2p
      - 9000:9000/udp # p2p
      - 5054:5054/tcp # metrics
    expose:
      - 4000 # http
    volumes:
      - /srv/gnosis/consensus/data:/data
      - /srv/gnosis/jwtsecret/jwt.hex:/jwt.hex
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    command: |
      lighthouse
      beacon_node
      --network=gnosis
      --disable-upnp
      --datadir=/data
      --port=9000
      --http
      --http-address=0.0.0.0
      --http-port=4000
      --execution-endpoint=http://execution:8551
      --execution-jwt=/jwt.hex
      --checkpoint-sync-url=https://checkpoint.gnosischain.com/
    logging:
      driver: "local"

networks:
  gnosis_net:
    name: gnosis_net
EOF
)

echo "$multiline_string" > /srv/docker-compose.yml

openssl rand -hex 32 | tr -d "\n" > "/srv/gnosis/jwtsecret/jwt.hex"