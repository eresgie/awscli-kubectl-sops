FROM alpine:3.11.6

ENV GLIBC_VER=2.31-r0
ENV KUBECTL_VER=v1.18.2
ENV AWS_IAM_AUTHENTICATOR_VER=1.16.8
ENV SOPS_VER=v3.5.0

# install glibc compatibility for alpine
RUN apk --no-cache add \
        binutils \
        curl \
        gettext \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install

RUN	mkdir -p /aws \
  && curl -o /usr/local/bin/kubectl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VER}/bin/linux/amd64/kubectl \
  && chmod +x /usr/local/bin/kubectl \
  && curl -o /usr/local/bin/aws-iam-authenticator -L https://amazon-eks.s3.us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VER}/2020-04-16/bin/linux/amd64/aws-iam-authenticator \
  && chmod +x /usr/local/bin/aws-iam-authenticator \
  && curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VER}/sops-${SOPS_VER}.linux \
  && chmod +x /usr/local/bin/sops

# cleanup
RUN rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples \
  && apk --no-cache del \
      binutils \
      curl \
  && rm glibc-${GLIBC_VER}.apk \
  && rm glibc-bin-${GLIBC_VER}.apk \
  && rm -rf /var/cache/apk/*

WORKDIR /aws
ENTRYPOINT ["aws"]
