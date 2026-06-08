pipeline {
    agent any

    environment {
        IMAGE = "manasnarayan/myapp"
    }

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/manasnarayan574-ui/argocd-demo.git'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    env.TAG = sh(script: "date +%s", returnStdout: true).trim()
                    sh "docker build -t $IMAGE:$TAG ."
                }
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'U', passwordVariable: 'P')]) {
                    sh """
                    echo \$P | docker login -u \$U --password-stdin
                    docker push $IMAGE:$TAG
                    """
                }
            }
        }

        stage('Update Deployment YAML') {
            steps {
                sh """
                sed -i 's|image: .*|image: $IMAGE:$TAG|g' deployment.yaml
                """
            }
        }

        stage('Update GitHub') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'U', passwordVariable: 'P')]) {
            sh """
            git config user.email "jenkins@example.com"
            git config user.name "jenkins"

            git add deployment.yaml
            git commit -m "update image" || echo "no changes"

            git remote set-url origin https://${U}:${P}@github.com/ManasNarayan574-UI/argocd-demo.git
            git push origin main
            """
        }
    }
}
