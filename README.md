# PWT Assignment – AWS CI/CD & Containerized Deployment

Task Tracker (Node.js + Express + MySQL) containerized with Docker, infrastructure provisioned with Terraform, and deployed on EC2 through a Jenkins pipeline that pushes images to Amazon ECR.

**Region:** `eu-north-1`

## Deployment Steps

### 1. Provision infrastructure with Terraform

Creates the VPC, public subnet, Internet Gateway, route table, security group, ECR repository and EC2 instance.

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

**VPC**

![VPC details](screenshots/vpc-details.png)

![VPC resource map](screenshots/vpc-resource-map.png)

**ECR repository**

![ECR repository](screenshots/ecr-repository.png)

### 2. Create the RDS MySQL database

Create an RDS MySQL instance in the same VPC with database name `task_tracker`. Allow inbound port `3306` from the EC2 instance's security group.

### 3. Prepare the EC2 instance

SSH into the instance and install Docker, Jenkins, AWS CLI and Git. Allow inbound ports `8080` (application) and `8081` (Jenkins) in the security group.

```bash
ssh -i <key>.pem ubuntu@<EC2_PUBLIC_IP>
```

Give the Jenkins user access to Docker and attach an IAM role (or configure credentials) that lets the instance push to ECR:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### 4. Create the environment file

Copy `.env.example` to `.env` and fill in the RDS details:

```env
DB_HOST=<your-rds-endpoint>.rds.amazonaws.com
DB_PORT=3306
DB_USER=admin
DB_PASSWORD=<password>
DB_NAME=task_tracker
PORT=3000
```

Verify Docker can reach RDS:

```bash
docker run --rm node:22-alpine node -e "
const net = require('net');
const s = net.connect(3306, '<your-rds-endpoint>');
s.setTimeout(5000);
s.on('connect', () => { console.log('RDS reachable from Docker'); s.end(); });
s.on('timeout', () => { console.log('RDS connection timed out'); s.destroy(); process.exit(1); });
s.on('error', e => { console.log('RDS connection error:', e.message); process.exit(1); });
"
```

### 5. Configure Jenkins

1. Open Jenkins at `http://<EC2_PUBLIC_IP>:8081`.
2. Go to **Manage Jenkins → Credentials → System → Global** and add a **Secret file** credential with ID `APP_ENV_FILE`, uploading the `.env` file from step 4.

![Jenkins credential](screenshots/jenkins-credential.png)

3. Create a **Pipeline** job named `app` using the `Jenkinsfile` from this repository (`https://github.com/Sarthaki15/PWT_Assignment.git`, branch `main`).

![Jenkins job](screenshots/jenkins-job.png)

### 6. Run the pipeline

Click **Build Now** (or push to `main`). The pipeline runs these stages:

1. **Checkout** – pulls the code from GitHub
2. **Build Docker Image** – multi-stage build, runs as non-root `node` user
3. **Test Docker Image** – starts a test container with the `.env` file and checks `http://localhost:8080/`
4. **Login to AWS ECR**
5. **Push Image to ECR** – pushes `<build-number>` and `latest` tags
6. **Deploy Application** – pulls the image and runs the container on EC2 at port `8080`

![Jenkins pipeline](screenshots/jenkins-pipeline.png)

**Image pushed to ECR**

![ECR images](screenshots/ecr-images.png)

### 7. Access the application

```
http://<EC2_PUBLIC_IP>:8080
```

![Application](screenshots/application.png)

## Cleanup

```bash
# Stop the application container
docker rm -f pwt-application

# Delete images from ECR (required before destroying the repository)
aws ecr batch-delete-image --repository-name my-ecr-repo --region eu-north-1 \
  --image-ids "$(aws ecr list-images --repository-name my-ecr-repo --region eu-north-1 --query 'imageIds[*]' --output json)"

# Destroy Terraform-managed resources
cd terraform
terraform destroy
```

Delete the RDS instance manually from the AWS console.
