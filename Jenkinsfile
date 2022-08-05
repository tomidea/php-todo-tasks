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

		// stage('Test') {

		// 	steps {
		// 			def response = httpRequest 'http://18.134.8.220/'
        // 			println("Status: "+response.status)
        // 			println("Content: "+response.content)

		// 			if(response.status != 200)
		// 			{
		// 				currentBuild.result = 'ABORTED'
    	// 				error('Endpoint return non 200 code...')
		// 			} 

		// 	}
		// }
		

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