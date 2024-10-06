resource "aws_ecr_repository" "eric-ci-api" {
  name                 = "eric-ci"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration { #traz segurança - escaneia em busca de vunerabilidade
    scan_on_push = true
  }

  tags = {
    IAC = true
  }
}