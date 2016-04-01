Plugins used
[
  {"source":"https://github.com/fiscal-cliff/phonegap-plugin-brightness.git"},
  {"source":"https://github.com/MangoTools/cordova-plugin-lightSensor.git"}
]


### Airsensor
#### Compile
sudo apt-get install libusb-dev
sudo vi /etc/udev/rules.d/99-usb.rules
SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", ATTR{idProduct}=="2013", MODE="0666"
gcc -o airsensor airsensor.c -lusb

#### Run
$ forever start -p /home/pi/.forever --sourceDir=/home/pi/airsensor server.js


npm install forever -g
$ chown pi:pi airserver.sh && chmod +x airserver.sh
$ cp airserver.sh /etc/init.d/
$ sudo update-rc.d airserver.sh defaults
$ /etc/init.d/airserver.sh start
