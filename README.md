# to create a gke cluster and its associated network components 
# obtain privileges for the serivce account is being used
# source the service account key on local to initiate the tf

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