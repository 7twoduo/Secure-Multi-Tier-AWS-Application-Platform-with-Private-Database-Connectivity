echo "Moving to Root Directory"
cd ..
echo "Terraform initializing...."
terraform init
echo "Terraform Validating...."
terraform validate
echo "Terraform plan..."
terraform plan
echo "Terraform building infrastructure..."
terraform apply -auto-approve
echo "Moving to scripts...."
cd scripts
echo "Building and uploading docker image to ecr ..."
chmod +x build_web_server.sh && bash ./build_web_server.sh
echo "Moving back to Root Directory...."
cd ..
echo "Terraform Reinitializing..."
terraform init 
echo "Terraform validating syntax....."
terraform validate
echo "Terraform planning build with ecr image...."
terraform plan
echo "Terraform building infrastructure...."
terraform apply -auto-approve
echo "Done Building your INFRASTRUCTURE: YOU ARE WELCOME"