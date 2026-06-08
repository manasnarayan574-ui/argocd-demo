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

        stage('Update Git Deployment Tag') {
    steps {
        // 'github-token' must match the exact ID of your credential in Jenkins
        withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
            script {
                // 1. Update the local file
                sh "sed -i 's|image: nginx:.*|image: nginx:v${BUILD_NUMBER}|g' deployment.yaml"
                
                // 2. Configure Git identity so the commit doesn't fail
                sh """
                    git config user.email "jenkins@yourdomain.com"
                    git config user.name "Jenkins CI"
                    git add deployment.yaml
                    git commit -m "chore: automated image tag update to v${BUILD_NUMBER} [skip ci]"
                """
                
                // 3. The exact syntax that prevents the 'Bad hostname' error:
                sh "git push https://${GIT_USER}:${GIT_TOKEN}@github.com/manasnarayan574-ui/argocd-demo.git HEAD:main"
            }
        }
    }
}
