# PWT Assignment – AWS CI/CD & Containerized Deployment

Task Tracker (Node.js + Express + MySQL) containerized with Docker, infrastructure provisioned with Terraform, and deployed on EC2 through a Jenkins pipeline that pushes images to Amazon ECR.

**Region:** `eu-north-1`

## Deployment Steps

### 1. Provision infrastructure with Terraform

Install Terraform (Ubuntu/Debian):

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl unzip
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
terraform -version
```

Install the AWS CLI and configure credentials:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
aws configure
```

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

SSH into the instance:

```bash
ssh -i <key>.pem ubuntu@<EC2_PUBLIC_IP>
```

**Install Docker**

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker ubuntu
docker --version
```

**Install AWS CLI**

```bash
sudo apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

**Install Jenkins**

```bash
sudo apt-get install -y fontconfig openjdk-21-jre-headless
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y jenkins
```

Run Jenkins on port `8081` (port `8080` is used by the application):

```bash
sudo mkdir -p /etc/systemd/system/jenkins.service.d
printf '[Service]\nEnvironment="JENKINS_PORT=8081"\n' | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
sudo systemctl daemon-reload
```

Give Jenkins access to Docker and start it:

```bash
sudo usermod -aG docker jenkins
sudo systemctl enable jenkins
sudo systemctl restart jenkins
sudo systemctl status jenkins
```

Get the initial admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Allow inbound ports `8080` (application) and `8081` (Jenkins) in the security group. The instance also needs permission to push to ECR (IAM role attached to the instance, or `aws configure` for the `jenkins` user).

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
