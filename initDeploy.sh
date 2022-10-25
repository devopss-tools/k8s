#!/bin/bash

function check_tools_command () {
  deployment_info_message "check dialog command"
    if ! which dialog; then
      if which apt; then
        sudo apt install -y dialog
      elif which yum; then
        sudo yum install -y dialog
      elif which apk; then
        apk add dialog
        apk add bash
      fi
    fi
  check_exit_code "function check_tools_command failed"
}
check_tools_command
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

function copy_files () {
  deployment_info_message " Init: Copy files  ..."
  cp -v k8s-deployment/templates/devspace.yaml ./  && \
  cp -v k8s-deployment/init/kustomization.yaml ./  && \
  cp -v k8s-deployment/init/.env ./  && \
  cp -v k8s-deployment/init/.gitlab-ci.yml ./
  check_exit_code "Copy files failed"
}


function update_ignores (){
  deployment_info_message " Update .gitignore and .dockerignore files ..."
  cat k8s-deployment/templates/.gitignore >> .gitignore
  cat k8s-deployment/templates/.dockerignore >> .dockerignore
  check_exit_code "Update .gitignore and .dockerignore failed"
}

function add_kustomization_configmap_envs (){
  echo 'Add  ...kustomization_configmap_envs.yaml >> ./kustomization.yaml'
  cat k8s-deployment/init/kustomization_configmap_envs.yaml >> ./kustomization.yaml
  check_exit_code "Update add_kustomization_configmap_envs"
}

function add_kustomization_patches (){
  deployment_info_message " Add kustomization $@ patches (kustomization.yaml) ..."
  if [[ $@ == "app_healthcheck" ]]; then
    echo '  - k8s-deployment/overlays/deployment/probe-liveness.yml'  >> kustomization.yaml
    echo '  - k8s-deployment/overlays/deployment/probe-readiness.yml'  >> kustomization.yaml
  fi
  if [[ $@ == "app_variables" ]]; then
    echo '  - k8s-deployment/overlays/environments/app-env-variables-file.yml'  >> kustomization.yaml
    add_kustomization_configmap_envs
  fi
}

function ci_cd () {
  copy_files
  rm -fv .env
  add_kustomization_patches app_healthcheck
  add_kustomization_patches app_variables
}
echo ${CI_REGISTRY}
if [[ ! -z ${CI_REGISTRY} ]]; then
  ci_cd
  check_exit_code "Update ci_cd"
  exit 0
fi

cmd=(dialog --separate-output --checklist "Select options:" 22 76 16)

options=(
         1 "Application environment variables." on    # any option can be set to default to "on"
         2 "Application health check endpoint." on
         3 "Run Once: Update .gitignore and .dockerignore" off
         )

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

clear
copy_files

for choice in $choices
do
    case $choice in
        1)
            add_kustomization_patches app_healthcheck
            ;;
        2)
            add_kustomization_patches app_variables
            ;;
        3)
            update_ignores
            ;;
    esac
done


