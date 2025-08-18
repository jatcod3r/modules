FROM registry.nestybox.com/nestybox/sysbox-deploy-k8s:v0.6.6-0

USER root

RUN sed -i.bk '91c\    ' /opt/sysbox/scripts/sysbox-installer-helper.sh
RUN sed -i.bk '94c\    yum install -y ca-certificates' /opt/sysbox/scripts/sysbox-installer-helper.sh
RUN sed -i.bk '95c\    yum update -y' /opt/sysbox/scripts/sysbox-installer-helper.sh
RUN sed -i.bk '96c\    yum install -y rsync fuse iptables' /opt/sysbox/scripts/sysbox-installer-helper.sh

RUN sed -i.bk '114c\   yum install -y make dkms' /opt/sysbox/scripts/sysbox-installer-helper.sh
RUN sed -i.bk '122c\   yum uninstall -y make dkms' /opt/sysbox/scripts/sysbox-installer-helper.sh

RUN sed -i.bk '1069s/^/#/' /opt/sysbox/scripts/sysbox-deploy-k8s.sh
RUN sed -i.bk '4s/^/#/' /opt/sysbox/systemd/99-sysbox-sysctl.conf

RUN  sed -i.bk '277a\                [[ "$distro" =~ "amzn" ]] ||' /opt/sysbox/scripts/sysbox-deploy-k8s.sh
RUN  sed -i.bk '749a\                [[ "$distro" =~ "amzn" ]] ||' /opt/sysbox/scripts/sysbox-deploy-k8s.sh
RUN  sed -i.bk '277a\                [[ "$distro" == "ubuntu-24.04" ]] ||' /opt/sysbox/scripts/sysbox-deploy-k8s.sh
RUN  sed -i.bk '749a\                [[ "$distro" == "ubuntu-24.04" ]] ||' /opt/sysbox/scripts/sysbox-deploy-k8s.sh