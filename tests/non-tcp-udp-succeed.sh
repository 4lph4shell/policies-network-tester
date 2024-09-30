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
echo "test ping (not tcp, nor udp) - expected 0"
cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: all-ports
spec:
  podSelector:
    matchLabels:
      run: ping
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector: {}
    - ipBlock:
        cidr: 8.8.8.8/32
EOF

kubectl run  -it --rm --restart=Never ping --image=busybox --command -- ping -c1 8.8.8.8
success=$?

exit $success