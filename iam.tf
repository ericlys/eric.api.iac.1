resource "aws_iam_openid_connect_provider" "oidc-git" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    IAC = "True"
  }
}

# role para poder subir o terraform
resource "aws_iam_role" "tf-role" {
  name = "tf-role"

  assume_role_policy = jsonencode({
    Statement : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRoleWithWebIdentity",
        Principal : {
          Federated : "arn:aws:iam::217127483231:oidc-provider/token.actions.githubusercontent.com"
        },
        Condition : {
          StringEquals : {
            "token.actions.githubusercontent.com:aud" : [
              "sts.amazonaws.com"
            ],
            "token.actions.githubusercontent.com:sub" : [
              "repo:ericlys/eric.api.iac.1:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
    Version : "2012-10-17",
  })

  tags = {
    IAC = "True"
  }
}

# add role policy para poder subir o terraform
resource "aws_iam_role_policy" "tf_policy" {
  name = "tf_policy"
  role = aws_iam_role.tf-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "Statement1",
        Action   = "ecr:*",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid      = "Statement2",
        Action   = "iam:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# role para poder fazer a build pelo app runner
resource "aws_iam_role" "app-runner-role" {
  name = "app-runner-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "build.apprunner.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  tags = {
    IAC = "True"
  }
}

# role para subir imagens no ecr
resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    Statement : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRoleWithWebIdentity",
        Principal : {
          Federated : "arn:aws:iam::217127483231:oidc-provider/token.actions.githubusercontent.com"
        },
        Condition : {
          StringEquals : {
            "token.actions.githubusercontent.com:aud" : [
              "sts.amazonaws.com"
            ],
            "token.actions.githubusercontent.com:sub" : [
              "repo:ericlys/eric.ci.api:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
    Version : "2012-10-17",
  })

  #   inline_policy {
  #     name = "ecr_app_permission"

  #     policy = jsonencode({
  #       Version = "2012-10-17"
  #       Statement = [
  #       {
  #         Sid = "Statement1"
  #         Action: [
  #           "ecr:GetDownloadUrlForLayer",
  #           "ecr:BatchGetImage",
  #           "ecr:BatchCheckLayerAvailability",
  #           "ecr:PutImage",
  #           "ecr:InitiateLayerUpload",
  #           "ecr:UploadLayerPart",
  #           "ecr:CompleteLayerUpload",
  #           "ecr:GetAuthorizationToken",
  #         ],
  #         Effect: "Allow",
  #         Resource: "*"
  #       }
  #     ]
  #   })
  # }

  tags = {
    IAC = true
  }
}

resource "aws_iam_role_policy" "ecr_app_policy" {
  name = "ecr_app_permission"
  role = aws_iam_role.ecr-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "Statement1",
        Action   = "apprunner:*",
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "Statement2",
        Action = [
          "iam:PassRole",
          "iam:CreateServiceLinkedRole"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "Statement3"
        Action : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
        ],
        Effect : "Allow",
        Resource : "*"
      }
    ]
  })
}