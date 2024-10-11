resource "aws_s3_bucket" "s3-test" {
  bucket        = "test-pipeline-iac"

  tags = {
    IAC = "True"
  }
}
