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
chmod +x build_and_push_ecr.sh && ./build_and_push_ecr.sh
echo "Moving back to Root Directory...."
cd ..
echo "Enabling ECS Service...."
sed -i '13s|default = false|default = true|' workflow.tf

echo "workflow.tf updated: line 13 is now:"
sed -n '13p' workflow.tf

echo "Terraform Reinitializing..."
terraform init 
echo "Terraform validating syntax....."
terraform validate
echo "Terraform planning build with ecr image...."
terraform plan
echo "Terraform building infrastructure...."
terraform apply -auto-approve
echo "One Final Terraform Apply to build db sg...."
terraform apply -auto-approve
echo "Done Building your INFRASTRUCTURE: YOU ARE WELCOME"