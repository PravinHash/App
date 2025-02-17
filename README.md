
# GUI QT application as a startup service systemd

## Service file 

[Unit]
Description=My GUI Application
After=multi-user.target

[Service]
Type=simple
Environment=DISPLAY=:0
Environment=QT_QPA_PLATFORM=xcb
ExecStart=/home/darkcode/ARCH/SmartMainApp/build/6_8_1_Self-Release/appSmartMai>
Restart=always
RestartSec=3
User=darkcode

[Install]
WantedBy=multi-user.target


## Commands 

```sh 
sudo nano /etc/systemd/system/test.service
```


```sh 
sudo systemctl daemon-reload
```

```sh 
sudo systemctl restart test.service
```

```sh 
sudo systemctl status test.service
```

```sh 
sudo journalctl -u test.service -n 20 -f
```


```sh 
sudo journalctl -u test.service -n 20 -f
```

```sh 
xrandr --query
```

```sh 
 xhost +SI:localuser:darkcode
```