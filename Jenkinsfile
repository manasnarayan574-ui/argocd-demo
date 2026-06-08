pipeline {
    agent any

    environment {
        DOCKER_IMAGE    = 'manasnarayan/myapp'
        GITHUB_CREDS    = 'github-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                // This clones and sets up the remote perfectly
                checkout scm
            }
        }

        stage('Build and Push Docker') {
            steps {
                script {
                    def tag = "${env.BUILD_NUMBER}"
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "docker build -t ${DOCKER_IMAGE}:${tag} ."
                        sh "echo '${PASS}' | docker login -u '${USER}' --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${tag}"
                    }
                }
            }
        }

        stage('Update and Push Manifest') {
            steps {
                script {
                    def tag = "${env.BUILD_NUMBER}"
                    sh "sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${tag}|g' deployment.yaml"
                    
                    // Native Git configuration without shell URL construction
                    sh "git config user.email 'jenkins@automation.com'"
                    sh "git config user.name 'Jenkins-CI-Bot'"
                    sh "git add deployment.yaml"
                    sh "git commit -m 'Update image tag to ${tag} [skip ci]'"
                    
                    // The 'push' step via Jenkins Plugin
                    // This uses the credentials already defined in the Checkout stage
                    sshagent(credentials: [env.GITHUB_CREDS]) {
                        sh "git push origin main"
                    }
                }
            }
        }
    }
}
