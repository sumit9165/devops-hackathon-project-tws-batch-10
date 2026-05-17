#!/bin/bash
# AWS User Data for Docker, Docker Compose, Kubectl, and KinD on AL2023

# Redirect stdout and stderr to a log file for easy debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/null) 2>&1

echo "=== Starting Bootstrapping ==="

# 1. Update system and install Docker
dnf update -y
dnf install -y docker

# 2. Start and enable Docker service
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# CRITICAL: Wait for Docker socket to be completely ready before proceeding
echo "Waiting for Docker daemon to start..."
while ! docker info >/dev/null 2>&1; do
    sleep 2
done
echo "Docker is ready!"

# 3. Install Docker Compose plugin globally
mkdir -p /usr/libexec/docker/cli-plugins/
ARCH=$(uname -m)
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-${ARCH}" -o /usr/libexec/docker/cli-plugins/docker-compose
chmod +x /usr/libexec/docker/cli-plugins/docker-compose

# 4. Install kubectl globally
K8S_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# 5. Install KinD (Kubernetes in Docker) globally
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

