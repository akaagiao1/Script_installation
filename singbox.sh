#!/bin/bash

# 更新系统和安装必要的软件包
apt update -y && apt install -y curl

# 创建证书和密钥的目录
mkdir -p /root/hysteria

# 生成密钥和自签名证书
openssl ecparam -genkey -name prime256v1 -out /root/hysteria/private.key
openssl req -new -x509 -days 36500 -key /root/hysteria/private.key -out /root/hysteria/cert.pem -subj "/CN=bing.com"

# 定义配置文件内容
config_json=$(cat <<EOF{    "inbounds": [        {            "type": "tuic",            "listen": "::",            "listen_port": 34443,            "users": [                {                    "uuid": "07d5407d-545f-44e6-ba28-ca167e8bb180",                    "password": ""                }            ],            "congestion_control": "bbr",            "tls": {                "enabled": true,                "alpn": [                    "h3"                ],                "certificate_path": "/root/hysteria/cert.pem",                "key_path": "/root/hysteria/private.key"            }        }    ],    "outbounds": [        {            "type": "direct"        }    ]}EOF)# 使用cat命令将配置内容写入到指定文件cat > /usr/local/etc/sing-box/config.json <<EOF$config_json
EOF

# 重启sing-box服务并检查状态
systemctl restart sing-box
systemctl status sing-box

exit 0
