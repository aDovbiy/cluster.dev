# Cluster.dev - Kubernetes-based Dev Environment in Minutes

Cluster.dev is an open-source system delivered as GitHub Action or Docker Image 
for creating and managing Kubernetes clusters with simple manifests by GitOps approach.  
Designed for developers that are bored to configure Kubernetes stuff
and just need: kubeconfig, dashboard, logging and monitoring out of the box.  

Based on DevOps and SRE best-practices. GitOps cluster management and application delivery.
Simple CICD integration. Easily extandable by pre-configured applications and modules. 
Supports different Cloud Providers and Kubernetes versions.

----
## Principle diagram. What it does?

![cluster.dev diagram](images/cluster-dev-diagram.png)

## How it works

In the background: 

 - Terraform creates a remote state file in your cloud account where all infrastructure objects are stored.
   Typically it is defined on Cloud Object Storage like AWS S3.
 - Terraform modules create Minikube/EKS/GKE/etc.. cluster within your Cloud Proivder using Account credentials.
 - ArgoCD Continuous Deployment system deployed inside Kubernetes cluster enables you to deploy your applications.

You receive:  

 - Automatically generated kubeconfig, ssh-access, Kubernetes Dashboard and ArgoCD UI url's. 

## Quick Start

Just create file in your repository  `.cluster.dev/minikube-a.yaml` 
```yaml
cluster:
  name: minikube-a
  cloud: 
    provider: aws
    region: eu-central-1
  provisioner:
    type: minikube
    instanceType: "m4.large"
```


Add a GitHub Workflow: `.github/workflows/main.yml`:  
```yaml
on: [push]
jobs:
  deploy_cluster_job:
    runs-on: ubuntu-latest
    name: Deploy and Update K8s Cluster
    steps:
    - name: Checkout Repo
      uses: actions/checkout@v1
    - name: Reconcile Clusters
      id: reconcile
      uses: shalb/cluster.dev@master
      with:
        cluster-config: './.cluster.dev/minikube-one.yaml'
        cloud-user: ${{ secrets.aws_access_key_id }}
        cloud-pass: ${{ secrets.aws_secret_access_key }}
    - name: Get the execution status
      run: echo "The status ${{ steps.validate.reconcile.status }}"
```

Also you need to add cloud credentials to your repo secrets, ex: 
```yaml
aws_access_key_id =  ATIAAJSXDBUVOQ4JR
aws_secret_access_key = SuperAwsSecret
```

That's it! Just push update and Cluster.dev will create for you a cluster in minutes.
And produce a working kubeconfig that could be downloaded and links to different UI's: Kibana, Grafana, Dashboard, etc...

## Contributing 

If you want to spread the project with your own code, you can start contributing with this quick guide: [CONTRIBUTING.md](./contributing/)