FROM fedora:23
MAINTAINER "CI StormCloud Team <vaclav.adamec@avg.com>"

ENV TERRAFORM_VERSION=0.7.13
ENV TERRAFORM_SHA256SUM=5a4f762a194542d38406b9b92c722b57f7910344db084e24c9c43d7719f4aa18

ENV K8S_VERSION=v1.5.1
ENV K8S_SHA256SUM=4d56b8fbec4a274a61893d244bfce532cadf313632a31a065a0edf7130066ac6

RUN dnf install -y bash wget ansible unzip openssh-clients graphviz

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS ./
ADD https://github.com/hashicorp/terraform/tree/master/examples/openstack-with-networking /code/

RUN sed -i '/terraform_${TERRAFORM_VERSION}_linux_amd64.zip/!d' terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS 2>&1  | egrep -e '(OK|FAILED)$'; echo $?

RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin; rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ADD https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl ./
RUN chmod +x ./kubectl
RUN mv ./kubectl /bin/kubectl

CMD ["/bin/bash"]
