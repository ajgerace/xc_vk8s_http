# xc_vk8s_http
This repository uses HashiCorp's Terraform to deploy an application on to F5 Distributed Cloud's Regional Edges using a HTTP load balancer and optionally an App Firewall. 

##  Requirements:
* Terraform v0.12+
* Volterra Provider currently v0.11.20

## Creating a Distributed Cloud API Credential P12 file
* Click on Administration 
* Click Credentials under Personal Management 
* Click Add Credentials
    * Enter a name for your credentials
    * Select API Certificate under Credential Type
    * Enter a password
    * Select an expiration date (maximum of 90 days)
    * Click Download

## Setting up Volterra provider
* Create the following environment variables 
    * VOLT_API_P12_FILE - This provides path to the Credential P12 file you just created
    * VOLT_API_URL - The URL to the Distributed Cloud API 
    * VES_P12_PASSWORD - The password of the P12 file
 
````bash
    export VOLT_API_URL='https://<your-tenant-name>.console.ves.volterra.io/api'
    export VOLT_API_P12_FILE='/home/ubuntu/myp12file.p12'
    export VES_P12_PASSWORD='password'
````
## Setup a virtual K8S cluster on XC and download k8s config file.


