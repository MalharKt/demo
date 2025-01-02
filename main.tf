provider "aws" {
  region = "us-east-1"
}


variable "ecr_image_uri" {
  description = "The URI of the Docker image in ECR"
  type        = string
}


# Create an S3 bucket
resource "aws_s3_bucket" "bucket_1" {
  bucket = "autom-bucket-25"


  tags = {
    Name        = "autom-bucket-25"
  }
}


# Upload file to S3 bucket
resource "aws_s3_object" "uploaded_file" {
  bucket = aws_s3_bucket.bucket_1.id
  key    = "sample_data.csv" # The object key in the bucket
  source = "/home/ubuntu/task/sample_data.csv" # Path to your local file
  acl    = "private"
}

# Create an RDS instance
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.39"  # Using a supported MySQL version
  instance_class       = "db.t3.micro"  # Changed to db.t3.micro
  db_name              = "autom_db"  # Use 'db_name' instead of 'name'
  username             = "malhar"
  password             = "malhar123"
  skip_final_snapshot  = true
  multi_az             = false
  publicly_accessible  = true
}


# Lambda function configuration

resource "aws_lambda_function" "example" {
  function_name = "s3-to-rds"
  image_uri     = var.ecr_image_uri
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/lambda-exec-role" # Existing role ARN
  timeout       = 20
  package_type  = "Image"

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.bucket_1.bucket
      S3_FILE_KEY    = "sample_data.csv"
      RDS_HOST       = aws_db_instance.example.endpoint
      RDS_USER       = "malhar"
      RDS_PASSWORD   = "malhar123"
      RDS_DATABASE   = "autom_db"
    }
  }
}

