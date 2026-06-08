pipeline {
    agent any

    environment {
        DOCKER_IMAGE    = 'manasnarayan/myapp'
        REPO_URL        = 'github.com/manasnarayan574-ui/argocd-demo.git'
        DOCKER_CREDS    = 'dockerhub-creds'
        GITHUB_CREDS    = 'github-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                // Ensure we have a clean workspace
                cleanWs()
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[credentialsId: env.GITHUB_CREDS, url: "https://${env.REPO_URL}"]]])
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
                        sh """
                        # Basic Identity
                        git config user.email 'jenkins@automation.com'
                        git config user.name 'Jenkins-CI-Bot'
                        
                        # Prepare Commit
                        git add deployment.yaml
                        git commit -m 'Update image tag to ${tag} [skip ci]'
                        
                        # Forcefully reset origin to use the authenticated URL
                        git remote remove origin
                        git remote add origin https://${GIT_USER}:${GIT_TOKEN}@${env.REPO_URL}
                        
                        # Explicitly push the local branch to the remote branch
                        git push origin main:main
                        """
                    }
                }
            }
        }
    }
}
