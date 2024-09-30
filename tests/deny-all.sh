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
echo "deny all policy - expected timeout"
cat <<EOF | kubectl create -f -
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

! kubectl run -it --rm --restart=Never curl --image=appropriate/curl --command -- curl --max-time 3 -s -o /dev/null -w "%{http_code}" hello:80
success=$?

exit $success