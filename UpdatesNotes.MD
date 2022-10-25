##### 29.04.2021
* add paths rules for alternative deployments 3
* add for alternate_deployment_3 new application resources

|K8S Deployment Patch File|VARIABLE|Default values|Description|
|---|---|---|---|
|`k8s-deployment/overlays/alternative_deployment_3/resources-cpu.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_CPU_LIMIT and K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_CPU_REQUEST`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_CPU_LIMIT alternative cpu for deployment 3 and K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_CPU_REQUEST alternative cpu request for deployment 3`|
|`k8s-deployment/overlays/alternative_deployment_3/resources-ram.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_RAM_LIMIT and K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_RAM_REQUEST`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_RAM_LIMIT alternative ram for deployment 3 and K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_RAM_REQUEST alternative ram request for deployment 3`|
|`k8s-deployment/overlays/alternative_deployment_3/probe-liveness-spec-path-port.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_3_HEALTH_PATH and K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_PORT`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_3_HEALTH_PATH alternative health path for deployment 3 and K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_PORT alternative port for deployment 3`|
|`k8s-deployment/overlays/alternative_deployment_3/probe-readiness-spec-path-port.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_3_HEALTH_PATH and K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_PORT`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_3_HEALTH_PATH alternative health path for deployment 3 and K8S_ALTERNATIVE_DEPLOYMENT_3_CONTAINER_PORT alternative port for deployment 3`|

##### 02.04.2021
* add feature ingress: proxy buffer parameters

|K8S Deployment Patch File|VARIABLE|Default values|Description|
|---|---|---|---|
|`k8s-deployment/overlays/ingress-controller/ingress-proxy-buffer-enable.yml`|`K8S_INGRESS_PROXY_BUFFER_SIZE and K8S_INGRESS_PROXY_BUFFER_NUMBERS`|`'"4"' and 8k `|` `|

##### 01.04.2021
* add tcp liveness and readiness probes

|K8S Deployment Patch File|VARIABLE|Default values|Description|
|---|---|---|---|
|`k8s-deployment/overlays/deployment/probe-tcp-liveness-readiness.yml`|`K8S_CONTAINER_PORT, K8S_CONTAINER_READINESS_TIMEOUT and K8S_CONTAINER_LIVNESS_TIMEOUT`|` `|`tcp container health check using application port `|


##### 22.02.2021
* add paths rules for alternative deployments 2
* add for alternate_deployment_1 and alternate_deployment_2 new application resources

|K8S Deployment Patch File|VARIABLE|Default values|Description|
|---|---|---|---|
|`k8s-deployment/overlays/alternative_deployment_1/resources-cpu.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_CPU_LIMIT and K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_CPU_REQUEST`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_CPU_LIMIT alternative cpu for deployment 1 and K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_CPU_REQUEST alternative cpu request for deployment 1`|
|`k8s-deployment/overlays/alternative_deployment_1/resources-ram.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_RAM_LIMIT and K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_RAM_REQUEST`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_RAM_LIMIT alternative ram for deployment 1 and K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_RAM_REQUEST alternative ram request for deployment 1`|
|`k8s-deployment/overlays/alternative_deployment_2/probe-liveness-spec-path-port.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_2_HEALTH_PATH and K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_PORT`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_2_HEALTH_PATH alternative health path for deployment 2 and K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_PORT alternative port for deployment 2`|
|`k8s-deployment/overlays/alternative_deployment_2/probe-readiness-spec-path-port.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_2_HEALTH_PATH and K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_PORT`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_1_HEALTH_PATH alternative health path for deployment 2 and K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_PORT alternative port for deployment 2`|
|`k8s-deployment/overlays/alternative_deployment_2/resources-cpu.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_CPU_LIMIT and K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_CPU_REQUEST`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_CPU_LIMIT alternative cpu for deployment 2 and K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_CPU_REQUEST alternative cpu request for deployment 2`|
|`k8s-deployment/overlays/alternative_deployment_2/resources-ram.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_RAM_LIMIT and K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_RAM_REQUEST`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_RAM_LIMIT alternative ram for deployment 2 and K8S_ALTERNATIVE_DEPLOYMENT_2_CONTAINER_RAM_REQUEST alternative ram request for deployment 2`|


