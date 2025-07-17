resource "aws_instance" "bitcoin_ingestor" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    iam_instance_profile = var.instance_profile_name
    subnet_id = var.subnet_id
}