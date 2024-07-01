# Runbook 

# Crete a gke cluster and its components

cd infra

terraform init 
terraform plan
terraform apply

#### Jenkinsfile is build to setup CI/CD pipeline

-> Cloning repo -> build node js image -> pushing to GCR -> GKE deployment

### App Deployment 

-> node-app

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml