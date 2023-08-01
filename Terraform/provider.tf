provider "aws" {
  region = "us-east-1"
}

provider "helm" {
  kubernetes {
    config_path = "/home/mmansour/.kube/config"
    host                   = data.aws_eks_cluster.my_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.my_cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.my_cluster.token
  }
}
