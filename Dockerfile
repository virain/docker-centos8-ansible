FROM centos:8
ENV container=docker

ENV pip_packages "ansible"

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

COPY CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo

# Install requirements.
RUN dnf makecache  \
 && dnf -y install rpm centos-release epel-release initscripts \
 && sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel* \
 && sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel* \
 && dnf -y update \
 && dnf -y install \
      vim \
      wget \
      sudo \
      which \
      hostname \
      python3 \
      python3-pip \
      unzip \
      'dnf-command(config-manager)' \
      git

RUN echo "fastestmirror=True" >> /etc/dnf/dnf.conf

COPY pip /root/.pip

# Install Ansible via Pip.
RUN pip3 install $pip_packages -i https://mirrors.aliyun.com/pypi/simple/

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
