#!/bin/bash

if [ -d "${PWD}/configFiles" ]; then
    KUBECONFIG_FOLDER=${PWD}/configFiles
else
    echo "Configuration files are not found."
    exit
fi

# Creating namespace and service
echo -e "\nCreating namespace"
echo "Running: kubectl apply -f ${KUBECONFIG_FOLDER}/blockchain-namespace.yaml"
kubectl apply -f ${KUBECONFIG_FOLDER}/blockchain-namespace.yaml

echo -e "\nCreating services"
echo "Running: kubectl apply -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml"
kubectl apply -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml

# Creating Persistant Volume
echo -e "\nCreating volume"
if [ "$(kubectl get pvc | grep nfs-pv | awk '{print $2}')" != "Bound" ]; then
    echo "The Persistant Volume does not seem to exist or is not bound"
    echo "Creating Persistant Volume"

    echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/createNfsPV.yaml"
    kubectl create -f ${KUBECONFIG_FOLDER}/createNfsPV.yaml
    sleep 5

    echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/createNfsVolume.yaml"
    kubectl create -f ${KUBECONFIG_FOLDER}/createNfsVolume.yaml
    sleep 5

    if [ "kubectl get pvc | grep nfs-pv | awk '{print $3}'" != "nfs-pv" ]; then
        echo "Success creating Persistant Volume"
    else
        echo "Failed to create Persistant Volume"
    fi
else
    echo "The Persistant Volume exists, not creating again"
fi

# Generate Network artifacts using configtx.yaml and crypto-config.yaml
echo -e "\nGenerating the required artifacts for Blockchain network"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/generateArtifactsJob.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/generateArtifactsJob.yaml

JOBSTATUS=$(kubectl get jobs -A|grep "utils" |awk '{print $3}')
job=$(kubectl get pods --selector=job-name=utils --output=jsonpath={.items..metadata.name} -A)
podSTATUS=$(kubectl get pods --selector=job-name=utils --output=jsonpath={.items..phase} -A)

while [ "${JOBSTATUS}" != "1/1" ]; do
    echo "Wating for container of utils pod to run. Current status of ${job} is ${JOBSTATUS}"
    sleep 5;
    if [ "${podSTATUS}" == "Error" ]; then
        echo "There is an error in utils job. Please check logs."
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs -A|grep "utils" |awk '{print $3}')
done

# Create zookeeper using Kubernetes Deployments
echo -e "\nCreating new Deployment to create three zookeepers and four kafkas in network"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/zookeeper-statefulset.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/zookeeper-statefulset.yaml

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/kafka0.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/kafka0.yaml

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/kafka1.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/kafka1.yaml

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/kafka2.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/kafka2.yaml

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/kafka3.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/kafka3.yaml
echo "Checking if all deployments are ready"

NUMPENDING=$(kubectl get deployments -A | grep fabric-zk-kafka | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments -A | grep fabric-zk-kafka | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
    sleep 1
done

# Create peers, ca, orderer using Kubernetes Deployments
echo -e "\nCreating new Deployment to create two peers in network"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/orderer.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/orderer.yaml

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/peerOrg1.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/peerOrg1.yaml

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/peerOrg2.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/peerOrg2.yaml

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/peerOrg3.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/peerOrg3.yaml

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/peerOrg4.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/peerOrg4.yaml

echo "Checking if all deployments are ready"

NUMPENDING=$(kubectl get deployments -A | grep example-com | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments -A | grep example-com | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
    sleep 1
done

echo "Waiting for 15 seconds for peers and orderer to settle"
sleep 15
echo -e "\nNetwork Setup Completed !!"
