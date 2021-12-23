sudo apt remove -y docker docker-engine docker.io
sudo apt remove -y docker-ce docker-ce-cli containerd.io

apt update
apt upgrade

sudo apt install \
    apt-transport-https \
    ca-certificates \
    curl gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt update
sudo apt install -y docker-ce
sudo apt install -y docker-ce-cli
sudo apt install -y containerd.io

docker -v

sudo systemctl enable docker
sudo service docker start

service docker status

sudo mkdir -p /data/portainer

sudo docker run \
    --name portainer \
    -p 9000:9000 \
    -d \
    --restart always \
    -v /data/portainer:/data \
    -v /var/run/docker.sock:/var/run/docker.sock \
    portainer/portainer