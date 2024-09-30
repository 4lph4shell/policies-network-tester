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
echo "egress to all pods, prohibits access to the internet - expected timeout"
cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-all-pods
spec:
  podSelector: {}
  egress:
  - to:
    - podSelector: {}
  policyTypes:
  - Egress
EOF

! kubectl run -it --rm --restart=Never curl --image=appropriate/curl --command -- curl --max-time 3 -s -o /dev/null -w "%{http_code}" www.google.com
success=$?

exit $success