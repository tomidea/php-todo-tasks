pipeline{

	agent any

	environment {
		DOCKERHUB_CREDENTIALS=credentials('dockerhub_id')
	}

	stages {

		stage('Build') {

			steps {
				sh 'docker build -t tomidea/todo-app:latest .'
			}
		}

		stage('Login') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}

		stage('Push') {

			steps {
				sh 'docker push tomidea/todo-app:latest'
			}
		}
	}

	post {
		always {
			sh 'docker logout'
		}
	}

}