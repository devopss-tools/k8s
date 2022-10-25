#!/bin/bash

function help () {
  echo "Usage: bash k8s-deployment/customs.sh [fuction name]"
  echo "       fuctions list:"
  echo "       bash k8s-deployment/customs.sh rs_scaling_max   | K8S_REPLICAS_MAX - max autoascaling replicas, default K8S_REPLICAS * 2"
  echo "       bash k8s-deployment/customs.sh rs_scaling_max   | K8S_ALTERNATIVE_DEPLOYMENT_1_REPLICAS_MAX - max autoascaling replicas, default K8S_ALTERNATIVE_DEPLOYMENT_1_REPLICAS * 2"
  echo "       bash k8s-deployment/customs.sh rs_scaling_max   | K8S_ALTERNATIVE_DEPLOYMENT_2_REPLICAS_MAX - max autoascaling replicas, default K8S_ALTERNATIVE_DEPLOYMENT_2_REPLICAS * 2"
  echo "       bash k8s-deployment/customs.sh rs_scaling_max   | K8S_ALTERNATIVE_DEPLOYMENT_3_REPLICAS_MAX - max autoascaling replicas, default K8S_ALTERNATIVE_DEPLOYMENT_3_REPLICAS * 2"
  echo "       bash k8s-deployment/customs.sh rs_scaling_max   | K8S_ALTERNATIVE_DEPLOYMENT_4_REPLICAS_MAX - max autoascaling replicas, default K8S_ALTERNATIVE_DEPLOYMENT_4_REPLICAS * 2"
  echo "       bash k8s-deployment/customs.sh rs_scaling_max   | K8S_ALTERNATIVE_DEPLOYMENT_5_REPLICAS_MAX - max autoascaling replicas, default K8S_ALTERNATIVE_DEPLOYMENT_5_REPLICAS * 2"
  echo "       bash ./customs.sh create_cluster_default_cron_jobs --imageRegistry=___ --registryUser=____ --registryPass=****,      true/false. Create Project Cron Jobs."

}

function deployment_failed_message() {
  echo -e "\e[31m  FAILED: ${1}.\e[0m"
  exit 1
}
function deployment_warning_message () {
  echo -e "\e[33m  WARNING: ${1}.\e[0m"
}
function deployment_info_message () {
  echo ""
  echo -e "\e[32m  INFO: ${1}.\e[0m"
}
function check_exit_code () {
  if [[ $? != 0 ]]; then
    deployment_failed_message "$@"
    exit 1
  fi
}
function check_null () {
  if [[ -z "$@" ]]; then
    deployment_failed_message "Variable <  '"$@"'  > is null"
  fi
}

function export_env_vars() {
  export ${1#*--}
  if [[ $? != 0 ]]; then
    deployment_failed_message "Syntax error on environment variables files .env."
    exit 1
  fi
}

function prepare_command_parameters (){
  deployment_info_message "Start prepare_command_parameters function "
  for i in "$@"; do
    case $i in
      $i)
        export_env_vars  ${i#*--}
      shift
      ;;
    esac
  done
  if [[ $? != 0 ]]; then
    deployment_failed_message "Syntax error on command parameters."
    exit 1
  fi
}

function rs_scaling_max() {
  if [[ -z "${K8S_REPLICAS_MAX}" ]]; then
    export K8S_REPLICAS_MAX=$((K8S_REPLICAS * 2))
    echo "K8S_REPLICAS_MAX was set with default value = K8S_REPLICAS * 2, (K8S_REPLICAS $K8S_REPLICAS * 2)"
  fi
  if [[ -z "${K8S_ALTERNATIVE_DEPLOYMENT_1_REPLICAS_MAX}" ]]; then
    export K8S_ALTERNATIVE_DEPLOYMENT_1_REPLICAS_MAX=$((K8S_ALTERNATIVE_DEPLOYMENT_1_REPLICAS * 2))
    echo "K8S_REPLICAS_MAX was set with default value = K8S_REPLICAS * 2, (K8S_REPLICAS $K8S_REPLICAS * 2)"
  fi
  if [[ -z "${K8S_ALTERNATIVE_DEPLOYMENT_2_REPLICAS_MAX}" ]]; then
    export K8S_ALTERNATIVE_DEPLOYMENT_2_REPLICAS_MAX=$((K8S_ALTERNATIVE_DEPLOYMENT_2_REPLICAS * 2))
    echo "K8S_REPLICAS_MAX was set with default value = K8S_REPLICAS * 2, (K8S_REPLICAS $K8S_REPLICAS * 2)"
  fi
  if [[ -z "${K8S_ALTERNATIVE_DEPLOYMENT_3_REPLICAS_MAX}" ]]; then
    export K8S_ALTERNATIVE_DEPLOYMENT_3_REPLICAS_MAX=$((K8S_ALTERNATIVE_DEPLOYMENT_3_REPLICAS * 2))
    echo "K8S_REPLICAS_MAX was set with default value = K8S_REPLICAS * 2, (K8S_REPLICAS $K8S_REPLICAS * 2)"
  fi
  if [[ -z "${K8S_ALTERNATIVE_DEPLOYMENT_4_REPLICAS_MAX}" ]]; then
    export K8S_ALTERNATIVE_DEPLOYMENT_4_REPLICAS_MAX=$((K8S_ALTERNATIVE_DEPLOYMENT_4_REPLICAS * 2))
    echo "K8S_REPLICAS_MAX was set with default value = K8S_REPLICAS * 2, (K8S_REPLICAS $K8S_REPLICAS * 2)"
  fi
  if [[ -z "${K8S_ALTERNATIVE_DEPLOYMENT_5_REPLICAS_MAX}" ]]; then
    export K8S_ALTERNATIVE_DEPLOYMENT_5_REPLICAS_MAX=$((K8S_ALTERNATIVE_DEPLOYMENT_5_REPLICAS * 2))
    echo "K8S_REPLICAS_MAX was set with default value = K8S_REPLICAS * 2, (K8S_REPLICAS $K8S_REPLICAS * 2)"
  fi
}

function create_cluster_default_cron_jobs () {
  deployment_info_message "Start create_cluster_default_cron_jobs function "
  if [[ -d "./customs.sh" ]]; then
    deployment_failed_message " File ./customs.sh does not exist."
  else
    export symb='$'
    prepare_command_parameters "$@"
    kubectl delete configmap kubeconfig --ignore-not-found  --kubeconfig ~/.kube/config && \
    kubectl create configmap kubeconfig --from-file ~/.kube/config --kubeconfig ~/.kube/config  && \
    cat cronJobs/cronJob-update-k8s-cluster-image-registry-secret.yml | envsubst | kubectl apply -f -
#    cat cronJobs/cronJob-clean-pods.yml | envsubst | kubectl apply -f -
  fi
  check_exit_code "Function create_cluster_default_cron_jobs failed"
}

echo $1
$1 "$@"
