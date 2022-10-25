apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${K8S_CA}
    server: ${K8S_CLUSTER_SERVER_URL}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: ${K8S_APP_NAMESPACE}
    user: ${K8S_CLUSTER_USER}
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: ${K8S_CLUSTER_USER}
  user:
    client-certificate-data: ${K8S_CLIENT_CERT}
    client-key-data: ${K8S_CLIENT_KEY_DATA}
    token: ${K8S_USER_ADMIN_TOKEN}
