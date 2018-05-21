alias use_k8s=use_k8s_config
alias workon=cd_to_workspace
alias gobuild=install_go
alias goenv=run_go
alias goformat=format_go

install_go(){
    docker run --rm -v "$PWD":/go -w /usr/src/app golang:1.8 go install -v $2 && bin/$(ls bin)
}

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
