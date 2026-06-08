pipeline {
    agent any

    // Notice: There is NO environment block here anymore!
    // This completely removes the "12345 / Bad hostname" bug.

    stages {
        stage('Checkout Code') {
            steps {
                // Pulls your repository code cleanly using SCM
                git url: 'https://github.com/manasnarayan574-ui/argocd-demo.git', branch: 'main'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                // Builds your local Dockerfile using the build number as a tag
                sh "docker build -t nginx:v${BUILD_NUMBER} ."
            }
        }

        stage('Update Git Deployment Tag') {
            steps {
                // This block safely grabs your token from Jenkins Credentials by its ID
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    script {
                        echo "Modifying deployment.yaml with tag v${BUILD_NUMBER}..."
                        // Inline search and replace for line 17 of deployment.yaml
                        sh "sed -i 's|image: nginx:.*|image: nginx:v${BUILD_NUMBER}|g' deployment.yaml"
                        
                        echo "Configuring local git user identity..."
                        sh """
                            git config user.email "jenkins@yourdomain.com"
                            git config user.name "Jenkins CI"
                        """
                        
                        echo "Committing changes..."
                        sh """
                            git add deployment.yaml
                            git commit -m "chore: automated image tag update to v${BUILD_NUMBER} [skip ci]"
                        """
                        
                        echo "Pushing changes back to GitHub repository..."
                        // Using the variables right here ensures standard, clean HTTPS authentication
                        sh "git push https://${GIT_