##### 18.02.2021
* add paths rules for alternative deployments 1

|K8S Deployment Patch File|VARIABLE|Default values|Description|
|---|---|---|---|
|`k8s-deployment/overlays/alternative_deployment_1/probe-liveness-spec-path-port.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_1_HEALTH_PATH and K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_PORT`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_1_HEALTH_PATH alternative health path for deployment 1 and K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_PORT alternative port for deployment 1`|
|`k8s-deployment/overlays/alternative_deployment_1/probe-readiness-spec-path-port.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_1_HEALTH_PATH and K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_PORT`|` `|`K8S_ALTERNATIVE_DEPLOYMENT_1_HEALTH_PATH alternative health path for deployment 1 and K8S_ALTERNATIVE_DEPLOYMENT_1_CONTAINER_PORT alternative port for deployment 1`|

##### 08.02.2021
* add paths rules for alternative deployments (1,2)

|K8S Deployment Patch File|VARIABLE|Default values|Description|
|---|---|---|---|
|`k8s-deployment/overlays/security/security-context-capabilities-netbindservice.yml`|` `|` `|` SECURITY CONTEXT with NET_BIND_SERVICE option`|
|`k8s-deployment/overlays/ingress-controller/ingress-subpath-alternative-1.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_1_NAME`|` `|`subpath for alternative deployment 1`|
|`k8s-deployment/overlays/ingress-controller/ingress-subpath-alternative-2.yml`|`K8S_ALTERNATIVE_DEPLOYMENT_2_NAME`|` `|`subpath for alternative deployment 2`|
* Add PODs Autoscaling
  
  |Deployment Name|Autoscaling variable|default value|
  |---|---|---|
  |Main deployment|K8S_REPLICAS_MAX|Nr. of replica * 2|
  |Altenative deployment nr.1|K8S_ALTERNATIVE_DEPLOYMENT_1_REPLICAS_MAX|Nr. of Altenative deployment nr.1 replica * 2|
  |Altenative deployment nr.2|K8S_ALTERNATIVE_DEPLOYMENT_2_REPLICAS_MAX|Nr. of Altenative deployment nr.2 replica * 2|
  |Altenative deployment nr.3|K8S_ALTERNATIVE_DEPLOYMENT_3_REPLICAS_MAX|Nr. of Altenative deployment nr.3 replica * 2|
  |Altenative deployment nr.4|K8S_ALTERNATIVE_DEPLOYMENT_4_REPLICAS_MAX|Nr. of Altenative deployment nr.4 replica * 2|
  |Altenative deployment nr.5|K8S_ALTERNATIVE_DEPLOYMENT_5_REPLICAS_MAX|Nr. of Altenative deployment nr.5 replica * 2|


##### 04.02.2021
* add security context capabilities
* add security context priveleged true
* add 3-5 (like 1-2) alternative deployments 

|K8S Deployment Patch File|VARIABLE|Default values|Description|
|---|---|---|---|
|`k8s-deployment/overlays/security/security-context-capabilities-netbindservice.yml`|` `|` `|` SECURITY CONTEXT with NET_BIND_SERVICE option`|
|`k8s-deployment/overlays/security/security-context-privileged-true.yml`|` `|` `|` SECURITYCONTEXT with privileged true option`|


##### 28.01.2021
* add rewrite (remove) path k8s patch

|K8S Deployment Patch File|VARIABLE|Default values|Description|
|---|---|---|---|
|`k8s-deployment/overlays/ingress-controller/ingress-path-remove-rewrite.yml`|`K8S_URL_PATH`|` `|`ex: K8S_URL_PATH=/test, will be rewrited to /`|

##### 19.01.2021
* Feature add: Deploy initializing, create/update default files: .env, .gitignore, .dockerignore, devspace.yaml, kustomization.yaml
```shell
bash k8s-deployment/initDeploy.sh
```
* Lens version: For Namespaces Admins Required >= v.3.6.9 or a smaller version.

##### 12.01.2021
* Add: Create cron Job - Image Registry Update
* Add: Create cron Job - Clean all failed containers
```shell
bash k8s-deployment/deploy.sh --cronJobs=true
```
------------------------------------------------------------------------
##### 06.01.2021
* Add: volume claime yaml example

------------------------------------------------------------------------
##### 30.12.2020
* Update version.sh: creating VersMinor on project variables
* Update templates/gitlab-ci.yml: make it cross projects for deploy dev/prod into k8s

------------------------------------------------------------------------
##### 22.12.2020
* Add Tests Scenarios: Build, Deploy base (without patches), advanced deploy (with max patches compatibles ), incrementing version.
* Add Alternatives Deployment Container Registry Secret Patch for devopss-tools platform service`|

