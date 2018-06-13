FROM       registry.access.redhat.com/rhel7
MAINTAINER Gonéri Le Bouder <goneri@lebouder.net>

ARG DCI_TOPIC=OSP10
COPY rhel.repo /etc/yum.repos.d
RUN yum -y update && yum clean all
RUN yum install -y https://packages.distributed-ci.io/dci-release.el7.noarch.rpm
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y openssh-server python sudo dci-ansible-agent iproute openssh-clients && yum clean all

RUN ln -fs /usr/share/zoneinfo/America/Toronto /etc/localtime
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa

RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh
COPY id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 644 /root/.ssh/authorized_keys

RUN printf "tempest_config: false\nrun_tempest: false\ninventory: undercloud\nrun_tripleo_validations: false\nrun_tripleo_validations_setup: false\nskip_certification_role: false\n" >> /etc/dci-ansible-agent/settings.yml
COPY dcirc_${DCI_TOPIC}.sh /etc/dci-ansible-agent/dcirc.sh
COPY running.yml /etc/dci-ansible-agent/hooks
COPY teardown.yml /etc/dci-ansible-agent/hooks

COPY chronyc /usr/local/bin
COPY docker.service /etc/systemd/system/docker.service
COPY dci-ansible-agent.service /etc/systemd/system/dci-ansible-agent.service

EXPOSE 80
EXPOSE 5000

RUN sed -i "s,dci_topic: .*,dci_topic: ${DCI_TOPIC}," /etc/dci-ansible-agent/settings.yml
RUN rm -f /etc/nologin /var/run/nologin

CMD ["/sbin/init"]
