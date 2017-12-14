## Install node

Install nvm
$ nvm install 6
$ npm install steroids -g


### Install app
$ steroids deploy
https://cloud.appgyver.com/applications/91514
$ adb install -r app-….apk

### Install openhab2

$ apt-get install openhab2

/var/log muss schreibbar sein, ist es nicht mit den settings in fstab

In /usr/share/openhab2/runtime/services.cfg:

`org.eclipse.smarthome.cors:enable=true`

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
$ npm install pm2@latest -g

#### Run

$ pm2 start config.js
$ pm2 save
$ sudo pm2 unstartup
$ sudo pm2 startup -u pi

Darauf achten dass der dump auch der ist, der per save gespeichert wurde
> Restoring processes located in /home/pi/.pm2/dump.pm2
