locals {
  image_tag = var.auto_deploy_latest ? "latest" : var.api_image_tag

  # Base environment variables for .NET API
  base_env_vars = [
    { name = "ASPNETCORE_ENVIRONMENT", value = var.environment },
    { name = "ASPNETCORE_URLS", value = "http://0.0.0.0:${var.service_definitions.api.port}" },
    { name = "MongoDB__ConnectionString", value = "mongodb://${aws_docdb_cluster.main.endpoint}:${aws_docdb_cluster.main.port}/?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false" },
  ]

  # OTEL environment variables for .NET API using Service Connect
  otel_env_vars = [
    { name = "Serilog__WriteTo__1__Args__Endpoint", value = "http://${var.service_definitions.otel_http.discovery_name}:${var.service_definitions.otel_http.port}" },
    { name = "Serilog__WriteTo__1__Args__ResourceAttributes__deployment.environment", value = var.environment },
    { name = "Serilog__WriteTo__1__Args__ResourceAttributes__service.version", value = local.image_tag },
    { name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = "http://${var.service_definitions.otel_http.discovery_name}:${var.service_definitions.otel_http.port}" },
    { name = "OTEL_RESOURCE_ATTRIBUTES", value = "service.name=SmartBin.Api,service.version=${local.image_tag},deployment.environment=${var.environment}" }
  ]

  # Combined environment variables
  api_env_vars = concat(local.base_env_vars, local.otel_env_vars)
}