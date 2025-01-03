provider "aws" {
  region = "us-east-1"
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
  source = "./task/sample_data.csv" # Path to your local file
  acl    = "public-read"
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

# Create an IAM role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "mal-lambda-exec-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


# Lambda function configuration

resource "aws_lambda_function" "example" {
  function_name = "s3-to-rds"
  image_uri     = "253490791461.dkr.ecr.us-east-1.amazonaws.com/task:latest"
  role          =  aws_iam_role.lambda_exec.arn
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

