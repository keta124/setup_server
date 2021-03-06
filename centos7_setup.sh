echo "SSH key"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2IRyRs0wK/9uMjJt7ZxX8Rb8VDnrCzhHwkykqLtjCyidm0xZrdbOM2X4U6TjDl8G2hp3ZZ2lamBVYCiv9IfjADzQfuhxfHnj+6ORMe8LVDXTd4HkEurnk28UYzkNq0qZekKkMAdQi3GQWmcauOXGLL/9gfTwRwxE7repBXXIWB5h0ye6KZs1hhNGBiWNwxyZotyLHS6JxpD0dBQlWlzAtPcCDCifgxwoue1jTHQ0Ll+kUgdeJbxYRB3GSoHl2rleTJwOxUBhbivG3VsY0eNlr0HWxfIuYBvIgZFfOKEkLAz1gefo131otXwuiWSVJwYtcPuv2RRvWkMQhJXSIieMk5IuAZqYGpwUc5dUj3UhmDGPqzQRvTUWqtDW6LJsAifJnlU1/3Oj0xNRTDDrXF76MQNWWOx6oGUh31gwq04MIsoAWYxzFaFUUOaz9HnYvzlfHQYsdEnBOTxfGiA4JkGDmRrQPT/6Fmb53tLiTVvKHuYbLlalh9XY49jiDkRAbnzxiQfcEf3QV6i8xgXLI4sIgEsfv9AwcvXEMgm6U8RbRqAUIQVpD1DZ+ojZ5h0ZxG6Rh4+vOE/QlRccW5eE/HwUCXkQX7lILxvLjLoELV/StIO0WGR5rBZNPBNC+lW/Nux7At8I6s3FqwdNLo3cHle8I39Kx/TFDDIgRYxp3mHAi+Q== " >> ~/.ssh/authorized_keys
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClT+3BWPmexTdCDUd1ZcRTpTinpq3fYcjDjkA6qOc2FgvaO77s25Z9iCrFm0UbSYbOZheeAqCyvAjus5xS6ZEMzwFPS0vqPsLqiEtIgPnBDZaILIhTAHkU5nUH9mtyPKWJuLOWbhRv0hJI+XQUYyGH7HaP+gkoR8kbNMyfdas8lV0aK2qkrBQ2n+em8l44MYeui6g4B8Jqb1YE3/IPDppQ9zdfJg9yg/2XNopJcfTKh5oTtchkEmxtJu+6Z3JZoZmqOVESz3EVGGHepuXFa+0hMEngPuGvTM1mZFdyh8Ei58JM22uqa4lzNtV0yWtlbSzceo0rREICtyCQxK187BklJ6gWtGCq0s5m/APqS4MCGTDXvoPcw0xL7C7xKkLDscivJVx3jKOq9ynRxkd1uc07SSQsX2undDUc62axxELC3g4v3bX8MDVuG+AfzA1QqGXxqhc/FBDJ0gsG4FMHDrR6e24C8Fohs22hd0CAbfzolfX89t8KlJGEe+0ek7pubhVARoEx4ae1MD/fWYQhZtLUtl0SSTAJw0TJN2qAufV+7MViB82TXG/n1+yw4SO8FTWeJuwIJJtHOB8xVxQmG4LnI8uBattd9DEqwZXCD8ZyVIeR+YpNuK7ufhCMFd/XUmJdka9RZpEPrtV7hctyUUE7chMGwCAsQN9CUdy9fPJsaw== sontn" >> ~/.ssh/authorized_keys
chmod 644 ~/.ssh/authorized_keys

echo "Securing root Logins"
echo "tty1" > /etc/securetty
chmod 700 /root

echo "INSTALL EPEL-RELEASE"
yum install epel-release -y
yum install iptables-services net-tools htop glances chrony wget nscd rsyslog -y
yum groupinstall "Development Tools" -y

echo "ENABLE CHRONY"
systemctl enable iptables chronyd crond
systemctl start chronyd
chronyc tracking

echo "DISABLE FIREWALL, POSTFIX"
systemctl disable firewalld
systemctl disable postfix

echo "DISABLE TUNED"
systemctl start tuned
tuned-adm off
systemctl stop tuned
systemctl disable tuned

echo "Start Name Service Caching"
systemctl start nscd.service
systemctl enable nscd.service

echo "INSTALL Rsyslog"
systemctl enable rsyslog.service
systemctl start rsyslog.service

echo "EDIT SYSCTL"
echo "vm.swappiness=1" >>/etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" >>/etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >>/etc/sysctl.conf
echo "net.core.somaxconn= 1024" >>/etc/sysctl.conf
echo "fs.file-max = 6544018" >>/etc/sysctl.conf
sysctl -p

echo "EDIT LIMITS.CONF"
echo "* soft nofile 65536" >>/etc/security/limits.conf
echo "* soft nproc 65536" >>/etc/security/limits.conf
echo "* hard nofile 1048576" >>/etc/security/limits.conf
echo "* hard nproc unlimited" >>/etc/security/limits.conf
echo "root - memlock unlimited" >>/etc/security/limits.conf

echo "ENABLE HUGEPAGE"
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.d/rc.local
echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >>/etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

echo "SET TIMEZONE"
timedatectl set-timezone Asia/Ho_Chi_Minh

echo "Update kernel"
yum update kernel -y

echo "IF RUN TUNED ==> "
echo "tuned-adm profile throughput-performance"
echo "EDIT SELINUX"
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#cmdlog
echo "export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug \"[\$(echo \$SSH_CLIENT | cut -d\" \" -f1)] # \$(history 1 | sed \"s/^[ ]*[0-9]\+[ ]*//\" )\"'" >>/etc/bashrc
echo "local6.debug                /var/log/cmdlog.log" >> /etc/rsyslog.conf
>/var/log/cmdlog.log
service rsyslog restart
echo "/var/log/cmdlog.log {
  create 0644 root root
  compress
  weekly
  rotate 12
  sharedscripts
  postrotate
  /bin/kill -HUP \`cat /var/run/syslogd.pid 2> /dev/null\` 2> /dev/null || true
  endscript
}" >>/etc/logrotate.d/cmdlog


