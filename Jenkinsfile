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
                        // 1. Configure git settings
                        sh """
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        git checkout -B main
                        git pull origin main --ff-only
                        """

                        // 2. Automatically update the YAML file
                        sh "sed -i 's|image: nginx:1.25|image: $IMAGE:$TAG|g' deployment.yaml"
                        sh "git add deployment.yaml"
                        
                        // 3. SAFE PUSH: Using single quotes around the shell command prevents Jenkins from mangling the URL strings
                        if (sh(script: "git diff-index --quiet HEAD --", returnStatus: true) != 0) {
                            sh 'git commit -m "chore: automated update from nginx:1.25 to ${IMAGE}:${TAG} [skip ci]"'
                            sh 'git push https://${GH_USER}:${GH_TOKEN}@github.com/manasnarayan574-ui/argocd-demo.git HEAD:main'
                        } else {
                            echo "No changes to commit."
                        }
                    }
                }
            }
        }
    }
}
