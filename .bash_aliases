alias use_k8s=use_k8s_config
alias workon=cd_to_workspace
alias goenv=run_go
alias goformat=format_go
alias k8sdelns=delete_ns
alias setgopath=set_go_path
alias podenv=dogetpodenv
alias podforward='kubectl port-forward  ${podname}  -n ${namespace} 6060:6060'
alias podexec='kubectl exec -it ${podname} -n  ${namespace} sh'
alias containerexec='kubectl exec -it ${podname} -c  eric-pm-bulk-reporter -n  ${namespace} sh'
alias podlog='kubectl logs ${podname} -n  ${namespace} '
alias containerlog='kubectl logs ${podname} -c  eric-pm-bulk-reporter -n  ${namespace} '
alias podget='kubectl get po -n  ${namespace}'
alias kubens='kubectl -n ${namespace} $@'
alias ksetns='kubectl config set-context `kubectl config current-context` --namespace'
alias kgetns='kubectl config view -o jsonpath="{..context.namespace}";echo'
# get all services with in a cluster and the nodePorts they use (if any)
alias ksvc="kubectl get --all-namespaces svc -o json | jq -r '.items[] | [.metadata.name,([.spec.ports[].nodePort | tostring ] | join(\"|\"))] | @csv'"
# shortcuts for frequent kubernetes commands
alias kpods="kubectl get po"
alias kinspect="kubectl describe"
alias setAzClient=set_az_client
alias setLocalClient=set_local_client

krun() { name=$1; shift; image=$1; shift; kubectl run -it --generator=run-pod/v1 --image $image $name -- $@; }
klogs() { kubectl logs $*;}
kexec(){ pod=$1; shift; kubectl exec -it $pod -- $@; }


run_go(){
    docker run --rm -i -v "$PWD":/go -w /go golang:1.10.1 go $@
}

format_go(){
    docker run --rm -v "$PWD":/go -w /go golang:1.8 gofmt -w $1
}

set_go_path(){
    export GOPATH=$PWD
    export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
}

cd_to_workspace(){
    cd ~/workspace/adp-gs-$1
}

use_k8s_config(){
    FILE="$HOME/.kube/$1_admin.conf"
    if [[ ! -f $FILE ]]; then
        echo "$FILE does not exist"
        return
    fi

    export KUBECONFIG=$FILE
    echo "$FILE is used now"
}

delete_ns(){
    kubectl delete --all po -n $1 --grace-period=0 --force
    kubectl delete all -n $1 --grace-period=0 --force  --all
    kubectl delete --all pvc -n $1
    kubectl delete ns $1
}

dogetpodenv(){
    export namespace="$1"
    export podname=$(kubectl get po -n ${namespace}  -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep $2)
    echo "$namespace/$podname"
}

set_az_resource(){
    export RESOURCE_GROUP='bca-dev-westeurope'
    export ACTIVITY_LOG_RESOURCE_GROUP='bca-activity-log-dev'
    export RESOURCE_GROUP_MC='MC_bca-dev-westeurope_bca-dev-cluster_westeurope'
    export SUBSCRIPTION_ID='15b4d43c-7a12-42ea-8184-cedd7e6f229a'
    export AME_SERVER_APP_ID='007998b2-d849-4f8d-91d3-1be06def28a8'
    export AME_SERVER_APP_SECRET='-/=Rdsvwv+b3dERlZn6DibUuzeezgQ20'
}

get_az_storage_account(){

    STORAGE_ACCOUNTS=$(az storage account list --output json --resource-group ${RESOURCE_GROUP} --subscription ${SUBSCRIPTION_ID})
    export SEC_ACC_NAME=$(echo $STORAGE_ACCOUNTS | jq -r '.[]|select(.name | startswith("seclogs")).name')
    export SYS_ACC_NAME=$(echo $STORAGE_ACCOUNTS | jq -r '.[]|select(.name | startswith("syslog")).name')
    export PRIV_ACC_NAME=$(echo $STORAGE_ACCOUNTS | jq -r '.[]|select(.name | startswith("privlogs")).name')

    # skip print secret key in consonle
    export SEC_ACC_KEY=$(az storage account keys list --account-name ${SEC_ACC_NAME} --resource-group ${RESOURCE_GROUP} --subscription ${SUBSCRIPTION_ID} | jq '.[0]''.value' | tr -d "\"")
    export SYS_ACC_KEY=$(az storage account keys list --account-name ${SYS_ACC_NAME} --resource-group ${RESOURCE_GROUP} --subscription ${SUBSCRIPTION_ID} | jq '.[0]''.value' | tr -d "\"")
    export PRIV_ACC_KEY=$(az storage account keys list --account-name ${PRIV_ACC_NAME} --resource-group ${RESOURCE_GROUP} --subscription ${SUBSCRIPTION_ID} | jq '.[0]''.value' | tr -d "\"")
}

