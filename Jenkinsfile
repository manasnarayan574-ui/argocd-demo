pipeline {
    agent any

    environment {
        // Your Docker Hub repository name
        IMAGE = "manasnarayan/myapp"
    }

    stages {
        stage('Build Image') {
            steps {
                script {
                    // Generates a unique timestamp tag so we don't just use 'latest'
                    TAG = sh(script: "date +%s", returnStdout: true).trim()
                    sh "docker build -t $IMAGE:$TAG ."
                }
            }
        }

        stage('Push Image') {
            steps {
                // Uses your saved Jenkins credentials to log into Docker Hub
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
                // Uses your GitHub Personal Access Token saved in Jenkins
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GH_USER', passwordVariable: 'GH_TOKEN')]) {
                    script {
                        // Ensure Jenkins pulls the absolute latest code from main first
                        sh "git checkout main"
                        sh "git pull origin main"

                        // THE AUTOMATION CONNECTION:
                        // This finds yesterday's manual 'image: nginx:1.25' and automatically 
                        // overwrites it with your brand new Docker Hub image and unique tag!
                        sh "sed -i 's|image: nginx:1.25|image: $IMAGE:$TAG|g' deployment.yaml"
                        
                        // Set Git identity so Jenkins can commit
                        sh """
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        """
                        
                        // Automatically stage, commit, and push the updated YAML back to GitHub
                        sh """
                        git add deployment.yaml
                        if ! git diff-index --quiet HEAD --; then
                            git commit -m "chore: automated update from nginx:1.25 to $IMAGE:$TAG [skip ci]"
                            git push https:\${GH_USER}:\${GH_TOKEN}@github.com/manasnarayan574-ui/argocd-demo.git HEAD:main
                        else
                            echo "No changes detected in deployment.yaml. Skipping commit."
                        fi
                        """
                    }
                }
            }
        }
    }
}
