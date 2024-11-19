#!/bin/bash

function Installwireguard() {
	sudo ufw disable
	sudo systemctl stop ufw
	sudo systemctl disable ufw
	sudo apt update
	apt install net-tools
	sudo apt install openresolv
	sudo apt install resolvconf
	echo "-----------------------以下是本机的所有网卡-------------------------"
	ifconfig | awk -F'[ :]+' '!NF{if(eth!=""&&ip=="")print eth;eth=ip4=""}/^[^ ]/{eth=$1}/inet addr:/{ip=$4}'
	
	local ethname="eth0"
	read -p "请输入网卡名称  默认:eth0   " input_eth
	[ -z "${input_eth}" ] && input_eth=${ethname}
	echo "网卡名称 = ${input_eth}"
	

	local ipaddress=$(get_ip)
	read -p "请输入IP地址  默认:${ipaddress}   " input_IP
	[ -z "${input_IP}" ] && input_IP=${ipaddress}
	echo $input_IP
	
	default_port=7328
	read -p "请设置WG的端口  默认:${default_port}   " input_port
	[ -z "${input_port}" ] && input_port=${default_port}
	
	
	
	echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
	echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf
	sysctl -p
	apt install wireguard
	
	cat >/etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = 0AVZVoZGDXlqnj2nc3cQ7UwszGmhL7ayHm/R+BzruGg=
Address = 10.0.0.1/24
DNS = 114.114.114.114
ListenPort = $input_port
PostUp   = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $input_eth -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $input_eth -j MASQUERADE
PreUp = iptables -t nat -A PREROUTING -d $input_IP -p tcp --dport 30303 -j DNAT --to-destination 10.0.0.100
PostDown = iptables -t nat -D PREROUTING -d $input_IP -p tcp --dport 30303 -j DNAT --to-destination 10.0.0.100
PreUp = iptables -t nat -A PREROUTING -d $input_IP -p udp --dport 30303 -j DNAT --to-destination 10.0.0.100
PostDown = iptables -t nat -D PREROUTING -d $input_IP -p udp --dport 30303 -j DNAT --to-destination 10.0.0.100
PreUp = iptables -t nat -A PREROUTING -d $input_IP -p tcp --dport 13000 -j DNAT --to-destination 10.0.0.100
PostDown = iptables -t nat -D PREROUTING -d $input_IP -p tcp --dport 13000 -j DNAT --to-destination 10.0.0.100
PreUp = iptables -t nat -A PREROUTING -d $input_IP -p udp --dport 12000 -j DNAT --to-destination 10.0.0.100
PostDown = iptables -t nat -D PREROUTING -d $input_IP -p udp --dport 12000 -j DNAT --to-destination 10.0.0.100

[Peer]
PublicKey = 0UGcIET3aabDYSneAoKADPJLUz61bB7kyXve6DV1oi8=
AllowedIPs = 10.0.0.100/32

[Peer]
PublicKey = Z5QQvPJ54j9nLfzsB9KtaxgJpUo9xr/9ZdF7IlLB3wA=
AllowedIPs = 10.0.0.101/32

EOF
	wg-quick up wg0
	systemctl enable wg-quick@wg0
	
}


function Installudp2raw() {
	local WG_port=${input_port}
	read -p "请输入WG的端口  默认:${WG_port}   " input_WG_port
	[ -z "${input_WG_port}" ] && input_WG_port=${WG_port}
	
	local UDP2Raw_port=20240
	read -p "请输入UDP2Raw的通信端口  默认:${UDP2Raw_port}   " input_UDP2Raw_port
	[ -z "${input_UDP2Raw_port}" ] && input_UDP2Raw_port=${UDP2Raw_port}
	
	
	mkdir /usr/udp2raw
	cd /usr/udp2raw
	wget https://github.com/wangyu-/udp2raw/releases/download/20230206.0/udp2raw_binaries.tar.gz -O udp2raw_binaries.tar.gz
	tar -zxvf udp2raw_binaries.tar.gz
	cat >/etc/systemd/system/udp2raw.service <<EOF
[Unit]
Description=udp2raw
After=network.target
[Service]
Type=simple
ExecStart=/usr/udp2raw/udp2raw_amd64 -s -l0.0.0.0:${input_UDP2Raw_port} -r 127.0.0.1:${input_WG_port} -k aa123123 --raw-mode faketcp -a
Restart=always
RestartSec=10
AmbientCapabilities=CAP_NET_BIND_SERVICE
[Install]
WantedBy=multi-user.target
EOF
	chmod 777 /etc/systemd/system/udp2raw.service
	systemctl daemon-reload
	systemctl enable udp2raw

}

function abcdefg() {
	local WG_port=${input_port}
	read -p "请输入WG的端口  默认:${WG_port}   " input_WG_port
	[ -z "${input_WG_port}" ] && input_WG_port=${WG_port}
	
	local UDP2Raw_port=20240
	read -p "请输入UDP2Raw的通信端口  默认:${UDP2Raw_port}   " input_UDP2Raw_port
	[ -z "${input_UDP2Raw_port}" ] && input_UDP2Raw_port=${UDP2Raw_port}
	
	
	mkdir /usr/udp2raw
	cd /usr/udp2raw
	wget https://github.com/wangyu-/udp2raw/releases/download/20230206.0/udp2raw_binaries.tar.gz -O udp2raw_binaries.tar.gz
	tar -zxvf udp2raw_binaries.tar.gz
	cat >/etc/systemd/system/udp2raw.service <<EOF
[Unit]
Description=udp2raw
After=network.target
[Service]
Type=simple
ExecStart=/usr/udp2raw/udp2raw_amd64 -s -l0.0.0.0:${input_UDP2Raw_port} -r 127.0.0.1:${input_WG_port} -k aa123123 --raw-mode faketcp -a
Restart=always
RestartSec=10
AmbientCapabilities=CAP_NET_BIND_SERVICE
[Install]
WantedBy=multi-user.target
EOF
	chmod 777 /etc/systemd/system/udp2raw.service
	systemctl daemon-reload
	systemctl enable udp2raw

}


function get_ip() {
    public_ip=$(ip a | grep inet | grep -v inet6 | grep -v '127.0.0.1' | grep -v '10.0.0.1' | awk '{print $2}' | awk -F / '{print$1}')
    echo $public_ip
}

Start() {
	while true;do
		echo "1. 一键安装Wireguard"
		echo "8. 退出"
		read -p "(请选择您需要的操作:" input_provider
		if [ ${input_provider} == 1 ]; then
			Installwireguard
			break
		fi

		if [ ${input_provider} == 8 ]; then
			break
		fi
	done
}
Start
