# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE FRONTEND MICROSERVICE
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE S3 AS A BACKEND
# Note that this has been commented out because Terraform does not allow interpolations in the backend configuration,
# but the S3 bucket name needs to be globally unique, so you have to uncomment the code below and specify it by hand.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    region         = "eu-central-1"
    bucket         = "this-is-our-bucket-name-mateipopa"
    key            = "exercise-06-mateipopa/stage/frontend/terraform.tfstate" // Add env:/mateipopa/ when asked for the key var!
    encrypt        = true
    dynamodb_table = "terraform-locks-example-mateipopa"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE FRONTEND
# ---------------------------------------------------------------------------------------------------------------------

module "frontend" {
  source = "../../../modules/microservice"

  name                  = "frontend-stage"
  size                  = 2
  key_name              = var.key_name
  user_data_script_name = "user-data-frontend.sh"
  server_text           = var.frontend_server_text
  is_internal_alb       = 0
  is_internal_alb_bool  = false

  # Pass an output from the backend remote state to the frontend module. This is the URL of the backend microservice,
  # which the frontend will use for "service calls"
  backend_url = data.terraform_remote_state.backend.outputs.url
}

# ---------------------------------------------------------------------------------------------------------------------
# FETCH THE BACKEND DATA FROM S3
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "backend" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.backend_remote_state_s3_bucket
    key    = var.backend_remote_state_s3_key
  }
}
