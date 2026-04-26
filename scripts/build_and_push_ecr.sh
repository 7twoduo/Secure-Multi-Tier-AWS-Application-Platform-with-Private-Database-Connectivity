#!/bin/bash
###                                                     MY MARVELOUS AND BEAUTIFUL SCRIPT
##########################  THIS SCRIPT IS OPTIMIZED OF WINDOWS BASH, FOR ALL OTHER SYSTEMS. JUST TURN ON DOCKER BEFORE RUNNING.
ECR_REPOSITORY_NAME="multi-vpc-peering-app" ## Put YOUR Ecr NAME HERE
IMAGE_TAG="v1" # PUT YOUR IMAGE TAG HERE
APP_DIR="./app" # PUT THE PATH TO YOUR APP FOLDER HERE
LOCAL_IMAGE_NAME="cool-stuff" # PUT THE IMAGE NAME FOR THE INSTANCE
AWS_REGION="us-east-1"

cd .. && echo "Current directory: $(pwd)" # Moves to the root directory

sudo systemctl start docker
# Checks if Docker is running
if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Starting Docker Desktop..."
  "/c/Program Files/Docker/Docker/Docker Desktop.exe" &
  sleep 60
else
  echo "Docker is already running."
fi
# Builds the local image
docker build -t "$LOCAL_IMAGE_NAME:$IMAGE_TAG" "$APP_DIR"
# Gets the AWS account ID and creates the ECR registry URI
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_IMAGE_URI="${ECR_REGISTRY}/${ECR_REPOSITORY_NAME}:${IMAGE_TAG}"
# Logs into the ECR repository
echo "Logging into ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"
# Tags the local image with the ECR repository URI
echo "Tagging image..."
docker tag "${LOCAL_IMAGE_NAME}:${IMAGE_TAG}" "$ECR_IMAGE_URI"
# Pushes the image to the ECR repository
echo "Pushing image to ECR..."
docker push "$ECR_IMAGE_URI"
# Prints the ECR image URI
echo "Pushed image:"
echo "$ECR_IMAGE_URI"