set_local_client(){
    export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
    kubectl cluster-info
    set_az_resource
    get_az_storage_account
}

set_az_client(){
    #az aks get-credentials --resource-group bca-dev-westeurope --subscription 15b4d43c-7a12-42ea-8184-cedd7e6f229a --name bca-dev-cluster --file ~/.kube/bcadev_admin.conf
    use_k8s_config bcadev
    set_az_resource
    get_az_storage_account
}

clean_adp_services(){
    helm del --purge adp-services
    kubectl delete all --all -n adp-services
    kubectl delete pvc --all -n adp-services
}

install_adp_service(){
helm dependency update ~/workspace/adp/helm/integration
VALUE=$1
helm install --name ${KUBE_NAME:=adp-services} --namespace ${KUBE_NAMESPACE:=adp-services} ~/workspace/adp/helm/integration -f ~/workspace/adp/helm/values/values-${VALUE:=dev-local}.yaml \
    --set config.subscriptionID=${SUBSCRIPTION_ID} \
    --set config.resourceGroup=${RESOURCE_GROUP} \
    --set config.resourceGroupMC=${RESOURCE_GROUP_MC} \
    --set config.clientSecret=${AME_SERVER_APP_SECRET} \
    --set config.clientID=${AME_SERVER_APP_ID} \
    --set eric-logstash.pipeline.storageAccount.diagnostic="${DIAG_ACC_NAME}" \
    --set eric-logstash.pipeline.storageAccountKey.diagnostic="${DIAG_ACC_KEY}" \
    --set eric-logstash.pipeline.storageAccount.privacy="${PRIV_ACC_NAME}" \
    --set eric-logstash.pipeline.storageAccountKey.privacy="${PRIV_ACC_KEY}" \
    --set eric-logstash.pipeline.storageAccount.security="${SEC_ACC_NAME}" \
    --set eric-logstash.pipeline.storageAccountKey.security="${SEC_ACC_KEY}" \
    --debug $2
}

upgrade_adp_services(){
helm dependency update ~/workspace/adp/helm/integration
VALUE=$1
helm upgrade ${KUBE_NAME:=adp-services} ~/workspace/adp/helm/integration -f ~/workspace/adp/helm/values/values-${VALUE:=dev-local}.yaml \
    --set config.subscriptionID=${SUBSCRIPTION_ID} \
    --set config.resourceGroup=${RESOURCE_GROUP} \
    --set config.resourceGroupMC=${RESOURCE_GROUP_MC} \
    --set config.clientSecret=${AME_SERVER_APP_SECRET} \
    --set config.clientID=${AME_SERVER_APP_ID} \
    --set eric-logstash.pipeline.storageAccount.diagnostic="${DIAG_ACC_NAME}" \
    --set eric-logstash.pipeline.storageAccountKey.diagnostic="${DIAG_ACC_KEY}" \
    --set eric-logstash.pipeline.storageAccount.privacy="${PRIV_ACC_NAME}" \
    --set eric-logstash.pipeline.storageAccountKey.privacy="${PRIV_ACC_KEY}" \
    --set eric-logstash.pipeline.storageAccount.security="${SEC_ACC_NAME}" \
    --set eric-logstash.pipeline.storageAccountKey.security="${SEC_ACC_KEY}" \
    --debug $2
}

create_local_cluster(){
    kind create cluster
    set_local_client

    ## install class stroage
    kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
    kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.beta.kubernetes.io/is-default-class":"true"}}}'
    kubectl patch storageclass standard -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
    kubectl patch storageclass standard -p '{"metadata":{"annotations":{"storageclass.beta.kubernetes.io/is-default-class":"false"}}}'

    ## install tiller
    kubectl -n kube-system create serviceaccount tiller
    kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller
}

function get_json_response () {
  local bash_options="$(set +o); set -$-"
  set +xe

  local output=$(eval $1 2>&1)
  local returnStatus=$?
  set -e

  if [[ $returnStatus -ne 0 ]] ; then
      echo $output >&2
      set +vx; eval "$bash_options"
      return 1
    fi

  local successfulRequest=$(echo $output | jq -r 'if type=="array" then "true" else .error == null end')

  if [[ $successfulRequest == "false" ]] ; then
      echo "Request failed: $output" >&2
      set +vx; eval "$bash_options"
      return 1
    fi

  set +vx; eval "$bash_options"
  echo $output
}
