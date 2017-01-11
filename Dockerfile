FROM fedora:23
MAINTAINER "CI StormCloud Team <vaclav.adamec@avg.com>"

ENV TERRAFORM_VERSION=0.8.1
ENV TERRAFORM_SHA256SUM=da98894a79b7e97ddcb2a1fed7700d3f53c3660f294fb709e1d52c9baaee5c59

RUN dnf install -y bash wget ansible unzip openssh-clients graphviz

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS ./
ADD https://github.com/hashicorp/terraform/tree/master/examples/openstack-with-networking /code/

RUN sed -i '/terraform_${TERRAFORM_VERSION}_linux_amd64.zip/!d' terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS 2>&1  | egrep -e '(OK|FAILED)$'; echo $?

RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin; rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

CMD ["/bin/bash"]
