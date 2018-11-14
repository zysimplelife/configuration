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

