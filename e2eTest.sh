if [ -d "${PWD}/configFiles" ]; then
    KUBECONFIG_FOLDER=${PWD}/configFiles
else
    echo "Configuration files are not found."
    exit
fi

# Generate channel artifacts using configtx.yaml and then create channel
echo -e "\nCreating channel transaction artifact and a channel"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/create_channel.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/create_channel.yaml

JOBSTATUS=$(kubectl get jobs -A|grep createchannel |awk '{print $3}')
while [ "${JOBSTATUS}" != "1/1" ]; do
    echo "Waiting for createchannel job to be completed"
    sleep 1;
    if [ "$(kubectl get pods -n temp| grep createchannel | awk '{print $3}')" == "Error" ]; then
        echo "Create Channel Failed"
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs -A|grep createchannel |awk '{print $3}')
done
echo "Create Channel Completed Successfully"

# Join all peers on a channel
echo -e "\nCreating joinchannel job"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/join_channel.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/join_channel.yaml

JOBSTATUS=$(kubectl get jobs -A|grep joinchannel |awk '{print $3}')
while [ "${JOBSTATUS}" != "1/1" ]; do
    echo "Waiting for joinchannel job to be completed"
    sleep 1;
    if [ "$(kubectl get pods -n temp| grep joinchannel | awk '{print $3}')" == "Error" ]; then
        echo "Join Channel Failed"
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs -A|grep joinchannel |awk '{print $3}')
done
echo "Join Channel Completed Successfully"

# Install chaincode on each peer
echo -e "\nCreating installchaincode job"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/chaincode_install.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/chaincode_install.yaml

JOBSTATUS=$(kubectl get jobs -A|grep chaincodeinstall |awk '{print $3}')
while [ "${JOBSTATUS}" != "1/1" ]; do
    echo "Waiting for chaincodeinstall job to be completed"
    sleep 1;
    if [ "$(kubectl get pods -n temp| grep chaincodeinstall | awk '{print $3}')" == "Error" ]; then
        echo "Chaincode Install Failed"
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs -A|grep chaincodeinstall |awk '{print $3}')
done
echo "Chaincode Install Completed Successfully"


# Instantiate chaincode on channel
echo -e "\nCreating chaincodeinstantiate job"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/chaincode_instantiate.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/chaincode_instantiate.yaml

JOBSTATUS=$(kubectl get jobs -A|grep chaincodeinstantiate |awk '{print $3}')
while [ "${JOBSTATUS}" != "1/1" ]; do
    echo "Waiting for chaincodeinstantiate job to be completed"
    sleep 1;
    if [ "$(kubectl get pods -n temp| grep chaincodeinstantiate | awk '{print $3}')" == "Error" ]; then
        echo "Chaincode Instantiation Failed"
        exit 1
    fi
    JOBSTATUS=$(kubectl get jobs -A|grep chaincodeinstantiate |awk '{print $3}')
done
echo "Chaincode Instantiation Completed Successfully"

sleep 15
echo -e "\ne2eTest Completed !!"
