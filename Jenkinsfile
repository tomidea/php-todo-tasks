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

		stage('Test') {

			steps {
				script{
					def response = httpRequest 'http://18.134.8.220/'
        			println("Status: "+response.status)

				    if(response.status != 200)
					{
						currentBuild.result = 'ABORTED'
    					error('Endpoint return non 200 code...')
					} 
        			println("Message: Test GET http://18.134.8.220/ passed")
				}

				}	
				
		}
		

		stage('Push') {

			steps {

				sh 'docker push tomidea/todo_app'

			}
		}
	}

	post {
		always {
			sh 'docker logout'
		}
	}

}