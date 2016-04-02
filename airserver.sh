### BEGIN INIT INFO
# Provides:             airsensor
# Required-Start:
# Required-Stop:
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    Supply SqueezeBoard w/ airsensor data
### END INIT INFO

export NODE_PATH=$NODE_PATH:/usr/local/bin
export HOME=/root
NODESCRIPT=/home/pi/SqueezeBoard/

case "$1" in
  start)
    sudo -u pi forever start -p /home/pi/.forever --sourceDir=$NODESCRIPT server.js
    ;;
  stop)
    sudo -u pi forever stop -p /home/pi/.forever ${NODESCRIPT}server.js
    ;;
  *)

  echo "Usage: /etc/init.d/airsensor {start|stop}"
  exit 1
  ;;
esac
exit 0
