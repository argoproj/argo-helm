#!/usr/bin/env groovy

@Library('jenkins-shared-library') _

pipeline {
    agent any
    options {
        disableConcurrentBuilds()
    }
    environment {
        VERSION = getSemver()
    }
    stages {

        stage('Checkout') {
            steps {
                checkoutWithEnv()
            }
        }

        stage('Skip?') {
            steps {
                abortIfGitTagExists env.VERSION
            }
        }

        stage('Tag') {
            when { branch 'master' }
            steps {
                pushGitTag env.VERSION
            }
        }
    }
    post {
        always {
            slackBuildStatus '#team-need4speed-auto', env.SLACK_USER
        }
    }
}
