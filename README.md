[![Docker Pulls](https://badgen.net/docker/pulls/pomlo/postgresql-s3-backup?icon=docker&label=pulls&cache=600)](https://hub.docker.com/r/pomlo/postgresql-s3-backup/tags) [![Docker Image Size](https://badgen.net/docker/size/pomlo/postgresql-s3-backup/latest?icon=docker&label=image%20size&cache=600)](https://hub.docker.com/r/pomlo/postgresql-s3-backup/tags) [![Docker build](https://img.shields.io/badge/automated-automated?style=flat&logo=docker&logoColor=blue&label=build&color=green&cacheSeconds=600)](https://hub.docker.com/r/pomlo/postgresql-s3-backup/tags) [![Docker Stars](https://badgen.net/docker/stars/pomlo/postgresql-s3-backup?icon=docker&label=stars&color=green&cache=600)](https://hub.docker.com/r/pomlo/postgresql-s3-backup) [![Github Stars](https://img.shields.io/github/stars/Pomlo/postgresql-s3-backup?label=stars&logo=github&color=green&style=flat&cacheSeconds=600)](https://github.com/Pomlo/postgresql-s3-backup) [![Github forks](https://img.shields.io/github/forks/Pomlo/postgresql-s3-backup?logo=github&style=flat&cacheSeconds=600)](https://github.com/Pomlo/postgresql-s3-backup/fork) [![Github open issues](https://img.shields.io/github/issues-raw/Pomlo/postgresql-s3-backup?logo=github&color=yellow&cacheSeconds=600)](https://github.com/Pomlo/postgresql-s3-backup/issues) [![Github closed issues](https://img.shields.io/github/issues-closed-raw/Pomlo/postgresql-s3-backup?logo=github&color=green&cacheSeconds=600)](https://github.com/Pomlo/postgresql-s3-backup/issues?q=is%3Aissue+is%3Aclosed) [![GitHub license](https://img.shields.io/github/license/Pomlo/postgresql-s3-backup)](https://github.com/Pomlo/postgresql-s3-backup/blob/master/LICENSE)


# postgresql-s3-backup
This is a Docker multi-arch image with a PostgreSQL client to create databases dumps, and s3cmd S3 client to interact with your S3 buckets, purely installed on the latest Alpine container.

This work is mostly inspired by [Angatar> d3fk/mysql-s3-backup](https://github.com/Angatar/mysql-s3-backup)

Useful with **any S3 compatible** object storage system to store your databases dumps.

The PostgreSQL client works with **any PostgreSQL-17 compatible database** ...

This container has a shell for entry point so that it can be **used to combine pg_dump and s3cmd commands** easily.

## Docker image
[![Docker Image Size](https://badgen.net/docker/size/pomlo/postgresql-s3-backup/latest?icon=docker&label=compressed%20size)](https://hub.docker.com/r/pomlo/postgresql-s3-backup/tags)

Pre-build as multi-arch image from Docker hub with "automated build" option.

- image name: **pomlo/postgresql-s3-backup**

`docker pull pomlo/postgresql-s3-backup`

Docker hub repository: https://hub.docker.com/r/pomlo/postgresql-s3-backup/

[![DockerHub Badge](https://dockeri.co/image/pomlo/postgresql-s3-backup)](https://hub.docker.com/r/pomlo/postgresql-s3-backup)

### Image TAGS
***"pomlo/postgresql-s3-backup:latest" is provided as multi-arch images.***

*These multi-arch images will fit most of architectures:*

- *linux/amd64*
- *linux/386*
- *linux/arm/v6*
- *linux/arm/v7*
- *linux/arm64/v8*
- *linux/ppc64le*
- *linux/s390x*


#### --- Latest ---

- **pomlo/postgresql-s3-backup:latest** is available as multi-arch image build from Docker Hub nodes dedicated to automated builds. Automated builds are triggered on each change of this [image code repository](https://github.com/Pomlo/postgresql-s3-backup) so that using the pomlo/postgresql-s3-backup:latest image ensures you to have the **latest updated (including security fixes) and functional version** available of s3cmd and postgresql client in a lightweight alpine image.

```sh
$ docker pull pomlo/postgresql-s3-backup:latest
```


## Basic usage

```sh
docker run --rm -v $(pwd):/s3 -v $HOME/.s3:/root pomlo/postgresql-s3-backup sh -c 'export DATE=$(date +%F_%H%M%S) && PGPASSWORD="${PGSQL_PASSWORD:your_password}" pg_dump -h ${PGSQL_HOST:localhost} -U ${PGSQL_USER:postgres} -d ${DATABASE_NAME} -f  "${DATE}_${DATABASE_NAME}_pgsqldump.sql" && s3cmd put --ssl ${DATE}_${DATABASE_NAME}_pgsqldump.sql s3://${BUCKET_NAME}'
```
The first volume is using your current directory as workdir(permit to keep a version of your dump locally) and the second volume is used for the configuration of your S3 connection.

Please reffer to pg_dump and s3cmd documentations to adapt options to your needs.

## s3cmd settings

It basically uses the .s3cfg configuration file. If you are already using s3cmd locally the previous docker command will use the .s3cfg file you already have at ``$HOME/.s3/.s3cfg``. In case you are not using s3cmd locally or don't want to use your local .s3cfg settings, you can use the s3cmd client to help you to generate your .s3cfg config file by using the following command.

```sh
mkdir .s3
docker run --rm -ti -v $(pwd):/s3 -v $(pwd)/.s3:/root pomlo/postgresql-s3-backup s3cmd --configure
```
A blank .s3cfg file is also provided as a template in the [.s3 directory of the source repository](https://github.com/Pomlo/postgresql-s3-backup/tree/master/.s3), if you wish to configure it by yourself from scratch.

### s3cmd and encryption
s3cmd enables you with encryption during transfert with SSL if defined in the config file or if the option in metionned in the command line.
s3cmd also enables you with encryption at REST with server-side encryption by using the flag --server-side-encryption (e.g: you can specify the KMS key to use on the server), or client side encryption by using the flag -e or --encrypt. These options can also be defined in the .s3cfg config file.

### s3cmd complete documentation

See [here](http://s3tools.org/usage) for the documentation.


## Automatic Periodic Backups with Kubernetes

This container was created to be used within a K8s CRONJOB.
You can use the provided YAML file named s3-dump-cronjob.yaml as a template for your CRONJOB.
A configmap can easily be created from the .s3cfg config file with the following kubectl command:
```sh
kubectl create configmap s3config --from-file $HOME/.s3
```
It is suggested to store your database credential into a K8s secret as a good practice.
Then, once configured with your data volume/path and your bucket (by completing the file or defining the ENV variables: YOUR_KMS_KEY_ID, YOUR_BUCKET_NAME, PGSQL_HOST, PGSQL_USER, PGSQL_PASSWORD/secret, DATABASE_NAME), the k8s CRONJOB can be created from the file:
```sh
kubectl create -f s3-dump-cronjob.yaml
```
*Nb: Enabling the versioning option of your S3 Bucket will provide you with an efficient versioned database backuping system*

### s3cmd & s3 data backups

In case you are interested in storing other data into a S3 compatible object storage you'd probably prefer to use [d3fk/s3cmd](https://hub.docker.com/r/d3fk/s3cmd) wich is also based on Alpine distrib but only contains the s3cmd tool and has s3cmd for entrypoint.


## License

The content of this [GitHub code repository](https://github.com/Pomlo/postgresql-s3-backup) is provided under **MIT** licence
[![GitHub license](https://img.shields.io/github/license/Pomlo/postgresql-s3-backup)](https://github.com/Pomlo/postgresql-s3-backup/blob/master/LICENSE). 
For **s3cmd** license, please see https://github.com/s3tools/s3cmd . 
For the postgresql-client client package license, please see https://pkgs.alpinelinux.org/packages?name=postgresql*-client .
