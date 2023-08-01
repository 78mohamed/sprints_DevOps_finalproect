data "aws_eks_cluster" "my_cluster" {
  name = aws_eks_cluster.my_cluster.name
}


data "aws_eks_cluster_auth" "my_cluster" {
  name = aws_eks_cluster.my_cluster.name
}


resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace  = "ingress-nginx"
  create_namespace = true


}














