import boto3
import pymysql
import os
import logging

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def read_s3_and_push_to_rds():
    rds_connection = None  # Initialize the connection variable
    try:
        # Initialize S3 client
        s3_client = boto3.client('s3')
        bucket_name = os.getenv('S3_BUCKET_NAME')
        file_key = os.getenv('S3_FILE_KEY')
        
        # Read data from S3
        s3_object = s3_client.get_object(Bucket=bucket_name, Key=file_key)
        data = s3_object['Body'].read().decode('utf-8')
        logger.info(f"Successfully read {file_key} from S3.")
        
        # Connect to RDS Database
        rds_connection = pymysql.connect(
            host=os.getenv('RDS_HOST'),
            user=os.getenv('RDS_USER'),
            password=os.getenv('RDS_PASSWORD'),
            database=os.getenv('RDS_DATABASE')
        )
        logger.info(f"Successfully connected to RDS at {os.getenv('RDS_HOST')}.")

        with rds_connection.cursor() as cursor:
            # Create table if it doesn't exist
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS car (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    column1 VARCHAR(255),
                    column2 VARCHAR(255)
                )
            """)
            logger.info("Table checked/created in RDS.")
            
            # Insert data into RDS
            insert_query = "INSERT INTO car (column1, column2) VALUES (%s, %s)"
            for line in data.splitlines():
                try:
                    column1, column2 = line.split(',')
                    cursor.execute(insert_query, (column1, column2))
                except Exception as e:
                    logger.error(f"Error inserting line: {line}, Error: {str(e)}")
                    continue  # Skip problematic rows
            
        rds_connection.commit()
        logger.info("Data successfully inserted into RDS.")
    except Exception as e:
        logger.error(f"Error in read_s3_and_push_to_rds: {str(e)}")
    finally:
        if rds_connection:
            rds_connection.close()
            logger.info("RDS connection closed.")

def lambda_handler(event, context):
    try:
        read_s3_and_push_to_rds()
    except Exception as e:
        logger.error(f"Lambda Handler error: {str(e)}")

