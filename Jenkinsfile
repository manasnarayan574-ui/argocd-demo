pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/manasnarayan574-ui/argocd-demo.git', branch: 'main'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                sh "docker build -t nginx:v${BUILD_NUMBER} ."
            }
        }

        stage('Update Git Deployment Tag') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    script {
                        echo "Modifying deployment.yaml with tag v${BUILD_NUMBER}..."
                        sh "sed -i 's|image: nginx:.*|image: nginx:v${BUILD_NUMBER}|g' deployment.yaml"
                        
                        echo "Configuring local git user identity..."
                        sh """
                            git config user.email "jenkins@yourdomain.com"
                            git config user.name "Jenkins CI"
                        """
                        
                        echo "Committing changes..."
                        sh """
                            git add deployment.yaml
                            git commit -m "chore: automated image tag update to v${BUILD_NUMBER} [skip ci]"
                        """
                        
                        echo "Pushing changes back to GitHub repository..."
                        sh "git push https://${GIT_USER}:${GIT_TOKEN}@github.com/manasnarayan574-ui/argocd-demo.git HEAD:main"
                    }
                }
            }
        }
    }
}
