alias use_k8s=use_k8s_config
alias workon=cd_to_workspace
alias goenv=run_go
alias goformat=format_go
alias k8sdelns=delete_ns
alias setgopath="export GOPATH=$PWD"
alias podenv=dogetpodenv
alias podforward="kubectl port-forward  ${podname}  -n ${namespace} 6060:6060"
alias podexec="kubectl exec -it ${podname} -c  eric-pm-bulk-reporter -n  ${namespace} sh"
alias podshowlog="kubectl logs ${podname} -c  eric-pm-bulk-reporter -n  ${namespace}"
alias podget="kubectl get po -n  ${namespace}"

run_go(){
    docker run --rm -i -v "$PWD":/go -w /go golang:1.10.1 go $@
}

format_go(){
    docker run --rm -v "$PWD":/go -w /go golang:1.8 gofmt -w $1
}


cd_to_workspace(){
    cd ~/workspace/adp-gs-$1
}

use_k8s_config(){
    export KUBECONFIG=~/.kube/$1_admin.conf
}

delete_ns(){
    kubectl delete all -n $1 --all
    kubectl delete ns $1
}

dogetpodenv(){
    export namespace="ezhayog-br-ns"
    export podname=$(kubectl get po -n ${namespace}  -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep bulk)
    echo "$namespace/$podname"
}

