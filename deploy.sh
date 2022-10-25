#!/bin/bash
#set -x
devspace_version=v5.6.0
function help() {
  echo Usage: k8s-deployment/base/deploy.sh [parameters]
  echo -h --help
  echo "--envDir                  default ./k8s-deployment"
  echo "--debugMode               DEBUG: true/false, default false"
  echo "--cleanK8sDeployment      Clean all created Kubernetes Deployment API objects of current Project: true/false, default false"
  echo "--installTools            true/false. Install all Tools ( devspace ). default false.  sudo bash deploy.sh --installTools=true"
  echo "--prepareEnv              true/false. Prepare Environment Variables and Files"
  echo "--checkDeployment         true/false. Check deployment status"
  echo "--pushImage               true/false. Push docker Image after build, dafault false."
  echo "--imageSecret             true/false. Create image secret, dafault false."
  echo "--rollBack                true/false. Deployment roll back."
  echo "--cronJobs                true/false. Create Project Cron Jobs."
  exit 0
}

function export_env_vars_file (){
  while read LINE || [ -n "$LINE" ]; do
    if [[ ${LINE} != "" && ${LINE} != '#'* ]]; then
      lineVar=$(echo $LINE | envsubst)
      export_env_vars ${lineVar}
    fi
  done < ${1}
  if [[ $? != 0 ]]; then
    deployment_failed_message "Syntax error on environment variables files .env."
    exit 1
  fi
}

function set_default_variables () {
  echo " Export all default parameters and env variables"
  export "debugMode=false"  && \
  export "cleanK8sDeployment=false"  && \
  export "envDir=."  && \
  export "envFile=.env"  && \
  export "installTools=false"  && \
  export "pushImage=false"  && \
  export "imageSecret=true"  && \
#  export "rollBack=false"  && \
  if [[ -f ./k8s-deployment/.env ]]; then
    ls ./k8s-deployment/.env
    export_env_vars_file ./k8s-deployment/.env
  elif [ -f .env ]; then
    ls ./k8s-deployment/.env
    export_env_vars_file ./k8s-deployment/.env
  else
    deployment_failed_message " File .env dose not found"
  fi
  if [[ $? != 0 ]]; then
    deployment_failed_message "Syntax error on default environment variables files .env."
    exit 1
  fi
}

function install_tools () {
  echo " Installing DevSpace tool, please wait some time"
  deployment_warning_message "<< need root permissions, ex: sudo bash deploy.sh --installTools=true >>"
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.8/bin/linux/amd64/kubectl && \
  chmod +x ./kubectl && \
  mv ./kubectl /usr/local/bin/kubectl && \
  curl -s -L "https://github.com/devspace-cloud/devspace/releases/${devspace_version}" | sed -nE 's!.*"([^"]*devspace-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o devspace && \
  chmod +x devspace && \
  install devspace /usr/local/bin && \
  rm ./devspace && \
  echo " Installing EnvSubst tool, please wait some time" && \
  curl -L https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-`uname -s`-`uname -m` -o envsubst
  chmod +x envsubst && \
  mv envsubst /usr/local/bin && \
  exit 0
  exit 1
}

