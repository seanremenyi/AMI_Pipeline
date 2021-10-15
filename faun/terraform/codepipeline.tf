resource "aws_codepipeline" "amibuild_codepipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.amibuild_codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["amibuild_artifacts"]

      configuration = {
        Owner      = var.github_owner
        Repo       = data.github_repository.myrepo.name
        Branch     = "main"
        OAuthToken = var.github_Oauthtoken
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["amibuild_artifacts"]
      output_artifacts = ["amibuild_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.amibuid_codebuild.name
      }
    }
  }
}