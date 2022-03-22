import hexdump
import pyhamtools
import qdatastream
import socket

UDP_IP = "127.0.0.1" # system running wsjtx
UDP_PORT = 2237
 
sock = socket.socket(socket.AF_INET,
                    socket.SOCK_DGRAM) 
sock.bind((UDP_IP, UDP_PORT))

seq = 0 # set starting number to 0

        
while True:
    data, addr = sock.recvfrom(1024) # 1024 byte buffer size 
    seq += 1 # inc message number
    print("decode message " + str(seq) + ": %s" % data)


# Refrence from https://sourceforge.net/p/wsjt/wsjt/8190/tree/tags/wsjtx-1.8.0/NetworkMessage.hpp#l58    
#      QDateTime:
#           QDate      qint64    Julian day number
#           QTime      quint32   Milli-seconds since midnight
#           timespec   quint8    0=local, 1=UTC, 2=Offset from UTC
#                                                 (seconds)
#                                3=time zone
#           offset     qint32    only present if timespec=2
#           timezone   several-fields only present if timespec=3

#  Decode        Out       2                      quint32
#                          Id (unique key)        utf8
#                          New                    bool
#                          Time                   QTime
#                          snr                    qint32
#                          Delta time (S)         float (serialized as double)
#                          Delta frequency (Hz)   quint32
#                          Mode                   utf8
#                          Message                utf8
#                          Low confidence         bool
#                          Off air                bool

    
def decode_wsjtx(d,m):
	m["id"] = d.read_bytes()
	m["new"] = d.read_bool()
	m["time"] = d.read_uint32()
	m["snr"] = d.read_int32()
	m["deltatime"] = d.read_double()
	m["deltafreq"] = d.read_uint32()
	m["mode"] = d.read_bytes()
	m["messageraw"] = d.read_bytes()
	m["message"] = m["messageraw"].decode("utf-8")
	m["conf"] = d.read_bool()
	m["cq"] = m["message"].startswith("CQ")
	
	if m["cq"]:
		t = m["message"].split(" ")
		m["call"] = t[-2]
		m["grid"] = t[-1]    
		m["dx"] = len(t)>3
        
def decode_qdatetime(d):
    dt = dict()
    dt["day"] = d.read_int64()
    dt["ms"] = d.read_uint32()
    dt["timespec"] = d.read_uint8()
    if dt["timespec"] == 2:
        dt["offset"] = d.read_int32()
    if dt["timespec"] == 3:
        print ("FAIL TODO")

    return(dt)