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
