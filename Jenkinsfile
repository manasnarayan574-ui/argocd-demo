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
                    // Generates a unique timestamp tag
                    TAG = sh(script: "date +%s", returnStdout: true).trim()
                    sh "docker build -t $IMAGE:$TAG ."
                }
            }
        }

        stage('Push Image') {
            steps {
                // Logs into Docker Hub using your saved credentials
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
                        // Cleanly pull and track the main branch first
                        sh "git checkout main"
                        sh "git pull origin main"

                        // THE AUTOMATION CONNECTION:
                        // Finds yesterday's manual 'image: nginx:1.25' and rewrites it to your new Docker Hub image
                        sh "sed -i 's|image: nginx:1.25|image: $IMAGE:$TAG|g' deployment.yaml"
                        
                        // Set Git identity so Jenkins can make the commit
                        sh """
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        git add deployment.yaml
                        """
                        
                        // Checks if changes exist, then commits and pushes using clean string concatenation to fix the SSH bug
                        if (sh(script: "git diff-index --quiet HEAD --", returnStatus: true) != 0) {
                            sh "git commit -m 'chore: automated update from nginx:1.25 to $IMAGE:$TAG [skip ci]'"
                            sh 'git push https://' + GH_USER + ':' + GH_TOKEN + '@github.com/manasnarayan574-ui/argocd-demo.git HEAD:main'
                        } else {
                            echo "No changes detected in deployment.yaml. Skipping commit."
                        }
                    }
                }
            }
        }
    }
}
