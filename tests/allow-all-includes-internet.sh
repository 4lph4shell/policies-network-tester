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
echo "egress all allows access to the internet - expected 200"

cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-to-1.1.1.1
  namespace: default
spec:
  podSelector: {}
  egress:
  - to:
    - ipBlock:
        cidr: 1.1.1.1/32
  policyTypes:
  - Egress
EOF

# egress only allowed to 1.1.1.1 - access to google should fail
! kubectl run -it --rm --restart=Never curl --image=appropriate/curl --command -- curl ${CURL_PROXY} --max-time 3 -s -o /dev/null -w "%{http_code}" www.google.com
success1=$?

cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-egress
  namespace: default
spec:
  podSelector: {}
  egress:
  - {}
  policyTypes:
  - Egress
EOF

# egress allowed to everything - access to internet should succeed
kubectl run -it --rm --restart=Never curl --image=appropriate/curl --command -- curl ${CURL_PROXY} --max-time 3 -s -o /dev/null -w "%{http_code}" www.google.com
success2=$?

[[ $success1 = 0 ]] && [[ $success2 = 0 ]] ; success=$?
exit $success