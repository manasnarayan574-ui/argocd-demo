pipeline {
    agent any

    environment {
        // From your uploaded screenshots
        DOCKER_IMAGE     = 'manasnarayan/myapp'
        GITHUB_REPO_URL  = 'github.com/manasnarayan574-ui/argocd-demo.git'
        
        // Credentials IDs set up in Jenkins
        DOCKER_CREDS_ID  = 'dockerhub-creds'
        GITHUB_CREDS_ID  = 'github-credentials'
        
        // Dynamic Tag based on Jenkins Build Number
        IMAGE_TAG        = "${BUILD_NUMBER}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clones the repository using your GitHub Credentials
                git url: "https://${GITHUB_REPO_URL}", branch: 'main', credentialsId: env.GITHUB_CREDS_ID
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE}:${IMAGE_TAG}"
                    sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Logs into Docker Hub and pushes the image
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo '${DOCKER_PASS}' | docker login -u '${DOCKER_USER}' --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Update Deployment YAML') {
            steps {
                script {
                    echo "Updating deployment.yaml with new image tag: ${IMAGE_TAG}"
                    
                    // Uses sed to find the image pattern and swap the tag cleanly
                    sh "sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${IMAGE_TAG}|g' deployment.yaml"
                }
            }
        }

        stage('Push Changes to GitHub') {
    steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                sh "git config user.email 'jenkins@automation.com'"
                sh "git config user.name 'Jenkins-CI-Bot'"
                
                sh "git add deployment.yaml"
                sh "git commit -m 'Automated manifest update: Image Tag ${IMAGE_TAG} [skip ci]'"
                
                // This is the most reliable way to push securely
                sh "git remote set-url origin https://${GIT_USER}:${GIT_TOKEN}@${GITHUB_REPO_URL}"
                sh "git push origin HEAD:main"
            }
        }
    }
}
