# This container image using to ensure proper versions and portability
# of required software

# A minimal Docker image based on Alpine Linux
# https://hub.docker.com/_/alpine/tags?name=3.17.0
FROM alpine:3.17.0 as build

ENV TF_VER 1.3.6
ENV TF_BASEURL https://releases.hashicorp.com/terraform
ENV TG_VER 0.42.5
ENV TG_BASEURL https://github.com/gruntwork-io/terragrunt/releases/download

WORKDIR /build

RUN apk add --no-cache --update curl \
 && curl -Lo terraform_${TF_VER}_SHA256SUMS \
    ${TF_BASEURL}/${TF_VER}/terraform_${TF_VER}_SHA256SUMS \
 && curl -Lo terraform_${TF_VER}_linux_amd64.zip \
    ${TF_BASEURL}/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip \
 && sha256sum -c terraform_${TF_VER}_SHA256SUMS 2>&1 | \
    grep terraform_${TF_VER}_linux_amd64.zip \
 && unzip terraform_${TF_VER}_linux_amd64.zip \
 && rm terraform_${TF_VER}_linux_amd64.zip terraform_${TF_VER}_SHA256SUMS \
 && curl -Lo terragrunt ${TG_BASEURL}/v${TG_VER}/terragrunt_linux_amd64 \
 && chmod +x terraform terragrunt

FROM alpine:3.17.0

ENV USER user

RUN addgroup -g 1000 -S ${USER} \
 && adduser -u 1000 -S ${USER} -G ${USER} -h /home/${USER}

COPY --from=build /build /usr/bin

RUN apk add --no-cache --update ansible

USER ${USER}

WORKDIR /code
