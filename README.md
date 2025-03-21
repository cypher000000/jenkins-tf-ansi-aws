# Jenkins pipeline with terraform, ansible and aws

Simple jenkins pipeline with terraform, ansible, docker and aws

## Project

Create a pipeline in Jenkins that create "build" EC2 instance, then build a docker image with an application and push it to the dockerhub registry, then create "prod" EC2 instance, pull image with the application from the dockerhub and launch container.

## How it works

0. Jenkins starts pipeline, сheckout source code and extract the commit hash for tagging docker image
1. Terraform in AWS deploys security group, ssh key and the EC2 ubuntu "build" instance according to a given configuration and variables, outputs public ip of created ec2 instance, tf state saved in S3
2. Inside ec2 "build" Ansible deploys docker, downloads the Dockerfile, builds the docker container with the assembled war artifact, tags the container with version number from commit hash and pushes the container to dockerhub 
3. Terraform in AWS deploys security group, ssh key and the EC2 ubuntu "prod" instance according to a given configuration and variables, outputs public ip of created ec2 instance, tf state saved in S3
4. Inside ec2 "prod" Ansible deploys docker, pulls and runs the container with tag = version number from commit hash
5. Jenkins do testing by curilng the status codes from the app
6. You can check the app by ip_prod:8080/demo/Hello but only from ip where jenkins pipeline was initiated. (You can add different cidr_ipv4 by another resource aws_vpc_security_group_ingress_rule in prod/terraform.tf)
7. If "terraform destroy" parameter activated in jenkins pipeline, terrafrom will destroy both EC2 instances, linked security groups and ssh keys

## Versions

- Jenkins 2.492.2
- OpenJDK 17.0.14
- Terraform 1.10.4
- Ansible 2.17.4
- Git 2.34.1
- curl 7.81
- all installed on Ubuntu 22.04
  
## How to make this work

1. On your VM/PC/etc:

- Install git, curl, jenkins and jdk, configure jenkins
- Install jenkins modules for terraform, ansible, git, aws credentials
- Register on dockerhub and create a repository (if you doesnt have any)
- Register on AWS and create an account (if you doesnt have any). Make sure that it has all permissions to create ec2 instance/security groups/upload ssh key and to work with s3
- Create and configure s3 bucket for storing state (be sure to enable versioning)
- Add in jenkins-host credentials for aws (AWS Credentials)
- Add in jenkins-host credentials 'test-dockerhub' for dockerhub (username with password)
- Create ssh key for ansible user (aws-key-1.pem + aws-key-1.pem.pub). also How to generate ssh-key code below.
- Add in jenkins-host credentials 'test-jenkins-ansible' private key data for ansible (SSH username with private key), specify user = "ubuntu"
- In jenkins-host specify the label for the embedded node, for example "main"

2. Fork this github repo, then:
- Specify your s3 info in both *.s3.tfbackend files,
- Specify all your variables in both variables.tf, dont forget path to the public_key, created above
- in Jenkinsfile you could specify variables REPO_DH and PROJ_DH

0. How to generate ssh-key:
``` bash
ssh-keygen -t rsa -b 2048 -f /tmp/key/aws_key_1.pem
chmod 400 /tmp/key/aws_key_1.pem
```

ALSO: You can automate pipeline in Jenkins using pollscm or githook if you move parameters REPO_DH and PROJ_DH to env variables and delete all 'when's and stages 3,6 in Jenkinfile

## Setup Jenkins pipeline

1. Create jenkins pipeline:
- General:
  - Github project: url github.com/......
- Pipeline
  - Pipeline script from SCM
    - SCM: Git
      - repository: url github.com/......
    - Branch: */main
    - Script path: Jenkinsfile
2. Build pipeline with parameters REPO_DH and PROJ_DH for dockerhub repo/project.
3. Wait for the build to complete and check the status code of the last stage in the console output
4. Check the app by url: ip_prod:8080/demo/Hello but you can do it only from the ip address of the server where jenkins was installed and used
5. Build again and activate TF_DESTROY parameter in jenkins pipeline, wait while terrafrom destroys both EC2 instances, linked security groups and ssh keys, delete S3 bucket and thats it!

## Credits for demo artifact app
@tongueroo for https://github.com/tongueroo/demo-java
