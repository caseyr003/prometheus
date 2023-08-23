# Create url to prometheus dashboard
output "prometheus_url" {
  value = "http://${oci_core_instance.observer.public_ip}:9090/graph"
}
