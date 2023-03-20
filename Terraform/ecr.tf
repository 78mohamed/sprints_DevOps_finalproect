resource "aws_ecr_repository" "my_ecr" {
  name                 = "my_ecr"
  image_tag_mutability = "IMMUTABLE"
  force_delete = true
}


data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "new policy"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
  }
}

resource "aws_ecr_repository_policy" "my_ecr_policy" {
  repository = aws_ecr_repository.my_ecr.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}
