import usb.core
import usb.util
from time import sleep
from struct import unpack_from, calcsize

vendor = 0x03eb
product = 0x2013
# find our device
dev = usb.core.find(idVendor=vendor, idProduct=product)

# was it found?
if dev is None:
    raise ValueError('Device not found')


if dev.is_kernel_driver_active(0):
    try:
            dev.detach_kernel_driver(0)
            print ("kernel driver detached")
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

def read():
    try:
        return dev.read(0x81, 0x10, 1000)
    except usb.core.USBError:
        print("?")

#Flush
read()

ret = dev.write(0x02, "\x40\x68\x2a\x54\x52\x0a\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40", 1000)
#print("USB returns {} on write".format(ret))

data = read()
#print("USB returns {} with length {} on read".format(data, len(data)))

toc, = unpack_from('<H', data, 2)
print(toc)
