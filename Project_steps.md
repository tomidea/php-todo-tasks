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
            
            $ docker build -t tooling:0.0.1 .
                                                                                 
    6. Run the container:
            
            $ docker run --network tooling_app_network -p 8085:80 -it tooling:0.0.1 
                                                                                 
      You can open the browser and type http://localhost:8085
