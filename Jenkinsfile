pipeline {
    agent any
    environment {
        PATH = "${PATH}:${getTerraformPath()}"
    }
    stages{
        stage('terraform init'){
            steps {
                 //sh "returnStatus: true, script: 'terraform workspace new dev'"
                slackSend (color: '#FFFF00', message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
                sh "terraform init"
            }
        }
        stage('terraform plan'){
            steps {
                 //sh "returnStatus: true, script: 'terraform workspace new dev'"
                 //sh "terraform apply -auto-approve"
                sh "terraform plan -out=tfplan -input=false"
            }
        }
        stage('Final Deployment Approval') {
            steps {
                script {
                def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
            }
        }
        }
        stage('Terraform Destroy'){
            steps {
                 //sh "returnStatus: true, script: 'terraform workspace new dev'"
                 //sh "terraform apply -auto-approve"
                sh "terraform destroy  -input=false tfplan"
            }
        }
    }
}

def getTerraformPath(){
        def tfHome= tool name: 'terraform-14', type: 'terraform'
        return tfHome
    }
