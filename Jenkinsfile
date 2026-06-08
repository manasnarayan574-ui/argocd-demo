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
                        // 1. Set Git identity first so Git doesn't complain during pulls/merges
                        sh """
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        """

                        // 2. Clear out any local tracking conflicts, checkout main cleanly
                        sh "git checkout -B main"
                        
                        // 3. THE FIX: Tells Git exactly how to reconcile branches using fast-forward only
                        sh "git pull origin main --ff-only"

                        // 4. Update the image tag automatically
                        sh "sed -i 's|image: nginx:1.25|image: $IMAGE:$TAG|g' deployment.yaml"
                        
                        sh "git add deployment.yaml"
                        
                        // 5. Commit and push back using clean string concatenation
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
