
# MIGRATION TO THE СLOUD WITH CONTAINERIZATION. PART 1 – DOCKER & DOCKER COMPOSE

## migrate the Tooling Web Application from a VM-based solution into a containerized one
* I have prepared an EC2 instance and installed docker engine on it

Step 1: Pull MySQL Docker Image from Docker Hub Registry
    
    docker pull mysql/mysql-server:latest
  List the images to check that you have downloaded them successfully:
    
    docker image ls
    
 Step 2: Deploy the MySQL Container to your Docker Engine
    
    docker run --name <container_name> -e MYSQL_ROOT_PASSWORD=<my-secret-pw> -d mysql/mysql-server:latest

  - Replace <container_name> with the name of your choice. 
  - The -d option instructs Docker to run the container as a service in the background
  - Replace <my-secret-pw> with your chosen password

 check to see if the MySQL container is running: docker ps -a
  
Step 3: Connecting to the MySQL Docker Container

       $ docker exec -it mysql mysql -uroot -p
* exec used to execute a command from bash itself
* -it makes the execution interactive and allocate a pseudo-TTY
* bash this is a unix shell and its used as an entry-point to interact with our container
* mysql The second mysql in the command "docker exec -it mysql mysql -uroot -p" serves as the entry point to interact with mysql container just like bash or sh
* -u mysql username
* -p mysql password

  ### Approach 2

 1. create a network:
          
        $ docker network create --subnet=172.18.0.0/24 tooling_app_network  

 2. create an environment variable to store the root password:
      
        $ export MYSQL_PW= 
 
 3. pull the image and run the container, all in one command like below:

       $ docker run --network tooling_app_network -h mysqlserverhost --name=mysql-server -e MYSQL_ROOT_PASSWORD=$MYSQL_PW  -d mysql/mysql-server:latest 
  
  * -d runs the container in detached mode
  * --network connects a container to a network
  * -h specifies a hostname
    
  4. Create a file and name it create_user.sql and add the below code in the file:

             $ CREATE USER ''@'%' IDENTIFIED BY ''; GRANT ALL PRIVILEGES ON * . * TO ''@'%'; 
   5. Run the script: $ docker exec -i mysql-server mysql -uroot -p$MYSQL_PW < create_user.sql 
                                                                                              
   6. Run the MySQL Client Container: $ docker exec -i mysql-server mysql -uroot -p$MYSQL_PW < create_user.sql   
  *  --name gives the container a name
  *  -it runs in interactive mode and Allocate a pseudo-TTY
  *  --rm automatically removes the container when it exits
  *  --network connects a container to a network
  *  -h a MySQL flag specifying the MySQL server Container hostname
  *  -u user created from the SQL script : admin username-for-user-created-from-the-SQL-script-create_user.sql
  * -p password specified for the user created from the SQL script

    ### Prepare database schema
    
 1. Clone the Tooling-app repository from here
       
        $ git clone https://github.com/darey-devops/tooling.git 

 2. On your terminal, export the location of the SQL file
        
        $ export tooling_db_schema=/tooling_db_schema.sql 
  
 3. Use the SQL script to create the database and prepare the schema. With the docker exec command, you can execute a command in a running container.
      $ docker exec -i mysql-server mysql -uroot -p$MYSQL_PW < $tooling_db_schema 

 4. Update the .env file with connection details to the database

            sudo vi .env

            MYSQL_IP=mysqlserverhost
            MYSQL_USER=username
            MYSQL_PASS=client-secrete-password
            MYSQL_DBNAME=toolingdb
            
                                                                                 
            Flags used:
            MYSQL_IP mysql ip address "leave as mysqlserverhost"
            MYSQL_USER mysql username for user export as environment variable
            MYSQL_PASS mysql password for the user exported as environment varaible
            MYSQL_DBNAME mysql databse name "toolingdb"      
   
    5. Run the Tooling App
            
            > $ docker build -t tooling:0.0.1 .
                                                                                 
    6. Run the container:
            '''
            $ docker run --network tooling_app_network -p 8085:80 -it tooling:0.0.1 
                  '''                                                               
        
    <img width="940" alt="Screenshot 2022-07-09 at 16 33 38" src="https://user-images.githubusercontent.com/51254648/183627129-169df1c9-677f-493d-a9d2-90858690200a.png">
    
    You can open the browser and type http://localhost:8085
    
    <img width="1280" alt="Screenshot 2022-07-09 at 17 18 35" src="https://user-images.githubusercontent.com/51254648/183627986-21f553cd-1e01-4347-8aea-e318b1c928b0.png">

                                                                                 
 ### PRACTICE TASK
