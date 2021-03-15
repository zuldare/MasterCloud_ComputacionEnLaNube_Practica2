# Práctica 1

Pasos a seguir:
## Paso 1: Crear los Security Groups

Creación de un Security Group para EC2 (__EC2_Events_SecurityGroup__):

    22	    TCP     my_ip	
    8443	TCP     0.0.0.0/0

Creación de un Security Group para RDS (__RDS_EventsApp_SecurityGroup__):

    MYSQL/Aurora	TCP	3306	sg-XXXXXXXXXXXXXXXX (EC2_Events_SecurityGroup)

## Paso 2: Crear un rol con acceso a S3

Creación de un rol __S3FullAccess__ para EC2 con la política AmazonS3FullAccess

## Paso 3: Lanzar las RDS

- MySQL 8.0
- Free Tier (db.t2.micro)
- USER: admin
- PASS: password
- DB:   events_db
- Security Group: __RDS_EventsApp_SecurityGroup__

## Paso 4: Lanzar la EC2

- Ubuntu Server 18.04 LTS
- Free tier (t2.micro)
- Role de IAM: __S3FullAccess__
- Security Group: __EC2_Events_SecurityGroup__

## Paso 5: Nos conectamos a la instancia y la configuramos

En local

```sh
export EC2_DNS=
export KEYS=
ssh -i ${KEYS} ubuntu@${EC2_DNS}
```

En remoto (EC2)

```sh
sudo apt-get update
sudo apt install -y openjdk-11-jdk
java -version
```

## Paso 6: Compilamos la aplicación y la copiamos al servidor remoto (Local -> EC2)

En local:
```sh
mvn install -DskipTests
scp -i ${KEYS} target/practica_1_cloud_ordinaria_2021-0.0.1-SNAPSHOT.jar ubuntu@${EC2_DNS}:/home/ubuntu/app.jar
```

## Paso 7: Lanzar la aplicación

En remoto (EC2):
```sh
export RDS_DNS=
sudo java -jar -Dspring.profiles.active=production app.jar \
    --server.port=443 \
    --spring.datasource.url=jdbc:mysql://${RDS_DNS}/events_db \
    --spring.datasource.username=admin \
    --spring.datasource.password=password \
    --amazon.s3.bucket-name=practica-1.cloud.michel \
    --amazon.s3.endpoint=https://s3.amazonaws.com/practica-1.cloud.michel/ \
    --amazon.s3.region=us-east-1
```

## Paso 8: Crear el servicio

> Revisar el fichero EventsJava.sh -> Rellenar la variable RDS_ENDPOINT

En local:
```sh
sudo scp -i ${KEYS} EventsJava.sh ubuntu@${EC2_DNS}:/tmp/EventsJava.sh
sudo scp -i ${KEYS} EventsJava.service ubuntu@${EC2_DNS}:/tmp/EventsJava.service
```

En remoto (EC2):
```sh
sudo mv /tmp/EventsJava.sh /usr/local/bin/EventsJava.sh
sudo mv /tmp/EventsJava.service /etc/systemd/system/EventsJava.service
sudo chmod +x /usr/local/bin/EventsJava.sh
sudo systemctl daemon-reload
sudo systemctl enable EventsJava
sudo systemctl start EventsJava
```

## Paso 9: Crear la AMI y lanzarla

