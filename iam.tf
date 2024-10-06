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

  tags = {
    IAC = true
  }
}