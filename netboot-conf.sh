#!/bin/bash

clear

echo ''
echo ''
echo '=========================='
echo '=====脚本来自：www.littlemo.cc====='
echo '=========================='
echo ''
echo ''

if [[ -f /etc/redhat-release ]]; then
  release="centos"
elif cat /etc/issue | grep -q -E -i "debian"; then
  release="debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
  release="ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
  release="centos"
elif cat /proc/version | grep -q -E -i "debian"; then
  release="debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
  release="ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
  release="centos"
  fi

[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1

if [[ "${release}" == "centos" ]]; then
  yum -y update && yum -y install wget
elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
  apt-get -y update && apt-get -y install wget
fi

mkdir /boot/debian-netboot-install

wget -P /boot/debian-netboot-install https://mirrors.tuna.tsinghua.edu.cn/debian/dists/bullseye/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz

wget -P /boot/debian-netboot-install https://mirrors.tuna.tsinghua.edu.cn/debian/dists/bullseye/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux

cat > /etc/grub.d/40_custom << EOF
#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
menuentry 'debian-netboot-install' {
set root='hd0,msdos1'
linux /boot/debian-netboot-install/linux
initrd /boot/debian-netboot-install/initrd.gz
}
EOF

sed -i '/^GRUB_TIMEOUT/d' /etc/default/grub

echo "GRUB_TIMEOUT=60" >> /etc/default/grub

if [[ "${release}" == "centos" ]]; then
  grub2-mkconfig -o /etc/grub2.cfg
elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
  update-grub
fi

echo ''
echo ''
echo ''
echo "配置完成，连接VNC后重启机器即可在启动菜单选择 debian-netboot-install"
echo ''
echo ''
