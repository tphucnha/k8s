#!/bin/bash
# Files are ordered in proper order with needed wait for the dependent custom resource definitions to get initialized.
# Usage: bash kubectl-delete.sh

usage(){
 cat << EOF

 Usage: $0 -f
 Description: To delete k8s manifests using the default \`kubectl delete -f\` command
[OR]
 Usage: $0 -k
 Description: To delete k8s manifests using the kustomize \`kubectl delete -k\` command
[OR]
 Usage: $0 -s
 Description: To delete k8s manifests using the skaffold binary \`skaffold run\` command

EOF
exit 0
}

logSummary() {
    echo ""
}

default() {
    suffix=k8s
    kubectl delete -f registry-${suffix}/
    kubectl delete -f moneylogger-${suffix}/
    kubectl delete -f moneyloggergw-${suffix}/

}

kustomize() {
    kubectl delete -k ./
}

scaffold() {
    // this will build the source and delete the manifests the K8s target. To turn the working directory
    // into a CI/CD space, initilaize it with `skaffold dev`
    skaffold run
}

[[ "$@" =~ ^-[fks]{1}$ ]]  || usage;

while getopts ":fks" opt; do
    case ${opt} in
    f ) echo "Applying default \`kubectl delete -f\`"; default ;;
    k ) echo "Applying kustomize \`kubectl delete -k\`"; kustomize ;;
    s ) echo "Applying using skaffold \`skaffold run\`"; scaffold ;;
    \? | * ) usage ;;
    esac
done

logSummary
