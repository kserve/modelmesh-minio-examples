# Copyright 2023 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Using specific tag for now, there was some reason newer minio versions didn't work
ARG MODEL_DIR=/data1/modelmesh-example-models
ARG FVT_DIR=/data1/modelmesh-example-models/fvt

FROM quay.io/centos/stream9-minimal as os
ARG MODEL_DIR
EXPOSE 9000

USER root

RUN useradd -u 1000 -g 0 modelmesh &&\
    mkdir -p ${MODEL_DIR} &&\
    chown -R 1000:0 /data1 && \
    chgrp -R 0 /data1 && \
    chmod -R g=u /data1

FROM quay.io/minio/minio:RELEASE.2024-02-26T09-33-48Z as minio
ARG FVT_DIR
ARG MODEL_DIR
COPY --chown=1000:0 keras      ${MODEL_DIR}/keras/
COPY --chown=1000:0 lightgbm   ${MODEL_DIR}/lightgbm/
COPY --chown=1000:0 onnx       ${MODEL_DIR}/onnx/
COPY --chown=1000:0 pytorch    ${MODEL_DIR}/pytorch/
COPY --chown=1000:0 sklearn    ${MODEL_DIR}/sklearn/
COPY --chown=1000:0 tensorflow ${MODEL_DIR}/tensorflow/
COPY --chown=1000:0 xgboost    ${MODEL_DIR}/xgboost/

# some models are duplicated for testing and verification
COPY --chown=1000:0 tensorflow/mnist ${MODEL_DIR}/tensorflow/mnist.savedmodel/

# some models are duplicated for FVT testing and verification
COPY --chown=1000:0 fvt ${FVT_DIR}/
COPY --chown=1000:0 keras                    ${FVT_DIR}/keras/
COPY --chown=1000:0 keras                    ${FVT_DIR}/tensorflow/keras-mnist/
COPY --chown=1000:0 keras                    ${FVT_DIR}/tensorflow/keras-mnistnew/
COPY --chown=1000:0 tensorflow/mnist         ${FVT_DIR}/tensorflow/mnist.savedmodel/
COPY --chown=1000:0 tensorflow/mnist         ${FVT_DIR}/tensorflow/mnist-dup.savedmodel/
COPY --chown=1000:0 fvt/pytorch/pytorch-mar  ${FVT_DIR}/pytorch/pytorch-mar-dup/


USER 1000
