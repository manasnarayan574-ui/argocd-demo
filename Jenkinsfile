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
                cleanWs()
                checkout scm
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
                        git config user.email 'jenkins@automation.com'
                        git config user.name 'Jenkins-CI-Bot'
                        
                        git add deployment.yaml
                        git commit -m 'Update image tag to ${tag} [skip ci]' || echo 'No changes to commit'
                        
                        # Remove old origin safely
                        git remote remove origin || true
                        
                        # HARDCODED USERNAME: This prevents the Jenkins credential from injecting a space.
                        # We only pull the GIT_TOKEN from the credentials block now.
                        git remote add origin https://manasnarayan574-ui:${GIT_TOKEN}@${env.REPO_URL}
                        
                        # THE REFSPEC FIX: Push the detached HEAD directly to remote main
                        git push origin HEAD:main
                        """
                    }
                }
            }
        }
    }
}