|K8S Deployment Patch File|VARIABLE|Default values|Description|
|---|---|---|---|
|`k8s-deployment/overlays/alternative_deployment_1/secret-image-repository-devopss-tools-platform.yml`|` `|` `|`Alternative 1 Deployment, Container Registry Secret for devopss-tools platform service`|
|`k8s-deployment/overlays/alternative_deployment_2/secret-image-repository-devopss-tools-platform.yml`|` `|` `|`Alternative 2 Deployment, Container Registry Secret for devopss-tools platform service`|
* <span style="color: red"> BUG Fix: 504 ingress controller upstream timed out while reading response header from upstream </span>

------------------------------------------------------------------------
##### 21.12.2020
* Fix readiness and readiness probes patches for alternative deployments
------------------------------------------------------------------------

##### 18.12.2020

* new K8S kustomization patches

|K8S Deployment Patch File|VARIABLE|Default values|Description|
|---|---|---|---|
|`k8s-deployment/overlays/storage/volume-dynamic-claim-mount.yml`|`K8S_VOLUME_CLAIM_NAME`<br>`K8S_VOLUME_MOUNT_PATH`|` `|`Mount K8S existent Volume(Claim by Name) into this Container PATH`|
|`k8s-deployment/overlays/alternative_deployment_1/volume-dynamic-claim-mount.yml`|`K8S_VOLUME_CLAIM_NAME`<br>`K8S_VOLUME_MOUNT_PATH`|` `|`Mount K8S existent Volume(Claim by Name) into this Container PATH`|
|`k8s-deployment/overlays/alternative_deployment_2/volume-dynamic-claim-mount.yml`|`K8S_VOLUME_CLAIM_NAME`<br>`K8S_VOLUME_MOUNT_PATH`|` `|`Mount K8S existent Volume(Claim by Name) into this Container PATH`|
|`k8s-deployment/overlays/storage/volume-claim-mount-to-nginx.yml`|`K8S_VOLUME_CLAIM_NAME`<br>`K8S_NGINX_FILES_LOCATION`|` `|`Mount K8S existent Volume(Claim by Name) into this NGINX Container PATH`|
```text
Note: K8S_NGINX_FILES_LOCATION=media example /usr/share/nginx/html/media
```
* Versioning 
```text
[ VersMajor,  VersMinor, VersPatch ]
add version.sh - For incrementing CI/CD project group's Settings -> Variables
```
```text
Into CI/CD Project Group Settings -> Variables
 - Set variables [ VersMajor,  VersMinor, VersPatch ] with value 0 (or VersMajor=1)
 - set CI_API_USER_TOKEN on project group
 - run command >  bash version.sh  --variable=VersMinor
Locally:
 - run command:  bash version.sh --token=<ci-api-user> --variable=VersMinor
```
------------------------------------------------------------------------
