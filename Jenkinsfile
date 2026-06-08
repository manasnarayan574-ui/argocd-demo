pipeline {
    agent any

    environment {
        // Configuration
        DOCKER_IMAGE    = 'manasnarayan/myapp'
        GITHUB_REPO_URL = 'github.com/manasnarayan574-ui/argocd-demo.git'
        
        // These ID's must match what you have in Jenkins Credentials exactly
        DOCKER_CREDS    = 'dockerhub-creds'
        GITHUB_CREDS    = 'github-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                // This command ensures 'origin' is set correctly for the whole build
                sh "git remote add origin https://${GITHUB_REPO_URL} || git remote set-url origin https://${GITHUB_REPO_URL}"
                git credentialsId: env.GITHUB_CREDS, url: "https://${GITHUB_REPO_URL}", branch: 'main'
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
                    sh "sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${tag}|g' deployment.yaml"
                    
                    withCredentials([usernamePassword(credentialsId: env.GITHUB_CREDS, usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        // We push using the authenticated URL directly to avoid remote configuration issues
                        sh """
                        git config user.email 'jenkins@automation.com'
                        git config user.name 'Jenkins-CI-Bot'
                        git add deployment.yaml
                        git commit -m 'Update image tag to ${tag} [skip ci]'
                        git push https://${GIT_USER}:${GIT_TOKEN}@${GITHUB_REPO_URL} HEAD:main
                        """
                    }
                }
            }
        }
    }
}
