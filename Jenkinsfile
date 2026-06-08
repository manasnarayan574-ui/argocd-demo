pipeline {
    agent any

    environment {
        IMAGE = "manasnarayan/myapp"
        TAG   = "${BUILD_NUMBER}"
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/manasnarayan574-ui/argocd-demo.git'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    sh "docker build -t $IMAGE:$TAG ."
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                script {
                    // This matches your ID 'dockerhub-creds' perfectly
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "echo \$PASS | docker login -u \$USER --password-stdin"
                        sh "docker push $IMAGE:$TAG"
                    }
                }
            }
        }

        stage('Update Deployment YAML') {
            steps {
                script {
                    sh "sed -i 's|image:.*|image: ${IMAGE}:${TAG}|g' deployment.yaml"
                }
            }
        }

        stage('Push Changes to GitHub') {
            steps {
                script {
                    // FIXED: Changed from 'github-token-creds' to match your actual ID: 'github-token'
                    withCredentials([usernamePassword(credentialsId: 'github-token', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'GITHUB_USER')]) {
                        
                        sh "git config user.email 'jenkins@automation.com'"
                        sh "git config user.name 'Jenkins CI'"
                        
                        sh "git add deployment.yaml"
                        sh "git commit -m 'Automated sync: image tag updated to ${TAG} [skip ci]'"
                        
                        sh "git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/manasnarayan574-ui/argocd-demo.git HEAD:main"
                    }
                }
            }
        }
    }
}
