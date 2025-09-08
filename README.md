通过ipmitool控制华南H12D-8D的风扇速度
按照主板进气温度Inlet_Temp为标准控制

安装
```
mkdir -r /opt/autofan
cp autofan.sh /opt/autofan
chmod 700 /opt/autofan

cp autofan.service /etc/systemd/system
systemctl daemon-reload
systemctl enable autofan
systemctl start autofan
```