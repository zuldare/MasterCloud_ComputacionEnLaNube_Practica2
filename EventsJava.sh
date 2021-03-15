#!/bin/sh 
SERVICE_NAME=EventsJava 
PATH_TO_JAR=/home/ubuntu/app.jar
PID_PATH_NAME=/tmp/EventsJava-pid 

export BUCKET_NAME=practica-1.cloud.michel
# OJO! AQUÍ USAMOS EL ENDPOINT DE LA BASE DE DATOS A FUEGO
export RDS_ENDPOINT=XXXXXXXXXXXXXXXXXXXXXXXXXXX

export REGION=us-east-1
export RDS_DATABASE=events_db
export RDS_PASS=password
export RDS_USER=admin

case $1 in 
     start)
          echo "Starting $SERVICE_NAME ..."
     if [ ! -f $PID_PATH_NAME ]; then 
          nohup java -jar -Dspring.profiles.active=production $PATH_TO_JAR --server.port=443 /tmp 2>> /dev/null >>/dev/null &      
          echo $! > $PID_PATH_NAME  
          echo "$SERVICE_NAME started ..."         
     else 
          echo "$SERVICE_NAME is already running ..."
     fi
     ;;
     stop)
     if [ -f $PID_PATH_NAME ]; then
          PID=$(cat $PID_PATH_NAME);
          echo "$SERVICE_NAME stoping ..." 
          kill $PID;         
          echo "$SERVICE_NAME stopped ..." 
          rm $PID_PATH_NAME       
     else          
          echo "$SERVICE_NAME is not running ..."   
     fi    
     ;;    
     restart)  
     if [ -f $PID_PATH_NAME ]; then 
          PID=$(cat $PID_PATH_NAME);    
          echo "$SERVICE_NAME stopping ..."; 
          kill $PID;           
          echo "$SERVICE_NAME stopped ...";  
          rm $PID_PATH_NAME     
          echo "$SERVICE_NAME starting ..."  
          nohup java -jar -Dspring.profiles.active=production $PATH_TO_JAR --server.port=443 /tmp 2>> /dev/null >>/dev/null &            
          echo $! > $PID_PATH_NAME  
          echo "$SERVICE_NAME started ..."    
     else           
          echo "$SERVICE_NAME is not running ..."    
          fi     ;;
esac