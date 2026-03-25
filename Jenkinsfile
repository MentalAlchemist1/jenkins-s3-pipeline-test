// =============================================================================
//  JENKINSFILE — CI/CD Pipeline for Terraform on AWS
// =============================================================================
//  Purpose:  Deploys AWS infrastructure via Terraform through Jenkins.
//
//  What to customize before using:
//    1. AWS_REGION       → Your AWS region (line 15)
//    2. CREDENTIAL_ID    → Must match the ID you set in Jenkins credentials (line 16)
//    3. Your GitHub repo → Set in Jenkins pipeline config (SCM section), NOT here
//
//  Requires on Jenkins server:
//    - Plugins:  AWS Credentials, Pipeline: AWS Steps, Git
//    - Binaries: terraform, aws cli, python3 (installed via SSH/exec)
//    - AWS credentials configured in Jenkins UI (Manage Jenkins → Credentials)
//    - AWS CLI configured on server (aws configure via SSH/exec)
// =============================================================================

pipeline {
    agent any

    // ── ENVIRONMENT VARIABLES (pipeline-wide) ──────────────────────────────
    environment {
        AWS_REGION    = 'us-west-2'
        CREDENTIAL_ID = 'jenkins-test'   // Must match your Jenkins credential ID exactly
    }

    stages {

        // ── STAGE 1: CHECKOUT CODE ─────────────────────────────────────────
        // Pulls the repo configured in Jenkins pipeline SCM settings.
        // No need to hardcode a GitHub URL here — checkout scm handles it.
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        // ── STAGE 2: TERRAFORM INIT ────────────────────────────────────────
        // Initializes Terraform — downloads providers, sets up backend.
        // Credentials are required because init may connect to an S3 backend.
        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                  credentialsId: "${CREDENTIAL_ID}",
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh '''
                        terraform init
                    '''
                }
            }
        }

        // ── STAGE 3: TERRAFORM VALIDATE ────────────────────────────────────
        // Checks syntax and internal consistency of Terraform files.
        // Does NOT need AWS credentials — it's a local syntax check only.
        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        // ── STAGE 4: TERRAFORM FORMAT ──────────────────────────────────────
        // Checks if .tf files follow standard formatting conventions.
        // Does NOT need AWS credentials — it's a local formatting check.
        stage('Terraform Format') {
            steps {
                sh 'terraform fmt -check'
            }
        }

        // ── STAGE 5: TERRAFORM PLAN ────────────────────────────────────────
        // Generates an execution plan showing what will be created/changed.
        // Saves the plan to a file so apply uses the exact same plan.
        stage('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                  credentialsId: "${CREDENTIAL_ID}",
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh '''
                        terraform plan -out=tfplan
                    '''
                }
            }
        }

        // ── STAGE 6: TERRAFORM APPLY ───────────────────────────────────────
        // Deploys the infrastructure defined in the plan.
        // -auto-approve skips the manual "yes" prompt.
        stage('Terraform Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                  credentialsId: "${CREDENTIAL_ID}",
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh '''
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        // ── STAGE 7 (OPTIONAL): TERRAFORM DESTROY ─────────────────────────
        // Tears down all infrastructure created by this pipeline.
        // Uses an input prompt so it only runs when you explicitly say "yes".
        // Prevents accidental charges from resources left running.
        stage('Terraform Destroy') {
            steps {
                input message: 'Destroy infrastructure?', ok: 'Yes, destroy it'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                  credentialsId: "${CREDENTIAL_ID}",
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh '''
                        terraform destroy -auto-approve
                    '''
                }
            }
        }
    }

    // ── POST-PIPELINE ACTIONS ──────────────────────────────────────────────
    // These run after all stages complete, regardless of success or failure.
    post {
        success {
            echo '>>> Pipeline completed successfully.'
        }
        failure {
            echo '>>> Pipeline failed. Check console output for details.'
        }
        always {
            echo '>>> Pipeline execution finished.'
        }
    }
}
