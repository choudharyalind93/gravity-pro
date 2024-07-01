pipeline {
    agent none // No agent required for the initial stages
    environment {
        PROJECT_ID = 'xxxxxxxxxx'
        CLUSTER_NAME = 'xxxxxxxxxx'
        CLUSTER_ZONE = 'xxxxxxxxxx'
        DOCKER_IMAGE = "gcr.io/${PROJECT_ID}/node-app"
        DOCKER_HOME = '/usr/bin/docker'
        PATH = "$DOCKER_HOME:$PATH"
    }

    stages {
        stage('Read Pod Template') {
            agent any
            steps {
                script {
                    podTemplateYaml = readFile 'podTemplate.yaml'
                }
            }
        }
        stage('Run on Kubernetes') {
            agent {
                kubernetes {
                    cloud 'kubernetes'
                    yaml podTemplateYaml
                }
            }
            stages {
                stage('Build Docker Image') {
                    steps {
                        container('jenkins-agent') {
                            sh '''
                            docker build -t $DOCKER_IMAGE .
                            '''
                        }
                    }
                }
                stage('Authenticate with GCR') {
                    steps {
                        container('jenkins-agent') {
                            withCredentials([file(credentialsId: 'xxxxxxxxxx', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                                sh '''
                                    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                                    gcloud auth configure-docker
                                '''
                            }
                        }
                    }
                }
                stage('Push Docker Image') {
                    steps {
                        container('jenkins-agent') {
                            sh '''
                                docker push $DOCKER_IMAGE
                            '''
                        }
                    }
                }
                stage('Deploy to GKE') {
                    steps {
                        container('jenkins-agent') {
                            withCredentials([file(credentialsId: 'xxxxxxxxxx', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                                sh '''
                                    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                                    gcloud config set project $PROJECT_ID
                                    gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE
                                    kubectl apply -f k8s/deployment.yaml
                                    kubectl apply -f k8s/service.yaml
                                '''
                            }
                        }
                    }
                }
            }
        }
    }
}