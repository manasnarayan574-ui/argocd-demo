pipeline {
    agent any

    environment {
        // Your GitHub repository details
        GIT_REPO_URL = 'github.com/manasnarayan574-ui/argocd-demo.git'
        DEPLOYMENT_FILE = 'deployment.yaml'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Pulls your repository code cleanly
                git url: "https://${GIT_REPO_URL}", branch: 'main'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                // Uses the credential ID we just fixed ('github-token' handles your hub login or git push tokens)
                // We are tagging the image using the Jenkins build number
                sh "docker build -t nginx:v${BUILD_NUMBER} ."
            }
        }

        stage('Update Git Deployment Tag') {
            steps {
                // This securely injects your github-token credentials without breaking Groovy syntax
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    script {
                        echo "Modifying deployment.yaml with tag v${BUILD_NUMBER}..."
                        
                        // Changes line 17 'image: nginx:1.25' to 'image: nginx:v<build_number>'
                        sh "sed -i 's|image: nginx:.*|image: nginx:v${BUILD_NUMBER}|g' ${DEPLOYMENT_FILE}"
                        
                        echo "Configuring local git user..."
                        sh """
                            git config user.email "jenkins@yourdomain.com"
                            git config user.name "Jenkins CI"
                        """
                        
                        echo "Committing and pushing changes..."
                        sh """
                            git add ${DEPLOYMENT_FILE}
                            git commit -m "chore: automated image tag update to v${BUILD_NUMBER} [skip ci]"
                            git push https://${GIT_USER}:${GIT_TOKEN}@${GIT_REPO_URL} HEAD:main
                        """
                    }
                }
            }
        }
    }
}
