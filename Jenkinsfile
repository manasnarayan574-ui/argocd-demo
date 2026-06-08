pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                // Pulls your code from GitHub cleanly
                git url: 'https://github.com/manasnarayan574-ui/argocd-demo.git', branch: 'main'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                // This part already works perfectly for you
                sh "docker build -t nginx:v${BUILD_NUMBER} ."
                // Add your docker push command here if needed
            }
        }

        stage('Update Git Deployment Tag') {
            steps {
                // Using usernamePassword injection cleanly inside the block
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    script {
                        echo "Modifying deployment.yaml with the new build tag..."
                        // Automatically replaces 'image: nginx:<anything>' with 'image: nginx:v<build_number>'
                        sh "sed -i 's|image: nginx:.*|image: nginx:v${BUILD_NUMBER}|g' deployment.yaml"
                        
                        echo "Setting local Git identity..."
                        sh """
                            git config user.email "jenkins@yourdomain.com"
                            git config user.name "Jenkins CI"
                        """
                        
                        echo "Staging and committing the updated deployment file..."
                        sh """
                            git add deployment.yaml
                            git commit -m "chore: automated image tag update to v${BUILD_NUMBER} [skip ci]"
                        """
                        
                        echo "Pushing changes back to GitHub..."
                        // This exact URL format avoids the Git 128 / Bad Hostname error completely
                        sh "git push https://${GIT_TOKEN}@github.com/manasnarayan574-ui/argocd-demo.git HEAD:main"
                    }
                }
            }
        }
    }
}
