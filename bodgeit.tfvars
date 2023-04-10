
appName = "bodgeit" 
appPort = 8080 
domainName = "cloud.myf5demo.com"
imageName = "ajgerace/bodgeit:4.0"
imagePullSecretName = "agerace-registry"
replicaCount = 1
xcDisableWaf = false
xcSiteName  = "dc12-ash"
xcNamespace = "a-gerace" 
xcTenant = "f5-amer-ent-qyyfhhfj"
xcWafPolicy = "star-ratings-fw"
xcWorkloadFlavor = "ves-io-tiny" 
healthcheckPath = "/bodgeit/home.jsp"
healthy_threshold = 3
unhealthy_threshold = 2
interval = 15
timeout = 3
