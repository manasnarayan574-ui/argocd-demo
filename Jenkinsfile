pipeline {
    agent any

    environment {
        IMAGE = "manasnarayan/myapp"
    }

    stages {
        stage('Build Image') {
            steps {
                script {
                    TAG = sh(script: "date +%s", returnStdout: true).trim()
                    sh "docker build -t $IMAGE:$TAG ."
                }
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'U', passwordVariable: 'P')]) {
                    sh """
                    echo \$P | docker login -u \$U --password-stdin
                    docker push $IMAGE:$TAG
                    """
                }
            }
        }

        stage('Update Deployment File & Push to Git') {
            steps {
                // 1. Inject your GitHub credentials safely
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GH_USER', passwordVariable: 'GH_TOKEN')]) {
                    script {
                        // 2. Update the deployment.yaml file with the new image tag
                        sh "sed -i 's|nginx:latest|$IMAGE:$TAG|g' deployment.yaml"
                        
                        // 3. Configure local git profile for the commit
                        sh """
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        """
                        
                        // 4. Commit the changes
                        sh """
                        git add deployment.yaml
                        git commit -m "chore: automated image tag update to $TAG [skip ci]"
                        """
                        
                        // 5. Push back to your repository using the token safely
                        sh """
                        git push https://${GH_USER}:${GH_TOKEN}@github.com/${GH_USER}/argocd-demo.git HEAD:main
                        """
                    }
                }
            }
        }
    }
}
