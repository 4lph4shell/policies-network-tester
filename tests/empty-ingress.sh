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
echo "policy with empty 'ingress' denies all - expected timeout"
cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: empty-ingress
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: hello
  policyTypes:
  - Ingress
  ingress:
EOF

! kubectl run -it --rm --restart=Never curl --image=appropriate/curl --command -- curl --max-time 3 -s -o /dev/null -w "%{http_code}" hello:80
success=$?

exit $success