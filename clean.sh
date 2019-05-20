
KUBECONFIG_FOLDER=${PWD}/configFiles

kubectl delete -f ${KUBECONFIG_FOLDER}/chaincode_instantiate.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/chaincode_install.yaml

kubectl delete -f ${KUBECONFIG_FOLDER}/join_channel.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/create_channel.yaml

kubectl delete -f ${KUBECONFIG_FOLDER}/zookeeper-statefulset.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/kafka0.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/kafka1.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/kafka2.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/kafka3.yaml

kubectl delete -f ${KUBECONFIG_FOLDER}/orderer.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/peerOrg1.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/peerOrg2.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/peerOrg3.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/peerOrg4.yaml

kubectl delete -f ${KUBECONFIG_FOLDER}/generateArtifactsJob.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/copyArtifactsJob.yaml

kubectl delete -f ${KUBECONFIG_FOLDER}/createNfsVolume.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/createNfsPV.yaml

kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-services.yaml
kubectl delete -f ${KUBECONFIG_FOLDER}/blockchain-namespace.yaml

sleep 15

echo -e "\npv:"
kubectl get pv
echo -e "\npvc:"
kubectl get pvc
echo -e "\njobs:"
kubectl get jobs
echo -e "\ndeployments:"
kubectl get deployments
echo -e "\nservices:"
kubectl get services
echo -e "\npods:"
kubectl get pods

echo -e "\nNetwork Cleaned!!\n"