function export_env_vars() {
  export ${1#*--}
  if [[ $? != 0 ]]; then
    deployment_failed_message "Syntax error on environment variables files .env."
    exit 1
  fi
}

function prepare_command_parameters (){
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

function prepare_environment_variables (){
  if [[ -f ${envDir}/${envFile} ]]; then
    echo " Export all envFile variables"
    export_env_vars_file ${envDir}/${envFile}
    if [[ $? != 0 ]]; then
      deployment_failed_message "Syntax error on environment variables files .env."
      exit 1
    fi
    if [[ -z ${AWS_EKS_CLUSTER_NAME} ]]; then
      cat ${envDir}/${envFile} | grep -v "K8S_\|DOCKER_\|AZ_\|DO_\|PROJECT_NAME\|PROJECT_DOMAIN_NAME" | envsubst > .env_vars
    else
      cat ${envDir}/${envFile} | grep -v "K8S_\|DOCKER_\|AZ_\|AWS_|DO_\|PROJECT_NAME\|PROJECT_DOMAIN_NAME" | envsubst > .env_vars
    fi
  elif [[ -f ${envVars} ]]; then
    echo " Export all CI envVars variables"
    export_env_vars_file ${envVars}
    if [[ $? != 0 ]]; then
      deployment_failed_message "Syntax error on environment variables files .env."
      exit 1
    fi
    cat ${envVars} | grep -v "K8S_\|DOCKER_\|AZ_\|AWS_|DO_\|PROJECT_NAME\|PROJECT_DOMAIN_NAME" | envsubst > .env_vars
  else
    deployment_failed_message "Configure Environment Variables, check env file and envDir command line parameter."
  fi
  if [[ $? != 0 ]]; then
    deployment_failed_message "Syntax error on environment variables files .env."
    exit 1
  fi
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

function prepare_custom_kustomization_file (){
  if [[ ! -z ${K8S_KUSTOMIZATION_FILE} ]]; then   # Copy ${K8S_KUSTOMIZATION_FILE} to kustomization.yaml
    if [[ -f ${K8S_KUSTOMIZATION_FILE} ]]; then
      cp -v ${K8S_KUSTOMIZATION_FILE} kustomization.yaml
    elif [[ -f ../${K8S_KUSTOMIZATION_FILE} ]]; then
      cp -v ../${K8S_KUSTOMIZATION_FILE} ../kustomization.yaml
    else
      echo -e "\e[31m  FAILED: Kustomization file ${K8S_KUSTOMIZATION_FILE} does not exist, check K8S_KUSTOMIZATION_FILE variable and file. \e[0m\n"
      exit 1
    fi
  fi
}

function prepare_for_deployment (){
  if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    help
  fi
  prepare_environment_variables "$@" && \
  if [[ ! -f ./app_config.tpl ]]; then
    deployment_warning_message " PROJECT CONFIG Application Template File does not exist in root directory of project"
  fi
  if [[ ! -f ./.env ]]; then
    deployment_warning_message " .env file does not exist in root directory of project"
  fi
  if [[ ! -z ${CI_REGISTRY_USER} ]]; then   # Login to Git2 Local Container Registry
    docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  fi
  if [[ -f ${envDir}/config/kubeconfig.tpl && -z ${AWS_EKS_CLUSTER_NAME} ]]; then
    mkdir -pv ~/.kube/ && cat ${envDir}/config/kubeconfig.tpl | envsubst >~/.kube/config
  elif [[ -f k8s-deployment/config/kubeconfig.tpl ]]; then
    mkdir -pv ~/.kube/ && cat k8s-deployment/config/kubeconfig.tpl | envsubst >~/.kube/config
  else
    echo -e "\e[31m  FAILED: Kubernetes cluster config file template does not exist. \e[0m\n"
    exit 1
  fi
  if [[ ! -z ${AZ_REGISTRY_USER} ]]; then   # Login to Azure Container Registry
    echo "docker login -u ${AZ_REGISTRY_USER} -p ******** kwgregistrytest.azurecr.io"
    docker login -u ${AZ_REGISTRY_USER} -p ${AZ_REGISTRY_PASS} kwgregistrytest.azurecr.io
  elif [[ ! -z ${AWS_EKS_CLUSTER_NAME} ]]; then
    echo aws eks --region ${AWS_REGION} update-kubeconfig --name ${AWS_EKS_CLUSTER_NAME}
    rm -fv ~/.kube/config
    aws eks --region ${AWS_REGION} update-kubeconfig --name ${AWS_EKS_CLUSTER_NAME}
    AWS_DOCKER_TOKEN=$(aws ecr get-login-password --region $AWS_REGION)
    docker login -u AWS -p ${AWS_DOCKER_TOKEN} ${K8S_DOCKER_IMAGE}
  else
    if [[ ! -z ${K8S_DOCKER_REP_USER} ]]; then   # Login to docker Registry
      echo "docker login -u ${K8S_DOCKER_REP_USER} -p ********* ${K8S_DOCKER_IMAGE}"
      docker login -u ${K8S_DOCKER_REP_USER} -p ${K8S_DOCKER_REP_PSWD} ${K8S_DOCKER_IMAGE}
#      docker login -u ${K8S_DOCKER_REP_USER} -p ${K8S_DOCKER_REP_PSWD} ${DOCKER_REPO_IMAGE}
    elif [[ ! -z ${CI_REGISTRY_USER} ]]; then   # Login to Git2 Local Container Registry
      docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    fi
    if [ $? != 0 ]; then
      deployment_failed_message "Docker Login Failed."
      exit 1
    fi
  fi
  prepare_custom_kustomization_file
}

function check_cluster_k8s_status() {
  if kubectl cluster-info -n ${K8S_APP_NAMESPACE} | grep ".*ubernetes.*.master.*.is.*.running.*"; then
    echo " Kubernetes cluster configured."
  else
    echo -e "\e[31m  FAILED: Kubernetes cluster config file does not config properly. \e[0m\n"
    exit 1
  fi
}

function deployment_status (){
  deployment_info_message " === Deployment PODs Events: === "
  kubectl get events -n ${K8S_APP_NAMESPACE} --field-selector involvedObject.kind=Pod | grep -v "Normal" | grep "${PROJECT_NAME}";   echo ' '
  deployment_info_message " === Deployment Describe PODs: === "
  kubectl describe pods -l project=${PROJECT_NAME} -n ${K8S_APP_NAMESPACE};   echo ' '
  deployment_info_message " === Deployment PODs Logs: === "
  kubectl logs -l project=${PROJECT_NAME} -n ${K8S_APP_NAMESPACE} --all-containers=true;   echo ' '
}

function check_deployment (){
  deployment_info_message " === Deployment STATUS: Rollout/RollBack, Nr.Pods.AVAILABLE === "
  for deployment in $(kubectl get deployments -n ${K8S_APP_NAMESPACE} -lproject=${PROJECT_NAME} | awk 'match($1,/^.+deployment/) {print $1}'); do
    if ! kubectl rollout status deployment $deployment -n ${K8S_APP_NAMESPACE} --timeout=${K8S_DEPLOYMENT_TIMEOUT}s; then
      echo " CI_COMMIT_BRANCH: ${CI_COMMIT_BRANCH}, CI_COMMIT_REF_NAME: ${CI_COMMIT_REF_NAME}"
      deployment_status
      if [[ ${rollBack} == "true" ]]; then
        kubectl rollout undo deployment $deployment -n ${K8S_APP_NAMESPACE}
        deployment_info_message "DEPLOYMENT Release Rolled Back"
      fi
      deployment_failed_message "$(date) - DEPLOYMENT Project ${PROJECT_NAME}"
      exit 1
    fi
  done
}

function apply_deployment_k8s () {
  devspace use namespace ${PROJECT_NAME}
}

function push_docker_image () {
 echo "Check {CI_REGISTRY} var and pushing Docker Image ... "
 if [[ ! -z ${CI_REGISTRY} ]]; then   # Login to Git2 Local Container Registry
   prepare_for_deployment && \
   docker tag $CI_REGISTRY/$CI_PROJECT_PATH:${DOCKER_IMAGE_TAG} ${K8S_DOCKER_IMAGE}:${DOCKER_IMAGE_TAG} && \
   docker push ${K8S_DOCKER_IMAGE}:${DOCKER_IMAGE_TAG}
 fi
}

function create_image_repo_secret () {
#    if [[ ${K8S_DOCKER_REP_USER} != "" || ${K8S_DOCKER_REP_PSWD} != "" || -f ${envVars} ]]; then
  if [[ ! -z ${K8S_DOCKER_REP_USER} ]] || [[ ! -z ${K8S_DOCKER_REP_PSWD} ]]; then

    echo " === Local environment, create k8s secret === "
    if [[ "${K8S_DOCKER_IMAGE}" =~ "devopss-tools-platform" ]]; then
      echo " = Create K8S secret for devopss-tools Platform component, set K8S_DOCKER_REP_USER=<gitlab access token> = "
      kubectl delete secret ${K8S_APP_NAMESPACE}-platform-image-registry-secret --ignore-not-found --namespace ${K8S_APP_NAMESPACE}
        kubectl create secret docker-registry ${K8S_APP_NAMESPACE}-platform-image-registry-secret --docker-server=${DOCKER_REPO_IMAGE} --docker-username=${K8S_DOCKER_REP_USER} --docker-password=${K8S_DOCKER_REP_PSWD} --namespace ${K8S_APP_NAMESPACE}
    else
      echo " = Create K8S secret, K8S_DOCKER_REP_USER: ${K8S_DOCKER_REP_USER}, K8S_DOCKER_REP_PSWD: ******  = "
      kubectl delete secret ${K8S_APP_NAMESPACE}-image-registry-secret --ignore-not-found --namespace ${K8S_APP_NAMESPACE} && \
      kubectl create secret docker-registry ${K8S_APP_NAMESPACE}-image-registry-secret --docker-server=${DOCKER_REPO_IMAGE} --docker-username=${K8S_DOCKER_REP_USER} \
              --docker-password=${K8S_DOCKER_REP_PSWD} --namespace ${K8S_APP_NAMESPACE}
    fi
  else
    deployment_failed_message "Check variables K8S_DOCKER_REP_USER: ${K8S_DOCKER_REP_USER}, K8S_DOCKER_REP_PSWD: ***** "
  fi
}

function create_cron_jobs () {
  deployment_info_message " Create CRON Jobs "
  if [[ -d "./k8s-deployment" ]]; then
    cd  k8s-deployment
    ls
  fi
  kubectl create configmap ${K8S_APP_NAMESPACE}-kubeconfig-configmap --from-file ~/.kube/config -n ${K8S_APP_NAMESPACE} --kubeconfig ~/.kube/config
  export symb='$'
  cat cronJobs/cronJob-update-image-registry-secret.yml | envsubst | kubectl apply -f -
  cat cronJobs/cronJob-clean-pods.yml | envsubst | kubectl apply -f -
}

################   Call above functions   ################
set_default_variables && \
prepare_command_parameters "$@" && \

if [[ ${pushImage} == "true" ]]; then push_docker_image && exit 0; exit 1; fi

if [[ ${installTools} == "true" ]]; then install_tools; fi

if [[ ${cronJobs} == "true" ]]; then
  prepare_for_deployment && \
  create_cron_jobs && \
  exit 0
  exit 1
fi

if [[ ${prepareEnv} == "true" ]]; then
  prepare_for_deployment "$@" && \
  create_image_repo_secret && \
  check_cluster_k8s_status && \
  if [ $? != 0 ]; then
    deployment_failed_message " Prepare environment variables FAILED"
  fi
else
  prepare_for_deployment "$@"
  create_image_repo_secret
fi

if [[ ${checkDeployment} == "true" ]]; then check_deployment; fi

