alias use_k8s=use_k8s_config
alias workon=cd_to_workspace
alias gobuild='docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app golang:1.8 go build -v && ./app'


cd_to_workspace(){
    cd ~/workspace/adp-gs-$1
}    

use_k8s_config(){
    export KUBECONFIG=~/.kube/$1_admin.conf
}    
