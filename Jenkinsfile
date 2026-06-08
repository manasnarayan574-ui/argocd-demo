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
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GH_USER', passwordVariable: 'GH_TOKEN')]) {
                    script {
                        // 1. Fix Detached HEAD by pulling latest changes and tracking main branch
                        sh "git checkout main"
                        sh "git pull origin main"

                        // 2. Dynamic sed: Finds your image name with ANY old tag and replaces it with the new one
                        sh "sed -i 's|manasnarayan/myapp:[^ ]*|manasnarayan/myapp:$TAG|g' deployment.yaml"
                        
                        // 3. Configure local git profile for Jenkins
                        sh """
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        """
                        
                        // 4. Safety Check: Only commit and push if deployment.yaml actually changed
                        sh """
                        git add deployment.yaml
                        if ! git diff-index --quiet HEAD --; then
                            git commit -m "chore: automated image tag update to $TAG [skip ci]"
                            git push https:\${GH_USER}:\${GH_TOKEN}@github.com/manasnarayan574-ui/argocd-demo.git HEAD:main
                        else
                            echo "No changes detected in deployment.yaml. Skipping git commit."
                        fi
                        """
                    }
                }
            }
        }
    }
}
