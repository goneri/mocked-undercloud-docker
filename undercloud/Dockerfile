FROM       registry.access.redhat.com/rhel7
MAINTAINER Gonéri Le Bouder <goneri@lebouder.net>

COPY rhel.repo /etc/yum.repos.d
RUN yum -y update && yum clean all
RUN yum install -y openssh-server python sudo && yum clean all
RUN ln -fs /usr/share/zoneinfo/America/Toronto /etc/localtime

RUN useradd --create-home --shell /bin/bash stack
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa

RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 644 /root/.ssh/authorized_keys

RUN mkdir /home/stack/.ssh
RUN chmod 700 /home/stack/.ssh
COPY authorized_keys /home/stack/.ssh/authorized_keys
RUN chmod 644 /home/stack/.ssh/authorized_keys
RUN chown stack:stack -R /home/stack/.ssh
RUN echo 'stack  ALL=(ALL)       NOPASSWD: ALL' > /etc/sudoers.d/stack
USER stack
RUN ssh-keygen -f /home/stack/.ssh/id_rsa -N '' -t rsa

USER root
RUN rm -f /etc/nologin /var/run/nologin

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
