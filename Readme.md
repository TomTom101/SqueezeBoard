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

### Server
$ npm install pm2 -g

#### Run
$ pm2 start /home/pi/SqueezeBoard/server.js --name "SqueezeBoard"
$ pm2 save
$ pm2 startup
