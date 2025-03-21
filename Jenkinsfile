// Global variables
def PUBLIC_IP_SEC = ''
def PUBLIC_IP_BUILD = ''
def PUBLIC_IP_PROD = ''
def COMMIT_HASH = ''
def STATUS_1 = ''
def STATUS_2 = ''
pipeline {
    agent { label 'main' }
    parameters{
        // Repository and project names for DockerHub, also select for destroy all EC2, you can code value here or write later in jenkins build parameters
        string(name: 'REPO_DH', defaultValue: 'test_repo', description: 'Name of repo in Dockerhub before /', trim: true)
        string(name: 'PROJ_DH', defaultValue: 'test_proj', description: 'Name of project in Dockerhub after /', trim: true)
        booleanParam(name: 'TF_DESTROY', defaultValue: false, description: 'Destroy Terraform build?')
    }
    stages {
        stage('Checking params') {
            // Check if the required parameters are provided
            when {
                beforeAgent true
                anyOf {
                    expression { params.REPO_DH.isEmpty() }
                    expression { params.PROJ_DH.isEmpty() }
                }
            }
            steps {
                error("ENV is empty")
            }
        }
        stage('Checkout') {
            // Checkout source code and extract the commit hash for tagging docker image
            steps {
                checkout scm
                script {
                    scmVars = checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/killaxefusr/jenkins-tf-ansi-aws']]])
                    env.GIT_COMMIT = scmVars.GIT_COMMIT
                    COMMIT_HASH = env.GIT_COMMIT.substring(0, 7)
                    }
            }
        }
        stage('Terraform destroy build') {
            // Destroy build EC2 instance if TF_DESTROY = true
            when {
                equals expected: true, actual: params.TF_DESTROY
            }
            steps {
                dir('build') {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'test-jenkins-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
// !Specify yours credentialsId for aws cli
                        sh 'terraform init -no-color -backend-config=conf_build.s3.tfbackend -input=false'
                        sh 'terraform plan -destroy -no-color -out=tfpland -input=false'
                        sh "terraform show -no-color tfpland"
                        sh 'terraform apply -no-color -input=false -auto-approve tfpland'
                    }
                }
            }
        }
        stage('Terraform apply build') {
            // Apply terraform config to create build EC2
            when {
                not {
                    equals expected: true, actual: params.TF_DESTROY
                }
            }
            steps {
                dir('build') {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'test-jenkins-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
// !Specify yours credentialsId for aws cli
                        sh 'terraform init -no-color -backend-config=conf_build.s3.tfbackend -input=false'
                        sh 'terraform plan -no-color -out=tfplan -input=false'
                        sh "terraform show -no-color tfplan"
                        sh 'terraform apply -no-color -input=false -auto-approve tfplan'
                        script {
                            PUBLIC_IP_BUILD = sh(
                                script: "terraform output -json aws_instance_public_dns | sed -e 's/[][]//g' -e 's/\"//g' | head -n 1",
                                returnStdout: true).trim()
                            PUBLIC_IP_SEC = sh(
                                script: "terraform output -json ip_addr_for_sec_group | sed -e 's/[][]//g' -e 's/\"//g' | head -n 1",
                                returnStdout: true).trim()
                            echo "PUBLIC IP SET FOR EC2_BUILD IS ${PUBLIC_IP_BUILD}"
                            echo "PUBLIC IP SET IN AWS_SEC_RULE IS ${PUBLIC_IP_SEC}"
                        }
                    }
                }
            }
        }
        stage('Ansible Build') {
            // Start ansible playbook to setup docker, create docker image and push it to the dockerhub
            when {
                not {
                    equals expected: true, actual: params.TF_DESTROY
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'test-dockerhub', passwordVariable: 'PASS_DH', usernameVariable: 'USER_DH')]) {
// !Specify yours credentialsId for Dockerhub
                    ansiblePlaybook(
                        credentialsId: 'test-jenkins-ansible', 
// !Specify yours credentialsId for ssh key
                        disableHostKeyChecking: true, 
                        inventory: "${PUBLIC_IP_BUILD},", 
                        playbook: 'build/build.yml',
                        extraVars: [
                            ec2_instance_ip: [value: "${PUBLIC_IP_BUILD}", hidden: false],
                            password_dh: [value: "${PASS_DH}", hidden: true],
                            username_dh: [value: "${USER_DH}", hidden: true],
                            image_tag: [value: "${COMMIT_HASH}", hidden: false],
                            repository: [value: "${params.REPO_DH}", hidden: false],
                            project: [value: "${params.PROJ_DH}", hidden: false]
                        ])
                }
            }
        }
        stage('Terraform destroy prod') {
            // Destroy prod EC2 instance if TF_DESTROY = true
            when {
                equals expected: true, actual: params.TF_DESTROY
            }
            steps {
                dir('prod') {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'test-jenkins-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
// !Specify yours credentialsId for aws cli
                        sh 'terraform init -no-color -backend-config=conf_prod.s3.tfbackend -input=false'
                        sh 'terraform plan -destroy -no-color -out=tfpland -input=false'
                        sh "terraform show -no-color tfpland"
                        sh 'terraform apply -no-color -input=false -auto-approve tfpland'
                    }
                }
            }
        }
        stage('Terraform apply Prod') {
            // Apply terraform config to create prod EC2
            when {
                not {
                    equals expected: true, actual: params.TF_DESTROY
                }
            }
            steps {
                dir('prod') {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'test-jenkins-aws', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
// !Specify yours credentialsId for aws cli
                        sh 'terraform init -no-color -backend-config=conf_prod.s3.tfbackend -input=false'
                        sh 'terraform plan -no-color -out=tfplan -input=false'
                        sh "terraform show -no-color tfplan"
                        sh 'terraform apply -no-color -input=false -auto-approve tfplan'
                        script {
                            PUBLIC_IP_PROD = sh(
                                script: "terraform output -json aws_instance_public_dns | sed -e 's/[][]//g' -e 's/\"//g' | head -n 1",
                                returnStdout: true).trim()
                            PUBLIC_IP_SEC = sh(
                                script: "terraform output -json ip_addr_for_sec_group | sed -e 's/[][]//g' -e 's/\"//g' | head -n 1",
                                returnStdout: true).trim()
                            echo "PUBLIC IP SET FOR EC2_PROD IS ${PUBLIC_IP_PROD}"
                            echo "PUBLIC IP SET IN AWS_SEC_RULE IS ${PUBLIC_IP_SEC}"
                        }
                    }
               }
            }
        }
        stage('Ansible Prod') {
            // Start ansible playbook to setup docker, and pull docker image from the dockerhub and start docker container
            when {
                not {
                    equals expected: true, actual: params.TF_DESTROY
                }
            }
            steps {
                ansiblePlaybook(
                    credentialsId: 'test-jenkins-ansible',
// !Specify yours credentialsId for ssh key
                    disableHostKeyChecking: true,
                    inventory: "${PUBLIC_IP_PROD},",
                    playbook: 'prod/prod.yml',
                    extraVars: [
                        ec2_instance_ip: [value: "${PUBLIC_IP_PROD}", hidden: false],
                        image_tag: [value: "${COMMIT_HASH}", hidden: false],
                        repository: [value: "${params.REPO_DH}", hidden: false],
                        project: [value: "${params.PROJ_DH}", hidden: false]
                    ])
            }
        }
        stage('Test Prod') {
            // Receive status code from the app and echo it
            when {
                not {
                    equals expected: true, actual: params.TF_DESTROY
                }
            }
            steps {
                sleep(time:30,unit:"SECONDS")
                script {
                    echo "PAGE 1 AVAILABLE ON ${PUBLIC_IP_PROD}:8080/demo/Hello"
                    STATUS_1 = sh(script: "curl -k -s -o /dev/null -w \"%{http_code}\" ${PUBLIC_IP_PROD}:8080/demo/Hello", returnStdout: true).trim()
                    echo "THE STATUS CODE PAGE 1 IS ${STATUS_1}"
                    echo "PAGE 2 AVAILABLE ON ${PUBLIC_IP_PROD}:8080/demo/index.jsp"
                    STATUS_2 = sh(script: "curl -k -s -o /dev/null -w \"%{http_code}\" ${PUBLIC_IP_PROD}:8080/demo/index.jsp", returnStdout: true).trim()
                    echo "THE STATUS CODE PAGE 2 IS ${STATUS_2}"
                }
            }
        }
    }
}
