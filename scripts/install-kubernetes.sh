#/bin/bash

####################################################
#Install kubernetes with dockers                   
###################################################

#Install docker

	if [[ $(rpm -qa | grep -c docker-ce) -ne 1 ]]
		then
		yum remove -y docker docker-common container-selinux docker-selinux docker-engine
		yum install -y yum-utils device-mapper-persistent-data lvm2
		yum-config-manager --add-repo  "https://download.docker.com/linux/centos/docker-ce.repo"
		yum-config-manager --enable docker-ce-edge
		yum makecache fast -y
		yum install docker-ce -y
		yum-config-manager --disable docker-ce-edge
#Make sure docker using the right drivers:
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=cgroupfs"]
}
EOF
		systemctl enable docker
		systemctl start docker
		yum install python2-pip -y
		pip install --upgrade pip
		pip install docker-compose
		
		echo "Docker succefully installed"

	fi

#Install kubeadm and kubectl

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
	setenforce 0
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	yum install -y kubelet kubeadm kubectl
	systemctl enable kubelet && systemctl start kubelet
#Some users on RHEL/CentOS 7 have reported issues with traffic being routed incorrectly due to iptables being bypassed. You should ensure
#net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config, e.g.

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
EOF
sysctl --system

	if [[ $(docker info | grep -ic cgroup) -eq 1 ]]
		then 
		sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
	fi
systemctl daemon-reload
systemctl restart kubelet

kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-
