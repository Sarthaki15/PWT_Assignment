
pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
        AWS_ACCOUNT_ID = '170010887450'

        ECR_REPOSITORY = 'my-ecr-repo'
        ECR_URI = '170010887450.dkr.ecr.eu-north-1.amazonaws.com/my-ecr-repo'

        IMAGE_TAG = "${BUILD_NUMBER}"

        APP_CONTAINER = 'pwt-application'
        APP_PORT = '8080'
        CONTAINER_PORT = '3000'

        TEST_CONTAINER = 'pwt-test'
        TEST_PORT = '8080'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code from GitHub...'

                git branch: 'main',
                    url: 'https://github.com/Sarthaki15/PWT_Assignment.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'

                sh '''
                    docker build \
                        -t $ECR_URI:$IMAGE_TAG \
                        -t $ECR_URI:latest .
                '''
            }
        }

        stage('Test Docker Image') {
            steps {
                withCredentials([
                    file(credentialsId: 'APP_ENV_FILE', variable: 'ENV_FILE')
                ]) {
                    sh '''
                        docker rm -f $TEST_CONTAINER || true

                        docker run -d \
                            --name $TEST_CONTAINER \
                            --env-file "$ENV_FILE" \
                            -p $TEST_PORT:$CONTAINER_PORT \
                            $ECR_URI:$IMAGE_TAG

                        for i in $(seq 1 15); do
                            if curl -fsS http://localhost:$TEST_PORT/; then
                                echo "Application test successful"
                                exit 0
                            fi

                            sleep 2
                        done

                        echo "Application test failed"
                        docker logs $TEST_CONTAINER
                        exit 1
                    '''
                    sh '''
                    echo "Checking database configuration inside container..."
                    docker exec pwt-test node -e "
                    console.log('DB_HOST:', process.env.DB_HOST);
                    console.log('DB_PORT:', process.env.DB_PORT);
                    console.log('DB_USER present:', !!process.env.DB_USER);
                    console.log('DB_NAME present:', !!process.env.DB_NAME);"
                    '''
                    sh '''
                    docker exec pwt-test node -e "
                    console.log('DB_HOST:', process.env.DB_HOST);
                    console.log('DB_PORT:', process.env.DB_PORT);
                    console.log('DB_USER:', process.env.DB_USER);
                    console.log('DB_NAME:', process.env.DB_NAME);"
                    '''
                }
            }

            post {
                always {
                    sh 'docker rm -f pwt-test || true'
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                echo 'Authenticating with AWS ECR...'

                sh '''
                    aws ecr get-login-password \
                        --region $AWS_REGION | \
                    docker login \
                        --username AWS \
                        --password-stdin $ECR_URI
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                echo 'Pushing Docker image to ECR...'

                sh '''
                    docker push $ECR_URI:$IMAGE_TAG
                    docker push $ECR_URI:latest
                '''
            }
        }

        stage('Deploy Application') {
            steps {
                withCredentials([
                    file(credentialsId: 'APP_ENV_FILE', variable: 'ENV_FILE')
                ]) {
                    echo 'Deploying application on EC2...'

                    sh '''
                        docker pull $ECR_URI:$IMAGE_TAG

                        docker rm -f $APP_CONTAINER || true

                        docker run -d \
                            --name $APP_CONTAINER \
                            --restart unless-stopped \
                            --env-file "$ENV_FILE" \
                            -p $APP_PORT:$CONTAINER_PORT \
                            $ECR_URI:$IMAGE_TAG

                        sleep 5

                        docker ps --filter name=$APP_CONTAINER

                        curl -f http://localhost:$APP_PORT/
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'CI/CD Pipeline completed successfully!'
            echo 'Application deployed successfully on EC2.'
        }

        failure {
            echo 'CI/CD Pipeline failed. Check the stage logs.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}
