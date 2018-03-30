echo "SSH key"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2IRyRs0wK/9uMjJt7ZxX8Rb8VDnrCzhHwkykqLtjCyidm0xZrdbOM2X4U6TjDl8G2hp3ZZ2lamBVYCiv9IfjADzQfuhxfHnj+6ORMe8LVDXTd4HkEurnk28UYzkNq0qZekKkMAdQi3GQWmcauOXGLL/9gfTwRwxE7repBXXIWB5h0ye6KZs1hhNGBiWNwxyZotyLHS6JxpD0dBQlWlzAtPcCDCifgxwoue1jTHQ0Ll+kUgdeJbxYRB3GSoHl2rleTJwOxUBhbivG3VsY0eNlr0HWxfIuYBvIgZFfOKEkLAz1gefo131otXwuiWSVJwYtcPuv2RRvWkMQhJXSIieMk5IuAZqYGpwUc5dUj3UhmDGPqzQRvTUWqtDW6LJsAifJnlU1/3Oj0xNRTDDrXF76MQNWWOx6oGUh31gwq04MIsoAWYxzFaFUUOaz9HnYvzlfHQYsdEnBOTxfGiA4JkGDmRrQPT/6Fmb53tLiTVvKHuYbLlalh9XY49jiDkRAbnzxiQfcEf3QV6i8xgXLI4sIgEsfv9AwcvXEMgm6U8RbRqAUIQVpD1DZ+ojZ5h0ZxG6Rh4+vOE/QlRccW5eE/HwUCXkQX7lILxvLjLoELV/StIO0WGR5rBZNPBNC+lW/Nux7At8I6s3FqwdNLo3cHle8I39Kx/TFDDIgRYxp3mHAi+Q== " >> ~/.ssh/authorized_keys
chmod 644 ~/.ssh/authorized_keys

echo "Securing root Logins"
echo "tty1" > /etc/securetty
chmod 700 /root

echo "DISABLE FIREWALL, POSTFIX"
systemctl disable firewalld
systemctl disable postfix

echo "Deny All TCP Wrappers"
echo "ALL:ALL" >> /etc/hosts.deny
echo "sshd:ALL" >> /etc/hosts.allow

echo "EDIT SYSCTL"
echo "fs.suid_dumpable = 0" >>/etc/sysctl.conf
echo "fs.suid_dumpable = 0" >>/etc/sysctl.conf
echo "kernel.exec-shield = 1" >>/etc/sysctl.conf
echo "net.core.somaxconn= 2048" >>/etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" >>/etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >>/etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >>/etc/sysctl.conf
echo "net.ipv4.tcp_syncookies = 1" >>/etc/sysctl.conf
echo "vm.swappiness=0" >>/etc/sysctl.conf
echo "vm.overcommit_memory=1" >>/etc/sysctl.conf
sysctl -p

echo "DISABLE IPV6"
echo "options ipv6 disable=1" >>/etc/modprobe.d/disabled.conf
echo "NETWORKING_IPV6=no" >>/etc/modprobe.d/disabled.conf
echo "IPV6INIT=no" >>/etc/modprobe.d/disabled.conf

echo "EDIT LIMITS.CONF"
echo "* hard core 0" >>/etc/security/limits.conf
echo "* soft nofile 32768" >>/etc/security/limits.conf
echo "* soft nproc 65536" >>/etc/security/limits.conf
echo "* hard nofile 1048576" >>/etc/security/limits.conf
echo "* hard nproc unlimited" >>/etc/security/limits.conf
echo "* hard memlock unlimited" >>/etc/security/limits.conf
echo "* soft memlock unlimited" >>/etc/security/limits.conf

echo "ENABLE HUGEPAGE"
echo "if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi" >> /etc/rc.d/rc.local

echo "if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi" >>/etc/rc.d/rc.local

echo "INSTALL EPEL-RELEASE"
yum install epel-release -y
yum install  iptables-services net-tools htop glances tuned chrony wget -y
yum groupinstall "Development Tools" -y

echo "INSTALL Rsyslog"
yum -y install rsyslog
systemctl enable rsyslog.service
systemctl start rsyslog.service

echo "SET TIMEZONE"
timedatectl set-timezone Asia/Ho_Chi_Minh

systemctl enable iptables chronyd crond tuned
systemctl start chronyd
chronyc tracking

echo "IF RUN TUNED ==> "
echo "tuned-adm profile throughput-performance"
echo "EDIT SELINUX"
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux