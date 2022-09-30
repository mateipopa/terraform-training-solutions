find . -type d \( -name "terraform.tfstate*" -o -name ".terraform" \) -prune -exec rm -rf {} \;
