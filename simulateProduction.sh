docker rm -f master-mysql

mvn package -DskipTests

export BUCKET_NAME=practica-2.iwcn.michel
export REGION=us-east-1

docker run --name master-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=cloud-computing -e MYSQL_DATABASE=events_db -d  mysql:5.7
sleep 10

export RDS_ENDPOINT=localhost:3306
export RDS_DATABASE=events_db
export RDS_PASS=cloud-computing
export RDS_USER=root

java -jar -Dspring.profiles.active=production target/practica_1_cloud_ordinaria_2021-0.0.1-SNAPSHOT.jar