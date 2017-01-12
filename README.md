# DON'T USE UNTIL YOU REALY KNOW HOW IT WORKS

# Ansible playbook and roles to create a simple Kubernetes cluster with kubeadm and Terraform on OpenStack

## Goal

Provide an Ansible playbook that implements the steps described in [Installing Kubernetes on Linux with kubeadm](http://kubernetes.io/docs/getting-started-guides/kubeadm/)

## Assumptions

This playbook assumes: 

* Access to OpenStack
* Access to the Internet
* Docker or local installation of Terraform and kubectl
* You are Ansible-knowledgable, can ssh into all the machines, and can sudo with no password prompt
* Make sure your machines are time-synchronized

## Configuration

1. Build Dockerfile
2. Copy ssh key to actuall workspace (see ansible.cfg)
3. Run docker
3. Change OSS variables as needed
4. Start OSS stack

## Components
- 3 instances with docker 1.11.2 and overlay storage driver
 - 1x master
 - 2x node

# Spin up stack

```bash
## Clone repozitory:
[root@workstation ]# git clone https://github.com/VAdamec/ansible-kubeadm-cluster

# Run Docker
[root@workstation ]# docker build . -t kubernetes-stack
[root@workstation ]# docker run -v `pwd`:/code -ti kubernetes-stack /bin/bash

## Rename sample variables and add your credentials
[root@container /]# cd /code
[root@container code]# mv variables.sample variables.tf
[root@container code]# vi variables.tf
[root@container code]# terraform plan
[root@container code]# terraform apply

## Destroy stack
[root@container code]# terraform detroy
```

After you have done this, you should be able to succesfully execute something like this:

```
    ansible -m ping -i ./terraform.py all
```

And your master and node machines should respond.  Don't bother proceeding until this works!

## Run the playbook

When you are ready to proceed, run:

```
    ansible-playbook cluster.yml -i ./terraform.py
    
    kubectl --kubeconfig remotes/devops.conf proxy

    open http://localhost:8001/ui/
```

This should execute/implement all four installation steps in the aforementioned installation guide.

The guide then provides examples you can run to test your cluster.

If you want to interact with your cluster via the kubectl command on your own machine (and why wouldn't you?), take note of the last note in the "Limitations" section of the guide:

```
         There is not yet an easy way to generate a kubeconfig file which can be used to authenticate to the cluster remotely with kubectl on, 
         for example, your workstation. Workaround: copy the kubelet’s kubeconfig from the master: use 
           scp root@<master>:/etc/kubernetes/admin.conf . 
         and then e.g. kubectl --kubeconfig ./admin.conf get nodes from your workstation.
```

The playbook retrieves the admin.conf file, and stores it locally as ```./remotes/cluster_name.conf``` to facilitate remote kubectl access.


## Pods installed by Ansible
* https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
 * enable UI at http://localhost:8001/ui/
* heapster stack
 * start metrics grabbing to InfluxDB (visible graphs in UI)
* https://cloud.weave.works/launch/k8s/weavescope.yaml
 * UI for weave and k8s/containers overview/dynamic map, to forward port use this command:

```
kubectl port-forward $(kubectl get pod --selector=weave-scope-component=app -o jsonpath='{.items..metadata.name}') 4040
ssh -f -N -L 4040:localhost:4040 centos@<MASTER> -i ~/.ssh/terraform.pem
```
* Selenium grid
 * chrome
 * firefox


 ```bash
 # Get service port
 $ kubectl get svc selenium-hub
 NAME           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
 selenium-hub   10.106.233.200   <nodes>       4444:32448/TCP   8m

$ export NODEPORT=`kubectl --kubeconfig remotes/devops.conf get svc --selector='app=selenium-hub' --output=template --template="{{ with index .items 0}}{{with index .spec.ports 0 }}{{.nodePort}}{{end}}{{end}}"`
$ export NODEIP=`kubectl --kubeconfig remotes/devops.conf describe  nodes devops-kubestack-node-01 | perl -wnE'say for /Addresses:\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\,.*/g'`

# Out of Docker, on your workstation
$ open http://${NODEIP}:${NODEPORT}
 ```
 * Scaling example
 ```bash
 $ kubectl scale --replicas=3 rc/selenium-node-chrome
 $ kubectl scale --replicas=3 rc/selenium-node-firefox
 ```

## Idempotency

* I belive I have made admission token generation idempotent. Generated tokens are stored in ```./tokens/cluster_name.yml```, and reused on subsequent playbook runs
* I'm not sure how to know that the init and join operations have successfully completed, I've tried to base it on files/directories that are created, but not yet certain that is correct.
* It seems like re-issuing the ```kubectl apply -f https://git.io/weave-kube``` is harmless, but again, I'm not certain...


## Notes and Caveats

* This playbook is under active development, but is not extensively tested.
* I have successfully run this to completion on a 3 machine Ubuntu setup, it basically worked the first time.
* I haven't yet succeeded in getting a cluster working perfectly on Centos 7. I spent all day today (2016-09-30) trying to do so, and ran into all kinds of issues, stay tuned for updates.
* I don't yet understand much or anything about the Kubernetes pod network "Weave Net" the guide and this playbook installs.  Be forewarned!

## Acknowlegements

* Huge kudos to the authors of kubeadm and [its getting started guide](http://kubernetes.io/docs/getting-started-guides/kubeadm/)
* Joe Beda [provided the code to generate tokens, and how to feed a token into kubeadm init](https://github.com/upmc-enterprises/kubeadm-aws/issues/1)
* @marun pointed me to the documentation about how to access the master remotely via kubectl

## Contributing

Pull requests and issues are welcome.












