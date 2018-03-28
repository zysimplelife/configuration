
function set_kube_conf(){
    export KUBECONFIG=~/.kube/$1.admin.conf
    echo KUBECONFIG=$KUBECONFIG
}

alias kubenv=set_kube_conf
