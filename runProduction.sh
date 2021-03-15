mvn package -DskipTests

export BUCKET_NAME=practica-1.cloud.michel
export RDS_ENDPOINT=

export REGION=us-east-1
export RDS_DATABASE=events_db
export RDS_PASS=password
export RDS_USER=admin

java -jar -Dspring.profiles.active=production target/practica_1_cloud_ordinaria_2021-0.0.1-SNAPSHOT.jar