#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import usb.core
import usb.util
from time import sleep
from struct import unpack_from, calcsize

DEBUG = False

def mapNum(value, in_min, in_max, out_min, out_max):
    return int((value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)

vendor = 0x03eb
product = 0x2013
# find our device
dev = usb.core.find(idVendor=vendor, idProduct=product)

# was it found?
if dev is None:
    print('😫')
    sys.exit()


if dev.is_kernel_driver_active(0):
    try:
            dev.detach_kernel_driver(0)
    except usb.core.USBError as e:
            sys.exit("Could not detach kernel driver: %s" % str(e))

#dev.set_configuration()

usb.util.claim_interface(dev, 0)

# get an endpoint instance
cfg = dev.get_active_configuration()
intf = cfg[(0,0)]

ep = usb.util.find_descriptor(
    intf,
    # match the first OUT endpoint
    custom_match = \
    lambda e: \
        usb.util.endpoint_direction(e.bEndpointAddress) == \
        usb.util.ENDPOINT_OUT)

assert ep is not None

def read(flush=False):
    try:
        data = dev.read(0x81, 0x0010)
        log("USB returns {} with length {} on read".format(data, len(data)))
        return data
    except usb.core.USBError as e:
        print("Could not read from USB", e)
        if(flush is False):
            print("exiting")
            sys.exit()

def log(msg):
    if(DEBUG is True):
        print(msg)
#Flush
ret = read(flush=True)
if(ret is None):
    sleep(1)
    # Sometimes a 2nd read is required
    ret = read(flush=True)


ret = dev.write(0x02, "\x40\x68\x2a\x54\x52\x0a\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40", 1000)
log("USB returns {} on write".format(ret))

data = read()

assert len(data) > 0
toc, = unpack_from('<H', data, 2)

toc = max(450, min(2000, toc))
print(mapNum(toc, 450, 2000, 100, 0))
