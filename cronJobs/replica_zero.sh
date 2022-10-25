#!/bin/bash

function help() {
  echo Usage: k8s-deployment/base/deploy.sh [parameters]
  echo --help
  echo "--cronJobReplicaZero   default null, have to be true"
  exit 0
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

function check_input_variables () {
  check_exit_code "function check_input_variables failed"
  echo " Check < VersMajor > group Settings->CI/CD->Variables"; check_null ${VersMajor}
  echo " Check CI_SERVER_HOST variable"; check_null ${CI_SERVER_HOST}
  echo " Check CI_PROJECT_NAMESPACE variable"; check_null ${CI_PROJECT_NAMESPACE}
  echo " Check CI_PROJECT_ID variable"; check_null ${CI_PROJECT_ID}
  echo " Check CI_API_V4_URL variable"; check_null ${CI_API_V4_URL}
}

function prepare_command_parameters (){
  deployment_info_message "Prepare command parameters"
  if [[ "$@" =~ "--help" ]]; then
    help
    exit 0
  fi
  for i in "$@"; do
    case $i in
      $i)
        export  ${i#*--}
      shift
      ;;
    esac
  done
  check_exit_code "function prepare_command_parameters failed"
}

prepare_command_parameters "$@"

if [[ "$cronJobReplicaZero" == "true" ]]; then
  kubectl delete configmap script-replicas-zero --ignore-not-found && \
  kubectl create configmap script-replicas-zero --from-file cronJobs/replica_zero.sh && \
  kubectl apply -f cronJobs/cronJob-zero-replica-for-unused-pods.yml
  check_exit_code "condition check cronJobReplicaZero failed"
  exit 0
fi

except_objects="kube\|ingress\|default\|nfs\|hiring\|recognition\|moderation\|Terminating\|NAME"
if [[ -z "$PODS_KEEP_DAYS" ]]; then echo " set PODS_KEEP_DAYS with default value: 5 "; fi
for namespace in $(kubectl get namespaces | grep -v $except_objects | awk '{print $1}'); do
#  namespace=parents

  if [[ ! -z $(kubectl get pods,deployments -n $namespace) ]]; then
    echo " === Namespace: $namespace === "
    result_days=$(kubectl get pods -n $namespace | grep -v $except_objects | awk '{print $5}' | grep -v "m" | awk 'match($1,/^.d/)' | grep "[1-$PODS_KEEP_DAYS]d")
#    result_days=$(kubectl get pods -n $namespace | grep -v $except_objects | awk '{print $5}' | awk 'match($1,!/[0-9]m/)' | awk 'match($1,!/[0-9][0-9]+d/)' | grep "[1-1]d")
    result_hours=$(kubectl get pods -n $namespace | grep -v $except_objects  | grep -v "No resources found" | awk 'match($5,/[0-9][0-9]+h/) {print $5}' | awk 'match($1,!/^.d/)')
  #  echo "result_hours: $result_hours"
    result_minutes=$(kubectl get pods -n $namespace | grep -v $except_objects | awk '{print $5}' | awk 'match($1,/[0-9]+m/)')
  #  echo "result_minutes: $result_minutes"
     #kubectl get pods -n $namespace | grep -v $except_objects | awk '{print $5}' | awk 'match($1,!/[0-9][0-9]+d/)' | awk 'match($1,/^[1-$PODS_KEEP_DAYS]+d/)'

    if [[ -z "$result_hours" &&  -z "$result_minutes" && -z "$result_days" ]]; then
      deployment_info_message " == $(date) == All result are null into namespace: $namespace, scale pods to 0 == "
      echo " - result_days: $result_days"
      echo " - result_hours: $result_hours"
      echo " - result_days: $result_minutes"
      kubectl get pods -n $namespace | grep -v $except_objects
      for pod in $(kubectl get pods -n $namespace | grep -v $except_objects); do
        echo " = Set label and deployment variables for pod: $pod = "
        #namespace=$(kubectl get pods -n $namespace | awk '{print $1}')
        label=$(kubectl get pods --show-labels -n $namespace | grep $pod | awk '{print $6}' | awk -F',' '{print $1}')
        deployment=$(kubectl get deployment -l $label -n $namespace | grep -v "NAME" | awk '{print $1}' )
        echo " Deployment: $deployment, label: $label "
        echo " Delete hpa with label: $label"
        kubectl delete hpa -l $label -n $namespace && \
        deployment_info_message " Tried to delete hpa with label: $label, see result one log/line before this"
        echo " Scale replica 0 for deployment: $deployment"
        kubectl scale deploy $deployment -n $namespace --replicas=1 && \
        deployment_info_message " Scaled replica 0 for deployment: $deployment"
      done
        deployment_info_message " == $(date) == Done: scale pods to 0 == "
    fi
  #  for deployment in $(kubectl get deployments -n $namespace | grep -v $except_objects | awk '{print $1}'); do
  #    echo $namespace
  #    kubectl scale deploy $deployment -n $namespace --replicas=1
  #  done
  fi
done



