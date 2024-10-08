#!/usr/bin/env bash

# ASCII Art Banner
AUTOCLICKER_TEXT="""\033[95m
   ___ _       _       ___     _          _ _  
  /   | |     | |     /   |   | |        | | |
 / /| | |_ __ | |__  / /| |___| |__   ___| | |
/ /_| | | '_ \| '_ \/ /_| / __| '_ \ / _ \ | |
\___  | | |_) | | | \___  \__ \ | | |  __/ | |
    |_/_| .__/|_| |_|   |_/___/_| |_|\___|_|_|
        | |                                   
        |_|                                   
\033[0m"""

echo -e "$AUTOCLICKER_TEXT"

AssertSuccess () {
  if [ $1 -ne 0 ]; then
    echo "############"
    echo "### FAIL ###"
    echo "############"
  else
    echo "###########"
    echo "# SUCCESS #"
    echo "###########"
  fi
}

CleanupNetworkPolicies () {
  for ns in $(kubectl get namespace -o jsonpath="{.items[*].metadata.name}"); do
    for np in $(kubectl get networkpolicies --namespace $ns -o jsonpath="{.items[*].metadata.name}"); do
      kubectl delete networkpolicies $np --namespace $ns
    done
  done
}

Cleanup () {
  echo ""
  echo "cleaning up..."
  kubectl delete service hello
  kubectl delete deployment hello
  kubectl delete namespace second
  kubectl delete pod curl
  kubectl delete pod ping
  CleanupNetworkPolicies
}

if [ "$1" != "" ]; then
  test_file=$1
fi

Cleanup

echo ""
echo "creating 'hello' deployment..."
cat <<EOF | kubectl create -f -
apiVersion: apps/v1 
kind: Deployment
metadata:
  labels:
    app: hello
  name: hello
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
      - image: rancher/hello-world
        imagePullPolicy: Always
        name: hello
        ports:
        - containerPort: 80
          name: http
EOF

echo ""
echo "creating 'hello' service..."
kubectl expose deployment hello --type=ClusterIP --port=80 --target-port=http

echo ""
echo "creating 'second' namespace..."
kubectl create namespace second
kubectl label namespace second namespace=second

echo ""
echo "waiting for hello pod to be ready..."
kubectl rollout -n default status deployment hello
echo "pod is ready"

echo ""
echo "running tests..."
for f in tests/*; do
  if [ "$test_file" = "" ] || [ "$f" = "$test_file" ]; then
    echo ""
    echo "$f"
    bash "$f" -H
    AssertSuccess $?
    CleanupNetworkPolicies
  fi
done

Cleanup
