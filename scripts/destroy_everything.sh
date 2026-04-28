cd ..

terraform init

terraform validate


terraform destroy -auto-approve

echo "Disabling ECS Service...."
sed -i '13s|default = true|default = false|' workflow.tf

echo "workflow.tf updated: line 13 is now:"
sed -n '13p' workflow.tf
echo "Done."