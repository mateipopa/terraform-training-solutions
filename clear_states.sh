find . -type d -or -type f -name "terraform.tfstate*" -prune -exec rm -rf {} \;
