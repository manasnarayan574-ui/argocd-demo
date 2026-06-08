pipeline {
    agent any

    environment {
        // Configuration
        DOCKER_IMAGE    = 'manasnarayan/myapp'
        GITHUB_REPO     = 'github.com/manasnarayan574-ui/argocd-demo.git'
        
        // Credential IDs as they appear in Jenkins
        DOCKER_CREDS    = 'dockerhub-creds'
        GITHUB_CREDS    = 'github-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                // This uses Jenkins built-in Git plugin to handle auth securely
                git credentialsId: env.GITHUB_CREDS, url: "https://${GITHUB_REPO}", branch: 'main'
            }
        }

        stage('Build and Push Docker') {
            steps {
                script {
                    def tag = "${env.BUILD_NUMBER}"
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDS, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "docker build -t ${DOCKER_IMAGE}:${tag} ."
                        sh "echo '${PASS}' | docker login -u '${USER}' --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${tag}"
                    }
                }
            }
        }

        stage('Update Manifest') {
            steps {
                script {
                    def tag = "${env.BUILD_NUMBER}"
                    // Update the yaml file
                    sh "sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${tag}|g' deployment.yaml"
                    
                    // Secure Push to GitHub
                    withCredentials([usernamePassword(credentialsId: env.GITHUB_CREDS, usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                        git config user.email 'jenkins@automation.com'
                        git config user.name 'Jenkins-CI-Bot'
                        git add deployment.yaml
                        git commit -m 'Update image tag to ${tag} [skip ci]'
                        
                        # Use a credential-free push by configuring the remote URL once
                        git remote set-url origin https://${GIT_USER}:${GIT_TOKEN}@${GITHUB_REPO}
                        git push origin main
                        """
                    }
                }
            }
        }
    }
}
