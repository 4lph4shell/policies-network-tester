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
echo "empty port allows all ports - expected 200"
cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: all-ports
spec:
  podSelector:
    matchLabels:
      run: curl
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector: {}
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
    - protocol: UDP
      port: 54 # open 54 too in case tufindns is installed
EOF

kubectl run -it --rm --restart=Never curl --image=appropriate/curl --command -- curl ${CURL_PROXY} --max-time 3 -s -o /dev/null -w "%{http_code}" www.google.com
success1=$?

kubectl run -it --rm --restart=Never curl --image=appropriate/curl --command -- curl --max-time 3 -s -o /dev/null -w "%{http_code}" hello:80
success2=$?

[[ $success1 = 0 ]] && [[ $success2 = 0 ]] ; success=$?

exit $success