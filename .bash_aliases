alias use_k8s=use_k8s_config
alias workon=cd_to_workspace
alias gobuild=install_go

install_go(){
    docker run --rm -v "$PWD":/go -w /usr/src/app golang:1.8 go install -v $1 && bin/$(ls bin)
}

cd_to_workspace(){
    cd ~/workspace/adp-gs-$1
}    

use_k8s_config(){
    export KUBECONFIG=~/.kube/$1_admin.conf
}    
