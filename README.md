# policies-network-tester
 test-network-policies
This repo contains a set of tests for Kubernetes network policies.  
test-netpol.sh sets up a 'hello' pod and service in namespace default and a second namespace 'second'.  
Then, each test script under tests applies some network policy and runs a client pod to test that connectivity succeeds or fails according to expected behavior.

## Setting up a cluster
Before running the tests, setup a cluster with **network policies enabled**.  
Note that GKE disables network policies by default.

## Connecting to the cluster
Make sure you are connected to your cluster as cluster admin.  
`kubectl` should be able to create pods, services and network policies.

## Running the tests

Run all tests (with proxy):
```
# CURL_PROXY="-x 10.0.1.10:3128"
./test-netpol.sh
```

You should see "SUCCESS" after each test.
If you see "FAIL" then something went wrong.  
If you think its a bug, please submit an issue with the kubernetes and CNI platform/version details, and the failing test.

Run a single test:
```
# pass relative path to test file as argument
./test-netpol.sh tests/alllow-all-without-internet.sh 
```
