resource "aws_codebuild_project" "amibuid_codebuild" {
  name          = "amibuid_codebuild"
  description   = "AMI Build Codebuild pipeline"
  build_timeout = "15"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.codebuild_log.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name  = "AMIID_SSMPS"
      value = var.ami_id_ssmps
    }
    environment_variable {
      name  = "SNS_ARN"
      value = aws_sns_topic.amibuild_notification.arn
    }
    environment_variable {
      name  = "BASE_AMI"
      value = var.base_ami_id
    }
    
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "amibuild_log-group"
      stream_name = "amibuild_log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codebuild_log.id}/build-log"
    }
  }

  source {
    type            = "CODEPIPELINE"
  }

  source_version = "master"

}