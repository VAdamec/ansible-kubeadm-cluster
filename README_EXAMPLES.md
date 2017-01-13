# Examples for K8S

## Guest book
* https://github.com/kubernetes/kubernetes/tree/release-1.5/examples/guestbook-go

```bash
kubectl create -f examples/guestbook-go/redis-master-controller.json
kubectl create -f examples/guestbook-go/redis-master-service.json

kubectl create -f examples/guestbook-go/redis-slave-controller.json
kubectl create -f examples/guestbook-go/redis-slave-service.json

kubectl create -f examples/guestbook-go/guestbook-controller.json
kubectl create -f examples/guestbook-go/guestbook-service.json

kubectl scale --replicas=3 rc/guestbook
```

```bash
/code/bin/wrk -t12 -c400 -d30s http://172.24.248.253:31625/
Running 30s test @ http://172.24.248.253:31625/
  12 threads and 400 connections


  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   180.87ms   14.07ms 568.87ms   79.31%
    Req/Sec   183.15     87.42   333.00     62.04%
  65187 requests in 30.10s, 68.82MB read
Requests/sec:   2165.88
Transfer/sec:      2.29MB
```

## Quotas

```bash
$ kubectl create namespace myspace

$ cat <<EOF > compute-resources.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
spec:
  hard:
    pods: "4"
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
EOF
$ kubectl create -f ./compute-resources.yaml --namespace=myspace
```

```bash
$ cat <<EOF > object-counts.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
spec:
  hard:
    configmaps: "10"
    persistentvolumeclaims: "4"
    replicationcontrollers: "20"
    secrets: "10"
    services: "10"
    services.loadbalancers: "2"
EOF
$ kubectl create -f ./object-counts.yaml --namespace=myspace
$ kubectl get quota --namespace=myspace
NAME                    AGE
compute-resources       30s
object-counts           32s
```

```bash
$ kubectl describe quota compute-resources --namespace=myspace
Name:                  compute-resources
Namespace:             myspace
Resource               Used Hard
--------               ---- ----
limits.cpu             0    2
limits.memory          0    2Gi
pods                   0    4
requests.cpu           0    1
requests.memory        0    1Gi
```

```bash
$ kubectl describe quota object-counts --namespace=myspace
Name:                   object-counts
Namespace:              myspace
Resource                Used    Hard
--------                ----    ----
configmaps              0       10
persistentvolumeclaims  0       4
replicationcontrollers  0       20
secrets                 1       10
services                0       10
services.loadbalancers  0       2
```

```bash
kubectl run nginx --image=nginx --replicas=1 --requests=cpu=100m,memory=256M --limits=cpu=200m,memory=512Mi --namespace=myspace
kubectl get pods --namespace=myspace

# Only 4 will be created, others will failed - forbidden due quota
kubectl scale --replicas=6 deployment/nginx --namespace=myspace
# Or use
kubectl edit deployment/nginx --namespace=myspace

# See deployment processing
kubectl rollout status deployment/nginx  --namespace=myspace
```

```bash
kubectl delete deployment,services -l run=nginx --namespace=myspace
```
