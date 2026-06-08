pipeline {
    agent any

    environment {
        // Configuration
        DOCKER_IMAGE    = 'manasnarayan/myapp'
        REPO_URL        = 'github.com/manasnarayan574-ui/argocd-demo.git'
        
        // Ensure these IDs match EXACTLY what you see in Jenkins Credentials
        DOCKER_CREDS    = 'dockerhub-creds'
        GITHUB_CREDS    = 'github-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                // Securely pull the code
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[credentialsId: env.GITHUB_CREDS, url: "https://${env.REPO_URL}"]]])
            }
        }

        stage('Build and Push Docker') {
            steps {
                script {
                    def tag = "${env.BUILD_NUMBER}"
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDS, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "docker build -t ${env.DOCKER_IMAGE}:${tag} ."
                        sh "echo '${PASS}' | docker login -u '${USER}' --password-stdin"
                        sh "docker push ${env.DOCKER_IMAGE}:${tag}"
                    }
                }
            }
        }

        stage('Update and Push Manifest') {
            steps {
                script {
                    def tag = "${env.BUILD_NUMBER}"
                    sh "sed -i 's|image: ${env.DOCKER_IMAGE}:.*|image: ${env.DOCKER_IMAGE}:${tag}|g' deployment.yaml"
                    
                    withCredentials([usernamePassword(credentialsId: env.GITHUB_CREDS, usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        // This block stores the credentials in memory, then performs a clean push
                        sh """
                        git config user.email 'jenkins@automation.com'
                        git config user.name 'Jenkins-CI-Bot'
                        
                        git config credential.helper store
                        echo "https://${GIT_USER}:${GIT_TOKEN}@github.com" > ~/.git-credentials
                        
                        git add deployment.yaml
                        git commit -m 'Update image tag to ${tag} [skip ci]'
                        
                        # With the helper configured, this command is now plain text
                        # No special characters, no shell interpretation issues.
                        git push origin main
                        """
                    }
                }
            }
        }
    }
}
