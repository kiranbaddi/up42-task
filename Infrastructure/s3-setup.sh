#!/bin/bash

# Create an S3 bucket with versioning enabled

BUCKET_NAME="up24-task-${echo $RANDOM | tr -dc 'a-z0-9' | head -c 3}"
aws s3api create-bucket --bucket $BUCKET_NAME --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
echo "S3 bucket created: $BUCKET_NAME with versioning enabled."

Create a bucket policy to allow public read access

cat > bucket-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowGetObject",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*",
            "Principal": { "AWS": "arn:aws:iam::654654584835:user/kiran" }
        },
        {
            "Sid": "AllowListBucket",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::$BUCKET_NAME",
            "Principal": { "AWS": "arn:aws:iam::654654584835:user/kiran" }
        }
    ]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json