# ModelMesh MinIO Examples

This repository contains the example models and the Dockerfile to build the
`modelmesh-minio-examples` container image. When ModelMesh is deployed with
the `--quickstart` flag, the example models are deployed via this image.


## Build the Image

Build the `modelmesh-minio-examples` docker image:

```sh
docker build --target minio-examples -t kserve/modelmesh-minio-examples:latest .
```

**Note**: When ModelMesh is [deployed with the `--fvt` flag](https://github.com/kserve/modelmesh-serving/blob/main/docs/developer.md)
then the `modelmesh-minio-dev-examples` image will be deployed instead of the
`modelmesh-minio-examples` image. To build the "dev" image, run the docker build
command with the `minio-fvt` target:

```sh
docker build --target minio-fvt -t kserve/modelmesh-minio-dev-examples:latest .
```

Push the newly built images to DockerHub:

```shell
docker push kserve/modelmesh-minio-examples:latest
docker push kserve/modelmesh-minio-dev-examples:latest
```


## Start the Container

Start a container with the name _"modelmesh-minio-examples"_:

```sh
docker run --rm --name "modelmesh-minio-examples" \
  -u "1000" \
  -p "9000:9000" \
  -e "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" \
  -e "MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  kserve/modelmesh-minio-examples:latest server /data1
```


## Test the Image Using the MinIO Client

Install the [MinIO client](https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart), `mc`.

Create an alias `localminio` for the local MinIO instance:

```sh
mc alias set localminio http://localhost:9000 AKIAIOSFODNN7EXAMPLE wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

List all objects in the `modelmesh-example-models` bucket:

```sh
mc ls -r localminio/modelmesh-example-models/
```


### Stop and Remove the Docker Container

To shut down and remove the _"modelmesh-minio-examples"_ Docker container run the
following commands:

```sh
docker stop "modelmesh-minio-examples"
docker rm "modelmesh-minio-examples"
```


### Developer Guidelines

Avoid duplicating large files in the Git repository, instead use `COPY ...` in
the `Dockerfile`.

When building a new container image after making changes to the `Dockerfile`,
check the size of the image and compare it to the `latest` image on DockerHub.


### Troubleshooting

If you are adding large files to the repository and the `git push ...` command is
hanging after `Writing objects`, you may have to increase your
[`http.postBuffer`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-httppostBuffer)
before pushing your commit(s) to GitHub:

```sh
git config http.postBuffer 52428800
```
