#!/bin/bash

function help() {
  echo Usage: k8s-deployment/base/deploy.sh [parameters]
  echo --help
  echo "--token                 gitlab ci-api-user token, --token=***** "
  echo "--variable              the variable you want to update (variable from project group: Settings->CI/CD->Variables), --variable=VersMinor"
  echo "--variable              is a GitLab Group variable, not project/repository"
  echo "--type                  projects or groups --type=projects"
  echo "From CI start >         bash version.sh  --variable=VersMinor"
  echo "From local start >      bash version.sh  --variable=VersMinor  --token=***** "
  echo " Use --variable=VersMinor --type=projects || OR --variable=VersMajor --type=groups"
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

function check_tools_command () {
  deployment_info_message "check curl command"
  if [[ ! -z ${CI_REGISTRY} ]]; then
    if ! which curl; then
      if which apt; then
        apt install -y curl
      elif which yum; then
        apk install -y curl
      elif which apk; then
        apk add  curl
      fi
    elif which apk; then
      apk add --update-cache --upgrade curl
    fi
    check_exit_code "function check_tools_command failed on curl check"
    if ! which jq; then
      if which apt; then
        apt install -y jq
      elif which yum; then
        apk install -y jq
      elif which apk; then
        apk add  jq
      fi
    fi
    check_exit_code "function check_tools_command failed on jq check"
  fi
  check_exit_code "function check_tools_command failed"
}

function add_variable () {
  deployment_info_message "Add variable < $@ = 0 > ${CI_API_V4_URL}/${type}/${ci_project}/variables: Settings->CI/CD->Variables "
  curl --request POST \
      --header "PRIVATE-TOKEN: $CI_API_USER_TOKEN" "${CI_API_V4_URL}/${type}/${ci_project}/variables" \
      --form "key=$@" --form "value=0"
  check_exit_code "function add_variable failed"
}

function check_variable () {
  deployment_info_message "Check variable < $@ > ${CI_API_V4_URL}/${type}/${ci_project}/variables: Settings->CI/CD->Variables "
  export checkVar=$(curl -s --header "PRIVATE-TOKEN: $CI_API_USER_TOKEN" "${CI_API_V4_URL}/${type}/${ci_project}/variables/$@")
  check_exit_code "function check_variable failed on get variable < $@ >"
  if ! echo $checkVar | grep "$@"; then
    add_variable "$@"
  fi
  check_exit_code "function check_variable failed, variable < $@ >"
}

function update_variable () {
  deployment_info_message "Update variable < $@ > ${CI_API_V4_URL}/${type}/${ci_project}/variables: Settings->CI/CD->Variables "
  check_variable "$@"
  varValue=$(curl -s --header "PRIVATE-TOKEN: $CI_API_USER_TOKEN" "${CI_API_V4_URL}/${type}/${ci_project}/variables/$@"   | jq -r '.value')
  check_exit_code "function check_variable failed on curl get variable < $@ >"
  echo " Current $@ value before increment - $@=${varValue}"
  newValue="$((varValue + 1))"
  echo ""
  curl --request PUT --header "PRIVATE-TOKEN: $CI_API_USER_TOKEN" "${CI_API_V4_URL}/${type}/${ci_project}/variables/$@" --form "value=$newValue"
  check_exit_code "function check_variable failed on curl put variable < $@ >"
  varValue=$(curl -s --header "PRIVATE-TOKEN: $CI_API_USER_TOKEN" "${CI_API_V4_URL}/${type}/${ci_project}/variables/$@"   | jq -r '.value')
  echo ""
  check_exit_code "function check_variable failed on curl get new variable < $@ >"
  export $@=$newValue
  check_exit_code "function check_variable failed on export new variable < $@ >"
  echo " Current $@ value after increment - $@=${varValue}"
}

function update_variables () {
  check_tools_command
  deployment_info_message " Update GitLab (user: ci-api-user) variables ${CI_API_V4_URL}/${type}/${ci_project}/variables: Settings->CI/CD->Variables "
  deployment_warning_message "ci-api-user require maintainer permissions"
  update_variable "${variable}"
  check_exit_code "function update_variables failed"
}

function init () {
  if [[ -z ${CI_API_USER_TOKEN} ]]; then
    deployment_warning_message "Set ${CI_SERVER_HOST}/${ci_project}: Settings->CI/CD->Variables"
    if [[ ! -z ${token} ]]; then
      export CI_API_USER_TOKEN=${token}
    else
      deployment_failed_message "ci-api-user token and/or CI_API_USER_TOKEN are null, run > bash version.sh --token=****************"
    fi
  fi
  check_exit_code "function init check token failed "
  echo " Check CI_API_USER_TOKEN variable"; check_null ${CI_API_USER_TOKEN}
  if [[ ${type} == "groups" ]]; then
    export ci_project=${CI_PROJECT_NAMESPACE}
  elif [[ ${type} == "projects" ]]; then
    export ci_project=${CI_PROJECT_ID}
  elif [[ -z ${type} ]]; then
    export type=projects
    export ci_project=${CI_PROJECT_ID}
  fi
  check_exit_code "function init check type/ci_project failed "
  echo " Check < variable > variable"; check_null ${variable}
}

prepare_command_parameters "$@"
init
check_input_variables
update_variables

### Check VersMinor variable
#export type=gropus ci_project=${CI_PROJECT_NAMESPACE}
#check_variable "VersMajor"