Practice Task №1 – Implement a POC to migrate the PHP-Todo app into a containerized application.

Part 1
* Write a Dockerfile for the TODO app
    
            FROM php:7.1-apache
            LABEL Creator="tomidea"
            COPY . /home
            COPY config.conf /etc/apache2/sites-enabled
            WORKDIR /home
            RUN apt-get update \
             && rm /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-available/000-default.conf \
             && echo "ServerName 127.0.0.1." >> /etc/apache2/apache2.conf \
             && a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests \
             && apachectl configtest \
             && service apache2 restart \
             && apt install -y wget git zip \
             && docker-php-ext-install pdo_mysql pdo mysqli \
             && wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet \
             && mv composer.phar /usr/bin/composer \
             && composer install 
            # && php artisan migrate
            EXPOSE 80
            # ENTRYPOINT [ "service", "apache2", "start"]
            CMD [ "php", "artisan", "serve" ]
    
* Run both database and app on your laptop Docker Engine
* Access the application from the browser                                                          

    <img width="1270" alt="Screenshot 2022-07-20 at 17 12 43" src="https://user-images.githubusercontent.com/51254648/183628353-b1dd3b4d-3004-4699-b4dc-673ab4f71223.png">

    
Part 2
* Create an account in Docker Hub
* Create a new Docker Hub repository
* Push the docker images from your PC to the repository
   <img width="1339" alt="Screenshot 2022-08-09 at 12 26 48" src="https://user-images.githubusercontent.com/51254648/183636363-8a30c0aa-0082-4e56-b7ab-ecf68d1556c2.png">

    
Part 3

* Write a Jenkinsfile that will simulate a Docker Build and a Docker Push to the registry
* Connect your repo to Jenkins
* Create a multi-branch pipeline
    <img width="1080" alt="jenkins maindev" src="https://user-images.githubusercontent.com/51254648/183631797-b54955cd-21ee-41d2-a024-f65e1b259791.png">

* Simulate a CI pipeline from a feature and master branch using previously created Jenkinsfile
* Ensure that the tagged images from your Jenkinsfile have a prefix that suggests which branch the image was pushed from. For example, feature-0.0.1.
   
    <img width="254" alt="vscode mandev img" src="https://user-images.githubusercontent.com/51254648/183629293-bc5d86b3-9346-4643-9878-5602a23e727b.png">


* Verify that the images pushed from the CI can be found at the registry.
    <img width="1308" alt="dockerhub maindev" src="https://user-images.githubusercontent.com/51254648/183629043-065513a5-5497-43ba-adc3-fecaedbf579f.png">

    
 ### Practice Task №2 – Complete Continous Integration With A Test Stage

* Update your Jenkinsfile with a test stage before pushing the image to the registry.
    
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
                            sh 'docker build -t tomidea/todo-app:'+env.BRANCH_NAME+'-0.0.1 .' .'
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
                        sh 'docker system prune --all'
                    }
                }

            }

* What you will be testing here is to ensure that the PHP-todo site http endpoint is able to return status code 200. Any other code will be determined a stage failure.
    
    <img width="951" alt="pass test" src="https://user-images.githubusercontent.com/51254648/183631910-80a5b952-03f7-4bb8-a4c0-d08a7d46a430.png">
    
    
    
    <img width="873" alt="failed test" src="https://user-images.githubusercontent.com/51254648/183632045-92adad14-e3e9-4fcc-a32d-b2d05c9d1815.png">

    
    
