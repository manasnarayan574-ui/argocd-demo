pipeline {
    agent any

    environment {
        // Match the repository name from your setup
        IMAGE = "manasnarayan/myapp"
        // Using Jenkins build number makes tracking much cleaner than a massive timestamp!
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
                    // Builds your docker image with the specific build tag
                    sh "docker build -t $IMAGE:$TAG ."
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                script {
                    // Update 'dockerhub-creds' to match whatever your actual Jenkins Credential ID is called
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
                    // This dynamically updates line 17 from 'image: nginx:1.25' to 'image: manasnarayan/myapp:TAG'
                    // Using '|' as a delimiter so the forward slashes in the image name don't break sed
                    sh "sed -i 's|image:.*|image: ${IMAGE}:${TAG}|g' deployment.yaml"
                }
            }
        }

        stage('Push Changes to GitHub') {
            steps {
                script {
                    // Authenticates using your GitHub credentials set up in Jenkins
                    // Update 'github-token-creds' to match your GitHub Username/Password or Token ID in Jenkins
                    withCredentials([usernamePassword(credentialsId: 'github-token-creds', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'GITHUB_USER')]) {
                        
                        // Set up local git configs so the commit doesn't fail
                        sh "git config user.email 'jenkins@company.com'"
                        sh "git config user.name 'Jenkins CI'"
                        
                        // Commit the updated deployment.yaml file
                        sh "git add deployment.yaml"
                        sh "git commit -m 'Automated deployment update: image tag ${TAG} [skip ci]'"
                        
                        // Push the update back to your GitHub main branch
                        sh "git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/manasnarayan574-ui/argocd-demo.git HEAD:main"
                    }
                }
            }
        }
    }
}
