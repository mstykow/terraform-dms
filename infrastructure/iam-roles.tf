#==============================================================
# IAM Roles to Use With AWS CLI and AWS DMS API / iam-roles.tf
#==============================================================

# If you use the AWS CLI or the AWS DMS API for your database migration, you must add
# three IAM roles to your AWS account before you can use the features of AWS DMS. Two of
# these are dms-vpc-role and dms-cloudwatch-logs-role. If you use Amazon Redshift as a
# target database, you must also add the IAM role dms-access-for-endpoint to your AWS
# account.

#--------------------------------------------------------------
# dms-vpc-role
#--------------------------------------------------------------

# Use AWS CLI to attach policy to role after creating the resources:
# aws iam attach-role-policy --role-name dms-vpc-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole

resource "aws_iam_role" "dmsvpcrole" {
  name = "dms-vpc-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "dms.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags {
    Name        = "${var.stack_name}_dms"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

# See https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.IAMPermissions.html
# and https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Target.S3.html#CHAP_Target.S3.Prerequisites
# for permission breakdown.
resource "aws_iam_role_policy" "dmsvpcpolicy" {
  name = "dmsvpcpolicy"
  role = "${aws_iam_role.dmsvpcrole.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "dms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:ListAliases", 
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole",
                "iam:CreateRole",
                "iam:AttachRolePolicy"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:Get*",
                "cloudwatch:List*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:FilterLogEvents",
                "logs:GetLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "redshift:Describe*",
                "redshift:ModifyClusterIamRoles"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:PutObjectTagging"
            ],
            "Resource": [
                "arn:aws:s3:::${var.target_bucket}*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.target_bucket}*"
            ]
        }
    ]
} 
EOF
}

#--------------------------------------------------------------
# dms-cloudwatch-logs-role
#--------------------------------------------------------------

# Use AWS CLI to attach policy to role after creating the resources:
# aws iam attach-role-policy --role-name dms-cloudwatch-logs-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole

resource "aws_iam_role" "dmscloudwatchlogsrole" {
  name = "dms-cloudwatch-logs-role"
  path = "/"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
   {
     "Effect": "Allow",
     "Principal": {
        "Service": "dms.amazonaws.com"
     },
   "Action": "sts:AssumeRole"
   }
 ]
}
EOF

  tags {
    Name        = "${var.stack_name}_dms"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

resource "aws_iam_role_policy" "dmscloudwatchlogspolicy" {
  name = "dmscloudwatchlogspolicy"
  role = "${aws_iam_role.dmscloudwatchlogsrole.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowDescribeOnAllLogGroups",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "AllowDescribeOfAllLogStreamsOnDmsTasksLogGroup",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:dms-tasks-*"
            ]
        },
        {
            "Sid": "AllowCreationOfDmsTasksLogGroups",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:dms-tasks-*"
            ]
        },
        {
            "Sid": "AllowCreationOfDmsTaskLogStream",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:dms-tasks-*:log-stream:dms-task-*"
            ]
        },
        {
            "Sid": "AllowUploadOfLogEventsToDmsTaskLogStream",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:dms-tasks-*:log-stream:dms-task-*"
            ]
        }
    ]
}
EOF
}

/*
#--------------------------------------------------------------
# dms-access-for-endpoint (only needed for Redshift target)
#--------------------------------------------------------------

# Use AWS CLI to attach policy to role after creating the resources:
# aws iam attach-role-policy --role-name dms-access-for-endpoint --policy-arn arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role

resource "aws_iam_role" "dmscloudwatchlogsrole" {
  name = "dms-cloudwatch-logs-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": {
        "Service": "dms.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "2",
      "Effect": "Allow",
      "Principal": {
        "Service": "redshift.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags {
    Name        = "${var.stack_name}_dms"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}
*/

