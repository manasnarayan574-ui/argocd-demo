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
                        // 1. Cleanly track the main branch
                        sh "git checkout main"
                        sh "git pull origin main"

                        // 2. THE EXACT SWAP: Finds yesterday's 'image: nginx:1.25' and automatically rewrites it to your new Docker Hub 'latest' image
                        sh "sed -i 's|image: nginx:1.25|image: manasnarayan/myapp:latest|g' deployment.yaml"
                        
                        // 3. Configure Git identity for Jenkins
                        sh """
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        """
                        
                        // 4. Automatically commit and push back to GitHub
                        sh """
                        git add deployment.yaml
                        if ! git diff-index --quiet HEAD --; then
                            git commit -m "chore: automated update from nginx:1.25 to custom latest image [skip ci]"
                            git push https:\${GH_USER}:\${GH_TOKEN}@github.com/manasnarayan574-ui/argocd-demo.git HEAD:main
                        else
                            echo "No changes detected. Skipping commit."
                        fi
                        """
                    }
                }
            }
        }
