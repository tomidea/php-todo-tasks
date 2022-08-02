pipeline{

	agent any

	environment {
		DOCKERHUB_CREDENTIALS=credentials('dockerhub_id')
	}

	stages {

		stage('Login') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}

		
		stage('Build') {

			steps {

				sh 'docker-compose -f docker-compose.yaml up -d'

			}
		}

		

		stage('Push') {

			steps {

				sh 'docker push docker.io/tomidea/docker-compose-pipeline_todo_app'

			}
		}
	}

	post {
		always {
			sh 'docker logout'
		}
	}

}