## Requirements:
"Use any language to setup a Wordpress & monitoring server. We are looking for a functional script." 

## Result

##### See [wp.papezt.com](https://wp.papezt.com)

## Implementation:

First of all I was surprised with "functional script" then I was thinking about some booring ansible but after that I decieded go with Cloud not only VM.
As you maybe know I like Google and K8s then you can guess what I used. In screenshots you can see some components I used to proof it's really working.

### Wordpress:
It's just official Docker image from Docker hub.
As a DB I used Mysql5.7 managed by Google.
Communication is trough private network without SSL.

I had fun and bought domain and generated Let's encrypt certificates. First of all I wanted to use GLB but it's 
nonsense for this case, second idea was Nginx ingress and controller - too complicated for small app then I ended up 
with a bit customised Nginx with custom probe because otherwise it will go to backend and this can cause a lot of problems.
For communication with WP is used DNS from K8s and internal network.

### Platform:
Whole infrastructure is writed as a code in Terraform.
To keep everything UP I used Kubernetes + managed database. As Nginx is only proxy I don't expect huge load then I created
HPA only for WP ant it scales based on CPU and MEM.

### Monitoring:
For monitoring is used build in Stackdriver it automatically collects logs and metrics from containers. I created few examples
of triggers just basic uptime check for whole page, CPU and Memory for WP and simple UP check for DB.
Uptime shows only 55% UP it's because I fixed it and recreated and it takes time to get to normal. 

## How to build your own stack:

#### Init:

- enable all necessary API's - I used tool from my colleague https://github.com/kiwicom/gcp-api-enabler
- add permission to BUILD user in IAM
- I used community builder for terraform - https://github.com/GoogleCloudPlatform/cloud-builders-community
- crate GCS for Terraform state
- connect GitHub with Cloud Build or `gcloud builds submit --config cloudbuild.yaml .`
- After creation of LB put his IP into DNS and Nginx service (DNS can be skipped)

#### Issues: 
- manual things, domain can be for example in Route53 managed by TF, same for certificates
- terraform - can be parametrized more, use parameters for templating manifests etc.
- terraform in cloud build is not that good as it looks some resources are creating long time and it have hard limit 5min :(
- switch Nginx proxy to Ingress
- not sure about beahving of PVC and WP with multiple instances
- tune HPA and limits
- tune probes
- definitely tune montiring and alerting
- tune log collecting, create log based metrics and define SRE metrics
- create tests
- K8s deploy is not aligned with best practices, use better tooling for deploy and versioning etc. 
- backups
- set infra to PROD mode - enable HA, don't use defaults
- naming + folder structure etc.
- secure environment and variable handling
- secure app - CORS, WAF, etc. 
- ...


