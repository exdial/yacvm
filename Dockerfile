FROM alpine:3.15.0 as build

ENV TF_VER 1.1.0
ENV TF_BASEURL https://releases.hashicorp.com/terraform

WORKDIR /usr/bin

RUN apk add --no-cache --update curl \
 && curl -Lo terraform_${TF_VER}_SHA256SUMS \
    ${TF_BASEURL}/${TF_VER}/terraform_${TF_VER}_SHA256SUMS \
 && curl -Lo terraform_${TF_VER}_linux_amd64.zip \
    ${TF_BASEURL}/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip \
 && sha256sum -c terraform_${TF_VER}_SHA256SUMS 2>&1 | \
    grep terraform_${TF_VER}_linux_amd64.zip \
 && unzip terraform_${TF_VER}_linux_amd64.zip \
 && rm terraform_${TF_VER}_linux_amd64.zip \
 && chmod +x terraform


FROM alpine:3.15.0

ENV USER user

RUN addgroup -g 1000 -S ${USER} \
 && adduser -u 1000 -S ${USER} -G ${USER} -h /home/${USER}

COPY --from=build /usr/bin/terraform /usr/bin/terraform

RUN apk add --no-cache --update ansible

USER ${USER}
