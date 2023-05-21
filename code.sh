#!/bin/bash

#** Docker Engine **

#Setup Repo:

sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://protect-us.mimecast.com/s/IpezCv2rKEsMWwO3IQDrMi?domain=download.docker.com | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://protect-us.mimecast.com/s/DVQoCwpvMGFYLl0WcqY4ON?domain=download.docker.com \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


#Install Docker Engine:

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo docker run hello-world



#** Kubernetes (kubectl) **

curl -LO "https://protect-us.mimecast.com/s/xsxxCxkwOJurJEm3uYlJoD?domain=dl.k8s.io(curl -L -s https://protect-us.mimecast.com/s/KXt2CyPxQKI9NO6RsRHOtc?domain=dl.k8s.io)/bin/linux/amd64/kubectl"

curl -LO "https://protect-us.mimecast.com/s/TIQRCzpyVLFJRW8AfoMZuP?domain=dl.k8s.io(curl -L -s https://protect-us.mimecast.com/s/KXt2CyPxQKI9NO6RsRHOtc?domain=dl.k8s.io)/bin/linux/amd64/kubectl.sha256"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client --output=yaml



#** Golang **

curl -OL https://protect-us.mimecast.com/s/9Lg7CADgj0c79przTMsvAT?domain=go.dev

sha256sum go1.19.3.linux-amd64.tar.gz

sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz

echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

source ~/.bashrc

go version



#** kinD **

curl -Lo ./kind https://protect-us.mimecast.com/s/RNL1CBBjlkcEVWPOTvIQhJ?domain=kind.sigs.k8s.io

chmod +x ./kind

sudo mv ./kind /usr/local/bin/kind




#** start kinD **

rm openfaas-cluster.yaml

touch openfaas-cluster.yaml

echo -e "# three node (two workers) cluster config\nkind: Cluster\napiVersion: https://protect-us.mimecast.com/s/XljhCDklpmugBYjkFBWs6F?domain=kind.x-k8s.io role: control-plane\n- role: worker\n- role: worker" >> openfaas-cluster.yaml

kind create cluster --config=openfaas-cluster.yaml

kubectl cluster-info --context kind-kind



#** Install Arkade **

curl -SLsf https://protect-us.mimecast.com/s/m3T2CERmrnuRW41NhyqJCv?domain=get.arkade.dev | sudo sh



#** Install OpenFaas **

arkade install openfaas



#** check deployments **

kubectl get deployments -n openfaas -l "release=openfaas, app=openfaas"

#** configure OpenFaaS **

kubectl rollout status -n openfaas deploy/gateway

kubectl port-forward -n openfaas svc/gateway 8080:8080 &

jobs

PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)



#** FaaS-CLI Setup **

curl -SLsf https://protect-us.mimecast.com/s/1UZpCG6oypFjJ3WQUWJTWK?domain=cli.openfaas.com | sudo sh





#*** Function initialization and manipulation ***

mkdir -p ~/functions && \
  cd ~/functions

faas-cli new pyfunc --lang python3

faas-cli build -f ./pyfunc.yml

docker images | grep pyfunc

docker login --username [Enter Username]

faas-cli push -f ./pyfunc.yml

echo -n $PASSWORD | faas-cli login --username admin --password-stdin

faas-cli deploy -f ./pyfunc.yml

echo "Done!"
