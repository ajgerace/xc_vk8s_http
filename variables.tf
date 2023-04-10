
variable "appName" {
    description     = "A string containing the application name"
    type            = string
}

variable "appPort" {
    description     = "Port number used by container and origin pool k8s service"
    type            = number
}

variable "domainName" {
     description    = "A string containing the domain that which the application record will be placed in"
     type           = string
}

variable "healthcheckPath" {
    description = "A string containing the path used to check health status of the origin pool"
    type = string  
}

variable "healthy_threshold" {
    description = "A number representing the number of successful responses to determine an enpoint is healthy"
    type = number
}

variable "imageName" {
    description     = "application constainer image name, example 'repo/images:tag'"
    type            = string
}

variable "imagePullSecretName" {
    description     = "A string containing the name of the F5 XC Secret for image repo" 
    type            = string
}

variable "interval" {
    description = "A number representing how frequently (seconds) healthcheck is run "
}

variable "replicaCount" {
    type =  number
}

variable "timeout" {
    type = number
}

variable "unhealthy_threshold" {
    type = number
}

variable "xcDisableWaf" {
    type = bool 
  
}
variable "xcNamespace" {
    description     = "A string containing the namespace in the F5 Distributed Cloud Environment"
    type            = string
}

variable "xcSiteName" {
    description = "A string containging te F5XC site name where to deploy the application"
    type = string
}

variable "xcTenant" {
    type = string
}

variable "xcWafPolicy" {
    type = string
  
}
variable "xcWorkloadFlavor" {
    type = string 
    default = "ves-io-tiny"
}


