# ModelMesh MinIO Examples

This repository contains the example models and the Dockerfile to build the
`modelmesh-minio-examples` container image. When ModelMesh is deployed with
the `--quickstart` flag, the example models are deployed via this image.


## Build the Image

Set the `DOCKER_USER` variable for the build and push process below:

```sh
# DOCKER_USER=kserve
DOCKER_USER=<your-docker-login>
```

Build the `modelmesh-minio-examples` docker image:

```sh
docker build --target minio-examples -t ${DOCKER_USER}/modelmesh-minio-examples:latest .
```

**Note**: When ModelMesh is [deployed with the `--fvt` flag](https://github.com/kserve/modelmesh-serving/blob/main/docs/developer.md)
then the `modelmesh-minio-dev-examples` image will be deployed instead of the
`modelmesh-minio-examples` image. To build the "dev" image, run the docker build
command with the `minio-fvt` target:

```sh
docker build --target minio-fvt -t ${DOCKER_USER}/modelmesh-minio-dev-examples:latest .
```

Push the newly built images to DockerHub:

```shell
docker push ${DOCKER_USER}/modelmesh-minio-examples:latest
docker push ${DOCKER_USER}/modelmesh-minio-dev-examples:latest
```


## Start the Container

Start a container with the name _"modelmesh-minio-examples"_:

```sh
docker run --rm --name "modelmesh-minio-examples" \
  -u "1000" \
  -p "9000:9000" \
  -p "9001:9001" \
  -e "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" \
  -e "MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  ${DOCKER_USER}/modelmesh-minio-examples:latest server /data1 --console-address ":9001"
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
check the size of the image and compare it to the
[`latest`](https://hub.docker.com/r/kserve/modelmesh-minio-dev-examples/tags)
image on DockerHub.

You can also compare the contents of the Docker images by using the `du` command
line utility to summarize disk usage of the files and folders recursively:

```sh
for user in kserve ${DOCKER_USER}; do
  docker run --rm --entrypoint bash ${user}/modelmesh-minio-dev-examples:latest \
    -c "du --max-depth=5 --all /data1/modelmesh-example-models/" | \
  sort -r -k 2 > file_sizes_${user}.txt
done

diff -U0 --minimal file_sizes_*.txt | \
  sed 's/^-/\x1b[1;31m-/;s/^+/\x1b[1;32m+/;s/^@/\x1b[1;34m@/;s/$/\x1b[0m/'

rm -f file_sizes_*.txt
```

Which should produce output similar to the one below when the `pytorch-mar-dup/mnist.mar`
model was added:

```diff
--- file_sizes_latest.txt   2023-01-24 13:05:37
+++ file_sizes_new.txt      2023-01-24 13:05:46
@@ -64,0 +65,2 @@
+4364   /data1/modelmesh-example-models/fvt/pytorch/pytorch-mar-dup/mnist.mar
+4368   /data1/modelmesh-example-models/fvt/pytorch/pytorch-mar-dup
@@ -78 +80 @@
-5184   /data1/modelmesh-example-models/fvt/pytorch
+9552   /data1/modelmesh-example-models/fvt/pytorch
@@ -114,2 +116,2 @@
-102836 /data1/modelmesh-example-models/fvt
-187160 /data1/modelmesh-example-models/
+107204 /data1/modelmesh-example-models/fvt
+191528 /data1/modelmesh-example-models/
```


### Troubleshooting

If you are adding large files to the repository and the `git push ...` command is
hanging after `Writing objects`, you may have to increase your
[`http.postBuffer`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-httppostBuffer)
before pushing your commit(s) to GitHub:

```sh
git config http.postBuffer 52428800
```
