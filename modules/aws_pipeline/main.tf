

#---------- CREATED IAM role for CodeBuild----------
resource "aws_iam_role" "codebuildrole" {
  name = "codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuildpolicy" {
  role = aws_iam_role.codebuildrole.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*",
                "cloudtrail:LookupEvents",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "replication.ecr.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
POLICY
}

########## IAM Policy attechment for CodeBuild ###################

resource "aws_iam_role_policy_attachment" "for-codebuil" {
  role       = aws_iam_role.codebuildrole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}



########## Call "region_ID" and "account_ID" ##############

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region_id = data.aws_region.current.id
}


data "aws_codecommit_repository" "test" {
  repository_name = "ecs-ha-repo"
}

#------------CREATED PROJECT IN CODEBUILD-----------
resource "aws_codebuild_project" "example" {
  name          = "test-project"
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuildrole.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode		= true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value =  local.region_id
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = "${data.aws_codecommit_repository.test.clone_url_http}"
    
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }
}

#--------- CREATED S3 FOR PIPELINE------------


resource "aws_s3_bucket" "s3-pipeline" {
  bucket = "ecs-codepipeline-test"

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}

#-----------Pipeline for first service--------------

resource "aws_codepipeline" "codepipeline" {
  name     = "pipeline-for-service1"
  role_arn = aws_iam_role.codepipeline_role.arn
  
  artifact_store {
    location = aws_s3_bucket.s3-pipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "ecs-ha-repo"
        BranchName     = "master"
        
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
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.example.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
          ClusterName = "${var.clustername}"
          ServiceName = "${var.servicename1}"
      }
    }
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}

########### Pipeline for second service ################

resource "aws_codepipeline" "codepipeline2" {
  name     = "pipeline-for-service2"
  role_arn = aws_iam_role.codepipeline_role.arn
  
  artifact_store {
    location = aws_s3_bucket.s3-pipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "ecs-ha-repo"
        BranchName     = "master"
        
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
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.example.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
          ClusterName = "${var.clustername}"
          ServiceName = "${var.servicename2}"
      }
    }
  }

  tags = {
    Owner = "${var.owner_name}"
    Name  = "${var.tag_name}"
  }

}


#----------- CREATED IAM ROLE FOR PIPELINE----------

resource "aws_iam_role" "codepipeline_role" {
  name = "test-role-farid"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

########## IAM Role policy attechments ###################

resource "aws_iam_role_policy_attachment" "for-codepipeline" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

resource "aws_iam_role_policy_attachment" "for-codepipeline1" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "for-codepipeline2" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "for-codepipeline3" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}
