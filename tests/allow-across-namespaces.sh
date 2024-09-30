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

echo "client in another namespace (policy allows access from all namespaces) - expected 200"
cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default.allow-hello-any-namespace
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: hello
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          run: curl
      namespaceSelector: {}
EOF

kubectl run --namespace second -it --rm --restart=Never curl --image=appropriate/curl --command -- curl --max-time 3 -s -o /dev/null -w "%{http_code}" hello.default.svc.cluster.local:80
success=$?

exit $success